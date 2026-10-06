# Database design notes

**Owner:** Patarawadee (Phase 2 lead, Phase 3). All three members decide the open questions.
**Sources:** Lab 7 §3, Lab 6 B3, the ERDs in [`docs/erd/`](erd/), Lectures 7–10.

Only Patarawadee changes `db/schema.sql`. Anyone may suggest changes to this file through a PR.

![Architecture](architecture.png)

## Entities (14 + 2 subtype tables + 1 bridge = 17 tables)

Implemented in [`db/schema.sql`](../db/schema.sql) and tested on MySQL 8.0. The staff FKs on
RESERVATION and CHECKIN come from the EER's **Created** and **Processes** relationships.
Columns in **bold** were added in the SQL. Checked against the EER (Phase 3): the first three are
already in the diagram, and the next two are implementation helpers that Chen notation does not draw.
The last two come from the team decisions of Tue 6 Oct and still need adding to the EER.

- **FLIGHT.FlightNo** (`'MW101'`). The business question "seats free on flight MW101 on 20 October" needs a flight number that repeats every day. FlightID stays the surrogate PK. *In the EER as a FLIGHT attribute.*
- **TICKET.PassengerID** → PASSENGER. The traveller on the ticket. RESERVATION.PassengerID stays as the person who booked, so a family of 3 on one reservation gets 3 named tickets (resolves open question 7). *In the EER as the TravelsOn relationship.*
- **TICKET.FareID** → FARE. This gives each ticket its price, so income per route can be calculated (resolves open questions 3 and 4). *In the EER as the Sells relationship.*
- **TICKET.ActiveSeat**. A generated helper column so MySQL itself enforces BR10 (see below). *Not drawn: derived from TicketStatus.*
- **StaffRole in each subtype table**. Lets MySQL enforce BR14 (see below). *Not drawn: the EER shows StaffRole once, on STAFF, as the discriminator of the `d` specialisation.*
- **ROUTE** (FlightNo, OriginCode, DestinationCode). A flight number always flies the same route, so the route is stored once here instead of on every dated flight (decision C). *To add to the EER: a ROUTE entity, Origin and Destination move from FLIGHT to ROUTE, and a new Follows relationship (ROUTE 1 : N FLIGHT).*
- **BOOKINGSTAFF.SalesOffice** and **CHECKINSTAFF.CounterNo**. One attribute that only each subtype has (open question 5). *To add to the EER as an oval on each subtype.*

The full relational model for report §4 (every table, PK, FK and FK action) is in
[`RELATIONAL_MODEL.md`](RELATIONAL_MODEL.md).

| Table | PK | Main attributes | FKs |
|---|---|---|---|
| PASSENGER | PassengerID | Name, PassportNo, PhoneNo, Email, MembershipStatus (Normal/Silver/Gold) | — |
| AIRPORT | AirportCode | City, Country | — |
| AIRCRAFT | AircraftID | AircraftModel, TotalSeat | — |
| **ROUTE** | FlightNo | — | OriginCode, DestinationCode |
| FLIGHT | FlightID | DepartureTime, ArrivalTime, Status (OnTime/Delayed/Canceled) | AircraftID, **FlightNo** |
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
| BOOKINGSTAFF | StaffID | **StaffRole** (always 'BookingStaff'), **SalesOffice** | (StaffID, StaffRole) → STAFF |
| CHECKINSTAFF | StaffID | **StaffRole** (always 'CheckInStaff'), **CounterNo** | (StaffID, StaffRole) → STAFF |

**Create order** (parents first): AIRPORT, AIRCRAFT, PASSENGER, STAFF → ROUTE, BOOKINGSTAFF, CHECKINSTAFF, SEAT, FARE_CONDITION → FLIGHT → FARE, RESERVATION → FARE_RULE, TICKET, PAYMENT → BAGGAGE, CHECKIN. **Drop order** is the reverse (Lecture 8.2).

## Relationships (from the Chen EER)

| Relationship | Parent → child | Card. | FK goes in | ON DELETE in `schema.sql`, and why |
|---|---|---|---|---|
| Origin | AIRPORT → ROUTE | 1:N | ROUTE.OriginCode | RESTRICT: an airport with routes cannot disappear |
| Destination | AIRPORT → ROUTE | 1:N | ROUTE.DestinationCode | RESTRICT |
| *(new)* Follows | ROUTE → FLIGHT | 1:N | FLIGHT.FlightNo | RESTRICT: a route with flights cannot disappear |
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

| *(new)* | FARE → TICKET | 1:N | TICKET.(FareID, FlightID) → FARE.(FareID, FlightID) | RESTRICT; the composite FK makes the fare belong to the ticket's flight |
| *(new)* Has rule | FARE ⇄ FARE_CONDITION | **M:N** | bridge FARE_RULE (FareID → CASCADE, ConditionID → RESTRICT) | rules go with their fare; a condition in use cannot be deleted (demo Q18d) |

M:N relationships (Lab 6 needs at least two):
1. RESERVATION ⇄ FLIGHT, resolved by **TICKET** (extra attributes: SeatID, PassengerID, FareID, issue date, status)
2. FARE ⇄ FARE_CONDITION, resolved by **FARE_RULE** (extra attribute: Fee)

On-update actions are CASCADE, except the two AIRPORT FKs on ROUTE. Those use RESTRICT,
because MySQL does not allow CASCADE on columns that a CHECK uses (`ROUTE_Airports_CK`, BR7).

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

## ERD review: done in `docs/erd/meow-airline-eer.drawio`

The new EER ([`erd/meow-airline-eer.png`](erd/meow-airline-eer.png), editable source
`erd/meow-airline-eer.drawio`) fixes everything found in the first drafts
(`eer-chen.webp`, `erd-crowsfoot.png`, kept for history):

1. ✅ **Second M:N added:** FARE_CONDITION entity + **HasRule** (FARE M : N FARE_CONDITION) with **Fee** on the relationship. The `Rule` oval is gone from FARE.
2. ✅ **TravelsOn added** (PASSENGER 1 : N TICKET, BR18), plus **Sells** (FARE 1 : N TICKET, the `TICKET.FareID` FK).
3. ✅ **PAYMENT.Status** is no longer underlined. Only keys are underlined.
4. ✅ **Typos fixed:** `DepartureTime`, `MembershipStatus`. `FlightNo` added.
5. ✅ **FK ovals removed** from FLIGHT. FKs are shown by the relationships, and listed in the relational model (§4).
6. ✅ **The crow's-foot sketch is outdated.** Use the new EER only.
7. ✅ **Specialisation is total + disjoint** (double line from STAFF to `d`): every staff member has a StaffRole (`NOT NULL` in the SQL) and only one (BR14). Kawintida: update BR14's wording to say every staff member is one of the two.
8. ✅ **`1` / `N` / `M` labels** on every relationship, and **double lines for total participation** wherever the SQL column is `NOT NULL` (e.g. every TICKET must belong to a RESERVATION).

Changes made in the EER are outlined in orange so the team can see them. If the team edits the
diagram, open the `.drawio` file in draw.io (File → Open), then File → Export as → PNG
over `meow-airline-eer.png`.

## Business rules: where each one is enforced

The DB layer is Patarawadee's (Phase 3). The backend layer is Kawintida's (Phase 4).

| BR | Rule (short) | Enforced in |
|---|---|---|
| BR1, BR2 | Flight has one origin and one destination airport | DB: `NOT NULL` FKs on ROUTE, and FLIGHT.FlightNo → ROUTE |
| BR3 | Flight uses exactly one aircraft | DB: `NOT NULL` FK |
| BR4 | Seat belongs to one aircraft | DB: `NOT NULL` FK |
| BR5 | Reservation belongs to one passenger | DB: `NOT NULL` FK |
| BR6 | Reservation ⇄ Flight M:N via TICKET | DB: TICKET table |
| BR7 | Origin ≠ destination | DB: `ROUTE_Airports_CK`, also validated in the backend |
| BR8 | Payment before a ticket is issued | Backend: `ticketController` |
| BR9 | Baggage is optional | DB: nothing required |
| BR10 | No seat on two live tickets for the same flight | **DB:** `TICKET_Seat_On_Flight_UQ`. Backend: also check inside the booking transaction so the user gets a friendly message |
| BR11 | Seat rows ≤ Aircraft.TotalSeat | Backend: `seatController` |
| BR12 | Bag weight per ticket ≤ class limit (Economy 20 kg, Business 30 kg, FirstClass 40 kg) | Backend: `baggageController` |
| BR13 | Check-in only if ticket issued and flight not departed | Backend: `checkinController` |
| BR14 | Staff is BookingStaff **or** CheckInStaff | **DB:** composite FK (StaffID, StaffRole). Backend: `staffController` inserts both rows in one transaction |
| BR15 | Fare belongs to one flight | DB: `NOT NULL` FK. A ticket's fare must be for the ticket's flight: composite FK `TICKET_FARE_FK` (FareID, FlightID) |
| *new* BR16 | A BookingStaff member may create many Reservations; each Reservation is created by one BookingStaff | DB: FK `RESERVATION.BookingStaffID` (Kawintida adds the rule text, report §2) |
| *new* BR17 | A CheckInStaff member may process many CheckIns; each CheckIn is processed by one CheckInStaff | DB: FK `CHECKIN.CheckInStaffID` |
| *new* BR18 | A Passenger may travel on many Tickets; each Ticket is for exactly one Passenger, who holds at most one live Ticket per Flight | **DB:** FK `TICKET.PassengerID` + `TICKET_Passenger_On_Flight_UQ` |
| *new* BR19 | A Fare may have many FareConditions and a FareCondition may apply to many Fares; each pairing records its Fee | **DB:** FARE_RULE composite PK + 2 FKs, `CHECK (Fee >= 0)` |

## Open design questions: decide Mon 5 Oct (all three members)

1. ~~Second M:N relationship~~ **Resolved:** FARE ⇄ FARE_CONDITION through the FARE_RULE bridge (BR19). STAFF ⇄ FLIGHT duty was rejected because Lab 7 §2.2 puts staff scheduling out of scope. A fare can be both refundable and changeable, so the single `FARE.Rule` value also broke 1NF.
2. ~~Who handled a booking or check-in?~~ **Resolved by the EER:** `BookingStaffID` and `CheckInStaffID` FKs.
3. ~~Ticket price~~ **Resolved in the SQL:** `TICKET.FareID`. Revert if the team disagrees.
4. ~~Income per route~~ **Resolved in the SQL:** income = the fare price of each live ticket, grouped by the ticket's flight route (`queries.sql` Q3). Payments are used only for paid/unpaid status.
5. ~~Subtype attributes~~ **Resolved (Tue 6 Oct):** BOOKINGSTAFF stores `SalesOffice` (the office the staff member sells from) and CHECKINSTAFF stores `CounterNo` (their check-in counter). Each subtype also has a relationship STAFF does not: BookingStaff **Created** reservations (BR16) and CheckInStaff **Processes** check-ins (BR17).
6. ~~Baggage limits~~ **Resolved (Tue 6 Oct):** Economy 20 kg, Business 30 kg, FirstClass 40 kg (BR12), as used in `queries.sql` Q11.
7. ~~Who is the traveller on each ticket?~~ **Resolved:** `TICKET.PassengerID` → PASSENGER (BR18). RESERVATION.PassengerID is the booker; each ticket names who flies. Shown as **TravelsOn** (PASSENGER 1:N TICKET) in the EER.

## Functional dependencies + 3NF check: Patarawadee fills this in (Lecture 7)

Write one FD per business rule: *determinant → dependents*. Then check each table:
**1NF** (atomic values, no repeating groups) → **2NF** (no partial dependency on part of a composite key) → **3NF** (no transitive dependency, non-key → non-key).

> **Checked against `db/schema.sql`. Decisions A and C agreed by all three members on Tue 6 Oct; B and E are
> still open.** ✓ = passes,
> ⚠ = passes only because of a team decision listed under *Decisions the 3NF check depends on*,
> ✗ = a known exception with its justification.
> Candidate keys are listed because a determinant that is a candidate key never breaks 3NF.

| Table | FDs | 1NF | 2NF | 3NF | Notes |
|---|---|---|---|---|---|
| PASSENGER | PassengerID → Name, PassportNo, PhoneNo, Email, MembershipStatus<br>PassportNo → PassengerID | ✓ | ✓ | ✓ | Candidate keys: PassengerID, PassportNo (`UNIQUE`). Single-column keys, so no partial dependency |
| AIRPORT | AirportCode → City, Country | ✓ | ✓ | ✓ | City → Country is **not** an FD: city names are not unique worldwide (decision A) |
| AIRCRAFT | AircraftID → AircraftModel, TotalSeat | ✓ | ✓ | ⚠ | AircraftModel → TotalSeat is **not** taken as an FD: two aircraft of one model can have different cabin layouts (decision B) |
| ROUTE | FlightNo → OriginCode, DestinationCode | ✓ | ✓ | ✓ | Split out of FLIGHT (decision C). Single-column key |
| FLIGHT | FlightID → FlightNo, AircraftID, DepartureTime, ArrivalTime, Status<br>(FlightNo, DepartureTime) → FlightID | ✓ | ✓ | ✓ | Candidate keys: FlightID, (FlightNo, DepartureTime). The route moved to ROUTE, so FlightNo no longer determines anything else in this table (decision C) |
| SEAT | SeatID → AircraftID, SeatNo, SeatClass<br>(AircraftID, SeatNo) → SeatID | ✓ | ✓ | ✓ | Candidate keys: SeatID, (AircraftID, SeatNo). SeatClass depends on the whole (AircraftID, SeatNo), not on SeatNo alone |
| FARE | FareID → FlightID, Class, Price | ✓ | ✓ | ✓ | BR15. The old multi-valued `Rule` column broke 1NF; it moved to FARE_RULE |
| RESERVATION | ReservationID → PassengerID, BookingStaffID, BookingDate, ReservationStatus | ✓ | ✓ | ✓ | BR5, BR16. PassengerID is the booker; travellers are on TICKET |
| TICKET | TicketID → ReservationID, PassengerID, FlightID, SeatID, FareID, TicketIssueDate, TicketStatus<br>**FareID → FlightID** (BR15)<br>**TicketStatus → ActiveSeat** | ✓ | ✓ | ✗ | Two transitive FDs, both kept on purpose. **ActiveSeat** is a generated column: MySQL computes it from TicketStatus, so it can never disagree (no update anomaly). **FlightID** is kept because the BR10 and BR18 `UNIQUE` constraints need it in this table. A ticket whose fare belongs to another flight is rejected by MySQL through the composite FK `TICKET_FARE_FK` (decision D) |
| PAYMENT | PaymentID → ReservationID, TotalAmount, PaymentMethod, TimeStamp, Status | ✓ | ✓ | ✓ | TotalAmount is stored, not derived: it is what was actually paid |
| BAGGAGE | BaggageID → TicketID, Weight, BaggageStatus | ✓ | ✓ | ✓ | BR9 |
| CHECKIN | CheckInID → TicketID, CheckInStaffID, CheckInTime, Gate, BoardingPassNo<br>TicketID → CheckInID<br>BoardingPassNo → CheckInID | ✓ | ✓ | ✓ | Candidate keys: CheckInID, TicketID, BoardingPassNo, so every determinant is a key. Gate really belongs to the flight (decision E) |
| STAFF | StaffID → StaffName, StaffRole | ✓ | ✓ | ✓ | (StaffID, StaffRole) is `UNIQUE` only as the target of the subtype FKs (BR14) |
| BOOKINGSTAFF | StaffID → StaffRole, SalesOffice | ✓ | ✓ | ✓ | StaffRole is always 'BookingStaff' (CHECK) |
| CHECKINSTAFF | StaffID → StaffRole, CounterNo | ✓ | ✓ | ✓ | StaffRole is always 'CheckInStaff' (CHECK) |
| FARE_CONDITION | ConditionID → ConditionName, Description<br>ConditionName → ConditionID | ✓ | ✓ | ✓ | Candidate keys: ConditionID, ConditionName (`UNIQUE`) |
| FARE_RULE | (FareID, ConditionID) → Fee | ✓ | ✓ | ✓ | BR19. The only composite PK. Fee needs **both** parts (a change fee differs per fare), so there is no partial dependency |

### Decisions the 3NF check depends on

Lecture 7: FDs come from business rules, not sample data. These are the places where the
sample data *looks* like an FD. The team decides whether each one is a business rule.

- **A. City → Country.** ✅ **Agreed: no** (Tue 6 Oct). City names repeat across countries, so a
  city does not determine its country. AIRPORT stays as it is.
- **B. AircraftModel → TotalSeat.** Draft says no, since airlines fit the same model with
  different layouts. If yes, split out an AIRCRAFT_MODEL table.
- **C. FlightNo → OriginCode, DestinationCode.** ✅ **Agreed: yes, done in `schema.sql`** (Tue 6 Oct).
  At real airlines a flight number is a fixed route, and `seed.sql` follows that. With the route
  in FLIGHT, the table broke 2NF (part of the candidate key (FlightNo, DepartureTime) decides
  the route) and 3NF (FlightID → FlightNo → route is transitive): MW101's route was repeated
  on every date it flies. The fix is the ROUTE table (FlightNo PK, OriginCode, DestinationCode)
  with FLIGHT.FlightNo → ROUTE, so each route is stored once.
- **D. TICKET.FareID → FlightID.** ✅ **Done in `schema.sql`**, using the same trick as the staff
  subtypes: FARE has `UNIQUE (FareID, FlightID)`, and TICKET's fare FK is
  `FOREIGN KEY (FareID, FlightID) REFERENCES FARE (FareID, FlightID)`. MySQL rejects a fare
  from another flight (Error Code 1452), so the redundancy stays safe. The table stays ✗ in
  theory, but the report can say the anomaly is blocked by the database.
- **E. CHECKIN.Gate.** Not a 3NF violation in this table (TicketID is a candidate key), but every
  passenger on one flight repeats the same gate. Moving Gate to FLIGHT removes the repetition.
