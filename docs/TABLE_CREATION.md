# How the tables were built (report §5–6)

**Owner:** Patarawadee (Phase 3). The SQL itself is [`db/schema.sql`](../db/schema.sql). This file
explains the steps behind it for report §6, following the Lecture 8 order:
**data types → nullable → unique → PK/FK → defaults → domain checks**.
Every example below was checked against the live schema on MySQL 8.0.

## §5 Create the database

```sql
CREATE DATABASE IF NOT EXISTS meow_airline;
USE meow_airline;
```

The script then drops any old tables **children first** (CHECKIN, BAGGAGE, PAYMENT, TICKET, …,
AIRPORT last), so it can be re-run on a database that already has data. It creates the 17 tables
**parents first**, because a foreign key can only point at a table that already exists
(Lecture 8.2).

## §6 Create the tables, step by step

### Step 1: Choose a data type for every column

| Kind of data | Type | Examples | Why |
|---|---|---|---|
| Surrogate keys | `INT` + `AUTO_INCREMENT` | PassengerID, FlightID, TicketID (12 tables) | MySQL numbers new rows itself |
| Natural key with a fixed length | `CHAR(3)` | AirportCode (`'BKK'`), OriginCode, DestinationCode | IATA codes are always 3 letters |
| Text of varying length | `VARCHAR(n)` sized to the data | Name `VARCHAR(100)`, PassportNo `VARCHAR(20)`, SeatNo `VARCHAR(4)`, FlightNo `VARCHAR(6)` | Uses only the space it needs |
| Money | `DECIMAL(10,2)` | Price, Fee, TotalAmount | Exact to the satang; `FLOAT` would round |
| Weight | `DECIMAL(5,2)` | BAGGAGE.Weight (kg) | Up to 999.99 kg, two decimals |
| Date and time | `DATETIME` | DepartureTime, ArrivalTime, CheckInTime, PAYMENT.TimeStamp | Flights need the time, not just the day |
| Date only | `DATE` | BookingDate, TicketIssueDate | The time of day isn't needed |
| A fixed list of values | `ENUM(...)` | MembershipStatus (Normal/Silver/Gold), SeatClass, TicketStatus, PaymentMethod | MySQL rejects any value not on the list |
| Generated helper | `TINYINT AS (...) STORED` | TICKET.ActiveSeat | Computed from TicketStatus for BR10 |

### Step 2: Decide which columns may be empty (`NULL`)

The default is **`NOT NULL`**. A column is nullable only when the business really allows it to be
empty. Only 7 columns are nullable (plus the generated ActiveSeat, which is `NULL` on purpose, see step 3):

| Column | Why it may be empty |
|---|---|
| PASSENGER.PhoneNo, PASSENGER.Email | Optional contact details |
| FARE_CONDITION.Description | The name is enough |
| RESERVATION.BookingStaffID | Booked online, or the staff member has left (partial participation in **Created**) |
| CHECKIN.CheckInStaffID | Self check-in (partial participation in **Processes**) |
| CHECKIN.Gate | Not assigned yet |
| TICKET.TicketIssueDate | Empty until the ticket is issued after payment (BR8) |

Every foreign key for a **total participation** in the EER is `NOT NULL`. For example, a ROUTE
must have two airports (BR1–BR2), a FLIGHT must have a route and an aircraft (BR3), and a TICKET
must belong to a reservation.

### Step 3: Mark the values that must be unique

| Constraint | Column(s) | Business reason |
|---|---|---|
| `PASSENGER_PassportNo_UQ` | PassportNo | One passport = one passenger |
| `SEAT_Aircraft_SeatNo_UQ` | (AircraftID, SeatNo) | No two seats '12A' on one aircraft |
| `FLIGHT_No_Departure_UQ` | (FlightNo, DepartureTime) | MW101 flies once per departure time |
| `FARE_CONDITION_Name_UQ` | ConditionName | No duplicate 'Refundable' |
| `CHECKIN_Ticket_UQ` | TicketID | 1:1, a ticket is checked in once |
| `CHECKIN_BoardingPass_UQ` | BoardingPassNo | Every boarding pass number is different |
| `TICKET_Seat_On_Flight_UQ` | (FlightID, SeatID, ActiveSeat) | **BR10: no double-booked seat (O1)** |
| `TICKET_Passenger_On_Flight_UQ` | (FlightID, PassengerID, ActiveSeat) | BR18: one live seat per traveller per flight |
| `STAFF_ID_Role_UQ` | (StaffID, StaffRole) | Target of the subtype FKs (BR14) |
| `FARE_ID_Flight_UQ` | (FareID, FlightID) | Target of TICKET's fare FK (BR15) |

The two TICKET constraints use a trick: ActiveSeat is `NULL` for a cancelled ticket, and `UNIQUE`
ignores `NULL`s. So a cancelled ticket frees its seat, but two live tickets for one seat are refused.

### Step 4: Add the primary and foreign keys

- **Primary keys:** every table has one, named `<TABLE>_PK`. Most are `AUTO_INCREMENT` surrogates.
  AIRPORT uses its natural key AirportCode, and ROUTE uses FlightNo (`'MW101'`). FARE_RULE has the only composite PK
  (FareID, ConditionID). The two staff subtypes reuse StaffID from STAFF.
- **Foreign keys:** 21 FKs, each named `<CHILD>_<PARENT>_FK`, and each with an `ON DELETE` and
  `ON UPDATE` action chosen on purpose:
  - **CASCADE** when the child means nothing without its parent: seats with their aircraft,
    fares with their flight, tickets with their reservation, bags and check-ins with their ticket.
  - **RESTRICT** when deleting would lose history or money: a passenger with bookings, a
    reservation with payments, a flight that sold tickets.
  - **SET NULL** when the row should stay but the link is optional: the booking or check-in staff
    member who left.

  The full list with a reason for each is in
  [`RELATIONAL_MODEL.md` §2](RELATIONAL_MODEL.md#2-foreign-keys-and-their-actions).
- Two FKs are **composite** so MySQL can enforce a business rule by itself:
  BOOKINGSTAFF/CHECKINSTAFF (StaffID, StaffRole) → STAFF for BR14, and
  TICKET (FareID, FlightID) → FARE for BR15.

### Step 5: Give default values

| Column | Default | Meaning |
|---|---|---|
| PASSENGER.MembershipStatus | `'Normal'` | New passengers start at the lowest tier |
| SEAT.SeatClass | `'Economy'` | Most seats are Economy |
| FLIGHT.Status | `'OnTime'` | Until the airline says otherwise |
| RESERVATION.BookingDate | `(CURRENT_DATE)` | Booked today |
| RESERVATION.ReservationStatus | `'Held'` | Held until it is paid |
| TICKET.TicketStatus | `'booked'` | Issued only after payment (BR8) |
| PAYMENT.TimeStamp | `CURRENT_TIMESTAMP` | Recorded when it is paid |
| PAYMENT.Status | `'Paid'` | Refund is a later change |
| BAGGAGE.BaggageStatus | `'CheckedIn'` | A bag starts at the counter |
| CHECKIN.CheckInTime | `CURRENT_TIMESTAMP` | Checked in now |
| FARE_RULE.Fee | `0.00` | Most conditions are free |
| BOOKINGSTAFF.StaffRole / CHECKINSTAFF.StaffRole | `'BookingStaff'` / `'CheckInStaff'` | Fixed for each subtype |

### Step 6: Add the domain checks (`CHECK`)

| Constraint | Rule | Business reason |
|---|---|---|
| `ROUTE_Airports_CK` | OriginCode <> DestinationCode | **BR7** |
| `FLIGHT_Times_CK` | ArrivalTime > DepartureTime | A flight lands after it leaves |
| `AIRCRAFT_TotalSeat_CK` | TotalSeat > 0 | An aircraft has seats |
| `FARE_Price_CK` | Price > 0 | No free fares |
| `FARE_RULE_Fee_CK` | Fee >= 0 | A fee can be zero, never negative |
| `PAYMENT_Amount_CK` | TotalAmount > 0 | A payment moves money |
| `BAGGAGE_Weight_CK` | Weight > 0 AND Weight <= 32 | 32 kg single-bag safety limit |
| `BOOKINGSTAFF_Role_CK` | StaffRole = 'BookingStaff' | **BR14** |
| `CHECKINSTAFF_Role_CK` | StaffRole = 'CheckInStaff' | **BR14** |

The `ENUM` types from step 1 also work as domain checks, because MySQL rejects any value outside
the list.

**Rules a `CHECK` cannot express.** A `CHECK` can only look at one row of one table. These rules
compare tables, so the backend enforces them: BR8 (pay before issuing), BR11 (seats ≤ TotalSeat),
BR12 (total bag weight per class), BR13 (check-in timing), and that a ticket's seat is on the
flight's aircraft. See [`DATABASE.md`](DATABASE.md#business-rules-where-each-one-is-enforced).

## Proof that the constraints work

`db/queries.sql` section E (Q15–Q18) runs each kind of constraint against the seed data: an
UPDATE that succeeds (Q15), a DELETE refused by `RESTRICT` (Q16, Q18d), a DELETE that `CASCADE`s
(Q17), and INSERTs refused by `CHECK` (Q18a, BR7) and `UNIQUE` (Q18b–c, BR10, BR18). Their
screenshots belong in report §7.
