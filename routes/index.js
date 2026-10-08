// routes/index.js
//
// The Home page: three record counts and shortcuts into each area.

const express = require('express');
const pool = require('../config/db');
const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    const [[counts]] = await pool.query(
      `SELECT (SELECT COUNT(*) FROM PASSENGER) AS passengers,
              (SELECT COUNT(*) FROM FLIGHT WHERE Status <> 'Cancelled' AND DepartureTime > NOW()) AS flights,
              (SELECT COUNT(*) FROM RESERVATION) AS reservations`
    );
    res.render('index', { title: 'Home', counts });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
