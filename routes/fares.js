// routes/fares.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Reviewer: Patarawadee (checks the SQL matches db/schema.sql)
// Table(s): FARE + FARE_RULE (bridge) + FARE_CONDITION
// Business rules: BR15, BR19   (see docs/DATABASE.md)
//
// NOTHING IS IMPLEMENTED YET. Copy the shape of routes/passengers.js
// (the Phase 0 practice page) when you start this file.
//
// TODO [Phase 4 · Backend · Kawintida]: define these routes and point each one at a function in
// controllers/fareController.js:
//   GET /flights/:flightId/fares/new — form
//   POST /flights/:flightId/fares — create
//   GET /fares/:id/edit — form
//   POST /fares/:id — update
//   POST /fares/:id/delete — delete
//
// TODO [Phase 4 · Backend · Kawintida]: register this file in server.js:
//   app.use('/', require('./routes/fares'));   // mounted at / because its URLs start with different prefixes
//
// Keep the URL list in sync with docs/ROUTES.md — Kornnaphat builds the
// pages against that contract.
