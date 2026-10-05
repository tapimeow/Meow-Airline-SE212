# Project phases — who does what, and when

Sources: **Lab 6 Part B** (SE212 project proposal, section B5) and **Lab 7**
(Database Design Proposal, section 5). Lecture-schedule details will be
added when the team receives them. See *Open items* at the bottom.

> **Two week numbers.** Lab 6 counts **project weeks** (Week 4 = ERD, Week 9 = demo).
> Lab 7 counts **course weeks** (Week 7 = EER, Week 15 = presentation).
> The table below shows both. Mango is the final authority on due dates.

| Phase | What | Lab 6 week | Lab 7 milestone | Owner | Reviewer |
|---|---|---|---|---|---|
| 0 | Setup + learn MySQL, practice Passenger CRUD | Weeks 1–2 | — | **All** | — |
| 1 | Proposal + 3-minute pitch | Next class | M1 (Week 6) ✅ | **All** | — |
| 2 | EER diagram + 3NF schema | Week 4 | M2 (Week 7), M3 (Week 9) | **All** (EER), **Patarawadee** leads 3NF | Kawintida, Kornnaphat |
| 3 | Database built + sample data | Week 6 | M4 (Week 11) | **Patarawadee** | Kawintida |
| 4 | Backend routes + SQL | Week 7 | — | **Kawintida** | Patarawadee |
| 5 | Frontend pages + 3 reports, ≥10 queries | Week 8 | M5 (Week 13) | **Kornnaphat** (pages), **Kawintida + Kornnaphat** (queries) | Patarawadee |
| 6 | Demo, Q&A, short report / slides | Week 9 | M6 (Week 15) | **All** | — |

Each phase **owner** is responsible for finishing it on time. Others may help,
but they ask the owner first (see `RULES.md`). The **reviewer** approves the
owner's pull requests for that phase.

---

## Phase 0 — Setup and practice · All

From the Lab 7 risk plan: *"build one small CRUD page (Passenger) as practice
before the real pages start."*

- [ ] Each member installs Node.js, MySQL and DBeaver, then clones the repo
- [ ] Each member runs the existing Passenger CRUD locally (`README.md` → *Running locally*)
- [ ] Each member finishes a short Express + MySQL + EJS tutorial
- [ ] Each member makes one small practice change on their own branch and opens a PR (to practise the workflow)

Files: `routes/passengers.js`, `controllers/passengerController.js`, `views/passengers/`

## Phase 1 — Proposal · All ✅

- [x] Lab 6 Part B printed, signed by Aj. Pree, pitched (4 slides)
- [x] Lab 7 proposal PDF uploaded to Mango by **every** member

## Phase 2 — EER diagram + 3NF schema · All, led by Patarawadee

- [ ] **All:** finish the Draw.io EER (Chen notation) with all 12 entities, the Staff specialisation, and cardinalities from BR1–BR15
- [ ] **All:** resolve the open design questions in `docs/DATABASE.md` (especially the **second M:N relationship**, which Lab 6 requires)
- [ ] **Patarawadee:** convert the EER to relational tables, list every PK/FK, and write down the 3NF check for each table in `docs/DATABASE.md`
- [ ] **Kawintida + Kornnaphat:** review the 3NF table list
- [ ] Export the EER as PNG to `docs/erd/` and submit to Mango

## Phase 3 — Database built · Patarawadee

- [ ] `db/schema.sql`: all 14 `CREATE TABLE`s (12 entities + `BOOKINGSTAFF` / `CHECKINSTAFF`), each constraint commented with its BR number
- [ ] `db/seed.sql`: realistic fake data (6 aircraft, real airport codes, fake passengers) with enough rows to test a full booking end to end
- [ ] Verify everything in DBeaver, then screenshot the tables for the deliverable
- [ ] Set up the shared Railway MySQL and send the credentials to the team **over chat, never in GitHub**
- [ ] Update `config/db.js` comments / `.env.example` if any connection setting changes

## Phase 4 — Backend routes · Kawintida

Files: `routes/*.js`, `controllers/*Controller.js`, `server.js`

- [ ] Agree the URL list in `docs/ROUTES.md` with Kornnaphat **before** coding
- [ ] Order: airports → aircraft/seats → flights/fares → reservations/tickets → payments → staff → check-in → baggage → reports
- [ ] Booking, change, and cancel run inside **one transaction** (O1: zero double bookings)
- [ ] Every business rule marked "backend" in `docs/DATABASE.md` is enforced in a controller
- [ ] Test each route in the browser and check the rows in DBeaver
- [ ] **Checkpoint (end of Lab 6 Week 7):** if behind schedule, make Baggage and Check-in view-only (risk plan)

## Phase 5 — Frontend + reports · Kornnaphat (+ Kawintida for queries)

Files: `views/**`, `public/css/style.css`, `public/js/main.js`, `db/queries.sql`

- [ ] **Kornnaphat:** one `views/<entity>/` folder per feature (each folder has a README listing its pages)
- [ ] **Kornnaphat:** add nav links in `views/partials/header.ejs`
- [ ] **Kornnaphat:** build the 3 report pages (`views/reports/`) with real MySQL data
- [ ] **Kornnaphat:** test every page at phone width
- [ ] **Kawintida:** queries Q1–Q5 in `db/queries.sql`
- [ ] **Kornnaphat:** queries Q6–Q10 in `db/queries.sql`
- [ ] Both: put the query results (screenshots) into the M5 deliverable

## Phase 6 — Demo and presentation · All

- [ ] Deploy to Railway; the demo runs from the URL, not a laptop
- [ ] Rehearse the live script: **book a family of 3 → pay → check in → show the 3 reports**
- [ ] Slides + short report; every member speaks
- [ ] Every member uploads the deliverables to Mango

---

## Open items

- [ ] **Lecture schedule:** waiting for the lecture material. Add any lecture requirements here and adjust the weeks above.
- [ ] Confirm whether the Lab 6 "project weeks" and Lab 7 "course weeks" refer to the same deadlines (ask Aj. Pree / TA).
