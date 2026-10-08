const express = require('express');
const router = express.Router();
const baggageController = require('../controllers/baggageController');

router.get('/tickets/:ticketId/baggage', baggageController.list);
router.post('/tickets/:ticketId/baggage', baggageController.create);
router.post('/baggage/:id', baggageController.update);
router.post('/baggage/:id/delete', baggageController.remove);

module.exports = router;
