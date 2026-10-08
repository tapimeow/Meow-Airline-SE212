const router = require('express').Router();
const controller = require('../controllers/flightController');

router.get('/', controller.list);
router.get('/new', controller.newForm);
router.get('/:id/edit', controller.editForm);
router.get('/:id', controller.detail);
router.post('/', controller.create);
router.post('/:id', controller.update);
router.post('/:id/delete', controller.remove);

module.exports = router;
