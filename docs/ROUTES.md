# Routes and pages

An overview of the URLs, the controller that handles them, and the views they render.

| Area | Main URLs | Controller | Views folder | BRs |
|---|---|---|---|---|
| Passengers | `/passengers` CRUD | passengerController | `views/passengers/` | BR5 |
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

Pages are server-rendered EJS. Browser-facing GET handlers render a view, and successful form submissions redirect to the relevant list or detail page.

All updates use POST so they work with plain HTML forms. Express parses `application/x-www-form-urlencoded` form fields (including `Tickets[0][FlightID]`) with `extended: true`. A reservation includes `PassengerID`, optional `BookingStaffID`, and indexed ticket fields for `PassengerID`, `FlightID`, `SeatID`, and `FareID`. Flight search accepts optional `origin`, `destination` and `date=YYYY-MM-DD` parameters. Fare forms submit `Class`, `Price`, and indexed `Rules[...][ConditionID]` / `Rules[...][Fee]` fields. Staff forms submit `StaffName`, `StaffRole`, and the matching subtype field (`SalesOffice` or `CounterNo`). Reports take `flightId`, `passengerId`, or `month=YYYY-MM` as appropriate.

- Forms use `POST` (HTML forms cannot send PUT or DELETE): `POST /x/:id` updates, `POST /x/:id/delete` deletes.
- Each controller passes `title` and the data the page needs.
- Errors: the controller re-renders the form with an `error` string, and the view shows it at the top.
