# views/reservations/

**Owner:** Kornnaphat — Phase 5 · Frontend · Kornnaphat
**Data comes from:** `controllers/reservationController.js` (Kawintida)
**Business rules shown on these pages:** BR5, BR6, BR8, BR10

Nothing is built yet. Create the `.ejs` files below when Phase 5 starts.
Copy the shape of `views/passengers/`, and include `partials/header` and
`partials/footer`.

Pages to build:
- list.ejs, detail.ejs, form.ejs (choose passenger, flight, seat from FREE seats only), cancel confirm.
- Goal O2: one booking in under 2 minutes — keep the form to one page.

Rules:
- Pages only show data the controller passes in. No SQL in `.ejs`.
- Must work at phone width (≈375 px).
- Show a clear error message when the backend refuses something (e.g. the seat is taken, or the bag is too heavy).
