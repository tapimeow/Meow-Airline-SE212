const pool = require('../config/db');

async function baggagePageData(ticketId) {
  const [[ticket]] = await pool.execute(`SELECT t.*, p.Name AS Traveller, s.SeatClass FROM TICKET t
    JOIN PASSENGER p ON p.PassengerID=t.PassengerID JOIN SEAT s ON s.SeatID=t.SeatID WHERE t.TicketID=?`, [ticketId]);
  if (!ticket) return null;
  const [baggage] = await pool.execute('SELECT * FROM BAGGAGE WHERE TicketID=? ORDER BY BaggageID', [ticketId]);
  const totalWeight = baggage.reduce((total, bag) => total + Number(bag.Weight), 0);
  const weightLimit = { Economy: 20, Business: 30, FirstClass: 40 }[ticket.SeatClass];
  return { title: 'Baggage', ticket, baggage, totalWeight, weightLimit, error: null };
}

exports.list = async (req, res, next) => {
  try {
    const locals = await baggagePageData(req.params.ticketId);
    if (!locals) return res.status(404).send('Ticket not found.');
    res.render('baggage/form', locals);
  } catch (err) { next(err); }
};

exports.create = async (req, res, next) => {
  const weight = Number(req.body.Weight);
  let conn;
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [tickets] = await conn.execute(`SELECT t.TicketID, s.SeatClass FROM TICKET t
      JOIN SEAT s ON s.SeatID=t.SeatID WHERE t.TicketID=? FOR UPDATE`, [req.params.ticketId]);
    if (!tickets.length) { await conn.rollback(); return res.status(404).send('Ticket not found.'); }
    const [sum] = await conn.execute('SELECT COALESCE(SUM(Weight), 0) AS total FROM BAGGAGE WHERE TicketID=?', [req.params.ticketId]);
    const limit = { Economy: 20, Business: 30, FirstClass: 40 }[tickets[0].SeatClass];
    let error = null;
    if (!(weight > 0)) error = 'Bag weight must be greater than zero.';
    else if (weight > 32) error = 'A single bag cannot exceed the database limit of 32 kg.';
    else if (Number(sum[0].total) + weight > limit) error = `Total baggage for this ticket cannot exceed ${limit} kg.`;
    if (error) {
      await conn.rollback();
      const locals = await baggagePageData(req.params.ticketId);
      return res.status(400).render('baggage/form', { ...locals, error });
    }
    await conn.execute('INSERT INTO BAGGAGE (TicketID, Weight) VALUES (?, ?)', [req.params.ticketId, weight]);
    await conn.commit(); res.redirect(`/tickets/${req.params.ticketId}/baggage`);
  } catch (err) {
    if (conn) await conn.rollback();
    if (err.code === 'ER_NO_REFERENCED_ROW_2') return res.status(400).send('Ticket was not found.');
    next(err);
  } finally { if (conn) conn.release(); }
};

exports.update = async (req, res, next) => {
  try {
    const statuses = ['CheckedIn', 'Loaded', 'Arrived', 'Lost'];
    const [[row]] = await pool.execute('SELECT TicketID FROM BAGGAGE WHERE BaggageID=?', [req.params.id]);
    if (!row) return res.status(404).send('Baggage record not found.');
    if (!statuses.includes(req.body.BaggageStatus)) {
      const locals = await baggagePageData(row.TicketID);
      return res.status(400).render('baggage/form', { ...locals, error: 'Choose a valid baggage status.' });
    }
    await pool.execute('UPDATE BAGGAGE SET BaggageStatus=? WHERE BaggageID=?', [req.body.BaggageStatus, req.params.id]);
    res.redirect(`/tickets/${row.TicketID}/baggage`);
  } catch (err) { next(err); }
};

exports.remove = async (req, res, next) => {
  try {
    const [[row]] = await pool.execute('SELECT TicketID FROM BAGGAGE WHERE BaggageID=?', [req.params.id]);
    if (!row) return res.status(404).send('Baggage record not found.');
    await pool.execute('DELETE FROM BAGGAGE WHERE BaggageID=?', [req.params.id]);
    res.redirect(`/tickets/${row.TicketID}/baggage`);
  } catch (err) { next(err); }
};
