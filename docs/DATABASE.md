# Database design notes

**Owner:** Patarawadee (Phase 2 lead, Phase 3). All three members fill in the open questions in Phase 2.
**Source:** Lab 7 proposal §3 (business rules, entity list), Lab 6 B3.

Only Patarawadee changes `db/schema.sql`. Anyone can suggest changes to this
file through a pull request.

## Entities (12 + 2 subtype tables)

| Table | PK | Main attributes | FKs |
|---|---|---|---|
| PASSENGER | PassengerID | Name, PassportNo, PhoneNo, Email, MembershipStatus (Normal/Silver/Gold) | — |
| AIRPORT | AirportCode | City, Country | — |
| AIRCRAFT | AircraftID | AircraftModel, TotalSeat | — |
| FLIGHT | FlightID | DepartureTime, ArrivalTime, Status (OnTime/Delayed/Canceled) | AircraftID, OriginCode, DestinationCode |
| SEAT | SeatID | SeatNo, SeatClass (Economy/Business/FirstClass) | AircraftID |
| RESERVATION | ReservationID | BookingDate, ReservationStatus (Held/Confirmed/Cancelled) | PassengerID |
| FARE | FareID | Class, Price, Rule (Refundable/Changeable) | FlightID |
| TICKET *(bridge)* | TicketID | TicketIssueDate, TicketStatus (issued/used/cancelled) | ReservationID, FlightID, SeatID |
| BAGGAGE | BaggageID | Weight, BaggageStatus | TicketID |
| PAYMENT | PaymentID | TotalAmount, PaymentMethod, TimeStamp, Status (Paid/Refunded) | ReservationID |
| CHECKIN | CheckInID | CheckInTime, Gate, BoardingPassNo | TicketID (UNIQUE, 1:1) |
| STAFF | StaffID | StaffName, StaffRole | — |
| BOOKINGSTAFF | StaffID | *(subtype attributes, TBD)* | StaffID → STAFF |
| CHECKINSTAFF | StaffID | *(subtype attributes, TBD)* | StaffID → STAFF |

## Business rules: where each one is enforced

The DB layer is Patarawadee's (Phase 3). The backend layer is Kawintida's (Phase 4).

| BR | Rule (short) | Enforced in |
|---|---|---|
| BR1, BR2 | Flight has exactly one origin and one destination airport | DB: `NOT NULL` FKs |
| BR3 | Flight uses exactly one aircraft | DB: `NOT NULL` FK |
| BR4 | Seat belongs to one aircraft | DB: `NOT NULL` FK |
| BR5 | Reservation belongs to one passenger | DB: `NOT NULL` FK |
| BR6 | Reservation ⇄ Flight M:N via TICKET | DB: TICKET table |
| BR7 | Origin ≠ destination | DB: `CHECK`, also validated in the backend |
| BR8 | Payment before a ticket is issued | Backend: `ticketController` |
| BR9 | Baggage is optional | DB: nothing required |
| BR10 | No seat on two live tickets for the same flight | Backend transaction in `reservationController`. DB: consider a `UNIQUE` on (FlightID, SeatID) for non-cancelled tickets |
| BR11 | Seat rows ≤ Aircraft.TotalSeat | Backend: `seatController` |
| BR12 | Bag weight per ticket ≤ class limit | Backend: `baggageController` |
| BR13 | Check-in only if ticket issued and flight not departed | Backend: `checkinController` |
| BR14 | Staff is BookingStaff **or** CheckInStaff | DB: subtype tables. Backend: `staffController` (disjoint) |
| BR15 | Fare belongs to one flight | DB: `NOT NULL` FK |

## Open design questions: decide in Phase 2 (all three members)

1. **Second M:N relationship.** Lab 6 B1 requires *at least two* many-to-many
   relationships, each with a bridge table. The current design has only one
   (Reservation ⇄ Flight via TICKET). Candidates:
   - Staff ⇄ Flight (crew/gate assignment): bridge `FLIGHT_ASSIGNMENT(StaffID, FlightID, Role)`
   - CheckInStaff ⇄ CheckIn (who processed it), if more than one staff member can handle a check-in
2. **Who handled it?** Lab 7 scope says the system identifies *who created or
   handled a booking or check-in*, but RESERVATION and CHECKIN have no StaffID.
   Should we add `RESERVATION.BookingStaffID` and `CHECKIN.CheckInStaffID`?
3. **Ticket price.** TICKET does not link to FARE. To calculate the price of a
   ticket and the income per route (report Q3), should TICKET store `FareID`
   or a `PricePaid`?
4. **Income per route.** PAYMENT belongs to a RESERVATION, but one reservation
   can cover several flights. How is the money split per route?
5. **Subtype attributes.** What does BOOKINGSTAFF / CHECKINSTAFF store that
   STAFF does not? If nothing, consider attributes such as `Counter` or `Terminal`.
6. **Baggage limits** per class (BR12): Economy 20 kg. What are the limits for Business and FirstClass?

## 3NF check: Patarawadee fills this in during Phase 2

| Table | 1NF | 2NF | 3NF | Notes |
|---|---|---|---|---|
| PASSENGER | | | | |
| … | | | | |
