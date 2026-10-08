const router = require('express').Router();
const controller = require('../controllers/fareController');

router.get('/flights/:flightId/fares/new', controller.newForm);
router.get('/fares/:id/edit', controller.editForm);
router.get('/flights/:flightId/fares', controller.list);
router.post('/flights/:flightId/fares', controller.create);
router.post('/fares/:id', controller.update);
router.post('/fares/:id/delete', controller.remove);

module.exports = router;
