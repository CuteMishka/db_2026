-- Laboratory Work 4 - SELECT queries
-- PostgreSQL 16, database: airport_db

-- 1. All airline names in uppercase.
SELECT UPPER(airline_name) AS airline_name_upper
FROM airline
ORDER BY airline_id;

-- 2. Replace "Air" with "Aero" in airline names.
-- This changes only the displayed result, not the table data.
SELECT airline_name,
       REPLACE(airline_name, 'Air', 'Aero') AS changed_name
FROM airline
ORDER BY airline_id;

-- 3. Flight numbers associated with airline 1 or airline 2.
-- In this database flight_id is used as the flight number.
SELECT flight_id AS flight_number, airline_id
FROM flights
WHERE airline_id IN (1, 2)
ORDER BY flight_id;

-- 4. Airports whose names contain both "Regional" and "Air".
SELECT airport_id, airport_name
FROM airport
WHERE airport_name ILIKE '%Regional%'
  AND airport_name ILIKE '%Air%'
ORDER BY airport_id;

-- 5. Passenger names and formatted dates of birth.
SELECT first_name || ' ' || last_name AS passenger_name,
       TO_CHAR(date_of_birth, 'FMMonth DD, YYYY') AS birth_date
FROM passenger
ORDER BY passenger_id;

-- 6. Delayed flight numbers and their delay duration.
SELECT flight_id AS flight_number,
       act_arrival_time - sch_arrival_time AS delay_time
FROM flights
WHERE act_arrival_time > sch_arrival_time
ORDER BY flight_id;

-- 7. Flights that arrived later than scheduled.
SELECT flight_id AS flight_number,
       sch_arrival_time,
       act_arrival_time
FROM flights
WHERE act_arrival_time > sch_arrival_time
ORDER BY flight_id;

-- 8. Airlines from France, Portugal or Poland created in the given period.
SELECT airline_id, airline_name, airline_country, created_at
FROM airline
WHERE UPPER(airline_country) IN ('FRANCE', 'PORTUGAL', 'POLAND')
  AND created_at >= DATE '2023-11-01'
  AND created_at <  DATE '2024-04-01'
ORDER BY created_at;

-- 9. Three heaviest baggage items weighing more than 25 kg.
SELECT baggage_id, weight_in_kg, booking_id
FROM baggage
WHERE weight_in_kg > 25
ORDER BY weight_in_kg DESC
LIMIT 3;

-- 10. Full name of the youngest passenger.
SELECT first_name || ' ' || last_name AS youngest_passenger
FROM passenger
ORDER BY date_of_birth DESC
LIMIT 1;

-- 11. Cheapest booking price on each platform.
SELECT booking_platform,
       MIN(ticket_price) AS cheapest_price
FROM booking
GROUP BY booking_platform
ORDER BY booking_platform;

-- 12. Airlines whose code contains at least one digit.
SELECT airline_id, airline_code, airline_name
FROM airline
WHERE airline_code ~ '[0-9]'
ORDER BY airline_id;

-- 13. Five most recently created airlines.
SELECT airline_id, airline_name, created_at
FROM airline
ORDER BY created_at DESC, airline_id DESC
LIMIT 5;

-- 14. Baggage checks with booking_id from 200 through 300,
--     excluding rows whose result is "Checked".
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

-- 15. Baggage checks updated in the same month as they were created,
--     but with an updated_at value earlier than created_at.
SELECT baggage_check_id AS check_id,
       check_result,
       created_at,
       updated_at
FROM baggage_check
WHERE DATE_TRUNC('month', updated_at)
      = DATE_TRUNC('month', created_at)
  AND updated_at < created_at
ORDER BY baggage_check_id;
