// controllers/seatController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): SEAT
// Business rules: BR4, BR10, BR11
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/seats.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/seats/ or redirect
//
// What this controller must enforce:
//   - BR11: count existing SEAT rows for the aircraft; refuse the insert if it would exceed TotalSeat.
//   - SeatNo must be unique per aircraft (e.g. 12A).
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
