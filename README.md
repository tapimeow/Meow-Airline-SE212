# Meow Airline

Skeleton project for the SE212 term project. Stack: MySQL + Node.js/Express + EJS,
matching section 4 of the Lab 7 proposal.

## What's already here

A full, working CRUD flow for **Passenger** - list, add, edit, delete - wired all the
way from route to controller to database to EJS view. This is the practice round from
the build plan (phase 1): everyone should run it locally once before starting the real
features, so the whole chain has been touched by hand.

Everything else is a stub or a `TODO` comment pointing at where the real code goes.
Comments are tagged by who's likely to touch that part - `[Mona - Database]`,
`[Junior - Backend]`, `[Namtan - Frontend]` - but they're a starting point, not a wall;
read the whole file you're working in.

## Folder structure

```
config/db.js          MySQL connection pool - the only place credentials live
db/schema.sql         CREATE TABLE statements (PASSENGER + AIRPORT filled in as examples)
db/seed.sql           Sample rows to develop against
routes/               One file per entity, e.g. passengers.js
controllers/          Query logic for each route file
views/                EJS templates, one folder per entity + shared partials/
public/css/           Stylesheet
server.js             Wires everything together
```

## Getting it running locally

1. `npm install`
2. Copy `.env.example` to `.env` and fill in your local MySQL credentials.
3. Create the database and load the schema + sample data:
   ```
   mysql -u root -p < db/schema.sql
   mysql -u root -p meow_airline < db/seed.sql
   ```
   (or paste both files into DBeaver's SQL editor)
4. `npm run dev`
5. Visit `http://localhost:3000/passengers`

## Next steps

See the full build order and per-role task list in the team's build plan artifact.
Short version:

1. Mona finishes `db/schema.sql` for the remaining 13 tables and `db/seed.sql` with
   realistic sample data for all of them.
2. Junior and Namtan agree on the page/route contract for the real features
   (flights, reservations, payments, check-in, reports) before writing them.
3. Junior adds one `routes/<entity>.js` + `controllers/<entity>Controller.js` pair per
   feature, copying the passengers pattern.
4. Namtan adds one `views/<entity>/` folder per feature, copying the passengers
   templates.
