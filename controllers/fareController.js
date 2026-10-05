// controllers/fareController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): FARE + FARE_RULE (bridge) + FARE_CONDITION
// Business rules: BR15, BR19
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/fares.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/fares/ or redirect
//
// What this controller must enforce:
//   - Price must be > 0.
//   - A fare's conditions live in FARE_RULE (FareID, ConditionID, Fee), the second M:N (BR19).
//     Creating or editing a fare = the FARE row + its FARE_RULE rows, in one transaction.
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
