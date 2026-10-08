const pool = require('../config/db');

async function paymentFormLocals(reservationId) {
  const [[reservation]] = await pool.execute(`SELECT r.*, p.Name AS PassengerName FROM RESERVATION r
    JOIN PASSENGER p ON p.PassengerID=r.PassengerID WHERE r.ReservationID=?`, [reservationId]);
  if (!reservation) return null;
  const [[due]] = await pool.execute(`SELECT COALESCE(SUM(f.Price), 0) AS amountDue FROM TICKET t
    JOIN FARE f ON f.FareID=t.FareID WHERE t.ReservationID=? AND t.TicketStatus<>'cancelled'`, [reservationId]);
  const [[paid]] = await pool.execute(`SELECT COALESCE(SUM(CASE WHEN Status='Paid' THEN TotalAmount ELSE -TotalAmount END), 0) AS amountPaid
    FROM PAYMENT WHERE ReservationID=?`, [reservationId]);
  return { title: 'Record payment', reservation, amountDue: Math.max(0, Number(due.amountDue) - Number(paid.amountPaid)), error: null };
}

exports.newForm = async (req, res, next) => {
  try {
    const locals = await paymentFormLocals(req.params.id);
    if (!locals) return res.status(404).send('Reservation not found.');
    res.render('payments/form', locals);
  } catch (err) { next(err); }
};

exports.create = async (req, res, next) => {
  const amount = Number(req.body.TotalAmount);
  const methods = ['Cash', 'Card', 'BankTransfer', 'QR'];
  if (!(amount > 0) || !methods.includes(req.body.PaymentMethod)) {
    const locals = await paymentFormLocals(req.params.reservationId);
    if (!locals) return res.status(404).send('Reservation not found.');
    return res.status(400).render('payments/form', { ...locals, error: 'Enter a positive amount and choose a valid payment method.' });
  }

  let conn;
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [reservations] = await conn.execute('SELECT ReservationStatus FROM RESERVATION WHERE ReservationID=? FOR UPDATE', [req.params.reservationId]);
    if (!reservations.length) { await conn.rollback(); return res.status(404).send('Reservation not found.'); }
    if (reservations[0].ReservationStatus === 'Cancelled') { await conn.rollback(); const locals = await paymentFormLocals(req.params.reservationId); return res.status(409).render('payments/form', { ...locals, error: 'A cancelled reservation cannot receive payment.' }); }

    await conn.execute('INSERT INTO PAYMENT (ReservationID, TotalAmount, PaymentMethod) VALUES (?, ?, ?)', [req.params.reservationId, amount, req.body.PaymentMethod]);
    const [[payments]] = await conn.execute(`SELECT COALESCE(SUM(CASE WHEN Status='Paid' THEN TotalAmount ELSE -TotalAmount END), 0) AS amountPaid
      FROM PAYMENT WHERE ReservationID=?`, [req.params.reservationId]);
    const [[fares]] = await conn.execute(`SELECT COALESCE(SUM(f.Price), 0) AS amountDue FROM TICKET t JOIN FARE f ON f.FareID=t.FareID
      WHERE t.ReservationID=? AND t.TicketStatus<>'cancelled'`, [req.params.reservationId]);
    if (Number(fares.amountDue) > 0 && Number(payments.amountPaid) >= Number(fares.amountDue)) {
      await conn.execute("UPDATE RESERVATION SET ReservationStatus='Confirmed' WHERE ReservationID=? AND ReservationStatus='Held'", [req.params.reservationId]);
    }
    await conn.commit(); res.redirect(`/reservations/${req.params.reservationId}`);
  } catch (err) { if (conn) await conn.rollback(); next(err); }
  finally { if (conn) conn.release(); }
};

exports.refund = async (req, res, next) => {
  let conn;
  const showError = async (reservationId, statusCode, error) => {
    const data = await require('./reservationController').getDetailData(reservationId);
    if (!data) return res.status(404).send('Reservation not found.');
    return res.status(statusCode).render('reservations/detail', { title: `Reservation #${reservationId}`, ...data, error });
  };
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [[paymentRef]] = await conn.execute('SELECT ReservationID FROM PAYMENT WHERE PaymentID=?', [req.params.id]);
    if (!paymentRef) { await conn.rollback(); return res.status(404).send('Payment not found.'); }
    const [reservation] = await conn.execute('SELECT ReservationStatus FROM RESERVATION WHERE ReservationID=? FOR UPDATE', [paymentRef.ReservationID]);
    if (!reservation.length) { await conn.rollback(); return res.status(404).send('Reservation not found.'); }
    const [payments] = await conn.execute('SELECT * FROM PAYMENT WHERE PaymentID=? FOR UPDATE', [req.params.id]);
    const payment = payments[0];
    if (payment.Status !== 'Paid') { await conn.rollback(); return showError(payment.ReservationID, 409, 'Only paid transactions can be refunded.'); }

    // The schema has no link to a source payment, so retain the existing simple duplicate check.
    const [priorRefunds] = await conn.execute(`SELECT PaymentID FROM PAYMENT
      WHERE ReservationID=? AND Status='Refunded' AND TotalAmount=?`, [payment.ReservationID, payment.TotalAmount]);
    if (priorRefunds.length) { await conn.rollback(); return showError(payment.ReservationID, 409, 'A refund for this amount is already recorded.'); }

    await conn.execute(`INSERT INTO PAYMENT (ReservationID, TotalAmount, PaymentMethod, Status)
      VALUES (?, ?, ?, 'Refunded')`, [payment.ReservationID, payment.TotalAmount, payment.PaymentMethod]);
    const [[amounts]] = await conn.execute(`SELECT
      COALESCE((SELECT SUM(CASE WHEN Status='Paid' THEN TotalAmount ELSE -TotalAmount END) FROM PAYMENT WHERE ReservationID=?), 0) AS amountPaid,
      COALESCE((SELECT SUM(f.Price) FROM TICKET t JOIN FARE f ON f.FareID=t.FareID WHERE t.ReservationID=? AND t.TicketStatus<>'cancelled'), 0) AS amountDue`, [payment.ReservationID, payment.ReservationID]);
    if (Number(amounts.amountPaid) < Number(amounts.amountDue)) {
      await conn.execute("UPDATE RESERVATION SET ReservationStatus='Held' WHERE ReservationID=? AND ReservationStatus='Confirmed'", [payment.ReservationID]);
    }
    await conn.commit(); res.redirect(`/reservations/${payment.ReservationID}`);
  } catch (err) { if (conn) await conn.rollback(); next(err); }
  finally { if (conn) conn.release(); }
};
