-- Laboratory Work 8 - VIEW and ROLES
-- Student: Madi Murat
-- Database: airport_db, PostgreSQL 16
-- Run Laboratory_Work_4_full_database.sql and Laboratory_Work_8_Setup.sql first.
-- Tasks marked "connect as" must be run in a separate connection of that user
-- (passwords are in the CREATE USER commands of ROLES task 2).


-- =====================================================
-- VIEW
-- =====================================================

-- Task 1. Create a view with all flights departing on a specific date.
CREATE OR REPLACE VIEW v_flights_by_date AS
SELECT f.flight_id, a.airline_name,
       dep.city AS from_city, arr.city AS to_city,
       f.sch_departure_time, f.sch_arrival_time, f.departing_gate
FROM flights f
JOIN airline a   ON a.airline_id = f.airline_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
WHERE f.sch_departure_time::date = DATE '2026-10-02';

SELECT * FROM v_flights_by_date ORDER BY sch_departure_time;

-- Task 2. Create a view with bookings for flights departing within the next week.
CREATE OR REPLACE VIEW v_bookings_next_week AS
SELECT b.booking_id, p.first_name || ' ' || p.last_name AS passenger,
       f.flight_id, f.sch_departure_time, b.booking_platform, b.ticket_price
FROM booking b
JOIN flights f   ON f.flight_id = b.flight_id
JOIN passenger p ON p.passenger_id = b.passenger_id
WHERE f.sch_departure_time >= CURRENT_TIMESTAMP
  AND f.sch_departure_time <  CURRENT_TIMESTAMP + INTERVAL '7 days';

SELECT * FROM v_bookings_next_week
ORDER BY sch_departure_time, booking_id;

-- Task 3. Create a view with the top 5 most popular flight routes by number of bookings.
CREATE OR REPLACE VIEW v_top_routes AS
SELECT dep.city || ' - ' || arr.city AS route,
       COUNT(b.booking_id) AS total_bookings
FROM booking b
JOIN flights f   ON f.flight_id = b.flight_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
GROUP BY dep.city, arr.city
ORDER BY total_bookings DESC, route
LIMIT 5;

SELECT * FROM v_top_routes;

-- Task 4. Create a view that lists all flights of a specific airline.
CREATE OR REPLACE VIEW v_airline_flights AS
SELECT f.flight_id, a.airline_name,
       dep.city AS from_city, arr.city AS to_city,
       f.sch_departure_time, f.sch_arrival_time
FROM flights f
JOIN airline a   ON a.airline_id = f.airline_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
WHERE a.airline_name = 'Air Astana';

SELECT * FROM v_airline_flights ORDER BY sch_departure_time;

-- Task 5. Modify the view from task 4: only flights departing within the next 7 days.
CREATE OR REPLACE VIEW v_airline_flights AS
SELECT f.flight_id, a.airline_name,
       dep.city AS from_city, arr.city AS to_city,
       f.sch_departure_time, f.sch_arrival_time
FROM flights f
JOIN airline a   ON a.airline_id = f.airline_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
WHERE a.airline_name = 'Air Astana'
  AND f.sch_departure_time >= CURRENT_TIMESTAMP
  AND f.sch_departure_time <  CURRENT_TIMESTAMP + INTERVAL '7 days';

SELECT * FROM v_airline_flights ORDER BY sch_departure_time;

-- Task 6. Create a view with flights delayed by more than 24 hours.
CREATE OR REPLACE VIEW v_delayed_flights AS
SELECT f.*,
       f.act_departure_time - f.sch_departure_time AS delay
FROM flights f
WHERE f.act_departure_time - f.sch_departure_time > INTERVAL '24 hours';

SELECT flight_id, sch_departure_time, act_departure_time, delay
FROM v_delayed_flights
ORDER BY delay DESC;

-- Task 7. Create a view with full name and country of origin of passengers who booked on Leffler-Thompson.
CREATE OR REPLACE VIEW v_leffler_thompson_passengers AS
SELECT DISTINCT p.first_name || ' ' || p.last_name AS full_name,
       p.country_of_citizenship AS country_of_origin
FROM passenger p
JOIN booking b ON b.passenger_id = p.passenger_id
WHERE b.booking_platform = 'Leffler-Thompson';

SELECT * FROM v_leffler_thompson_passengers
ORDER BY full_name;

-- Task 8. Create a view with the top 10 most visited countries.
CREATE OR REPLACE VIEW v_top_countries AS
SELECT arr.country, COUNT(b.booking_id) AS visits
FROM booking b
JOIN flights f   ON f.flight_id = b.flight_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
GROUP BY arr.country
ORDER BY visits DESC, arr.country
LIMIT 10;

SELECT * FROM v_top_countries;

-- Task 9. Update a view: add new information through the view and show the result.
INSERT INTO v_delayed_flights
 (flight_id, sch_departure_time, sch_arrival_time, departing_airport_id,
  arriving_airport_id, departing_gate, arriving_gate, airline_id,
  act_departure_time, act_arrival_time, created_at, updated_at)
VALUES
 (301, '2026-11-20 08:00', '2026-11-20 12:00', 1, 1301, 'A1', 'B1', 3,
  '2026-11-21 14:00', '2026-11-21 18:00', now(), now());

UPDATE v_delayed_flights SET arriving_gate = 'B9' WHERE flight_id = 301;

SELECT flight_id, arriving_gate, sch_departure_time, act_departure_time, delay
FROM v_delayed_flights WHERE flight_id = 301;

SELECT flight_id, arriving_gate, airline_id FROM flights WHERE flight_id = 301;

-- Task 10. Drop all existing views.
SELECT viewname FROM pg_views WHERE schemaname = 'public' ORDER BY viewname;

DROP VIEW IF EXISTS v_flights_by_date, v_bookings_next_week, v_top_routes,
    v_airline_flights, v_delayed_flights,
    v_leffler_thompson_passengers, v_top_countries;

SELECT viewname FROM pg_views WHERE schemaname = 'public' ORDER BY viewname;


-- =====================================================
-- ROLES
-- =====================================================

-- Task 1. Create the group roles flight_manager and flight_analyst and show the roles.
CREATE ROLE flight_manager NOLOGIN;

CREATE ROLE flight_analyst NOLOGIN;

SELECT rolname, rolcanlogin, rolconnlimit
FROM pg_roles
WHERE rolname LIKE 'flight\_%' ORDER BY rolname;

-- Task 2. Create users first_user and second_user and add them to the group roles.
CREATE USER first_user  WITH PASSWORD 'first_pass_123'  IN ROLE flight_manager;

CREATE USER second_user WITH PASSWORD 'second_pass_123' IN ROLE flight_analyst;

SELECT g.rolname AS group_role, m.rolname AS member
FROM pg_auth_members am
JOIN pg_roles g ON g.oid = am.roleid
JOIN pg_roles m ON m.oid = am.member
WHERE g.rolname LIKE 'flight\_%' ORDER BY 1, 2;

-- Task 3. Grant flight_analyst SELECT on flights, airline and booking.
GRANT SELECT ON flights, airline, booking TO flight_analyst;

SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'flight_analyst' ORDER BY table_name;

-- Task 4. Grant flight_manager SELECT, INSERT, UPDATE on booking and SELECT on other tables.
GRANT SELECT ON ALL TABLES IN SCHEMA public TO flight_manager;

GRANT INSERT, UPDATE ON booking TO flight_manager;

SELECT table_name, string_agg(privilege_type, ', ' ORDER BY privilege_type) AS privileges
FROM information_schema.role_table_grants
WHERE grantee = 'flight_manager'
GROUP BY table_name ORDER BY table_name;

-- Task 5. Connect as second_user, read flights and try to delete from booking.
-- connect as second_user
SELECT flight_id, sch_departure_time, departing_gate FROM flights
ORDER BY flight_id LIMIT 5;

DELETE FROM booking WHERE booking_id = 1001;

-- Task 6. Connect as first_user, insert and update a booking, and try to delete one.
-- connect as first_user
INSERT INTO booking (booking_id, flight_id, passenger_id, booking_platform,
                     created_at, updated_at, status, ticket_price)
VALUES (9001, 101, 1, 'Website', now(), now(), 'Confirmed', 45000);

UPDATE booking SET status = 'Checked-in', updated_at = now()
WHERE booking_id = 9001;

DELETE FROM booking WHERE booking_id = 9001;

SELECT booking_id, status, ticket_price FROM booking WHERE booking_id = 9001;

-- Task 7. Grant column-level SELECT on the full name and country columns of passenger.
GRANT SELECT (first_name, last_name, country_of_citizenship)
ON passenger TO flight_analyst;

SET ROLE second_user;

SELECT first_name, last_name, country_of_citizenship
FROM passenger ORDER BY last_name, first_name LIMIT 4;

SELECT passport_number FROM passenger;

RESET ROLE;

-- Task 8. Revoke SELECT on booking from flight_analyst and show that access is denied.
REVOKE SELECT ON booking FROM flight_analyst;

SET ROLE second_user;

SELECT * FROM booking LIMIT 3;

SELECT COUNT(*) AS flights_visible FROM flights;

RESET ROLE;

-- Task 9. Alter roles: change a password, set a connection limit and rename a role.
ALTER ROLE first_user WITH PASSWORD 'new_pass_456';

ALTER ROLE second_user CONNECTION LIMIT 5;

ALTER ROLE flight_analyst RENAME TO flight_reader;

SELECT rolname, rolcanlogin, rolconnlimit FROM pg_roles
WHERE rolname IN ('first_user','second_user','flight_manager','flight_reader')
ORDER BY rolname;

-- Task 10. Drop all created roles.
DROP OWNED BY first_user, second_user, flight_manager, flight_reader;

DROP ROLE first_user, second_user, flight_manager, flight_reader;

SELECT rolname FROM pg_roles
WHERE rolname IN ('first_user','second_user','flight_manager','flight_reader');
