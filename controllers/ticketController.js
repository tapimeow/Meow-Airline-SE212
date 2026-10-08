const pool = require('../config/db');

// GET /tickets/:id — render ticket, baggage, and check-in information.
exports.detail = async (req, res, next) => {
  try {
    const [tickets] = await pool.execute(
      `SELECT t.*, p.Name AS Traveller, f.FlightNo, f.DepartureTime,
              f.ArrivalTime, f.Gate, s.SeatNo, s.SeatClass, fa.Price
       FROM TICKET t
       JOIN PASSENGER p ON p.PassengerID = t.PassengerID
       JOIN FLIGHT f ON f.FlightID = t.FlightID
       JOIN SEAT s ON s.SeatID = t.SeatID
       JOIN FARE fa ON fa.FareID = t.FareID
       WHERE t.TicketID = ?`,
      [req.params.id]
    );
    if (!tickets.length) return res.status(404).send('Ticket not found.');

    const [baggage] = await pool.execute(
      'SELECT * FROM BAGGAGE WHERE TicketID = ?', [req.params.id]
    );
    const [checkins] = await pool.execute(
      'SELECT * FROM CHECKIN WHERE TicketID = ?', [req.params.id]
    );
    res.render('tickets/detail', {
      title: `Ticket #${tickets[0].TicketID}`,
      ticket: tickets[0],
      baggage,
      checkin: checkins[0] || null,
      error: null,
    });
  } catch (err) {
    next(err);
  }
};

// POST /tickets/:id/issue — only issue when the reservation is fully paid.
// Read totals first: MySQL rejects an UPDATE that reads TICKET in a subquery
// against the same target table (error 1093).
exports.issue = async (req, res, next) => {
  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();

    const [ticketRows] = await conn.execute(
      `SELECT ReservationID, TicketStatus
       FROM TICKET WHERE TicketID = ? FOR UPDATE`,
      [req.params.id]
    );
    if (!ticketRows.length) {
      await conn.rollback();
      return res.status(404).send('Ticket not found.');
    }
    if (ticketRows[0].TicketStatus !== 'booked') {
      await conn.rollback();
      const detail = await require('./reservationController').getDetailData(ticketRows[0].ReservationID);
      return res.status(409).render('reservations/detail', {
        title: `Reservation #${ticketRows[0].ReservationID}`,
        ...detail,
        error: 'Only a booked ticket can be issued.',
      });
    }

    const reservationId = ticketRows[0].ReservationID;
    const [[payment]] = await conn.execute(
      `SELECT COALESCE(SUM(CASE WHEN Status = 'Paid' THEN TotalAmount
                                ELSE -TotalAmount END), 0) AS amountPaid
       FROM PAYMENT WHERE ReservationID = ?`,
      [reservationId]
    );
    const [[fare]] = await conn.execute(
      `SELECT COALESCE(SUM(f.Price), 0) AS amountDue
       FROM TICKET t JOIN FARE f ON f.FareID = t.FareID
       WHERE t.ReservationID = ? AND t.TicketStatus <> 'cancelled'`,
      [reservationId]
    );

    if (Number(payment.amountPaid) < Number(fare.amountDue)) {
      await conn.rollback();
      const detail = await require('./reservationController').getDetailData(reservationId);
      return res.status(409).render('reservations/detail', {
        title: `Reservation #${reservationId}`,
        ...detail,
        error: 'The reservation must be fully paid before a ticket can be issued.',
      });
    }

    const [result] = await conn.execute(
      `UPDATE TICKET
       SET TicketStatus = 'issued', TicketIssueDate = CURRENT_DATE
       WHERE TicketID = ? AND TicketStatus = 'booked'`,
      [req.params.id]
    );
    if (!result.affectedRows) {
      await conn.rollback();
      const detail = await require('./reservationController').getDetailData(reservationId);
      return res.status(409).render('reservations/detail', { title: `Reservation #${reservationId}`, ...detail, error: 'Ticket is no longer in booked status.' });
    }

    await conn.commit();
    res.redirect(`/reservations/${reservationId}`);
  } catch (err) {
    if (conn) await conn.rollback();
    if (err.code === 'ER_SIGNAL_EXCEPTION') {
      return res.status(400).send(err.sqlMessage || err.message);
    }
    next(err);
  } finally {
    if (conn) conn.release();
  }
};
