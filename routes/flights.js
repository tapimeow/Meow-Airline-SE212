// routes/flights.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Reviewer: Patarawadee (checks the SQL matches db/schema.sql)
// Table(s): FLIGHT
// Business rules: BR1, BR2, BR3, BR7, BR15   (see docs/DATABASE.md)
//
// NOTHING IS IMPLEMENTED YET. Copy the shape of routes/passengers.js
// (the Phase 0 practice page) when you start this file.
//
// TODO [Phase 4 · Backend · Kawintida]: define these routes and point each one at a function in
// controllers/flightController.js:
//   GET /flights — list + search (origin, destination, date)
//   GET /flights/new — form
//   POST /flights — create
//   GET /flights/:id — detail: fares + free seats by class (O4, report Q1)
//   GET /flights/:id/edit — form
//   POST /flights/:id — update (incl. Status OnTime/Delayed/Canceled)
//   POST /flights/:id/delete — delete
//
// TODO [Phase 4 · Backend · Kawintida]: register this file in server.js:
//   app.use('/flights', require('./routes/flights'));
//
// Keep the URL list in sync with docs/ROUTES.md — Kornnaphat builds the
// pages against that contract.
