-- Laboratory Work 4 - portable PostgreSQL database
-- Tested with PostgreSQL 16.
--
-- HOW TO RUN IN PGADMIN:
-- 1. Create or select an empty database, for example airport_db.
-- 2. Open Query Tool.
-- 3. Open this file and press Execute (F5).
--
-- The script can be run again. It recreates only the tables listed below.

SET client_encoding = 'UTF8';
SET TIME ZONE 'Asia/Almaty';

BEGIN;

DROP TABLE IF EXISTS baggage_check CASCADE;
DROP TABLE IF EXISTS security_check CASCADE;
DROP TABLE IF EXISTS boarding_pass CASCADE;
DROP TABLE IF EXISTS baggage CASCADE;
DROP TABLE IF EXISTS booking_flight CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS flights CASCADE;
DROP TABLE IF EXISTS passenger CASCADE;
DROP TABLE IF EXISTS airport CASCADE;
DROP TABLE IF EXISTS airline CASCADE;

-- =========================
-- 1. TABLES
-- =========================

CREATE TABLE airline (
    airline_id       INT PRIMARY KEY,
    airline_code     VARCHAR(30) NOT NULL UNIQUE,
    airline_name     VARCHAR(50) NOT NULL,
    airline_country  VARCHAR(50) NOT NULL,
    created_at       TIMESTAMP NOT NULL,
    updated_at       TIMESTAMP NOT NULL
);

CREATE TABLE airport (
    airport_id    INT PRIMARY KEY,
    airport_name  VARCHAR(50) NOT NULL,
    country       VARCHAR(50) NOT NULL,
    state         VARCHAR(50) NOT NULL,
    city          VARCHAR(50) NOT NULL,
    created_at    TIMESTAMP NOT NULL,
    updated_at    TIMESTAMP NOT NULL
);

CREATE TABLE passenger (
    passenger_id            INT PRIMARY KEY,
    first_name              VARCHAR(50) NOT NULL,
    last_name               VARCHAR(50) NOT NULL,
    date_of_birth           DATE NOT NULL,
    gender                  VARCHAR(50) NOT NULL,
    country_of_citizenship  VARCHAR(50) NOT NULL,
    country_of_residence    VARCHAR(50) NOT NULL,
    passport_number         VARCHAR(20) NOT NULL UNIQUE,
    created_at              TIMESTAMP NOT NULL,
    updated_at              TIMESTAMP NOT NULL
);

CREATE TABLE flights (
    flight_id             INT PRIMARY KEY,
    sch_departure_time    TIMESTAMP NOT NULL,
    sch_arrival_time      TIMESTAMP NOT NULL,
    departing_airport_id  INT NOT NULL REFERENCES airport(airport_id),
    arriving_airport_id   INT NOT NULL REFERENCES airport(airport_id),
    departing_gate        TEXT NOT NULL,
    arriving_gate         VARCHAR(50) NOT NULL,
    airline_id            INT NOT NULL REFERENCES airline(airline_id),
    act_departure_time    TIMESTAMP NOT NULL,
    act_arrival_time      TIMESTAMP NOT NULL,
    created_at            TIMESTAMP NOT NULL,
    updated_at            TIMESTAMP NOT NULL,
    CHECK (departing_airport_id <> arriving_airport_id),
    CHECK (sch_arrival_time > sch_departure_time)
);

CREATE TABLE booking (
    booking_id        INT PRIMARY KEY,
    flight_id         INT NOT NULL REFERENCES flights(flight_id),
    passenger_id      INT NOT NULL REFERENCES passenger(passenger_id),
    booking_platform  VARCHAR(50) NOT NULL,
    created_at        TIMESTAMP NOT NULL,
    updated_at        TIMESTAMP NOT NULL,
    status            VARCHAR(50) NOT NULL,
    ticket_price      DECIMAL(10,2) NOT NULL CHECK (ticket_price >= 0)
);

CREATE TABLE booking_flight (
    booking_flight_id  INT PRIMARY KEY,
    booking_id         INT NOT NULL REFERENCES booking(booking_id),
    flight_id          INT NOT NULL REFERENCES flights(flight_id),
    created_at         TIMESTAMP NOT NULL,
    updated_at         TIMESTAMP NOT NULL,
    UNIQUE (booking_id, flight_id)
);

CREATE TABLE baggage (
    baggage_id    INT PRIMARY KEY,
    weight_in_kg  DECIMAL(4,2) NOT NULL CHECK (weight_in_kg > 0),
    created_at    TIMESTAMP NOT NULL,
    updated_at    TIMESTAMP NOT NULL,
    booking_id    INT NOT NULL REFERENCES booking(booking_id)
);

CREATE TABLE boarding_pass (
    boarding_pass_id  INT PRIMARY KEY,
    booking_id        INT NOT NULL REFERENCES booking(booking_id),
    seat              VARCHAR(50) NOT NULL,
    boarding_time     TIMESTAMP NOT NULL,
    created_at        TIMESTAMP NOT NULL,
    updated_at        TIMESTAMP NOT NULL,
    UNIQUE (booking_id, seat)
);

CREATE TABLE security_check (
    security_check_id  INT PRIMARY KEY,
    check_result       VARCHAR(20) NOT NULL,
    created_at         TIMESTAMP NOT NULL,
    updated_at         TIMESTAMP NOT NULL,
    passenger_id       INT NOT NULL REFERENCES passenger(passenger_id)
);

CREATE TABLE baggage_check (
    baggage_check_id  INT PRIMARY KEY,
    check_result      VARCHAR(50) NOT NULL,
    created_at        TIMESTAMP NOT NULL,
    updated_at        TIMESTAMP NOT NULL,
    booking_id        INT NOT NULL REFERENCES booking(booking_id),
    passenger_id      INT NOT NULL REFERENCES passenger(passenger_id)
);

-- =========================
-- 2. TEST DATA
-- =========================

INSERT INTO airline
    (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
VALUES
    (1,  'KC',  'Air Astana',       'Kazakhstan',     '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (2,  'DV',  'SCAT Airlines',    'Kazakhstan',     '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (3,  'TK',  'Turkish Airlines', 'Turkey',         '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (4,  'BA',  'British Airways',  'United Kingdom', '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (5,  'UNK', 'Global Airways',   'United Kingdom', '2026-09-29 09:52:47', '2026-09-29 00:00:00'),
    (6,  'KZA', 'KazAir',           'Turkey',         '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (7,  'AE',  'AirEasy',          'France',         '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (8,  'FH',  'FlyHigh',          'Brazil',         '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (9,  'FF',  'FlyFly',           'Poland',         '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (10, 'F2',  'France Connect',   'France',         '2024-01-15 10:00:00', '2024-01-15 10:00:00'),
    (11, 'P7',  'Portugal Air',     'Portugal',       '2024-02-10 11:30:00', '2024-02-10 11:30:00'),
    (12, 'PL8', 'Poland Regional',  'Poland',         '2023-12-05 09:15:00', '2023-12-05 09:15:00');

INSERT INTO airport
    (airport_id, airport_name, country, state, city, created_at, updated_at)
VALUES
    (1,    'Almaty International Airport',               'Kazakhstan',     'Almaty Region',    'Almaty',    '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (2,    'Nursultan Nazarbayev International Airport', 'Kazakhstan',     'Capital District', 'Astana',    '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (3,    'Heathrow Airport',                           'United Kingdom', 'Greater London',   'London',    '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (4,    'Haneda Airport',                             'Japan',          'Tokyo',            'Tokyo',     '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (1201, 'Kokshetau Regional Airport',                 'Kazakhstan',     'Akmola Region',    'Kokshetau', '2026-10-05 22:16:28', '2026-10-05 22:16:28'),
    (1202, 'Aktobe Regional Airport',                    'Kazakhstan',     'Aktobe Region',    'Aktobe',    '2026-10-05 22:16:28', '2026-10-05 22:16:28');

INSERT INTO passenger
    (passenger_id, first_name, last_name, date_of_birth, gender,
     country_of_citizenship, country_of_residence, passport_number,
     created_at, updated_at)
VALUES
    (1, 'Amina',   'Sarsenova', '1998-04-12', 'Female', 'Kazakhstan',     'Kazakhstan',     'KZ100001', '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (2, 'Daniyar', 'Tulegen',   '1995-08-21', 'Male',   'Kazakhstan',     'Kazakhstan',     'KZ100002', '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (3, 'Sofia',   'Lee',       '2000-01-15', 'Female', 'United Kingdom', 'United Kingdom', 'GB100003', '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (4, 'Noah',    'Kim',       '1992-11-03', 'Male',   'Japan',          'Japan',          'JP100004', '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (5, 'Aisha',   'Omar',      '1999-06-30', 'Female', 'Turkey',         'Turkey',         'TR100005', '2026-09-29 09:52:47', '2026-09-29 09:52:47');

INSERT INTO flights
    (flight_id, sch_departure_time, sch_arrival_time,
     departing_airport_id, arriving_airport_id,
     departing_gate, arriving_gate, airline_id,
     act_departure_time, act_arrival_time, created_at, updated_at)
VALUES
    (101, '2026-10-01 07:00:00', '2026-10-01 09:40:00', 1, 2, 'A1', 'B2', 1, '2026-10-01 07:05:00', '2026-10-01 09:43:00', '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (102, '2026-10-02 09:30:00', '2026-10-02 15:20:00', 2, 3, 'A4', 'T3', 2, '2026-10-02 09:33:00', '2026-10-02 15:18:00', '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (103, '2026-10-03 04:20:00', '2026-10-03 11:40:00', 3, 4, 'C2', 'D8', 4, '2026-10-03 04:25:00', '2026-10-03 11:44:00', '2026-09-29 09:52:47', '2026-09-29 09:52:47');

INSERT INTO booking
    (booking_id, flight_id, passenger_id, booking_platform,
     created_at, updated_at, status, ticket_price)
VALUES
    (1001, 101, 1, 'Website',    '2026-09-29 09:52:47', '2026-09-29 09:52:47', 'Confirmed',  51750.00),
    (1002, 101, 2, 'Mobile App', '2026-09-29 09:52:47', '2026-09-29 09:52:47', 'Confirmed',  51750.00),
    (1003, 102, 3, 'Agency',     '2026-09-29 09:52:47', '2026-09-29 09:52:47', 'Confirmed',  36800.00),
    (1004, 103, 4, 'Website',    '2026-09-29 09:52:47', '2026-09-29 09:52:47', 'Confirmed', 212750.00),
    (1005, 102, 5, 'Mobile App', '2026-09-29 09:52:47', '2026-09-29 09:52:47', 'Confirmed',  38525.00),
    (220,  101, 1, 'Website',    '2024-03-10 09:00:00', '2024-03-10 09:00:00', 'Confirmed',  27500.00),
    (250,  102, 2, 'Mobile App', '2024-04-02 10:30:00', '2024-04-02 10:30:00', 'Confirmed',  30000.00);

INSERT INTO booking_flight
    (booking_flight_id, booking_id, flight_id, created_at, updated_at)
VALUES
    (1, 1001, 101, '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (2, 1002, 101, '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (3, 1003, 102, '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (4, 1004, 103, '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (5, 1005, 102, '2026-09-29 09:52:47', '2026-09-29 09:52:47'),
    (6, 220,  101, '2024-03-10 09:00:00', '2024-03-10 09:00:00'),
    (7, 250,  102, '2024-04-02 10:30:00', '2024-04-02 10:30:00');

INSERT INTO baggage
    (baggage_id, weight_in_kg, created_at, updated_at, booking_id)
VALUES
    (1, 18.50, '2026-09-29 10:00:00', '2026-09-29 10:00:00', 1001),
    (2, 32.80, '2026-09-29 10:00:00', '2026-09-29 10:00:00', 1002),
    (3, 27.40, '2026-09-29 10:00:00', '2026-09-29 10:00:00', 1003),
    (4, 29.60, '2026-09-29 10:00:00', '2026-09-29 10:00:00', 1004),
    (5, 15.00, '2026-09-29 10:00:00', '2026-09-29 10:00:00', 1005),
    (6, 24.90, '2024-03-10 10:00:00', '2024-03-10 10:00:00', 220),
    (7, 26.10, '2024-04-02 11:00:00', '2024-04-02 11:00:00', 250);

INSERT INTO boarding_pass
    (boarding_pass_id, booking_id, seat, boarding_time, created_at, updated_at)
VALUES
    (1, 1001, '12A', '2026-10-01 06:20:00', '2026-09-29 10:00:00', '2026-09-29 10:00:00'),
    (2, 1002, '12B', '2026-10-01 06:20:00', '2026-09-29 10:00:00', '2026-09-29 10:00:00'),
    (3, 1003, '08C', '2026-10-02 08:50:00', '2026-09-29 10:00:00', '2026-09-29 10:00:00'),
    (4, 1004, '21F', '2026-10-03 03:40:00', '2026-09-29 10:00:00', '2026-09-29 10:00:00'),
    (5, 1005, '09A', '2026-10-02 08:50:00', '2026-09-29 10:00:00', '2026-09-29 10:00:00'),
    (6, 220,  '14A', '2026-10-01 06:20:00', '2024-03-10 10:00:00', '2024-03-10 10:00:00'),
    (7, 250,  '10D', '2026-10-02 08:50:00', '2024-04-02 11:00:00', '2024-04-02 11:00:00');

INSERT INTO security_check
    (security_check_id, check_result, created_at, updated_at, passenger_id)
VALUES
    (1, 'Passed', '2026-10-01 05:50:00', '2026-10-01 05:50:00', 1),
    (2, 'Passed', '2026-10-01 05:55:00', '2026-10-01 05:55:00', 2),
    (3, 'Passed', '2026-10-02 08:20:00', '2026-10-02 08:20:00', 3),
    (4, 'Passed', '2026-10-03 03:10:00', '2026-10-03 03:10:00', 4),
    (5, 'Passed', '2026-10-02 08:25:00', '2026-10-02 08:25:00', 5);

INSERT INTO baggage_check
    (baggage_check_id, check_result, created_at, updated_at, booking_id, passenger_id)
VALUES
    (2,   'Checked',     '2023-05-11 09:00:00', '2023-05-11 09:00:00', 1002, 2),
    (3,   'Checked',     '2024-03-05 10:00:00', '2026-09-29 09:52:47', 1003, 3),
    (4,   'Checked',     '2024-03-20 11:00:00', '2026-09-29 09:52:47', 1004, 4),
    (5,   'Checked',     '2025-07-01 12:00:00', '2025-07-01 12:00:00', 1005, 5),
    (6,   'Not checked', '2026-09-29 09:52:47', '2026-09-29 09:52:47', 1001, 1),
    (200, 'Not checked', '2024-03-20 12:00:00', '2024-03-18 09:00:00', 220,  1),
    (201, 'Inspection',  '2024-04-02 11:00:00', '2024-04-02 11:15:00', 250,  2);

COMMIT;

-- =========================
-- 3. LABORATORY WORK 4 TASKS
-- =========================

-- Task 1. All airline names in uppercase.
SELECT UPPER(airline_name) AS airline_name_upper
FROM airline
ORDER BY airline_id;

-- Task 2. Replace Air with Aero in the displayed names.
SELECT airline_name,
       REPLACE(airline_name, 'Air', 'Aero') AS changed_name
FROM airline
ORDER BY airline_id;

-- Task 3. Flights associated with airline 1 or airline 2.
SELECT flight_id AS flight_number, airline_id
FROM flights
WHERE airline_id IN (1, 2)
ORDER BY flight_id;

-- Task 4. Airport names containing both Regional and Air.
SELECT airport_id, airport_name
FROM airport
WHERE airport_name ILIKE '%Regional%'
  AND airport_name ILIKE '%Air%'
ORDER BY airport_id;

-- Task 5. Passenger names and formatted birth dates.
SELECT first_name || ' ' || last_name AS passenger_name,
       TO_CHAR(date_of_birth, 'FMMonth DD, YYYY') AS birth_date
FROM passenger
ORDER BY passenger_id;

-- Task 6. Delayed flights and the delay duration.
SELECT flight_id AS flight_number,
       act_arrival_time - sch_arrival_time AS delay_time
FROM flights
WHERE act_arrival_time > sch_arrival_time
ORDER BY flight_id;

-- Task 7. Flights that arrived later than scheduled.
SELECT flight_id AS flight_number,
       sch_arrival_time,
       act_arrival_time
FROM flights
WHERE act_arrival_time > sch_arrival_time
ORDER BY flight_id;

-- Task 8. Selected European airlines created in the given period.
SELECT airline_id, airline_name, airline_country, created_at
FROM airline
WHERE UPPER(airline_country) IN ('FRANCE', 'PORTUGAL', 'POLAND')
  AND created_at >= DATE '2023-11-01'
  AND created_at < DATE '2024-04-01'
ORDER BY created_at;

-- Task 9. Top three baggage items heavier than 25 kg.
SELECT baggage_id, weight_in_kg, booking_id
FROM baggage
WHERE weight_in_kg > 25
ORDER BY weight_in_kg DESC
LIMIT 3;

-- Task 10. Youngest passenger.
SELECT first_name || ' ' || last_name AS youngest_passenger
FROM passenger
ORDER BY date_of_birth DESC
LIMIT 1;

-- Task 11. Cheapest booking on each platform.
SELECT booking_platform,
       MIN(ticket_price) AS cheapest_price
FROM booking
GROUP BY booking_platform
ORDER BY booking_platform;

-- Task 12. Airline codes containing a digit.
SELECT airline_id, airline_code, airline_name
FROM airline
WHERE airline_code ~ '[0-9]'
ORDER BY airline_id;

-- Task 13. Five most recently created airlines.
SELECT airline_id, airline_name, created_at
FROM airline
ORDER BY created_at DESC, airline_id DESC
LIMIT 5;

-- Task 14. Non-Checked baggage checks for booking IDs 200 to 300.
SELECT baggage_check_id AS check_id,
       check_result,
       created_at,
       updated_at,
       booking_id,
       passenger_id
FROM baggage_check
WHERE booking_id BETWEEN 200 AND 300
  AND check_result <> 'Checked'
ORDER BY baggage_check_id;

-- Task 15. Update in the same month but earlier than creation.
SELECT baggage_check_id AS check_id,
       check_result,
       created_at,
       updated_at
FROM baggage_check
WHERE DATE_TRUNC('month', updated_at)
      = DATE_TRUNC('month', created_at)
  AND updated_at < created_at
ORDER BY baggage_check_id;

