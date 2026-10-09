-- db/seed.sql
--
-- [Phase 3 · Database · Patarawadee] Sample data for every table (report
-- section 7: "INSERT sample data for every table"). Run it after schema.sql:
--
--   mysql -u root -p meow_airline < db/seed.sql
--
-- All people are fake (Lab 6 B4.3). Airport codes are real IATA codes.
-- "Today" in this data is early October 2026:
--   September flights have already flown (used for the "last month" report),
--   October flights are still to come (used for booking and check-in),
--   and November-December flights fill the calendar for the 100 passengers.
-- Seat maps are shortened to keep the data readable: 12 seats on aircraft 1-6
-- (row 1 Business, rows 2-3 Economy) and 18 on the wide-body aircraft 7-8
-- (row 1 FirstClass, row 2 Business, rows 3-5 Economy). BR11 still holds.
--
-- Rows the queries in db/queries.sql rely on:
--   - flight MW101 on 20 Oct 2026 with a family of 3 on one reservation (Q1, demo)
--   - passenger 1 with one paid and one unpaid reservation (Q2)
--   - a September route that sold no seats, HKT -> USM (Q3)
--   - aircraft 6 with no flights (Q12)
--   - tickets on upcoming flights that are not checked in yet (Q10)
--   - reservation 6: held, unpaid, no payments (safe to delete in Q17)

USE meow_airline;

-- AIRPORT ------------------------------------------------------------
INSERT INTO AIRPORT (AirportCode, City, Country) VALUES
  ('BKK', 'Bangkok',    'Thailand'),
  ('CNX', 'Chiang Mai', 'Thailand'),
  ('HKT', 'Phuket',     'Thailand'),
  ('USM', 'Koh Samui',  'Thailand'),
  ('KBV', 'Krabi',      'Thailand'),
  ('SIN', 'Singapore',  'Singapore'),
  ('VTE', 'Vientiane',  'Laos');

-- Long-haul destinations for the wide-body aircraft
INSERT INTO AIRPORT (AirportCode, City, Country) VALUES
  ('NRT', 'Tokyo', 'Japan'),
  ('HKG', 'Hong Kong', 'China');

-- AIRCRAFT: Meow Airline's six aircraft ------------------------------------
INSERT INTO AIRCRAFT (AircraftModel, TotalSeat) VALUES
  ('ATR 72-600',   70),   -- 1
  ('ATR 72-600',   70),   -- 2
  ('Airbus A320', 180),   -- 3
  ('Airbus A320', 180),   -- 4
  ('Embraer E190', 100),  -- 5
  ('Airbus A321', 220);   -- 6  (in maintenance: no flights, see Q12)

-- 7, 8: wide-body aircraft with FirstClass seats (flown BKK-NRT and BKK-HKG)
INSERT INTO AIRCRAFT (AircraftModel, TotalSeat) VALUES
  ('Boeing 787-9', 290),
  ('Airbus A350-900', 300);

-- PASSENGER ----------------------------------------------------------
INSERT INTO PASSENGER (Name, PassportNo, PhoneNo, Email, MembershipStatus) VALUES
  ('Somsak Jaidee',      'AA1234567', '0812345678',  'somsak@example.com',     'Normal'),  -- 1
  ('Nara Chaisiri',      'AB7654321', '0898765432',  'nara@example.com',       'Gold'),    -- 2
  ('Wichai Saetang',     'AC2223334', '0861112222',  'wichai@example.com',     'Silver'),  -- 3 (family booker)
  ('Ladda Saetang',      'AC2223335', '0861112223',  'ladda@example.com',      'Normal'),  -- 4 (family)
  ('Siriporn Kaewmanee', 'AD5556667', '0823334444',  'siriporn@example.com',   'Silver'),  -- 5
  ('Tom Keomany',        'LA0098765', '+8562055501', 'tom.k@example.la',       'Normal'),  -- 6
  ('Mint Saetang',       'AC2223336', NULL,          NULL,                     'Normal'),  -- 7 (family, child: no phone/email)
  ('Daniel Tan',         'SG7788990', '+6591234567', 'daniel.tan@example.sg',  'Gold');    -- 8

-- 9-100: 92 more passengers (100 in total), all FAKE (RULES.md 1.3), fixed seed.
--         72 Thai, 10 Lao, 10 Singaporean; 64 Normal, 18 Silver, 10 Gold. Everyone has
--         an email and no one is a Saetang, so Q5a/Q5b keep the same result.
INSERT INTO PASSENGER (Name, PassportNo, PhoneNo, Email, MembershipStatus) VALUES
  ('Dao Jantarawong', 'AE7801816', '0866016098', 'dao.jantarawong@example.com', 'Gold'),
  ('Narong Kongkaew', 'AE9607804', '0950032635', 'narong.kongkaew@example.com', 'Normal'),
  ('Chanida Thongsuk', 'AF9555456', '0671790299', 'chanida.thongsuk@example.com', 'Normal'),
  ('Thida Wongsakul', 'AH4170831', '0826142415', 'thida.wongsakul@example.com', 'Silver'),
  ('Bounmy Vongsavath', 'LA6887763', '+8562066796608', 'bounmy.vongsavath@example.la', 'Normal'),
  ('Yupin Meesuk', 'AG5945325', '0669156255', 'yupin.meesuk@example.com', 'Silver'),
  ('Kanokwan Boonmee', 'AF9366572', '0884864457', 'kanokwan.boonmee@example.com', 'Normal'),
  ('Malai Kongkaew', 'AE9055254', '0981436016', 'malai.kongkaew@example.com', 'Normal'),
  ('Manop Sirikul', 'AH2978795', '0825261837', 'manop.sirikul@example.com', 'Normal'),
  ('Sasithorn Sangthong', 'AE0761639', '0879154664', 'sasithorn.sangthong@example.com', 'Normal'),
  ('Darunee Chantarasak', 'AH7416623', '0606816303', 'darunee.chantarasak@example.com', 'Normal'),
  ('Preeda Yodsri', 'AH4590571', '0605227077', 'preeda.yodsri@example.com', 'Normal'),
  ('Sunee Lertsiri', 'AH6947353', '0991924204', 'sunee.lertsiri@example.com', 'Normal'),
  ('Sombat Suksai', 'AF4356098', '0606217653', 'sombat.suksai@example.com', 'Normal'),
  ('Hui Min Goh', 'K5562118J', '+6596009500', 'hui.min.goh@example.sg', 'Normal'),
  ('Sombat Phromma', 'AG7494888', '0938393058', 'sombat.phromma@example.com', 'Normal'),
  ('Sasithorn Khamsuk', 'AG3211827', '0932008641', 'sasithorn.khamsuk@example.com', 'Normal'),
  ('Arjun Teo', 'K2849135S', '+6585109502', 'arjun.teo@example.sg', 'Normal'),
  ('Narong Phanthong', 'AH3728290', '0657887243', 'narong.phanthong@example.com', 'Silver'),
  ('Chalida Saelim', 'AG9849800', '0839243390', 'chalida.saelim@example.com', 'Normal'),
  ('Aaron Goh', 'K1447223W', '+6593597128', 'aaron.goh@example.sg', 'Gold'),
  ('Kittipong Inthasorn', 'AF2780097', '0928844674', 'kittipong.inthasorn@example.com', 'Normal'),
  ('Warunee Kongkaew', 'AH6304926', '0877980231', 'warunee.kongkaew@example.com', 'Normal'),
  ('Latsamy Douangphachanh', 'LA8579775', '+8562009150499', 'latsamy.douangphachanh@example.la', 'Silver'),
  ('Panya Chantarasak', 'AG0750909', '0804567050', 'panya.chantarasak@example.com', 'Normal'),
  ('Benjamas Lertsiri', 'AE0586861', '0948147628', 'benjamas.lertsiri@example.com', 'Silver'),
  ('Dao Wattana', 'AF3793539', '0947896738', 'dao.wattana@example.com', 'Normal'),
  ('Dao Phanthong', 'AE1724001', '0974912655', 'dao.phanthong@example.com', 'Normal'),
  ('Charoen Thongdee', 'AE2340681', '0838969990', 'charoen.thongdee@example.com', 'Silver'),
  ('Dao Nakprasert', 'AG9946074', '0625959327', 'dao.nakprasert@example.com', 'Gold'),
  ('Arthit Kongkaew', 'AH8284407', '0606767453', 'arthit.kongkaew@example.com', 'Silver'),
  ('Rattana Meesuk', 'AE4674808', '0843892920', 'rattana.meesuk@example.com', 'Normal'),
  ('Pong Lertsiri', 'AF9257821', '0631043003', 'pong.lertsiri@example.com', 'Normal'),
  ('Charoen Yodsri', 'AG3628064', '0667395616', 'charoen.yodsri@example.com', 'Normal'),
  ('Panya Kaewkla', 'AF4328728', '0902195590', 'panya.kaewkla@example.com', 'Normal'),
  ('Chaiwat Yodsri', 'AG0178234', '0943175570', 'chaiwat.yodsri@example.com', 'Silver'),
  ('Vilayvanh Xaysana', 'LA4942127', '+8562031322353', 'vilayvanh.xaysana@example.la', 'Normal'),
  ('Chanthala Xaysana', 'LA4040085', '+8562001188648', 'chanthala.xaysana@example.la', 'Normal'),
  ('Chanthala Douangphachanh', 'LA0072592', '+8562087194816', 'chanthala.douangphachanh@example.la', 'Normal'),
  ('Anan Boonmee', 'AH5663063', '0845131765', 'anan.boonmee@example.com', 'Gold'),
  ('Hui Min Chua', 'K6495948D', '+6595853136', 'hui.min.chua@example.sg', 'Normal'),
  ('Narong Phromma', 'AF4525288', '0848999358', 'narong.phromma@example.com', 'Normal'),
  ('Benjamas Chaiyaporn', 'AE4311317', '0882939675', 'benjamas.chaiyaporn@example.com', 'Normal'),
  ('Chanida Suksai', 'AG7831382', '0681414061', 'chanida.suksai@example.com', 'Normal'),
  ('Nong Lertsiri', 'AF4259362', '0681334995', 'nong.lertsiri@example.com', 'Normal'),
  ('Napat Kaewkla', 'AF9260750', '0829119420', 'napat.kaewkla@example.com', 'Normal'),
  ('Noy Xaysana', 'LA1591414', '+8562056259227', 'noy.xaysana@example.la', 'Normal'),
  ('Vilayvanh Vongsavath', 'LA4866875', '+8562002304710', 'vilayvanh.vongsavath@example.la', 'Silver'),
  ('Rattana Khamsuk', 'AH6602219', '0900272441', 'rattana.khamsuk@example.com', 'Normal'),
  ('Anan Meesuk', 'AF3692160', '0998959392', 'anan.meesuk@example.com', 'Normal'),
  ('Chaiwat Khamsuk', 'AE2618055', '0881720161', 'chaiwat.khamsuk@example.com', 'Silver'),
  ('Yupin Suksai', 'AG5547390', '0857778586', 'yupin.suksai@example.com', 'Silver'),
  ('Suda Inthasorn', 'AE8173658', '0960508992', 'suda.inthasorn@example.com', 'Silver'),
  ('Darunee Lertsiri', 'AE7263387', '0994071340', 'darunee.lertsiri@example.com', 'Normal'),
  ('Arjun Rajan', 'K5411639P', '+6597248562', 'arjun.rajan@example.sg', 'Normal'),
  ('Napat Suksai', 'AH9497050', '0996066826', 'napat.suksai@example.com', 'Gold'),
  ('Darunee Wongsakul', 'AG6952409', '0811991314', 'darunee.wongsakul@example.com', 'Normal'),
  ('Thida Lertsiri', 'AE1728215', '0980720856', 'thida.lertsiri@example.com', 'Normal'),
  ('Noy Douangphachanh', 'LA6260741', '+8562048065875', 'noy.douangphachanh@example.la', 'Silver'),
  ('Clement Ismail', 'K2337793S', '+6582419399', 'clement.ismail@example.sg', 'Normal'),
  ('Prasert Srisawat', 'AG1471109', '0809538679', 'prasert.srisawat@example.com', 'Normal'),
  ('Ekachai Inthasorn', 'AF1193973', '0924247174', 'ekachai.inthasorn@example.com', 'Normal'),
  ('Nipon Kongkaew', 'AH0955730', '0912711448', 'nipon.kongkaew@example.com', 'Normal'),
  ('Malai Somboon', 'AG1354250', '0652971571', 'malai.somboon@example.com', 'Gold'),
  ('Thida Thongdee', 'AE1119320', '0626125096', 'thida.thongdee@example.com', 'Normal'),
  ('Siti Ismail', 'K4740364T', '+6599297572', 'siti.ismail@example.sg', 'Normal'),
  ('Pimchanok Srisawat', 'AG6913825', '0999993571', 'pimchanok.srisawat@example.com', 'Normal'),
  ('Dao Meesuk', 'AF1940119', '0987069598', 'dao.meesuk@example.com', 'Normal'),
  ('Sakda Kaewkla', 'AE4197723', '0679202789', 'sakda.kaewkla@example.com', 'Normal'),
  ('Malai Jantarawong', 'AF0136794', '0827181675', 'malai.jantarawong@example.com', 'Silver'),
  ('Wei Ling Rajan', 'K9264230J', '+6597157129', 'wei.ling.rajan@example.sg', 'Normal'),
  ('Sunee Jantarawong', 'AF0766063', '0924798526', 'sunee.jantarawong@example.com', 'Normal'),
  ('Wanida Nakprasert', 'AE8697599', '0697257356', 'wanida.nakprasert@example.com', 'Normal'),
  ('Malai Chantarasak', 'AH0962515', '0893587586', 'malai.chantarasak@example.com', 'Silver'),
  ('Aaron Wong', 'K9080845U', '+6594220674', 'aaron.wong@example.sg', 'Gold'),
  ('Orathai Thongdee', 'AG2939938', '0818113105', 'orathai.thongdee@example.com', 'Normal'),
  ('Kulap Phanthong', 'AE8653871', '0838878509', 'kulap.phanthong@example.com', 'Gold'),
  ('Vilayvanh Sayavong', 'LA5027809', '+8562031486463', 'vilayvanh.sayavong@example.la', 'Normal'),
  ('Pimchanok Suksai', 'AE9783807', '0840308690', 'pimchanok.suksai@example.com', 'Normal'),
  ('Nipon Srisawat', 'AH4944630', '0873911055', 'nipon.srisawat@example.com', 'Normal'),
  ('Orathai Lertsiri', 'AE6677642', '0951919952', 'orathai.lertsiri@example.com', 'Normal'),
  ('Narong Wattana', 'AG4379389', '0957715473', 'narong.wattana@example.com', 'Normal'),
  ('Chalida Lertsiri', 'AF3290522', '0909210308', 'chalida.lertsiri@example.com', 'Gold'),
  ('Sunee Rattanakul', 'AE1883754', '0853685451', 'sunee.rattanakul@example.com', 'Normal'),
  ('Yupin Thongdee', 'AG6801869', '0673136691', 'yupin.thongdee@example.com', 'Normal'),
  ('Ekachai Wongsakul', 'AF1143837', '0929074846', 'ekachai.wongsakul@example.com', 'Normal'),
  ('Ekachai Srisawat', 'AF9084738', '0600219146', 'ekachai.srisawat@example.com', 'Normal'),
  ('Thongla Keomanivong', 'LA7748544', '+8562028611785', 'thongla.keomanivong@example.la', 'Silver'),
  ('Arthit Somboon', 'AF1924236', '0986364906', 'arthit.somboon@example.com', 'Silver'),
  ('Arjun Ismail', 'K5946148Z', '+6585486314', 'arjun.ismail@example.sg', 'Gold'),
  ('Sombat Nakprasert', 'AF1513794', '0938715146', 'sombat.nakprasert@example.com', 'Silver'),
  ('Yupin Nakprasert', 'AF9852867', '0670283480', 'yupin.nakprasert@example.com', 'Normal');

-- STAFF + subtypes (BR14: each staff member is in exactly one subtype;
-- the schema blocks two subtypes, Q8b checks that none is missing) --
INSERT INTO STAFF (StaffName, StaffRole) VALUES
  ('Ploy Srisuk',    'BookingStaff'),   -- 1
  ('Anan Wongsa',    'BookingStaff'),   -- 2
  ('Malee Thongdee', 'CheckInStaff'),   -- 3
  ('Chai Boonmee',   'CheckInStaff');   -- 4

INSERT INTO BOOKINGSTAFF (StaffID, SalesOffice) VALUES
  (1, 'Bangkok Silom Office'),
  (2, 'Chiang Mai Office');
INSERT INTO CHECKINSTAFF (StaffID, CounterNo) VALUES
  (3, 'A12'),
  (4, 'B03');

-- SEAT: SeatID = (AircraftID - 1) * 12 + position --------------------------
INSERT INTO SEAT (AircraftID, SeatNo, SeatClass) VALUES
  -- aircraft 1 (ATR 72-600): seats 1-12
  (1, '1A', 'Business'), (1, '1B', 'Business'), (1, '1C', 'Business'), (1, '1D', 'Business'),
  (1, '2A', 'Economy'), (1, '2B', 'Economy'), (1, '2C', 'Economy'), (1, '2D', 'Economy'), (1, '3A', 'Economy'), (1, '3B', 'Economy'), (1, '3C', 'Economy'), (1, '3D', 'Economy'),
  -- aircraft 2 (ATR 72-600): seats 13-24
  (2, '1A', 'Business'), (2, '1B', 'Business'), (2, '1C', 'Business'), (2, '1D', 'Business'),
  (2, '2A', 'Economy'), (2, '2B', 'Economy'), (2, '2C', 'Economy'), (2, '2D', 'Economy'), (2, '3A', 'Economy'), (2, '3B', 'Economy'), (2, '3C', 'Economy'), (2, '3D', 'Economy'),
  -- aircraft 3 (Airbus A320): seats 25-36
  (3, '1A', 'Business'), (3, '1B', 'Business'), (3, '1C', 'Business'), (3, '1D', 'Business'),
  (3, '2A', 'Economy'), (3, '2B', 'Economy'), (3, '2C', 'Economy'), (3, '2D', 'Economy'), (3, '3A', 'Economy'), (3, '3B', 'Economy'), (3, '3C', 'Economy'), (3, '3D', 'Economy'),
  -- aircraft 4 (Airbus A320): seats 37-48
  (4, '1A', 'Business'), (4, '1B', 'Business'), (4, '1C', 'Business'), (4, '1D', 'Business'),
  (4, '2A', 'Economy'), (4, '2B', 'Economy'), (4, '2C', 'Economy'), (4, '2D', 'Economy'), (4, '3A', 'Economy'), (4, '3B', 'Economy'), (4, '3C', 'Economy'), (4, '3D', 'Economy'),
  -- aircraft 5 (Embraer E190): seats 49-60
  (5, '1A', 'Business'), (5, '1B', 'Business'), (5, '1C', 'Business'), (5, '1D', 'Business'),
  (5, '2A', 'Economy'), (5, '2B', 'Economy'), (5, '2C', 'Economy'), (5, '2D', 'Economy'), (5, '3A', 'Economy'), (5, '3B', 'Economy'), (5, '3C', 'Economy'), (5, '3D', 'Economy'),
  -- aircraft 6 (Airbus A321): seats 61-72
  (6, '1A', 'Business'), (6, '1B', 'Business'), (6, '1C', 'Business'), (6, '1D', 'Business'),
  (6, '2A', 'Economy'), (6, '2B', 'Economy'), (6, '2C', 'Economy'), (6, '2D', 'Economy'), (6, '3A', 'Economy'), (6, '3B', 'Economy'), (6, '3C', 'Economy'), (6, '3D', 'Economy');

-- aircraft 7 (Boeing 787-9): seats 73-90, aircraft 8 (Airbus A350-900): seats 91-108
-- row 1 FirstClass, row 2 Business, rows 3-5 Economy
INSERT INTO SEAT (AircraftID, SeatNo, SeatClass) VALUES
  (7, '1A', 'FirstClass'), (7, '1B', 'FirstClass'), (7, '2A', 'Business'), (7, '2B', 'Business'), (7, '2C', 'Business'), (7, '2D', 'Business'), (7, '3A', 'Economy'), (7, '3B', 'Economy'), (7, '3C', 'Economy'), (7, '3D', 'Economy'), (7, '4A', 'Economy'), (7, '4B', 'Economy'), (7, '4C', 'Economy'), (7, '4D', 'Economy'), (7, '5A', 'Economy'), (7, '5B', 'Economy'), (7, '5C', 'Economy'), (7, '5D', 'Economy'),
  (8, '1A', 'FirstClass'), (8, '1B', 'FirstClass'), (8, '2A', 'Business'), (8, '2B', 'Business'), (8, '2C', 'Business'), (8, '2D', 'Business'), (8, '3A', 'Economy'), (8, '3B', 'Economy'), (8, '3C', 'Economy'), (8, '3D', 'Economy'), (8, '4A', 'Economy'), (8, '4B', 'Economy'), (8, '4C', 'Economy'), (8, '4D', 'Economy'), (8, '5A', 'Economy'), (8, '5B', 'Economy'), (8, '5C', 'Economy'), (8, '5D', 'Economy');

-- ROUTE: each flight number always flies the same route ------------------
INSERT INTO ROUTE (FlightNo, OriginCode, DestinationCode) VALUES
  ('MW101', 'BKK', 'CNX'),
  ('MW102', 'CNX', 'BKK'),
  ('MW201', 'BKK', 'HKT'),
  ('MW301', 'BKK', 'SIN'),
  ('MW401', 'HKT', 'USM'),
  ('MW501', 'BKK', 'VTE');

-- return legs, Krabi, and the long-haul routes
INSERT INTO ROUTE (FlightNo, OriginCode, DestinationCode) VALUES
  ('MW202', 'HKT', 'BKK'),
  ('MW302', 'SIN', 'BKK'),
  ('MW402', 'USM', 'HKT'),
  ('MW502', 'VTE', 'BKK'),
  ('MW601', 'BKK', 'KBV'),
  ('MW602', 'KBV', 'BKK'),
  ('MW801', 'BKK', 'NRT'),
  ('MW802', 'NRT', 'BKK'),
  ('MW901', 'BKK', 'HKG'),
  ('MW902', 'HKG', 'BKK');

-- FLIGHT: dated departures of the routes above ---------------------------
INSERT INTO FLIGHT (FlightNo, AircraftID, DepartureTime, ArrivalTime, Status, Gate) VALUES
  -- September 2026 (already flown)
  ('MW101', 1, '2026-09-10 08:00', '2026-09-10 09:15', 'OnTime', 'A1'),   -- 1
  ('MW102', 1, '2026-09-10 10:30', '2026-09-10 11:45', 'OnTime', 'B2'),   -- 2
  ('MW201', 3, '2026-09-15 09:00', '2026-09-15 10:25', 'Delayed', 'A3'),  -- 3
  ('MW301', 4, '2026-09-20 13:00', '2026-09-20 16:20', 'OnTime', 'C1'),   -- 4
  ('MW401', 2, '2026-09-25 15:00', '2026-09-25 16:00', 'OnTime', 'D2'),   -- 5
  -- October 2026 (upcoming)
  ('MW101', 1, '2026-10-20 08:00', '2026-10-20 09:15', 'OnTime', 'A2'),   -- 6  <- Q1 example
  ('MW102', 1, '2026-10-20 10:30', '2026-10-20 11:45', 'OnTime', 'B1'),   -- 7
  ('MW201', 3, '2026-10-21 09:00', '2026-10-21 10:25', 'OnTime', 'A4'),   -- 8
  ('MW501', 5, '2026-10-22 11:00', '2026-10-22 12:10', 'OnTime', 'C2'),   -- 9
  ('MW301', 4, '2026-10-25 13:00', '2026-10-25 16:20', 'OnTime', 'C3');   -- 10

-- 11-34: November and December 2026 (upcoming)
INSERT INTO FLIGHT (FlightNo, AircraftID, DepartureTime, ArrivalTime, Status, Gate) VALUES
  ('MW101', 1, '2026-11-05 08:00', '2026-11-05 09:15', 'OnTime', 'A2'),   -- 11
  ('MW102', 1, '2026-11-05 10:30', '2026-11-05 11:45', 'OnTime', 'B1'),   -- 12
  ('MW201', 3, '2026-11-06 09:00', '2026-11-06 10:25', 'OnTime', 'A4'),   -- 13
  ('MW202', 3, '2026-11-06 11:30', '2026-11-06 12:55', 'OnTime', 'B3'),   -- 14
  ('MW801', 7, '2026-11-08 23:30', '2026-11-09 07:45', 'OnTime', 'E1'),   -- 15
  ('MW802', 7, '2026-11-10 10:30', '2026-11-10 15:30', 'OnTime', 'E2'),   -- 16
  ('MW301', 4, '2026-11-12 13:00', '2026-11-12 16:20', 'OnTime', 'C1'),   -- 17
  ('MW302', 4, '2026-11-12 17:30', '2026-11-12 19:00', 'OnTime', 'C4'),   -- 18
  ('MW601', 2, '2026-11-14 07:30', '2026-11-14 08:50', 'OnTime', 'D1'),   -- 19
  ('MW602', 2, '2026-11-14 10:00', '2026-11-14 11:20', 'OnTime', 'D3'),   -- 20
  ('MW901', 8, '2026-11-18 09:00', '2026-11-18 12:45', 'OnTime', 'E3'),   -- 21
  ('MW902', 8, '2026-11-18 14:30', '2026-11-18 18:15', 'OnTime', 'E4'),   -- 22
  ('MW501', 5, '2026-11-20 11:00', '2026-11-20 12:10', 'OnTime', 'C2'),   -- 23
  ('MW502', 5, '2026-11-20 13:30', '2026-11-20 14:40', 'OnTime', 'C3'),   -- 24
  ('MW401', 2, '2026-11-25 15:00', '2026-11-25 16:00', 'OnTime', 'D2'),   -- 25
  ('MW402', 2, '2026-11-25 17:00', '2026-11-25 18:00', 'OnTime', 'D4'),   -- 26
  ('MW101', 1, '2026-12-18 08:00', '2026-12-18 09:15', 'OnTime', 'A1'),   -- 27
  ('MW102', 1, '2026-12-18 10:30', '2026-12-18 11:45', 'OnTime', 'B2'),   -- 28
  ('MW801', 7, '2026-12-20 23:30', '2026-12-21 07:45', 'OnTime', 'E1'),   -- 29
  ('MW901', 8, '2026-12-23 09:00', '2026-12-23 12:45', 'OnTime', 'E3'),   -- 30
  ('MW201', 3, '2026-12-24 09:00', '2026-12-24 10:25', 'OnTime', 'A3'),   -- 31
  ('MW802', 7, '2026-12-27 10:30', '2026-12-27 15:30', 'OnTime', 'E2'),   -- 32
  ('MW902', 8, '2026-12-28 14:30', '2026-12-28 18:15', 'OnTime', 'E4'),   -- 33
  ('MW601', 2, '2026-12-29 07:30', '2026-12-29 08:50', 'OnTime', 'D1');   -- 34

-- FARE: FareID = 2 * FlightID - 1 (Economy) and 2 * FlightID (Business) -------
INSERT INTO FARE (FlightID, Class, Price) VALUES
  (1,  'Economy', 1500.00), (1,  'Business', 4500.00),  -- 1, 2
  (2,  'Economy', 1500.00), (2,  'Business', 4500.00),  -- 3, 4
  (3,  'Economy', 1800.00), (3,  'Business', 5200.00),  -- 5, 6
  (4,  'Economy', 3900.00), (4,  'Business', 9800.00),  -- 7, 8
  (5,  'Economy', 1200.00), (5,  'Business', 3500.00),  -- 9, 10
  (6,  'Economy', 1500.00), (6,  'Business', 4500.00),  -- 11, 12
  (7,  'Economy', 1500.00), (7,  'Business', 4500.00),  -- 13, 14
  (8,  'Economy', 1800.00), (8,  'Business', 5200.00),  -- 15, 16
  (9,  'Economy', 2500.00), (9,  'Business', 6500.00),  -- 17, 18
  (10, 'Economy', 3900.00), (10, 'Business', 9800.00);  -- 19, 20

-- 21-75: fares for flights 11-34 (FirstClass on aircraft 7 and 8)
INSERT INTO FARE (FlightID, Class, Price) VALUES
  (11, 'Economy', 1500.00),
  (11, 'Business', 4500.00),
  (12, 'Economy', 1500.00),
  (12, 'Business', 4500.00),
  (13, 'Economy', 1800.00),
  (13, 'Business', 5200.00),
  (14, 'Economy', 1800.00),
  (14, 'Business', 5200.00),
  (15, 'Economy', 9500.00),
  (15, 'Business', 24000.00),
  (15, 'FirstClass', 52000.00),
  (16, 'Economy', 9500.00),
  (16, 'Business', 24000.00),
  (16, 'FirstClass', 52000.00),
  (17, 'Economy', 3900.00),
  (17, 'Business', 9800.00),
  (18, 'Economy', 3900.00),
  (18, 'Business', 9800.00),
  (19, 'Economy', 1600.00),
  (19, 'Business', 4800.00),
  (20, 'Economy', 1600.00),
  (20, 'Business', 4800.00),
  (21, 'Economy', 5200.00),
  (21, 'Business', 14500.00),
  (21, 'FirstClass', 31000.00),
  (22, 'Economy', 5200.00),
  (22, 'Business', 14500.00),
  (22, 'FirstClass', 31000.00),
  (23, 'Economy', 2500.00),
  (23, 'Business', 6500.00),
  (24, 'Economy', 2500.00),
  (24, 'Business', 6500.00),
  (25, 'Economy', 1200.00),
  (25, 'Business', 3500.00),
  (26, 'Economy', 1200.00),
  (26, 'Business', 3500.00),
  (27, 'Economy', 1500.00),
  (27, 'Business', 4500.00),
  (28, 'Economy', 1500.00),
  (28, 'Business', 4500.00),
  (29, 'Economy', 9500.00),
  (29, 'Business', 24000.00),
  (29, 'FirstClass', 52000.00),
  (30, 'Economy', 5200.00),
  (30, 'Business', 14500.00),
  (30, 'FirstClass', 31000.00),
  (31, 'Economy', 1800.00),
  (31, 'Business', 5200.00),
  (32, 'Economy', 9500.00),
  (32, 'Business', 24000.00),
  (32, 'FirstClass', 52000.00),
  (33, 'Economy', 5200.00),
  (33, 'Business', 14500.00),
  (33, 'FirstClass', 31000.00),
  (34, 'Economy', 1600.00),
  (34, 'Business', 4800.00);

-- FARE_CONDITION -----------------------------------------------------
INSERT INTO FARE_CONDITION (ConditionName, Description) VALUES
  ('Refundable',          'Money back if the passenger cancels'),            -- 1
  ('Changeable',          'Date or flight can be changed before departure'), -- 2
  ('Free seat selection', 'Passenger chooses any free seat at no cost'),     -- 3
  ('Priority boarding',   'Boards the aircraft first');                      -- 4

-- FARE_RULE (bridge) -------------------------------------------------
-- Economy fares (odd FareID): changeable for a 500 THB fee.
-- Business fares (even FareID): refundable, changeable, free seat selection
-- and priority boarding, all with no fee.
INSERT INTO FARE_RULE (FareID, ConditionID, Fee) VALUES
  (1, 2, 500.00),
  (2, 1, 0.00), (2, 2, 0.00), (2, 3, 0.00), (2, 4, 0.00),
  (3, 2, 500.00),
  (4, 1, 0.00), (4, 2, 0.00), (4, 3, 0.00), (4, 4, 0.00),
  (5, 2, 500.00),
  (6, 1, 0.00), (6, 2, 0.00), (6, 3, 0.00), (6, 4, 0.00),
  (7, 2, 500.00),
  (8, 1, 0.00), (8, 2, 0.00), (8, 3, 0.00), (8, 4, 0.00),
  (9, 2, 500.00),
  (10, 1, 0.00), (10, 2, 0.00), (10, 3, 0.00), (10, 4, 0.00),
  (11, 2, 500.00),
  (12, 1, 0.00), (12, 2, 0.00), (12, 3, 0.00), (12, 4, 0.00),
  (13, 2, 500.00),
  (14, 1, 0.00), (14, 2, 0.00), (14, 3, 0.00), (14, 4, 0.00),
  (15, 2, 500.00),
  (16, 1, 0.00), (16, 2, 0.00), (16, 3, 0.00), (16, 4, 0.00),
  (17, 2, 500.00),
  (18, 1, 0.00), (18, 2, 0.00), (18, 3, 0.00), (18, 4, 0.00),
  (19, 2, 500.00),
  (20, 1, 0.00), (20, 2, 0.00), (20, 3, 0.00), (20, 4, 0.00);

-- fares 21-75: same conditions as above (Economy changeable, Business and FirstClass everything)
INSERT INTO FARE_RULE (FareID, ConditionID, Fee) VALUES
  (21, 2, 500.00),
  (22, 1, 0.00), (22, 2, 0.00), (22, 3, 0.00), (22, 4, 0.00),
  (23, 2, 500.00),
  (24, 1, 0.00), (24, 2, 0.00), (24, 3, 0.00), (24, 4, 0.00),
  (25, 2, 500.00),
  (26, 1, 0.00), (26, 2, 0.00), (26, 3, 0.00), (26, 4, 0.00),
  (27, 2, 500.00),
  (28, 1, 0.00), (28, 2, 0.00), (28, 3, 0.00), (28, 4, 0.00),
  (29, 2, 500.00),
  (30, 1, 0.00), (30, 2, 0.00), (30, 3, 0.00), (30, 4, 0.00),
  (31, 1, 0.00), (31, 2, 0.00), (31, 3, 0.00), (31, 4, 0.00),
  (32, 2, 500.00),
  (33, 1, 0.00), (33, 2, 0.00), (33, 3, 0.00), (33, 4, 0.00),
  (34, 1, 0.00), (34, 2, 0.00), (34, 3, 0.00), (34, 4, 0.00),
  (35, 2, 500.00),
  (36, 1, 0.00), (36, 2, 0.00), (36, 3, 0.00), (36, 4, 0.00),
  (37, 2, 500.00),
  (38, 1, 0.00), (38, 2, 0.00), (38, 3, 0.00), (38, 4, 0.00),
  (39, 2, 500.00),
  (40, 1, 0.00), (40, 2, 0.00), (40, 3, 0.00), (40, 4, 0.00),
  (41, 2, 500.00),
  (42, 1, 0.00), (42, 2, 0.00), (42, 3, 0.00), (42, 4, 0.00),
  (43, 2, 500.00),
  (44, 1, 0.00), (44, 2, 0.00), (44, 3, 0.00), (44, 4, 0.00),
  (45, 1, 0.00), (45, 2, 0.00), (45, 3, 0.00), (45, 4, 0.00),
  (46, 2, 500.00),
  (47, 1, 0.00), (47, 2, 0.00), (47, 3, 0.00), (47, 4, 0.00),
  (48, 1, 0.00), (48, 2, 0.00), (48, 3, 0.00), (48, 4, 0.00),
  (49, 2, 500.00),
  (50, 1, 0.00), (50, 2, 0.00), (50, 3, 0.00), (50, 4, 0.00),
  (51, 2, 500.00),
  (52, 1, 0.00), (52, 2, 0.00), (52, 3, 0.00), (52, 4, 0.00),
  (53, 2, 500.00),
  (54, 1, 0.00), (54, 2, 0.00), (54, 3, 0.00), (54, 4, 0.00),
  (55, 2, 500.00),
  (56, 1, 0.00), (56, 2, 0.00), (56, 3, 0.00), (56, 4, 0.00),
  (57, 2, 500.00),
  (58, 1, 0.00), (58, 2, 0.00), (58, 3, 0.00), (58, 4, 0.00),
  (59, 2, 500.00),
  (60, 1, 0.00), (60, 2, 0.00), (60, 3, 0.00), (60, 4, 0.00),
  (61, 2, 500.00),
  (62, 1, 0.00), (62, 2, 0.00), (62, 3, 0.00), (62, 4, 0.00),
  (63, 1, 0.00), (63, 2, 0.00), (63, 3, 0.00), (63, 4, 0.00),
  (64, 2, 500.00),
  (65, 1, 0.00), (65, 2, 0.00), (65, 3, 0.00), (65, 4, 0.00),
  (66, 1, 0.00), (66, 2, 0.00), (66, 3, 0.00), (66, 4, 0.00),
  (67, 2, 500.00),
  (68, 1, 0.00), (68, 2, 0.00), (68, 3, 0.00), (68, 4, 0.00),
  (69, 2, 500.00),
  (70, 1, 0.00), (70, 2, 0.00), (70, 3, 0.00), (70, 4, 0.00),
  (71, 1, 0.00), (71, 2, 0.00), (71, 3, 0.00), (71, 4, 0.00),
  (72, 2, 500.00),
  (73, 1, 0.00), (73, 2, 0.00), (73, 3, 0.00), (73, 4, 0.00),
  (74, 1, 0.00), (74, 2, 0.00), (74, 3, 0.00), (74, 4, 0.00),
  (75, 2, 500.00),
  (76, 1, 0.00), (76, 2, 0.00), (76, 3, 0.00), (76, 4, 0.00);

-- RESERVATION --------------------------------------------------------
INSERT INTO RESERVATION (PassengerID, BookingStaffID, BookingDate, ReservationStatus) VALUES
  (1, 1,    '2026-09-01', 'Confirmed'),   -- 1  Somsak: BKK->CNX->BKK return trip in September
  (2, 2,    '2026-09-05', 'Confirmed'),   -- 2  Nara: Business to Phuket
  (8, 1,    '2026-09-08', 'Confirmed'),   -- 3  Daniel: to Singapore
  (5, 2,    '2026-09-12', 'Cancelled'),   -- 4  Siriporn: cancelled and refunded
  (3, 1,    '2026-10-01', 'Confirmed'),   -- 5  Wichai: family of 3 on MW101, 20 Oct
  (6, 2,    '2026-10-03', 'Held'),        -- 6  Tom: held, NOT paid yet
  (2, NULL, '2026-10-04', 'Confirmed'),   -- 7  Nara: booked online (no staff), Business to Vientiane
  (1, 1,    '2026-10-04', 'Held');        -- 8  Somsak: held, NOT paid yet

-- 9-41: more bookings for the 100 passengers (flight 6, MW101 20 Oct, is left
--        as it is for the live demo and Q1/Q7/Q10/Q18)
INSERT INTO RESERVATION (PassengerID, BookingStaffID, BookingDate, ReservationStatus) VALUES
  (98, 2, '2026-08-21', 'Confirmed'),
  (18, NULL, '2026-09-03', 'Confirmed'),
  (97, 1, '2026-08-25', 'Confirmed'),
  (78, 1, '2026-08-28', 'Confirmed'),
  (12, NULL, '2026-08-16', 'Confirmed'),
  (33, 1, '2026-09-04', 'Confirmed'),
  (43, NULL, '2026-08-29', 'Confirmed'),
  (50, 1, '2026-08-19', 'Confirmed'),
  (68, 1, '2026-09-05', 'Confirmed'),
  (16, 2, '2026-08-30', 'Confirmed'),
  (31, 1, '2026-08-20', 'Confirmed'),
  (93, 1, '2026-08-20', 'Confirmed'),
  (40, 1, '2026-08-23', 'Confirmed'),
  (26, 2, '2026-09-02', 'Confirmed'),
  (19, 1, '2026-08-29', 'Confirmed'),
  (90, 1, '2026-09-10', 'Confirmed'),
  (21, 2, '2026-09-13', 'Confirmed'),
  (83, 1, '2026-09-01', 'Confirmed'),
  (59, NULL, '2026-10-08', 'Held'),
  (11, 2, '2026-10-03', 'Confirmed'),
  (24, 1, '2026-10-03', 'Confirmed'),
  (77, NULL, '2026-10-10', 'Confirmed'),
  (53, 2, '2026-10-01', 'Confirmed'),
  (75, 2, '2026-10-05', 'Confirmed'),
  (55, 2, '2026-10-01', 'Confirmed'),
  (42, 2, '2026-10-11', 'Confirmed'),
  (9, 1, '2026-10-05', 'Confirmed'),
  (35, 2, '2026-09-28', 'Held'),
  (30, NULL, '2026-10-08', 'Confirmed'),
  (25, NULL, '2026-10-11', 'Confirmed'),
  (69, 2, '2026-10-07', 'Confirmed'),
  (63, 2, '2026-10-02', 'Confirmed'),
  (46, NULL, '2026-10-06', 'Confirmed');

-- 42-155: bookings on the November and December flights (Somsak has none,
--        so Q2 and the demo stay the same)
INSERT INTO RESERVATION (PassengerID, BookingStaffID, BookingDate, ReservationStatus) VALUES
  (13, NULL, '2026-10-03', 'Held'),
  (62, NULL, '2026-09-20', 'Held'),
  (45, 2, '2026-09-23', 'Held'),
  (74, NULL, '2026-10-07', 'Confirmed'),
  (99, NULL, '2026-09-23', 'Confirmed'),
  (33, 1, '2026-09-23', 'Cancelled'),
  (5, 2, '2026-09-25', 'Held'),
  (79, 2, '2026-09-21', 'Confirmed'),
  (82, 1, '2026-09-23', 'Confirmed'),
  (54, 1, '2026-10-04', 'Confirmed'),
  (38, 1, '2026-10-05', 'Confirmed'),
  (80, 1, '2026-09-20', 'Confirmed'),
  (28, 2, '2026-10-03', 'Confirmed'),
  (55, 1, '2026-10-04', 'Confirmed'),
  (54, 1, '2026-09-21', 'Confirmed'),
  (18, NULL, '2026-09-29', 'Confirmed'),
  (72, NULL, '2026-10-02', 'Confirmed'),
  (4, NULL, '2026-09-22', 'Confirmed'),
  (37, NULL, '2026-10-08', 'Confirmed'),
  (84, 2, '2026-10-06', 'Confirmed'),
  (97, NULL, '2026-09-27', 'Confirmed'),
  (2, 1, '2026-10-08', 'Confirmed'),
  (43, 1, '2026-09-28', 'Confirmed'),
  (96, 2, '2026-09-29', 'Confirmed'),
  (19, 2, '2026-10-08', 'Confirmed'),
  (86, 1, '2026-10-08', 'Confirmed'),
  (54, 1, '2026-09-24', 'Held'),
  (52, 2, '2026-10-08', 'Confirmed'),
  (93, NULL, '2026-09-24', 'Confirmed'),
  (37, 1, '2026-09-30', 'Held'),
  (60, NULL, '2026-09-30', 'Confirmed'),
  (23, 2, '2026-10-08', 'Held'),
  (2, 2, '2026-09-24', 'Confirmed'),
  (28, 2, '2026-10-07', 'Confirmed'),
  (11, 1, '2026-10-06', 'Confirmed'),
  (75, NULL, '2026-09-20', 'Confirmed'),
  (46, 2, '2026-09-21', 'Held'),
  (27, 2, '2026-09-27', 'Confirmed'),
  (68, NULL, '2026-09-22', 'Held'),
  (50, NULL, '2026-09-29', 'Confirmed'),
  (42, 2, '2026-10-08', 'Confirmed'),
  (32, NULL, '2026-09-29', 'Confirmed'),
  (22, NULL, '2026-09-26', 'Confirmed'),
  (62, 1, '2026-10-06', 'Confirmed'),
  (86, 2, '2026-09-30', 'Confirmed'),
  (83, 2, '2026-09-24', 'Held'),
  (25, NULL, '2026-10-05', 'Confirmed'),
  (56, NULL, '2026-09-30', 'Confirmed'),
  (71, NULL, '2026-10-06', 'Confirmed'),
  (7, 1, '2026-09-22', 'Held'),
  (40, 1, '2026-10-04', 'Confirmed'),
  (96, 1, '2026-10-04', 'Confirmed'),
  (16, NULL, '2026-10-03', 'Confirmed'),
  (76, NULL, '2026-09-26', 'Held'),
  (92, 2, '2026-10-04', 'Confirmed'),
  (90, 2, '2026-10-07', 'Confirmed'),
  (68, NULL, '2026-09-26', 'Confirmed'),
  (93, NULL, '2026-09-30', 'Confirmed'),
  (57, NULL, '2026-10-07', 'Confirmed'),
  (61, NULL, '2026-10-06', 'Held'),
  (37, 2, '2026-09-29', 'Confirmed'),
  (70, NULL, '2026-09-24', 'Held'),
  (62, 2, '2026-09-23', 'Confirmed'),
  (23, 1, '2026-10-01', 'Cancelled'),
  (42, 2, '2026-10-04', 'Confirmed'),
  (14, 1, '2026-10-01', 'Held'),
  (74, 2, '2026-09-27', 'Confirmed'),
  (46, 2, '2026-09-20', 'Confirmed'),
  (3, 2, '2026-10-03', 'Confirmed'),
  (40, NULL, '2026-10-04', 'Held'),
  (74, NULL, '2026-10-05', 'Confirmed'),
  (34, NULL, '2026-09-25', 'Confirmed'),
  (53, 2, '2026-10-04', 'Confirmed'),
  (27, NULL, '2026-09-21', 'Cancelled'),
  (37, NULL, '2026-10-02', 'Confirmed'),
  (21, 1, '2026-10-01', 'Confirmed'),
  (87, 2, '2026-09-21', 'Confirmed'),
  (72, 2, '2026-09-27', 'Confirmed'),
  (34, 2, '2026-09-21', 'Confirmed'),
  (86, NULL, '2026-09-30', 'Confirmed'),
  (17, 1, '2026-09-22', 'Confirmed'),
  (57, NULL, '2026-10-06', 'Confirmed'),
  (43, 1, '2026-10-04', 'Confirmed'),
  (100, 1, '2026-09-30', 'Held'),
  (92, 2, '2026-09-27', 'Confirmed'),
  (32, 1, '2026-09-30', 'Held'),
  (75, NULL, '2026-10-08', 'Held'),
  (34, 2, '2026-09-26', 'Held'),
  (95, 2, '2026-10-07', 'Confirmed'),
  (10, 2, '2026-09-21', 'Cancelled'),
  (98, NULL, '2026-09-23', 'Held'),
  (17, NULL, '2026-10-08', 'Confirmed'),
  (30, 2, '2026-09-23', 'Confirmed'),
  (5, 2, '2026-09-29', 'Confirmed'),
  (90, 1, '2026-09-27', 'Confirmed'),
  (60, NULL, '2026-10-05', 'Held'),
  (6, 2, '2026-10-04', 'Confirmed'),
  (10, NULL, '2026-10-06', 'Confirmed'),
  (14, 2, '2026-09-27', 'Confirmed'),
  (50, 2, '2026-10-03', 'Confirmed'),
  (100, 2, '2026-10-08', 'Confirmed'),
  (4, 1, '2026-09-29', 'Confirmed'),
  (63, 1, '2026-10-01', 'Confirmed'),
  (58, 1, '2026-09-25', 'Held'),
  (14, 1, '2026-10-06', 'Cancelled'),
  (85, NULL, '2026-10-04', 'Confirmed'),
  (43, 2, '2026-09-22', 'Confirmed'),
  (53, 1, '2026-09-20', 'Held'),
  (86, NULL, '2026-10-02', 'Confirmed'),
  (26, NULL, '2026-09-26', 'Held'),
  (61, 2, '2026-09-21', 'Confirmed'),
  (20, 1, '2026-10-03', 'Confirmed'),
  (36, 2, '2026-10-03', 'Cancelled'),
  (95, 1, '2026-10-05', 'Confirmed');

-- TICKET (bridge) ----------------------------------------------------
-- Columns: reservation, traveller, flight, seat, fare, issue date, status
-- The traveller is usually the booker; the family tickets (6-8) are booked by
-- Wichai (passenger 3) for himself, Ladda (4) and Mint (7).
INSERT INTO TICKET (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketIssueDate, TicketStatus) VALUES
  (1, 1, 1,  5,  1,  '2026-09-01', 'used'),       -- 1  Somsak   MW101 seat 2A Economy
  (1, 1, 2,  6,  3,  '2026-09-01', 'used'),       -- 2  Somsak   MW102 seat 2B Economy
  (2, 2, 3,  25, 6,  '2026-09-05', 'used'),       -- 3  Nara     MW201 seat 1A Business
  (3, 8, 4,  41, 7,  '2026-09-08', 'used'),       -- 4  Daniel   MW301 seat 2A Economy
  (4, 5, 5,  13, 10, '2026-09-12', 'cancelled'),  -- 5  Siriporn MW401 seat 1A Business (cancelled)
  (5, 3, 6,  5,  11, '2026-10-01', 'issued'),     -- 6  Wichai   MW101 20 Oct seat 2A (family)
  (5, 4, 6,  6,  11, '2026-10-01', 'issued'),     -- 7  Ladda    MW101 20 Oct seat 2B (family)
  (5, 7, 6,  7,  11, '2026-10-01', 'issued'),     -- 8  Mint     MW101 20 Oct seat 2C (family)
  (6, 6, 8,  29, 15, NULL,         'booked'),     -- 9  Tom      MW201 21 Oct seat 2A (not paid, so not issued: BR8)
  (7, 2, 9,  49, 18, '2026-10-04', 'issued'),     -- 10 Nara     MW501 22 Oct seat 1A Business
  (8, 1, 10, 42, 19, NULL,         'booked');     -- 11 Somsak   MW301 25 Oct seat 2B (not paid, so not issued: BR8)

-- 12-74: tickets for the reservations above (September ones are used,
--         October ones issued when paid, booked when held, cancelled when refunded)
INSERT INTO TICKET (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketIssueDate, TicketStatus) VALUES
  (9, 98, 1, 2, 2, '2026-08-21', 'used'),
  (9, 98, 2, 1, 4, '2026-08-21', 'used'),
  (10, 18, 1, 12, 1, '2026-09-03', 'used'),
  (11, 97, 1, 8, 1, '2026-08-25', 'used'),
  (11, 97, 2, 5, 3, '2026-08-25', 'used'),
  (12, 78, 1, 6, 1, '2026-08-28', 'used'),
  (12, 32, 1, 11, 1, '2026-08-28', 'used'),
  (12, 56, 1, 9, 1, '2026-08-28', 'used'),
  (13, 12, 1, 10, 1, '2026-08-16', 'used'),
  (13, 58, 1, 7, 1, '2026-08-16', 'used'),
  (14, 33, 2, 12, 3, '2026-09-04', 'used'),
  (14, 62, 2, 10, 3, '2026-09-04', 'used'),
  (15, 43, 2, 8, 3, '2026-08-29', 'used'),
  (15, 49, 2, 11, 3, '2026-08-29', 'used'),
  (15, 29, 2, 9, 3, '2026-08-29', 'used'),
  (16, 50, 2, 7, 3, '2026-08-19', 'used'),
  (17, 68, 3, 32, 5, '2026-09-05', 'used'),
  (18, 16, 3, 34, 5, '2026-08-30', 'used'),
  (18, 67, 3, 29, 5, '2026-08-30', 'used'),
  (19, 31, 3, 31, 5, '2026-08-20', 'used'),
  (19, 89, 3, 36, 5, '2026-08-20', 'used'),
  (19, 96, 3, 33, 5, '2026-08-20', 'used'),
  (20, 93, 3, 30, 5, '2026-08-20', 'used'),
  (21, 40, 3, 35, 5, '2026-08-23', 'used'),
  (22, 26, 4, 42, 7, '2026-09-02', 'used'),
  (22, 54, 4, 45, 7, '2026-09-02', 'used'),
  (23, 19, 4, 47, 7, '2026-08-29', 'used'),
  (23, 28, 4, 48, 7, '2026-08-29', 'used'),
  (23, 81, 4, 43, 7, '2026-08-29', 'used'),
  (24, 90, 4, 39, 8, '2026-09-10', 'used'),
  (24, 87, 4, 40, 8, '2026-09-10', 'used'),
  (24, 65, 4, 37, 8, '2026-09-10', 'used'),
  (25, 21, 5, 23, 9, '2026-09-13', 'used'),
  (26, 83, 5, 15, 10, '2026-09-01', 'used'),
  (26, 66, 5, 14, 10, '2026-09-01', 'used'),
  (26, 13, 5, 16, 10, '2026-09-01', 'used'),
  (27, 59, 7, 5, 13, NULL, 'booked'),
  (27, 39, 7, 12, 13, NULL, 'booked'),
  (28, 11, 7, 6, 13, '2026-10-03', 'issued'),
  (29, 24, 7, 8, 13, '2026-10-03', 'issued'),
  (29, 91, 7, 9, 13, '2026-10-03', 'issued'),
  (29, 74, 7, 10, 13, '2026-10-03', 'issued'),
  (30, 77, 7, 11, 13, '2026-10-10', 'issued'),
  (31, 53, 8, 36, 15, '2026-10-01', 'issued'),
  (31, 52, 8, 31, 15, '2026-10-01', 'issued'),
  (31, 34, 8, 33, 15, '2026-10-01', 'issued'),
  (32, 75, 8, 34, 15, '2026-10-05', 'issued'),
  (33, 55, 8, 30, 15, '2026-10-01', 'issued'),
  (34, 42, 8, 35, 15, '2026-10-11', 'issued'),
  (34, 20, 8, 32, 15, '2026-10-11', 'issued'),
  (35, 9, 9, 52, 18, '2026-10-05', 'issued'),
  (35, 15, 9, 51, 18, '2026-10-05', 'issued'),
  (35, 82, 9, 50, 18, '2026-10-05', 'issued'),
  (36, 35, 9, 56, 17, NULL, 'booked'),
  (36, 100, 9, 57, 17, NULL, 'booked'),
  (36, 45, 9, 54, 17, NULL, 'booked'),
  (37, 30, 10, 47, 19, '2026-10-08', 'issued'),
  (38, 25, 10, 43, 19, '2026-10-11', 'issued'),
  (39, 69, 10, 41, 19, '2026-10-07', 'issued'),
  (39, 94, 10, 45, 19, '2026-10-07', 'issued'),
  (40, 63, 10, 48, 19, '2026-10-02', 'issued'),
  (40, 37, 10, 46, 19, '2026-10-02', 'issued'),
  (41, 46, 10, 44, 19, '2026-10-06', 'issued');

-- 75-321: tickets for those reservations (issued when paid, booked when held,
--         cancelled when refunded)
INSERT INTO TICKET (ReservationID, PassengerID, FlightID, SeatID, FareID, TicketIssueDate, TicketStatus) VALUES
  (42, 13, 11, 5, 21, NULL, 'booked'),
  (42, 2, 11, 6, 21, NULL, 'booked'),
  (42, 96, 11, 7, 21, NULL, 'booked'),
  (42, 13, 12, 5, 23, NULL, 'booked'),
  (42, 2, 12, 10, 23, NULL, 'booked'),
  (42, 96, 12, 6, 23, NULL, 'booked'),
  (43, 62, 11, 8, 21, NULL, 'booked'),
  (43, 62, 12, 7, 23, NULL, 'booked'),
  (44, 45, 11, 9, 21, NULL, 'booked'),
  (44, 61, 11, 10, 21, NULL, 'booked'),
  (45, 74, 11, 11, 21, '2026-10-07', 'issued'),
  (45, 30, 11, 12, 21, '2026-10-07', 'issued'),
  (46, 99, 12, 4, 24, '2026-09-23', 'issued'),
  (47, 33, 12, 8, 23, '2026-09-23', 'cancelled'),
  (48, 5, 12, 1, 24, NULL, 'booked'),
  (48, 61, 12, 2, 24, NULL, 'booked'),
  (49, 79, 13, 33, 25, '2026-09-21', 'issued'),
  (49, 79, 14, 29, 27, '2026-09-21', 'issued'),
  (50, 82, 13, 27, 26, '2026-09-23', 'issued'),
  (50, 72, 13, 26, 26, '2026-09-23', 'issued'),
  (51, 54, 13, 29, 25, '2026-10-04', 'issued'),
  (52, 38, 13, 30, 25, '2026-10-05', 'issued'),
  (52, 63, 13, 36, 25, '2026-10-05', 'issued'),
  (52, 38, 14, 30, 27, '2026-10-05', 'issued'),
  (52, 63, 14, 36, 27, '2026-10-05', 'issued'),
  (53, 80, 13, 31, 25, '2026-09-20', 'issued'),
  (53, 58, 13, 32, 25, '2026-09-20', 'issued'),
  (54, 28, 13, 34, 25, '2026-10-03', 'issued'),
  (54, 28, 14, 31, 27, '2026-10-03', 'issued'),
  (55, 55, 14, 32, 27, '2026-10-04', 'issued'),
  (56, 54, 14, 34, 27, '2026-09-21', 'issued'),
  (56, 78, 14, 35, 27, '2026-09-21', 'issued'),
  (57, 18, 14, 25, 28, '2026-09-29', 'issued'),
  (57, 76, 14, 27, 28, '2026-09-29', 'issued'),
  (58, 72, 15, 74, 31, '2026-10-02', 'issued'),
  (59, 4, 15, 86, 29, '2026-09-22', 'issued'),
  (59, 80, 15, 85, 29, '2026-09-22', 'issued'),
  (59, 92, 15, 79, 29, '2026-09-22', 'issued'),
  (60, 37, 15, 73, 31, '2026-10-08', 'issued'),
  (61, 84, 15, 80, 29, '2026-10-06', 'issued'),
  (61, 60, 15, 81, 29, '2026-10-06', 'issued'),
  (62, 97, 15, 82, 29, '2026-09-27', 'issued'),
  (62, 97, 16, 79, 32, '2026-09-27', 'issued'),
  (63, 2, 15, 88, 29, '2026-10-08', 'issued'),
  (63, 11, 15, 83, 29, '2026-10-08', 'issued'),
  (63, 2, 16, 80, 32, '2026-10-08', 'issued'),
  (63, 11, 16, 81, 32, '2026-10-08', 'issued'),
  (64, 43, 15, 89, 29, '2026-09-28', 'issued'),
  (65, 96, 16, 87, 32, '2026-09-29', 'issued'),
  (65, 74, 16, 89, 32, '2026-09-29', 'issued'),
  (65, 32, 16, 82, 32, '2026-09-29', 'issued'),
  (66, 19, 16, 83, 32, '2026-10-08', 'issued'),
  (66, 85, 16, 84, 32, '2026-10-08', 'issued'),
  (67, 86, 16, 85, 32, '2026-10-08', 'issued'),
  (68, 54, 16, 90, 32, NULL, 'booked'),
  (68, 60, 16, 86, 32, NULL, 'booked'),
  (69, 52, 16, 88, 32, '2026-10-08', 'issued'),
  (70, 93, 17, 41, 35, '2026-09-24', 'issued'),
  (70, 96, 17, 42, 35, '2026-09-24', 'issued'),
  (70, 92, 17, 45, 35, '2026-09-24', 'issued'),
  (70, 93, 18, 41, 37, '2026-09-24', 'issued'),
  (70, 96, 18, 44, 37, '2026-09-24', 'issued'),
  (70, 92, 18, 42, 37, '2026-09-24', 'issued'),
  (71, 37, 17, 39, 36, NULL, 'booked'),
  (71, 37, 18, 37, 38, NULL, 'booked'),
  (72, 60, 17, 37, 36, '2026-09-30', 'issued'),
  (73, 23, 17, 46, 35, NULL, 'booked'),
  (73, 23, 18, 45, 37, NULL, 'booked'),
  (74, 2, 17, 38, 36, '2026-09-24', 'issued'),
  (74, 59, 17, 40, 36, '2026-09-24', 'issued'),
  (75, 28, 18, 43, 37, '2026-10-07', 'issued'),
  (76, 11, 18, 46, 37, '2026-10-06', 'issued'),
  (77, 75, 18, 47, 37, '2026-09-20', 'issued'),
  (78, 46, 19, 18, 39, NULL, 'booked'),
  (78, 35, 19, 19, 39, NULL, 'booked'),
  (78, 46, 20, 17, 41, NULL, 'booked'),
  (78, 35, 20, 22, 41, NULL, 'booked'),
  (79, 27, 19, 23, 39, '2026-09-27', 'issued'),
  (80, 68, 19, 17, 39, NULL, 'booked'),
  (81, 50, 19, 20, 39, '2026-09-29', 'issued'),
  (81, 49, 19, 21, 39, '2026-09-29', 'issued'),
  (82, 42, 19, 22, 39, '2026-10-08', 'issued'),
  (82, 82, 19, 24, 39, '2026-10-08', 'issued'),
  (83, 32, 19, 13, 40, '2026-09-29', 'issued'),
  (83, 32, 20, 13, 42, '2026-09-29', 'issued'),
  (84, 22, 20, 18, 41, '2026-09-26', 'issued'),
  (84, 59, 20, 21, 41, '2026-09-26', 'issued'),
  (84, 71, 20, 19, 41, '2026-09-26', 'issued'),
  (85, 62, 20, 20, 41, '2026-10-06', 'issued'),
  (86, 86, 21, 97, 43, '2026-09-30', 'issued'),
  (87, 83, 21, 91, 45, NULL, 'booked'),
  (87, 83, 22, 91, 48, NULL, 'booked'),
  (88, 25, 21, 104, 43, '2026-10-05', 'issued'),
  (88, 3, 21, 108, 43, '2026-10-05', 'issued'),
  (89, 56, 21, 92, 45, '2026-09-30', 'issued'),
  (89, 56, 22, 92, 48, '2026-09-30', 'issued'),
  (90, 71, 21, 98, 43, '2026-10-06', 'issued'),
  (91, 7, 21, 106, 43, NULL, 'booked'),
  (91, 49, 21, 99, 43, NULL, 'booked'),
  (91, 7, 22, 97, 46, NULL, 'booked'),
  (91, 49, 22, 98, 46, NULL, 'booked'),
  (92, 40, 21, 100, 43, '2026-10-04', 'issued'),
  (92, 58, 21, 103, 43, '2026-10-04', 'issued'),
  (93, 96, 21, 102, 43, '2026-10-04', 'issued'),
  (94, 16, 21, 101, 43, '2026-10-03', 'issued'),
  (94, 73, 21, 107, 43, '2026-10-03', 'issued'),
  (95, 76, 21, 95, 44, NULL, 'booked'),
  (95, 60, 21, 93, 44, NULL, 'booked'),
  (96, 92, 21, 105, 43, '2026-10-04', 'issued'),
  (97, 90, 22, 99, 46, '2026-10-07', 'issued'),
  (97, 99, 22, 103, 46, '2026-10-07', 'issued'),
  (98, 68, 22, 100, 46, '2026-09-26', 'issued'),
  (98, 94, 22, 101, 46, '2026-09-26', 'issued'),
  (98, 73, 22, 102, 46, '2026-09-26', 'issued'),
  (99, 93, 22, 104, 46, '2026-09-30', 'issued'),
  (99, 30, 22, 107, 46, '2026-09-30', 'issued'),
  (100, 57, 22, 105, 46, '2026-10-07', 'issued'),
  (100, 28, 22, 106, 46, '2026-10-07', 'issued'),
  (101, 61, 23, 60, 49, NULL, 'booked'),
  (101, 89, 23, 53, 49, NULL, 'booked'),
  (101, 61, 24, 55, 51, NULL, 'booked'),
  (101, 89, 24, 53, 51, NULL, 'booked'),
  (102, 37, 23, 49, 50, '2026-09-29', 'issued'),
  (102, 76, 23, 50, 50, '2026-09-29', 'issued'),
  (102, 59, 23, 51, 50, '2026-09-29', 'issued'),
  (102, 37, 24, 52, 52, '2026-09-29', 'issued'),
  (102, 76, 24, 49, 52, '2026-09-29', 'issued'),
  (102, 59, 24, 50, 52, '2026-09-29', 'issued'),
  (103, 70, 23, 57, 49, NULL, 'booked'),
  (103, 33, 23, 54, 49, NULL, 'booked'),
  (103, 80, 23, 55, 49, NULL, 'booked'),
  (104, 62, 23, 56, 49, '2026-09-23', 'issued'),
  (104, 62, 24, 54, 51, '2026-09-23', 'issued'),
  (105, 23, 24, 58, 51, '2026-10-01', 'cancelled'),
  (105, 86, 24, 59, 51, '2026-10-01', 'cancelled'),
  (106, 42, 24, 56, 51, '2026-10-04', 'issued'),
  (107, 14, 24, 51, 52, NULL, 'booked'),
  (108, 74, 24, 58, 51, '2026-09-27', 'issued'),
  (109, 46, 25, 17, 53, '2026-09-20', 'issued'),
  (109, 2, 25, 21, 53, '2026-09-20', 'issued'),
  (109, 46, 26, 24, 55, '2026-09-20', 'issued'),
  (109, 2, 26, 21, 55, '2026-09-20', 'issued'),
  (110, 3, 25, 13, 54, '2026-10-03', 'issued'),
  (111, 40, 25, 18, 53, NULL, 'booked'),
  (112, 74, 25, 19, 53, '2026-10-05', 'issued'),
  (112, 74, 26, 18, 55, '2026-10-05', 'issued'),
  (113, 34, 25, 14, 54, '2026-09-25', 'issued'),
  (113, 92, 25, 15, 54, '2026-09-25', 'issued'),
  (113, 34, 26, 13, 56, '2026-09-25', 'issued'),
  (113, 92, 26, 16, 56, '2026-09-25', 'issued'),
  (114, 53, 25, 20, 53, '2026-10-04', 'issued'),
  (114, 62, 25, 22, 53, '2026-10-04', 'issued'),
  (115, 27, 26, 15, 56, '2026-09-21', 'cancelled'),
  (115, 63, 26, 14, 56, '2026-09-21', 'cancelled'),
  (116, 37, 26, 14, 56, '2026-10-02', 'issued'),
  (116, 35, 26, 15, 56, '2026-10-02', 'issued'),
  (117, 21, 26, 17, 55, '2026-10-01', 'issued'),
  (117, 45, 26, 22, 55, '2026-10-01', 'issued'),
  (118, 87, 26, 19, 55, '2026-09-21', 'issued'),
  (119, 72, 27, 1, 58, '2026-09-27', 'issued'),
  (119, 41, 27, 2, 58, '2026-09-27', 'issued'),
  (119, 19, 27, 3, 58, '2026-09-27', 'issued'),
  (119, 72, 28, 1, 60, '2026-09-27', 'issued'),
  (119, 41, 28, 2, 60, '2026-09-27', 'issued'),
  (119, 19, 28, 3, 60, '2026-09-27', 'issued'),
  (120, 34, 27, 11, 57, '2026-09-21', 'issued'),
  (120, 27, 27, 12, 57, '2026-09-21', 'issued'),
  (120, 100, 27, 8, 57, '2026-09-21', 'issued'),
  (121, 86, 27, 5, 57, '2026-09-30', 'issued'),
  (121, 87, 27, 7, 57, '2026-09-30', 'issued'),
  (121, 69, 27, 6, 57, '2026-09-30', 'issued'),
  (121, 86, 28, 11, 59, '2026-09-30', 'issued'),
  (121, 87, 28, 5, 59, '2026-09-30', 'issued'),
  (121, 69, 28, 6, 59, '2026-09-30', 'issued'),
  (122, 17, 28, 7, 59, '2026-09-22', 'issued'),
  (123, 57, 28, 9, 59, '2026-10-06', 'issued'),
  (124, 43, 29, 79, 61, '2026-10-04', 'issued'),
  (124, 43, 32, 79, 69, '2026-10-04', 'issued'),
  (125, 100, 29, 88, 61, NULL, 'booked'),
  (125, 84, 29, 87, 61, NULL, 'booked'),
  (125, 100, 32, 80, 69, NULL, 'booked'),
  (125, 84, 32, 81, 69, NULL, 'booked'),
  (126, 92, 29, 80, 61, '2026-09-27', 'issued'),
  (126, 92, 32, 84, 69, '2026-09-27', 'issued'),
  (127, 32, 29, 84, 61, NULL, 'booked'),
  (127, 63, 29, 89, 61, NULL, 'booked'),
  (127, 47, 29, 81, 61, NULL, 'booked'),
  (128, 75, 29, 83, 61, NULL, 'booked'),
  (128, 3, 29, 90, 61, NULL, 'booked'),
  (128, 53, 29, 82, 61, NULL, 'booked'),
  (128, 75, 32, 82, 69, NULL, 'booked'),
  (128, 3, 32, 83, 69, NULL, 'booked'),
  (128, 53, 32, 85, 69, NULL, 'booked'),
  (129, 34, 29, 73, 63, NULL, 'booked'),
  (129, 57, 29, 74, 63, NULL, 'booked'),
  (130, 95, 30, 97, 64, '2026-10-07', 'issued'),
  (130, 16, 30, 98, 64, '2026-10-07', 'issued'),
  (131, 10, 30, 105, 64, '2026-09-21', 'cancelled'),
  (131, 58, 30, 99, 64, '2026-09-21', 'cancelled'),
  (131, 10, 33, 97, 72, '2026-09-21', 'cancelled'),
  (131, 58, 33, 97, 72, '2026-09-21', 'cancelled'),
  (132, 98, 30, 99, 64, NULL, 'booked'),
  (132, 50, 30, 100, 64, NULL, 'booked'),
  (132, 46, 30, 101, 64, NULL, 'booked'),
  (132, 98, 33, 97, 72, NULL, 'booked'),
  (132, 50, 33, 99, 72, NULL, 'booked'),
  (132, 46, 33, 98, 72, NULL, 'booked'),
  (133, 17, 30, 106, 64, '2026-10-08', 'issued'),
  (133, 17, 33, 105, 72, '2026-10-08', 'issued'),
  (134, 30, 30, 108, 64, '2026-09-23', 'issued'),
  (135, 5, 30, 102, 64, '2026-09-29', 'issued'),
  (136, 90, 30, 103, 64, '2026-09-27', 'issued'),
  (136, 90, 33, 100, 72, '2026-09-27', 'issued'),
  (137, 60, 30, 91, 66, NULL, 'booked'),
  (137, 60, 33, 91, 74, NULL, 'booked'),
  (138, 6, 30, 104, 64, '2026-10-04', 'issued'),
  (139, 10, 31, 29, 67, '2026-10-06', 'issued'),
  (139, 44, 31, 30, 67, '2026-10-06', 'issued'),
  (139, 88, 31, 31, 67, '2026-10-06', 'issued'),
  (140, 14, 31, 36, 67, '2026-09-27', 'issued'),
  (140, 96, 31, 32, 67, '2026-09-27', 'issued'),
  (140, 6, 31, 33, 67, '2026-09-27', 'issued'),
  (141, 50, 31, 35, 67, '2026-10-03', 'issued'),
  (141, 45, 31, 34, 67, '2026-10-03', 'issued'),
  (142, 100, 31, 25, 68, '2026-10-08', 'issued'),
  (142, 22, 31, 27, 68, '2026-10-08', 'issued'),
  (143, 4, 32, 86, 69, '2026-09-29', 'issued'),
  (144, 63, 32, 90, 69, '2026-10-01', 'issued'),
  (144, 57, 32, 87, 69, '2026-10-01', 'issued'),
  (145, 58, 32, 88, 69, NULL, 'booked'),
  (146, 14, 33, 93, 73, '2026-10-06', 'cancelled'),
  (146, 23, 33, 93, 73, '2026-10-06', 'cancelled'),
  (147, 85, 33, 103, 72, '2026-10-04', 'issued'),
  (147, 5, 33, 104, 72, '2026-10-04', 'issued'),
  (147, 94, 33, 101, 72, '2026-10-04', 'issued'),
  (148, 43, 33, 102, 72, '2026-09-22', 'issued'),
  (149, 53, 33, 106, 72, NULL, 'booked'),
  (150, 86, 33, 107, 72, '2026-10-02', 'issued'),
  (151, 26, 34, 17, 75, NULL, 'booked'),
  (151, 72, 34, 18, 75, NULL, 'booked'),
  (152, 61, 34, 13, 76, '2026-09-21', 'issued'),
  (153, 20, 34, 19, 75, '2026-10-03', 'issued'),
  (153, 91, 34, 20, 75, '2026-10-03', 'issued'),
  (153, 64, 34, 22, 75, '2026-10-03', 'issued'),
  (154, 36, 34, 24, 75, '2026-10-03', 'cancelled'),
  (155, 95, 34, 24, 75, '2026-10-05', 'issued'),
  (155, 69, 34, 21, 75, '2026-10-05', 'issued');

-- PAYMENT ------------------------------------------------------------
INSERT INTO PAYMENT (ReservationID, TotalAmount, PaymentMethod, TimeStamp, Status) VALUES
  (1, 3000.00, 'Card',         '2026-09-01 10:15', 'Paid'),
  (2, 5200.00, 'QR',           '2026-09-05 14:02', 'Paid'),
  (3, 3900.00, 'Card',         '2026-09-08 09:40', 'Paid'),
  (4, 3500.00, 'Cash',         '2026-09-12 11:20', 'Paid'),
  (4, 3500.00, 'Cash',         '2026-09-14 16:05', 'Refunded'),   -- Business fare 10 has the Refundable condition, so money back
  (5, 4500.00, 'BankTransfer', '2026-10-01 13:30', 'Paid'),       -- 3 x 1,500
  (7, 6500.00, 'Card',         '2026-10-04 19:45', 'Paid');
  -- reservations 6 and 8 have no payment yet (Q2)

-- payments for the new reservations (held ones have none yet)
INSERT INTO PAYMENT (ReservationID, TotalAmount, PaymentMethod, TimeStamp, Status) VALUES
  (9, 9000.00, 'BankTransfer', '2026-08-21 11:05', 'Paid'),
  (10, 1500.00, 'QR', '2026-09-03 10:15', 'Paid'),
  (11, 3000.00, 'Cash', '2026-08-25 20:15', 'Paid'),
  (12, 4500.00, 'BankTransfer', '2026-08-28 14:30', 'Paid'),
  (13, 3000.00, 'Card', '2026-08-16 13:05', 'Paid'),
  (14, 3000.00, 'Cash', '2026-09-04 18:30', 'Paid'),
  (15, 4500.00, 'BankTransfer', '2026-08-29 11:30', 'Paid'),
  (16, 1500.00, 'Card', '2026-08-19 18:30', 'Paid'),
  (17, 1800.00, 'Cash', '2026-09-05 09:45', 'Paid'),
  (18, 3600.00, 'QR', '2026-08-30 10:30', 'Paid'),
  (19, 5400.00, 'Cash', '2026-08-20 18:45', 'Paid'),
  (20, 1800.00, 'BankTransfer', '2026-08-20 09:05', 'Paid'),
  (21, 1800.00, 'QR', '2026-08-23 13:15', 'Paid'),
  (22, 7800.00, 'BankTransfer', '2026-09-02 15:45', 'Paid'),
  (23, 11700.00, 'QR', '2026-08-29 18:30', 'Paid'),
  (24, 29400.00, 'QR', '2026-09-10 19:45', 'Paid'),
  (25, 1200.00, 'Card', '2026-09-13 15:30', 'Paid'),
  (26, 10500.00, 'QR', '2026-09-01 10:15', 'Paid'),
  (28, 1500.00, 'Cash', '2026-10-03 17:30', 'Paid'),
  (29, 4500.00, 'QR', '2026-10-03 16:15', 'Paid'),
  (30, 1500.00, 'Card', '2026-10-10 14:45', 'Paid'),
  (31, 5400.00, 'QR', '2026-10-01 11:05', 'Paid'),
  (32, 1800.00, 'Cash', '2026-10-05 09:30', 'Paid'),
  (33, 1800.00, 'Cash', '2026-10-01 11:30', 'Paid'),
  (34, 3600.00, 'Cash', '2026-10-11 11:45', 'Paid'),
  (35, 19500.00, 'QR', '2026-10-05 14:15', 'Paid'),
  (37, 3900.00, 'BankTransfer', '2026-10-08 14:15', 'Paid'),
  (38, 3900.00, 'QR', '2026-10-11 20:45', 'Paid'),
  (39, 7800.00, 'QR', '2026-10-07 15:05', 'Paid'),
  (40, 7800.00, 'Cash', '2026-10-02 11:05', 'Paid'),
  (41, 3900.00, 'BankTransfer', '2026-10-06 13:30', 'Paid');

-- payments for the November and December bookings (held ones have none yet)
INSERT INTO PAYMENT (ReservationID, TotalAmount, PaymentMethod, TimeStamp, Status) VALUES
  (45, 3000.00, 'Cash', '2026-10-07 13:50', 'Paid'),
  (46, 4500.00, 'Cash', '2026-09-23 18:50', 'Paid'),
  (47, 1500.00, 'BankTransfer', '2026-09-23 18:20', 'Paid'),
  (47, 1500.00, 'BankTransfer', '2026-09-23 21:30', 'Refunded'),
  (49, 3600.00, 'Cash', '2026-09-21 16:35', 'Paid'),
  (50, 10400.00, 'Cash', '2026-09-23 20:35', 'Paid'),
  (51, 1800.00, 'Cash', '2026-10-04 14:50', 'Paid'),
  (52, 7200.00, 'Cash', '2026-10-05 20:35', 'Paid'),
  (53, 3600.00, 'QR', '2026-09-20 17:50', 'Paid'),
  (54, 3600.00, 'Card', '2026-10-03 13:20', 'Paid'),
  (55, 1800.00, 'QR', '2026-10-04 18:50', 'Paid'),
  (56, 3600.00, 'BankTransfer', '2026-09-21 10:20', 'Paid'),
  (57, 10400.00, 'Card', '2026-09-29 15:05', 'Paid'),
  (58, 52000.00, 'Card', '2026-10-02 09:50', 'Paid'),
  (59, 28500.00, 'Card', '2026-09-22 19:20', 'Paid'),
  (60, 52000.00, 'QR', '2026-10-08 09:35', 'Paid'),
  (61, 19000.00, 'BankTransfer', '2026-10-06 17:35', 'Paid'),
  (62, 19000.00, 'QR', '2026-09-27 14:20', 'Paid'),
  (63, 38000.00, 'QR', '2026-10-08 09:20', 'Paid'),
  (64, 9500.00, 'Card', '2026-09-28 18:50', 'Paid'),
  (65, 28500.00, 'QR', '2026-09-29 13:35', 'Paid'),
  (66, 19000.00, 'Card', '2026-10-08 10:20', 'Paid'),
  (67, 9500.00, 'Cash', '2026-10-08 20:35', 'Paid'),
  (69, 9500.00, 'Card', '2026-10-08 17:35', 'Paid'),
  (70, 23400.00, 'Card', '2026-09-24 14:50', 'Paid'),
  (72, 9800.00, 'BankTransfer', '2026-09-30 18:50', 'Paid'),
  (74, 19600.00, 'QR', '2026-09-24 19:50', 'Paid'),
  (75, 3900.00, 'Cash', '2026-10-07 12:50', 'Paid'),
  (76, 3900.00, 'Card', '2026-10-06 13:35', 'Paid'),
  (77, 3900.00, 'QR', '2026-09-20 14:35', 'Paid'),
  (79, 1600.00, 'BankTransfer', '2026-09-27 11:50', 'Paid'),
  (81, 3200.00, 'BankTransfer', '2026-09-29 17:05', 'Paid'),
  (82, 3200.00, 'QR', '2026-10-08 18:50', 'Paid'),
  (83, 9600.00, 'Cash', '2026-09-29 11:50', 'Paid'),
  (84, 4800.00, 'Cash', '2026-09-26 17:50', 'Paid'),
  (85, 1600.00, 'QR', '2026-10-06 20:05', 'Paid'),
  (86, 5200.00, 'BankTransfer', '2026-09-30 14:35', 'Paid'),
  (88, 10400.00, 'QR', '2026-10-05 10:20', 'Paid'),
  (89, 62000.00, 'Card', '2026-09-30 10:05', 'Paid'),
  (90, 5200.00, 'Card', '2026-10-06 10:05', 'Paid'),
  (92, 10400.00, 'BankTransfer', '2026-10-04 12:20', 'Paid'),
  (93, 5200.00, 'QR', '2026-10-04 09:05', 'Paid'),
  (94, 10400.00, 'BankTransfer', '2026-10-03 12:50', 'Paid'),
  (96, 5200.00, 'BankTransfer', '2026-10-04 18:20', 'Paid'),
  (97, 10400.00, 'Cash', '2026-10-07 12:20', 'Paid'),
  (98, 15600.00, 'Card', '2026-09-26 13:50', 'Paid'),
  (99, 10400.00, 'Cash', '2026-09-30 10:50', 'Paid'),
  (100, 10400.00, 'Cash', '2026-10-07 09:35', 'Paid'),
  (102, 39000.00, 'BankTransfer', '2026-09-29 15:35', 'Paid'),
  (104, 5000.00, 'BankTransfer', '2026-09-23 17:05', 'Paid'),
  (105, 5000.00, 'Cash', '2026-10-01 09:35', 'Paid'),
  (105, 5000.00, 'Cash', '2026-10-01 21:30', 'Refunded'),
  (106, 2500.00, 'BankTransfer', '2026-10-04 12:35', 'Paid'),
  (108, 2500.00, 'BankTransfer', '2026-09-27 18:50', 'Paid'),
  (109, 4800.00, 'BankTransfer', '2026-09-20 17:20', 'Paid'),
  (110, 3500.00, 'QR', '2026-10-03 19:50', 'Paid'),
  (112, 2400.00, 'Card', '2026-10-05 20:05', 'Paid'),
  (113, 14000.00, 'BankTransfer', '2026-09-25 09:05', 'Paid'),
  (114, 2400.00, 'Cash', '2026-10-04 16:20', 'Paid'),
  (115, 7000.00, 'Cash', '2026-09-21 20:50', 'Paid'),
  (115, 7000.00, 'Cash', '2026-09-21 21:30', 'Refunded'),
  (116, 7000.00, 'Cash', '2026-10-02 17:50', 'Paid'),
  (117, 2400.00, 'Cash', '2026-10-01 19:50', 'Paid'),
  (118, 1200.00, 'Card', '2026-09-21 11:50', 'Paid'),
  (119, 27000.00, 'Cash', '2026-09-27 17:05', 'Paid'),
  (120, 4500.00, 'QR', '2026-09-21 20:50', 'Paid'),
  (121, 9000.00, 'Cash', '2026-09-30 09:20', 'Paid'),
  (122, 1500.00, 'QR', '2026-09-22 19:20', 'Paid'),
  (123, 1500.00, 'QR', '2026-10-06 10:20', 'Paid'),
  (124, 19000.00, 'QR', '2026-10-04 16:20', 'Paid'),
  (126, 19000.00, 'Card', '2026-09-27 20:35', 'Paid'),
  (130, 10400.00, 'Card', '2026-10-07 09:20', 'Paid'),
  (131, 20800.00, 'Card', '2026-09-21 15:05', 'Paid'),
  (131, 20800.00, 'Card', '2026-09-21 21:30', 'Refunded'),
  (133, 10400.00, 'BankTransfer', '2026-10-08 20:35', 'Paid'),
  (134, 5200.00, 'Cash', '2026-09-23 20:05', 'Paid'),
  (135, 5200.00, 'Cash', '2026-09-29 14:50', 'Paid'),
  (136, 10400.00, 'BankTransfer', '2026-09-27 16:50', 'Paid'),
  (138, 5200.00, 'Card', '2026-10-04 17:50', 'Paid'),
  (139, 5400.00, 'Cash', '2026-10-06 13:35', 'Paid'),
  (140, 5400.00, 'Cash', '2026-09-27 12:50', 'Paid'),
  (141, 3600.00, 'Card', '2026-10-03 20:50', 'Paid'),
  (142, 10400.00, 'QR', '2026-10-08 20:35', 'Paid'),
  (143, 9500.00, 'BankTransfer', '2026-09-29 13:35', 'Paid'),
  (144, 19000.00, 'Card', '2026-10-01 17:35', 'Paid'),
  (146, 29000.00, 'QR', '2026-10-06 18:35', 'Paid'),
  (146, 29000.00, 'QR', '2026-10-06 21:30', 'Refunded'),
  (147, 15600.00, 'BankTransfer', '2026-10-04 17:20', 'Paid'),
  (148, 5200.00, 'QR', '2026-09-22 14:20', 'Paid'),
  (150, 5200.00, 'Card', '2026-10-02 09:05', 'Paid'),
  (152, 4800.00, 'QR', '2026-09-21 12:05', 'Paid'),
  (153, 4800.00, 'BankTransfer', '2026-10-03 13:50', 'Paid'),
  (154, 1600.00, 'QR', '2026-10-03 09:35', 'Paid'),
  (154, 1600.00, 'QR', '2026-10-03 21:30', 'Refunded'),
  (155, 3200.00, 'Card', '2026-10-05 15:05', 'Paid');

-- BAGGAGE (BR9: optional; BR12: Economy 20 kg, Business 30 kg per ticket) ---
INSERT INTO BAGGAGE (TicketID, Weight, BaggageStatus) VALUES
  (1, 15.00, 'Arrived'),
  (2, 12.00, 'Arrived'),
  (3, 22.00, 'Arrived'),
  (3,  6.50, 'Arrived'),
  (4, 19.50, 'Arrived');

-- bags on the new September tickets (within 20 kg Economy / 30 kg Business)
INSERT INTO BAGGAGE (TicketID, Weight, BaggageStatus) VALUES
  (12, 10.00, 'Arrived'),
  (12, 11.00, 'Arrived'),
  (13, 12.50, 'Arrived'),
  (13, 2.50, 'Arrived'),
  (20, 15.00, 'Arrived'),
  (22, 9.00, 'Arrived'),
  (23, 9.50, 'Arrived'),
  (24, 12.50, 'Arrived'),
  (25, 10.50, 'Arrived'),
  (26, 7.50, 'Arrived'),
  (27, 17.50, 'Arrived'),
  (32, 7.00, 'Arrived'),
  (34, 14.00, 'Arrived'),
  (36, 10.50, 'Arrived'),
  (37, 15.00, 'Arrived'),
  (39, 10.00, 'Arrived'),
  (40, 7.50, 'Arrived'),
  (42, 12.00, 'Arrived'),
  (43, 23.00, 'Arrived'),
  (43, 6.00, 'Arrived'),
  (44, 16.50, 'Arrived'),
  (45, 24.00, 'Arrived'),
  (45, 4.00, 'Arrived'),
  (46, 16.50, 'Arrived'),
  (46, 13.00, 'Arrived');

-- CHECKIN (one per ticket; only September tickets so far) ---------------
INSERT INTO CHECKIN (TicketID, CheckInStaffID, CheckInTime, BoardingPassNo) VALUES
  (1, 3, '2026-09-10 06:45', 'BP260910-001'),
  (2, 3, '2026-09-10 09:05', 'BP260910-002'),
  (3, 4, '2026-09-15 07:30', 'BP260915-001'),
  (4, 4, '2026-09-20 11:10', 'BP260920-001');

-- check-ins for every new September (used) ticket
INSERT INTO CHECKIN (TicketID, CheckInStaffID, CheckInTime, BoardingPassNo) VALUES
  (12, 4, '2026-09-10 06:42', 'BP260910-003'),
  (13, 4, '2026-09-10 08:50', 'BP260910-004'),
  (14, 4, '2026-09-10 06:13', 'BP260910-005'),
  (15, 3, '2026-09-10 06:11', 'BP260910-006'),
  (16, 3, '2026-09-10 08:51', 'BP260910-007'),
  (17, 4, '2026-09-10 06:12', 'BP260910-008'),
  (18, 3, '2026-09-10 06:33', 'BP260910-009'),
  (19, 3, '2026-09-10 06:14', 'BP260910-010'),
  (20, 4, '2026-09-10 06:47', 'BP260910-011'),
  (21, 4, '2026-09-10 06:29', 'BP260910-012'),
  (22, 3, '2026-09-10 09:15', 'BP260910-013'),
  (23, 3, '2026-09-10 08:45', 'BP260910-014'),
  (24, 4, '2026-09-10 08:55', 'BP260910-015'),
  (25, 4, '2026-09-10 08:42', 'BP260910-016'),
  (26, 4, '2026-09-10 09:28', 'BP260910-017'),
  (27, 3, '2026-09-10 08:38', 'BP260910-018'),
  (28, 3, '2026-09-15 07:16', 'BP260915-002'),
  (29, 4, '2026-09-15 07:39', 'BP260915-003'),
  (30, 3, '2026-09-15 07:12', 'BP260915-004'),
  (31, 4, '2026-09-15 07:26', 'BP260915-005'),
  (32, 4, '2026-09-15 07:25', 'BP260915-006'),
  (33, 4, '2026-09-15 07:07', 'BP260915-007'),
  (34, 3, '2026-09-15 07:18', 'BP260915-008'),
  (35, 4, '2026-09-15 07:35', 'BP260915-009'),
  (36, 4, '2026-09-20 11:32', 'BP260920-002'),
  (37, 3, '2026-09-20 11:25', 'BP260920-003'),
  (38, 3, '2026-09-20 11:10', 'BP260920-004'),
  (39, 4, '2026-09-20 11:46', 'BP260920-005'),
  (40, 4, '2026-09-20 11:41', 'BP260920-006'),
  (41, 4, '2026-09-20 11:29', 'BP260920-007'),
  (42, 4, '2026-09-20 11:34', 'BP260920-008'),
  (43, 4, '2026-09-20 11:08', 'BP260920-009'),
  (44, 3, '2026-09-25 13:38', 'BP260925-001'),
  (45, 4, '2026-09-25 13:20', 'BP260925-002'),
  (46, 4, '2026-09-25 13:12', 'BP260925-003'),
  (47, 3, '2026-09-25 13:04', 'BP260925-004');
