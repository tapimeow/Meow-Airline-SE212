# views/staff/

**Owner:** Kornnaphat — Phase 5 · Frontend · Kornnaphat
**Data comes from:** `controllers/staffController.js` (Kawintida)
**Business rules shown on these pages:** BR14

EJS templates are drafted in this folder. The backend controllers still return JSON, so integration requires the backend handlers to render these views and pass the locals documented in `docs/EJS_VIEW_CONTRACT.md`.
Copy the shape of `views/passengers/`, and include `partials/header` and
`partials/footer`.

Pages to build:
- list.ejs, form.ejs (role is a radio button — only one can be picked; show a Sales office field for BookingStaff or a Counter no. field for CheckInStaff).

Rules:
- Pages only show data the controller passes in. No SQL in `.ejs`.
- Must work at phone width (≈375 px).
- Show a clear error message when the backend refuses something (e.g. the seat is taken, or the bag is too heavy).
