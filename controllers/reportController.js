// Report pages render EJS views; all data and business calculations stay here.
const pool = require('../config/db');

exports.index = (req, res) => res.render('reports/index', { title: 'Reports', error: null });

exports.freeSeats = async (req, res, next) => {
  const selectedFlightId = req.query.flightId || '';
  try {
    const [flights] = await pool.execute(`SELECT f.FlightID,f.FlightNo,f.DepartureTime,r.OriginCode,r.DestinationCode
      FROM FLIGHT f JOIN ROUTE r ON r.FlightNo=f.FlightNo ORDER BY f.DepartureTime`);
    let results = [];
    if (selectedFlightId) {
      if (!/^\d+$/.test(selectedFlightId)) return res.status(400).render('reports/free-seats', { title: 'Free seats by flight', flights, selectedFlightId: '', results, error: 'Choose a valid flight.' });
      [results] = await pool.execute(`SELECT s.SeatClass,COUNT(*) AS total_seats,COUNT(t.TicketID) AS sold,
        COUNT(*)-COUNT(t.TicketID) AS free FROM FLIGHT f JOIN SEAT s ON s.AircraftID=f.AircraftID
        LEFT JOIN TICKET t ON t.FlightID=f.FlightID AND t.SeatID=s.SeatID AND t.TicketStatus<>'cancelled'
        WHERE f.FlightID=? GROUP BY s.SeatClass ORDER BY s.SeatClass`, [selectedFlightId]);
    }
    res.render('reports/free-seats', { title: 'Free seats by flight', flights, selectedFlightId, results, error: null });
  } catch (err) { next(err); }
};

exports.passengerBookings = async (req, res, next) => {
  let selectedPassengerId = req.query.passengerId || '';
  let q = (req.query.q || '').trim();
  try {
    let results = [];
    let matches = [];
    let passenger = null;
    const render = (status, error) => res.status(status).render('reports/passenger-bookings',
      { title: 'Passenger bookings', q, matches, passenger, selectedPassengerId, results, error });
    if (!selectedPassengerId && q) {
      const like = `%${q.replace(/[\\%_]/g, '\\$&')}%`;
      [matches] = await pool.execute(`SELECT PassengerID, Name, PassportNo FROM PASSENGER
        WHERE Name LIKE ? OR PassportNo LIKE ? ORDER BY Name LIMIT 50`, [like, like]);
      if (!matches.length) return render(404, `No passenger matches "${q}".`);
      if (matches.length > 1) return render(200, null);
      selectedPassengerId = String(matches[0].PassengerID);
    }
    if (selectedPassengerId) {
      if (!/^\d+$/.test(selectedPassengerId)) { selectedPassengerId = ''; return render(400, 'Choose a valid passenger.'); }
      [[passenger]] = await pool.execute('SELECT PassengerID, Name, PassportNo FROM PASSENGER WHERE PassengerID=?', [selectedPassengerId]);
      if (!passenger) { selectedPassengerId = ''; return render(404, 'Passenger not found.'); }
      if (!q) q = `${passenger.Name}`;
      [results] = await pool.execute(`SELECT r.ReservationID,r.BookingDate,r.ReservationStatus,
        COALESCE(p.amount_paid,0) AS amount_paid,COALESCE(ft.total_due,0) AS total_due,
        CASE WHEN p.refund_count>0 AND COALESCE(p.amount_paid,0)<=0 THEN 'Refunded'
          WHEN COALESCE(p.amount_paid,0)<=0 THEN 'NOT PAID'
          WHEN COALESCE(p.amount_paid,0)<COALESCE(ft.total_due,0) THEN 'PARTIALLY PAID' ELSE 'Paid' END AS payment_status,
        f.FlightNo,ro.OriginCode,ro.DestinationCode,f.DepartureTime,t.TicketID,t.TicketStatus,tr.Name AS traveller
        FROM RESERVATION r
        LEFT JOIN (SELECT ReservationID,SUM(CASE WHEN Status='Paid' THEN TotalAmount ELSE -TotalAmount END) AS amount_paid,
          SUM(Status='Refunded') AS refund_count FROM PAYMENT GROUP BY ReservationID) p ON p.ReservationID=r.ReservationID
        LEFT JOIN (SELECT t.ReservationID,SUM(f.Price) AS total_due FROM TICKET t JOIN FARE f ON f.FareID=t.FareID
          WHERE t.TicketStatus<>'cancelled' GROUP BY t.ReservationID) ft ON ft.ReservationID=r.ReservationID
        LEFT JOIN TICKET t ON t.ReservationID=r.ReservationID LEFT JOIN PASSENGER tr ON tr.PassengerID=t.PassengerID
        LEFT JOIN FLIGHT f ON f.FlightID=t.FlightID LEFT JOIN ROUTE ro ON ro.FlightNo=f.FlightNo
        WHERE r.PassengerID=? ORDER BY r.ReservationID,f.DepartureTime`, [selectedPassengerId]);
    }
    render(200, null);
  } catch (err) { next(err); }
};

exports.routeIncome = async (req, res, next) => {
  const month = req.query.month || '';
  try {
    // The Month dropdown lists every month that has flights, e.g. '2026-10' -> 'October 2026'.
    const [months] = await pool.execute(`SELECT DISTINCT DATE_FORMAT(DepartureTime,'%Y-%m') AS value,
      DATE_FORMAT(DepartureTime,'%M %Y') AS label FROM FLIGHT ORDER BY value`);
    let routes = [];
    let fewestRoutes = [];
    if (month) {
      if (!/^\d{4}-(0[1-9]|1[0-2])$/.test(month)) return res.status(400).render('reports/route-income', { title: 'Route income', month: '', months, routes, fewestRoutes, error: 'Choose a valid month.' });
      [routes] = await pool.execute(`SELECT r.OriginCode,r.DestinationCode,COUNT(t.TicketID) AS seats_sold,
        COALESCE(SUM(fa.Price),0) AS income FROM FLIGHT f JOIN ROUTE r ON r.FlightNo=f.FlightNo
        LEFT JOIN TICKET t ON t.FlightID=f.FlightID AND t.TicketStatus<>'cancelled'
        LEFT JOIN FARE fa ON fa.FareID=t.FareID
        WHERE f.DepartureTime>=CONCAT(?,'-01') AND f.DepartureTime<DATE_ADD(CONCAT(?,'-01'),INTERVAL 1 MONTH)
        GROUP BY r.OriginCode,r.DestinationCode ORDER BY income DESC,r.OriginCode,r.DestinationCode`, [month, month]);
      if (routes.length) {
        const minimum = Math.min(...routes.map((row) => Number(row.seats_sold)));
        fewestRoutes = routes.filter((row) => Number(row.seats_sold) === minimum);
      }
    }
    res.render('reports/route-income', { title: 'Route income', month, months, routes, fewestRoutes, error: null });
  } catch (err) { next(err); }
};
