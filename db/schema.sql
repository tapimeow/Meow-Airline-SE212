-- db/schema.sql
--
-- [Phase 3 · Database · Patarawadee] Report sections 5–6 (Lecture 8):
-- CREATE DATABASE + CREATE TABLE for every table in the relational model.
-- Design notes and the reason for each FK action: docs/DATABASE.md.
--
-- Run top to bottom (it drops and recreates every table, so the sample data
-- is reset too):
--
--   mysql -u root -p < db/schema.sql
--   mysql -u root -p meow_airline < db/seed.sql
--
-- or open both files in MySQL Workbench / DBeaver and execute them.
-- Tested on MySQL 8.0.

-- ---------------------------------------------------------------------
-- Section 5: create the database
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS meow_airline;
USE meow_airline;

-- Drop children before parents (Lecture 8.2: "DROP TABLE — order matters").
DROP VIEW  IF EXISTS v_flight_load;
DROP TABLE IF EXISTS CHECKIN;
DROP TABLE IF EXISTS BAGGAGE;
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS RESERVATION;
DROP TABLE IF EXISTS FARE;
DROP TABLE IF EXISTS FLIGHT;
DROP TABLE IF EXISTS SEAT;
DROP TABLE IF EXISTS CHECKINSTAFF;
DROP TABLE IF EXISTS BOOKINGSTAFF;
DROP TABLE IF EXISTS STAFF;
DROP TABLE IF EXISTS PASSENGER;
DROP TABLE IF EXISTS AIRCRAFT;
DROP TABLE IF EXISTS AIRPORT;

-- ---------------------------------------------------------------------
-- Section 6: create the tables, parents first
-- ---------------------------------------------------------------------

-- AIRPORT ------------------------------------------------------------
CREATE TABLE AIRPORT (
  AirportCode  CHAR(3)     NOT NULL,              -- IATA code, e.g. 'BKK' (typed in, not AUTO_INCREMENT)
  City         VARCHAR(80) NOT NULL,
  Country      VARCHAR(80) NOT NULL,
  CONSTRAINT AIRPORT_PK PRIMARY KEY (AirportCode)
);

-- AIRCRAFT -----------------------------------------------------------
CREATE TABLE AIRCRAFT (
  AircraftID     INT          NOT NULL AUTO_INCREMENT,
  AircraftModel  VARCHAR(50)  NOT NULL,
  TotalSeat      INT          NOT NULL,
  CONSTRAINT AIRCRAFT_PK PRIMARY KEY (AircraftID),
  CONSTRAINT AIRCRAFT_TotalSeat_CK CHECK (TotalSeat > 0)
  -- BR11 (seat rows <= TotalSeat) compares two tables, so a CHECK cannot
  -- express it. It is enforced in controllers/seatController.js.
);

-- PASSENGER ----------------------------------------------------------
CREATE TABLE PASSENGER (
  PassengerID       INT           NOT NULL AUTO_INCREMENT,
  Name              VARCHAR(100)  NOT NULL,
  PassportNo        VARCHAR(20)   NOT NULL,
  PhoneNo           VARCHAR(20),
  Email             VARCHAR(120),
  MembershipStatus  ENUM('Normal', 'Silver', 'Gold') NOT NULL DEFAULT 'Normal',
  CONSTRAINT PASSENGER_PK PRIMARY KEY (PassengerID),
  CONSTRAINT PASSENGER_PassportNo_UQ UNIQUE (PassportNo)
);

-- STAFF (supertype) --------------------------------------------------
-- BR14: a staff member is BookingStaff OR CheckInStaff, never both (disjoint).
-- StaffRole says which subtype the row belongs to. Each subtype table repeats
-- the role and points at (StaffID, StaffRole), so a CheckInStaff row can only
-- reference a STAFF row whose role is 'CheckInStaff', and the reverse.
CREATE TABLE STAFF (
  StaffID    INT           NOT NULL AUTO_INCREMENT,
  StaffName  VARCHAR(100)  NOT NULL,
  StaffRole  ENUM('BookingStaff', 'CheckInStaff') NOT NULL,
  CONSTRAINT STAFF_PK PRIMARY KEY (StaffID),
  CONSTRAINT STAFF_ID_Role_UQ UNIQUE (StaffID, StaffRole)       -- target of the subtype FKs (BR14)
);

-- BOOKINGSTAFF (subtype) ---------------------------------------------
CREATE TABLE BOOKINGSTAFF (
  StaffID    INT NOT NULL,
  StaffRole  ENUM('BookingStaff', 'CheckInStaff') NOT NULL DEFAULT 'BookingStaff',
  CONSTRAINT BOOKINGSTAFF_PK PRIMARY KEY (StaffID),
  CONSTRAINT BOOKINGSTAFF_Role_CK CHECK (StaffRole = 'BookingStaff'),           -- BR14
  CONSTRAINT BOOKINGSTAFF_STAFF_FK FOREIGN KEY (StaffID, StaffRole)
    REFERENCES STAFF (StaffID, StaffRole)
    ON DELETE RESTRICT ON UPDATE RESTRICT
  -- MySQL forbids CASCADE on a column that also has a CHECK, so the
  -- subtype row is deleted first (in one transaction) before the STAFF row.
);

-- CHECKINSTAFF (subtype) ---------------------------------------------
CREATE TABLE CHECKINSTAFF (
  StaffID    INT NOT NULL,
  StaffRole  ENUM('BookingStaff', 'CheckInStaff') NOT NULL DEFAULT 'CheckInStaff',
  CONSTRAINT CHECKINSTAFF_PK PRIMARY KEY (StaffID),
  CONSTRAINT CHECKINSTAFF_Role_CK CHECK (StaffRole = 'CheckInStaff'),           -- BR14
  CONSTRAINT CHECKINSTAFF_STAFF_FK FOREIGN KEY (StaffID, StaffRole)
    REFERENCES STAFF (StaffID, StaffRole)
    ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- SEAT ---------------------------------------------------------------
CREATE TABLE SEAT (
  SeatID      INT         NOT NULL AUTO_INCREMENT,
  AircraftID  INT         NOT NULL,                                             -- BR4
  SeatNo      VARCHAR(4)  NOT NULL,                                             -- e.g. '12A'
  SeatClass   ENUM('Economy', 'Business', 'FirstClass') NOT NULL DEFAULT 'Economy',
  CONSTRAINT SEAT_PK PRIMARY KEY (SeatID),
  CONSTRAINT SEAT_Aircraft_SeatNo_UQ UNIQUE (AircraftID, SeatNo),               -- no two '12A' on one aircraft
  CONSTRAINT SEAT_AIRCRAFT_FK FOREIGN KEY (AircraftID)
    REFERENCES AIRCRAFT (AircraftID)
    ON DELETE CASCADE ON UPDATE CASCADE           -- a seat cannot exist without its aircraft
);

-- FLIGHT -------------------------------------------------------------
CREATE TABLE FLIGHT (
  FlightID         INT         NOT NULL AUTO_INCREMENT,
  FlightNo         VARCHAR(6)  NOT NULL,          -- schedule number, e.g. 'MW101' (the same number flies every day)
  AircraftID       INT         NOT NULL,          -- BR3
  OriginCode       CHAR(3)     NOT NULL,          -- BR1
  DestinationCode  CHAR(3)     NOT NULL,          -- BR2
  DepartureTime    DATETIME    NOT NULL,
  ArrivalTime      DATETIME    NOT NULL,
  Status           ENUM('OnTime', 'Delayed', 'Canceled') NOT NULL DEFAULT 'OnTime',
  CONSTRAINT FLIGHT_PK PRIMARY KEY (FlightID),
  CONSTRAINT FLIGHT_No_Departure_UQ UNIQUE (FlightNo, DepartureTime),
  CONSTRAINT FLIGHT_Route_CK CHECK (OriginCode <> DestinationCode),             -- BR7
  CONSTRAINT FLIGHT_Times_CK CHECK (ArrivalTime > DepartureTime),
  CONSTRAINT FLIGHT_AIRCRAFT_FK FOREIGN KEY (AircraftID)
    REFERENCES AIRCRAFT (AircraftID)
    ON DELETE RESTRICT ON UPDATE CASCADE,         -- cannot delete an aircraft that has flights
  -- The two airport FKs use RESTRICT on update as well: MySQL does not
  -- allow CASCADE on columns used in a CHECK constraint (FLIGHT_Route_CK).
  CONSTRAINT FLIGHT_ORIGIN_FK FOREIGN KEY (OriginCode)
    REFERENCES AIRPORT (AirportCode)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT FLIGHT_DESTINATION_FK FOREIGN KEY (DestinationCode)
    REFERENCES AIRPORT (AirportCode)
    ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- FARE ---------------------------------------------------------------
CREATE TABLE FARE (
  FareID    INT            NOT NULL AUTO_INCREMENT,
  FlightID  INT            NOT NULL,                                            -- BR15
  Class     ENUM('Economy', 'Business', 'FirstClass') NOT NULL,
  Price     DECIMAL(10,2)  NOT NULL,
  Rule      ENUM('Refundable', 'Changeable') NOT NULL DEFAULT 'Changeable',
  CONSTRAINT FARE_PK PRIMARY KEY (FareID),
  CONSTRAINT FARE_Price_CK CHECK (Price > 0),
  CONSTRAINT FARE_FLIGHT_FK FOREIGN KEY (FlightID)
    REFERENCES FLIGHT (FlightID)
    ON DELETE CASCADE ON UPDATE CASCADE           -- a fare means nothing without its flight
);

-- RESERVATION --------------------------------------------------------
CREATE TABLE RESERVATION (
  ReservationID      INT   NOT NULL AUTO_INCREMENT,
  PassengerID        INT   NOT NULL,                                            -- BR5
  BookingStaffID     INT,                                                       -- BR16 (EER "Created"); NULL if the passenger booked online or the staff member left
  BookingDate        DATE  NOT NULL DEFAULT (CURRENT_DATE),
  ReservationStatus  ENUM('Held', 'Confirmed', 'Cancelled') NOT NULL DEFAULT 'Held',
  CONSTRAINT RESERVATION_PK PRIMARY KEY (ReservationID),
  CONSTRAINT RESERVATION_PASSENGER_FK FOREIGN KEY (PassengerID)
    REFERENCES PASSENGER (PassengerID)
    ON DELETE RESTRICT ON UPDATE CASCADE,         -- keep booking history: cannot delete a passenger who has bookings
  CONSTRAINT RESERVATION_BOOKINGSTAFF_FK FOREIGN KEY (BookingStaffID)
    REFERENCES BOOKINGSTAFF (StaffID)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- TICKET (bridge: RESERVATION M:N FLIGHT, BR6) ------------------------
CREATE TABLE TICKET (
  TicketID         INT   NOT NULL AUTO_INCREMENT,
  ReservationID    INT   NOT NULL,
  FlightID         INT   NOT NULL,
  SeatID           INT   NOT NULL,
  FareID           INT   NOT NULL,                -- the fare sold on this ticket: gives the price for income reports
  TicketIssueDate  DATE,                          -- NULL until the ticket is issued (BR8: only after payment)
  TicketStatus     ENUM('booked', 'issued', 'used', 'cancelled') NOT NULL DEFAULT 'booked',
  -- BR10: one seat cannot be on two live tickets for the same flight.
  -- ActiveSeat is 1 for a live ticket and NULL for a cancelled one. A UNIQUE
  -- index ignores NULLs, so cancelled tickets never block the seat, and two
  -- live tickets for the same seat and flight are rejected by MySQL itself.
  ActiveSeat       TINYINT AS (IF(TicketStatus = 'cancelled', NULL, 1)) STORED,
  CONSTRAINT TICKET_PK PRIMARY KEY (TicketID),
  CONSTRAINT TICKET_Seat_On_Flight_UQ UNIQUE (FlightID, SeatID, ActiveSeat),    -- BR10
  CONSTRAINT TICKET_RESERVATION_FK FOREIGN KEY (ReservationID)
    REFERENCES RESERVATION (ReservationID)
    ON DELETE CASCADE ON UPDATE CASCADE,          -- deleting a reservation deletes its tickets
  CONSTRAINT TICKET_FLIGHT_FK FOREIGN KEY (FlightID)
    REFERENCES FLIGHT (FlightID)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT TICKET_SEAT_FK FOREIGN KEY (SeatID)
    REFERENCES SEAT (SeatID)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT TICKET_FARE_FK FOREIGN KEY (FareID)
    REFERENCES FARE (FareID)
    ON DELETE RESTRICT ON UPDATE CASCADE
  -- Also enforced in the backend (they need data from other tables):
  --   the seat must belong to the flight's aircraft, the fare must belong to
  --   the same flight, BR8 (issue only after payment), BR13 (check-in rules).
);

-- PAYMENT ------------------------------------------------------------
CREATE TABLE PAYMENT (
  PaymentID      INT            NOT NULL AUTO_INCREMENT,
  ReservationID  INT            NOT NULL,
  TotalAmount    DECIMAL(10,2)  NOT NULL,
  PaymentMethod  ENUM('Cash', 'Card', 'BankTransfer', 'QR') NOT NULL,
  TimeStamp      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Status         ENUM('Paid', 'Refunded') NOT NULL DEFAULT 'Paid',
  CONSTRAINT PAYMENT_PK PRIMARY KEY (PaymentID),
  CONSTRAINT PAYMENT_Amount_CK CHECK (TotalAmount > 0),
  CONSTRAINT PAYMENT_RESERVATION_FK FOREIGN KEY (ReservationID)
    REFERENCES RESERVATION (ReservationID)
    ON DELETE RESTRICT ON UPDATE CASCADE          -- never lose money records: a paid reservation cannot be deleted
);

-- BAGGAGE ------------------------------------------------------------
CREATE TABLE BAGGAGE (
  BaggageID      INT           NOT NULL AUTO_INCREMENT,
  TicketID       INT           NOT NULL,                                        -- BR9: optional for a ticket, mandatory for a bag
  Weight         DECIMAL(5,2)  NOT NULL,                                        -- kg
  BaggageStatus  ENUM('CheckedIn', 'Loaded', 'Arrived', 'Lost') NOT NULL DEFAULT 'CheckedIn',
  CONSTRAINT BAGGAGE_PK PRIMARY KEY (BaggageID),
  CONSTRAINT BAGGAGE_Weight_CK CHECK (Weight > 0 AND Weight <= 32),             -- single-bag safety limit
  CONSTRAINT BAGGAGE_TICKET_FK FOREIGN KEY (TicketID)
    REFERENCES TICKET (TicketID)
    ON DELETE CASCADE ON UPDATE CASCADE
  -- BR12 (total weight per ticket <= class limit) is checked in
  -- controllers/baggageController.js and shown by query Q11.
);

-- CHECKIN (1:1 with TICKET) -------------------------------------------
CREATE TABLE CHECKIN (
  CheckInID       INT          NOT NULL AUTO_INCREMENT,
  TicketID        INT          NOT NULL,
  CheckInStaffID  INT,                                                          -- BR17 (EER "Processes"); NULL for self check-in
  CheckInTime     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Gate            VARCHAR(5),
  BoardingPassNo  VARCHAR(20)  NOT NULL,
  CONSTRAINT CHECKIN_PK PRIMARY KEY (CheckInID),
  CONSTRAINT CHECKIN_Ticket_UQ UNIQUE (TicketID),                               -- 1:1: a ticket is checked in once
  CONSTRAINT CHECKIN_BoardingPass_UQ UNIQUE (BoardingPassNo),
  CONSTRAINT CHECKIN_TICKET_FK FOREIGN KEY (TicketID)
    REFERENCES TICKET (TicketID)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT CHECKIN_CHECKINSTAFF_FK FOREIGN KEY (CheckInStaffID)
    REFERENCES CHECKINSTAFF (StaffID)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- TODO [Phase 2 · All]: the second M:N bridge table required by Lab 6
-- (docs/DATABASE.md, open question 1) goes here once the team decides it.
