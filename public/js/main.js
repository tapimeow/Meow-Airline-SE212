/* [Phase 5 · Frontend · Kornnaphat] Browser interface for the JSON API. */
(() => {
  const app = document.getElementById('app');
  const notice = document.getElementById('notice');
  const cash = (v) => `${Number(v || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} THB`;
  const esc = (v) => String(v ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const dt = (v) => v ? new Intl.DateTimeFormat('en-GB', { dateStyle: 'medium', timeStyle: 'short', timeZone: 'Asia/Bangkok' }).format(new Date(v)) : '—';
  const dateOnly = (v) => v ? new Intl.DateTimeFormat('en-GB', { dateStyle: 'medium', timeZone: 'Asia/Bangkok' }).format(new Date(v)) : '—';
  const qs = (obj) => new URLSearchParams(Object.entries(obj).filter(([, v]) => v !== '' && v != null)).toString();
  const api = async (url, options = {}) => {
    const response = await fetch(url, { ...options, headers: { ...(options.body ? { 'Content-Type': 'application/json' } : {}), ...options.headers } });
    const type = response.headers.get('content-type') || '';
    const data = type.includes('application/json') ? await response.json() : await response.text();
    if (!response.ok) throw new Error(data?.error || data || `Request failed (${response.status})`);
    return data;
  };
  const post = (url, body = {}) => api(url, { method: 'POST', body: JSON.stringify(body) });
  const notify = (message, bad = false) => { notice.hidden = false; notice.textContent = message; notice.className = `notice ${bad ? 'notice-error' : 'notice-success'}`; window.scrollTo({ top: 0, behavior: 'smooth' }); };
  const fail = (e) => notify(e.message || 'Something went wrong. Please try again.', true);
  const heading = (eyebrow, title, action = '') => `<header class="page-head"><div><p class="eyebrow">${esc(eyebrow)}</p><h1>${esc(title)}</h1></div>${action}</header>`;
  const empty = (title, detail = '') => `<div class="empty-card"><strong>${esc(title)}</strong><span>${esc(detail)}</span></div>`;
  const table = (rows, cols, emptyText = 'No records to show yet.') => !rows?.length ? empty(emptyText) : `<div class="table-card report-table-wrap"><table class="data-table"><thead><tr>${cols.map(c => `<th>${esc(c.label)}</th>`).join('')}</tr></thead><tbody>${rows.map(row => `<tr>${cols.map(c => `<td data-label="${esc(c.label)}">${c.render ? c.render(row) : esc(row[c.key])}</td>`).join('')}</tr>`).join('')}</tbody></table></div>`;
  const button = (label, attrs = '') => `<button class="btn" ${attrs}>${esc(label)}</button>`;
  const selectOptions = (rows, value, label, selected = '') => (rows || []).map(r => `<option value="${esc(r[value])}" ${String(r[value]) === String(selected) ? 'selected' : ''}>${esc(typeof label === 'function' ? label(r) : r[label])}</option>`).join('');
  const formField = (label, name, type = 'text', value = '', required = true, extra = '') => `<label>${esc(label)}<input name="${esc(name)}" type="${esc(type)}" value="${esc(value)}" ${required ? 'required' : ''} ${extra}></label>`;
  const moneyBadge = (n) => `<span class="badge">${cash(n)}</span>`;

  function setNav(view) {
    document.querySelectorAll('[data-view]').forEach(a => a.classList.toggle('is-active', a.dataset.view === view));
    document.querySelector('.app-nav')?.classList.remove('nav-open');
    document.querySelector('.menu-toggle')?.setAttribute('aria-expanded', 'false');
  }
  function go(view) { if (location.hash === `#${view}`) render(); else location.hash = view; }
  function pageError(message) { app.innerHTML = `${heading('Something needs attention', 'Could not load this page')}<p class="error-message">${esc(message)}</p><button class="btn btn-quiet" data-action="reload">Try again</button>`; }

  async function home() {
    const [passengers, flights, reservations, reports] = await Promise.all([
      api('/passengers').catch(() => []), api('/flights').catch(() => []), api('/reservations').catch(() => []), api('/reports').catch(() => ({})),
    ]);
    app.innerHTML = `<section class="welcome-panel"><div><p class="eyebrow">Your regional airline desk</p><h1>Good day. Ready for takeoff?</h1><p>Keep bookings, flight operations and passenger reports together in one place.</p><a class="btn" href="#booking" data-view="booking">Create a booking</a></div><div class="welcome-stamp" aria-hidden="true"><svg viewBox="0 0 120 120"><path d="M16 68 103 27 79 104 57 76 16 68Z"/><path d="m57 76 46-49"/></svg></div></section>
      <section class="stats-grid" aria-label="Current records"><article class="stat-card"><span>Passengers</span><strong>${passengers.length}</strong><a href="#passengers" data-view="passengers">View passengers</a></article><article class="stat-card stat-blue"><span>Scheduled flights</span><strong>${flights.length}</strong><a href="#flights" data-view="flights">View flights</a></article><article class="stat-card stat-pink"><span>Reservations</span><strong>${reservations.length}</strong><a href="#reservations" data-view="reservations">Manage bookings</a></article></section>
      <section class="section-block"><div class="section-title"><div><p class="eyebrow">Tools for today</p><h2>Operations shortcuts</h2></div></div><div class="shortcut-grid"><a href="#flights" data-view="flights"><span>01</span><strong>Find a flight</strong><small>Schedules, routes and fares</small></a><a href="#checkin" data-view="checkin"><span>02</span><strong>Check in</strong><small>Find a ticket and issue boarding pass</small></a><a href="#reports" data-view="reports"><span>03</span><strong>View reports</strong><small>Seats, bookings and route income</small></a></div></section>`;
  }

  async function passengers() {
    const rows = await api('/passengers');
    app.innerHTML = `${heading('Customer records', 'Passengers', '<a class="btn" href="/passengers/new">Add passenger</a>')}<p class="page-intro">Passenger details are managed in the existing CRUD page.</p>${table(rows, [
      { label: 'Name', key: 'Name' }, { label: 'Passport', key: 'PassportNo' }, { label: 'Phone', key: 'PhoneNo' }, { label: 'Email', key: 'Email' }, { label: 'Membership', render: r => `<span class="badge ${r.MembershipStatus === 'Gold' ? 'badge-gold' : ''}">${esc(r.MembershipStatus)}</span>` },
      { label: 'Actions', render: r => `<a href="/passengers/${Number(r.PassengerID)}/edit">Edit record</a>` },
    ], 'No passengers found.')}`;
  }

  async function flights() {
    const params = new URLSearchParams(location.hash.split('?')[1] || '');
    const filters = { origin: params.get('origin') || '', destination: params.get('destination') || '', date: params.get('date') || '' };
    const [rows, airports] = await Promise.all([api(`/flights?${qs(filters)}`), api('/airports')]);
    app.innerHTML = `${heading('Schedules & routes', 'Flights', '<span class="action-row"><a class="btn btn-quiet" href="#airports" data-view="airports">Manage routes</a><button class="btn" data-action="show-flight-form">+ Add flight</button></span>')}<div id="flight-form-slot"></div>
      <form class="filter-form" data-form="flight-filter"><label>Origin<select name="origin"><option value="">All airports</option>${selectOptions(airports, 'AirportCode', r => `${r.AirportCode} · ${r.City}`, filters.origin)}</select></label><label>Destination<select name="destination"><option value="">All airports</option>${selectOptions(airports, 'AirportCode', r => `${r.AirportCode} · ${r.City}`, filters.destination)}</select></label>${formField('Departure date', 'date', 'date', filters.date, false)}<button class="btn" type="submit">Find flights</button></form>
      <section class="flight-grid">${rows.map(f => `<article class="flight-card"><div class="flight-route"><span>${esc(f.OriginCode)}</span><i aria-hidden="true">→</i><span>${esc(f.DestinationCode)}</span></div><p>${esc(f.FlightNo)} <span class="status-pill">${esc(f.Status)}</span></p><p class="muted">${dt(f.DepartureTime)}</p><p class="muted">Arrives ${dt(f.ArrivalTime)} · Gate ${esc(f.Gate || 'TBA')}</p><span class="action-row"><button class="btn btn-sm" data-action="start-booking" data-flight="${Number(f.FlightID)}">Book this flight</button><button class="btn btn-sm btn-quiet" data-action="manage-fares" data-id="${Number(f.FlightID)}">Fares</button><button class="btn btn-sm btn-quiet" data-action="edit-flight" data-id="${Number(f.FlightID)}">Edit</button><button class="btn btn-sm btn-danger" data-action="delete-flight" data-id="${Number(f.FlightID)}">Delete</button></span></article>`).join('') || empty('No flights match those filters.', 'Try another date or route.')}</section>`;
  }

  async function flightForm(id = '') {
    const [routes, aircraft] = await Promise.all([api('/routes'), api('/aircraft')]);
    const f = id ? (await api(`/flights/${id}`)).flight : {};
    document.getElementById('flight-form-slot').innerHTML = `<form class="stacked-form compact-form admin-inline-form" data-form="flight-save" data-id="${id ? Number(id) : ''}"><h2>${id ? 'Edit flight' : 'Schedule a flight'}</h2><label>Flight number<select name="FlightNo" required ${id ? 'disabled' : ''}><option value="">Choose route</option>${selectOptions(routes, 'FlightNo', r => `${r.FlightNo} · ${r.OriginCode} → ${r.DestinationCode}`, f.FlightNo)}</select></label><label>Aircraft<select name="AircraftID" required><option value="">Choose aircraft</option>${selectOptions(aircraft, 'AircraftID', r => `${r.AircraftModel} · #${r.AircraftID}`, f.AircraftID)}</select></label>${formField('Departure', 'DepartureTime', 'datetime-local', f.DepartureTime ? String(f.DepartureTime).replace(' ', 'T').slice(0,16) : '')}${formField('Arrival', 'ArrivalTime', 'datetime-local', f.ArrivalTime ? String(f.ArrivalTime).replace(' ', 'T').slice(0,16) : '')}<label>Status<select name="Status">${['OnTime', 'Delayed', 'Cancelled'].map(s => `<option ${f.Status === s ? 'selected' : ''}>${s}</option>`).join('')}</select></label>${formField('Gate', 'Gate', 'text', f.Gate || '', false)}<span class="form-actions"><button class="btn">Save flight</button><button class="btn btn-quiet" type="button" data-action="close-flight-form">Close</button></span></form>`;
  }

  async function fares(flightId) {
    const [flight, rows] = await Promise.all([api(`/flights/${flightId}`), api(`/flights/${flightId}/fares`)]);
    const unique = [...new Map(rows.map(r => [r.FareID, r])).values()];
    app.innerHTML = `${heading(`Flight ${esc(flight.flight.FlightNo)}`, 'Fare options', '<a href="#flights" data-view="flights">Back to flights</a>')}<p class="page-intro">Fare rules determine the ticket price and booking conditions.</p><form class="filter-form" data-form="fare-create" data-flight="${Number(flightId)}"><label>Cabin class<select name="Class"><option>Economy</option><option>Business</option><option>FirstClass</option></select></label>${formField('Price (THB)', 'Price', 'number', '', true, 'min="0.01" step="0.01"')}<button class="btn">Add fare</button></form>${table(unique, [{ label: 'Class', key: 'Class' }, { label: 'Price', render: r => cash(r.Price) }, { label: 'Conditions', render: r => rows.filter(x => x.FareID === r.FareID && x.ConditionName).map(x => `${esc(x.ConditionName)}${Number(x.Fee) ? ` · ${cash(x.Fee)}` : ''}`).join(', ') || 'No additional conditions' }, { label: 'Remove', render: r => `<button class="btn btn-sm btn-danger" data-action="delete-fare" data-id="${Number(r.FareID)}" data-flight="${Number(flightId)}">Remove</button>` }], 'No fares configured.')}`;
  }

  async function booking(flightId = '') {
    const [ps, fs, staff] = await Promise.all([api('/passengers'), api('/flights'), api('/staff')]);
    app.innerHTML = `${heading('New reservation', 'Build a booking', '<a href="#flights" data-view="flights">Back to flights</a>')}<p class="page-intro">Choose the booker, then add a ticket for every traveller. Each ticket needs a flight, cabin fare and seat.</p>
      <form class="stacked-form booking-form" data-form="booking"><label>Booked by<select name="PassengerID" required><option value="">Choose passenger</option>${selectOptions(ps, 'PassengerID', p => `${p.Name} · ${p.PassportNo}`)}</select></label>
      <label>Booking staff (optional)<select name="BookingStaffID"><option value="">Online booking</option>${selectOptions(staff.filter(s => s.StaffRole === 'BookingStaff'), 'StaffID', 'StaffName')}</select></label>
      <div class="section-title"><h2>Travellers and tickets</h2><button type="button" class="btn btn-quiet btn-sm" data-action="add-ticket">+ Add traveller</button></div>
      <div class="ticket-builders"><div class="ticket-builder" data-ticket-row><label>Traveller<select data-field="PassengerID" required><option value="">Choose passenger</option>${selectOptions(ps, 'PassengerID', p => `${p.Name} · ${p.PassportNo}`)}</select></label><label>Flight<select data-field="FlightID" required><option value="">Choose flight</option>${selectOptions(fs, 'FlightID', f => `${f.FlightNo} · ${f.OriginCode} → ${f.DestinationCode} · ${dt(f.DepartureTime)}`, flightId)}</select></label><label>Fare<select data-field="FareID" required><option value="">Choose flight first</option></select></label><label>Seat<select data-field="SeatID" required><option value="">Choose flight first</option></select></label></div></div>
      <div class="form-actions"><button class="btn" type="submit">Create reservation</button><a class="btn btn-quiet" href="#reservations" data-view="reservations">Cancel</a></div></form>`;
    if (flightId) await hydrateTicketRow(app.querySelector('[data-ticket-row]'));
  }

  async function hydrateTicketRow(row) {
    const flightId = row.querySelector('[data-field="FlightID"]').value;
    const fare = row.querySelector('[data-field="FareID"]'); const seat = row.querySelector('[data-field="SeatID"]');
    fare.innerHTML = '<option value="">Loading fares…</option>'; seat.innerHTML = '<option value="">Loading seats…</option>';
    if (!flightId) { fare.innerHTML = '<option value="">Choose flight first</option>'; seat.innerHTML = '<option value="">Choose flight first</option>'; return; }
    try {
      const [detail, fareRows] = await Promise.all([api(`/flights/${flightId}`), api(`/flights/${flightId}/fares`)]);
      const aircraftDetail = await api(`/aircraft/${detail.flight.AircraftID}`);
      const aircraft = aircraftDetail.aircraft ? aircraftDetail : { aircraft: aircraftDetail, seats: aircraftDetail.seats || [] };
      const fares = [...new Map(fareRows.map(r => [r.FareID, r])).values()];
      fare.innerHTML = `<option value="">Choose fare</option>${fares.map(f => `<option data-class="${esc(f.Class)}" value="${Number(f.FareID)}">${esc(f.Class)} · ${cash(f.Price)}</option>`).join('')}`;
      seat.innerHTML = `<option value="">Choose a seat · availability checked on save</option>${aircraft.seats.map(s => `<option data-class="${esc(s.SeatClass)}" value="${Number(s.SeatID)}">${esc(s.SeatNo)} · ${esc(s.SeatClass)}</option>`).join('')}`;
    } catch (e) { fare.innerHTML = '<option value="">Could not load fares</option>'; seat.innerHTML = '<option value="">Could not load seats</option>'; fail(e); }
  }

  async function reservations() {
    const [rows, ps] = await Promise.all([api('/reservations'), api('/passengers')]);
    app.innerHTML = `${heading('Passenger journeys', 'Reservations', '<button class="btn" data-action="new-booking">+ New booking</button>')}<form class="filter-form" data-form="reservation-filter"><label>Passenger<select name="passengerId"><option value="">All passengers</option>${selectOptions(ps, 'PassengerID', p => `${p.Name} · ${p.PassportNo}`)}</select></label><label>Status<select name="status"><option value="">All statuses</option>${['Held', 'Confirmed', 'Cancelled'].map(x => `<option>${x}</option>`).join('')}</select></label><button class="btn btn-quiet" type="submit">Apply filter</button></form>${table(rows, [
      { label: 'Reservation', render: r => `<a href="#reservation/${Number(r.ReservationID)}">#${Number(r.ReservationID)}</a>` }, { label: 'Passenger', key: 'PassengerName' }, { label: 'Booked', render: r => dateOnly(r.BookingDate) }, { label: 'Status', render: r => `<span class="status-pill">${esc(r.ReservationStatus)}</span>` }, { label: 'Open', render: r => `<button class="btn btn-sm btn-quiet" data-action="open-reservation" data-id="${Number(r.ReservationID)}">Details</button>` },
    ], 'No reservations found.')}`;
  }

  async function reservationDetail(id) {
    const { reservation: r, tickets, payments } = await api(`/reservations/${id}`);
    const amountDue = tickets.filter(t => t.TicketStatus !== 'cancelled').reduce((sum, t) => sum + Number(t.Price || 0), 0);
    const paid = payments.reduce((sum, p) => sum + (p.Status === 'Paid' ? Number(p.TotalAmount) : -Number(p.TotalAmount)), 0);
    app.innerHTML = `${heading(`Reservation #${Number(id)}`, esc(r.PassengerName), '<a href="#reservations" data-view="reservations">All reservations</a>')}<section class="summary-grid"><article class="summary-card"><span>Status</span><strong>${esc(r.ReservationStatus)}</strong></article><article class="summary-card"><span>Fare total</span><strong>${cash(amountDue)}</strong></article><article class="summary-card"><span>Net paid</span><strong>${cash(paid)}</strong></article><article class="summary-card"><span>Balance</span><strong>${cash(Math.max(0, amountDue - paid))}</strong></article></section>
      <div class="section-title"><div><p class="eyebrow">Travellers</p><h2>Tickets</h2></div></div>${table(tickets, [
        { label: 'Ticket', render: t => `#${Number(t.TicketID)}` }, { label: 'Traveller', key: 'TravellerName' }, { label: 'Flight', render: t => `Flight #${Number(t.FlightID)}` }, { label: 'Seat', key: 'SeatNo' }, { label: 'Fare', render: t => cash(t.Price) }, { label: 'Status', key: 'TicketStatus' }, { label: 'Actions', render: t => `<span class="action-row">${t.TicketStatus === 'booked' ? `<button class="btn btn-sm" data-action="issue-ticket" data-id="${Number(t.TicketID)}">Issue</button>` : ''}<button class="btn btn-sm btn-quiet" data-action="ticket-baggage" data-id="${Number(t.TicketID)}">Baggage</button></span>` },
      ], 'This reservation has no tickets.')}
      <div class="section-title"><div><p class="eyebrow">Ledger</p><h2>Payments</h2></div><button class="btn btn-sm" data-action="pay-reservation" data-id="${Number(id)}" data-due="${Math.max(0, amountDue - paid).toFixed(2)}">Record payment</button></div><div id="payment-form-slot"></div>${table(payments, [{ label: 'Payment', render: p => `#${Number(p.PaymentID)}` }, { label: 'Amount', render: p => cash(p.TotalAmount) }, { label: 'Method', key: 'PaymentMethod' }, { label: 'Status', key: 'Status' }, { label: 'Time', render: p => dt(p.TimeStamp) }, { label: 'Action', render: p => p.Status === 'Paid' ? `<button class="btn btn-sm btn-quiet" data-action="refund-payment" data-id="${Number(p.PaymentID)}">Refund</button>` : '—' }], 'No payments recorded.')}
      <div class="form-actions"><button class="btn btn-danger" data-action="cancel-reservation" data-id="${Number(id)}">Cancel reservation</button></div>`;
  }

  async function reports() {
    const [fs, ps] = await Promise.all([api('/flights'), api('/passengers')]);
    app.innerHTML = `${heading('Decision support', 'Reports')}<p class="page-intro">Answer the daily questions: how many seats remain, which bookings need payment, and how routes performed.</p>
      <section class="report-grid"><article class="report-card"><span class="report-number">01 · O4</span><h2>Free seats</h2><p>See total seats, seats sold and remaining seats by class for a selected flight.</p><form class="stacked-form compact-form" data-form="report-free"><label>Flight<select name="flightId" required><option value="">Choose a flight</option>${selectOptions(fs, 'FlightID', f => `${f.FlightNo} · ${f.OriginCode} → ${f.DestinationCode} · ${dt(f.DepartureTime)}`)}</select></label><button class="btn" type="submit">Show seats</button></form></article>
      <article class="report-card"><span class="report-number">02</span><h2>Passenger bookings</h2><p>Review itinerary details, ticket status and payment balance.</p><form class="stacked-form compact-form" data-form="report-passenger"><label>Passenger<select name="passengerId" required><option value="">Choose a passenger</option>${selectOptions(ps, 'PassengerID', p => `${p.Name} · ${p.PassportNo}`)}</select></label><button class="btn" type="submit">Show bookings</button></form></article>
      <article class="report-card"><span class="report-number">03 · O3</span><h2>Route income</h2><p>Compare fare revenue and sales by route for a month.</p><form class="stacked-form compact-form" data-form="report-income"><label>Month<input name="month" type="month" value="2026-09" required></label><button class="btn" type="submit">Show income</button></form></article></section><div id="report-results" class="report-results"></div>`;
  }

  async function airports() {
    const [rows, routes] = await Promise.all([api('/airports'), api('/routes')]);
    app.innerHTML = `${heading('Network setup', 'Airports & routes')}<section class="admin-columns"><article class="admin-panel"><h2>Add airport</h2><form class="stacked-form compact-form" data-form="airport-create">${formField('Airport code (3 letters)', 'AirportCode', 'text', '', true, 'maxlength="3" pattern="[A-Z]{3}"')}${formField('City', 'City')}${formField('Country', 'Country')}<button class="btn">Save airport</button></form></article><article class="admin-panel"><h2>Route map</h2><p class="muted">Routes are keyed by flight number.</p><div class="route-chip-list">${routes.map(r => `<span class="route-chip"><strong>${esc(r.FlightNo)}</strong> ${esc(r.OriginCode)} → ${esc(r.DestinationCode)}</span>`).join('') || 'No routes yet.'}</div><form class="stacked-form compact-form" data-form="route-create"><h3>Add route</h3>${formField('Flight number', 'FlightNo') }<label>Origin<select name="OriginCode" required><option value="">Select airport</option>${selectOptions(rows, 'AirportCode', r => `${r.AirportCode} · ${r.City}`)}</select></label><label>Destination<select name="DestinationCode" required><option value="">Select airport</option>${selectOptions(rows, 'AirportCode', r => `${r.AirportCode} · ${r.City}`)}</select></label><button class="btn">Save route</button></form></article></section><h2 class="section-heading">Airport directory</h2>${table(rows, [{ label: 'Code', key: 'AirportCode' }, { label: 'City', key: 'City' }, { label: 'Country', key: 'Country' }, { label: 'Action', render: r => `<button class="btn btn-sm btn-danger" data-action="delete-airport" data-id="${esc(r.AirportCode)}">Delete</button>` }], 'No airports configured.')}`;
  }

  async function fleet() {
    const aircraft = await api('/aircraft');
    app.innerHTML = `${heading('Aircraft & seat plans', 'Fleet', '<button class="btn" data-action="show-aircraft-form">+ Add aircraft</button>')}<div id="aircraft-form-slot"></div><section class="fleet-grid">${aircraft.map(a => `<article class="fleet-card"><div class="fleet-card-head"><div><p class="eyebrow">Aircraft ${Number(a.AircraftID)}</p><h2>${esc(a.AircraftModel)}</h2></div><span class="badge">${Number(a.TotalSeat)} seats</span></div><button class="btn btn-sm btn-quiet" data-action="aircraft-detail" data-id="${Number(a.AircraftID)}">Seat plan & details</button></article>`).join('') || empty('No aircraft registered.')}</section>`;
  }

  async function aircraftDetail(id) {
    const { aircraft: a, seats } = await api(`/aircraft/${id}`);
    app.innerHTML = `${heading(`Aircraft ${Number(id)}`, esc(a.AircraftModel), '<a href="#fleet" data-view="fleet">Back to fleet</a>')}<section class="summary-grid"><article class="summary-card"><span>Configured seats</span><strong>${seats.length} / ${Number(a.TotalSeat)}</strong></article><article class="summary-card"><span>Model</span><strong>${esc(a.AircraftModel)}</strong></article></section><div class="section-title"><div><p class="eyebrow">Seat map</p><h2>Seats</h2></div><button class="btn" data-action="show-seat-form" data-id="${Number(id)}">+ Add seat</button></div><div id="seat-form-slot"></div>${table(seats, [{ label: 'Seat', key: 'SeatNo' }, { label: 'Class', key: 'SeatClass' }, { label: 'Remove', render: s => `<button class="btn btn-sm btn-danger" data-action="delete-seat" data-id="${Number(s.SeatID)}" data-aircraft="${Number(id)}">Remove</button>` }], 'No seats defined.')}`;
  }

  async function staff() {
    const rows = await api('/staff');
    app.innerHTML = `${heading('Team & counters', 'Staff', '<button class="btn" data-action="show-staff-form">+ Add staff member</button>')}<div id="staff-form-slot"></div>${table(rows, [{ label: 'Name', key: 'StaffName' }, { label: 'Role', key: 'StaffRole' }, { label: 'Office / counter', render: r => esc(r.SalesOffice || r.CounterNo || '—') }, { label: 'Remove', render: r => `<button class="btn btn-sm btn-danger" data-action="delete-staff" data-id="${Number(r.StaffID)}">Remove</button>` }], 'No staff members registered.')}`;
  }

  async function checkin() {
    const params = new URLSearchParams(location.hash.split('?')[1] || '');
    const results = params.has('reservationId') || params.has('passportNo') ? await api(`/checkin?${qs({ reservationId: params.get('reservationId'), passportNo: params.get('passportNo') })}`) : [];
    const staff = await api('/staff');
    app.innerHTML = `${heading('Departure desk', 'Check-in')}<p class="page-intro">Find a booking by reservation number or passport. Only issued tickets for future flights can check in.</p><form class="filter-form" data-form="checkin-search">${formField('Reservation number', 'reservationId', 'number', params.get('reservationId') || '', false)}${formField('Passport number', 'passportNo', 'text', params.get('passportNo') || '', false)}<button class="btn">Search tickets</button></form>${results.length ? table(results, [{ label: 'Traveller', key: 'Traveller' }, { label: 'Passport', key: 'PassportNo' }, { label: 'Flight', key: 'FlightNo' }, { label: 'Departure', render: r => dt(r.DepartureTime) }, { label: 'Seat', key: 'SeatNo' }, { label: 'Ticket', key: 'TicketStatus' }, { label: 'Check-in', render: r => r.CheckInID ? `<button class="btn btn-sm btn-quiet" data-action="boarding-pass" data-id="${Number(r.CheckInID)}">Boarding pass</button>` : r.TicketStatus === 'issued' ? `<button class="btn btn-sm" data-action="checkin-ticket" data-id="${Number(r.TicketID)}">Check in</button>` : 'Issue ticket first' }], 'No matching tickets.') : empty('Search for a reservation or passenger.', 'Use a reservation number or passport number to find tickets.')}`;
    const form = app.querySelector('[data-form="checkin-search"]');
    form.insertAdjacentHTML('beforeend', `<label>Processed by (optional)<select name="CheckInStaffID"><option value="">Self check-in</option>${selectOptions(staff.filter(s => s.StaffRole === 'CheckInStaff'), 'StaffID', r => `${r.StaffName} · Counter ${r.CounterNo}`)}</select></label>`);
  }

  async function baggage(ticketId = '') {
    app.innerHTML = `${heading('Ticket services', 'Baggage')}<p class="page-intro">Add a bag to a ticket. Total weight is checked against the passenger’s cabin-class limit.</p><form class="filter-form" data-form="baggage-search">${formField('Ticket number', 'ticketId', 'number', ticketId, true)}<button class="btn">Find baggage</button></form><div id="baggage-results"></div>`;
    if (ticketId) await loadBaggage(ticketId);
  }
  async function loadBaggage(id) {
    const rows = await api(`/tickets/${id}/baggage`);
    const host = document.getElementById('baggage-results');
    host.innerHTML = `<form class="filter-form" data-form="baggage-create" data-ticket="${Number(id)}">${formField('Bag weight (kg)', 'Weight', 'number', '', true, 'min="0.1" step="0.1"')}<button class="btn">Add bag</button></form>${table(rows, [{ label: 'Bag', render: r => `#${Number(r.BaggageID)}` }, { label: 'Weight', render: r => `${Number(r.Weight).toFixed(2)} kg` }, { label: 'Status', key: 'BaggageStatus' }, { label: 'Remove', render: r => `<button class="btn btn-sm btn-danger" data-action="delete-baggage" data-id="${Number(r.BaggageID)}" data-ticket="${Number(id)}">Remove</button>` }], 'No bags added.')}`;
  }

  async function render() {
    notice.hidden = true;
    const hash = location.hash.slice(1) || 'home';
    const [view, id] = hash.split('?')[0].split('/');
    setNav(view);
    try {
      if (view === 'home') await home();
      else if (view === 'passengers') await passengers();
      else if (view === 'flights') await flights();
      else if (view === 'fares' && id) await fares(id);
      else if (view === 'reservations') await reservations();
      else if (view === 'reservation' && id) await reservationDetail(id);
      else if (view === 'booking') await booking(new URLSearchParams(hash.split('?')[1] || '').get('flightId') || '');
      else if (view === 'reports') await reports();
      else if (view === 'airports') await airports();
      else if (view === 'fleet') await fleet();
      else if (view === 'aircraft' && id) await aircraftDetail(id);
      else if (view === 'staff') await staff();
      else if (view === 'checkin') await checkin();
      else if (view === 'baggage') await baggage(new URLSearchParams(hash.split('?')[1] || '').get('ticketId') || '');
      else pageError('This area is not available.');
    } catch (e) { pageError(e.message); }
  }

  document.addEventListener('click', async (event) => {
    const link = event.target.closest('[data-view]');
    if (link && link.tagName !== 'A') { event.preventDefault(); go(link.dataset.view); }
    const action = event.target.closest('[data-action]'); if (!action) return;
    const id = action.dataset.id;
    try {
      switch (action.dataset.action) {
        case 'reload': render(); break;
        case 'new-booking': go('booking'); break;
        case 'show-flight-form': await flightForm(); break;
        case 'edit-flight': await flightForm(id); break;
        case 'close-flight-form': document.getElementById('flight-form-slot').innerHTML = ''; break;
        case 'manage-fares': location.hash = `fares/${id}`; break;
        case 'delete-flight': if (confirm('Delete this flight? Tickets may prevent deletion.')) { await api(`/flights/${id}/delete`, { method: 'POST' }); notify('Flight deleted.'); await flights(); } break;
        case 'delete-fare': if (confirm('Delete this fare? Existing tickets may prevent deletion.')) { await api(`/fares/${id}/delete`, { method: 'POST' }); notify('Fare deleted.'); await fares(action.dataset.flight); } break;
        case 'start-booking': location.hash = `booking?flightId=${encodeURIComponent(action.dataset.flight)}`; break;
        case 'open-reservation': location.hash = `reservation/${id}`; break;
        case 'add-ticket': {
          const first = app.querySelector('[data-ticket-row]'); const clone = first.cloneNode(true);
          clone.querySelectorAll('select').forEach(s => { s.selectedIndex = 0; });
          clone.insertAdjacentHTML('beforeend', '<button type="button" class="text-button" data-action="remove-ticket">Remove traveller</button>');
          first.parentElement.appendChild(clone); break;
        }
        case 'remove-ticket': action.closest('[data-ticket-row]').remove(); break;
        case 'issue-ticket': await post(`/tickets/${id}/issue`); notify('Ticket issued.'); await reservationDetail(location.hash.split('/')[1]); break;
        case 'pay-reservation': {
          const slot = document.getElementById('payment-form-slot');
          slot.innerHTML = `<form class="filter-form" data-form="payment-create" data-reservation="${Number(id)}">${formField('Amount (THB)', 'TotalAmount', 'number', action.dataset.due || '', true, 'min="0.01" step="0.01"')}<label>Method<select name="PaymentMethod"><option>QR</option><option>Card</option><option>BankTransfer</option><option>Cash</option></select></label><button class="btn">Record payment</button></form>`;
          slot.scrollIntoView({ behavior: 'smooth', block: 'center' }); break;
        }
        case 'refund-payment': if (confirm('Record a refund for this payment?')) { await post(`/payments/${id}/refund`); notify('Refund recorded.'); await render(); } break;
        case 'cancel-reservation': if (confirm('Cancel this reservation and its active tickets?')) { await post(`/reservations/${id}/cancel`); notify('Reservation cancelled.'); await render(); } break;
        case 'checkin-ticket': {
          const staffId = app.querySelector('[name="CheckInStaffID"]')?.value || null;
          const result = await post(`/checkin/${id}`, { CheckInStaffID: staffId }); notify(`Checked in. Boarding pass ${result.BoardingPassNo}.`); await render(); break;
        }
        case 'boarding-pass': {
          const p = await api(`/checkin/${id}/boarding-pass`);
          app.innerHTML = `${heading('Boarding pass', `Pass ${esc(p.BoardingPassNo)}`, '<a href="#checkin" data-view="checkin">Back to check-in</a>')}<article class="boarding-pass"><div><p class="eyebrow">Meow Airline · ${esc(p.FlightNo)}</p><h2>${esc(p.OriginCode)} <span>→</span> ${esc(p.DestinationCode)}</h2><p>${esc(p.Traveller)}</p></div><dl><div><dt>Departure</dt><dd>${dt(p.DepartureTime)}</dd></div><div><dt>Gate</dt><dd>${esc(p.Gate || 'To be announced')}</dd></div><div><dt>Seat</dt><dd>${esc(p.SeatNo)} · ${esc(p.SeatClass)}</dd></div><div><dt>Boarding pass</dt><dd>${esc(p.BoardingPassNo)}</dd></div></dl></article>`; break;
        }
        case 'ticket-baggage': location.hash = `baggage?ticketId=${id}`; break;
        case 'aircraft-detail': location.hash = `aircraft/${id}`; break;
        case 'show-aircraft-form': document.getElementById('aircraft-form-slot').innerHTML = `<form class="stacked-form compact-form" data-form="aircraft-create"><h2>New aircraft</h2>${formField('Aircraft model', 'AircraftModel')}${formField('Seat capacity', 'TotalSeat', 'number', '', true, 'min="1"')}<button class="btn">Save aircraft</button></form>`; break;
        case 'show-seat-form': document.getElementById('seat-form-slot').innerHTML = `<form class="filter-form" data-form="seat-create" data-aircraft="${id}">${formField('Seat number', 'SeatNo')}<label>Cabin class<select name="SeatClass"><option>Economy</option><option>Business</option><option>FirstClass</option></select></label><button class="btn">Add seat</button></form>`; break;
        case 'show-staff-form': document.getElementById('staff-form-slot').innerHTML = `<form class="filter-form" data-form="staff-create">${formField('Name', 'StaffName')}<label>Role<select name="StaffRole"><option value="BookingStaff">Booking staff</option><option value="CheckInStaff">Check-in staff</option></select></label>${formField('Sales office (booking staff)', 'SalesOffice', 'text', '', false)}${formField('Counter number (check-in staff)', 'CounterNo', 'text', '', false)}<button class="btn">Save staff member</button></form>`; break;
        case 'delete-airport': if (confirm(`Delete airport ${id}?`)) { await api(`/airports/${encodeURIComponent(id)}/delete`, { method: 'POST' }); notify('Airport deleted.'); await render(); } break;
        case 'delete-seat': if (confirm('Remove this seat?')) { await api(`/seats/${id}/delete`, { method: 'POST' }); notify('Seat removed.'); await aircraftDetail(action.dataset.aircraft); } break;
        case 'delete-staff': if (confirm('Remove this staff member?')) { await api(`/staff/${id}/delete`, { method: 'POST' }); notify('Staff member removed.'); await staff(); } break;
        case 'delete-baggage': if (confirm('Remove this bag?')) { await api(`/baggage/${id}/delete`, { method: 'POST' }); notify('Baggage removed.'); await loadBaggage(action.dataset.ticket); } break;
      }
    } catch (e) { fail(e); }
  });

  document.addEventListener('change', async (event) => {
    if (event.target.matches('[data-field="FlightID"]')) await hydrateTicketRow(event.target.closest('[data-ticket-row]'));
    if (event.target.matches('[data-field="FareID"], [data-field="SeatID"]')) {
      const row = event.target.closest('[data-ticket-row]');
      const fare = row.querySelector('[data-field="FareID"]'); const seat = row.querySelector('[data-field="SeatID"]');
      const selected = event.target.matches('[data-field="FareID"]') ? fare : seat;
      const counterpart = selected === fare ? seat : fare;
      const selectedClass = selected.selectedOptions[0]?.dataset.class;
      if (selectedClass) {
        [...counterpart.options].forEach(option => { option.hidden = Boolean(option.value) && option.dataset.class !== selectedClass; });
        if (counterpart.selectedOptions[0]?.dataset.class && counterpart.selectedOptions[0].dataset.class !== selectedClass) counterpart.value = '';
      } else [...counterpart.options].forEach(option => { option.hidden = false; });
    }
    if (event.target.matches('[name="StaffRole"]')) {
      const form = event.target.closest('form'); const booking = event.target.value === 'BookingStaff';
      form.querySelector('[name="SalesOffice"]').required = booking; form.querySelector('[name="CounterNo"]').required = !booking;
    }
  });

  document.addEventListener('submit', async (event) => {
    const form = event.target.closest('[data-form]'); if (!form) return;
    event.preventDefault(); const data = Object.fromEntries(new FormData(form).entries());
    try {
      switch (form.dataset.form) {
        case 'flight-filter': location.hash = `flights?${qs(data)}`; await render(); break;
        case 'reservation-filter': {
          const rows = await api(`/reservations?${qs(data)}`);
          app.innerHTML = `${heading('Passenger journeys', 'Reservations', '<button class="btn" data-action="new-booking">+ New booking</button>')}${table(rows, [{ label: 'Reservation', render: r => `<a href="#reservation/${Number(r.ReservationID)}">#${Number(r.ReservationID)}</a>` }, { label: 'Passenger', key: 'PassengerName' }, { label: 'Booked', render: r => dateOnly(r.BookingDate) }, { label: 'Status', key: 'ReservationStatus' }, { label: 'Open', render: r => `<button class="btn btn-sm btn-quiet" data-action="open-reservation" data-id="${Number(r.ReservationID)}">Details</button>` }])}`; break;
        }
        case 'booking': {
          const tickets = [...app.querySelectorAll('[data-ticket-row]')].map(row => ({ PassengerID: row.querySelector('[data-field="PassengerID"]').value, FlightID: row.querySelector('[data-field="FlightID"]').value, FareID: row.querySelector('[data-field="FareID"]').value, SeatID: row.querySelector('[data-field="SeatID"]').value }));
          const result = await post('/reservations', { PassengerID: data.PassengerID, BookingStaffID: data.BookingStaffID || null, Tickets: tickets }); notify(`Reservation #${result.ReservationID} created.`); location.hash = `reservation/${result.ReservationID}`; break;
        }
        case 'flight-save': {
          const payload = { ...data, AircraftID: Number(data.AircraftID) };
          for (const field of ['DepartureTime', 'ArrivalTime']) if (payload[field]) payload[field] = `${payload[field].replace('T', ' ')}:00`;
          if (form.dataset.id) { await post(`/flights/${form.dataset.id}`, payload); notify('Flight updated.'); }
          else { await post('/flights', payload); notify('Flight scheduled.'); }
          await flights(); break;
        }
        case 'fare-create': await post(`/flights/${form.dataset.flight}/fares`, { Class: data.Class, Price: Number(data.Price) }); notify('Fare added.'); await fares(form.dataset.flight); break;
        case 'payment-create': await post(`/reservations/${form.dataset.reservation}/payments`, { TotalAmount: Number(data.TotalAmount), PaymentMethod: data.PaymentMethod }); notify('Payment recorded.'); await reservationDetail(form.dataset.reservation); break;
        case 'report-free': {
          const rows = await api(`/reports/free-seats?flightId=${encodeURIComponent(data.flightId)}`); document.getElementById('report-results').innerHTML = `${heading('Availability', 'Free seats by class')}${table(rows, [{ label: 'Cabin class', key: 'SeatClass' }, { label: 'Total', key: 'total_seats' }, { label: 'Sold', key: 'sold' }, { label: 'Free', render: r => `<strong>${Number(r.free)}</strong>` }], 'No seats reported.')}`; break;
        }
        case 'report-passenger': {
          const rows = await api(`/reports/passenger-bookings?passengerId=${encodeURIComponent(data.passengerId)}`); document.getElementById('report-results').innerHTML = `${heading('Passenger activity', 'Bookings and payment status')}${table(rows, [{ label: 'Reservation', render: r => `#${Number(r.ReservationID)} · ${esc(r.ReservationStatus)}` }, { label: 'Flight', key: 'FlightNo' }, { label: 'Route', render: r => r.OriginCode ? `${esc(r.OriginCode)} → ${esc(r.DestinationCode)}` : '—' }, { label: 'Departure', render: r => dt(r.DepartureTime) }, { label: 'Traveller', key: 'traveller' }, { label: 'Ticket', key: 'TicketStatus' }, { label: 'Payment status', render: r => `<span class="status-pill ${r.payment_status === 'Paid' ? 'status-paid' : 'status-unpaid'}">${esc(r.payment_status)}</span>` }, { label: 'Paid / due', render: r => `${cash(r.amount_paid)} / ${cash(r.total_due)}` }], 'No bookings found.')}`; break;
        }
        case 'report-income': {
          const result = await api(`/reports/route-income?month=${encodeURIComponent(data.month)}`); document.getElementById('report-results').innerHTML = `${heading(`Month ${esc(result.month)}`, 'Route income')}${result.fewestRoutes?.length ? `<p class="summary-note">Fewest seats sold: <strong>${result.fewestRoutes.map(r => `${esc(r.OriginCode)} → ${esc(r.DestinationCode)}`).join(', ')}</strong> (${Number(result.fewestSeatsSold)}).</p>` : ''}${table(result.routes, [{ label: 'Route', render: r => `${esc(r.OriginCode)} → ${esc(r.DestinationCode)}` }, { label: 'Seats sold', key: 'seats_sold' }, { label: 'Fare income', render: r => cash(r.income) }, { label: 'Sales', render: r => Number(r.seats_sold) === Number(result.fewestSeatsSold) ? '<span class="status-pill status-unpaid">Fewest sold</span>' : '—' }], 'No routes in this month.')}`; break;
        }
        case 'checkin-search': location.hash = `checkin?${qs(data)}`; await render(); break;
        case 'baggage-search': location.hash = `baggage?ticketId=${encodeURIComponent(data.ticketId)}`; await render(); break;
        case 'baggage-create': await post(`/tickets/${form.dataset.ticket}/baggage`, { Weight: data.Weight }); notify('Bag added.'); await loadBaggage(form.dataset.ticket); break;
        case 'airport-create': await post('/airports', data); notify('Airport added.'); await render(); break;
        case 'route-create': await post('/routes', data); notify('Route added.'); await render(); break;
        case 'aircraft-create': await post('/aircraft', { AircraftModel: data.AircraftModel, TotalSeat: Number(data.TotalSeat) }); notify('Aircraft added.'); await fleet(); break;
        case 'seat-create': await post(`/aircraft/${form.dataset.aircraft}/seats`, data); notify('Seat added.'); await aircraftDetail(form.dataset.aircraft); break;
        case 'staff-create': await post('/staff', data); notify('Staff member added.'); await staff(); break;
      }
    } catch (e) { fail(e); }
  });

  document.querySelector('.menu-toggle')?.addEventListener('click', (e) => {
    const nav = document.querySelector('.app-nav'); const open = nav.classList.toggle('nav-open'); e.currentTarget.setAttribute('aria-expanded', String(open));
  });
  window.addEventListener('hashchange', render);
  render();
})();
