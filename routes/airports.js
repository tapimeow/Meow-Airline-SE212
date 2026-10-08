const r=require('express').Router(),c=require('../controllers/airportController'); r.get('/',c.list);r.post('/',c.create);r.post('/:code',c.update);r.post('/:code/delete',c.remove);module.exports=r;
