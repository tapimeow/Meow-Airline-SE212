const r=require('express').Router(),c=require('../controllers/apiAdminController');
r.get('/',c.routesList);r.post('/',c.routesCreate);r.post('/:flightNo',c.routesUpdate);r.post('/:flightNo/delete',c.routesRemove);module.exports=r;
