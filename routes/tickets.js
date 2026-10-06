const router=require('express').Router(); const c=require('../controllers/ticketController'); router.get('/:id',c.detail); router.post('/:id/issue',c.issue); module.exports=router;
