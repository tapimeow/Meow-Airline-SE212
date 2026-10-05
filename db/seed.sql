-- db/seed.sql
--
-- [Phase 3 · Database · Patarawadee] Sample data for every table (report
-- section 7: "INSERT sample data for every table"). Run it after schema.sql:
--
--   mysql -u root -p meow_airline < db/seed.sql
--
-- All people are fake (Lab 6 B4.3). Airport codes are real IATA codes.
-- "Today" in this data is early October 2026:
--   September flights have already flown (used for the "last month" report),
--   October flights are still to come (used for booking and check-in).
-- Seat maps are shortened to 12 seats per aircraft (row 1 Business, rows 2-3
-- Economy) to keep the data readable. BR11 still holds (12 <= TotalSeat).
--
-- Rows the queries in db/queries.sql rely on:
--   - flight MW101 on 20 Oct 2026 with a family of 3 on one reservation (Q1, demo)
--   - passenger 1 with one paid and one unpaid reservation (Q2)
--   - a September route that sold no seats, HKT -> USM (Q3)
--   - aircraft 6 with no flights (Q12)
--   - tickets on upcoming flights that are not checked in yet (Q10)
--   - reservation 6: held, unpaid, no payments (safe to delete in Q17)

USE meow_airline;

-- AIRPORT ------------------------------------------------------------
INSERT INTO AIRPORT (AirportCode, City, Country) VALUES
  ('BKK', 'Bangkok',    'Thailand'),
  ('CNX', 'Chiang Mai', 'Thailand'),
  ('HKT', 'Phuket',     'Thailand'),
  ('USM', 'Koh Samui',  'Thailand'),
  ('KBV', 'Krabi',      'Thailand'),
  ('SIN', 'Singapore',  'Singapore'),
  ('VTE', 'Vientiane',  'Laos');

-- AIRCRAFT: Meow Airline's six aircraft ------------------------------------
INSERT INTO AIRCRAFT (AircraftModel, TotalSeat) VALUES
  ('ATR 72-600',   70),   -- 1
  ('ATR 72-600',   70),   -- 2
  ('Airbus A320', 180),   -- 3
  ('Airbus A320', 180),   -- 4
  ('Embraer E190', 100),  -- 5
  ('Airbus A321', 220);   -- 6  (in maintenance: no flights, see Q12)

-- PASSENGER ----------------------------------------------------------
INSERT INTO PASSENGER (Name, PassportNo, PhoneNo, Email, MembershipStatus) VALUES
  ('Somsak Jaidee',      'AA1234567', '0812345678',  'somsak@example.com',     'Normal'),  -- 1
  ('Nara Chaisiri',      'AB7654321', '0898765432',  'nara@example.com',       'Gold'),    -- 2
  ('Wichai Saetang',     'AC2223334', '0861112222',  'wichai@example.com',     'Silver'),  -- 3 (family booker)
  ('Ladda Saetang',      'AC2223335', '0861112223',  'ladda@example.com',      'Normal'),  -- 4 (family)
  ('Siriporn Kaewmanee', 'AD5556667', '0823334444',  'siriporn@example.com',   'Silver'),  -- 5
  ('Tom Keomany',        'LA0098765', '+8562055501', 'tom.k@example.la',       'Normal'),  -- 6
  ('Mint Saetang',       'AC2223336', NULL,          NULL,                     'Normal'),  -- 7 (family, child: no phone/email)
  ('Daniel Tan',         'SG7788990', '+6591234567', 'daniel.tan@example.sg',  'Gold');    -- 8

-- STAFF + subtypes (BR14: each staff member is in exactly one subtype) --
INSERT INTO STAFF (StaffName, StaffRole) VALUES
  ('Ploy Srisuk',    'BookingStaff'),   -- 1
  ('Anan Wongsa',    'BookingStaff'),   -- 2
  ('Malee Thongdee', 'CheckInStaff'),   -- 3
  ('Chai Boonmee',   'CheckInStaff');   -- 4

INSERT INTO BOOKINGSTAFF (StaffID) VALUES (1), (2);
INSERT INTO CHECKINSTAFF (StaffID) VALUES (3), (4);

-- SEAT: SeatID = (AircraftID - 1) * 12 + position --------------------------
INSERT INTO SEAT (AircraftID, SeatNo, SeatClass) VALUES
  -- aircraft 1 (ATR 72-600): seats 1-12
  (1, '1A', 'Business'), (1, '1B', 'Business'), (1, '1C', 'Business'), (1, '1D', 'Business'),
  (1, '2A', 'Economy'), (1, '2B', 'Economy'), (1, '2C', 'Economy'), (1, '2D', 'Economy'), (1, '3A', 'Economy'), (1, '3B', 'Economy'), (1, '3C', 'Economy'), (1, '3D', 'Economy'),
  -- aircraft 2 (ATR 72-600): seats 13-24
  (2, '1A', 'Business'), (2, '1B', 'Business'), (2, '1C', 'Business'), (2, '1D', 'Business'),
  (2, '2A', 'Economy'), (2, '2B', 'Economy'), (2, '2C', 'Economy'), (2, '2D', 'Economy'), (2, '3A', 'Economy'), (2, '3B', 'Economy'), (2, '3C', 'Economy'), (2, '3D', 'Economy'),
  -- aircraft 3 (Airbus A320): seats 25-36
  (3, '1A', 'Business'), (3, '1B', 'Business'), (3, '1C', 'Business'), (3, '1D', 'Business'),
  (3, '2A', 'Economy'), (3, '2B', 'Economy'), (3, '2C', 'Economy'), (3, '2D', 'Economy'), (3, '3A', 'Economy'), (3, '3B', 'Economy'), (3, '3C', 'Economy'), (3, '3D', 'Economy'),
  -- aircraft 4 (Airbus A320): seats 37-48
  (4, '1A', 'Business'), (4, '1B', 'Business'), (4, '1C', 'Business'), (4, '1D', 'Business'),
  (4, '2A', 'Economy'), (4, '2B', 'Economy'), (4, '2C', 'Economy'), (4, '2D', 'Economy'), (4, '3A', 'Economy'), (4, '3B', 'Economy'), (4, '3C', 'Economy'), (4, '3D', 'Economy'),
  -- aircraft 5 (Embraer E190): seats 49-60
  (5, '1A', 'Business'), (5, '1B', 'Business'), (5, '1C', 'Business'), (5, '1D', 'Business'),
  (5, '2A', 'Economy'), (5, '2B', 'Economy'), (5, '2C', 'Economy'), (5, '2D', 'Economy'), (5, '3A', 'Economy'), (5, '3B', 'Economy'), (5, '3C', 'Economy'), (5, '3D', 'Economy'),
  -- aircraft 6 (Airbus A321): seats 61-72
  (6, '1A', 'Business'), (6, '1B', 'Business'), (6, '1C', 'Business'), (6, '1D', 'Business'),
  (6, '2A', 'Economy'), (6, '2B', 'Economy'), (6, '2C', 'Economy'), (6, '2D', 'Economy'), (6, '3A', 'Economy'), (6, '3B', 'Economy'), (6, '3C', 'Economy'), (6, '3D', 'Economy');

-- FLIGHT -------------------------------------------------------------
INSERT INTO FLIGHT (FlightNo, AircraftID, OriginCode, DestinationCode, DepartureTime, ArrivalTime, Status) VALUES
  -- September 2026 (already flown)
  ('MW101', 1, 'BKK', 'CNX', '2026-09-10 08:00', '2026-09-10 09:15', 'OnTime'),   -- 1
  ('MW102', 1, 'CNX', 'BKK', '2026-09-10 10:30', '2026-09-10 11:45', 'OnTime'),   -- 2
  ('MW201', 3, 'BKK', 'HKT', '2026-09-15 09:00', '2026-09-15 10:25', 'Delayed'),  -- 3
  ('MW301', 4, 'BKK', 'SIN', '2026-09-20 13:00', '2026-09-20 16:20', 'OnTime'),   -- 4
  ('MW401', 2, 'HKT', 'USM', '2026-09-25 15:00', '2026-09-25 16:00', 'OnTime'),   -- 5
  -- October 2026 (upcoming)
  ('MW101', 1, 'BKK', 'CNX', '2026-10-20 08:00', '2026-10-20 09:15', 'OnTime'),   -- 6  <- Q1 example
  ('MW102', 1, 'CNX', 'BKK', '2026-10-20 10:30', '2026-10-20 11:45', 'OnTime'),   -- 7
  ('MW201', 3, 'BKK', 'HKT', '2026-10-21 09:00', '2026-10-21 10:25', 'OnTime'),   -- 8
  ('MW501', 5, 'BKK', 'VTE', '2026-10-22 11:00', '2026-10-22 12:10', 'OnTime'),   -- 9
  ('MW301', 4, 'BKK', 'SIN', '2026-10-25 13:00', '2026-10-25 16:20', 'OnTime');   -- 10

-- FARE: FareID = 2 * FlightID - 1 (Economy) and 2 * FlightID (Business) -------
INSERT INTO FARE (FlightID, Class, Price, Rule) VALUES
  (1,  'Economy', 1500.00, 'Changeable'), (1,  'Business', 4500.00, 'Refundable'),  -- 1, 2
  (2,  'Economy', 1500.00, 'Changeable'), (2,  'Business', 4500.00, 'Refundable'),  -- 3, 4
  (3,  'Economy', 1800.00, 'Changeable'), (3,  'Business', 5200.00, 'Refundable'),  -- 5, 6
  (4,  'Economy', 3900.00, 'Changeable'), (4,  'Business', 9800.00, 'Refundable'),  -- 7, 8
  (5,  'Economy', 1200.00, 'Changeable'), (5,  'Business', 3500.00, 'Refundable'),  -- 9, 10
  (6,  'Economy', 1500.00, 'Changeable'), (6,  'Business', 4500.00, 'Refundable'),  -- 11, 12
  (7,  'Economy', 1500.00, 'Changeable'), (7,  'Business', 4500.00, 'Refundable'),  -- 13, 14
  (8,  'Economy', 1800.00, 'Changeable'), (8,  'Business', 5200.00, 'Refundable'),  -- 15, 16
  (9,  'Economy', 2500.00, 'Changeable'), (9,  'Business', 6500.00, 'Refundable'),  -- 17, 18
  (10, 'Economy', 3900.00, 'Changeable'), (10, 'Business', 9800.00, 'Refundable');  -- 19, 20

-- RESERVATION --------------------------------------------------------
INSERT INTO RESERVATION (PassengerID, BookingStaffID, BookingDate, ReservationStatus) VALUES
  (1, 1,    '2026-09-01', 'Confirmed'),   -- 1  Somsak: BKK->CNX->BKK return trip in September
  (2, 2,    '2026-09-05', 'Confirmed'),   -- 2  Nara: Business to Phuket
  (8, 1,    '2026-09-08', 'Confirmed'),   -- 3  Daniel: to Singapore
  (5, 2,    '2026-09-12', 'Cancelled'),   -- 4  Siriporn: cancelled and refunded
  (3, 1,    '2026-10-01', 'Confirmed'),   -- 5  Wichai: family of 3 on MW101, 20 Oct
  (6, 2,    '2026-10-03', 'Held'),        -- 6  Tom: held, NOT paid yet
  (2, NULL, '2026-10-04', 'Confirmed'),   -- 7  Nara: booked online (no staff), Business to Vientiane
  (1, 1,    '2026-10-04', 'Held');        -- 8  Somsak: held, NOT paid yet

-- TICKET (bridge) ----------------------------------------------------
-- Columns: reservation, flight, seat, fare, issue date, status
INSERT INTO TICKET (ReservationID, FlightID, SeatID, FareID, TicketIssueDate, TicketStatus) VALUES
  (1, 1,  5,  1,  '2026-09-01', 'used'),       -- 1  MW101 seat 2A Economy
  (1, 2,  6,  3,  '2026-09-01', 'used'),       -- 2  MW102 seat 2B Economy
  (2, 3,  25, 6,  '2026-09-05', 'used'),       -- 3  MW201 seat 1A Business
  (3, 4,  41, 7,  '2026-09-08', 'used'),       -- 4  MW301 seat 2A Economy
  (4, 5,  13, 10, '2026-09-12', 'cancelled'),  -- 5  MW401 seat 1A Business (cancelled)
  (5, 6,  5,  11, '2026-10-01', 'issued'),     -- 6  MW101 20 Oct seat 2A  (family)
  (5, 6,  6,  11, '2026-10-01', 'issued'),     -- 7  MW101 20 Oct seat 2B  (family)
  (5, 6,  7,  11, '2026-10-01', 'issued'),     -- 8  MW101 20 Oct seat 2C  (family)
  (6, 8,  29, 15, NULL,         'booked'),     -- 9  MW201 21 Oct seat 2A (not paid, so not issued: BR8)
  (7, 9,  49, 18, '2026-10-04', 'issued'),     -- 10 MW501 22 Oct seat 1A Business
  (8, 10, 42, 19, NULL,         'booked');     -- 11 MW301 25 Oct seat 2B (not paid, so not issued: BR8)

-- PAYMENT ------------------------------------------------------------
INSERT INTO PAYMENT (ReservationID, TotalAmount, PaymentMethod, TimeStamp, Status) VALUES
  (1, 3000.00, 'Card',         '2026-09-01 10:15', 'Paid'),
  (2, 5200.00, 'QR',           '2026-09-05 14:02', 'Paid'),
  (3, 3900.00, 'Card',         '2026-09-08 09:40', 'Paid'),
  (4, 3500.00, 'Cash',         '2026-09-12 11:20', 'Paid'),
  (4, 3500.00, 'Cash',         '2026-09-14 16:05', 'Refunded'),   -- Refundable fare, so money back
  (5, 4500.00, 'BankTransfer', '2026-10-01 13:30', 'Paid'),       -- 3 x 1,500
  (7, 6500.00, 'Card',         '2026-10-04 19:45', 'Paid');
  -- reservations 6 and 8 have no payment yet (Q2)

-- BAGGAGE (BR9: optional; BR12: Economy 20 kg, Business 30 kg per ticket) ---
INSERT INTO BAGGAGE (TicketID, Weight, BaggageStatus) VALUES
  (1, 15.00, 'Arrived'),
  (2, 12.00, 'Arrived'),
  (3, 22.00, 'Arrived'),
  (3,  6.50, 'Arrived'),
  (4, 19.50, 'Arrived');

-- CHECKIN (one per ticket; only September tickets so far) ---------------
INSERT INTO CHECKIN (TicketID, CheckInStaffID, CheckInTime, Gate, BoardingPassNo) VALUES
  (1, 3, '2026-09-10 06:45', 'A1', 'BP260910-001'),
  (2, 3, '2026-09-10 09:05', 'B2', 'BP260910-002'),
  (3, 4, '2026-09-15 07:30', 'A3', 'BP260915-001'),
  (4, 4, '2026-09-20 11:10', 'C1', 'BP260920-001');
