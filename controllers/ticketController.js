// controllers/ticketController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): TICKET (bridge Reservation–Flight)
// Business rules: BR6, BR8, BR10, BR13
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/tickets.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/tickets/ or redirect
//
// What this controller must enforce:
//   - BR8: refuse to issue a ticket while its reservation has no Paid PAYMENT.
//   - TicketStatus: issued / used / cancelled.
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
