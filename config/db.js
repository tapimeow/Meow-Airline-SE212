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
  // Return DATE / DATETIME / TIMESTAMP as plain strings ('2026-09-01',
  // '2026-10-20 08:00:00') instead of JS Date objects. A Date is sent to the
  // browser in UTC, so a booking on 1 Sep showed up as 31 Aug 17:00.
  dateStrings: true,
});

// Say at startup which database the app uses (never the password), and try
// one query. Without DB_HOST, mysql2 quietly falls back to localhost, which on
// Railway shows up later as ECONNREFUSED 127.0.0.1:3306 on every page.
if (!process.env.DB_HOST) {
  console.warn('DB_HOST is not set: check .env locally or the Variables tab on Railway.');
}
console.log(`Database: ${process.env.DB_USER}@${process.env.DB_HOST}:${process.env.DB_PORT || 3306}/${process.env.DB_NAME}`);
pool.query('SELECT 1')
  .then(() => console.log('Database connection OK'))
  .catch((err) => console.error(`Database connection failed: ${err.code} ${err.message}`));

// Example of the safe pattern to copy in controllers:
//   const [rows] = await pool.execute(
//     'SELECT * FROM PASSENGER WHERE PassengerID = ?',
//     [passengerId]
//   );

module.exports = pool;
