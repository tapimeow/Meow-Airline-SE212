// routes/reservations.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Reviewer: Patarawadee (checks the SQL matches db/schema.sql)
// Table(s): RESERVATION (+ TICKET in one transaction)
// Business rules: BR5, BR6, BR8, BR10   (see docs/DATABASE.md)
//
// NOTHING IS IMPLEMENTED YET. Copy the shape of routes/passengers.js
// (the Phase 0 practice page) when you start this file.
//
// TODO [Phase 4 · Backend · Kawintida]: define these routes and point each one at a function in
// controllers/reservationController.js:
//   GET /reservations — list (filter by passenger, status)
//   GET /reservations/new?flightId= — booking form
//   POST /reservations — create booking: reservation + ticket(s) in ONE transaction
//   GET /reservations/:id — detail: tickets, payments, total paid vs due
//   POST /reservations/:id/change — change flight/seat
//   POST /reservations/:id/cancel — cancel
//
// TODO [Phase 4 · Backend · Kawintida]: register this file in server.js:
//   app.use('/reservations', require('./routes/reservations'));
//
// Keep the URL list in sync with docs/ROUTES.md — Kornnaphat builds the
// pages against that contract.
