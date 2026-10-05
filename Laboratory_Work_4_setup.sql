-- Laboratory Work 4
-- Small idempotent data set used to demonstrate non-empty SELECT results.
-- Existing rows are not deleted. Re-running this file does not create duplicates.

BEGIN;

-- Airlines for tasks 8 and 12.
INSERT INTO airline
    (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
VALUES
    (10, 'F2',  'France Connect',  'France',   TIMESTAMP '2024-01-15 10:00:00', TIMESTAMP '2024-01-15 10:00:00'),
    (11, 'P7',  'Portugal Air',    'Portugal', TIMESTAMP '2024-02-10 11:30:00', TIMESTAMP '2024-02-10 11:30:00'),
    (12, 'PL8', 'Poland Regional', 'Poland',   TIMESTAMP '2023-12-05 09:15:00', TIMESTAMP '2023-12-05 09:15:00')
ON CONFLICT DO NOTHING;

-- Airports for task 4. The assignment contains the typo "Reginal";
-- the correct English word "Regional" is used in the data and query.
INSERT INTO airport
    (airport_id, airport_name, country, state, city, created_at, updated_at)
VALUES
    (1201, 'Kokshetau Regional Airport', 'Kazakhstan', 'Akmola Region', 'Kokshetau', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1202, 'Aktobe Regional Airport',    'Kazakhstan', 'Aktobe Region', 'Aktobe',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- Restore realistic actual times for tasks 6 and 7.
UPDATE flights
SET act_departure_time = TIMESTAMP '2026-10-01 07:05:00',
    act_arrival_time   = TIMESTAMP '2026-10-01 09:43:00'
WHERE flight_id = 101
  AND act_arrival_time IS NULL;

UPDATE flights
SET airline_id         = 2,
    act_departure_time = TIMESTAMP '2026-10-02 09:33:00',
    act_arrival_time   = TIMESTAMP '2026-10-02 15:18:00'
WHERE flight_id = 102
  AND act_arrival_time IS NULL;

UPDATE flights
SET act_departure_time = TIMESTAMP '2026-10-03 04:25:00',
    act_arrival_time   = TIMESTAMP '2026-10-03 11:44:00'
WHERE flight_id = 103
  AND act_arrival_time IS NULL;

-- Bookings in the range required by task 14.
INSERT INTO booking
    (booking_id, flight_id, passenger_id, booking_platform,
     created_at, updated_at, status, ticket_price)
VALUES
    (220, 101, 1, 'Website',   TIMESTAMP '2024-03-10 09:00:00', TIMESTAMP '2024-03-10 09:00:00', 'Confirmed', 27500.00),
    (250, 102, 2, 'Mobile App', TIMESTAMP '2024-04-02 10:30:00', TIMESTAMP '2024-04-02 10:30:00', 'Confirmed', 30000.00)
ON CONFLICT DO NOTHING;

-- Baggage checks for tasks 14 and 15.
INSERT INTO baggage_check
    (baggage_check_id, check_result, created_at, updated_at, booking_id, passenger_id)
VALUES
    (200, 'Not checked', TIMESTAMP '2024-03-20 12:00:00', TIMESTAMP '2024-03-18 09:00:00', 220, 1),
    (201, 'Inspection',  TIMESTAMP '2024-04-02 11:00:00', TIMESTAMP '2024-04-02 11:15:00', 250, 2)
ON CONFLICT DO NOTHING;

-- The current local database does not contain the baggage table from Lab 2.
CREATE TABLE IF NOT EXISTS baggage (
    baggage_id    INT PRIMARY KEY,
    weight_in_kg  DECIMAL(4,2) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    booking_id    INT NOT NULL REFERENCES booking(booking_id)
);

INSERT INTO baggage
    (baggage_id, weight_in_kg, created_at, updated_at, booking_id)
VALUES
    (1, 18.50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1001),
    (2, 32.80, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1002),
    (3, 27.40, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1003),
    (4, 29.60, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1004),
    (5, 15.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1005),
    (6, 24.90, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 220),
    (7, 26.10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 250)
ON CONFLICT DO NOTHING;

COMMIT;
