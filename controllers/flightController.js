// controllers/flightController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): FLIGHT, ROUTE (origin + destination live on ROUTE, joined on FlightNo)
// Business rules: BR1, BR2, BR3, BR7, BR15
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/flights.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/flights/ or redirect
//
// What this controller must enforce:
//   - A new flight picks an existing FlightNo from ROUTE. Adding a new route = insert into ROUTE first.
//   - BR7: reject a ROUTE with OriginCode = DestinationCode before inserting (the DB CHECK ROUTE_Airports_CK is the second line of defence).
//   - ArrivalTime must be after DepartureTime.
//   - Free seats = seats of the flight's aircraft MINUS seats already on a non-cancelled TICKET for this flight (BR10).
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
