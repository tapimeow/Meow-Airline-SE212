# Team rules

Ground rules for three people working in one repo. Read this before your
first commit. If the team agrees on something new, add it here in a PR.

Who owns what: [`docs/TEAM.md`](docs/TEAM.md). When things are due: [`docs/PHASES.md`](docs/PHASES.md).

## 1. Everyone

1. **Stay in your phase's files.** Each folder has one owner (see `docs/TEAM.md`).
   To change someone else's file, ask them first or open a PR and request
   their review.
2. **Never commit secrets.** `.env` is in `.gitignore`. Only `.env.example`
   (placeholder values) goes in the repo. Share Railway credentials over chat.
3. **Never commit real personal data.** Seed data is fake (Lab 6 B4.3).
4. **Branch per task**, named `<name>/<short-task>`, e.g.
   `patarawadee/schema-flight`, `kawintida/reservations-route`, `kornnaphat/checkin-page`.
5. **No direct pushes to `main`.** Open a pull request. The phase's reviewer
   (see `docs/PHASES.md`) approves it before merging.
6. **Small PRs.** One table, one route file, or one page per PR is ideal.
7. **Commit messages** start with the area: `db: add FLIGHT table (BR7)`,
   `backend: reservations create route`, `frontend: flights list page`.
8. **TODO comments** use the owner tag:
   `// TODO [Phase 4 · Backend · Kawintida]: ...`. Delete the TODO when it is done.
9. **Pull `main` before you start work each day** to avoid merge conflicts.
10. **Tick the checkbox** in `docs/PHASES.md` in the same PR that finishes the item.
11. **Stuck for more than 1 day?** Say so in the group chat. Do not wait until the deadline.

## 2. Database: Patarawadee

1. Only Patarawadee changes table structure in `db/schema.sql`. Others ask
   for changes instead of editing it.
2. Every constraint gets a comment naming its business rule, e.g. `-- BR7`.
3. Every new table gets seed rows in `db/seed.sql` in the same PR.
4. `schema.sql` must run top to bottom on an empty database without errors.
5. Table names are `UPPERCASE`. Column names are `PascalCase`, matching the proposal (`PassengerID`, `DepartureTime`).

## 3. Backend: Kawintida

1. One `routes/<entity>.js` + `controllers/<entity>Controller.js` pair per entity.
2. All database access goes through `config/db.js`. Never open your own connection.
3. **Always** use `?` placeholders: `pool.execute(sql, [values])`. Never put
   request input into the SQL string (SQL injection).
4. Anything that changes more than one table (booking, cancel, creating staff)
   runs in **one transaction**.
5. Check that a column exists in `db/schema.sql` before you query it. Do not guess names.
6. Changing a URL means updating `docs/ROUTES.md` and telling Kornnaphat.
7. **Every `async` controller function has a `try/catch`.** Express 4 does not catch errors
   from async code, and one uncaught error crashes the whole server. Show a message for
   errors the user can fix (e.g. `ER_DUP_ENTRY` = seat already taken, `ER_ROW_IS_REFERENCED_2`
   = still in use). Pass anything else to `next(err)`. Copy `controllers/passengerController.js`.

## 4. Frontend: Kornnaphat

1. One `views/<entity>/` folder per feature. Every page includes
   `partials/header` and `partials/footer`.
2. No SQL or business calculations in `.ejs` files. If a page needs other data, ask Kawintida.
3. Every page must work at phone width. Check it with the browser's device toolbar before opening a PR.
4. Use `<%= %>` (escaped) for data. Use `<%- %>` only for `include`.
5. Never put an EJS tag inside an HTML comment (`<!-- <%= x %> -->`). EJS still runs it.
6. Show the controller's `error` message at the top of the page, styled with the `.error-message` class (see `views/passengers/`).

## 5. Definition of done

A task is done when:
- it runs locally against `db/seed.sql`,
- the reviewer approved the PR and it is merged into `main`,
- the TODO comment is removed and the checkbox in `docs/PHASES.md` is ticked.
