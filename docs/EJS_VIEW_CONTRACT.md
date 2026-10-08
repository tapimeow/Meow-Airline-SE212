# EJS view contract for the frontend handoff

**Decision:** use server-rendered EJS pages, following the existing Passenger CRUD. Namtan owns the page templates; backend handlers supply data, an `error` value, and redirect after successful form submissions. Every page should also receive `title`.

The following view names and locals are the backend-to-template contract. Collection names are plural; a single record is singular.

| View | Locals |
|---|---|
| `airports/list` | `airports`, `error` |
| `airports/form` | `airport` (null when creating), `editing`, `error` |
| `aircraft/list` | `aircraft`, `error` |
| `aircraft/detail` | `aircraft`, `seats`, `error` |
| `aircraft/form` | `aircraft` (null when creating), `editing`, `error` |
| `seats/form` | `aircraft`, `seat` (null when creating), `error` |
| `flights/list` | `flights`, `filters`, `airports`, `error` |
| `flights/form` | `flight` (null when creating), `routes`, `aircraft`, `editing`, `error` |
| `flights/detail` | `flight`, `fares`, `availability`, `error` |
| `fares/form` | `flight`, `fare` (null when creating), `conditions`, `fareRules`, `error` |
| `reservations/list` | `reservations`, `filters`, `passengers`, `error` |
| `reservations/form` | `reservation` (null when creating), `passengers`, `flights`, `staff`, `error` |
| `reservations/detail` | `reservation`, `tickets`, `payments`, `error` |
| `tickets/detail` | `ticket`, `baggage`, `checkin`, `error` |
| `payments/form` | `reservation`, `amountDue`, `error` |
| `baggage/form` | `ticket`, `baggage`, `totalWeight`, `weightLimit`, `error` |
| `checkin/search` | `tickets`, `reservationId`, `passportNo`, `error` |
| `checkin/boarding-pass` | `boardingPass`, `error` |
| `staff/list` | `staff`, `error` |
| `staff/form` | `staffMember` (null when creating), `editing`, `error` |
| `reports/index` | `error` |
| `reports/free-seats` | `flights`, `selectedFlightId`, `results`, `error` |
| `reports/passenger-bookings` | `passengers`, `selectedPassengerId`, `results`, `error` |
| `reports/route-income` | `month`, `routes`, `fewestRoutes`, `error` |

`FLIGHT.DepartureTime` and `ArrivalTime` are MySQL `DATETIME` values. Pages should format them in `Asia/Bangkok`; `server.js` provides `formatFlightTime` for that display.

Every rendered page also receives `title`. The optional `editing` local distinguishes a new form from a failed edit submission when submitted values are present but do not include a database ID. Do not put SQL or business calculations in the templates. For booking and other write actions, controller validation errors should re-render the appropriate form with the submitted values and `error`; success should redirect to the list or detail page.
