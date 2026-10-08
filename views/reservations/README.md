# views/reservations/

**Owner:** Kornnaphat — Phase 5 · Frontend · Kornnaphat
**Data comes from:** `controllers/reservationController.js` (Kawintida)
**Business rules shown on these pages:** BR5, BR6, BR8, BR10

EJS templates are drafted in this folder. The backend controllers still return JSON, so integration requires the backend handlers to render these views and pass the locals documented in `docs/EJS_VIEW_CONTRACT.md`.
Copy the shape of `views/passengers/`, and include `partials/header` and
`partials/footer`.

Pages to build:
- list.ejs, detail.ejs, form.ejs (choose the booker, the flight, then one traveller + one FREE seat per ticket), cancel confirm.
- Goal O2: one booking in under 2 minutes — keep the form to one page.

Rules:
- Pages only show data the controller passes in. No SQL in `.ejs`.
- Must work at phone width (≈375 px).
- Show a clear error message when the backend refuses something (e.g. the seat is taken, or the bag is too heavy).
