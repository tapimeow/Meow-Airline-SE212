// controllers/baggageController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): BAGGAGE
// Business rules: BR9, BR12
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/baggage.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/baggage/ or redirect
//
// What this controller must enforce:
//   - BR12: sum of Weight for the ticket + new bag must not exceed the class limit (e.g. Economy 20 kg).
//   - BR9: baggage is optional — a ticket with zero bags is valid.
//   - Lab 6 risk plan: if the backend is behind on Sun 11 Oct, this page becomes VIEW-ONLY.
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
