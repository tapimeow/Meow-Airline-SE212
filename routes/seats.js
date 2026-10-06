const r=require('express').Router(),c=require('../controllers/seatController');r.post('/aircraft/:aircraftId/seats',c.create);r.post('/seats/:id/delete',c.remove);module.exports=r;
