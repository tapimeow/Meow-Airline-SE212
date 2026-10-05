// controllers/checkinController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): CHECKIN
// Business rules: BR13
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/checkin.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/checkin/ or redirect
//
// What this controller must enforce:
//   - BR13: only if TicketStatus = issued AND the flight has not departed.
//   - CHECKIN is 1:1 with TICKET — a second check-in for the same ticket must be refused (UNIQUE TicketID).
//   - Lab 6 risk plan: if behind at end of Week 7, this page becomes VIEW-ONLY.
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
