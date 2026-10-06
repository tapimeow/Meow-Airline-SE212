# Relational model (report §4)

**Owner:** Patarawadee (Phase 2). Built from the EER in [`docs/erd/`](erd/) and checked against
[`db/schema.sql`](../db/schema.sql) on MySQL 8.0. The FDs and the 3NF check are in
[`docs/DATABASE.md`](DATABASE.md#functional-dependencies--3nf-check-patarawadee-fills-this-in-lecture-7).

**Notation:** <u>underlined</u> = primary key · *italic* = foreign key (→ the table it references) ·
`UQ` = other candidate key (`UNIQUE`). 16 relations, listed parents first (the create order).

## 1. Relations

**AIRPORT** (<u>AirportCode</u>, City, Country)

**AIRCRAFT** (<u>AircraftID</u>, AircraftModel, TotalSeat)

**PASSENGER** (<u>PassengerID</u>, Name, PassportNo, PhoneNo, Email, MembershipStatus)
- UQ: PassportNo

**STAFF** (<u>StaffID</u>, StaffName, StaffRole)
- UQ: (StaffID, StaffRole), the target of the two subtype FKs

**BOOKINGSTAFF** (<u>*StaffID*</u>, *StaffRole*)
- (StaffID, StaffRole) → STAFF (StaffID, StaffRole) · StaffRole is always 'BookingStaff'

**CHECKINSTAFF** (<u>*StaffID*</u>, *StaffRole*)
- (StaffID, StaffRole) → STAFF (StaffID, StaffRole) · StaffRole is always 'CheckInStaff'

**SEAT** (<u>SeatID</u>, *AircraftID*, SeatNo, SeatClass)
- AircraftID → AIRCRAFT
- UQ: (AircraftID, SeatNo)

**FLIGHT** (<u>FlightID</u>, FlightNo, *AircraftID*, *OriginCode*, *DestinationCode*, DepartureTime, ArrivalTime, Status)
- AircraftID → AIRCRAFT · OriginCode → AIRPORT · DestinationCode → AIRPORT
- UQ: (FlightNo, DepartureTime)

**FARE** (<u>FareID</u>, *FlightID*, Class, Price)
- FlightID → FLIGHT
- UQ: (FareID, FlightID), the target of TICKET's fare FK

**FARE_CONDITION** (<u>ConditionID</u>, ConditionName, Description)
- UQ: ConditionName

**FARE_RULE** (<u>*FareID*, *ConditionID*</u>, Fee)
- FareID → FARE · ConditionID → FARE_CONDITION

**RESERVATION** (<u>ReservationID</u>, *PassengerID*, *BookingStaffID*, BookingDate, ReservationStatus)
- PassengerID → PASSENGER (the booker) · BookingStaffID → BOOKINGSTAFF (nullable)

**TICKET** (<u>TicketID</u>, *ReservationID*, *PassengerID*, *FlightID*, *SeatID*, *FareID*, TicketIssueDate, TicketStatus, ActiveSeat)
- ReservationID → RESERVATION · PassengerID → PASSENGER (the traveller) · FlightID → FLIGHT ·
  SeatID → SEAT · (FareID, FlightID) → FARE (FareID, FlightID)
- UQ: (FlightID, SeatID, ActiveSeat) for BR10 · (FlightID, PassengerID, ActiveSeat) for BR18
- ActiveSeat is generated from TicketStatus (1 = live, NULL = cancelled)

**PAYMENT** (<u>PaymentID</u>, *ReservationID*, TotalAmount, PaymentMethod, TimeStamp, Status)
- ReservationID → RESERVATION

**BAGGAGE** (<u>BaggageID</u>, *TicketID*, Weight, BaggageStatus)
- TicketID → TICKET

**CHECKIN** (<u>CheckInID</u>, *TicketID*, *CheckInStaffID*, CheckInTime, Gate, BoardingPassNo)
- TicketID → TICKET · CheckInStaffID → CHECKINSTAFF (nullable)
- UQ: TicketID (1:1 with TICKET) · BoardingPassNo

## 2. Foreign keys and their actions

| Child | FK column(s) | → Parent | ON DELETE | ON UPDATE | Why |
|---|---|---|---|---|---|
| BOOKINGSTAFF | StaffID, StaffRole | STAFF | RESTRICT | RESTRICT | BR14. MySQL forbids CASCADE on a column with a CHECK |
| CHECKINSTAFF | StaffID, StaffRole | STAFF | RESTRICT | RESTRICT | BR14, same reason |
| SEAT | AircraftID | AIRCRAFT | CASCADE | CASCADE | A seat cannot exist without its aircraft |
| FLIGHT | AircraftID | AIRCRAFT | RESTRICT | CASCADE | Cannot delete an aircraft that has flights |
| FLIGHT | OriginCode | AIRPORT | RESTRICT | RESTRICT | Column is in the BR7 CHECK, so no CASCADE |
| FLIGHT | DestinationCode | AIRPORT | RESTRICT | RESTRICT | Same |
| FARE | FlightID | FLIGHT | CASCADE | CASCADE | A fare means nothing without its flight |
| FARE_RULE | FareID | FARE | CASCADE | CASCADE | The rules go with their fare |
| FARE_RULE | ConditionID | FARE_CONDITION | RESTRICT | CASCADE | Cannot delete a condition still in use |
| RESERVATION | PassengerID | PASSENGER | RESTRICT | CASCADE | Keep booking history |
| RESERVATION | BookingStaffID | BOOKINGSTAFF | SET NULL | CASCADE | Booking stays if the staff member leaves |
| TICKET | ReservationID | RESERVATION | CASCADE | CASCADE | Deleting a reservation deletes its tickets |
| TICKET | PassengerID | PASSENGER | RESTRICT | CASCADE | Cannot delete a passenger who has tickets |
| TICKET | FlightID | FLIGHT | RESTRICT | CASCADE | Cannot delete a flight that sold tickets |
| TICKET | SeatID | SEAT | RESTRICT | CASCADE | Cannot delete a sold seat |
| TICKET | FareID, FlightID | FARE | RESTRICT | CASCADE | BR15: the fare must be for the ticket's flight |
| PAYMENT | ReservationID | RESERVATION | RESTRICT | CASCADE | Never lose money records |
| BAGGAGE | TicketID | TICKET | CASCADE | CASCADE | Bags go with their ticket |
| CHECKIN | TicketID | TICKET | CASCADE | CASCADE | Check-in goes with its ticket |
| CHECKIN | CheckInStaffID | CHECKINSTAFF | SET NULL | CASCADE | Check-in stays if the staff member leaves |

## 3. How the EER became these tables (Lecture 7 mapping rules)

| EER construct | Rule | Result here |
|---|---|---|
| Strong entity | One table, its key becomes the PK | AIRPORT, AIRCRAFT, PASSENGER, STAFF, FLIGHT, SEAT, FARE, FARE_CONDITION, RESERVATION, PAYMENT, BAGGAGE, CHECKIN |
| 1:N relationship | PK of the "1" side goes into the "N" side as an FK | Has, Uses, Origin, Destination, Offers, Makes, Created, Covers, BelongsTo, For, TravelsOn, Sells, AssignedTo, Carries, Processes |
| Total participation on the N side | FK is `NOT NULL` | e.g. every TICKET has a ReservationID |
| Partial participation | FK is nullable | RESERVATION.BookingStaffID, CHECKIN.CheckInStaffID |
| 1:1 relationship | FK on either side, plus `UNIQUE` | ResultsIn → CHECKIN.TicketID |
| M:N relationship | Bridge table, FKs to both sides; relationship attributes move into it | HasRule: FARE ⇄ FARE_CONDITION → **FARE_RULE** (with Fee) |
| Associative entity | Own table; its two relationships become FKs | RESERVATION ⇄ FLIGHT is drawn as the entity **TICKET** with BelongsTo and For → TICKET.ReservationID, TICKET.FlightID |
| Disjoint, total specialisation (`d`) | One table per supertype and subtype, sharing the PK; discriminator StaffRole | STAFF → BOOKINGSTAFF, CHECKINSTAFF |
| Multi-valued attribute | Separate table | The old FARE.Rule → FARE_RULE (1NF) |

TICKET keeps its own surrogate PK (TicketID) instead of (ReservationID, FlightID), because one
reservation can hold several tickets on the same flight (a family of 3, BR18).
