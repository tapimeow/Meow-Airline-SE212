// controllers/aircraftController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): AIRCRAFT
// Business rules: BR3, BR4, BR11
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/aircraft.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/aircraft/ or redirect
//
// What this controller must enforce:
//   - BR11: TotalSeat cannot be lowered below the number of SEAT rows that already exist.
//   - Meow Airline has 6 aircraft — seed data should match that.
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
