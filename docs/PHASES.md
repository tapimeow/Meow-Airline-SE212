# Project phases: who does what, and when

Sources: Lab 6 Part B (B5), Lab 7 §5, Lectures 7–10.

> **Hard deadline: Thursday 15 October 2026. Presentation, plus slides, report
> and source code on Mango** (Lecture 10). Today is Thu 8 Oct, so there are
> **7 days**. The Lab 6 / Lab 7 week numbers are replaced by the dates below.
> Confirm the date with Aj. Pree. The same slide also shows an old final-exam
> date ("17 Oct 2021").

| Phase | What | Dates | Owner | Reviewer |
|---|---|---|---|---|
| 0 | Setup, learn MySQL, practice Passenger CRUD | Mon 5 – Tue 6 | **All** | — |
| 1 | Proposal + pitch | done ✅ | **All** | — |
| 2 | Fix ERD, relational model, FDs + 3NF | Mon 5 – Tue 6 | **Patarawadee** leads, all decide open questions | Kawintida, Kornnaphat |
| 3 | `schema.sql` + `seed.sql` running in MySQL | Wed 7 – Thu 8 | **Patarawadee** | Kawintida |
| 4 | Backend routes + controllers | Fri 9 – Mon 12 | **Kawintida** | Patarawadee |
| 5a | `queries.sql` (report §7) | Fri 9 – Sun 11 | **Kawintida + Kornnaphat** | Patarawadee |
| 5b | Frontend pages + 3 report pages | Sat 10 – Mon 12 | **Kornnaphat** | Patarawadee |
| 6 | Report doc, slides, rehearsal, Mango upload | Tue 13 – Wed 14 | **All** (see `docs/REPORT.md`) | — |
| — | **Presentation** | **Thu 15 Oct** | **All** | — |

If time runs out, follow the priority order in [`docs/REPORT.md`](REPORT.md#priority-order-if-time-runs-out).
The database and SQL come first. The web app comes after.

---

## Phase 0: Setup and practice · All · Mon 5 – Tue 6

- [ ] Install MySQL + MySQL Workbench or DBeaver (Lecture 8 shows Workbench), plus Node.js. Patarawadee ✅ (Tue 6 Oct)
- [ ] Clone the repo and run the Passenger CRUD (`README.md` → *Running locally*). Patarawadee ✅ (Tue 6 Oct: `/passengers` shows the seed data)
- [ ] Kawintida + Kornnaphat: while Patarawadee works on Phase 2, do the Lab 8/9 SQL exercises (Pine Valley, `om`). They teach exactly the JOINs that Phase 5a needs
- [ ] Kawintida + Kornnaphat: agree the URL list in `docs/ROUTES.md`

## Phase 2: Relational model + 3NF · Patarawadee leads · Mon 5 – Tue 6

Lecture 7: functional dependencies come from **business rules**, not sample data.

- [x] Second M:N decided: FARE ⇄ FARE_CONDITION via FARE_RULE (`docs/DATABASE.md`)
- [x] **All (Mon):** decide the remaining open questions in `docs/DATABASE.md` (Tue 6 Oct: A no, C yes → ROUTE table, Q5 SalesOffice / CounterNo, Q6 20/30/40 kg, B no, E Gate → FLIGHT)
- [x] Apply the ERD review fixes: new EER in `docs/erd/meow-airline-eer.drawio` + `.png`
- [ ] **All:** review the new EER. Patarawadee ✅ (Wed 7 Oct: updated with ROUTE, Gate on FLIGHT, SalesOffice / CounterNo)
- [x] **Patarawadee:** write the relational model: every table, PK, FK (report §4) → `docs/RELATIONAL_MODEL.md`
- [x] **Patarawadee:** write the FDs for each table and the 1NF → 2NF → 3NF check in `docs/DATABASE.md` (draft; the team still decides A–C)
- [x] **Kawintida:** update the business rules list with the staff rules (report §2) → `docs/BUSINESS_RULES.md`
- [x] **Kawintida + Kornnaphat:** review the 3NF table

## Phase 3: Database built · Patarawadee · Wed 7 – Thu 8

- [x] `db/schema.sql`: all tables, with every constraint from the checklist in `docs/REPORT.md` (PK, FK + ON DELETE/UPDATE, CHECK, DEFAULT). Tested on MySQL 8.0
- [x] Patarawadee reviews the columns added in the SQL (`docs/DATABASE.md` → Entities) and adds them to the EER (already covered, no diagram change needed)
- [x] `db/seed.sql`: `INSERT` for **every** table (6 aircraft, real airport codes, fake passengers)
- [x] Runs top to bottom on an empty database. Re-checked Tue 6 Oct in Workbench on MySQL 8.4: `schema.sql` then `seed.sql`, 0 errors, and the app reads the data
- [x] Screenshot the tables in Workbench / DBeaver for the report (Wed 7 Oct: `db/pic/Schema` + `db/pic/Seed`, in report §5–§6)
- [x] **Thu evening:** tell the team the schema is frozen. After this point, schema changes go through Patarawadee only (frozen early, Wed 7 Oct, with the updated EER)
- [ ] (Optional) shared Railway database, with credentials sent over chat

## Phase 4: Backend · Kawintida · Fri 9 – Mon 12

Order (stop wherever time runs out): flights/fares → **reservations + tickets (transaction)** → payments → reports → staff → check-in → baggage → airports/aircraft/seats admin.

- [x] Booking, change, and cancel run in **one transaction** (O1)
- [x] Each rule marked "backend" in `docs/DATABASE.md` is enforced
- [x] HTTP-smoke-tested backend route groups and booking → payment → issue → check-in against a disposable schema + seed copy (Thu 8 Oct); the working database was unchanged
- [ ] Test the EJS browser forms and confirm DB rows after the templates arrive

## Phase 5a: SQL queries · Kawintida + Kornnaphat · Fri 9 – Sun 11

- [x] Queries written in `db/queries.sql`. All run against `seed.sql`
- [x] Kawintida reviewed Q1–Q9 and Q19, and updated Q2 payment states and Q19 to retain fares without conditions
- [x] Kawintida ran Q1–Q9 and Q19 against local `meow_airline`; result captures are in [`docs/JUNIOR_QUERY_RESULTS.md`](JUNIOR_QUERY_RESULTS.md) (Thu 8 Oct)
- [ ] Kornnaphat runs Q10–Q18 and Q20 and adds result evidence for report §7
- [ ] The UPDATE/DELETE examples must show the constraints working (Lecture 8.2)

## Phase 5b: Frontend · Kornnaphat · Sat 10 – Mon 12

- [ ] The 3 report pages first (they are the demo), then booking, payment, check-in
- [ ] One `views/<entity>/` folder per feature. Each folder's README lists its pages
- [ ] Nav links in `views/partials/header.ejs`. Test at phone width

## Phase 6: Report, slides, submission · All · Tue 13 – Wed 14

- [ ] **Tue:** feature freeze. Assemble the report (`docs/REPORT.md` → section owners). Patarawadee ✅ §3–§6 written (Wed 7 Oct)
- [ ] **Tue:** slides (each member owns their part). Patarawadee ✅ full 21-slide draft made (Wed 7 Oct); others fill their parts
- [ ] **Wed:** full rehearsal with a timer, including the live demo: book a family of 3 → pay → check in → 3 reports
- [ ] **Wed:** every member uploads the slides, report, and source code (zip of `main`) to Mango
- [ ] **Thu 15:** present

---

## Open items

- [ ] Confirm the 15 Oct presentation date and the final report format with Aj. Pree
- [x] Decide the second M:N relationship: FARE ⇄ FARE_CONDITION
