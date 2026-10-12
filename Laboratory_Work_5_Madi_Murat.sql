-- Laboratory Work 5
-- Student: Madi Murat
-- Database: airport_db
-- PostgreSQL 16

-- Task 1. Passengers must be at least 10 years old.
ALTER TABLE passenger
    DROP CONSTRAINT IF EXISTS chk_passenger_min_age_10;

ALTER TABLE passenger
    ADD CONSTRAINT chk_passenger_min_age_10
    CHECK (
        date_of_birth IS NOT NULL
        AND date_of_birth <= CURRENT_DATE - INTERVAL '10 years'
    ) NOT VALID;


-- Task 2. The ticket price must be from 0 to 50000 tenge.
-- The original wording says "less than 0". It is treated as "not less than 0".
ALTER TABLE booking
    DROP CONSTRAINT IF EXISTS chk_booking_ticket_price;

UPDATE booking
SET ticket_price = 50000
WHERE ticket_price > 50000;

UPDATE booking
SET ticket_price = 0
WHERE ticket_price < 0;

ALTER TABLE booking
    ADD CONSTRAINT chk_booking_ticket_price
    CHECK (ticket_price BETWEEN 0 AND 50000);


-- Task 3. Baggage weight must be from 1 to 23 kg.
ALTER TABLE baggage
    DROP CONSTRAINT IF EXISTS chk_baggage_weight;

ALTER TABLE baggage
    ADD CONSTRAINT chk_baggage_weight
    CHECK (weight_in_kg BETWEEN 1 AND 23) NOT VALID;


-- Task 4. Airport names must contain at least 10 characters.
ALTER TABLE airport
    DROP CONSTRAINT IF EXISTS chk_airport_name_length;

ALTER TABLE airport
    ADD CONSTRAINT chk_airport_name_length
    CHECK (CHAR_LENGTH(TRIM(airport_name)) >= 10) NOT VALID;


-- Task 5. Add useful UNIQUE constraints to every table in this database.
ALTER TABLE airline DROP CONSTRAINT IF EXISTS airline_airline_code_key;
ALTER TABLE airline DROP CONSTRAINT IF EXISTS uq_airline_code;
ALTER TABLE airline
    ADD CONSTRAINT uq_airline_code UNIQUE (airline_code);

ALTER TABLE airport DROP CONSTRAINT IF EXISTS uq_airport_name_city;
ALTER TABLE airport
    ADD CONSTRAINT uq_airport_name_city UNIQUE (airport_name, city);

ALTER TABLE passenger DROP CONSTRAINT IF EXISTS uq_passenger_identity;
ALTER TABLE passenger
    ADD CONSTRAINT uq_passenger_identity
    UNIQUE (first_name, last_name, date_of_birth);

ALTER TABLE flights DROP CONSTRAINT IF EXISTS uq_flight_schedule;
ALTER TABLE flights
    ADD CONSTRAINT uq_flight_schedule
    UNIQUE (
        sch_departure_time,
        departing_airport_id,
        arriving_airport_id,
        airline_id
    );

ALTER TABLE booking DROP CONSTRAINT IF EXISTS uq_booking_flight_passenger;
ALTER TABLE booking
    ADD CONSTRAINT uq_booking_flight_passenger
    UNIQUE (flight_id, passenger_id, created_at);

ALTER TABLE baggage DROP CONSTRAINT IF EXISTS uq_baggage_booking_weight;
ALTER TABLE baggage
    ADD CONSTRAINT uq_baggage_booking_weight
    UNIQUE (booking_id, weight_in_kg);

ALTER TABLE baggage_check DROP CONSTRAINT IF EXISTS uq_baggage_check_event;
ALTER TABLE baggage_check
    ADD CONSTRAINT uq_baggage_check_event
    UNIQUE (booking_id, passenger_id, created_at);


-- Task 6. Male passengers must be at least 18 years old;
-- female passengers must be at least 19 years old.
ALTER TABLE passenger
    DROP CONSTRAINT IF EXISTS chk_passenger_gender_age;

ALTER TABLE passenger
    ADD CONSTRAINT chk_passenger_gender_age
    CHECK (
        CASE
            WHEN LOWER(gender) = 'male' THEN
                date_of_birth <= CURRENT_DATE - INTERVAL '18 years'
            WHEN LOWER(gender) = 'female' THEN
                date_of_birth <= CURRENT_DATE - INTERVAL '19 years'
            ELSE TRUE
        END
    ) NOT VALID;


-- Task 7. Add and use country_of_citizenship.
ALTER TABLE passenger
    ADD COLUMN IF NOT EXISTS country_of_citizenship VARCHAR(100);

UPDATE passenger
SET country_of_citizenship = country
WHERE country_of_citizenship IS NULL;

ALTER TABLE passenger
    ALTER COLUMN country_of_citizenship SET NOT NULL;

ALTER TABLE passenger
    DROP CONSTRAINT IF EXISTS chk_passenger_citizenship_age;

ALTER TABLE passenger
    ADD CONSTRAINT chk_passenger_citizenship_age
    CHECK (
        date_of_birth <= CURRENT_DATE -
        CASE
            WHEN LOWER(country_of_citizenship) = 'kazakhstan'
                THEN INTERVAL '18 years'
            WHEN LOWER(country_of_citizenship) = 'france'
                THEN INTERVAL '17 years'
            ELSE INTERVAL '19 years'
        END
    ) NOT VALID;


-- Task 8. Add a discount amount and check it against the creation date.
ALTER TABLE booking
    ADD COLUMN IF NOT EXISTS ticket_discount NUMERIC(12, 2);

UPDATE booking
SET ticket_discount = ROUND(
    ticket_price *
    CASE
        WHEN created_at >= TIMESTAMP '2024-01-01 00:00:00' THEN 0.05
        ELSE 0.10
    END,
    2
);

ALTER TABLE booking
    ALTER COLUMN ticket_discount SET NOT NULL;

ALTER TABLE booking
    DROP CONSTRAINT IF EXISTS chk_booking_ticket_discount;

ALTER TABLE booking
    ADD CONSTRAINT chk_booking_ticket_discount
    CHECK (
        ticket_discount = ROUND(
            ticket_price *
            CASE
                WHEN created_at >= TIMESTAMP '2024-01-01 00:00:00' THEN 0.05
                ELSE 0.10
            END,
            2
        )
    ) NOT VALID;


-- Task 9. Default booking status is Confirmed.
ALTER TABLE booking
    ALTER COLUMN status SET DEFAULT 'Confirmed';

DELETE FROM booking WHERE booking_id = 1300;

INSERT INTO booking (
    booking_id,
    flight_id,
    passenger_id,
    booking_platform,
    created_at,
    updated_at,
    ticket_price,
    ticket_discount
)
VALUES (
    1300,
    103,
    3,
    'Website',
    TIMESTAMP '2024-02-15 12:00:00',
    TIMESTAMP '2024-02-15 12:00:00',
    35000.00,
    1750.00
);


-- Task 10. New booking rows automatically receive the current date and time.
ALTER TABLE booking
    ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP;

DELETE FROM booking WHERE booking_id = 1301;

INSERT INTO booking (
    booking_id,
    flight_id,
    passenger_id,
    booking_platform,
    ticket_price,
    ticket_discount
)
VALUES (
    1301,
    103,
    5,
    'Mobile App',
    42000.00,
    2100.00
);


-- Final verification.
SELECT
    conrelid::regclass AS table_name,
    conname AS constraint_name,
    contype AS constraint_type,
    convalidated AS validated
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
  AND (
      conname LIKE 'chk_%'
      OR conname LIKE 'uq_%'
  )
ORDER BY conrelid::regclass::text, conname;

SELECT
    booking_id,
    created_at,
    status,
    ticket_price,
    ticket_discount
FROM booking
WHERE booking_id IN (1300, 1301)
ORDER BY booking_id;
