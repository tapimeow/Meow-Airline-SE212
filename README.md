# Meow Airline ✈️🐱

SE212 / 953212 term project: a booking system for **Meow Airline**, a small
regional airline with eight aircraft. It replaces the shared Excel file and LINE
chats with one MySQL database, so seats can't be double-booked and the
manager gets reports in seconds.

**Stack:** MySQL 8 · Node.js + Express · EJS / HTML / CSS / JavaScript · MySQL Workbench / DBeaver · draw.io

**Live site:** https://meow-airline.up.railway.app (hosted on Railway, redeployed on every push to `main`)

## Team

| Member | Student ID | Role | Main work |
|---|---|---|---|
| Patarawadee Kunna | 682115034 | Database | EER, relational model, FDs and 3NF, `db/schema.sql`, `db/seed.sql`, `config/db.js` |
| Kawintida Kantong | 682115002 | Backend | `routes/`, `controllers/`, `server.js`, queries Q1–Q9 and Q19 |
| Kornnaphat Uttama | 682115001 | Frontend | `views/`, `public/`, report pages, queries Q10–Q18 and Q20 |

## Goals

- **O1** Zero double-booked seats
- **O2** One booking in under 2 minutes (it used to take about 8)
- **O3** Seats sold and income per route in under 10 seconds
- **O4** Live free seats per flight, by class

The system answers the airline's three key questions, each as a report page:

1. How many seats are still free on flight MW101 on 20 October, and in which class?
2. Which bookings has this passenger made, and which are not paid yet?
3. How much did each route earn last month, and which route sold the fewest seats?

## What it does

- **Booking:** book several travellers on one reservation in a single transaction; only free seats of the fare's class can be picked.
- **Payments and tickets:** payments are kept as a ledger (a refund is a new row); tickets are issued only once the reservation is fully paid (BR8).
- **Check-in and baggage:** check in issued tickets before departure, print a boarding pass, and record bags within the class weight limit.
- **Admin:** airports, routes, aircraft and seats, flights and fares, staff, passengers.
- **Reports:** free seats by class, a passenger's bookings and payment status, income per route.

## The database rules itself

MySQL refuses bad data even if the app has a bug. For example:

- **No double booking (BR10):** `TICKET.ActiveSeat` is 1 for a live ticket and NULL for a cancelled one, and `UNIQUE (FlightID, SeatID, ActiveSeat)` rejects a second live ticket for the same seat.
- **Seat and fare must fit the flight:** triggers on TICKET refuse a seat from another aircraft or a seat class that doesn't match the fare.
- **Disjoint staff roles (BR14):** a composite FK on `(StaffID, StaffRole)` stops a staff member from being both booking and check-in staff.

Rules that need totals or the current time (BR8, BR11, BR12, BR13) are checked in the controllers inside transactions.

## Folder structure

```
config/db.js        MySQL connection pool (credentials come from .env)
db/schema.sql       CREATE DATABASE + 17 tables, triggers
db/seed.sql         Fake sample data for every table
db/queries.sql      20 report queries (Q1–Q20)
routes/             One file per area: the URL list
controllers/        One file per area: SQL + business rules
views/              EJS pages, one folder per area, shared partials
public/             CSS, browser-side JavaScript, images
server.js           App entry point: wires everything together
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
4. `npm run dev`, then open http://localhost:3000

## Out of scope

Real bank/card payment (we only record payments) · native mobile app · payroll and staff scheduling.
