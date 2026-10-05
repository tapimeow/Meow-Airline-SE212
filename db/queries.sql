-- db/queries.sql
--
-- Report section 7: "SQL source code for queries" (Lecture 8).
-- Owners: Kawintida writes Q1–Q9, Kornnaphat writes Q10–Q18.
--         Patarawadee checks that each one matches schema.sql.
-- Phase 5a · Fri 9 – Sun 11 Oct (docs/PHASES.md).
--
-- NOTHING IS IMPLEMENTED YET. For each query:
--   1. write the SQL under its comment
--   2. run it against seed.sql in Workbench / DBeaver
--   3. screenshot the result for the report
-- The INSERTs for every table live in db/seed.sql (Patarawadee).
--
-- Lecture checklist, which every category below must cover:
--   L8.2  WHERE · AND/OR with parentheses · BETWEEN · IN · LIKE · IS NULL
--         ORDER BY · LIMIT · aggregates · GROUP BY · HAVING
--         UPDATE / DELETE that show the constraints working
--   L9    INNER JOIN on 3–4 tables via the TICKET bridge · LEFT JOIN + IS NULL
--   L10   VIEW · LIKE wildcards · CHECK in action

USE meow_airline;

-- =====================================================================
-- A. The 3 business questions (Lab 6 B2.4). These are the report pages.
-- =====================================================================
-- Q1  [Kawintida]  Free seats on one flight (e.g. MW101 on 20 Oct), by class.
--                  JOIN FLIGHT–SEAT + LEFT JOIN TICKET ... IS NULL, GROUP BY SeatClass   (O4, BR10)
-- Q2  [Kawintida]  All reservations of one passenger, and which are unpaid.
--                  LEFT JOIN PAYMENT, IS NULL / SUM(TotalAmount)                           (report Q2)
-- Q3  [Kawintida]  Income per route last month, and the route with the fewest seats sold.
--                  4-table JOIN, GROUP BY Origin/Destination, ORDER BY ... LIMIT 1         (O3)
--                  Depends on open question 3/4 in docs/DATABASE.md.

-- =====================================================================
-- B. Single-table queries (Lecture 8.2)
-- =====================================================================
-- Q4  [Kawintida]  Flights departing BETWEEN two dates, ORDER BY DepartureTime.
-- Q5  [Kawintida]  Passengers whose Email LIKE '%@example.com' or Name LIKE 'S%'.
-- Q6  [Kawintida]  Count passengers per MembershipStatus. GROUP BY + HAVING COUNT(*) > 1.

-- =====================================================================
-- C. Joins (Lecture 9)
-- =====================================================================
-- Q7  [Kawintida]  Boarding list for a flight: passenger name, seat, class
--                  (PASSENGER–RESERVATION–TICKET–SEAT, 4 tables).
-- Q8  [Kawintida]  Double-booking check: same FlightID + SeatID on 2 live tickets.
--                  GROUP BY ... HAVING COUNT(*) > 1, must return 0 rows   (O1, BR10)
-- Q9  [Kawintida]  Reservations created per booking staff member (JOIN STAFF / BOOKINGSTAFF).
-- Q10 [Kornnaphat] Tickets on a flight that are NOT checked in yet.
--                  LEFT JOIN CHECKIN ... IS NULL   (BR13)
-- Q11 [Kornnaphat] Total baggage weight per ticket vs. its class limit. SUM + HAVING   (BR12)
-- Q12 [Kornnaphat] Aircraft with no flights scheduled (LEFT JOIN ... IS NULL).
-- Q13 [Kornnaphat] Gold/Silver members (IN) and how much they paid this year.

-- =====================================================================
-- D. View (Lecture 10)
-- =====================================================================
-- Q14 [Kornnaphat] CREATE VIEW v_flight_load: each flight with seats total / sold / free.
--                  Q1 and the report page can then SELECT from it.

-- =====================================================================
-- E. UPDATE / DELETE that show the constraints working (Lecture 8.2)
--    For each one: run the SELECT first, then the change, then the SELECT again.
-- =====================================================================
-- Q15 [Kornnaphat] UPDATE a flight's Status to 'Delayed' (succeeds, uses the PK in WHERE).
-- Q16 [Kornnaphat] DELETE a PASSENGER who has reservations: rejected by ON DELETE RESTRICT (error 1451).
-- Q17 [Kornnaphat] DELETE a RESERVATION: its TICKETs disappear via ON DELETE CASCADE.
-- Q18 [Kornnaphat] INSERT a FLIGHT with OriginCode = DestinationCode: rejected by CHECK (error 3819, BR7).
--
-- Each person may swap a query for a better one. Update this list if you do.
