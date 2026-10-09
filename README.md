# Meow Airline ✈️🐱

SE212 / 953212 term project: a booking system for **Meow Airline**, a small
regional airline with six aircraft. It replaces the shared Excel file and LINE
chats with one MySQL database, so seats can't be double-booked and the
manager gets reports in seconds.

**Team:** Patarawadee Kunna (682115034) · Kawintida Kantong (682115002) · Kornnaphat Uttama (682115001)
**Stack:** MySQL · Node.js + Express · EJS/HTML/CSS/JS · Railway · GitHub · DBeaver / Workbench

> 📅 **Report submission on Mango: Wednesday 14 October 2026. Presentation (with slides and source code): Thursday 15 October 2026.**
> The day-by-day plan is in [`docs/PHASES.md`](docs/PHASES.md).

![Architecture: Browser ⇄ Express ⇄ MySQL](docs/architecture.png)

## Status: skeleton

**Done:** the database. `db/schema.sql`, `db/seed.sql` and `db/queries.sql` run on MySQL 8.0,
and the **Passenger CRUD** works (the Phase 0 practice page).
Every other app file contains only comments that say **who** builds it,
**in which phase**, and **which business rules** it must enforce.

## Read these first

| File | What's in it |
|---|---|
| [`RULES.md`](RULES.md) | Team rules: branches, PRs, who may edit what, coding rules |
| [`docs/PHASES.md`](docs/PHASES.md) | Phases 0–6, owner and reviewer for each, checklists |
| [`docs/TEAM.md`](docs/TEAM.md) | Who owns which files and how to find your TODOs |
| [`docs/DATABASE.md`](docs/DATABASE.md) | Tables, relationships, ERD review fixes, where each BR is enforced, open questions, 3NF table |
| [`docs/RELATIONAL_MODEL.md`](docs/RELATIONAL_MODEL.md) | Relational model for report §4: every table, PK, FK and FK action, and how the EER maps to tables |
| [`docs/TABLE_CREATION.md`](docs/TABLE_CREATION.md) | Report §5–6: how `schema.sql` was built, step by step (types, NULL, UNIQUE, PK/FK, defaults, CHECKs) |
| [`docs/REPORT.md`](docs/REPORT.md) | Final report sections and owners, lecture checklists, slides, priority order |
| [`docs/erd/`](docs/erd/) | The EER diagram: `meow-airline-eer.png`, editable `meow-airline-eer.drawio` |
| [`docs/ROUTES.md`](docs/ROUTES.md) | URL ↔ controller ↔ page contract for the backend and frontend |

## Goals (from the proposal)

- **O1** Zero double-booked seats in the first month
- **O2** One booking in under 2 minutes (currently about 8)
- **O3** Seats-sold-and-income report for any flight in under 10 seconds
- **O4** Real-time free seats per flight, by class

Reports the system must answer:
1. How many seats are still free on flight MW101 on 20 October, and in which class?
2. Which bookings has this passenger made, and which are not paid yet?
3. How much did each route earn last month, and which route sold the fewest seats?

## Folder structure

```
config/db.js            MySQL pool, the only place credentials are read      [Patarawadee]
db/schema.sql           CREATE TABLEs (17 tables, 2 M:N bridges)            [Patarawadee, Phase 3]
db/seed.sql             Fake sample data                                     [Patarawadee, Phase 3]
db/queries.sql          20 queries for report section 7                      [Kawintida + Kornnaphat, Phase 5a]
routes/                 One file per entity: URL list                        [Kawintida, Phase 4]
controllers/            One file per entity: SQL + business rules            [Kawintida, Phase 4]
views/                  One folder per entity (each has a README of pages)   [Kornnaphat, Phase 5]
public/css, public/js   Styling and small browser helpers                    [Kornnaphat, Phase 5]
server.js               Wires routes together                                [Kawintida, Phase 4]
docs/                   Plans and design notes                               [All]
```

## Running locally

1. `npm install`
2. Copy `.env.example` to `.env` and fill in your local MySQL credentials.
3. Load the database (or open the files in Workbench / DBeaver and run them in this order):
   ```
   mysql -u root -p < db/schema.sql
   mysql -u root -p meow_airline < db/seed.sql
   mysql -u root -p meow_airline < db/queries.sql   # optional: runs every report query
   ```
   Running `schema.sql` again resets all the data.
4. `npm run dev`, then open http://localhost:3000/passengers

## Out of scope

Real bank/card payment (we only record payments) · native mobile app · payroll and staff scheduling.
