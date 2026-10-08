# views/airports/

**Owner:** Kornnaphat — Phase 5 · Frontend · Kornnaphat
**Data comes from:** `controllers/airportController.js` (Kawintida)
**Business rules shown on these pages:** BR1, BR2, BR7

EJS templates are drafted in this folder. The backend controllers still return JSON, so integration requires the backend handlers to render these views and pass the locals documented in `docs/EJS_VIEW_CONTRACT.md`.
Copy the shape of `views/passengers/`, and include `partials/header` and
`partials/footer`.

Pages to build:
- list.ejs: table of Code, City, Country + Edit/Delete.
- form.ejs: Code (3 letters, read-only when editing), City, Country.

Rules:
- Pages only show data the controller passes in. No SQL in `.ejs`.
- Must work at phone width (≈375 px).
- Show a clear error message when the backend refuses something (e.g. the seat is taken, or the bag is too heavy).
