-- db/schema.sql
--
-- [Phase 3 · Database · Patarawadee] Report sections 5–6 (Lecture 8): the relational model turned into real SQL.
-- PASSENGER and AIRPORT are filled in below as a worked example - copy the
-- same pattern for the rest of the 14 tables (12 entities + 2 staff subtypes) from the ERD. Keep this file
-- as the single source of truth for the schema; run it top to bottom on a
-- fresh database with:
--
--   mysql -u root -p meow_airline < db/schema.sql
--
-- or paste it into DBeaver's SQL editor.

CREATE DATABASE IF NOT EXISTS meow_airline;
USE meow_airline;

-- ---------------------------------------------------------------------
-- Worked example: PASSENGER
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PASSENGER (
  PassengerID     INT AUTO_INCREMENT PRIMARY KEY,
  Name            VARCHAR(100)  NOT NULL,
  PassportNo      VARCHAR(20)   NOT NULL UNIQUE,
  PhoneNo         VARCHAR(20),
  Email           VARCHAR(120),
  MembershipStatus ENUM('Normal', 'Silver', 'Gold') NOT NULL DEFAULT 'Normal'
);

-- ---------------------------------------------------------------------
-- Worked example: AIRPORT
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS AIRPORT (
  AirportCode  CHAR(3) PRIMARY KEY,   -- e.g. 'BKK' - short code, not auto-increment
  City         VARCHAR(80) NOT NULL,
  Country      VARCHAR(80) NOT NULL
);

-- ---------------------------------------------------------------------
-- TODO [Phase 3 · Database · Patarawadee] (Wed 7 – Thu 8 Oct): add the
-- remaining tables. The full list, FKs and create order are in
-- docs/DATABASE.md. The report checklist is in docs/REPORT.md.
--
-- Every table must have (Lectures 8, 8.2, 10):
--   - PRIMARY KEY (AUTO_INCREMENT for surrogate keys)
--   - NOT NULL / UNIQUE where a business rule requires it
--   - FOREIGN KEY ... REFERENCES ... with an explicit ON DELETE / ON UPDATE
--     action, chosen on purpose (RESTRICT / CASCADE / SET NULL)
--   - CHECK for domain rules, DEFAULT where a sensible default exists
--   - a comment naming the business rule, e.g.  -- BR7
--
-- Create order (parents first):
--   AIRPORT, AIRCRAFT, PASSENGER, STAFF
--   -> BOOKINGSTAFF, CHECKINSTAFF, SEAT, FLIGHT
--   -> FARE, RESERVATION (FK BookingStaffID, from the EER "Created")
--   -> TICKET, PAYMENT
--   -> BAGGAGE, CHECKIN (FK CheckInStaffID, from the EER "Processes";
--                        TicketID UNIQUE because CheckIn is 1:1 with Ticket)
--   + the second M:N bridge table, once the team picks it (docs/DATABASE.md)
--
-- Rules that a CHECK cannot express (BR8, BR10–BR13) are enforced in
-- the backend. See the table in docs/DATABASE.md.
--
-- Example of the FK + CHECK pattern for FLIGHT:
--
-- CREATE TABLE IF NOT EXISTS FLIGHT (
--   FlightID        INT AUTO_INCREMENT PRIMARY KEY,
--   AircraftID      INT NOT NULL,
--   OriginCode      CHAR(3) NOT NULL,
--   DestinationCode CHAR(3) NOT NULL,
--   DepartureTime   DATETIME NOT NULL,
--   ArrivalTime     DATETIME NOT NULL,
--   Status          ENUM('OnTime','Delayed','Canceled') NOT NULL DEFAULT 'OnTime',
--   FOREIGN KEY (AircraftID)      REFERENCES AIRCRAFT(AircraftID)  ON DELETE RESTRICT ON UPDATE CASCADE,  -- BR3
--   FOREIGN KEY (OriginCode)      REFERENCES AIRPORT(AirportCode)  ON DELETE RESTRICT ON UPDATE CASCADE,  -- BR1
--   FOREIGN KEY (DestinationCode) REFERENCES AIRPORT(AirportCode)  ON DELETE RESTRICT ON UPDATE CASCADE,  -- BR2
--   CHECK (OriginCode <> DestinationCode),                                                               -- BR7
--   CHECK (ArrivalTime > DepartureTime)
-- );
