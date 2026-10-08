# RESTful CRUD API (report section 8)

The Meow Airline web server uses Node.js and Express with MySQL persistence. `server.js` configures JSON and HTML-form request parsing, serves static assets, and mounts the feature routers. Browser-facing GET routes render EJS pages; successful form submissions redirect to the relevant list or detail page. Controllers validate input, run parameterized statements through the shared MySQL pool in `config/db.js`, and enforce business rules that span rows. Validation and database errors are shown on the relevant page. The shared view names and locals are documented in [`EJS_VIEW_CONTRACT.md`](EJS_VIEW_CONTRACT.md).

The API is grouped by feature:

| Feature | Main endpoints |
|---|---|
| Airports and routes | Airport pages: `GET /airports`, `/airports/new`, `/airports/:code/edit`; POST create/update/delete. Route maintenance remains under `/routes` |
| Aircraft and seats | Aircraft pages: `GET /aircraft`, `/aircraft/new`, `/aircraft/:id`, `/aircraft/:id/edit`, `/aircraft/:id/seats/new`; POST create/update/delete seats and aircraft |
| Flights and fares | Flight pages: `GET /flights`, `/flights/new`, `/flights/:id`, `/flights/:id/edit`; fare form at `/flights/:flightId/fares/new` and `/fares/:id/edit`; POST forms redirect to flight details |
| Reservations and tickets | `GET /reservations`, `/reservations/new`, `/reservations/:id`, `/tickets/:id`; POST booking, change, cancel, and issue actions |
| Payments | `GET /reservations/:id/payments`; POST payment and `/payments/:id/refund` |
| Baggage and check-in | `GET/POST /tickets/:ticketId/baggage`, `POST /baggage/:id`, `POST /baggage/:id/delete`; `GET /checkin`, `POST /checkin/:ticketId`, `GET /checkin/:id/boarding-pass` |
| Staff and reports | Staff pages: `GET /staff`, `/staff/new`, `/staff/:id/edit`; report pages at `/reports`, `/reports/free-seats`, `/reports/passenger-bookings`, and `/reports/route-income` |

The booking form submits a booker and indexed ticket entries such as `Tickets[0][FlightID]`, parsed by Express with `extended: true`. Reservation creation and all ticket inserts share one database transaction: any invalid passenger, fare, seat, or duplicate live seat rolls back the complete booking. Cancellation changes the reservation and releases its live tickets in one transaction, but is refused once a ticket has checked in. MySQL's unique key on the generated active-seat value is the final protection against concurrent double booking. Duplicate-seat failures are shown as a conflict on the booking form.

Payment records are kept as ledger rows. A refund is a separate row marked `Refunded`, so the original transaction remains in the history and the net payment is the sum of paid rows minus refunded rows. Because the current schema has no `RefundOfPaymentID` link, duplicate refunds are prevented by reservation and amount; separate equal-value payments therefore cannot each be refunded independently until the schema adds that link. When net payment covers the active ticket fares, the reservation becomes `Confirmed`; if a refund makes it underpaid, it returns to `Held`. Ticket issue checks the same paid-versus-due totals. Check-in accepts only issued tickets before departure, while a unique database constraint ensures a ticket can be checked in once. Baggage creation locks the ticket while it checks the total weight against the cabin's allowance.

The MySQL pool returns `DATE` and `DATETIME` values as strings. EJS pages display flight times in the airline's timezone (Asia/Bangkok); `server.js` exposes a `formatFlightTime` helper for that display.

Other cross-row checks include the aircraft seat limit and the staff specialisation. Seat creation and aircraft-capacity updates lock the aircraft while checking that seats do not exceed `TotalSeat`. Staff creation inserts the `STAFF` row and exactly one role-specific row in one transaction. Flight and fare changes are checked against existing tickets so they cannot leave tickets with a seat or fare inconsistent with their flight.

Report pages use parameterized SQL for the three project questions: remaining seats by class, a passenger's reservations and payment status, and route income with the route or routes that sold the fewest seats in a selected month. Route income is based on the fares attached to non-cancelled tickets, the project team's agreed definition.

The business rule list for the report is in [`BUSINESS_RULES.md`](BUSINESS_RULES.md). Endpoint paths, parameters, and request shapes are in [`ROUTES.md`](ROUTES.md).
