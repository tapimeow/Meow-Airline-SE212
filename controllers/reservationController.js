// controllers/reservationController.js
//
// Owner:    [Phase 4 · Backend · Kawintida]
// Table(s): RESERVATION (+ TICKET in one transaction)
// Business rules: BR5, BR6, BR8, BR10
//
// NOTHING IS IMPLEMENTED YET. One exported function per route in
// routes/reservations.js. Follow controllers/passengerController.js:
//   - import the shared pool from config/db.js (never open your own connection)
//   - use pool.execute(sql, [values]) with ? placeholders — no string concatenation
//   - render a view from views/reservations/ or redirect
//
// What this controller must enforce:
//   - THE core feature (O1, O2). Booking MUST run in a transaction:
//   -   1) lock / re-check the seat is not already on a live ticket for that flight (BR10)
//   -   2) insert RESERVATION (status Held)  3) insert TICKET row(s)  4) commit — rollback on any error.
//   - One reservation may hold several tickets (connecting flights / family of 3 for the demo) — BR6.
//   - Each ticket names its traveller (TICKET.PassengerID, BR18). The booking form asks for one passenger per seat; the reservation's PassengerID is the booker.
//   - Cancel = set ReservationStatus Cancelled + all its tickets cancelled (+ refund PAYMENT if fare Rule allows), all in one transaction.
//   - Save RESERVATION.BookingStaffID: the booking staff member who created it (EER "Created", BR16).
//
// TODO [Phase 4 · Backend · Kawintida]: write the functions.
// TODO [Phase 4 · Backend · Kawintida]: test every route in the browser and check the rows in DBeaver.
