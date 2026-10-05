# Database design notes

**Owner:** Patarawadee (Phase 2 lead, Phase 3). All three members decide the open questions.
**Sources:** Lab 7 §3, Lab 6 B3, the ERDs in [`docs/erd/`](erd/), Lectures 7–10.

Only Patarawadee changes `db/schema.sql`. Anyone may suggest changes to this file through a PR.

![Architecture](architecture.png)

## Entities (13 + 2 subtype tables + 1 bridge = 16 tables)

Implemented in [`db/schema.sql`](../db/schema.sql) and tested on MySQL 8.0. The staff FKs on
RESERVATION and CHECKIN come from the EER's **Created** and **Processes** relationships.
Columns in **bold** were added in the SQL and are not in the EER yet. Add them to the EER, or tell
Patarawadee to remove them:

- **FLIGHT.FlightNo** (`'MW101'`). The business question "seats free on flight MW101 on 20 October" needs a flight number that repeats every day. FlightID stays the surrogate PK.
- **TICKET.PassengerID** → PASSENGER. The traveller on the ticket. RESERVATION.PassengerID stays as the person who booked, so a family of 3 on one reservation gets 3 named tickets (resolves open question 7).
- **TICKET.FareID** → FARE. This gives each ticket its price, so income per route can be calculated (resolves open questions 3 and 4).
- **TICKET.ActiveSeat**. A generated helper column so MySQL itself enforces BR10 (see below).
- **StaffRole in each subtype table**. Lets MySQL enforce BR14 (see below).

| Table | PK | Main attributes | FKs |
|---|---|---|---|
| PASSENGER | PassengerID | Name, PassportNo, PhoneNo, Email, MembershipStatus (Normal/Silver/Gold) | — |
| AIRPORT | AirportCode | City, Country | — |
| AIRCRAFT | AircraftID | AircraftModel, TotalSeat | — |
| FLIGHT | FlightID | **FlightNo**, DepartureTime, ArrivalTime, Status (OnTime/Delayed/Canceled) | AircraftID, OriginCode, DestinationCode |
| SEAT | SeatID | SeatNo, SeatClass (Economy/Business/FirstClass) | AircraftID |
| FARE | FareID | Class, Price *(the old `Rule` column moved to FARE_RULE)* | FlightID |
| **FARE_CONDITION** | ConditionID | ConditionName (UNIQUE), Description | — |
| **FARE_RULE** *(bridge)* | (FareID, ConditionID) | Fee | FareID, ConditionID |
| RESERVATION | ReservationID | BookingDate, ReservationStatus (Held/Confirmed/Cancelled) | PassengerID, **BookingStaffID** |
| TICKET *(bridge)* | TicketID | TicketIssueDate, TicketStatus (booked/issued/used/cancelled), **ActiveSeat** | ReservationID, **PassengerID** (traveller), FlightID, SeatID, **FareID** |
| PAYMENT | PaymentID | TotalAmount, PaymentMethod, TimeStamp, Status (Paid/Refunded) | ReservationID |
| BAGGAGE | BaggageID | Weight, BaggageStatus | TicketID |
| CHECKIN | CheckInID | CheckInTime, Gate, BoardingPassNo | TicketID (UNIQUE), **CheckInStaffID** |
| STAFF | StaffID | StaffName, StaffRole | — |
| BOOKINGSTAFF | StaffID | **StaffRole** (always 'BookingStaff'), other subtype attributes TBD | (StaffID, StaffRole) → STAFF |
| CHECKINSTAFF | StaffID | **StaffRole** (always 'CheckInStaff'), other subtype attributes TBD | (StaffID, StaffRole) → STAFF |

**Create order** (parents first): AIRPORT, AIRCRAFT, PASSENGER, STAFF → BOOKINGSTAFF, CHECKINSTAFF, SEAT, FLIGHT, FARE_CONDITION → FARE → FARE_RULE, RESERVATION → TICKET, PAYMENT → BAGGAGE, CHECKIN. **Drop order** is the reverse (Lecture 8.2).

## Relationships (from the Chen EER)

| Relationship | Parent → child | Card. | FK goes in | ON DELETE in `schema.sql`, and why |
|---|---|---|---|---|
| Origin | AIRPORT → FLIGHT | 1:N | FLIGHT.OriginCode | RESTRICT: an airport with flights cannot disappear |
| Destination | AIRPORT → FLIGHT | 1:N | FLIGHT.DestinationCode | RESTRICT |
| Uses | AIRCRAFT → FLIGHT | 1:N | FLIGHT.AircraftID | RESTRICT |
| Has | AIRCRAFT → SEAT | 1:N | SEAT.AircraftID | CASCADE: a seat cannot exist without its aircraft |
| Offers | FLIGHT → FARE | 1:N | FARE.FlightID | CASCADE |
| Makes | PASSENGER → RESERVATION | 1:N | RESERVATION.PassengerID (the booker) | RESTRICT: keep booking history (demo Q16) |
| *(new)* TravelsOn | PASSENGER → TICKET | 1:N | TICKET.PassengerID (the traveller) | RESTRICT: cannot delete a passenger who has tickets |
| Created | BOOKINGSTAFF → RESERVATION | 1:N | RESERVATION.BookingStaffID (nullable) | SET NULL: NULL also means booked online |
| Covers | RESERVATION → PAYMENT | 1:N | PAYMENT.ReservationID | RESTRICT: never lose money records |
| BelongsTo | RESERVATION → TICKET | 1:N | TICKET.ReservationID | CASCADE (demo Q17) |
| For | FLIGHT → TICKET | 1:N | TICKET.FlightID | RESTRICT |
| AssignedTo | SEAT → TICKET | 1:N | TICKET.SeatID | RESTRICT |
| Carries | TICKET → BAGGAGE | 1:N | BAGGAGE.TicketID | CASCADE |
| ResultsIn | TICKET → CHECKIN | 1:1 | CHECKIN.TicketID (UNIQUE) | CASCADE |
| Processes | CHECKINSTAFF → CHECKIN | 1:N | CHECKIN.CheckInStaffID (nullable) | SET NULL |
| ISA (d) | STAFF → BOOKINGSTAFF / CHECKINSTAFF | disjoint | subtype (StaffID, StaffRole) | RESTRICT: MySQL forbids CASCADE on a column with a CHECK, so delete the subtype row first |

| *(new)* | FARE → TICKET | 1:N | TICKET.FareID | RESTRICT |
| *(new)* Has rule | FARE ⇄ FARE_CONDITION | **M:N** | bridge FARE_RULE (FareID → CASCADE, ConditionID → RESTRICT) | rules go with their fare; a condition in use cannot be deleted (demo Q18d) |

M:N relationships (Lab 6 needs at least two):
1. RESERVATION ⇄ FLIGHT, resolved by **TICKET** (extra attributes: SeatID, PassengerID, FareID, issue date, status)
2. FARE ⇄ FARE_CONDITION, resolved by **FARE_RULE** (extra attribute: Fee)

On-update actions are CASCADE, except the two AIRPORT FKs on FLIGHT. Those use RESTRICT,
because MySQL does not allow CASCADE on columns that a CHECK uses (`FLIGHT_Route_CK`, BR7).

### Two rules enforced by MySQL itself, not only by the backend

- **BR10, no double booking (O1).** `TICKET.ActiveSeat` is `1` for a live ticket and `NULL` for a
  cancelled one. `UNIQUE (FlightID, SeatID, ActiveSeat)` rejects a second live ticket for the same
  seat on the same flight (error 1062), but lets a seat be resold after a cancellation, because
  UNIQUE ignores NULLs. Demo: `db/queries.sql` Q18b.
- **BR14, disjoint specialisation.** STAFF has `UNIQUE (StaffID, StaffRole)`. Each subtype table
  stores its own role (fixed by a CHECK) and references that pair, so a BookingStaff member cannot
  also be added to CHECKINSTAFF (error 1452).
- **BR18, one seat per traveller per flight.** `UNIQUE (FlightID, PassengerID, ActiveSeat)` stops
  the same passenger from holding two live tickets on one flight (error 1062, demo Q18c).
  Like BR10, a cancelled ticket does not count.

## ERD review: fix before the report (Patarawadee, with all three reviewing)

From `docs/erd/eer-chen.webp` and `docs/erd/erd-crowsfoot.png`:

1. **Add the second M:N** to the EER: a FARE_CONDITION entity (ConditionID, ConditionName, Description) and a **Has rule** diamond between FARE and FARE_CONDITION (M:N) with the attribute **Fee** on the relationship. Remove the `Rule` oval from FARE.
2. **Add the TravelsOn relationship** (PASSENGER 1 : N TICKET, BR18). The SQL already has it.
3. **PAYMENT.Status is underlined** in the Chen EER. Only `PaymentID` should be underlined (the key).
4. **Typos:** `DepartmentTime` → `DepartureTime`. `MemberShipStatus` → `MembershipStatus` (match the proposal and the SQL).
5. **FLIGHT shows FK ovals** (AircraftID, OriginCode, DestinationCode). In Chen notation the FKs are expressed by the relationships, so remove these ovals (other entities such as TICKET do not show FK ovals). They belong in the relational model (§4).
6. **The crow's-foot sketch disagrees with the EER on staff.** It draws the "many" end at STAFF for Staff–Reservation and Staff–CheckIn, and links STAFF directly. The EER says one BookingStaff creates many Reservations, and one CheckInStaff processes many CheckIns. Make the sketch match the EER, or stop using it.
7. **Specialisation participation.** The single line from STAFF to the `d` circle means *partial* (a staff member could be neither type). If every staff member must be one of the two, draw a double line (*total*). Either way, update BR14 to say which.
8. Add `1` / `N` labels next to each diamond if Aj. Pree wants classic Chen cardinality labels. The diagram currently uses crow's-foot line ends.

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
| BR10 | No seat on two live tickets for the same flight | **DB:** `TICKET_Seat_On_Flight_UQ`. Backend: also check inside the booking transaction so the user gets a friendly message |
| BR11 | Seat rows ≤ Aircraft.TotalSeat | Backend: `seatController` |
| BR12 | Bag weight per ticket ≤ class limit | Backend: `baggageController` |
| BR13 | Check-in only if ticket issued and flight not departed | Backend: `checkinController` |
| BR14 | Staff is BookingStaff **or** CheckInStaff | **DB:** composite FK (StaffID, StaffRole). Backend: `staffController` inserts both rows in one transaction |
| BR15 | Fare belongs to one flight | DB: `NOT NULL` FK |
| *new* BR16 | A BookingStaff member may create many Reservations; each Reservation is created by one BookingStaff | DB: FK `RESERVATION.BookingStaffID` (Kawintida adds the rule text, report §2) |
| *new* BR17 | A CheckInStaff member may process many CheckIns; each CheckIn is processed by one CheckInStaff | DB: FK `CHECKIN.CheckInStaffID` |
| *new* BR18 | A Passenger may travel on many Tickets; each Ticket is for exactly one Passenger, who holds at most one live Ticket per Flight | **DB:** FK `TICKET.PassengerID` + `TICKET_Passenger_On_Flight_UQ` |
| *new* BR19 | A Fare may have many FareConditions and a FareCondition may apply to many Fares; each pairing records its Fee | **DB:** FARE_RULE composite PK + 2 FKs, `CHECK (Fee >= 0)` |

## Open design questions: decide Mon 5 Oct (all three members)

1. ~~Second M:N relationship~~ **Resolved:** FARE ⇄ FARE_CONDITION through the FARE_RULE bridge (BR19). STAFF ⇄ FLIGHT duty was rejected because Lab 7 §2.2 puts staff scheduling out of scope. A fare can be both refundable and changeable, so the single `FARE.Rule` value also broke 1NF.
2. ~~Who handled a booking or check-in?~~ **Resolved by the EER:** `BookingStaffID` and `CheckInStaffID` FKs.
3. ~~Ticket price~~ **Resolved in the SQL:** `TICKET.FareID`. Revert if the team disagrees.
4. ~~Income per route~~ **Resolved in the SQL:** income = the fare price of each live ticket, grouped by the ticket's flight route (`queries.sql` Q3). Payments are used only for paid/unpaid status.
5. **Subtype attributes.** What do BOOKINGSTAFF / CHECKINSTAFF store that STAFF does not? Without extra attributes the specialisation is hard to justify. Example: `Counter`, `Terminal`.
6. **Baggage limits** per class (BR12): Economy 20 kg. `queries.sql` Q11 *assumes* Business 30 kg and FirstClass 40 kg. Confirm these.
7. ~~Who is the traveller on each ticket?~~ **Resolved:** `TICKET.PassengerID` → PASSENGER (BR18). RESERVATION.PassengerID is the booker; each ticket names who flies. Add a **TravelsOn** relationship (PASSENGER 1:N TICKET) to the EER.

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
| FARE_CONDITION | | | | | |
| FARE_RULE | | | | | |
