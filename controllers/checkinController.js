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
//   - Find the ticket by the traveller's passport: TICKET.PassengerID -> PASSENGER.PassportNo.
//   - BR13: only if TicketStatus = issued AND the flight has not departed.
//   - CHECKIN is 1:1 with TICKET: a second check-in for the same ticket must be refused (UNIQUE TicketID). Save CHECKIN.CheckInStaffID (EER "Processes", BR17).
//   - Lab 6 risk plan: if the backend is behind on Sun 11 Oct, this page becomes VIEW-ONLY.
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
