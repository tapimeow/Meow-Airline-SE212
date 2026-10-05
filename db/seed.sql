-- db/seed.sql
--
-- [Phase 3 · Database · Patarawadee] Sample rows so Kawintida and Kornnaphat can build against real
-- data instead of an empty database. Run this after schema.sql:
--
--   mysql -u root -p meow_airline < db/seed.sql
--
-- Add a handful of rows for every table you add to schema.sql - enough
-- that a full booking (passenger -> reservation -> ticket -> payment ->
-- check-in) can actually be tested end to end.

USE meow_airline;

INSERT INTO PASSENGER (Name, PassportNo, PhoneNo, Email, MembershipStatus) VALUES
  ('Somsak Jaidee', 'AA1234567', '0812345678', 'somsak@example.com', 'Normal'),
  ('Nara Chaisiri',  'AB7654321', '0898765432', 'nara@example.com',   'Gold');

INSERT INTO AIRPORT (AirportCode, City, Country) VALUES
  ('BKK', 'Bangkok',   'Thailand'),
  ('CNX', 'Chiang Mai','Thailand'),
  ('HKT', 'Phuket',    'Thailand');

-- TODO [Phase 3 · Database · Patarawadee] (Wed 7 – Thu 8 Oct): INSERT rows for
-- EVERY table (report section 7 requires it), in the same parent-first order as
-- schema.sql: AIRCRAFT (6 of them), STAFF + BOOKINGSTAFF + CHECKINSTAFF, SEAT,
-- FLIGHT, FARE, RESERVATION, TICKET, PAYMENT, BAGGAGE, CHECKIN.
-- Include rows the queries in db/queries.sql need, e.g. an unpaid reservation
-- (Q2), a ticket not checked in (Q10), an aircraft with no flights (Q12), and
-- a family of 3 on one reservation for the demo.
