// routes/passengers.js
//
// [Phase 0 · Practice · All three members] Already working: run it
// locally once before starting your own phase (docs/PHASES.md).
//
// This is the practice round from the build plan: a full CRUD flow for one
// entity, working end to end (route -> controller -> database -> EJS view)
// before anyone starts the real booking features. Copy this file's shape
// for every other entity's routes - e.g. routes/flights.js, then
// controllers/flightController.js, then views/flights/.

const express = require('express');
const router = express.Router();
const passengerController = require('../controllers/passengerController');

router.get('/', passengerController.list);            // GET  /passengers            - list all
router.get('/new', passengerController.showCreateForm); // GET  /passengers/new        - blank form
router.post('/', passengerController.create);           // POST /passengers            - create
router.get('/:id/edit', passengerController.showEditForm); // GET /passengers/:id/edit - filled-in form
router.post('/:id', passengerController.update);         // POST /passengers/:id        - update
router.post('/:id/delete', passengerController.remove);  // POST /passengers/:id/delete - delete

module.exports = router;
