const pool = require('../config/db');

const classes = ['Economy', 'Business', 'FirstClass'];
const required = (body, keys) => keys.every((key) => String(body[key] ?? '').trim());
const nullable = (value) => String(value ?? '').trim() || null;
const dbMessage = (err) => {
  if (err.code === 'ER_DUP_ENTRY') return 'A record with those unique values already exists.';
  if (err.code === 'ER_ROW_IS_REFERENCED_2') return 'This record is still in use.';
  if (err.code === 'ER_NO_REFERENCED_ROW_2') return 'A referenced record does not exist.';
  return null;
};

// Airports
exports.airportsList = async (req, res, next) => {
  try {
    const [airports] = await pool.execute('SELECT * FROM AIRPORT ORDER BY AirportCode');
    res.render('airports/list', { title: 'Airports', airports, error: null });
  } catch (err) { next(err); }
};

exports.airportsNew = (req, res) => res.render('airports/form', {
  title: 'Add airport', airport: null, editing: false, error: null,
});

exports.airportsEdit = async (req, res, next) => {
  try {
    const [[airport]] = await pool.execute('SELECT * FROM AIRPORT WHERE AirportCode = ?', [req.params.code]);
    if (!airport) return res.status(404).send('Airport not found.');
    res.render('airports/form', { title: 'Edit airport', airport, editing: true, error: null });
  } catch (err) { next(err); }
};

exports.airportsCreate = async (req, res, next) => {
  const body = req.body;
  if (!required(body, ['AirportCode', 'City', 'Country']) || !/^[A-Z]{3}$/.test(body.AirportCode)) {
    return res.status(400).render('airports/form', { title: 'Add airport', airport: body, editing: false, error: 'Use a three-letter uppercase airport code and provide city and country.' });
  }
  try {
    await pool.execute('INSERT INTO AIRPORT (AirportCode, City, Country) VALUES (?, ?, ?)', [body.AirportCode, body.City.trim(), body.Country.trim()]);
    res.redirect('/airports');
  } catch (err) {
    const message = dbMessage(err);
    if (message) return res.status(409).render('airports/form', { title: 'Add airport', airport: body, editing: false, error: message });
    next(err);
  }
};

exports.airportsUpdate = async (req, res, next) => {
  const body = req.body;
  try {
    if (!required(body, ['City', 'Country'])) {
      return res.status(400).render('airports/form', { title: 'Edit airport', airport: { ...body, AirportCode: req.params.code }, editing: true, error: 'City and Country are required.' });
    }
    const [result] = await pool.execute('UPDATE AIRPORT SET City = ?, Country = ? WHERE AirportCode = ?', [body.City.trim(), body.Country.trim(), req.params.code]);
    if (!result.affectedRows) return res.status(404).send('Airport not found.');
    res.redirect('/airports');
  } catch (err) {
    const message = dbMessage(err);
    if (message) return res.status(409).render('airports/form', { title: 'Edit airport', airport: { ...body, AirportCode: req.params.code }, editing: true, error: message });
    next(err);
  }
};

exports.airportsRemove = async (req, res, next) => {
  try {
    const [result] = await pool.execute('DELETE FROM AIRPORT WHERE AirportCode = ?', [req.params.code]);
    if (!result.affectedRows) return res.status(404).send('Airport not found.');
    res.redirect('/airports');
  } catch (err) {
    const message = dbMessage(err);
    if (message) {
      const [airports] = await pool.execute('SELECT * FROM AIRPORT ORDER BY AirportCode');
      return res.status(409).render('airports/list', { title: 'Airports', airports, error: message });
    }
    next(err);
  }
};

// Routes have no EJS page in the agreed view contract; keep these endpoints as JSON.
exports.routesList = async (req, res, next) => {
  try {
    const [routes] = await pool.execute(`SELECT ro.*, a.City AS OriginCity, d.City AS DestinationCity
      FROM ROUTE ro JOIN AIRPORT a ON a.AirportCode = ro.OriginCode
      JOIN AIRPORT d ON d.AirportCode = ro.DestinationCode ORDER BY ro.FlightNo`);
    res.json(routes);
  } catch (err) { next(err); }
};
exports.routesCreate = async (req, res, next) => {
  const { FlightNo, OriginCode, DestinationCode } = req.body;
  if (!required(req.body, ['FlightNo', 'OriginCode', 'DestinationCode']) || OriginCode === DestinationCode) return res.status(400).json({ error: 'Provide FlightNo and two different airport codes.' });
  try {
    await pool.execute('INSERT INTO ROUTE (FlightNo, OriginCode, DestinationCode) VALUES (?, ?, ?)', [FlightNo, OriginCode, DestinationCode]);
    res.status(201).json({ FlightNo });
  } catch (err) { if (dbMessage(err)) return res.status(409).json({ error: dbMessage(err) }); next(err); }
};
exports.routesUpdate = async (req, res, next) => {
  const { OriginCode, DestinationCode } = req.body;
  if (!required(req.body, ['OriginCode', 'DestinationCode']) || OriginCode === DestinationCode) return res.status(400).json({ error: 'OriginCode and DestinationCode must be different.' });
  try {
    const [result] = await pool.execute('UPDATE ROUTE SET OriginCode = ?, DestinationCode = ? WHERE FlightNo = ?', [OriginCode, DestinationCode, req.params.flightNo]);
    if (!result.affectedRows) return res.status(404).json({ error: 'Route not found.' });
    res.json({ updated: true });
  } catch (err) { if (dbMessage(err)) return res.status(409).json({ error: dbMessage(err) }); next(err); }
};
exports.routesRemove = async (req, res, next) => {
  try {
    const [result] = await pool.execute('DELETE FROM ROUTE WHERE FlightNo = ?', [req.params.flightNo]);
    if (!result.affectedRows) return res.status(404).json({ error: 'Route not found.' });
    res.json({ deleted: true });
  } catch (err) { if (dbMessage(err)) return res.status(409).json({ error: dbMessage(err) }); next(err); }
};

// Aircraft and seats
exports.aircraftList = async (req, res, next) => {
  try {
    const [aircraft] = await pool.execute(`SELECT a.*, COUNT(s.SeatID) AS SeatCount
      FROM AIRCRAFT a LEFT JOIN SEAT s ON s.AircraftID = a.AircraftID
      GROUP BY a.AircraftID ORDER BY a.AircraftID`);
    res.render('aircraft/list', { title: 'Aircraft', aircraft, error: null });
  } catch (err) { next(err); }
};
exports.aircraftNew = (req, res) => res.render('aircraft/form', { title: 'Add aircraft', aircraft: null, editing: false, error: null });
exports.aircraftEdit = async (req, res, next) => {
  try {
    const [[aircraft]] = await pool.execute('SELECT * FROM AIRCRAFT WHERE AircraftID = ?', [req.params.id]);
    if (!aircraft) return res.status(404).send('Aircraft not found.');
    res.render('aircraft/form', { title: 'Edit aircraft', aircraft, editing: true, error: null });
  } catch (err) { next(err); }
};
exports.aircraftDetail = async (req, res, next) => {
  try {
    const [[aircraft]] = await pool.execute('SELECT * FROM AIRCRAFT WHERE AircraftID = ?', [req.params.id]);
    if (!aircraft) return res.status(404).send('Aircraft not found.');
    const [seats] = await pool.execute('SELECT * FROM SEAT WHERE AircraftID = ? ORDER BY SeatNo', [req.params.id]);
    res.render('aircraft/detail', { title: 'Seat plan', aircraft, seats, error: null });
  } catch (err) { next(err); }
};
exports.aircraftCreate = async (req, res, next) => {
  const body = req.body;
  if (!required(body, ['AircraftModel']) || !(Number(body.TotalSeat) > 0)) return res.status(400).render('aircraft/form', { title: 'Add aircraft', aircraft: body, editing: false, error: 'Aircraft model and positive seat capacity are required.' });
  try {
    await pool.execute('INSERT INTO AIRCRAFT (AircraftModel, TotalSeat) VALUES (?, ?)', [body.AircraftModel.trim(), Number(body.TotalSeat)]);
    res.redirect('/aircraft');
  } catch (err) { const message = dbMessage(err); if (message) return res.status(409).render('aircraft/form', { title: 'Add aircraft', aircraft: body, editing: false, error: message }); next(err); }
};
exports.aircraftUpdate = async (req, res, next) => {
  const body = req.body; let conn;
  if (!required(body, ['AircraftModel']) || !(Number(body.TotalSeat) > 0)) return res.status(400).render('aircraft/form', { title: 'Edit aircraft', aircraft: { ...body, AircraftID: req.params.id }, editing: true, error: 'Aircraft model and positive seat capacity are required.' });
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [[aircraft]] = await conn.execute('SELECT AircraftID FROM AIRCRAFT WHERE AircraftID = ? FOR UPDATE', [req.params.id]);
    if (!aircraft) { await conn.rollback(); return res.status(404).send('Aircraft not found.'); }
    const [[count]] = await conn.execute('SELECT COUNT(*) AS seatCount FROM SEAT WHERE AircraftID = ?', [req.params.id]);
    if (Number(body.TotalSeat) < Number(count.seatCount)) {
      await conn.rollback();
      return res.status(409).render('aircraft/form', { title: 'Edit aircraft', aircraft: { ...body, AircraftID: req.params.id }, editing: true, error: 'Capacity cannot be less than the number of configured seats.' });
    }
    await conn.execute('UPDATE AIRCRAFT SET AircraftModel = ?, TotalSeat = ? WHERE AircraftID = ?', [body.AircraftModel.trim(), Number(body.TotalSeat), req.params.id]);
    await conn.commit(); res.redirect('/aircraft');
  } catch (err) {
    if (conn) await conn.rollback();
    const message = dbMessage(err);
    if (message) return res.status(409).render('aircraft/form', { title: 'Edit aircraft', aircraft: { ...body, AircraftID: req.params.id }, editing: true, error: message });
    next(err);
  } finally { if (conn) conn.release(); }
};
exports.aircraftRemove = async (req, res, next) => {
  try {
    const [result] = await pool.execute('DELETE FROM AIRCRAFT WHERE AircraftID = ?', [req.params.id]);
    if (!result.affectedRows) return res.status(404).send('Aircraft not found.');
    res.redirect('/aircraft');
  } catch (err) {
    const message = dbMessage(err);
    if (message) { const [aircraft] = await pool.execute('SELECT * FROM AIRCRAFT ORDER BY AircraftID'); return res.status(409).render('aircraft/list', { title: 'Aircraft', aircraft, error: message }); }
    next(err);
  }
};
exports.seatNew = async (req, res, next) => {
  try {
    const [[aircraft]] = await pool.execute('SELECT * FROM AIRCRAFT WHERE AircraftID = ?', [req.params.aircraftId]);
    if (!aircraft) return res.status(404).send('Aircraft not found.');
    res.render('seats/form', { title: 'Add seat', aircraft, seat: null, error: null });
  } catch (err) { next(err); }
};
exports.seatCreate = async (req, res, next) => {
  const body = req.body; let conn;
  if (!required(body, ['SeatNo']) || !classes.includes(body.SeatClass || 'Economy')) {
    const [[aircraft]] = await pool.execute('SELECT * FROM AIRCRAFT WHERE AircraftID = ?', [req.params.aircraftId]);
    if (!aircraft) return res.status(404).send('Aircraft not found.');
    return res.status(400).render('seats/form', { title: 'Add seat', aircraft, seat: body, error: 'Enter a seat number and choose a valid cabin class.' });
  }
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [[aircraft]] = await conn.execute('SELECT * FROM AIRCRAFT WHERE AircraftID = ? FOR UPDATE', [req.params.aircraftId]);
    if (!aircraft) { await conn.rollback(); return res.status(404).send('Aircraft not found.'); }
    const [[count]] = await conn.execute('SELECT COUNT(*) AS seatCount FROM SEAT WHERE AircraftID = ?', [req.params.aircraftId]);
    if (Number(count.seatCount) >= Number(aircraft.TotalSeat)) {
      await conn.rollback();
      const [seats] = await pool.execute('SELECT * FROM SEAT WHERE AircraftID = ? ORDER BY SeatNo', [req.params.aircraftId]);
      return res.status(409).render('aircraft/detail', { title: 'Seat plan', aircraft, seats, error: 'This aircraft has reached its configured seat limit.' });
    }
    await conn.execute('INSERT INTO SEAT (AircraftID, SeatNo, SeatClass) VALUES (?, ?, ?)', [req.params.aircraftId, body.SeatNo.trim(), body.SeatClass || 'Economy']);
    await conn.commit(); res.redirect(`/aircraft/${req.params.aircraftId}`);
  } catch (err) {
    if (conn) await conn.rollback();
    const message = dbMessage(err);
    if (message) {
      const [[aircraft]] = await pool.execute('SELECT * FROM AIRCRAFT WHERE AircraftID = ?', [req.params.aircraftId]);
      if (aircraft) return res.status(409).render('seats/form', { title: 'Add seat', aircraft, seat: body, error: message });
      return res.status(404).send('Aircraft not found.');
    }
    next(err);
  } finally { if (conn) conn.release(); }
};
exports.seatRemove = async (req, res, next) => {
  try {
    const [[seat]] = await pool.execute('SELECT AircraftID FROM SEAT WHERE SeatID = ?', [req.params.id]);
    if (!seat) return res.status(404).send('Seat not found.');
    await pool.execute('DELETE FROM SEAT WHERE SeatID = ?', [req.params.id]);
    res.redirect(`/aircraft/${seat.AircraftID}`);
  } catch (err) {
    const message = dbMessage(err);
    if (message) {
      const [[seat]] = await pool.execute('SELECT AircraftID FROM SEAT WHERE SeatID = ?', [req.params.id]);
      if (seat) { const [[aircraft]] = await pool.execute('SELECT * FROM AIRCRAFT WHERE AircraftID = ?', [seat.AircraftID]); const [seats] = await pool.execute('SELECT * FROM SEAT WHERE AircraftID = ? ORDER BY SeatNo', [seat.AircraftID]); return res.status(409).render('aircraft/detail', { title: 'Seat plan', aircraft, seats, error: message }); }
    }
    next(err);
  }
};

// Flights
async function flightFormData(req, flight = null) {
  const [routes] = await pool.execute('SELECT * FROM ROUTE ORDER BY FlightNo');
  const [aircraft] = await pool.execute('SELECT * FROM AIRCRAFT ORDER BY AircraftID');
  return { title: flight ? 'Edit flight' : 'Schedule flight', flight, routes, aircraft, editing: Boolean(flight), error: null };
}
exports.flightsList = async (req, res, next) => {
  try {
    const filters = { origin: req.query.origin || '', destination: req.query.destination || '', date: req.query.date || '' };
    const [airports] = await pool.execute('SELECT * FROM AIRPORT ORDER BY AirportCode');
    const [flights] = await pool.execute(`SELECT f.*, ro.OriginCode, ro.DestinationCode FROM FLIGHT f
      JOIN ROUTE ro ON ro.FlightNo = f.FlightNo WHERE (? = '' OR ro.OriginCode = ?)
      AND (? = '' OR ro.DestinationCode = ?) AND (? = '' OR DATE(f.DepartureTime) = ?)
      ORDER BY f.DepartureTime`, [filters.origin, filters.origin, filters.destination, filters.destination, filters.date, filters.date]);
    res.render('flights/list', { title: 'Flights', flights, airports, filters, error: null });
  } catch (err) { next(err); }
};
exports.flightsNew = async (req, res, next) => {
  try { res.render('flights/form', await flightFormData(req)); } catch (err) { next(err); }
};
exports.flightsEdit = async (req, res, next) => {
  try {
    const [[flight]] = await pool.execute('SELECT * FROM FLIGHT WHERE FlightID = ?', [req.params.id]);
    if (!flight) return res.status(404).send('Flight not found.');
    res.render('flights/form', await flightFormData(req, flight));
  } catch (err) { next(err); }
};
exports.flightsDetail = async (req, res, next) => {
  try {
    const [[flight]] = await pool.execute(`SELECT f.*, ro.OriginCode, ro.DestinationCode FROM FLIGHT f
      JOIN ROUTE ro ON ro.FlightNo = f.FlightNo WHERE f.FlightID = ?`, [req.params.id]);
    if (!flight) return res.status(404).send('Flight not found.');
    const [fares] = await pool.execute(`SELECT fa.*, GROUP_CONCAT(CONCAT(fc.ConditionName, ' (', fr.Fee, ')') ORDER BY fc.ConditionName SEPARATOR ', ') AS Conditions
      FROM FARE fa LEFT JOIN FARE_RULE fr ON fr.FareID = fa.FareID LEFT JOIN FARE_CONDITION fc ON fc.ConditionID = fr.ConditionID
      WHERE fa.FlightID = ? GROUP BY fa.FareID ORDER BY fa.Class, fa.Price`, [req.params.id]);
    const [availability] = await pool.execute(`SELECT s.SeatClass, COUNT(*) AS total_seats,
      COUNT(t.TicketID) AS sold, COUNT(*) - COUNT(t.TicketID) AS free
      FROM SEAT s LEFT JOIN TICKET t ON t.SeatID = s.SeatID AND t.FlightID = ? AND t.TicketStatus <> 'cancelled'
      WHERE s.AircraftID = ? GROUP BY s.SeatClass ORDER BY s.SeatClass`, [req.params.id, flight.AircraftID]);
    res.render('flights/detail', { title: 'Flight details', flight, fares, availability, error: null });
  } catch (err) { next(err); }
};
exports.flightsCreate = async (req, res, next) => {
  const body = req.body;
  if (!required(body, ['FlightNo', 'AircraftID', 'DepartureTime', 'ArrivalTime']) || new Date(body.ArrivalTime) <= new Date(body.DepartureTime)) {
    const locals = await flightFormData(req); locals.flight = body; locals.editing = false; locals.error = 'Provide a route, aircraft, and valid times (arrival must be after departure).';
    return res.status(400).render('flights/form', locals);
  }
  try {
    const [result] = await pool.execute(`INSERT INTO FLIGHT (FlightNo, AircraftID, DepartureTime, ArrivalTime, Status, Gate)
      VALUES (?, ?, ?, ?, ?, ?)`, [body.FlightNo, body.AircraftID, body.DepartureTime, body.ArrivalTime, body.Status || 'OnTime', nullable(body.Gate)]);
    res.redirect(`/flights/${result.insertId}`);
  } catch (err) {
    const message = dbMessage(err);
    if (message) { const locals = await flightFormData(req); locals.flight = body; locals.editing = false; locals.error = message; return res.status(409).render('flights/form', locals); }
    next(err);
  }
};
exports.flightsUpdate = async (req, res, next) => {
  const body = req.body;
  if (!required(body, ['AircraftID', 'DepartureTime', 'ArrivalTime', 'Status']) || new Date(body.ArrivalTime) <= new Date(body.DepartureTime)) {
    const locals = await flightFormData(req, { ...body, FlightID: req.params.id }); locals.editing = true; locals.error = 'Provide an aircraft, status, and valid times (arrival must be after departure).';
    return res.status(400).render('flights/form', locals);
  }
  try {
    const [[flight]] = await pool.execute('SELECT FlightNo FROM FLIGHT WHERE FlightID = ?', [req.params.id]);
    if (!flight) return res.status(404).send('Flight not found.');
    const [[count]] = await pool.execute(`SELECT COUNT(*) AS mismatches FROM TICKET t JOIN SEAT s ON s.SeatID = t.SeatID
      WHERE t.FlightID = ? AND t.TicketStatus <> 'cancelled' AND s.AircraftID <> ?`, [req.params.id, body.AircraftID]);
    if (Number(count.mismatches)) { const locals = await flightFormData(req, { ...body, FlightID: req.params.id, FlightNo: flight.FlightNo }); locals.editing = true; locals.error = 'Aircraft cannot change while active tickets use seats from the current aircraft.'; return res.status(409).render('flights/form', locals); }
    await pool.execute(`UPDATE FLIGHT SET AircraftID = ?, DepartureTime = ?, ArrivalTime = ?, Status = ?, Gate = ? WHERE FlightID = ?`, [body.AircraftID, body.DepartureTime, body.ArrivalTime, body.Status, nullable(body.Gate), req.params.id]);
    res.redirect(`/flights/${req.params.id}`);
  } catch (err) {
    const message = dbMessage(err);
    if (message) { const locals = await flightFormData(req, { ...body, FlightID: req.params.id }); locals.editing = true; locals.error = message; return res.status(409).render('flights/form', locals); }
    next(err);
  }
};
exports.flightsRemove = async (req, res, next) => {
  try {
    const [result] = await pool.execute('DELETE FROM FLIGHT WHERE FlightID = ?', [req.params.id]);
    if (!result.affectedRows) return res.status(404).send('Flight not found.');
    res.redirect('/flights');
  } catch (err) { const message = dbMessage(err); if (message) { const [flights] = await pool.execute(`SELECT f.*, r.OriginCode, r.DestinationCode FROM FLIGHT f JOIN ROUTE r ON r.FlightNo=f.FlightNo ORDER BY f.DepartureTime`); const [airports] = await pool.execute('SELECT * FROM AIRPORT ORDER BY AirportCode'); return res.status(409).render('flights/list', { title: 'Flights', flights, airports, filters: {}, error: message }); } next(err); }
};

// Fares
async function fareFormData(flightId, fare = null) {
  const [[flight]] = await pool.execute(`SELECT f.*, r.OriginCode, r.DestinationCode FROM FLIGHT f JOIN ROUTE r ON r.FlightNo=f.FlightNo WHERE f.FlightID=?`, [flightId]);
  if (!flight) return null;
  const [conditions] = await pool.execute('SELECT * FROM FARE_CONDITION ORDER BY ConditionName');
  const [fareRules] = fare ? await pool.execute('SELECT * FROM FARE_RULE WHERE FareID = ?', [fare.FareID]) : [[]];
  return { title: fare ? 'Edit fare' : 'Add fare', flight, fare, conditions, fareRules, error: null };
}
exports.faresList = async (req, res, next) => {
  req.params.id = req.params.flightId;
  return exports.flightsDetail(req, res, next);
};
exports.faresNew = async (req, res, next) => {
  try { const locals = await fareFormData(req.params.flightId); if (!locals) return res.status(404).send('Flight not found.'); res.render('fares/form', locals); } catch (err) { next(err); }
};
exports.faresEdit = async (req, res, next) => {
  try {
    const [[fare]] = await pool.execute('SELECT * FROM FARE WHERE FareID = ?', [req.params.id]);
    if (!fare) return res.status(404).send('Fare not found.');
    const locals = await fareFormData(fare.FlightID, fare); res.render('fares/form', locals);
  } catch (err) { next(err); }
};
function normalizeRules(value) {
  if (!value) return [];
  const raw = Array.isArray(value) ? value : Object.values(value);
  return raw.filter((rule) => rule && rule.ConditionID);
}
exports.faresCreate = async (req, res, next) => {
  const body = req.body; let conn;
  const Rules = normalizeRules(body.Rules);
  if (!classes.includes(body.Class) || !(Number(body.Price) > 0)) { const locals = await fareFormData(req.params.flightId); if (!locals) return res.status(404).send('Flight not found.'); return res.status(400).render('fares/form', { ...locals, fare: body, fareRules: Rules, error: 'Choose a valid class and enter a positive price.' }); }
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [fare] = await conn.execute('INSERT INTO FARE (FlightID, Class, Price) VALUES (?, ?, ?)', [req.params.flightId, body.Class, Number(body.Price)]);
    for (const rule of Rules) {
      if (Number(rule.Fee || 0) < 0) throw Object.assign(new Error('Fare condition fees cannot be negative.'), { status: 400 });
      await conn.execute('INSERT INTO FARE_RULE (FareID, ConditionID, Fee) VALUES (?, ?, ?)', [fare.insertId, rule.ConditionID, Number(rule.Fee || 0)]);
    }
    await conn.commit(); res.redirect(`/flights/${req.params.flightId}`);
  } catch (err) {
    if (conn) await conn.rollback();
    const message = err.message || dbMessage(err);
    if (err.status || dbMessage(err)) { const locals = await fareFormData(req.params.flightId); if (locals) return res.status(err.status || 409).render('fares/form', { ...locals, fare: body, fareRules: Rules, error: message }); }
    next(err);
  } finally { if (conn) conn.release(); }
};
exports.faresUpdate = async (req, res, next) => {
  const body = req.body; let conn;
  try {
    const [[fare]] = await pool.execute('SELECT * FROM FARE WHERE FareID = ?', [req.params.id]);
    if (!fare) return res.status(404).send('Fare not found.');
    const Rules = normalizeRules(body.Rules);
    if (!classes.includes(body.Class) || !(Number(body.Price) > 0)) { const locals = await fareFormData(fare.FlightID, fare); return res.status(400).render('fares/form', { ...locals, fare: { ...fare, ...body }, fareRules: Rules, error: 'Choose a valid class and enter a positive price.' }); }
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [[mismatch]] = await conn.execute(`SELECT COUNT(*) AS count FROM TICKET t JOIN SEAT s ON s.SeatID=t.SeatID
      WHERE t.FareID=? AND t.TicketStatus <> 'cancelled' AND s.SeatClass <> ?`, [req.params.id, body.Class]);
    if (Number(mismatch.count)) { await conn.rollback(); const locals = await fareFormData(fare.FlightID, fare); return res.status(409).render('fares/form', { ...locals, fare: { ...fare, ...body }, fareRules: Rules, error: 'Fare class cannot change while active tickets use a different seat class.' }); }
    await conn.execute('UPDATE FARE SET Class=?, Price=? WHERE FareID=?', [body.Class, Number(body.Price), req.params.id]);
    await conn.execute('DELETE FROM FARE_RULE WHERE FareID=?', [req.params.id]);
    for (const rule of Rules) { if (Number(rule.Fee || 0) < 0) throw Object.assign(new Error('Fare condition fees cannot be negative.'), { status: 400 }); await conn.execute('INSERT INTO FARE_RULE (FareID, ConditionID, Fee) VALUES (?, ?, ?)', [req.params.id, rule.ConditionID, Number(rule.Fee || 0)]); }
    await conn.commit(); res.redirect(`/flights/${fare.FlightID}`);
  } catch (err) {
    if (conn) await conn.rollback();
    const message = err.message || dbMessage(err);
    if (err.status || dbMessage(err)) { const [[fare]] = await pool.execute('SELECT * FROM FARE WHERE FareID=?', [req.params.id]); if (fare) { const locals = await fareFormData(fare.FlightID, fare); return res.status(err.status || 409).render('fares/form', { ...locals, fare: { ...fare, ...body }, fareRules: Rules, error: message }); } }
    next(err);
  } finally { if (conn) conn.release(); }
};
exports.faresRemove = async (req, res, next) => {
  try {
    const [[fare]] = await pool.execute('SELECT FlightID FROM FARE WHERE FareID = ?', [req.params.id]);
    if (!fare) return res.status(404).send('Fare not found.');
    await pool.execute('DELETE FROM FARE WHERE FareID = ?', [req.params.id]); res.redirect(`/flights/${fare.FlightID}`);
  } catch (err) { const message = dbMessage(err); if (message) return res.status(409).send(message); next(err); }
};

// Staff
exports.staffList = async (req, res, next) => {
  try {
    const [staff] = await pool.execute(`SELECT s.StaffID, s.StaffName, s.StaffRole, b.SalesOffice, c.CounterNo
      FROM STAFF s LEFT JOIN BOOKINGSTAFF b ON b.StaffID=s.StaffID LEFT JOIN CHECKINSTAFF c ON c.StaffID=s.StaffID ORDER BY s.StaffID`);
    res.render('staff/list', { title: 'Staff', staff, error: null });
  } catch (err) { next(err); }
};
exports.staffNew = (req, res) => res.render('staff/form', { title: 'Add staff member', staffMember: null, editing: false, error: null });
exports.staffEdit = async (req, res, next) => {
  try {
    const [[staffMember]] = await pool.execute(`SELECT s.StaffID,s.StaffName,s.StaffRole,b.SalesOffice,c.CounterNo
      FROM STAFF s LEFT JOIN BOOKINGSTAFF b ON b.StaffID=s.StaffID LEFT JOIN CHECKINSTAFF c ON c.StaffID=s.StaffID WHERE s.StaffID=?`, [req.params.id]);
    if (!staffMember) return res.status(404).send('Staff member not found.');
    res.render('staff/form', { title: 'Edit staff member', staffMember, editing: true, error: null });
  } catch (err) { next(err); }
};
exports.staffCreate = async (req, res, next) => {
  const body = req.body; let conn;
  if (!required(body, ['StaffName', 'StaffRole']) || !['BookingStaff', 'CheckInStaff'].includes(body.StaffRole) || (body.StaffRole === 'BookingStaff' && !required(body, ['SalesOffice'])) || (body.StaffRole === 'CheckInStaff' && !required(body, ['CounterNo']))) return res.status(400).render('staff/form', { title: 'Add staff member', staffMember: body, editing: false, error: 'Provide a name, valid role, and matching subtype field.' });
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [staff] = await conn.execute('INSERT INTO STAFF (StaffName, StaffRole) VALUES (?, ?)', [body.StaffName.trim(), body.StaffRole]);
    if (body.StaffRole === 'BookingStaff') await conn.execute("INSERT INTO BOOKINGSTAFF (StaffID, StaffRole, SalesOffice) VALUES (?, 'BookingStaff', ?)", [staff.insertId, body.SalesOffice.trim()]);
    else await conn.execute("INSERT INTO CHECKINSTAFF (StaffID, StaffRole, CounterNo) VALUES (?, 'CheckInStaff', ?)", [staff.insertId, body.CounterNo.trim()]);
    await conn.commit(); res.redirect('/staff');
  } catch (err) { if (conn) await conn.rollback(); const message = dbMessage(err); if (message) return res.status(409).render('staff/form', { title: 'Add staff member', staffMember: body, editing: false, error: message }); next(err); } finally { if (conn) conn.release(); }
};
exports.staffUpdate = async (req, res, next) => {
  const body = req.body; let conn;
  try {
    if (!required(body, ['StaffName', 'StaffRole']) || !['BookingStaff', 'CheckInStaff'].includes(body.StaffRole) || (body.StaffRole === 'BookingStaff' && !required(body, ['SalesOffice'])) || (body.StaffRole === 'CheckInStaff' && !required(body, ['CounterNo']))) return res.status(400).render('staff/form', { title: 'Edit staff member', staffMember: { ...body, StaffID: req.params.id }, editing: true, error: 'Provide a name, valid role, and matching subtype field.' });
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [[old]] = await conn.execute('SELECT StaffRole FROM STAFF WHERE StaffID = ? FOR UPDATE', [req.params.id]);
    if (!old) { await conn.rollback(); return res.status(404).send('Staff member not found.'); }
    if (old.StaffRole !== body.StaffRole) { await conn.rollback(); return res.status(409).render('staff/form', { title: 'Edit staff member', staffMember: { ...body, StaffID: req.params.id }, editing: true, error: 'A staff role cannot change after creation.' }); }
    await conn.execute('UPDATE STAFF SET StaffName = ? WHERE StaffID = ?', [body.StaffName.trim(), req.params.id]);
    if (body.StaffRole === 'BookingStaff') await conn.execute('UPDATE BOOKINGSTAFF SET SalesOffice = ? WHERE StaffID = ?', [body.SalesOffice.trim(), req.params.id]);
    else await conn.execute('UPDATE CHECKINSTAFF SET CounterNo = ? WHERE StaffID = ?', [body.CounterNo.trim(), req.params.id]);
    await conn.commit(); res.redirect('/staff');
  } catch (err) { if (conn) await conn.rollback(); const message = dbMessage(err); if (message) return res.status(409).render('staff/form', { title: 'Edit staff member', staffMember: { ...body, StaffID: req.params.id }, editing: true, error: message }); next(err); } finally { if (conn) conn.release(); }
};
exports.staffRemove = async (req, res, next) => {
  let conn;
  try {
    conn = await pool.getConnection(); await conn.beginTransaction();
    const [[staff]] = await conn.execute('SELECT StaffRole FROM STAFF WHERE StaffID = ? FOR UPDATE', [req.params.id]);
    if (!staff) { await conn.rollback(); return res.status(404).send('Staff member not found.'); }
    await conn.execute(staff.StaffRole === 'BookingStaff' ? 'DELETE FROM BOOKINGSTAFF WHERE StaffID = ?' : 'DELETE FROM CHECKINSTAFF WHERE StaffID = ?', [req.params.id]);
    await conn.execute('DELETE FROM STAFF WHERE StaffID = ?', [req.params.id]); await conn.commit(); res.redirect('/staff');
  } catch (err) { if (conn) await conn.rollback(); const message = dbMessage(err); if (message) { const [staff] = await pool.execute(`SELECT s.StaffID,s.StaffName,s.StaffRole,b.SalesOffice,c.CounterNo FROM STAFF s LEFT JOIN BOOKINGSTAFF b ON b.StaffID=s.StaffID LEFT JOIN CHECKINSTAFF c ON c.StaffID=s.StaffID`); return res.status(409).render('staff/list', { title: 'Staff', staff, error: message }); } next(err); } finally { if (conn) conn.release(); }
};
