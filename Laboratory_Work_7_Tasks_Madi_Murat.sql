-- Laboratory Work 7 - INDEX
-- Student: Madi Murat
-- Run Laboratory_Work_7_Setup_Database.sql first.

SET search_path TO lab7_demo, public;

-- Task 1. Index on actual_departure.
DROP INDEX IF EXISTS idx_flights_actual_departure;
CREATE INDEX idx_flights_actual_departure
    ON flights(actual_departure);


-- Task 2. Unique flight number and scheduled departure combination.
DROP INDEX IF EXISTS idx_flights_no_scheduled_unique;
CREATE UNIQUE INDEX idx_flights_no_scheduled_unique
    ON flights(flight_no, scheduled_departure);


-- Task 3. Composite route index.
DROP INDEX IF EXISTS idx_flights_route;
CREATE INDEX idx_flights_route
    ON flights(departure_airport_id, arrival_airport_id);


-- Task 4. Compare the same query without and with an index.
DROP INDEX IF EXISTS idx_flights_actual_departure;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM flights
WHERE actual_departure >= TIMESTAMP '2026-02-01'
  AND actual_departure <  TIMESTAMP '2026-02-02';

CREATE INDEX idx_flights_actual_departure
    ON flights(actual_departure);

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM flights
WHERE actual_departure >= TIMESTAMP '2026-02-01'
  AND actual_departure <  TIMESTAMP '2026-02-02';


-- Task 5. Check use of the route index.
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM flights
WHERE departure_airport_id = 101
  AND arrival_airport_id = 720;


-- Task 6. Unique passport index and duplicate test.
DROP INDEX IF EXISTS idx_passengers_passport_unique;
CREATE UNIQUE INDEX idx_passengers_passport_unique
    ON passengers(passport_number);

-- Allows this demonstration section to be run again without resetting the schema.
DELETE FROM passengers
WHERE passenger_id IN (10001, 10002);

INSERT INTO passengers VALUES
    (10001, 'Anna', 'Testova', DATE '1999-03-14', 'Kazakhstan', 'NEW000001');

-- The second row has the same passport. The error is caught so the script continues.
DO $$
BEGIN
    BEGIN
        INSERT INTO passengers VALUES
            (10002, 'John', 'Tester', DATE '1998-07-20', 'Philippines', 'NEW000001');
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'Second passenger rejected: passport NEW000001 already exists';
    END;
END $$;

SELECT passenger_id, first_name, last_name, passport_number
FROM passengers
WHERE passport_number = 'NEW000001';


-- Task 7. Multi-column passenger index and plan check.
DROP INDEX IF EXISTS idx_passengers_personal_data;
CREATE INDEX idx_passengers_personal_data
    ON passengers(first_name, last_name, date_of_birth, country_of_citizenship);

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM passengers
WHERE country_of_citizenship = 'Philippines'
  AND date_of_birth >= DATE '1984-01-01'
  AND date_of_birth <  DATE '1985-01-01';


-- Task 8. List indexes on Passengers, then remove the indexes created above.
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'lab7_demo'
  AND tablename = 'passengers'
ORDER BY indexname;

DROP INDEX IF EXISTS idx_passengers_passport_unique;
DROP INDEX IF EXISTS idx_passengers_personal_data;


-- Task 9. Booking lookup before and after the index.
DROP INDEX IF EXISTS idx_booking_passenger;
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM booking WHERE passenger_id = 100;

CREATE INDEX idx_booking_passenger ON booking(passenger_id);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM booking WHERE passenger_id = 100;


-- Task 10. Composite index used in a three-table join.
DROP INDEX IF EXISTS idx_booking_flight_pair;
CREATE INDEX idx_booking_flight_pair
    ON booking_flight(booking_id, flight_id);

EXPLAIN (ANALYZE, BUFFERS)
SELECT f.flight_no, b.price
FROM booking b
JOIN booking_flight bf ON bf.booking_id = b.booking_id
JOIN flights f ON f.flight_id = bf.flight_id
WHERE b.price > 9000
ORDER BY b.booking_id
LIMIT 20;


-- Task 11. Low-selectivity and high-selectivity status values.
DROP INDEX IF EXISTS idx_flights_status;
CREATE INDEX idx_flights_status ON flights(status);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM flights WHERE status = 'Departed';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM flights WHERE status = 'Boarding';


-- Task 12. Selective and non-selective baggage ranges.
DROP INDEX IF EXISTS idx_baggage_weight;
CREATE INDEX idx_baggage_weight ON baggage(weight_in_kg);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM baggage WHERE weight_in_kg > 49;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM baggage WHERE weight_in_kg > 5;


-- Task 13. Prefix LIKE and leading-wildcard LIKE.
DROP INDEX IF EXISTS idx_airport_name;
CREATE INDEX idx_airport_name
    ON airport(airport_name text_pattern_ops);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM airport WHERE airport_name LIKE 'A%';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM airport WHERE airport_name LIKE '%Airport';


-- Task 14. Leftmost prefix rule.
DROP INDEX IF EXISTS idx_airport_country_city;
CREATE INDEX idx_airport_country_city ON airport(country, city);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM airport WHERE country = 'Kazakhstan';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM airport WHERE city = 'Almaty';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM airport
WHERE country = 'Kazakhstan' AND city = 'Almaty';


-- Task 15. Expression index.
DROP INDEX IF EXISTS idx_passengers_lower_last_name;
CREATE INDEX idx_passengers_lower_last_name
    ON passengers(LOWER(last_name));

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM passengers WHERE LOWER(last_name) = 'irnis';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM passengers WHERE last_name = 'Irnis';


-- Task 16. Covering index and index-only scan.
DROP INDEX IF EXISTS idx_booking_passenger_price_cover;
CREATE INDEX idx_booking_passenger_price_cover
    ON booking(passenger_id) INCLUDE (price);

VACUUM (ANALYZE) booking;

EXPLAIN (ANALYZE, BUFFERS)
SELECT price FROM booking WHERE passenger_id = 100;


-- Task 17. Duplicate airline codes and a working unique index.
DROP INDEX IF EXISTS idx_airline_code_unique;

DO $$
BEGIN
    BEGIN
        EXECUTE 'CREATE UNIQUE INDEX idx_airline_code_unique ON airline(airline_code)';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'Unique index rejected because duplicate airline codes exist';
    END;
END $$;

SELECT airline_code, COUNT(*) AS duplicate_count
FROM airline
GROUP BY airline_code
HAVING COUNT(*) > 1;

UPDATE airline
SET airline_code = 'Z2'
WHERE airline_id = 8;

CREATE UNIQUE INDEX idx_airline_code_unique
    ON airline(airline_code);

SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'lab7_demo'
  AND tablename = 'airline';
