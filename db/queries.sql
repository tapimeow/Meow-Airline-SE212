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
--   Kawintida  : Q1–Q9 (incl. Q8b), Q19
--   Kornnaphat : Q10–Q18, Q20
--
-- Lecture coverage:
--   L8.2  WHERE · AND/OR · BETWEEN · IN · LIKE · IS NULL · ORDER BY · LIMIT
--         aggregates · GROUP BY · HAVING · UPDATE/DELETE showing constraints
--   L9    INNER JOIN on 3–4 tables via the TICKET bridge · LEFT JOIN + IS NULL
--   L10   VIEW · LIKE wildcards · CHECK in action
--   also  WITH (Q3b) · a trigger refusing bad tickets (Q18e, Q18f)
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
-- Q2a: the bookings, with their flights (5-table join)
SELECT r.ReservationID, r.BookingDate, r.ReservationStatus,
       f.FlightNo, ro.OriginCode, ro.DestinationCode, f.DepartureTime,
       t.TicketStatus
FROM PASSENGER p
JOIN RESERVATION r  ON r.PassengerID   = p.PassengerID
JOIN TICKET      t  ON t.ReservationID = r.ReservationID
JOIN FLIGHT      f  ON f.FlightID      = t.FlightID
JOIN ROUTE       ro ON ro.FlightNo     = f.FlightNo
WHERE p.PassengerID = 1
ORDER BY f.DepartureTime;

-- Q2b: payment status of each booking (LEFT JOIN keeps unpaid bookings).
--      A refund is its own PAYMENT row, so it is subtracted (same as Q13).
SELECT r.ReservationID, r.ReservationStatus,
       COUNT(pay.PaymentID)            AS payments,
       COALESCE(SUM(CASE WHEN pay.Status = 'Paid' THEN pay.TotalAmount
                         ELSE -pay.TotalAmount END), 0) AS amount_paid,
       CASE WHEN COUNT(pay.PaymentID) = 0          THEN 'NOT PAID'
            WHEN SUM(pay.Status = 'Refunded') > 0  THEN 'Refunded'
            ELSE 'Paid' END                       AS payment_status
FROM RESERVATION r
LEFT JOIN PAYMENT pay
  ON pay.ReservationID = r.ReservationID
WHERE r.PassengerID = 1
GROUP BY r.ReservationID, r.ReservationStatus
ORDER BY r.ReservationID;

-- Q3 [Kawintida] How much money did each route earn last month, and which
--    route sold the fewest seats?                                    (O3)
--    Income = fare price of every live ticket on September flights.
--    LEFT JOIN so a route with zero tickets still appears (with 0).
-- Q3a: income per route, highest first
SELECT CONCAT(ro.OriginCode, ' -> ', ro.DestinationCode) AS route,
       COUNT(t.TicketID)        AS seats_sold,
       COALESCE(SUM(fa.Price), 0) AS income
FROM FLIGHT f
JOIN ROUTE ro
  ON ro.FlightNo = f.FlightNo
LEFT JOIN TICKET t
  ON t.FlightID = f.FlightID
 AND t.TicketStatus <> 'cancelled'
LEFT JOIN FARE fa
  ON fa.FareID = t.FareID
WHERE f.DepartureTime >= '2026-09-01'
  AND f.DepartureTime <  '2026-10-01'
GROUP BY ro.OriginCode, ro.DestinationCode
ORDER BY income DESC, route;

-- Q3b: the route(s) that sold the fewest seats last month.
--      Not ORDER BY ... LIMIT 1: if two routes tie for the fewest, LIMIT 1
--      would hide one. WITH names the per-route counts once, and the outer
--      query keeps every route equal to the minimum.
WITH route_sales AS (
  SELECT CONCAT(ro.OriginCode, ' -> ', ro.DestinationCode) AS route,
         COUNT(t.TicketID) AS seats_sold
  FROM FLIGHT f
  JOIN ROUTE ro
    ON ro.FlightNo = f.FlightNo
  LEFT JOIN TICKET t
    ON t.FlightID = f.FlightID
   AND t.TicketStatus <> 'cancelled'
  WHERE f.DepartureTime >= '2026-09-01'
    AND f.DepartureTime <  '2026-10-01'
  GROUP BY ro.OriginCode, ro.DestinationCode
)
SELECT route, seats_sold
FROM route_sales
WHERE seats_sold = (SELECT MIN(seats_sold) FROM route_sales)
ORDER BY route;

-- =====================================================================
-- B. Single-table queries (Lecture 8.2)
-- =====================================================================

-- Q4 [Kawintida] Flights departing in October 2026, earliest first (BETWEEN, ORDER BY)
--    The end is written to the second: '23:59' alone would mean 23:59:00 and
--    miss a flight at 23:59:30. (DATETIME here has no fractions of a second.)
--    The route comes from ROUTE, joined on the flight number.
SELECT f.FlightNo, ro.OriginCode, ro.DestinationCode, f.DepartureTime, f.Status
FROM FLIGHT f
JOIN ROUTE ro ON ro.FlightNo = f.FlightNo
WHERE f.DepartureTime BETWEEN '2026-10-01 00:00:00' AND '2026-10-31 23:59:59'
ORDER BY f.DepartureTime;

-- Q5 [Kawintida] LIKE and IS NULL
-- Q5a: everyone in the Saetang family
SELECT PassengerID, Name, PassportNo
FROM PASSENGER
WHERE Name LIKE '%Saetang';

-- Q5b: passengers we cannot contact by email
SELECT PassengerID, Name, PhoneNo
FROM PASSENGER
WHERE Email IS NULL;

-- Q6 [Kawintida] Passengers per membership level, only levels with 3 or more (GROUP BY + HAVING)
--    With the sample data Normal (4) is kept and Gold (2) and Silver (2) are
--    dropped, so the screenshot shows HAVING removing groups.
SELECT MembershipStatus, COUNT(*) AS passengers
FROM PASSENGER
GROUP BY MembershipStatus
HAVING COUNT(*) >= 3
ORDER BY passengers DESC;

-- =====================================================================
-- C. Joins (Lecture 9)
-- =====================================================================

-- Q7 [Kawintida] Boarding list for MW101 on 20 Oct: who sits where, and who
--    booked it. PASSENGER is joined twice with two aliases (like the self-join
--    in Lecture 9): tr = the traveller on the ticket, bk = the booker.
SELECT f.FlightNo, s.SeatNo, s.SeatClass,
       tr.Name AS traveller, tr.PassportNo,
       bk.Name AS booked_by, t.TicketStatus
FROM FLIGHT f
JOIN TICKET      t  ON t.FlightID      = f.FlightID
JOIN SEAT        s  ON s.SeatID        = t.SeatID
JOIN PASSENGER   tr ON tr.PassengerID  = t.PassengerID
JOIN RESERVATION r  ON r.ReservationID = t.ReservationID
JOIN PASSENGER   bk ON bk.PassengerID  = r.PassengerID
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

-- Q8b [Kawintida] BR14 check: every staff member must be in exactly one
--     subtype table. The schema already stops two (composite FK + CHECK);
--     this finds a STAFF row with no subtype row. MUST return 0 rows.
SELECT s.StaffID, s.StaffName, s.StaffRole
FROM STAFF s
LEFT JOIN BOOKINGSTAFF b ON b.StaffID = s.StaffID
LEFT JOIN CHECKINSTAFF c ON c.StaffID = s.StaffID
WHERE b.StaffID IS NULL
  AND c.StaffID IS NULL;

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
SELECT t.TicketID, p.Name AS traveller, s.SeatNo, t.TicketStatus
FROM TICKET t
JOIN FLIGHT    f ON f.FlightID    = t.FlightID
JOIN SEAT      s ON s.SeatID      = t.SeatID
JOIN PASSENGER p ON p.PassengerID = t.PassengerID
LEFT JOIN CHECKIN c ON c.TicketID = t.TicketID
WHERE f.FlightNo = 'MW101'
  AND DATE(f.DepartureTime) = '2026-10-20'
  AND t.TicketStatus = 'issued'
  AND c.CheckInID IS NULL
ORDER BY s.SeatNo;

-- Q11 [Kornnaphat] Total baggage weight per ticket vs. its class limit (BR12)
--     Limits: Economy 20 kg, Business 30 kg, FirstClass 40 kg
--     (agreed by the team, docs/DATABASE.md open question 6)
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
       ro.OriginCode, ro.DestinationCode, s.SeatClass,
       COUNT(*)                     AS total_seats,
       COUNT(t.TicketID)            AS sold,
       COUNT(*) - COUNT(t.TicketID) AS free
FROM FLIGHT f
JOIN ROUTE ro
  ON ro.FlightNo = f.FlightNo
JOIN SEAT s
  ON s.AircraftID = f.AircraftID
LEFT JOIN TICKET t
  ON t.FlightID = f.FlightID
 AND t.SeatID   = s.SeatID
 AND t.TicketStatus <> 'cancelled'
GROUP BY f.FlightID, f.FlightNo, f.DepartureTime, ro.OriginCode, ro.DestinationCode, s.SeatClass;

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
-- Q18a: a route from BKK to BKK. Expected: Error Code 3819, check constraint
--       'ROUTE_Airports_CK' is violated (BR7)
-- INSERT INTO ROUTE (FlightNo, OriginCode, DestinationCode)
-- VALUES ('MW999', 'BKK', 'BKK');
--
-- Q18b: sell seat 2A on MW101 (20 Oct) again, although ticket 6 already has it.
--       Expected: Error Code 1062, duplicate entry for key
--       'TICKET_Seat_On_Flight_UQ': the database itself prevents double booking (O1, BR10)
-- INSERT INTO TICKET (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketStatus)
-- VALUES (8, 1, 6, 5, 11, 'booked');
--
-- Q18c: give Ladda a second seat (2D) on the same flight she already has a ticket for.
--       Expected: Error Code 1062, duplicate entry for key
--       'TICKET_Passenger_On_Flight_UQ' (BR18)
-- INSERT INTO TICKET (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketStatus)
-- VALUES (5, 4, 6, 8, 11, 'booked');
--
-- Q18d: delete the 'Refundable' condition while Business fares still use it.
--       Expected: Error Code 1451, foreign key 'FARE_RULE_CONDITION_FK' (RESTRICT)
-- DELETE FROM FARE_CONDITION WHERE ConditionName = 'Refundable';
--
-- Q18e: sell seat 2A of aircraft 3 (SeatID 29) on MW101 20 Oct, which
--       aircraft 1 flies. Expected: Error Code 1644, 'This seat is not on
--       the aircraft that flies this flight' (trigger TICKET_Seat_Fare_BI)
-- INSERT INTO TICKET (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketStatus)
-- VALUES (8, 1, 6, 29, 11, 'booked');
--
-- Q18f: sell Business seat 1A (SeatID 1) on the Economy fare 11.
--       Expected: Error Code 1644, 'The seat class does not match the fare
--       class' (trigger TICKET_Seat_Fare_BI)
-- INSERT INTO TICKET (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketStatus)
-- VALUES (8, 1, 6, 1, 11, 'booked');

-- =====================================================================
-- F. The second M:N: FARE ⇄ FARE_CONDITION through the FARE_RULE bridge
-- =====================================================================

-- Q19 [Kawintida] What does each fare on MW101 (20 Oct) include, and what
--     does each condition cost? (3 tables through the bridge, like
--     orders -> order_details -> items in Lecture 9)
SELECT fa.Class, fa.Price, fc.ConditionName, fr.Fee
FROM FLIGHT f
JOIN FARE           fa ON fa.FlightID    = f.FlightID
JOIN FARE_RULE      fr ON fr.FareID      = fa.FareID
JOIN FARE_CONDITION fc ON fc.ConditionID = fr.ConditionID
WHERE f.FlightNo = 'MW101'
  AND DATE(f.DepartureTime) = '2026-10-20'
ORDER BY fa.Price, fc.ConditionName;

-- Q20 [Kornnaphat] Upcoming fares that are NOT refundable: a passenger
--     buying one gets no money back on cancel. (LEFT JOIN + IS NULL, with the
--     condition name inside ON so every fare is kept)
SELECT f.FlightNo, f.DepartureTime, fa.Class, fa.Price
FROM FARE fa
JOIN FLIGHT f ON f.FlightID = fa.FlightID
LEFT JOIN (FARE_RULE fr
           JOIN FARE_CONDITION fc
             ON fc.ConditionID = fr.ConditionID
            AND fc.ConditionName = 'Refundable')
  ON fr.FareID = fa.FareID
WHERE f.DepartureTime >= '2026-10-01'
  AND fr.FareID IS NULL
ORDER BY f.DepartureTime, fa.Class;
