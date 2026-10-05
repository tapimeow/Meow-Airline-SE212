// routes/checkin.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Reviewer: Patarawadee (checks the SQL matches db/schema.sql)
// Table(s): CHECKIN
// Business rules: BR13   (see docs/DATABASE.md)
//
// NOTHING IS IMPLEMENTED YET. Copy the shape of routes/passengers.js
// (the Phase 0 practice page) when you start this file.
//
// TODO [Phase 4 · Backend · Kawintida]: define these routes and point each one at a function in
// controllers/checkinController.js:
//   GET /checkin — search booking (reservation ID or passport no.)
//   POST /checkin/:ticketId — check in (creates CHECKIN row)
//   GET /checkin/:id/boarding-pass — printable boarding pass
//
// TODO [Phase 4 · Backend · Kawintida]: register this file in server.js:
//   app.use('/checkin', require('./routes/checkin'));
//
// Keep the URL list in sync with docs/ROUTES.md — Kornnaphat builds the
// pages against that contract.
