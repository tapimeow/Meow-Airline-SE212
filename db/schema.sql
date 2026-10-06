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
-- Dropping TICKET also drops its triggers; the procedure they call is separate.
DROP VIEW  IF EXISTS v_flight_load;
DROP PROCEDURE IF EXISTS ticket_check_seat_and_fare;
DROP TABLE IF EXISTS CHECKIN;
DROP TABLE IF EXISTS BAGGAGE;
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS RESERVATION;
DROP TABLE IF EXISTS FARE_RULE;
DROP TABLE IF EXISTS FARE_CONDITION;
DROP TABLE IF EXISTS FARE;
DROP TABLE IF EXISTS FLIGHT;
DROP TABLE IF EXISTS ROUTE;
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
-- Total (every STAFF row has a subtype row) cannot be a constraint here:
-- MySQL checks FKs per statement, so STAFF must exist before its subtype
-- row. staffController inserts both in one transaction, and Q8b in
-- db/queries.sql lists any staff member left without a subtype row.
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
  StaffID      INT          NOT NULL,
  StaffRole    ENUM('BookingStaff', 'CheckInStaff') NOT NULL DEFAULT 'BookingStaff',
  SalesOffice  VARCHAR(50)  NOT NULL,                                           -- e.g. 'Bangkok Silom Office'
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
  StaffID    INT         NOT NULL,
  StaffRole  ENUM('BookingStaff', 'CheckInStaff') NOT NULL DEFAULT 'CheckInStaff',
  CounterNo  VARCHAR(5)  NOT NULL,                                              -- check-in counter, e.g. 'A12'
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

-- ROUTE --------------------------------------------------------------
-- A flight number always flies the same route (decision C in
-- docs/DATABASE.md), so FlightNo -> OriginCode, DestinationCode. Keeping
-- those columns in FLIGHT would repeat the route on every dated flight
-- (a transitive dependency, so not 3NF). The route lives here once.
CREATE TABLE ROUTE (
  FlightNo         VARCHAR(6)  NOT NULL,          -- schedule number, e.g. 'MW101'
  OriginCode       CHAR(3)     NOT NULL,          -- BR1
  DestinationCode  CHAR(3)     NOT NULL,          -- BR2
  CONSTRAINT ROUTE_PK PRIMARY KEY (FlightNo),
  CONSTRAINT ROUTE_Airports_CK CHECK (OriginCode <> DestinationCode),           -- BR7
  -- The two airport FKs use RESTRICT on update as well: MySQL does not
  -- allow CASCADE on columns used in a CHECK constraint (ROUTE_Airports_CK).
  CONSTRAINT ROUTE_ORIGIN_FK FOREIGN KEY (OriginCode)
    REFERENCES AIRPORT (AirportCode)
    ON DELETE RESTRICT ON UPDATE RESTRICT,        -- an airport with routes cannot disappear
  CONSTRAINT ROUTE_DESTINATION_FK FOREIGN KEY (DestinationCode)
    REFERENCES AIRPORT (AirportCode)
    ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- FLIGHT -------------------------------------------------------------
-- One dated departure of a route, e.g. MW101 on 20 Oct 2026.
CREATE TABLE FLIGHT (
  FlightID         INT         NOT NULL AUTO_INCREMENT,
  FlightNo         VARCHAR(6)  NOT NULL,          -- the route flown (the same number flies every day)
  AircraftID       INT         NOT NULL,          -- BR3
  DepartureTime    DATETIME    NOT NULL,
  ArrivalTime      DATETIME    NOT NULL,
  Status           ENUM('OnTime', 'Delayed', 'Canceled') NOT NULL DEFAULT 'OnTime',
  Gate             VARCHAR(5),                    -- one gate per departure (decision E); NULL until assigned
  CONSTRAINT FLIGHT_PK PRIMARY KEY (FlightID),
  CONSTRAINT FLIGHT_No_Departure_UQ UNIQUE (FlightNo, DepartureTime),
  CONSTRAINT FLIGHT_Times_CK CHECK (ArrivalTime > DepartureTime),
  CONSTRAINT FLIGHT_ROUTE_FK FOREIGN KEY (FlightNo)
    REFERENCES ROUTE (FlightNo)
    ON DELETE RESTRICT ON UPDATE CASCADE,         -- cannot delete a route that has flights
  CONSTRAINT FLIGHT_AIRCRAFT_FK FOREIGN KEY (AircraftID)
    REFERENCES AIRCRAFT (AircraftID)
    ON DELETE RESTRICT ON UPDATE CASCADE          -- cannot delete an aircraft that has flights
);

-- FARE ---------------------------------------------------------------
CREATE TABLE FARE (
  FareID    INT            NOT NULL AUTO_INCREMENT,
  FlightID  INT            NOT NULL,                                            -- BR15
  Class     ENUM('Economy', 'Business', 'FirstClass') NOT NULL,
  Price     DECIMAL(10,2)  NOT NULL,
  -- The fare's conditions (refundable, changeable, ...) are in FARE_RULE below:
  -- one fare can have several, so a single Rule column would not be atomic (1NF).
  CONSTRAINT FARE_PK PRIMARY KEY (FareID),
  CONSTRAINT FARE_ID_Flight_UQ UNIQUE (FareID, FlightID),                       -- target of TICKET_FARE_FK (BR15)
  CONSTRAINT FARE_Price_CK CHECK (Price > 0),
  CONSTRAINT FARE_FLIGHT_FK FOREIGN KEY (FlightID)
    REFERENCES FLIGHT (FlightID)
    ON DELETE CASCADE ON UPDATE CASCADE           -- a fare means nothing without its flight
);

-- FARE_CONDITION -----------------------------------------------------
-- The list of conditions a fare can carry, e.g. 'Refundable', 'Changeable'.
CREATE TABLE FARE_CONDITION (
  ConditionID    INT           NOT NULL AUTO_INCREMENT,
  ConditionName  VARCHAR(40)   NOT NULL,
  Description    VARCHAR(200),
  CONSTRAINT FARE_CONDITION_PK PRIMARY KEY (ConditionID),
  CONSTRAINT FARE_CONDITION_Name_UQ UNIQUE (ConditionName)
);

-- FARE_RULE (bridge: FARE M:N FARE_CONDITION, BR19) -------------------
-- One fare can have many conditions, and one condition applies to many fares.
-- Fee is the extra attribute of the relationship: the price of using that
-- condition on that fare (e.g. a 500 THB change fee on an Economy fare).
CREATE TABLE FARE_RULE (
  FareID       INT            NOT NULL,
  ConditionID  INT            NOT NULL,
  Fee          DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  CONSTRAINT FARE_RULE_PK PRIMARY KEY (FareID, ConditionID),                    -- composite key, like ORDER_LINE in Lecture 8
  CONSTRAINT FARE_RULE_Fee_CK CHECK (Fee >= 0),
  CONSTRAINT FARE_RULE_FARE_FK FOREIGN KEY (FareID)
    REFERENCES FARE (FareID)
    ON DELETE CASCADE ON UPDATE CASCADE,          -- the rules go with their fare
  CONSTRAINT FARE_RULE_CONDITION_FK FOREIGN KEY (ConditionID)
    REFERENCES FARE_CONDITION (ConditionID)
    ON DELETE RESTRICT ON UPDATE CASCADE          -- cannot delete a condition that fares still use
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
  PassengerID      INT   NOT NULL,                -- BR18: the traveller on this ticket (RESERVATION.PassengerID is the booker)
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
  CONSTRAINT TICKET_Passenger_On_Flight_UQ UNIQUE (FlightID, PassengerID, ActiveSeat), -- BR18: one live seat per traveller per flight
  CONSTRAINT TICKET_RESERVATION_FK FOREIGN KEY (ReservationID)
    REFERENCES RESERVATION (ReservationID)
    ON DELETE CASCADE ON UPDATE CASCADE,          -- deleting a reservation deletes its tickets
  CONSTRAINT TICKET_PASSENGER_FK FOREIGN KEY (PassengerID)
    REFERENCES PASSENGER (PassengerID)
    ON DELETE RESTRICT ON UPDATE CASCADE,         -- cannot delete a passenger who has tickets
  -- FlightID reaches TICKET twice: directly, and through FARE (TICKET_FARE_FK).
  -- With CASCADE on both, renumbering a flight that sold tickets failed with a
  -- misleading error 1452, so both are RESTRICT on update: a flight or fare
  -- that sold tickets keeps its ID (it is AUTO_INCREMENT, never edited anyway).
  CONSTRAINT TICKET_FLIGHT_FK FOREIGN KEY (FlightID)
    REFERENCES FLIGHT (FlightID)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT TICKET_SEAT_FK FOREIGN KEY (SeatID)
    REFERENCES SEAT (SeatID)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  -- BR15: the fare must belong to the ticket's flight. Pointing at
  -- (FareID, FlightID) instead of FareID alone makes MySQL reject a fare from
  -- another flight (same trick as the staff subtypes, BR14).
  CONSTRAINT TICKET_FARE_FK FOREIGN KEY (FareID, FlightID)
    REFERENCES FARE (FareID, FlightID)
    ON DELETE RESTRICT ON UPDATE RESTRICT
  -- The seat must be on the flight's aircraft, and in the fare's class: see
  -- the triggers below. Enforced in the backend instead: BR8 (issue only
  -- after payment), BR13 (check-in rules).
);

-- TICKET triggers: seat and fare must fit the flight ----------------------
-- A CHECK can only see one row, and these rules compare TICKET with SEAT,
-- FLIGHT and FARE, so a trigger checks them before every insert and update:
--   - the seat must be on the aircraft that flies this flight
--   - the seat class must match the fare class (no Business seat on an
--     Economy fare)
-- A broken rule stops the statement with error 1644 (SQLSTATE 45000).
-- DELIMITER lets the procedure body contain ';' (mysql CLI, Workbench and
-- DBeaver all understand it).
DELIMITER $$

CREATE PROCEDURE ticket_check_seat_and_fare(IN p_flight INT, IN p_seat INT, IN p_fare INT)
BEGIN
  DECLARE seat_aircraft   INT;
  DECLARE seat_class      VARCHAR(20);
  DECLARE flight_aircraft INT;
  DECLARE fare_class      VARCHAR(20);

  -- A missing row leaves the variable NULL; the FKs then report that error
  SELECT AircraftID, SeatClass INTO seat_aircraft, seat_class FROM SEAT WHERE SeatID = p_seat;
  SELECT AircraftID INTO flight_aircraft FROM FLIGHT WHERE FlightID = p_flight;
  SELECT Class INTO fare_class FROM FARE WHERE FareID = p_fare;

  IF seat_aircraft <> flight_aircraft THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This seat is not on the aircraft that flies this flight';
  END IF;
  IF seat_class <> fare_class THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The seat class does not match the fare class';
  END IF;
END$$

CREATE TRIGGER TICKET_Seat_Fare_BI BEFORE INSERT ON TICKET
FOR EACH ROW
BEGIN
  CALL ticket_check_seat_and_fare(NEW.FlightID, NEW.SeatID, NEW.FareID);
END$$

CREATE TRIGGER TICKET_Seat_Fare_BU BEFORE UPDATE ON TICKET
FOR EACH ROW
BEGIN
  CALL ticket_check_seat_and_fare(NEW.FlightID, NEW.SeatID, NEW.FareID);
END$$

DELIMITER ;

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
