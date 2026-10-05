// routes/tickets.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Reviewer: Patarawadee (checks the SQL matches db/schema.sql)
// Table(s): TICKET (bridge Reservation–Flight)
// Business rules: BR6, BR8, BR10, BR13   (see docs/DATABASE.md)
//
// NOTHING IS IMPLEMENTED YET. Copy the shape of routes/passengers.js
// (the Phase 0 practice page) when you start this file.
//
// TODO [Phase 4 · Backend · Kawintida]: define these routes and point each one at a function in
// controllers/ticketController.js:
//   GET /tickets/:id — detail (passenger, flight, seat, bags, check-in)
//   POST /tickets/:id/issue — set TicketStatus = issued
//   (tickets are created inside the reservation transaction)
//
// TODO [Phase 4 · Backend · Kawintida]: register this file in server.js:
//   app.use('/tickets', require('./routes/tickets'));
//
// Keep the URL list in sync with docs/ROUTES.md — Kornnaphat builds the
// pages against that contract.
