const pool = require('../config/db');
const fail = (res, err) => {
  if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'That seat or traveller already has a live ticket on this flight.' });
  if (err.code === 'ER_NO_REFERENCED_ROW_2') return res.status(400).json({ error: 'Passenger, flight, fare, seat, or staff record was not found.' });
  return null;
};
exports.list = async (req,res,next)=>{try{const [rows]=await pool.execute(`SELECT r.*,p.Name PassengerName FROM RESERVATION r JOIN PASSENGER p ON p.PassengerID=r.PassengerID WHERE (? IS NULL OR r.PassengerID=?) AND (? IS NULL OR r.ReservationStatus=?) ORDER BY r.BookingDate DESC`,[req.query.passengerId||null,req.query.passengerId||null,req.query.status||null,req.query.status||null]);res.json(rows);}catch(e){next(e);}};
exports.create = async (req,res,next)=>{
 const {PassengerID,BookingStaffID=null,Tickets}=req.body;
 if(!Number.isInteger(Number(PassengerID))||!Array.isArray(Tickets)||!Tickets.length)return res.status(400).json({error:'PassengerID and a non-empty Tickets array are required.'});
 const conn=await pool.getConnection().catch(err=>{next(err);return null;}); if(!conn)return;
 try { await conn.beginTransaction();
  const [r]=await conn.execute(`INSERT INTO RESERVATION (PassengerID,BookingStaffID) VALUES (?,?)`,[PassengerID,BookingStaffID||null]);
  for(const t of Tickets){if(!t.PassengerID||!t.FlightID||!t.SeatID||!t.FareID)throw Object.assign(new Error('Each ticket needs PassengerID, FlightID, SeatID and FareID.'),{status:400});
   await conn.execute(`INSERT INTO TICKET (ReservationID,PassengerID,FlightID,SeatID,FareID,TicketStatus) VALUES (?,?,?,?,?,'booked')`,[r.insertId,t.PassengerID,t.FlightID,t.SeatID,t.FareID]);}
  await conn.commit();res.status(201).json({ReservationID:r.insertId});
 } catch(e){await conn.rollback();if(e.status)return res.status(e.status).json({error:e.message});if(fail(res,e))return;next(e);}finally{conn.release();}
};
exports.detail=async(req,res,next)=>{try{const [rows]=await pool.execute(`SELECT r.*,p.Name PassengerName,t.TicketID,t.PassengerID TravellerID,tr.Name TravellerName,t.FlightID,t.SeatID,s.SeatNo,t.FareID,f.Price,t.TicketStatus FROM RESERVATION r JOIN PASSENGER p ON p.PassengerID=r.PassengerID LEFT JOIN TICKET t ON t.ReservationID=r.ReservationID LEFT JOIN PASSENGER tr ON tr.PassengerID=t.PassengerID LEFT JOIN SEAT s ON s.SeatID=t.SeatID LEFT JOIN FARE f ON f.FareID=t.FareID WHERE r.ReservationID=?`,[req.params.id]);if(!rows.length)return res.status(404).json({error:'Reservation not found.'});const [payments]=await pool.execute('SELECT * FROM PAYMENT WHERE ReservationID=?',[req.params.id]);res.json({reservation:rows[0],tickets:rows.filter(x=>x.TicketID),payments});}catch(e){next(e);}};
exports.change=async(req,res,next)=>{const {TicketID,FlightID,SeatID,FareID}=req.body;let conn;try{conn=await pool.getConnection();await conn.beginTransaction();const [locked]=await conn.execute(`SELECT TicketID FROM TICKET WHERE TicketID=? AND ReservationID=? AND TicketStatus='booked' FOR UPDATE`,[TicketID,req.params.id]);if(!locked.length){await conn.rollback();return res.status(404).json({error:'Booked ticket not found or ticket is already issued.'});}await conn.execute(`UPDATE TICKET SET FlightID=?,SeatID=?,FareID=? WHERE TicketID=?`,[FlightID,SeatID,FareID,TicketID]);await conn.commit();res.json({updated:true});}catch(e){if(conn)await conn.rollback();if(fail(res,e))return;next(e);}finally{if(conn)conn.release();}};
exports.cancel=async(req,res,next)=>{const conn=await pool.getConnection().catch(err=>{next(err);return null;});if(!conn)return;try{await conn.beginTransaction();const [r]=await conn.execute(`UPDATE RESERVATION SET ReservationStatus='Cancelled' WHERE ReservationID=? AND ReservationStatus<>'Cancelled'`,[req.params.id]);if(!r.affectedRows){await conn.rollback();return res.status(404).json({error:'Active reservation not found.'});}await conn.execute(`UPDATE TICKET SET TicketStatus='cancelled' WHERE ReservationID=? AND TicketStatus IN ('booked','issued')`,[req.params.id]);await conn.commit();res.json({cancelled:true});}catch(e){await conn.rollback();next(e);}finally{conn.release();}};
