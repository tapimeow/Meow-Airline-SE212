// routes/index.js
//
// Just the home page for now. This is a good place for links into each
// role's area of the site while the real landing page isn't built yet.

const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.render('index', { title: 'Meow Airline' });
});

module.exports = router;
