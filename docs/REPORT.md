# Final report, slides, and submission

**Presentation day: Thursday 15 October 2026** (Lecture 10).
Submit to **Mango**: the slides, the report document, and the source code.
Every member uploads (same rule as Lab 7).

## Report sections (Lecture 8, "Term project report")

Each section has one owner. The owner writes it. Everyone proofreads it on Tue 13 Oct.

| # | Section | Owner | Source / what to include |
|---|---|---|---|
| 1 | Introduction / Background | **Kornnaphat** | Lab 7 §1.1–1.3 (business, problem, motivation) + objectives O1–O4 |
| 2 | Business rules | **Kawintida** | Lab 7 §3, BR1–BR19. Draft text ready in [`docs/BUSINESS_RULES.md`](BUSINESS_RULES.md); see `docs/DATABASE.md` for design and enforcement details. |
| 3 | ER diagram | **All**. Patarawadee exports the final version | `docs/erd/meow-airline-eer.png` (source: `meow-airline-eer.drawio`) |
| 4 | Relational model | **Patarawadee** | Every table with PK (underlined) and FK, the FD list, and the 3NF check (Lecture 7). Drafts: `docs/RELATIONAL_MODEL.md` + `docs/DATABASE.md` |
| 5 | SQL: create database | **Patarawadee** | Top of `db/schema.sql` |
| 6 | SQL: create tables | **Patarawadee** | `db/schema.sql`, explained step by step in `docs/TABLE_CREATION.md` |
| 7 | SQL: queries | **Kawintida + Kornnaphat** | `db/queries.sql` + a screenshot of each result |
| 8 | RESTful CRUD API (Node.js + Express + MySQL) | **Kawintida** (API), **Kornnaphat** (pages) | API write-up: [`docs/API_REPORT.md`](API_REPORT.md); Lecture 8 says *"if we have time"*. See the priority order below |

## Requirements from the lectures (checklist)

**Section 5–6, `db/schema.sql`** (Lecture 8 + 8.2 + 10) · Patarawadee
- [x] `CREATE DATABASE` + `USE`
- [x] `PRIMARY KEY` on every table (named `CONSTRAINT xxx_PK` is fine)
- [x] `FOREIGN KEY` with an explicit **`ON DELETE` / `ON UPDATE`** action, chosen on purpose (`RESTRICT` / `CASCADE` / `SET NULL`)
- [x] `CHECK` constraints (e.g. BR7 origin ≠ destination, Price > 0, Weight > 0)
- [x] `DEFAULT` values (e.g. `MembershipStatus 'Normal'`, `BookingDate CURRENT_DATE`)
- [x] `NOT NULL` / `UNIQUE` where the BRs require them (PassportNo, CHECKIN.TicketID)
- [x] `AUTO_INCREMENT` surrogate keys
- [x] Tables created **parents first**. Any `DROP TABLE` at the top runs **children first**
- [x] Table-creation steps from Lecture 8: data types → nullable → unique → PK/FK → defaults → domain checks → `docs/TABLE_CREATION.md`

**Section 7, `db/queries.sql`** (Lecture 8.2 + 9 + 10) · Kawintida + Kornnaphat
- [x] `INSERT` sample data for **every** table (lives in `db/seed.sql`, owned by Patarawadee)
- [x] `SELECT` with `WHERE`, `ORDER BY`, `LIMIT`, `GROUP BY` / `HAVING`, aggregates
- [x] `INNER JOIN` across 3–4 tables (through the TICKET bridge)
- [x] `LEFT JOIN … IS NULL` ("which X have no Y?")
- [x] `LIKE` wildcard search, `BETWEEN`, `IN`
- [x] at least one `VIEW`
- [x] `UPDATE` and `DELETE` examples **that show the constraints working**: one that succeeds, one rejected by `RESTRICT`, one that `CASCADE`s, one rejected by `CHECK`

## Priority order if time runs out

Lecture 8 makes the web app (section 8) optional for the report. Lab 6 grades a
working app. Build in this order and stop wherever the time runs out:

1. Schema + seed data running in MySQL (sections 4–6) ← **must have**
2. `db/queries.sql` with results (section 7) ← **must have**
3. Backend + pages for the booking flow and the 3 reports (Passenger → Reservation → Payment → reports)
4. Check-in and Baggage pages (view-only is fine. Lab 6 risk plan)
5. Railway deployment (otherwise demo from a laptop)

## Slides (all members speak)

| Part | Speaker |
|---|---|
| Problem, users, goals | Kornnaphat |
| ERD + relational model + SQL schema | Patarawadee |
| Queries + live demo of booking and reports | Kawintida |
| Wrap-up: what we'd add next | Whoever is free. Decide at rehearsal |

Demo script (Lab 6): **book a family of 3 → pay → check in → show the 3 reports.**
