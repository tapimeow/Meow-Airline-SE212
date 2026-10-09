const pool = require('../config/db');

async function findTickets(reservationId = '', passportNo = '') {
  if (!reservationId && !passportNo) return [];
  const [tickets] = await pool.execute(`SELECT t.TicketID, t.ReservationID, t.TicketStatus, p.Name AS Traveller, p.PassportNo,
      f.FlightNo, f.DepartureTime, f.Gate, s.SeatNo, c.CheckInID
    FROM TICKET t JOIN PASSENGER p ON p.PassengerID=t.PassengerID
    JOIN FLIGHT f ON f.FlightID=t.FlightID JOIN SEAT s ON s.SeatID=t.SeatID
    LEFT JOIN CHECKIN c ON c.TicketID=t.TicketID
    WHERE (? = '' OR t.ReservationID=?) AND (? = '' OR p.PassportNo=?) ORDER BY f.DepartureTime`,
  [reservationId, reservationId, passportNo, passportNo]);
  return tickets;
}

exports.search = async (req, res, next) => {
  try {
    const reservationId = req.query.reservationId || '';
    const passportNo = req.query.passportNo || '';
    const tickets = await findTickets(reservationId, passportNo);
    res.render('checkin/search', { title: 'Check-in', tickets, reservationId, passportNo, error: null });
  } catch (err) { next(err); }
};

exports.checkIn = async (req, res, next) => {
  try {
    const [[ticket]] = await pool.execute(`SELECT t.TicketID,t.ReservationID,t.TicketStatus,f.DepartureTime
      FROM TICKET t JOIN FLIGHT f ON f.FlightID=t.FlightID WHERE t.TicketID=?`, [req.params.ticketId]);
    if (!ticket) return res.status(404).send('Ticket not found.');
    if (ticket.TicketStatus !== 'issued') {
      const tickets = await findTickets(String(ticket.ReservationID), '');
      return res.status(409).render('checkin/search', { title: 'Check-in', tickets, reservationId: ticket.ReservationID, passportNo: '', error: 'Only issued tickets can check in.' });
    }
    if (new Date(ticket.DepartureTime) <= new Date()) {
      const tickets = await findTickets(String(ticket.ReservationID), '');
      return res.status(409).render('checkin/search', { title: 'Check-in', tickets, reservationId: ticket.ReservationID, passportNo: '', error: 'Check-in is closed because the flight has departed.' });
    }
    const boardingPassNo = `BP${Date.now()}${Math.floor(Math.random() * 1000)}`;
    const [result] = await pool.execute('INSERT INTO CHECKIN (TicketID, CheckInStaffID, BoardingPassNo) VALUES (?, ?, ?)', [req.params.ticketId, req.body.CheckInStaffID || null, boardingPassNo]);
    res.redirect(`/checkin/${result.insertId}/boarding-pass`);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      const [[ticket]] = await pool.execute('SELECT ReservationID FROM TICKET WHERE TicketID=?', [req.params.ticketId]);
      if (ticket) {
        const tickets = await findTickets(String(ticket.ReservationID), '');
        return res.status(409).render('checkin/search', { title: 'Check-in', tickets, reservationId: ticket.ReservationID, passportNo: '', error: 'This ticket is already checked in.' });
      }
    }
    if (err.code === 'ER_NO_REFERENCED_ROW_2') return res.status(400).send('Check-in staff member was not found.');
    next(err);
  }
};

exports.boardingPass = async (req, res, next) => {
  try {
    const [[boardingPass]] = await pool.execute(`SELECT c.*,t.TicketID,t.TicketStatus,p.Name AS Traveller,p.PassportNo,
      f.FlightNo,f.DepartureTime,f.ArrivalTime,f.Gate,r.OriginCode,r.DestinationCode,s.SeatNo,s.SeatClass
      FROM CHECKIN c JOIN TICKET t ON t.TicketID=c.TicketID JOIN PASSENGER p ON p.PassengerID=t.PassengerID
      JOIN FLIGHT f ON f.FlightID=t.FlightID JOIN ROUTE r ON r.FlightNo=f.FlightNo
      JOIN SEAT s ON s.SeatID=t.SeatID WHERE c.CheckInID=?`, [req.params.id]);
    if (!boardingPass) return res.status(404).send('Boarding pass not found.');
    res.render('checkin/boarding-pass', { title: 'Boarding pass', boardingPass, error: null });
  } catch (err) { next(err); }
};
