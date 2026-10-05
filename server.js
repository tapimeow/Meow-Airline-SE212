// server.js
//
// App entry point. Run with `npm run dev` (auto-restarts on save) or
// `npm start`. This file's job is just wiring - routes and CSS live in
// their own folders below.

require('dotenv').config();
const express = require('express');
const path = require('path');

const indexRoutes = require('./routes/index');
const passengerRoutes = require('./routes/passengers');
// TODO [Phase 4 · Backend · Kawintida]: add one app.use line here for
// every route file as it gets built (see docs/ROUTES.md for the full list):
//   app.use('/airports',     require('./routes/airports'));
//   app.use('/aircraft',     require('./routes/aircraft'));
//   app.use('/',             require('./routes/seats'));     // nested under /aircraft/:id/seats
//   app.use('/flights',      require('./routes/flights'));
//   app.use('/',             require('./routes/fares'));     // nested under /flights/:id/fares
//   app.use('/reservations', require('./routes/reservations'));
//   app.use('/tickets',      require('./routes/tickets'));
//   app.use('/',             require('./routes/payments'));  // nested under /reservations/:id/payments
//   app.use('/',             require('./routes/baggage'));   // nested under /tickets/:id/baggage
//   app.use('/checkin',      require('./routes/checkin'));
//   app.use('/staff',        require('./routes/staff'));
//   app.use('/reports',      require('./routes/reports'));

const app = express();

// [Phase 5 · Frontend · Kornnaphat] Templates live in views/, using EJS. Shared markup
// (nav, header, footer) belongs in views/partials/ so it's not repeated on
// every page - see views/partials/header.ejs and footer.ejs.
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Static files (CSS, client-side JS, images) are served straight from
// public/ - e.g. public/css/style.css is reachable at /css/style.css.
app.use(express.static(path.join(__dirname, 'public')));

// Parses form submissions (application/x-www-form-urlencoded) so
// req.body works in controllers - every <form> in views/ needs this.
app.use(express.urlencoded({ extended: true }));

// Mount routes. Keep each entity's routes in its own file under routes/.
app.use('/', indexRoutes);
app.use('/passengers', passengerRoutes);

// Basic 404 - customize this page under views/ if you want it styled.
app.use((req, res) => {
  res.status(404).send('Page not found');
});

// Error handler: controllers call next(err) for errors the user cannot fix.
// It must have 4 arguments so Express knows it handles errors. The details
// go to the terminal; the browser only sees a short message.
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).send('Something went wrong. Check the server terminal for details.');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Meow Airline app running at http://localhost:${PORT}`);
});
