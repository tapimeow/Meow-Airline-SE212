const pool = require('../config/db');

const errorMessage = (err) => {
  if (err.code === 'ER_DUP_ENTRY') return 'That seat or traveller already has a live ticket on this flight.';
  if (err.code === 'ER_NO_REFERENCED_ROW_2') return 'Passenger, flight, fare, seat, or staff record was not found.';
  if (err.code === 'ER_SIGNAL_EXCEPTION') return err.sqlMessage || err.message;
  return null;
};

async function reservationFormLocals(body = null) {
  const [passengers] = await pool.execute('SELECT PassengerID, Name, PassportNo FROM PASSENGER ORDER BY Name');
  // Only flights that have not left yet can be booked.
  const [flights] = await pool.execute(`SELECT f.FlightID, f.FlightNo, f.DepartureTime, r.OriginCode, r.DestinationCode
    FROM FLIGHT f JOIN ROUTE r ON r.FlightNo=f.FlightNo
    WHERE f.Status <> 'Cancelled' AND f.DepartureTime > NOW() ORDER BY f.DepartureTime`);
  const [staff] = await pool.execute('SELECT StaffID, StaffName FROM STAFF WHERE StaffRole="BookingStaff" ORDER BY StaffName');
  // The form fills its Fare and Seat dropdowns from these once a flight is picked (public/js/main.js).
  const [fares] = await pool.execute(`SELECT fa.FareID, fa.FlightID, fa.Class, fa.Price
    FROM FARE fa JOIN FLIGHT f ON f.FlightID=fa.FlightID
    WHERE f.Status <> 'Cancelled' AND f.DepartureTime > NOW() ORDER BY fa.FlightID, fa.Price`);
  const [seats] = await pool.execute(`SELECT f.FlightID, s.SeatID, s.SeatNo, s.SeatClass
    FROM FLIGHT f JOIN SEAT s ON s.AircraftID=f.AircraftID
    LEFT JOIN TICKET t ON t.FlightID=f.FlightID AND t.SeatID=s.SeatID AND t.TicketStatus <> 'cancelled'
    WHERE f.Status <> 'Cancelled' AND f.DepartureTime > NOW() AND t.TicketID IS NULL
    ORDER BY f.FlightID, s.SeatID`);
  return { title: 'New reservation', reservation: body, passengers, flights, staff, fares, seats, error: null };
}

async function reservationDetailData(id) {
  const [rows] = await pool.execute(`SELECT r.*, p.Name AS PassengerName, t.TicketID,
      t.PassengerID AS TravellerID, tr.Name AS TravellerName, t.FlightID, fl.FlightNo,
      fl.DepartureTime, t.SeatID, s.SeatNo, t.FareID, f.Price, t.TicketStatus
    FROM RESERVATION r JOIN PASSENGER p ON p.PassengerID=r.PassengerID
    LEFT JOIN TICKET t ON t.ReservationID=r.ReservationID
    LEFT JOIN PASSENGER tr ON tr.PassengerID=t.PassengerID
    LEFT JOIN FLIGHT fl ON fl.FlightID=t.FlightID
    LEFT JOIN SEAT s ON s.SeatID=t.SeatID LEFT JOIN FARE f ON f.FareID=t.FareID
    WHERE r.ReservationID=?`, [id]);
  if (!rows.length) return null;
  const [payments] = await pool.execute('SELECT * FROM PAYMENT WHERE ReservationID=? ORDER BY TimeStamp, PaymentID', [id]);
  return { reservation: rows[0], tickets: rows.filter((row) => row.TicketID), payments };
}
exports.getDetailData = reservationDetailData;

async function renderReservationDetail(req, res, statusCode = 200, error = null) {
  const data = await reservationDetailData(req.params.id);
  if (!data) return res.status(404).send('Reservation not found.');
  return res.status(statusCode).render('reservations/detail', { title: `Reservation #${req.params.id}`, ...data, error });
}

exports.list = async (req, res, next) => {
  try {
    const filters = { passengerId: req.query.passengerId || '', status: req.query.status || '' };
    const [passengers] = await pool.execute('SELECT PassengerID, Name FROM PASSENGER ORDER BY Name');
    const [reservations] = await pool.execute(`SELECT r.*, p.Name AS PassengerName FROM RESERVATION r
      JOIN PASSENGER p ON p.PassengerID=r.PassengerID
      WHERE (? = '' OR r.PassengerID = ?) AND (? = '' OR r.ReservationStatus = ?)
      ORDER BY r.BookingDate DESC, r.ReservationID DESC`, [filters.passengerId, filters.passengerId, filters.status, filters.status]);
    res.render('reservations/list', { title: 'Reservations', reservations, passengers, filters, error: null });
  } catch (err) { next(err); }
};

exports.newForm = async (req, res, next) => {
  try {
    const locals = await reservationFormLocals(null);
    if (req.query.flightId) locals.reservation = { FlightID: req.query.flightId };
    res.render('reservations/form', locals);
  } catch (err) { next(err); }
};

exports.create = async (req, res, next) => {
  const body = req.body;
  const tickets = Array.isArray(body.Tickets) ? body.Tickets : (body.Tickets ? Object.values(body.Tickets) : []);
  // A ticket needs a seat (SeatID is NOT NULL, BR10). When a traveller's flight and
  // fare are picked but the class has no free seat, say which flight and class is full.
  const seatless = tickets.filter((t) => Number(t.FlightID) > 0 && Number(t.FareID) > 0 && !(Number(t.SeatID) > 0));
  if (seatless.length) {
    try {
      const [full] = await pool.query(`SELECT DISTINCT f.FlightNo, fa.Class FROM FARE fa JOIN FLIGHT f ON f.FlightID=fa.FlightID
        WHERE fa.FareID IN (?)`, [seatless.map((t) => Number(t.FareID))]);
      const locals = await reservationFormLocals(body);
      locals.tickets = tickets;
      locals.error = full.map((r) => `${r.FlightNo} has no free ${r.Class} seats.`).join(' ') +
        ' Choose another fare or flight for that traveller.';
      return res.status(409).render('reservations/form', locals);
    } catch (err) { return next(err); }
  }
  const invalid = !Number.isInteger(Number(body.PassengerID)) || Number(body.PassengerID) < 1 ||
    !tickets.length || tickets.some((ticket) => !['PassengerID', 'FlightID', 'SeatID', 'FareID'].every((field) => Number.isInteger(Number(ticket[field])) && Number(ticket[field]) > 0));
  if (invalid) {
    const locals = await reservationFormLocals(body); locals.tickets = tickets; locals.error = 'Choose the booker and provide at least one complete traveller ticket.';
    return res.status(400).render('reservations/form', locals);
  }

  let conn;
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [reservation] = await conn.execute('INSERT INTO RESERVATION (PassengerID, BookingStaffID) VALUES (?, ?)', [Number(body.PassengerID), body.BookingStaffID || null]);
    for (const ticket of tickets) {
      await conn.execute(`INSERT INTO TICKET (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketStatus)
        VALUES (?, ?, ?, ?, ?, 'booked')`, [reservation.insertId, Number(ticket.PassengerID), Number(ticket.FlightID), Number(ticket.SeatID), Number(ticket.FareID)]);
    }
    await conn.commit(); res.redirect(`/reservations/${reservation.insertId}`);
  } catch (err) {
    if (conn) await conn.rollback();
    const message = errorMessage(err);
    if (message) { const locals = await reservationFormLocals(body); locals.tickets = tickets; locals.error = message; return res.status(err.code === 'ER_DUP_ENTRY' ? 409 : 400).render('reservations/form', locals); }
    next(err);
  } finally { if (conn) conn.release(); }
};

exports.detail = async (req, res, next) => {
  try { await renderReservationDetail(req, res); } catch (err) { next(err); }
};

exports.change = async (req, res, next) => {
  const { TicketID, FlightID, SeatID, FareID } = req.body;
  let conn;
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [tickets] = await conn.execute(`SELECT TicketID FROM TICKET WHERE TicketID=? AND ReservationID=? AND TicketStatus='booked' FOR UPDATE`, [TicketID, req.params.id]);
    if (!tickets.length) { await conn.rollback(); return renderReservationDetail(req, res, 404, 'Booked ticket not found or it has already been issued.'); }
    await conn.execute('UPDATE TICKET SET FlightID=?, SeatID=?, FareID=? WHERE TicketID=?', [FlightID, SeatID, FareID, TicketID]);
    await conn.commit(); res.redirect(`/reservations/${req.params.id}`);
  } catch (err) {
    if (conn) await conn.rollback();
    const message = errorMessage(err);
    if (message) return renderReservationDetail(req, res, err.code === 'ER_DUP_ENTRY' ? 409 : 400, message);
    next(err);
  } finally { if (conn) conn.release(); }
};

exports.cancel = async (req, res, next) => {
  let conn;
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [reservation] = await conn.execute('SELECT ReservationStatus FROM RESERVATION WHERE ReservationID=? FOR UPDATE', [req.params.id]);
    if (!reservation.length || reservation[0].ReservationStatus === 'Cancelled') {
      await conn.rollback(); return renderReservationDetail(req, res, 404, 'Active reservation not found.');
    }
    const [checkedIn] = await conn.execute(`SELECT c.CheckInID FROM CHECKIN c JOIN TICKET t ON t.TicketID=c.TicketID
      WHERE t.ReservationID=? LIMIT 1 FOR UPDATE`, [req.params.id]);
    if (checkedIn.length) {
      await conn.rollback(); return renderReservationDetail(req, res, 409, 'This reservation cannot be cancelled because a ticket has already checked in.');
    }
    await conn.execute("UPDATE RESERVATION SET ReservationStatus='Cancelled' WHERE ReservationID=?", [req.params.id]);
    await conn.execute("UPDATE TICKET SET TicketStatus='cancelled' WHERE ReservationID=? AND TicketStatus IN ('booked','issued')", [req.params.id]);
    await conn.commit(); res.redirect(`/reservations/${req.params.id}`);
  } catch (err) { if (conn) await conn.rollback(); next(err); }
  finally { if (conn) conn.release(); }
};
