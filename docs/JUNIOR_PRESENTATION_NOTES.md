# Kawintida / Junior: query and demo speaking notes

## Queries I own

- **Q1 — seats left:** start from seats on the aircraft for the selected flight, then `LEFT JOIN` live tickets. A missing ticket means a free seat. Group by cabin class.
- **Q2 — passenger bookings and payment:** Q2a joins the passenger, reservation, ticket, flight and route to show itinerary details. Q2b summarizes the payment ledger separately from fares, so refunds reduce the net paid amount and partial payments remain visible.
- **Q3 — route income:** count non-cancelled tickets and sum their fare prices for flights in the selected month. Q3b uses a CTE and returns every route tied for the fewest seats sold.
- **Q4 — October departures:** date range with `BETWEEN`, ordered by departure time.
- **Q5 — passenger lookup:** `LIKE` finds the Saetang family; `IS NULL` finds passengers without email.
- **Q6 — membership totals:** `GROUP BY` forms membership groups and `HAVING` keeps levels with at least three passengers.
- **Q7 — boarding list:** joins traveller and booker as separate passenger aliases, with flight, seat and reservation details.
- **Q8 / Q8b — integrity checks:** count duplicate live seat assignments and find staff without a subtype row; both should return no rows for valid seed data.
- **Q9 — bookings by booking staff:** `LEFT JOIN` keeps booking staff with zero reservations in the result.
- **Q19 — fare conditions:** joins fare rules to condition names and fees; `LEFT JOIN` also keeps a fare that has no attached condition.

## Demo sequence

1. Find a future flight and inspect its free seats by class.
2. Create one reservation for the family booker, then add one ticket per traveller with a free seat and fare in the matching class.
3. Record a payment for at least the active fare total. Issue tickets only after the reservation is fully paid.
4. Check in each issued ticket before its departure and show the boarding pass.
5. Open the three reports: free seats by class, passenger bookings/payment status, and monthly income plus the fewest-selling route.

Useful API endpoints are listed in [`ROUTES.md`](ROUTES.md). Query text and sample values are in [`../db/queries.sql`](../db/queries.sql). Use IDs returned by the live database during the demo; auto-increment IDs can change when the seed is reloaded.
