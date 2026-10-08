const r=require('express').Router(),c=require('../controllers/staffController');r.get('/',c.list);r.post('/',c.create);r.post('/:id',c.update);r.post('/:id/delete',c.remove);module.exports=r;
