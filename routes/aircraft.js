const router = require('express').Router();
const controller = require('../controllers/aircraftController');

router.get('/', controller.list);
router.get('/new', controller.newForm);
router.get('/:aircraftId/seats/new', controller.newSeatForm);
router.get('/:id', controller.detail);
router.get('/:id/edit', controller.editForm);
router.post('/', controller.create);
router.post('/:id', controller.update);
router.post('/:id/delete', controller.remove);

module.exports = router;
