// public/js/main.js
//
// [Phase 5 · Frontend · Kornnaphat] Small browser-side helpers, loaded on every
// page from views/partials/footer.ejs. No database or business logic here:
// the controllers and MySQL check every rule again when the form is saved.

// Header: highlight the section you are in, and open/close the nav on phones.
(function () {
  var path = window.location.pathname;
  document.querySelectorAll('.app-nav a').forEach(function (link) {
    var href = link.getAttribute('href');
    var here = href === '/' ? path === '/' : path === href || path.indexOf(href + '/') === 0;
    link.classList.toggle('is-active', here);
    if (here) link.setAttribute('aria-current', 'page');
  });

  var toggle = document.querySelector('.menu-toggle');
  if (toggle) {
    toggle.addEventListener('click', function () {
      var open = document.querySelector('.app-nav').classList.toggle('nav-open');
      toggle.setAttribute('aria-expanded', String(open));
    });
  }
})();

// "Are you sure?" before a delete or cancel: add data-confirm="..." to the <form>.
document.addEventListener('submit', function (event) {
  var message = event.target.getAttribute('data-confirm');
  if (message && !window.confirm(message)) {
    event.preventDefault();
  }
});

// Booking form (views/reservations/form.ejs): one row per traveller.
// Picking a flight fills that row's Fare list; picking a fare fills the Seat
// list with free seats of the same class (the TICKET triggers refuse a
// mismatch). A seat already chosen in another row is left out.
(function () {
  var form = document.querySelector('[data-booking-form]');
  var dataTag = document.getElementById('booking-data');
  if (!form || !dataTag) return;

  var data = JSON.parse(dataTag.textContent);
  var rowsBox = form.querySelector('[data-ticket-rows]');
  var template = rowsBox.querySelector('[data-ticket-row]').cloneNode(true);

  function field(row, name) {
    return row.querySelector('select[name$="[' + name + ']"]');
  }

  function option(value, text) {
    var o = document.createElement('option');
    o.value = value;
    o.textContent = text;
    return o;
  }

  function fillFares(row) {
    var flightId = field(row, 'FlightID').value;
    var fare = field(row, 'FareID');
    var keep = fare.value;
    fare.innerHTML = '';
    if (!flightId) {
      fare.appendChild(option('', 'Select flight first'));
      return;
    }
    fare.appendChild(option('', 'Choose fare'));
    data.fares.forEach(function (f) {
      if (String(f.FlightID) === flightId) {
        fare.appendChild(option(f.FareID, f.Class + ' · ' + Number(f.Price).toFixed(2) + ' THB'));
      }
    });
    fare.value = keep;
    if (fare.value !== keep) fare.value = '';
  }

  function fillSeats() {
    var rows = rowsBox.querySelectorAll('[data-ticket-row]');
    rows.forEach(function (row) {
      var flightId = field(row, 'FlightID').value;
      var fareId = field(row, 'FareID').value;
      var seat = field(row, 'SeatID');
      var keep = seat.value;
      var fare = data.fares.filter(function (f) { return String(f.FareID) === fareId; })[0];
      var takenElsewhere = [];
      rows.forEach(function (other) {
        if (other !== row && field(other, 'FlightID').value === flightId && field(other, 'SeatID').value) {
          takenElsewhere.push(field(other, 'SeatID').value);
        }
      });

      seat.innerHTML = '';
      if (!flightId) { seat.appendChild(option('', 'Select flight first')); return; }
      if (!fare) { seat.appendChild(option('', 'Select fare first')); return; }

      var free = data.seats.filter(function (s) {
        return String(s.FlightID) === flightId && s.SeatClass === fare.Class &&
          takenElsewhere.indexOf(String(s.SeatID)) === -1;
      });
      seat.appendChild(option('', free.length ? 'Choose seat' : 'No free ' + fare.Class + ' seats'));
      free.forEach(function (s) { seat.appendChild(option(s.SeatID, s.SeatNo + ' · ' + s.SeatClass)); });
      seat.value = keep;
      if (seat.value !== keep) seat.value = '';
    });
  }

  // Rows post as Tickets[0][...], Tickets[1][...], ... so renumber after any add or remove.
  function renumber() {
    var rows = rowsBox.querySelectorAll('[data-ticket-row]');
    rows.forEach(function (row, i) {
      row.querySelectorAll('select').forEach(function (select) {
        select.name = select.name.replace(/^Tickets\[\d+\]/, 'Tickets[' + i + ']');
      });
      // style.display, not hidden: style.css gives every button display:inline-block.
      row.querySelector('[data-remove-ticket-row]').style.display = rows.length === 1 ? 'none' : '';
    });
  }

  form.querySelector('[data-add-ticket-row]').addEventListener('click', function () {
    var row = template.cloneNode(true);
    row.querySelectorAll('select').forEach(function (select) { select.value = ''; });
    rowsBox.appendChild(row);
    fillFares(row);
    renumber();
    fillSeats();
  });

  rowsBox.addEventListener('click', function (event) {
    if (!event.target.matches('[data-remove-ticket-row]')) return;
    event.target.closest('[data-ticket-row]').remove();
    renumber();
    fillSeats();
  });

  rowsBox.addEventListener('change', function (event) {
    var row = event.target.closest('[data-ticket-row]');
    if (event.target.name.indexOf('[FlightID]') !== -1) fillFares(row);
    fillSeats();
  });

  // A flight passed in the URL (/reservations/new?flightId=6) is already selected.
  rowsBox.querySelectorAll('[data-ticket-row]').forEach(fillFares);
  renumber();
  fillSeats();
})();
