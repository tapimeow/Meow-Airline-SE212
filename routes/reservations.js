const router = require('express').Router();
const controller = require('../controllers/reservationController');
const paymentController = require('../controllers/paymentController');

router.get('/', controller.list);
router.get('/new', controller.newForm);
router.get('/:id/payments', paymentController.newForm);
router.post('/', controller.create);
router.get('/:id', controller.detail);
router.post('/:id/change', controller.change);
router.post('/:id/cancel', controller.cancel);

module.exports = router;
