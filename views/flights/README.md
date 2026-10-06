# views/flights/

**Owner:** Kornnaphat — Phase 5 · Frontend · Kornnaphat
**Data comes from:** `controllers/flightController.js` (Kawintida)
**Business rules shown on these pages:** BR1, BR2, BR3, BR7, BR15

Nothing is built yet. Create the `.ejs` files below when Phase 5 starts.
Copy the shape of `views/passengers/`, and include `partials/header` and
`partials/footer`.

Pages to build:
- list.ejs: search form at the top + results table.
- form.ejs: Flight number dropdown (each one shows its route, e.g. "MW101 BKK → CNX", from ROUTE), Aircraft dropdown, Departure/Arrival datetime, Status.
- detail.ejs: flight info, fares table, free seats per class, "Book this flight" button.

Rules:
- Pages only show data the controller passes in. No SQL in `.ejs`.
- Must work at phone width (≈375 px).
- Show a clear error message when the backend refuses something (e.g. the seat is taken, or the bag is too heavy).
