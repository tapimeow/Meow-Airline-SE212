// controllers/passengerController.js
//
// [Phase 4 · Backend · Kawintida] Reference implementation for the practice CRUD page.
// Every function follows the same shape: run a query against `pool`, then
// render or redirect. Copy this pattern for the real entities - reports
// (seats sold, empty seats, income) are just a `list`-style function that
// renders a different view with the report queries from db/queries.sql
// instead of a plain SELECT.
//
// Error handling: Express 4 does not catch errors thrown inside an async
// function, and an uncaught one crashes the whole server. So every async
// handler has a try/catch:
//   - errors the user can fix (duplicate passport, passenger still has
//     bookings) re-render the page with an `error` message
//   - anything else goes to next(err), which server.js turns into a 500 page

const pool = require('../config/db');

// MySQL error codes we turn into friendly messages
const DUPLICATE = 'ER_DUP_ENTRY';               // 1062: UNIQUE constraint (PassportNo)
const STILL_USED = 'ER_ROW_IS_REFERENCED_2';    // 1451: ON DELETE RESTRICT (has bookings/tickets)

// Empty form fields arrive as '' - store them as NULL instead
const orNull = (value) => (value === undefined || value.trim() === '' ? null : value.trim());

// Name and PassportNo are required. The browser checks `required`, but a
// value of only spaces gets past it - the database would store '' because
// NOT NULL allows an empty string. Returns an error message, or null if OK.
const checkRequired = (Name, PassportNo) =>
  !Name || !Name.trim() || !PassportNo || !PassportNo.trim()
    ? 'Name and passport number are required.'
    : null;

// GET /passengers - show every passenger in a table
exports.list = async (req, res, next) => {
  try {
    // Typed name or passport number narrows the list; empty shows everyone.
    const q = (req.query.q || '').trim();
    const like = `%${q.replace(/[\\%_]/g, '\\$&')}%`;
    const [passengers] = await pool.execute(`SELECT * FROM PASSENGER
      WHERE ? = '' OR Name LIKE ? OR PassportNo LIKE ? ORDER BY PassengerID`, [q, like, like]);
    res.render('passengers/list', { title: 'Passengers', passengers, q, error: null });
  } catch (err) {
    next(err);
  }
};

// GET /passengers/new - blank form
exports.showCreateForm = (req, res) => {
  res.render('passengers/form', { title: 'Add passenger', passenger: null, error: null });
};

// POST /passengers - insert a new row
// Note the `?` placeholders - values are passed separately, never
// concatenated into the SQL string, so user input can't be interpreted as
// SQL (this is what stops SQL injection).
exports.create = async (req, res, next) => {
  const { Name, PassportNo, PhoneNo, Email, MembershipStatus } = req.body;
  const missing = checkRequired(Name, PassportNo);
  if (missing) {
    return res.status(400).render('passengers/form', {
      title: 'Add passenger',
      passenger: req.body,
      error: missing,
    });
  }
  try {
    await pool.execute(
      `INSERT INTO PASSENGER (Name, PassportNo, PhoneNo, Email, MembershipStatus)
       VALUES (?, ?, ?, ?, ?)`,
      [Name.trim(), PassportNo.trim(), orNull(PhoneNo), orNull(Email), MembershipStatus || 'Normal']
    );
    res.redirect('/passengers');
  } catch (err) {
    if (err.code === DUPLICATE) {
      // Show the form again with what the user typed, plus the message
      return res.status(400).render('passengers/form', {
        title: 'Add passenger',
        passenger: req.body,
        error: `Passport number ${PassportNo} is already registered.`,
      });
    }
    next(err);
  }
};

// GET /passengers/:id/edit - form pre-filled with one passenger's data
exports.showEditForm = async (req, res, next) => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM PASSENGER WHERE PassengerID = ?',
      [req.params.id]
    );
    if (rows.length === 0) return res.status(404).send('Passenger not found');
    res.render('passengers/form', { title: 'Edit passenger', passenger: rows[0], error: null });
  } catch (err) {
    next(err);
  }
};

// POST /passengers/:id - update an existing row
exports.update = async (req, res, next) => {
  const { Name, PassportNo, PhoneNo, Email, MembershipStatus } = req.body;
  const missing = checkRequired(Name, PassportNo);
  if (missing) {
    return res.status(400).render('passengers/form', {
      title: 'Edit passenger',
      passenger: { ...req.body, PassengerID: req.params.id },
      error: missing,
    });
  }
  try {
    const [result] = await pool.execute(
      `UPDATE PASSENGER
       SET Name = ?, PassportNo = ?, PhoneNo = ?, Email = ?, MembershipStatus = ?
       WHERE PassengerID = ?`,
      [Name.trim(), PassportNo.trim(), orNull(PhoneNo), orNull(Email), MembershipStatus || 'Normal', req.params.id]
    );
    // No row matched: the passenger was deleted, or the URL has a wrong id
    if (result.affectedRows === 0) return res.status(404).send('Passenger not found');
    res.redirect('/passengers');
  } catch (err) {
    if (err.code === DUPLICATE) {
      return res.status(400).render('passengers/form', {
        title: 'Edit passenger',
        passenger: { ...req.body, PassengerID: req.params.id },
        error: `Passport number ${PassportNo} is already registered to another passenger.`,
      });
    }
    next(err);
  }
};

// POST /passengers/:id/delete
// The database refuses (ON DELETE RESTRICT) if the passenger has
// reservations or tickets - we show that as a message instead of crashing.
exports.remove = async (req, res, next) => {
  try {
    await pool.execute('DELETE FROM PASSENGER WHERE PassengerID = ?', [req.params.id]);
    res.redirect('/passengers');
  } catch (err) {
    if (err.code === STILL_USED) {
      try {
        const [passengers] = await pool.execute('SELECT * FROM PASSENGER ORDER BY PassengerID');
        return res.status(409).render('passengers/list', {
          title: 'Passengers',
          passengers,
          error: 'This passenger has bookings or tickets, so they cannot be deleted.',
        });
      } catch (listErr) {
        return next(listErr);
      }
    }
    next(err);
  }
};
