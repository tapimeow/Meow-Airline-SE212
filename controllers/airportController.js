const admin = require('./apiAdminController');
exports.list = admin.airportsList;
exports.newForm = admin.airportsNew;
exports.editForm = admin.airportsEdit;
exports.create = admin.airportsCreate;
exports.update = admin.airportsUpdate;
exports.remove = admin.airportsRemove;
