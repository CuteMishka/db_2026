-- Laboratory Work 7 - demonstration database
-- Student: Madi Murat
-- PostgreSQL 16+
--
-- This script is safe for an existing database: it works only inside
-- the separate lab7_demo schema. Run the whole file once in pgAdmin.

DROP SCHEMA IF EXISTS lab7_demo CASCADE;
CREATE SCHEMA lab7_demo;
SET search_path TO lab7_demo, public;

CREATE TABLE airline (
    airline_id      integer PRIMARY KEY,
    airline_code    varchar(10),
    airline_name    varchar(80) NOT NULL,
    airline_country varchar(80) NOT NULL
);

CREATE TABLE airport (
    airport_id   integer PRIMARY KEY,
    airport_name varchar(120) NOT NULL,
    country      varchar(80) NOT NULL,
    city         varchar(80) NOT NULL
);

CREATE TABLE passengers (
    passenger_id           integer PRIMARY KEY,
    first_name             varchar(60) NOT NULL,
    last_name              varchar(60) NOT NULL,
    date_of_birth          date NOT NULL,
    country_of_citizenship varchar(80) NOT NULL,
    passport_number        varchar(30) NOT NULL
);

CREATE TABLE flights (
    flight_id             integer PRIMARY KEY,
    flight_no             varchar(20) NOT NULL,
    scheduled_departure   timestamp NOT NULL,
    actual_departure      timestamp,
    departure_airport_id  integer NOT NULL REFERENCES airport(airport_id),
    arrival_airport_id    integer NOT NULL REFERENCES airport(airport_id),
    airline_id            integer NOT NULL REFERENCES airline(airline_id),
    status                varchar(20) NOT NULL
);

CREATE TABLE booking (
    booking_id  integer PRIMARY KEY,
    passenger_id integer NOT NULL REFERENCES passengers(passenger_id),
    price       numeric(10, 2) NOT NULL,
    created_at  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE booking_flight (
    booking_flight_id integer PRIMARY KEY,
    booking_id        integer NOT NULL REFERENCES booking(booking_id),
    flight_id         integer NOT NULL REFERENCES flights(flight_id)
);

CREATE TABLE baggage (
    baggage_id  integer PRIMARY KEY,
    booking_id  integer NOT NULL REFERENCES booking(booking_id),
    weight_in_kg numeric(5, 2) NOT NULL
);

INSERT INTO airline VALUES
    (1, 'KC',  'Air Astana',       'Kazakhstan'),
    (2, 'DV',  'SCAT Airlines',    'Kazakhstan'),
    (3, 'TK',  'Turkish Airlines', 'Turkey'),
    (4, 'BA',  'British Airways',  'United Kingdom'),
    (5, 'LH',  'Lufthansa',        'Germany'),
    (6, 'AF',  'Air France',       'France'),
    (7, 'ZZ',  'Demo Air One',     'Kazakhstan'),
    (8, 'ZZ',  'Demo Air Two',     'Kazakhstan');

INSERT INTO airport
SELECT
    g,
    CASE
        WHEN g % 20 = 0 THEN 'Almaty ' || g || ' Airport'
        WHEN g % 20 = 1 THEN 'Astana ' || g || ' International'
        ELSE 'City ' || g || ' Airport'
    END,
    (ARRAY['Kazakhstan', 'Philippines', 'France', 'Germany', 'Turkey'])[1 + (g % 5)],
    (ARRAY['Almaty', 'Manila', 'Paris', 'Berlin', 'Istanbul', 'Astana'])[1 + (g % 6)]
FROM generate_series(1, 1000) AS g;

INSERT INTO passengers
SELECT
    g,
    CASE WHEN g = 100 THEN 'Carlos' ELSE 'Name' || g END,
    CASE WHEN g = 100 THEN 'Irnis' ELSE 'Surname' || (g % 800) END,
    CASE
        WHEN g = 100 THEN DATE '1984-05-18'
        ELSE DATE '1965-01-01' + ((g * 17) % 15000)
    END,
    CASE WHEN g = 100 THEN 'Philippines'
         ELSE (ARRAY['Kazakhstan', 'Philippines', 'France', 'Germany', 'Turkey'])[1 + (g % 5)]
    END,
    'P' || LPAD(g::text, 9, '0')
FROM generate_series(1, 10000) AS g;

INSERT INTO flights
SELECT
    g,
    'FL' || LPAD((g % 5000)::text, 4, '0'),
    TIMESTAMP '2026-01-01 00:00:00' + g * INTERVAL '3 minutes',
    TIMESTAMP '2026-01-01 00:00:00' + g * INTERVAL '3 minutes'
        + ((g % 25) * INTERVAL '1 minute'),
    1 + (g % 1000),
    1 + ((g * 7 + 19) % 1000),
    1 + (g % 6),
    CASE
        WHEN g % 50 = 0 THEN 'Departed'
        WHEN g % 5 = 0 THEN 'Scheduled'
        ELSE 'Boarding'
    END
FROM generate_series(1, 30000) AS g;

INSERT INTO booking
SELECT
    g,
    1 + (g % 10000),
    (5000 + (g % 20000))::numeric(10, 2),
    TIMESTAMP '2026-01-01 00:00:00' + g * INTERVAL '1 minute'
FROM generate_series(1, 60000) AS g;

INSERT INTO booking_flight
SELECT g, g, 1 + (g % 30000)
FROM generate_series(1, 60000) AS g;

INSERT INTO baggage
SELECT
    g,
    1 + (g % 60000),
    (5.01 + (g % 4500) / 100.0)::numeric(5, 2)
FROM generate_series(1, 50000) AS g;

ANALYZE airline;
ANALYZE airport;
ANALYZE passengers;
ANALYZE flights;
ANALYZE booking;
ANALYZE booking_flight;
ANALYZE baggage;

SELECT
    (SELECT COUNT(*) FROM airline) AS airlines,
    (SELECT COUNT(*) FROM airport) AS airports,
    (SELECT COUNT(*) FROM passengers) AS passengers,
    (SELECT COUNT(*) FROM flights) AS flights,
    (SELECT COUNT(*) FROM booking) AS bookings,
    (SELECT COUNT(*) FROM booking_flight) AS booking_flights,
    (SELECT COUNT(*) FROM baggage) AS baggage_rows;
