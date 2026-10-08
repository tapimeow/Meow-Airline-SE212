const admin = require('./apiAdminController');
exports.list = admin.faresList;
exports.newForm = admin.faresNew;
exports.editForm = admin.faresEdit;
exports.create = admin.faresCreate;
exports.update = admin.faresUpdate;
exports.remove = admin.faresRemove;
