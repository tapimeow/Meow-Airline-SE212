const router = require('express').Router();
const controller = require('../controllers/airportController');

router.get('/', controller.list);
router.get('/new', controller.newForm);
router.get('/:code/edit', controller.editForm);
router.post('/', controller.create);
router.post('/:code', controller.update);
router.post('/:code/delete', controller.remove);

module.exports = router;
