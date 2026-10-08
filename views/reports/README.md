# views/reports/

**Owner:** Kornnaphat — Phase 5 · Frontend · Kornnaphat
**Data comes from:** `controllers/reportController.js` (Kawintida)

Pages:
- `index.ejs` — links to the 3 reports
- `free-seats.ejs` — Q1: pick a flight → table of class / total seats / sold / free
- `passenger-bookings.ejs` — Q2: pick a passenger → bookings, with unpaid ones highlighted
- `route-income.ejs` — Q3: pick a month → income per route, and the route with the fewest seats sold highlighted

The view locals follow [`../../docs/EJS_VIEW_CONTRACT.md`](../../docs/EJS_VIEW_CONTRACT.md). The current report handlers still return JSON; the backend handoff must render these templates and pass the contract locals before browser navigation is integrated.

These three pages are the main part of the 15 Oct presentation demo, so make them easy to read.
