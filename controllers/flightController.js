const admin = require('./apiAdminController');
exports.list = admin.flightsList;
exports.newForm = admin.flightsNew;
exports.editForm = admin.flightsEdit;
exports.detail = admin.flightsDetail;
exports.create = admin.flightsCreate;
exports.update = admin.flightsUpdate;
exports.remove = admin.flightsRemove;
