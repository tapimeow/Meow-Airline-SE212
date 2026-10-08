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

## Section 1 — Introduction / Background

### 1.1 Business background

Meow Airline is a small regional airline operating a six-aircraft fleet and scheduled routes between cities in Thailand and nearby countries. Its day-to-day work includes maintaining flight schedules and fares, booking seats for individual passengers and families, recording payments, issuing tickets, and checking passengers in before departure. The project models these activities in one database-backed booking system.

### 1.2 Problem and motivation

When flight, passenger, and payment information is kept across shared spreadsheets and LINE conversations, staff must reconcile updates by hand. The same seat can appear available to two agents, booking details can be difficult to trace, and managers may need to assemble sales and availability figures manually. These gaps slow down service and make operational decisions less reliable. Meow Airline therefore needs one consistent source of booking data, with rules that prevent invalid seat assignments and reports that answer common operational questions directly.

### 1.3 Project objectives

The system has four objectives:

1. **O1 — Prevent double booking:** ensure that no flight has two active tickets for the same seat.
2. **O2 — Shorten booking time:** reduce the time needed to complete one booking from about eight minutes to under two minutes.
3. **O3 — Speed up income reporting:** return seats sold and fare income for a selected flight or route in under ten seconds.
4. **O4 — Show live availability:** report free seats for each cabin class on a flight.

The application uses MySQL for persistent data, Node.js and Express for request handling, and server-rendered EJS pages for the browser interface. Its scope includes flight and fare information, passengers, reservations and tickets, payments, baggage, check-in, staff, and reports. Real bank or card processing, native mobile applications, and payroll are out of scope.

## Kornnaphat presentation segment — problem, users, and goals

**Suggested speaking notes (about 45–60 seconds):**

> Meow Airline is a small regional carrier with six aircraft. Its staff coordinate schedules, bookings, and payment details, and the project addresses the operational risk of keeping those records in separate spreadsheets and LINE conversations. When two agents cannot see the same current seat inventory, a seat may be offered twice; manual lookups also make booking and reporting slower. Our users are booking staff, check-in staff, and the airline manager. We are building one MySQL-backed system with rules that block duplicate live seat assignments and pages for booking and check-in. Our goals are to prevent double bookings, bring a booking from about eight minutes to under two, produce seats-sold and income reports in under ten seconds, and show free seats by class. The rest of the presentation explains the data model and demonstrates these workflows.

**Slide outline:**

- **Problem and users:** fragmented spreadsheet/chat records; booking staff, check-in staff, and manager.
- **Why it matters:** duplicate-seat risk, slower booking, and manual reporting.
- **Objectives O1–O4:** prevent duplicate seats; under 2-minute booking; under 10-second income report; real-time availability by cabin class.

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
