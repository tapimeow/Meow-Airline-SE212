# Team rules

Not code - just the ground rules for working in this repo across three people.
Read this before your first commit; update it if the team agrees on something new.

## Everyone

1. Never commit `.env` or real database credentials. `.gitignore` already excludes
   `.env` - only `.env.example` (placeholder values) goes into the repo.
2. Branch off `main` per feature, named `<role>/<short-description>` -
   e.g. `junior/flights-route`, `namtan/checkin-page`, `mona/schema-fare`.
3. Open a pull request before merging to `main`; at least one other teammate
   reviews it. No direct pushes to `main`.
4. Tag new `TODO` comments the same way this skeleton does -
   `[Mona - Database]`, `[Junior - Backend]`, `[Namtan - Frontend]` - so
   ownership stays obvious to whoever opens the file next.
5. Test your own feature locally against the shared `db/seed.sql` data
   before opening a pull request.
6. Check a column or table actually exists in `db/schema.sql` before
   writing a query against it - ask Mona rather than guessing a name.
7. Tick off the matching item in README.md's "Next steps" list once a
   feature is merged, so the team can see progress at a glance.

## Mona - Database

1. Only Mona changes table structure in `db/schema.sql` (new tables,
   columns, constraints). Junior or Namtan needing a schema change asks for
   it rather than editing the file directly - two people changing table
   structure at once is how migrations get out of sync.
2. Every new table or column gets matching sample rows added to
   `db/seed.sql` in the same pull request, so the app never points at
   empty tables.
3. Every constraint added to the schema gets a comment naming the business
   rule it enforces (e.g. `-- BR11`), same as the existing examples -
   that's what makes the schema traceable back to the proposal.

## Junior - Backend

1. One `routes/<entity>.js` + `controllers/<entity>Controller.js` pair per
   entity - don't mix two entities' logic into one file.
2. All database access goes through the shared pool in `config/db.js` -
   never open a separate connection in a controller.
3. Queries always use `?` placeholders with values passed separately
   (`pool.execute(sql, [values])`) - never build a query by concatenating
   request input into the SQL string.
4. Any change that touches more than one table in one action (booking a
   seat, cancelling a reservation) runs inside a transaction, so a failure
   partway through can't leave the database half-updated.

## Namtan - Frontend

1. One `views/<entity>/` folder per feature, reusing `partials/header.ejs`
   and `partials/footer.ejs` for the page shell - don't copy the `<html>`
   boilerplate into every new template.
2. Every new page has to work at phone width (per the proposal's scope) -
   check it by shrinking the browser window before opening a pull request.
3. Views only display what the controller already passed in - no database
   queries or business calculations inside an `.ejs` file. If a page needs
   different data, that's a change to ask Junior for in the controller.
