// routes/reports.js
//
// Owner:    [Phase 4 · Backend · Kawintida] for the routes and controller
//           [Phase 5 · Frontend · Kornnaphat] for the report pages
// SQL:      db/queries.sql (Milestone M5 — Kawintida + Kornnaphat)
//
// NOTHING IS IMPLEMENTED YET.
//
// TODO [Phase 4 · Backend · Kawintida]: define the 3 report routes from the Lab 6 proposal (B2.4):
//   GET /reports                        — menu of the 3 reports
//   GET /reports/free-seats?flightId=   — Q1 free seats on a flight, by class        (O4)
//   GET /reports/passenger-bookings?passengerId= — Q2 a passenger's bookings + which are unpaid
//   GET /reports/route-income?month=    — Q3 income per route last month + route with fewest seats sold (O3)
//
// TODO [Phase 4 · Backend · Kawintida]: register in server.js:  app.use('/reports', require('./routes/reports'));
// Goal O3: every report must load in under 10 seconds.
