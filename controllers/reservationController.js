const pool = require('../config/db');

// Convert common MySQL constraint failures into useful booking responses.
const fail = (res, err) => {
  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({
      error: 'That seat or traveller already has a live ticket on this flight.'
    });
  }
  if (err.code === 'ER_NO_REFERENCED_ROW_2') {
    return res.status(400).json({
      error: 'Passenger, flight, fare, seat, or staff record was not found.'
    });
  }
  if (err.code === 'ER_SIGNAL_EXCEPTION') {
    return res.status(400).json({ error: err.sqlMessage || err.message });
  }
  return null;
};

// GET /reservations — optionally filter by passenger and reservation status.
exports.list = async (req, res, next) => {
  try {
    const passengerId = req.query.passengerId || null;
    const status = req.query.status || null;
    const [reservations] = await pool.execute(
      `SELECT r.*, p.Name AS PassengerName
       FROM RESERVATION r
       JOIN PASSENGER p ON p.PassengerID = r.PassengerID
       WHERE (? IS NULL OR r.PassengerID = ?)
         AND (? IS NULL OR r.ReservationStatus = ?)
       ORDER BY r.BookingDate DESC`,
      [passengerId, passengerId, status, status]
    );
    res.json(reservations);
  } catch (err) {
    next(err);
  }
};

// POST /reservations — create the reservation and all its tickets atomically.
exports.create = async (req, res, next) => {
  const { PassengerID, BookingStaffID = null, Tickets } = req.body;
  if (!Number.isInteger(Number(PassengerID)) || !Array.isArray(Tickets) || !Tickets.length) {
    return res.status(400).json({
      error: 'PassengerID and a non-empty Tickets array are required.'
    });
  }

  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();

    const [reservation] = await conn.execute(
      'INSERT INTO RESERVATION (PassengerID, BookingStaffID) VALUES (?, ?)',
      [PassengerID, BookingStaffID || null]
    );

    for (const ticket of Tickets) {
      const fields = ['PassengerID', 'FlightID', 'SeatID', 'FareID'];
      if (!fields.every((field) => ticket[field])) {
        throw Object.assign(
          new Error('Each ticket needs PassengerID, FlightID, SeatID, and FareID.'),
          { status: 400 }
        );
      }
      await conn.execute(
        `INSERT INTO TICKET
           (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketStatus)
         VALUES (?, ?, ?, ?, ?, 'booked')`,
        [reservation.insertId, ticket.PassengerID, ticket.FlightID, ticket.SeatID, ticket.FareID]
      );
    }

    await conn.commit();
    res.status(201).json({ ReservationID: reservation.insertId });
  } catch (err) {
    if (conn) await conn.rollback();
    if (err.status) return res.status(err.status).json({ error: err.message });
    if (fail(res, err)) return;
    next(err);
  } finally {
    if (conn) conn.release();
  }
};

// GET /reservations/:id — return the reservation, tickets, and payment rows.
exports.detail = async (req, res, next) => {
  try {
    const [rows] = await pool.execute(
      `SELECT r.*, p.Name AS PassengerName, t.TicketID,
              t.PassengerID AS TravellerID, tr.Name AS TravellerName,
              t.FlightID, t.SeatID, s.SeatNo, t.FareID, f.Price, t.TicketStatus
       FROM RESERVATION r
       JOIN PASSENGER p ON p.PassengerID = r.PassengerID
       LEFT JOIN TICKET t ON t.ReservationID = r.ReservationID
       LEFT JOIN PASSENGER tr ON tr.PassengerID = t.PassengerID
       LEFT JOIN SEAT s ON s.SeatID = t.SeatID
       LEFT JOIN FARE f ON f.FareID = t.FareID
       WHERE r.ReservationID = ?`,
      [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Reservation not found.' });

    const [payments] = await pool.execute(
      'SELECT * FROM PAYMENT WHERE ReservationID = ?', [req.params.id]
    );
    res.json({
      reservation: rows[0],
      tickets: rows.filter((row) => row.TicketID),
      payments
    });
  } catch (err) {
    next(err);
  }
};

// POST /reservations/:id/change — transactionally reassign a booked ticket.
exports.change = async (req, res, next) => {
  const { TicketID, FlightID, SeatID, FareID } = req.body;
  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();
    const [tickets] = await conn.execute(
      `SELECT TicketID FROM TICKET
       WHERE TicketID = ? AND ReservationID = ? AND TicketStatus = 'booked'
       FOR UPDATE`,
      [TicketID, req.params.id]
    );
    if (!tickets.length) {
      await conn.rollback();
      return res.status(404).json({ error: 'Booked ticket not found or ticket is already issued.' });
    }

    await conn.execute(
      'UPDATE TICKET SET FlightID = ?, SeatID = ?, FareID = ? WHERE TicketID = ?',
      [FlightID, SeatID, FareID, TicketID]
    );
    await conn.commit();
    res.json({ updated: true });
  } catch (err) {
    if (conn) await conn.rollback();
    if (fail(res, err)) return;
    next(err);
  } finally {
    if (conn) conn.release();
  }
};

// POST /reservations/:id/cancel — cancel active tickets and reservation together.
exports.cancel = async (req, res, next) => {
  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();
    const [result] = await conn.execute(
      `UPDATE RESERVATION SET ReservationStatus = 'Cancelled'
       WHERE ReservationID = ? AND ReservationStatus <> 'Cancelled'`,
      [req.params.id]
    );
    if (!result.affectedRows) {
      await conn.rollback();
      return res.status(404).json({ error: 'Active reservation not found.' });
    }

    await conn.execute(
      `UPDATE TICKET SET TicketStatus = 'cancelled'
       WHERE ReservationID = ? AND TicketStatus IN ('booked', 'issued')`,
      [req.params.id]
    );
    await conn.commit();
    res.json({ cancelled: true });
  } catch (err) {
    if (conn) await conn.rollback();
    next(err);
  } finally {
    if (conn) conn.release();
  }
};
