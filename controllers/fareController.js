// controllers/fareController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): FARE
// Business rules: BR15
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/fares.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/fares/ or redirect
//
// What this controller must enforce:
//   - Price must be > 0.
//   - Rule is Refundable / Changeable — it decides whether cancel gives a refund PAYMENT row.
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
