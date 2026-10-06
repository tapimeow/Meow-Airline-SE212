const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

router.post('/reservations/:reservationId/payments', paymentController.create);
router.post('/payments/:id/refund', paymentController.refund);

module.exports = router;
