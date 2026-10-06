# RESTful CRUD API (report section 8)

The Meow Airline web server uses Node.js and Express for its HTTP API and MySQL for persistent data. `server.js` configures JSON and HTML-form request parsing, serves static assets, and mounts the feature routers. Each router maps a URL and HTTP method to a controller. Controllers validate user input, run parameterized statements through the shared MySQL pool in `config/db.js`, enforce business rules that span rows, and return JSON results or clear HTTP errors. The API uses `POST` for create, update, and delete actions so it also supports ordinary HTML forms.

The API is grouped by feature:

| Feature | Main endpoints |
|---|---|
| Airports and routes | `GET/POST /airports`, `POST /airports/:code`, `POST /airports/:code/delete`; matching CRUD under `/routes` |
| Aircraft and seats | `GET/POST /aircraft`, `GET /aircraft/:id`, `POST /aircraft/:id`, `POST /aircraft/:id/delete`; `POST /aircraft/:aircraftId/seats`, `POST /seats/:id/delete` |
| Flights and fares | `GET/POST /flights`, `GET /flights/:id`, `POST /flights/:id`, `POST /flights/:id/delete`; fare list/create under `/flights/:flightId/fares`, update/delete under `/fares/:id` |
| Reservations and tickets | `GET/POST /reservations`, `GET /reservations/:id`, `POST /reservations/:id/change`, `POST /reservations/:id/cancel`, `GET /tickets/:id`, `POST /tickets/:id/issue` |
| Payments | `POST /reservations/:reservationId/payments`, `POST /payments/:id/refund` |
| Baggage and check-in | `GET/POST /tickets/:ticketId/baggage`, `POST /baggage/:id`, `POST /baggage/:id/delete`; `GET /checkin`, `POST /checkin/:ticketId`, `GET /checkin/:id/boarding-pass` |
| Staff and reports | `GET/POST /staff`, `POST /staff/:id`, `POST /staff/:id/delete`; `GET /reports/free-seats`, `/reports/passenger-bookings`, and `/reports/route-income` |

The booking request contains a booker and one ticket entry for each traveller and seat. Reservation creation and all its ticket inserts share one database transaction: any invalid passenger, fare, seat, or duplicate live seat rolls back the complete booking. Cancellation changes the reservation and releases its live tickets in one transaction. MySQL's unique key on the generated active-seat value is the final protection against concurrent double booking. The API translates duplicate-seat failures into an HTTP 409 conflict.

Payment records are kept as ledger rows. A refund is a separate row marked `Refunded`, so the original transaction remains in the history and the net payment is the sum of paid rows minus refunded rows. Because the current schema has no `RefundOfPaymentID` link, the API prevents a second refund with the same reservation and amount; separate equal-value payments therefore cannot each be refunded independently until the schema adds that link. When net payment covers the active ticket fares, the reservation becomes `Confirmed`. Ticket issue checks the same paid-versus-due totals. Check-in accepts only issued tickets before departure, while a unique database constraint ensures a ticket can be checked in once. Baggage creation locks the ticket while it checks the total weight against the cabin's allowance.

Flight `DATETIME` values are interpreted using the server/database timezone and may be serialized to JSON in UTC. EJS pages should display them in the airline's local timezone (Asia/Bangkok); `server.js` exposes a `formatFlightTime` helper for this purpose.

Other cross-row checks include the aircraft seat limit and the staff specialisation. Seat creation and aircraft-capacity updates lock the aircraft while checking that seats do not exceed `TotalSeat`. Staff creation inserts the `STAFF` row and exactly one role-specific row in one transaction. Flight and fare changes are checked against existing tickets so they cannot leave tickets with a seat or fare inconsistent with their flight.

Report endpoints use parameterized SQL and return the data for the three project questions: remaining seats by class, a passenger's reservations and payment status, and route income with the route or routes that sold the fewest seats in a selected month. Route income is based on the fares attached to non-cancelled tickets, the project team's agreed definition.

The business rule list for the report is in [`BUSINESS_RULES.md`](BUSINESS_RULES.md). Endpoint paths, parameters, and request shapes are in [`ROUTES.md`](ROUTES.md).
