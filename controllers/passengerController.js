// controllers/passengerController.js
//
// [Junior - Backend] Reference implementation for the practice CRUD page.
// Every function follows the same shape: run a query against `pool`, then
// render or redirect. Copy this pattern for the real entities - reports
// (seats sold, empty seats, income) are just a `list`-style function that
// renders a different view with Mona's report queries instead of a plain
// SELECT.

const pool = require('../config/db');

// GET /passengers - show every passenger in a table
exports.list = async (req, res) => {
  const [passengers] = await pool.execute('SELECT * FROM PASSENGER ORDER BY PassengerID');
  res.render('passengers/list', { title: 'Passengers', passengers });
};

// GET /passengers/new - blank form
exports.showCreateForm = (req, res) => {
  res.render('passengers/form', { title: 'Add passenger', passenger: null });
};

// POST /passengers - insert a new row
// Note the `?` placeholders - values are passed separately, never
// concatenated into the SQL string, so user input can't be interpreted as
// SQL (this is what stops SQL injection).
exports.create = async (req, res) => {
  const { Name, PassportNo, PhoneNo, Email, MembershipStatus } = req.body;
  await pool.execute(
    `INSERT INTO PASSENGER (Name, PassportNo, PhoneNo, Email, MembershipStatus)
     VALUES (?, ?, ?, ?, ?)`,
    [Name, PassportNo, PhoneNo, Email, MembershipStatus || 'Normal']
  );
  res.redirect('/passengers');
};

// GET /passengers/:id/edit - form pre-filled with one passenger's data
exports.showEditForm = async (req, res) => {
  const [rows] = await pool.execute(
    'SELECT * FROM PASSENGER WHERE PassengerID = ?',
    [req.params.id]
  );
  if (rows.length === 0) return res.status(404).send('Passenger not found');
  res.render('passengers/form', { title: 'Edit passenger', passenger: rows[0] });
};

// POST /passengers/:id - update an existing row
exports.update = async (req, res) => {
  const { Name, PassportNo, PhoneNo, Email, MembershipStatus } = req.body;
  await pool.execute(
    `UPDATE PASSENGER
     SET Name = ?, PassportNo = ?, PhoneNo = ?, Email = ?, MembershipStatus = ?
     WHERE PassengerID = ?`,
    [Name, PassportNo, PhoneNo, Email, MembershipStatus, req.params.id]
  );
  res.redirect('/passengers');
};

// POST /passengers/:id/delete
exports.remove = async (req, res) => {
  await pool.execute('DELETE FROM PASSENGER WHERE PassengerID = ?', [req.params.id]);
  res.redirect('/passengers');
};

// TODO [Junior - Backend]: once RESERVATION/TICKET/PAYMENT tables exist,
// the real booking flow needs a transaction so two agents can never sell
// the same seat (this is the double-booking problem from the proposal).
// Sketch:
//
//   const conn = await pool.getConnection();
//   try {
//     await conn.beginTransaction();
//     // 1. check the seat isn't already ticketed on this flight
//     // 2. insert the Ticket row
//     // 3. commit
//     await conn.commit();
//   } catch (err) {
//     await conn.rollback();
//     throw err;
//   } finally {
//     conn.release();
//   }
