const admin = require('./apiAdminController');
exports.list = admin.staffList;
exports.newForm = admin.staffNew;
exports.editForm = admin.staffEdit;
exports.create = admin.staffCreate;
exports.update = admin.staffUpdate;
exports.remove = admin.staffRemove;
