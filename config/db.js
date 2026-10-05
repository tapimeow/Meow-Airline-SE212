// config/db.js
//
// [Phase 3 · Database · Patarawadee] This is the one place the app's MySQL connection lives.
// Everyone else imports `pool` from here instead of opening their own
// connection - that way there's only one set of credentials to update when
// we move from a local database to the shared Railway one.
//
// [Phase 4 · Backend · Kawintida] Use `pool.query(...)` (or `pool.execute(...)` for
// parameterised queries) inside your controllers. Always pass values as a
// second array argument - never build SQL strings with string concatenation
// or template literals, or the app is open to SQL injection.

require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
});

// Example of the safe pattern to copy in controllers:
//   const [rows] = await pool.execute(
//     'SELECT * FROM PASSENGER WHERE PassengerID = ?',
//     [passengerId]
//   );

module.exports = pool;
