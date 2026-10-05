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

-- TODO [Phase 3 · Database · Patarawadee]: add seed rows for AIRCRAFT, FLIGHT, SEAT,
-- RESERVATION, FARE, TICKET, BAGGAGE, PAYMENT, CHECKIN, STAFF and its two
-- subtype tables once those CREATE TABLE statements exist in schema.sql.
