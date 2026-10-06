# Route ↔ page contract

**Owners:** Kawintida (backend) and Kornnaphat (frontend) agree on this list
**before** Phase 4 starts. After that, any change goes through a PR that both
of them approve.

Each route file in `routes/` lists its planned URLs in its header comment. This
table gives the overview.

| Area | Main URLs | Controller | Views folder | BRs |
|---|---|---|---|---|
| Passengers *(Phase 0 practice, done)* | `/passengers` CRUD | passengerController | `views/passengers/` | BR5 |
| Airports | `/airports` CRUD | airportController | `views/airports/` | BR1, BR2, BR7 |
| Routes | `/routes` CRUD | apiAdminController | `views/flights/` | BR1, BR2, BR7 |
| Aircraft + seats | `/aircraft` CRUD, `/aircraft/:id/seats` | aircraftController, seatController | `views/aircraft/`, `views/seats/` | BR3, BR4, BR11 |
| Flights + fares | `/flights` CRUD + search, `/flights/:id/fares` (with fare conditions) | flightController, fareController | `views/flights/`, `views/fares/` | BR7, BR15, BR19 |
| Booking | `/reservations` (new, detail, change, cancel) | reservationController | `views/reservations/` | BR5, BR6, BR10 |
| Tickets | `/tickets/:id`, `/tickets/:id/issue` | ticketController | `views/tickets/` | BR8 |
| Payments | `/reservations/:id/payments`, `/payments/:id/refund` | paymentController | `views/payments/` | BR8 |
| Baggage | `/tickets/:id/baggage` | baggageController | `views/baggage/` | BR9, BR12 |
| Check-in | `/checkin`, `/checkin/:id/boarding-pass` | checkinController | `views/checkin/` | BR13 |
| Staff | `/staff` CRUD | staffController | `views/staff/` | BR14 |
| Reports | `/reports/free-seats`, `/reports/passenger-bookings`, `/reports/route-income` | reportController | `views/reports/` | — |

## Conventions

The agreed browser experience is server-rendered EJS, matching the Passenger CRUD; Namtan owns the templates. The current implementation still returns JSON, so convert browser-facing handlers to `res.render`/redirect before treating the EJS pages as integrated. The required view names and locals are documented in [`EJS_VIEW_CONTRACT.md`](EJS_VIEW_CONTRACT.md).

All updates use POST so they work with plain HTML forms. The reservation create payload in the current controller is `{ "PassengerID": 1, "BookingStaffID": 2, "Tickets": [{ "PassengerID": 1, "FlightID": 6, "SeatID": 5, "FareID": 11 }] }`. Flight search accepts optional `origin`, `destination` and `date=YYYY-MM-DD` parameters. Fare create/update accepts `Class`, `Price`, and optional `Rules: [{ "ConditionID": 1, "Fee": 0 }]`. Staff creation accepts `StaffName`, `StaffRole`, and the matching subtype field (`SalesOffice` or `CounterNo`). Reports take `flightId`, `passengerId`, or `month=YYYY-MM` as appropriate.

- Forms use `POST` (HTML forms cannot send PUT or DELETE): `POST /x/:id` updates, `POST /x/:id/delete` deletes.
- Each controller passes `title` and the data the page needs. The names of the variables passed to a view are written in the view folder's README once they are agreed.
- Errors: the controller re-renders the form with an `error` string, and the view shows it at the top.
