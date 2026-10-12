// routes/passengers.js
//
// Passenger CRUD: list, add, edit and delete passengers
// (route -> controller -> database -> EJS view).

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
