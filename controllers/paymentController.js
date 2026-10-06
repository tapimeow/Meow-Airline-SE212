const pool = require('../config/db');

// POST /reservations/:reservationId/payments — record payment and confirm once paid.
exports.create = async (req, res, next) => {
  const { TotalAmount, PaymentMethod } = req.body;
  const amount = Number(TotalAmount);
  const methods = ['Cash', 'Card', 'BankTransfer', 'QR'];
  if (!(amount > 0) || !methods.includes(PaymentMethod)) {
    return res.status(400).json({ error: 'A positive amount and valid payment method are required.' });
  }

  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();

    const [reservations] = await conn.execute(
      'SELECT ReservationStatus FROM RESERVATION WHERE ReservationID = ? FOR UPDATE',
      [req.params.reservationId]
    );
    if (!reservations.length) {
      await conn.rollback();
      return res.status(404).json({ error: 'Reservation not found.' });
    }
    if (reservations[0].ReservationStatus === 'Cancelled') {
      await conn.rollback();
      return res.status(409).json({ error: 'A cancelled reservation cannot receive payment.' });
    }

    const [insert] = await conn.execute(
      `INSERT INTO PAYMENT (ReservationID, TotalAmount, PaymentMethod)
       VALUES (?, ?, ?)`,
      [req.params.reservationId, amount, PaymentMethod]
    );
    const [[payments]] = await conn.execute(
      `SELECT COALESCE(SUM(CASE WHEN Status = 'Paid' THEN TotalAmount
                                ELSE -TotalAmount END), 0) AS amountPaid
       FROM PAYMENT WHERE ReservationID = ?`,
      [req.params.reservationId]
    );
    const [[fares]] = await conn.execute(
      `SELECT COALESCE(SUM(f.Price), 0) AS amountDue
       FROM TICKET t JOIN FARE f ON f.FareID = t.FareID
       WHERE t.ReservationID = ? AND t.TicketStatus <> 'cancelled'`,
      [req.params.reservationId]
    );

    if (Number(fares.amountDue) > 0 && Number(payments.amountPaid) >= Number(fares.amountDue)) {
      await conn.execute(
        `UPDATE RESERVATION SET ReservationStatus = 'Confirmed'
         WHERE ReservationID = ? AND ReservationStatus = 'Held'`,
        [req.params.reservationId]
      );
    }

    await conn.commit();
    res.status(201).json({ PaymentID: insert.insertId });
  } catch (err) {
    if (conn) await conn.rollback();
    next(err);
  } finally {
    if (conn) conn.release();
  }
};

// POST /payments/:id/refund — write a negative ledger entry as a refund row.
exports.refund = async (req, res, next) => {
  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();

    const [payments] = await conn.execute(
      'SELECT * FROM PAYMENT WHERE PaymentID = ? FOR UPDATE', [req.params.id]
    );
    if (!payments.length) {
      await conn.rollback();
      return res.status(404).json({ error: 'Payment not found.' });
    }
    const payment = payments[0];
    if (payment.Status !== 'Paid') {
      await conn.rollback();
      return res.status(409).json({ error: 'Only paid transactions can be refunded.' });
    }

    // PAYMENT has no RefundOfPaymentID column, so the current schema can only
    // prevent duplicate refunds by matching reservation and amount.
    const [priorRefunds] = await conn.execute(
      `SELECT PaymentID FROM PAYMENT
       WHERE ReservationID = ? AND Status = 'Refunded' AND TotalAmount = ?`,
      [payment.ReservationID, payment.TotalAmount]
    );
    if (priorRefunds.length) {
      await conn.rollback();
      return res.status(409).json({ error: 'A refund for this amount is already recorded.' });
    }

    const [refund] = await conn.execute(
      `INSERT INTO PAYMENT (ReservationID, TotalAmount, PaymentMethod, Status)
       VALUES (?, ?, ?, 'Refunded')`,
      [payment.ReservationID, payment.TotalAmount, payment.PaymentMethod]
    );
    await conn.commit();
    res.status(201).json({ RefundPaymentID: refund.insertId });
  } catch (err) {
    if (conn) await conn.rollback();
    next(err);
  } finally {
    if (conn) conn.release();
  }
};
