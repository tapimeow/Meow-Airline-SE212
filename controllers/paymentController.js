// controllers/paymentController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): PAYMENT
// Business rules: BR8
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/payments.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/payments/ or redirect
//
// What this controller must enforce:
//   - Records amount / method / status only — NO real bank or card gateway (out of scope).
//   - After a Paid payment, the reservation can move Held -> Confirmed and tickets can be issued (BR8).
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
