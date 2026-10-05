// controllers/staffController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): STAFF + BOOKINGSTAFF / CHECKINSTAFF
// Business rules: BR14
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/staff.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/staff/ or redirect
//
// What this controller must enforce:
//   - BR14 (EER specialisation, disjoint): a staff member is BookingStaff OR CheckInStaff, never both.
//   - Creating staff = insert STAFF + insert into exactly one subtype table, in one transaction.
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
