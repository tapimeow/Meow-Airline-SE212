const router = require('express').Router();
const controller = require('../controllers/seatController');

router.post('/aircraft/:aircraftId/seats', controller.create);
router.post('/seats/:id/delete', controller.remove);

module.exports = router;
