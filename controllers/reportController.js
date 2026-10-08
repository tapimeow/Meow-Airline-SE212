// controllers/reportController.js
//
// Owner: [Phase 4 · Backend · Kawintida]
//
// Report handlers return JSON so the frontend can use the same parameterized
// report data without embedding SQL in EJS templates.
//
// Q3 income follows the agreed definition in docs/DATABASE.md: sum live-ticket
// fare prices by route, rather than trying to allocate reservation payments.
const pool = require('../config/db');

exports.index = (req, res) => res.json({ reports: [
  '/reports/free-seats?flightId=<id>',
  '/reports/passenger-bookings?passengerId=<id>',
  '/reports/route-income?month=YYYY-MM'
] });

exports.freeSeats = async (req, res, next) => {
  try {
    const id = Number(req.query.flightId);
    if (!Number.isInteger(id) || id < 1) return res.status(400).json({ error: 'flightId must be a positive integer.' });
    const [rows] = await pool.execute(`SELECT s.SeatClass, COUNT(*) total_seats,
      COUNT(t.TicketID) sold, COUNT(*) - COUNT(t.TicketID) free
      FROM FLIGHT f JOIN SEAT s ON s.AircraftID=f.AircraftID
      LEFT JOIN TICKET t ON t.FlightID=f.FlightID AND t.SeatID=s.SeatID AND t.TicketStatus <> 'cancelled'
      WHERE f.FlightID=? GROUP BY s.SeatClass ORDER BY s.SeatClass`, [id]);
    res.json(rows);
  } catch (err) { next(err); }
};

exports.passengerBookings = async (req, res, next) => {
  try {
    const id = Number(req.query.passengerId);
    if (!Number.isInteger(id) || id < 1) return res.status(400).json({ error: 'passengerId must be a positive integer.' });
    const [rows] = await pool.execute(`SELECT r.ReservationID, r.BookingDate, r.ReservationStatus,
      COALESCE(p.amount_paid,0) amount_paid,COALESCE(ft.total_due,0) total_due,
      CASE WHEN p.refund_count>0 AND COALESCE(p.amount_paid,0)<=0 THEN 'Refunded'
           WHEN COALESCE(p.amount_paid,0)<=0 THEN 'NOT PAID'
           WHEN COALESCE(p.amount_paid,0)<COALESCE(ft.total_due,0) THEN 'PARTIALLY PAID' ELSE 'Paid' END payment_status,
      f.FlightNo, ro.OriginCode, ro.DestinationCode, f.DepartureTime,
      t.TicketID, t.TicketStatus, tr.Name traveller
      FROM RESERVATION r LEFT JOIN (SELECT ReservationID,
      SUM(CASE WHEN Status='Paid' THEN TotalAmount ELSE -TotalAmount END) amount_paid,
      COUNT(*) payment_count,SUM(Status='Refunded') refund_count FROM PAYMENT GROUP BY ReservationID) p
      ON p.ReservationID=r.ReservationID
      LEFT JOIN (SELECT t.ReservationID,SUM(f.Price) total_due FROM TICKET t JOIN FARE f ON f.FareID=t.FareID
      WHERE t.TicketStatus<>'cancelled' GROUP BY t.ReservationID) ft ON ft.ReservationID=r.ReservationID
      LEFT JOIN TICKET t ON t.ReservationID=r.ReservationID
      LEFT JOIN PASSENGER tr ON tr.PassengerID=t.PassengerID
      LEFT JOIN FLIGHT f ON f.FlightID=t.FlightID LEFT JOIN ROUTE ro ON ro.FlightNo=f.FlightNo
      WHERE r.PassengerID=? GROUP BY r.ReservationID,r.BookingDate,r.ReservationStatus,p.amount_paid,p.payment_count,p.refund_count,ft.total_due,
      f.FlightNo,ro.OriginCode,ro.DestinationCode,f.DepartureTime,t.TicketID,t.TicketStatus,tr.Name
      ORDER BY r.ReservationID,f.DepartureTime`, [id]);
    res.json(rows);
  } catch (err) { next(err); }
};

exports.routeIncome = async (req, res, next) => {
  try {
    const month = req.query.month;
    if (!/^\d{4}-(0[1-9]|1[0-2])$/.test(month || '')) return res.status(400).json({ error: 'month must use YYYY-MM format.' });
    const [rows] = await pool.execute(`SELECT ro.OriginCode,ro.DestinationCode,
      COUNT(t.TicketID) seats_sold,COALESCE(SUM(fa.Price),0) income
      FROM FLIGHT f JOIN ROUTE ro ON ro.FlightNo=f.FlightNo
      LEFT JOIN TICKET t ON t.FlightID=f.FlightID AND t.TicketStatus<>'cancelled'
      LEFT JOIN FARE fa ON fa.FareID=t.FareID
      WHERE f.DepartureTime >= CONCAT(?,'-01') AND f.DepartureTime < DATE_ADD(CONCAT(?,'-01'),INTERVAL 1 MONTH)
      GROUP BY ro.OriginCode,ro.DestinationCode ORDER BY income DESC,ro.OriginCode,ro.DestinationCode`, [month, month]);
    const fewest = rows.length ? Math.min(...rows.map(r => Number(r.seats_sold))) : null;
    res.json({ month, routes: rows, fewestSeatsSold: fewest, fewestRoutes: fewest === null ? [] : rows.filter(r => Number(r.seats_sold) === fewest) });
  } catch (err) { next(err); }
};
