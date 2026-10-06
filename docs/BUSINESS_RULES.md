# Business rules (report section 2)

These rules describe Meow Airline's data and booking process. “Database” means the rule is enforced by a key, constraint, or trigger in `db/schema.sql`; “backend” means the Express controller checks it before accepting a change.

| ID | Business rule | Enforcement |
|---|---|---|
| BR1 | Each route has exactly one origin airport. | Database: `ROUTE.OriginCode` is a non-null FK to `AIRPORT`. |
| BR2 | Each route has exactly one destination airport. | Database: `ROUTE.DestinationCode` is a non-null FK to `AIRPORT`. |
| BR3 | Each scheduled flight uses exactly one aircraft. | Database: non-null `FLIGHT.AircraftID` FK. |
| BR4 | Each seat belongs to exactly one aircraft; an aircraft may have many seats. | Database: non-null `SEAT.AircraftID` FK and per-aircraft seat number uniqueness. |
| BR5 | Each reservation is made by one passenger; a passenger may make many reservations. | Database: non-null `RESERVATION.PassengerID` FK. |
| BR6 | A reservation can cover multiple flights, and a flight can appear in multiple reservations. Each reservation-flight traveller-seat assignment is stored as a ticket. | Database: `TICKET` links reservation, traveller, flight, seat, and fare. |
| BR7 | A route's origin and destination must be different airports. | Database: `ROUTE_Airports_CK`; the database also requires both airport codes to exist. |
| BR8 | Tickets may be issued only after the reservation has received enough payment to cover all active ticket fares. | Backend: ticket issue controller totals non-refunded payments against the reservation's active fare total. |
| BR9 | A ticket may have no baggage records or several baggage records. | Database: `BAGGAGE` rows are optional children of a ticket. |
| BR10 | A seat may be assigned to at most one live ticket on a flight. Cancelled tickets release the seat. | Database: unique generated `ActiveSeat` key; booking returns a friendly conflict for duplicate seats. |
| BR11 | An aircraft cannot have more seat records than its `TotalSeat`. | Backend: seat creation locks the aircraft row and checks the current count; aircraft capacity cannot be reduced below the seat count. |
| BR12 | Total baggage per ticket is limited by cabin class: Economy 20 kg, Business 30 kg, FirstClass 40 kg. | Backend: baggage controller checks the class limit. Database also rejects an individual bag above 32 kg. |
| BR13 | Only an issued ticket for a flight that has not departed can be checked in, and a ticket can be checked in once. | Backend: check-in controller checks status and departure time; database unique key on `CHECKIN.TicketID` prevents repeat check-in. |
| BR14 | Every staff member is exactly one of BookingStaff or CheckInStaff. | Database: role discriminator and subtype composite foreign keys/checks enforce disjointness; backend creates the supertype and exactly one subtype in a transaction. |
| BR15 | Every fare belongs to one flight; each ticket's fare must belong to that same flight. | Database: fare-to-flight FK and composite `TICKET_FARE_FK`. |
| BR16 | A BookingStaff member may create many reservations. A reservation may record one BookingStaff member, or `NULL` when booked online or when that staff member leaves. | Database: nullable `RESERVATION.BookingStaffID` FK to `BOOKINGSTAFF`. |
| BR17 | A CheckInStaff member may process many check-ins. A check-in may record one processing staff member, or `NULL` for self check-in or after that staff member leaves. | Database: nullable `CHECKIN.CheckInStaffID` FK to `CHECKINSTAFF`. |
| BR18 | Each ticket names exactly one travelling passenger. A passenger may hold at most one live ticket on a given flight. | Database: `TICKET.PassengerID` FK and unique generated `ActiveSeat` key by flight and passenger. |
| BR19 | A fare may include multiple conditions, and each condition may apply to multiple fares. Each fare-condition pairing records its own non-negative fee. | Database: `FARE_RULE` bridge, composite primary key, foreign keys, and fee check. |

For BR8, payments are stored as ledger entries. A refund is recorded as a separate `PAYMENT` row with status `Refunded`; it offsets the paid amount and preserves the transaction history. Report income is defined as the fare price of each non-cancelled ticket, grouped by route, rather than allocating reservation payments among flights.
