# Database design notes

**Owner:** Patarawadee (Phase 2 lead, Phase 3). All three members decide the open questions.
**Sources:** Lab 7 §3, Lab 6 B3, the ERDs in [`docs/erd/`](erd/), Lectures 7–10.

Only Patarawadee changes `db/schema.sql`. Anyone may suggest changes to this file through a PR.

![Architecture](architecture.png)

## Entities (12 + 2 subtype tables)

The staff FKs on RESERVATION and CHECKIN come from the EER's **Created** and **Processes** relationships.

| Table | PK | Main attributes | FKs |
|---|---|---|---|
| PASSENGER | PassengerID | Name, PassportNo, PhoneNo, Email, MembershipStatus (Normal/Silver/Gold) | — |
| AIRPORT | AirportCode | City, Country | — |
| AIRCRAFT | AircraftID | AircraftModel, TotalSeat | — |
| FLIGHT | FlightID | DepartureTime, ArrivalTime, Status (OnTime/Delayed/Canceled) | AircraftID, OriginCode, DestinationCode |
| SEAT | SeatID | SeatNo, SeatClass (Economy/Business/FirstClass) | AircraftID |
| FARE | FareID | Class, Price, Rule (Refundable/Changeable) | FlightID |
| RESERVATION | ReservationID | BookingDate, ReservationStatus (Held/Confirmed/Cancelled) | PassengerID, **BookingStaffID** |
| TICKET *(bridge)* | TicketID | TicketIssueDate, TicketStatus (issued/used/cancelled) | ReservationID, FlightID, SeatID |
| PAYMENT | PaymentID | TotalAmount, PaymentMethod, TimeStamp, Status (Paid/Refunded) | ReservationID |
| BAGGAGE | BaggageID | Weight, BaggageStatus | TicketID |
| CHECKIN | CheckInID | CheckInTime, Gate, BoardingPassNo | TicketID (UNIQUE), **CheckInStaffID** |
| STAFF | StaffID | StaffName, StaffRole | — |
| BOOKINGSTAFF | StaffID | *(subtype attributes, TBD)* | StaffID → STAFF |
| CHECKINSTAFF | StaffID | *(subtype attributes, TBD)* | StaffID → STAFF |

**Create order** (parents first): AIRPORT, AIRCRAFT, PASSENGER, STAFF → BOOKINGSTAFF, CHECKINSTAFF, SEAT, FLIGHT → FARE, RESERVATION → TICKET, PAYMENT → BAGGAGE, CHECKIN. **Drop order** is the reverse (Lecture 8.2).

## Relationships (from the Chen EER)

| Relationship | Parent → child | Card. | FK goes in | ON DELETE: Patarawadee decides |
|---|---|---|---|---|
| Origin | AIRPORT → FLIGHT | 1:N | FLIGHT.OriginCode | RESTRICT? |
| Destination | AIRPORT → FLIGHT | 1:N | FLIGHT.DestinationCode | RESTRICT? |
| Uses | AIRCRAFT → FLIGHT | 1:N | FLIGHT.AircraftID | RESTRICT? |
| Has | AIRCRAFT → SEAT | 1:N | SEAT.AircraftID | CASCADE or RESTRICT? |
| Offers | FLIGHT → FARE | 1:N | FARE.FlightID | CASCADE? |
| Makes | PASSENGER → RESERVATION | 1:N | RESERVATION.PassengerID | RESTRICT? |
| Created | BOOKINGSTAFF → RESERVATION | 1:N | RESERVATION.BookingStaffID | SET NULL? (then the FK must allow NULL) |
| Covers | RESERVATION → PAYMENT | 1:N | PAYMENT.ReservationID | RESTRICT? (do not lose money records) |
| BelongsTo | RESERVATION → TICKET | 1:N | TICKET.ReservationID | CASCADE? |
| For | FLIGHT → TICKET | 1:N | TICKET.FlightID | RESTRICT? |
| AssignedTo | SEAT → TICKET | 1:N | TICKET.SeatID | RESTRICT? |
| Carries | TICKET → BAGGAGE | 1:N | BAGGAGE.TicketID | CASCADE? |
| ResultsIn | TICKET → CHECKIN | 1:1 | CHECKIN.TicketID (UNIQUE) | CASCADE? |
| Processes | CHECKINSTAFF → CHECKIN | 1:N | CHECKIN.CheckInStaffID | SET NULL? |
| ISA (d) | STAFF → BOOKINGSTAFF / CHECKINSTAFF | disjoint | subtype.StaffID (PK + FK) | CASCADE |

M:N: RESERVATION ⇄ FLIGHT, resolved by TICKET.

## ERD review: fix before the report (Patarawadee, with all three reviewing)

From `docs/erd/eer-chen.webp` and `docs/erd/erd-crowsfoot.png`:

1. **Only one M:N.** Lab 6 requires at least two. See open question 1.
2. **PAYMENT.Status is underlined** in the Chen EER. Only `PaymentID` should be underlined (the key).
3. **Typos:** `DepartmentTime` → `DepartureTime`. `MemberShipStatus` → `MembershipStatus` (match the proposal and the SQL).
4. **FLIGHT shows FK ovals** (AircraftID, OriginCode, DestinationCode). In Chen notation the FKs are expressed by the relationships, so remove these ovals (other entities such as TICKET do not show FK ovals). They belong in the relational model (§4).
5. **The crow's-foot sketch disagrees with the EER on staff.** It draws the "many" end at STAFF for Staff–Reservation and Staff–CheckIn, and links STAFF directly. The EER says one BookingStaff creates many Reservations, and one CheckInStaff processes many CheckIns. Make the sketch match the EER, or stop using it.
6. **Specialisation participation.** The single line from STAFF to the `d` circle means *partial* (a staff member could be neither type). If every staff member must be one of the two, draw a double line (*total*). Either way, update BR14 to say which.
7. Add `1` / `N` labels next to each diamond if Aj. Pree wants classic Chen cardinality labels. The diagram currently uses crow's-foot line ends.

## Business rules: where each one is enforced

The DB layer is Patarawadee's (Phase 3). The backend layer is Kawintida's (Phase 4).

| BR | Rule (short) | Enforced in |
|---|---|---|
| BR1, BR2 | Flight has one origin and one destination airport | DB: `NOT NULL` FKs |
| BR3 | Flight uses exactly one aircraft | DB: `NOT NULL` FK |
| BR4 | Seat belongs to one aircraft | DB: `NOT NULL` FK |
| BR5 | Reservation belongs to one passenger | DB: `NOT NULL` FK |
| BR6 | Reservation ⇄ Flight M:N via TICKET | DB: TICKET table |
| BR7 | Origin ≠ destination | DB: `CHECK`, also validated in the backend |
| BR8 | Payment before a ticket is issued | Backend: `ticketController` |
| BR9 | Baggage is optional | DB: nothing required |
| BR10 | No seat on two live tickets for the same flight | Backend transaction (`reservationController`). DB: consider a `UNIQUE` on (FlightID, SeatID) |
| BR11 | Seat rows ≤ Aircraft.TotalSeat | Backend: `seatController` |
| BR12 | Bag weight per ticket ≤ class limit | Backend: `baggageController` |
| BR13 | Check-in only if ticket issued and flight not departed | Backend: `checkinController` |
| BR14 | Staff is BookingStaff **or** CheckInStaff | DB: subtype tables. Backend: `staffController` |
| BR15 | Fare belongs to one flight | DB: `NOT NULL` FK |
| *new* BR16 | A BookingStaff member may create many Reservations; each Reservation is created by one BookingStaff | DB: FK `RESERVATION.BookingStaffID` (Kawintida adds the rule text, report §2) |
| *new* BR17 | A CheckInStaff member may process many CheckIns; each CheckIn is processed by one CheckInStaff | DB: FK `CHECKIN.CheckInStaffID` |

## Open design questions: decide Mon 5 Oct (all three members)

1. **Second M:N relationship** (Lab 6 requirement). Candidates:
   - STAFF ⇄ FLIGHT crew/gate duty: bridge `FLIGHT_ASSIGNMENT(StaffID, FlightID, DutyRole)`
   - PASSENGER ⇄ FLIGHT is **not** valid, because it is already covered through RESERVATION/TICKET (a redundant path)
2. ~~Who handled a booking or check-in?~~ **Resolved by the EER:** `BookingStaffID` and `CheckInStaffID` FKs.
3. **Ticket price.** TICKET does not link to FARE. To compute income per route (report Q3), should TICKET store `FareID` or `PricePaid`?
4. **Income per route.** PAYMENT belongs to a RESERVATION, but one reservation can span several flights. How is the money split?
5. **Subtype attributes.** What do BOOKINGSTAFF / CHECKINSTAFF store that STAFF does not? Without extra attributes the specialisation is hard to justify. Example: `Counter`, `Terminal`.
6. **Baggage limits** per class (BR12): Economy 20 kg. What are the limits for Business and FirstClass?

## Functional dependencies + 3NF check: Patarawadee fills this in (Lecture 7)

Write one FD per business rule: *determinant → dependents*. Then check each table:
**1NF** (atomic values, no repeating groups) → **2NF** (no partial dependency on part of a composite key) → **3NF** (no transitive dependency, non-key → non-key).

| Table | FDs | 1NF | 2NF | 3NF | Notes |
|---|---|---|---|---|---|
| PASSENGER | | | | | |
| AIRPORT | | | | | |
| AIRCRAFT | | | | | |
| FLIGHT | | | | | |
| SEAT | | | | | |
| FARE | | | | | |
| RESERVATION | | | | | |
| TICKET | | | | | |
| PAYMENT | | | | | |
| BAGGAGE | | | | | |
| CHECKIN | | | | | |
| STAFF | | | | | |
| BOOKINGSTAFF | | | | | |
| CHECKINSTAFF | | | | | |
| *(second M:N bridge)* | | | | | |
