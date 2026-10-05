-- db/queries.sql
--
-- Report section 7: "SQL source code for queries" (Lecture 8).
-- Run after schema.sql + seed.sql. The whole file runs top to bottom without
-- errors. The statements that are SUPPOSED to fail (to show a constraint
-- working) are commented out. Run each of those on its own and screenshot
-- the error.
--
-- Owners (Phase 5a): each person checks their queries against the data,
-- takes the result screenshots for the report, and explains them in the
-- presentation.
--   Kawintida  : Q1–Q9
--   Kornnaphat : Q10–Q18
--
-- Lecture coverage:
--   L8.2  WHERE · AND/OR · BETWEEN · IN · LIKE · IS NULL · ORDER BY · LIMIT
--         aggregates · GROUP BY · HAVING · UPDATE/DELETE showing constraints
--   L9    INNER JOIN on 3–4 tables via the TICKET bridge · LEFT JOIN + IS NULL
--   L10   VIEW · LIKE wildcards · CHECK in action
--
-- Dates are written as literals so the results match the sample data. In the
-- app, the controller passes them as ? parameters instead.

USE meow_airline;

-- =====================================================================
-- A. The 3 business questions (Lab 6 B2.4). These are the 3 report pages.
-- =====================================================================

-- Q1 [Kawintida] How many seats are still free on flight MW101 on
--    20 October, and in which class?                         (O4, BR10)
--    Every seat of the flight's aircraft, LEFT JOINed to a live ticket for
--    that seat on that flight. No ticket means the seat is free.
SELECT s.SeatClass,
       COUNT(*)                     AS total_seats,
       COUNT(t.TicketID)            AS sold,
       COUNT(*) - COUNT(t.TicketID) AS free
FROM FLIGHT f
JOIN SEAT s
  ON s.AircraftID = f.AircraftID
LEFT JOIN TICKET t
  ON t.FlightID = f.FlightID
 AND t.SeatID   = s.SeatID
 AND t.TicketStatus <> 'cancelled'
WHERE f.FlightNo = 'MW101'
  AND DATE(f.DepartureTime) = '2026-10-20'
GROUP BY s.SeatClass
ORDER BY s.SeatClass;

-- Q2 [Kawintida] Which bookings has this passenger made, and which of them
--    are not paid yet?                                     (passenger 1)
-- Q2a: the bookings, with their flights (4-table join)
SELECT r.ReservationID, r.BookingDate, r.ReservationStatus,
       f.FlightNo, f.OriginCode, f.DestinationCode, f.DepartureTime,
       t.TicketStatus
FROM PASSENGER p
JOIN RESERVATION r ON r.PassengerID   = p.PassengerID
JOIN TICKET      t ON t.ReservationID = r.ReservationID
JOIN FLIGHT      f ON f.FlightID      = t.FlightID
WHERE p.PassengerID = 1
ORDER BY f.DepartureTime;

-- Q2b: payment status of each booking (LEFT JOIN keeps unpaid bookings)
SELECT r.ReservationID, r.ReservationStatus,
       COUNT(pay.PaymentID)            AS payments,
       COALESCE(SUM(pay.TotalAmount), 0) AS amount_paid,
       CASE WHEN COUNT(pay.PaymentID) = 0 THEN 'NOT PAID' ELSE 'Paid' END AS payment_status
FROM RESERVATION r
LEFT JOIN PAYMENT pay
  ON pay.ReservationID = r.ReservationID
 AND pay.Status = 'Paid'
WHERE r.PassengerID = 1
GROUP BY r.ReservationID, r.ReservationStatus
ORDER BY r.ReservationID;

-- Q3 [Kawintida] How much money did each route earn last month, and which
--    route sold the fewest seats?                                    (O3)
--    Income = fare price of every live ticket on September flights.
--    LEFT JOIN so a route with zero tickets still appears (with 0).
-- Q3a: income per route, highest first
SELECT CONCAT(f.OriginCode, ' -> ', f.DestinationCode) AS route,
       COUNT(t.TicketID)        AS seats_sold,
       COALESCE(SUM(fa.Price), 0) AS income
FROM FLIGHT f
LEFT JOIN TICKET t
  ON t.FlightID = f.FlightID
 AND t.TicketStatus <> 'cancelled'
LEFT JOIN FARE fa
  ON fa.FareID = t.FareID
WHERE f.DepartureTime >= '2026-09-01'
  AND f.DepartureTime <  '2026-10-01'
GROUP BY f.OriginCode, f.DestinationCode
ORDER BY income DESC;

-- Q3b: the route that sold the fewest seats last month
SELECT CONCAT(f.OriginCode, ' -> ', f.DestinationCode) AS route,
       COUNT(t.TicketID) AS seats_sold
FROM FLIGHT f
LEFT JOIN TICKET t
  ON t.FlightID = f.FlightID
 AND t.TicketStatus <> 'cancelled'
WHERE f.DepartureTime >= '2026-09-01'
  AND f.DepartureTime <  '2026-10-01'
GROUP BY f.OriginCode, f.DestinationCode
ORDER BY seats_sold ASC, route
LIMIT 1;

-- =====================================================================
-- B. Single-table queries (Lecture 8.2)
-- =====================================================================

-- Q4 [Kawintida] Flights departing in October 2026, earliest first (BETWEEN, ORDER BY)
SELECT FlightNo, OriginCode, DestinationCode, DepartureTime, Status
FROM FLIGHT
WHERE DepartureTime BETWEEN '2026-10-01 00:00' AND '2026-10-31 23:59'
ORDER BY DepartureTime;

-- Q5 [Kawintida] LIKE and IS NULL
-- Q5a: everyone in the Saetang family
SELECT PassengerID, Name, PassportNo
FROM PASSENGER
WHERE Name LIKE '%Saetang';

-- Q5b: passengers we cannot contact by email
SELECT PassengerID, Name, PhoneNo
FROM PASSENGER
WHERE Email IS NULL;

-- Q6 [Kawintida] Passengers per membership level, only levels with 2 or more (GROUP BY + HAVING)
SELECT MembershipStatus, COUNT(*) AS passengers
FROM PASSENGER
GROUP BY MembershipStatus
HAVING COUNT(*) >= 2
ORDER BY passengers DESC;

-- =====================================================================
-- C. Joins (Lecture 9)
-- =====================================================================

-- Q7 [Kawintida] Boarding list for MW101 on 20 Oct: who sits where (4 tables)
--    NOTE: TICKET has no traveller column yet, so all 3 family tickets show
--    the booker's name. See docs/DATABASE.md, open question 7.
SELECT f.FlightNo, s.SeatNo, s.SeatClass, p.Name AS booked_by, t.TicketStatus
FROM FLIGHT f
JOIN TICKET      t ON t.FlightID      = f.FlightID
JOIN SEAT        s ON s.SeatID        = t.SeatID
JOIN RESERVATION r ON r.ReservationID = t.ReservationID
JOIN PASSENGER   p ON p.PassengerID   = r.PassengerID
WHERE f.FlightNo = 'MW101'
  AND DATE(f.DepartureTime) = '2026-10-20'
  AND t.TicketStatus <> 'cancelled'
ORDER BY s.SeatNo;

-- Q8 [Kawintida] Double-booking check: the same seat on 2+ live tickets for
--    one flight. MUST return 0 rows (O1, BR10).
SELECT t.FlightID, t.SeatID, COUNT(*) AS live_tickets
FROM TICKET t
WHERE t.TicketStatus <> 'cancelled'
GROUP BY t.FlightID, t.SeatID
HAVING COUNT(*) > 1;

-- Q9 [Kawintida] Reservations created by each booking staff member
--    (LEFT JOIN keeps a staff member with 0 bookings)
SELECT s.StaffID, s.StaffName, COUNT(r.ReservationID) AS reservations_created
FROM STAFF s
JOIN BOOKINGSTAFF b      ON b.StaffID = s.StaffID
LEFT JOIN RESERVATION r  ON r.BookingStaffID = b.StaffID
GROUP BY s.StaffID, s.StaffName
ORDER BY reservations_created DESC;

-- Q10 [Kornnaphat] Issued tickets on MW101 (20 Oct) that are NOT checked in yet
--     (LEFT JOIN + IS NULL, BR13)
SELECT t.TicketID, s.SeatNo, t.TicketStatus
FROM TICKET t
JOIN FLIGHT f ON f.FlightID = t.FlightID
JOIN SEAT   s ON s.SeatID   = t.SeatID
LEFT JOIN CHECKIN c ON c.TicketID = t.TicketID
WHERE f.FlightNo = 'MW101'
  AND DATE(f.DepartureTime) = '2026-10-20'
  AND t.TicketStatus = 'issued'
  AND c.CheckInID IS NULL
ORDER BY s.SeatNo;

-- Q11 [Kornnaphat] Total baggage weight per ticket vs. its class limit (BR12)
--     Limits: Economy 20 kg, Business 30 kg, FirstClass 40 kg
--     (Business/FirstClass limits are assumptions. See docs/DATABASE.md, open question 6.)
SELECT t.TicketID, s.SeatClass,
       COUNT(b.BaggageID) AS bags,
       SUM(b.Weight)      AS total_kg,
       CASE s.SeatClass WHEN 'Economy' THEN 20 WHEN 'Business' THEN 30 ELSE 40 END AS limit_kg,
       CASE s.SeatClass WHEN 'Economy' THEN 20 WHEN 'Business' THEN 30 ELSE 40 END
         - SUM(b.Weight)  AS remaining_kg
FROM TICKET t
JOIN SEAT    s ON s.SeatID   = t.SeatID
JOIN BAGGAGE b ON b.TicketID = t.TicketID
GROUP BY t.TicketID, s.SeatClass
ORDER BY remaining_kg;

-- Q12 [Kornnaphat] Aircraft with no flights at all (LEFT JOIN + IS NULL)
SELECT a.AircraftID, a.AircraftModel
FROM AIRCRAFT a
LEFT JOIN FLIGHT f ON f.AircraftID = a.AircraftID
WHERE f.FlightID IS NULL;

-- Q13 [Kornnaphat] Gold and Silver members, and how much they paid in 2026
--     (IN, refunds subtracted)
SELECT p.Name, p.MembershipStatus,
       SUM(CASE WHEN pay.Status = 'Paid' THEN pay.TotalAmount ELSE -pay.TotalAmount END) AS net_paid
FROM PASSENGER p
JOIN RESERVATION r ON r.PassengerID   = p.PassengerID
JOIN PAYMENT   pay ON pay.ReservationID = r.ReservationID
WHERE p.MembershipStatus IN ('Gold', 'Silver')
  AND YEAR(pay.TimeStamp) = 2026
GROUP BY p.PassengerID, p.Name, p.MembershipStatus
ORDER BY net_paid DESC;

-- =====================================================================
-- D. View (Lecture 10)
-- =====================================================================

-- Q14 [Kornnaphat] v_flight_load: seats total / sold / free for every flight
--     and class. The free-seats report page can read from this view.
CREATE OR REPLACE VIEW v_flight_load AS
SELECT f.FlightID, f.FlightNo, f.DepartureTime,
       f.OriginCode, f.DestinationCode, s.SeatClass,
       COUNT(*)                     AS total_seats,
       COUNT(t.TicketID)            AS sold,
       COUNT(*) - COUNT(t.TicketID) AS free
FROM FLIGHT f
JOIN SEAT s
  ON s.AircraftID = f.AircraftID
LEFT JOIN TICKET t
  ON t.FlightID = f.FlightID
 AND t.SeatID   = s.SeatID
 AND t.TicketStatus <> 'cancelled'
GROUP BY f.FlightID, f.FlightNo, f.DepartureTime, f.OriginCode, f.DestinationCode, s.SeatClass;

-- Using the view: upcoming flights, Economy load
SELECT FlightNo, DepartureTime, OriginCode, DestinationCode, total_seats, sold, free
FROM v_flight_load
WHERE SeatClass = 'Economy'
  AND DepartureTime >= '2026-10-01'
ORDER BY DepartureTime;

-- =====================================================================
-- E. UPDATE / DELETE that show the constraints working (Lecture 8.2)
--    Safe habit from the lecture: SELECT first, change, SELECT again,
--    all inside START TRANSACTION ... ROLLBACK so the sample data stays
--    the same for everyone.
-- =====================================================================

-- Q15 [Kornnaphat] UPDATE: MW301 on 25 Oct is delayed (PK in WHERE)
START TRANSACTION;
SELECT FlightID, FlightNo, DepartureTime, Status FROM FLIGHT WHERE FlightID = 10;
UPDATE FLIGHT SET Status = 'Delayed' WHERE FlightID = 10;
SELECT FlightID, FlightNo, DepartureTime, Status FROM FLIGHT WHERE FlightID = 10;
ROLLBACK;

-- Q16 [Kornnaphat] DELETE a passenger who has reservations: RESTRICT stops it.
--     Run this line on its own. Expected:
--     Error Code: 1451. Cannot delete or update a parent row: a foreign key
--     constraint fails (... RESERVATION_PASSENGER_FK ...)
-- DELETE FROM PASSENGER WHERE PassengerID = 1;

-- Q17 [Kornnaphat] DELETE a held, unpaid reservation: its tickets are removed
--     too, by ON DELETE CASCADE.
START TRANSACTION;
SELECT TicketID, ReservationID, FlightID FROM TICKET WHERE ReservationID = 6;   -- 1 row
DELETE FROM RESERVATION WHERE ReservationID = 6;
SELECT TicketID, ReservationID, FlightID FROM TICKET WHERE ReservationID = 6;   -- 0 rows
ROLLBACK;

-- Q18 [Kornnaphat] The database refuses rule-breaking data. Run each on its own.
-- Q18a: a flight from BKK to BKK. Expected: Error Code 3819, check constraint
--       'FLIGHT_Route_CK' is violated (BR7)
-- INSERT INTO FLIGHT (FlightNo, AircraftID, OriginCode, DestinationCode, DepartureTime, ArrivalTime)
-- VALUES ('MW999', 1, 'BKK', 'BKK', '2026-10-30 08:00', '2026-10-30 09:00');
--
-- Q18b: sell seat 2A on MW101 (20 Oct) again, although ticket 6 already has it.
--       Expected: Error Code 1062, duplicate entry for key
--       'TICKET_Seat_On_Flight_UQ': the database itself prevents double booking (O1, BR10)
-- INSERT INTO TICKET (ReservationID, FlightID, SeatID, FareID, TicketStatus)
-- VALUES (8, 6, 5, 11, 'booked');
