-- db/schema.sql
--
-- [Mona - Database] This is the M3/M4 deliverable turned into real SQL.
-- PASSENGER and AIRPORT are filled in below as a worked example - copy the
-- same pattern for the rest of the 15 tables from the ERD. Keep this file
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
-- TODO [Mona - Database]: add the remaining tables from the ERD, same
-- pattern as above - PRIMARY KEY on the underlined attribute, FOREIGN KEY
-- for every FK column, and a CHECK/ENUM wherever a business rule
-- constrains the values a column can hold.
--
-- Remaining tables, with the business rule each one's constraints trace
-- back to (see the Lab 7 proposal, section 3 Business rules):
--
--   AIRCRAFT    (BR11: seat rows for an Aircraft must not exceed TotalSeat -
--                enforce this in the backend when a Seat is inserted, not
--                something a plain CHECK constraint can express)
--   FLIGHT      (FK to AIRCRAFT, and two FKs to AIRPORT for origin/destination -
--                BR7: origin and destination cannot be the same airport)
--   SEAT        (FK to AIRCRAFT)
--   RESERVATION (FK to PASSENGER)
--   FARE        (FK to FLIGHT - BR15)
--   TICKET      (FKs to RESERVATION, FLIGHT, SEAT - the bridge table
--                resolving Reservation-Flight M:N, BR6)
--   BAGGAGE     (FK to TICKET)
--   PAYMENT     (FK to RESERVATION)
--   CHECKIN     (FK to TICKET, and TicketID should be UNIQUE here since
--                CheckIn is 1:1 with Ticket)
--   STAFF       (StaffID, StaffName, StaffRole)
--   BOOKINGSTAFF   (StaffID as both PK and FK back to STAFF - EER
--                    specialisation, BR14)
--   CHECKINSTAFF   (same pattern as BOOKINGSTAFF)
--
-- Example of the FK + ENUM pattern to follow for FLIGHT:
--
-- CREATE TABLE IF NOT EXISTS FLIGHT (
--   FlightID        INT AUTO_INCREMENT PRIMARY KEY,
--   AircraftID      INT NOT NULL,
--   OriginCode      CHAR(3) NOT NULL,
--   DestinationCode CHAR(3) NOT NULL,
--   DepartureTime   DATETIME NOT NULL,
--   ArrivalTime     DATETIME NOT NULL,
--   Status          ENUM('Scheduled','Departed','Arrived','Cancelled') NOT NULL DEFAULT 'Scheduled',
--   FOREIGN KEY (AircraftID) REFERENCES AIRCRAFT(AircraftID),
--   FOREIGN KEY (OriginCode) REFERENCES AIRPORT(AirportCode),
--   FOREIGN KEY (DestinationCode) REFERENCES AIRPORT(AirportCode),
--   CHECK (OriginCode <> DestinationCode)
-- );
