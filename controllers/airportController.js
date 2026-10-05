// controllers/airportController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): AIRPORT
// Business rules: BR1, BR2, BR7
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/airports.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/airports/ or redirect
//
// What this controller must enforce:
//   - AirportCode is the PK (e.g. BKK) — it is typed in, not AUTO_INCREMENT.
//   - Block delete if any FLIGHT still uses this airport as origin or destination (show a friendly error).
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
