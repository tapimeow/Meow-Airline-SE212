// config/db.js
//
// The one place the app's MySQL connection lives. Every controller imports
// `pool` from here, so the credentials (from .env) are read in one place.
//
// Controllers always pass values as a second array argument
// (`pool.execute(sql, [values])`) and never build SQL strings with
// concatenation or template literals, so user input can't run as SQL.

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
// one query. Without DB_HOST, mysql2 quietly falls back to localhost, which
// shows up later as ECONNREFUSED 127.0.0.1:3306 on every page.
if (!process.env.DB_HOST) {
  console.warn('DB_HOST is not set: check .env locally or the Variables tab on Railway.');
}
console.log(`Database: ${process.env.DB_USER}@${process.env.DB_HOST}:${process.env.DB_PORT || 3306}/${process.env.DB_NAME}`);
pool.query('SELECT 1')
  .then(() => console.log('Database connection OK'))
  .catch((err) => console.error(`Database connection failed: ${err.code} ${err.message}`));

module.exports = pool;
