# views/aircraft/

**Owner:** Kornnaphat — Phase 5 · Frontend · Kornnaphat
**Data comes from:** `controllers/aircraftController.js` (Kawintida)
**Business rules shown on these pages:** BR3, BR4, BR11

Nothing is built yet. Create the `.ejs` files below when Phase 5 starts.
Copy the shape of `views/passengers/`, and include `partials/header` and
`partials/footer`.

Pages to build:
- list.ejs: Model, TotalSeat, seats created so far.
- form.ejs: AircraftModel, TotalSeat.
- detail.ejs: aircraft info + its seat map grouped by class.

Rules:
- Pages only show data the controller passes in. No SQL in `.ejs`.
- Must work at phone width (≈375 px).
- Show a clear error message when the backend refuses something (e.g. the seat is taken, or the bag is too heavy).
