# views/airports/

**Owner:** Kornnaphat — Phase 5 · Frontend · Kornnaphat
**Data comes from:** `controllers/airportController.js` (Kawintida)
**Business rules shown on these pages:** BR1, BR2, BR7

Nothing is built yet. Create the `.ejs` files below when Phase 5 starts.
Copy the shape of `views/passengers/`, and include `partials/header` and
`partials/footer`.

Pages to build:
- list.ejs: table of Code, City, Country + Edit/Delete.
- form.ejs: Code (3 letters, read-only when editing), City, Country.

Rules:
- Pages only show data the controller passes in. No SQL in `.ejs`.
- Must work at phone width (≈375 px).
- Show a clear error message when the backend refuses something (e.g. the seat is taken, or the bag is too heavy).
