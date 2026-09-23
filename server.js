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
// TODO [Junior - Backend]: add one require + one app.use line here for
// every new route file, following the passengers.js pattern:
//   const flightRoutes = require('./routes/flights');
//   const reservationRoutes = require('./routes/reservations');
//   const paymentRoutes = require('./routes/payments');
//   const checkinRoutes = require('./routes/checkin');
//   const reportRoutes = require('./routes/reports');

const app = express();

// [Namtan - Frontend] Templates live in views/, using EJS. Shared markup
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Meow Airline app running at http://localhost:${PORT}`);
});
