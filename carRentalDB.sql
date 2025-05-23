-- Drop tables in reverse order of creation to avoid FK constraint issues 
-- DROP TABLE IF EXISTS payments;
-- DROP TABLE IF EXISTS maintenances;
-- DROP TABLE IF EXISTS insurances;
-- DROP TABLE IF EXISTS rentals;
-- DROP TABLE IF EXISTS reservations;
-- DROP TABLE IF EXISTS cars;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS locations;

-- Locations Table
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    contact_number VARCHAR(20)
);

-- Customers Table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    address TEXT
);

-- Cars Table
CREATE TABLE cars (
    car_id SERIAL PRIMARY KEY,
    car_model VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    year SMALLINT CHECK (year > 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    color VARCHAR(30),
    rental_rate DECIMAL(10, 2) NOT NULL CHECK (rental_rate > 0),
    availability VARCHAR(20) DEFAULT 'Available' CHECK (availability IN ('Available', 'Rented', 'Maintenance', 'Reserved')),
    current_location_id INTEGER NOT NULL,
    CONSTRAINT fk_car_location
        FOREIGN KEY(current_location_id)
        REFERENCES locations(location_id)
        ON DELETE RESTRICT -- A car must be based at an existing location
);

-- Reservations Table
CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    reservation_date DATE NOT NULL DEFAULT CURRENT_DATE,
    pickup_date DATE NOT NULL,
    return_date DATE NOT NULL,
    pickup_location_id INTEGER NOT NULL,
    return_location_id INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'Confirmed' CHECK (status IN ('Confirmed', 'Cancelled', 'Completed', 'No-Show')),
    CONSTRAINT fk_reservation_car
        FOREIGN KEY(car_id)
        REFERENCES cars(car_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_reservation_customer
        FOREIGN KEY(customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_reservation_pickup_location
        FOREIGN KEY(pickup_location_id)
        REFERENCES locations(location_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_reservation_return_location
        FOREIGN KEY(return_location_id)
        REFERENCES locations(location_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_reservation_dates CHECK (pickup_date >= reservation_date AND return_date > pickup_date)
);

-- Rentals Table
CREATE TABLE rentals (
    rental_id SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    reservation_id INTEGER NULL, -- Optional link to a reservation
    rental_start_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expected_return_date TIMESTAMP NOT NULL,
    rental_end_date TIMESTAMP NULL, -- Null if rental is ongoing
    total_amount DECIMAL(10, 2) CHECK (total_amount >= 0),
    pickup_location_id INTEGER NOT NULL,
    return_location_id INTEGER NULL, -- Can be null until returned, or if one-way allowed and specified
    CONSTRAINT fk_rental_car
        FOREIGN KEY(car_id)
        REFERENCES cars(car_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_rental_customer
        FOREIGN KEY(customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_rental_reservation
        FOREIGN KEY(reservation_id)
        REFERENCES reservations(reservation_id)
        ON DELETE SET NULL, -- If reservation is deleted, rental can still exist
    CONSTRAINT fk_rental_pickup_location
        FOREIGN KEY(pickup_location_id)
        REFERENCES locations(location_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_rental_return_location
        FOREIGN KEY(return_location_id)
        REFERENCES locations(location_id)
        ON DELETE SET NULL, -- A car might be returned to a different (or null if unknown yet) location
    CONSTRAINT chk_rental_dates CHECK (expected_return_date > rental_start_date),
    CONSTRAINT chk_rental_end_date CHECK (rental_end_date IS NULL OR rental_end_date >= rental_start_date)
);

-- Payments Table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    rental_id INTEGER NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(50) CHECK (payment_method IN ('Credit Card', 'Debit Card', 'Cash', 'Online Transfer', 'Mobile Money')),
    CONSTRAINT fk_payment_rental
        FOREIGN KEY(rental_id)
        REFERENCES rentals(rental_id)
        ON DELETE CASCADE -- If a rental is deleted, its payments are deleted
);

-- Insurances Table
CREATE TABLE insurances (
    insurance_id SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL,
    insurance_provider VARCHAR(100) NOT NULL,
    policy_number VARCHAR(50) UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT fk_insurance_car
        FOREIGN KEY(car_id)
        REFERENCES cars(car_id)
        ON DELETE CASCADE, -- If a car is deleted, its insurance policies are deleted
    CONSTRAINT chk_insurance_dates CHECK (end_date > start_date)
);

-- Maintenances Table
CREATE TABLE maintenances (
    maintenance_id SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL,
    maintenance_date DATE NOT NULL,
    description TEXT NOT NULL,
    cost DECIMAL(10, 2) CHECK (cost >= 0),
    status VARCHAR(50) DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT fk_maintenance_car
        FOREIGN KEY(car_id)
        REFERENCES cars(car_id)
        ON DELETE CASCADE -- If a car is deleted, its maintenance records are deleted
);

-- Add indexes for frequently queried foreign keys for performance
CREATE INDEX idx_cars_location_id ON cars(current_location_id);
CREATE INDEX idx_reservations_car_id ON reservations(car_id);
CREATE INDEX idx_reservations_customer_id ON reservations(customer_id);
CREATE INDEX idx_rentals_car_id ON rentals(car_id);
CREATE INDEX idx_rentals_customer_id ON rentals(customer_id);
CREATE INDEX idx_rentals_reservation_id ON rentals(reservation_id);
CREATE INDEX idx_payments_rental_id ON payments(rental_id);
CREATE INDEX idx_insurances_car_id ON insurances(car_id);
CREATE INDEX idx_maintenances_car_id ON maintenances(car_id);

-- Insert into locations (Parent table)
INSERT INTO locations (location_name, address, contact_number) VALUES
('Downtown Branch', '123 Main St, Cityville', '555-0101'),
('Airport Kiosk', '789 Airport Rd, Terminal A', '555-0102'),
('North Suburb Office', '456 Oak Ln, Northtown', '555-0103'),
('Westside Garage', '321 Pine Ave, Westburg', '555-0104'),
('East End Lot', '654 Maple Dr, Eastville', '555-0105');

-- Insert into customers (Parent table)
INSERT INTO customers (first_name, last_name, email, phone_number, address) VALUES
('John', 'Doe', 'john.doe@example.com', '555-1234', '10 Downing St, Capital City'),
('Jane', 'Smith', 'jane.smith@example.com', '555-5678', '22 Baker St, Metroburg'),
('Alice', 'Brown', 'alice.brown@example.com', '555-9012', '34 Abbey Rd, Townsville'),
('Bob', 'Green', 'bob.green@example.com', '555-3456', '45 Penny Ln, Villagetown'),
('Charlie', 'White', 'charlie.white@example.com', '555-7890', '56 Strawberry Fields, Countryside');

-- Insert into cars (Depends on locations)
INSERT INTO cars (car_model, manufacturer, year, color, rental_rate, availability, current_location_id) VALUES
('Corolla', 'Toyota', 2022, 'Silver', 50.00, 'Available', 1),
('Civic', 'Honda', 2023, 'Black', 55.00, 'Available', 1),
('Mustang', 'Ford', 2021, 'Red', 80.00, 'Maintenance', 2),
('CX-5', 'Mazda', 2022, 'Blue', 65.00, 'Available', 3),
('Model 3', 'Tesla', 2023, 'White', 120.00, 'Rented', 2),
('Outback', 'Subaru', 2022, 'Green', 70.00, 'Available', 4); -- Added a 6th car for more variety

-- Insert into reservations (Depends on cars, customers, locations)
INSERT INTO reservations (car_id, customer_id, reservation_date, pickup_date, return_date, pickup_location_id, return_location_id, status) VALUES
(1, 1, '2025-05-20', '2025-06-01', '2025-06-05', 1, 1, 'Confirmed'),
(2, 2, '2025-05-21', '2025-06-10', '2025-06-15', 1, 2, 'Confirmed'),
(4, 3, '2025-05-22', '2025-06-03', '2025-06-07', 3, 3, 'Cancelled'),
(1, 4, '2025-05-23', '2025-07-01', '2025-07-10', 1, 1, 'Confirmed'),
(5, 5, '2025-05-23', '2025-05-25', '2025-05-30', 2, 2, 'Completed'); -- Assuming car 5 was pre-reserved and is now 'Rented'

-- Insert into rentals (Depends on cars, customers, locations, optionally reservations)
-- Assuming car_id=5 is already rented, let's rent car_id=1
INSERT INTO rentals (car_id, customer_id, reservation_id, rental_start_date, expected_return_date, total_amount, pickup_location_id, return_location_id) VALUES
(1, 1, 1, '2025-06-01 09:00:00', '2025-06-05 09:00:00', 200.00, 1, 1),
(5, 5, 5, '2025-05-25 10:00:00', '2025-05-30 10:00:00', 600.00, 2, 2), -- Rental for the Tesla
(2, 3, NULL, '2025-05-15 14:00:00', '2025-05-20 14:00:00', 275.00, 1, 1), -- Walk-in, car 2 was available before reservation
(4, 4, NULL, '2025-05-10 11:00:00', '2025-05-17 11:00:00', 455.00, 3, 3),
(6, 2, NULL, '2025-05-20 16:00:00', '2025-05-27 16:00:00', 490.00, 4, 4);
-- Update car availability after rentals
UPDATE cars SET availability = 'Rented' WHERE car_id IN (1, 5, 2, 4, 6); -- Reflecting the rentals

-- Insert into payments (Depends on rentals)
INSERT INTO payments (rental_id, payment_date, amount, payment_method) VALUES
(1, '2025-06-01 09:05:00', 200.00, 'Credit Card'),
(2, '2025-05-25 10:05:00', 600.00, 'Online Transfer'),
(3, '2025-05-15 14:05:00', 275.00, 'Mobile Money'),
(4, '2025-05-10 11:05:00', 455.00, 'Credit Card'),
(5, '2025-05-20 16:05:00', 490.00, 'Debit Card');

-- Insert into insurances (Depends on cars)
INSERT INTO insurances (car_id, insurance_provider, policy_number, start_date, end_date) VALUES
(1, 'AllSecure Insurers', 'POL12345A', '2025-01-01', '2025-12-31'),
(2, 'SafeRide Assurance', 'POL67890B', '2025-02-01', '2026-01-31'),
(3, 'CoverAll Ltd.', 'POL24680C', '2024-11-01', '2025-10-31'),
(4, 'Guardian Auto', 'POL13579D', '2025-03-15', '2026-03-14'),
(5, 'Premium Protect', 'POL97531E', '2025-04-01', '2026-03-31');

-- Insert into maintenances (Depends on cars)
INSERT INTO maintenances (car_id, maintenance_date, description, cost, status) VALUES
(3, '2025-05-15', 'Routine oil change and inspection', 150.00, 'Completed'),
(1, '2025-07-01', 'Tire rotation', 75.00, 'Scheduled'),
(5, '2025-04-20', 'Battery check and software update', 200.00, 'Completed'),
(2, '2025-08-10', 'Brake pad replacement', 300.00, 'Scheduled'),
(4, '2025-09-01', 'Annual service', 250.00, 'Scheduled');
-- Update car availability for car 3 if maintenance is ongoing
UPDATE cars SET availability = 'Available' WHERE car_id = 3 AND availability = 'Maintenance'; -- Assuming maintenance is done for car 3

-- ===========================
--   READ  OPERATIONS
-- ===========================

-- Select all cars available at 'Downtown Branch' (location_id=1)
SELECT c.car_id, c.manufacturer, c.car_model, c.rental_rate
FROM cars c
JOIN locations l ON c.current_location_id = l.location_id
WHERE l.location_name = 'Downtown Branch' AND c.availability = 'Available';

-- Select all active rentals with customer and car details
SELECT r.rental_id, cu.first_name || ' ' || cu.last_name AS customer_name,
       ca.manufacturer || ' ' || ca.car_model AS car,
       r.rental_start_date, r.expected_return_date, r.total_amount
FROM rentals r
JOIN customers cu ON r.customer_id = cu.customer_id
JOIN cars ca ON r.car_id = ca.car_id
WHERE r.rental_end_date IS NULL;

-- Select payment details for a specific rental (e.g., rental_id = 1)
SELECT payment_id, payment_date, amount, payment_method
FROM payments
WHERE rental_id = 1;

-- Select all reservations for a specific customer (e.g., customer_id = 1 John Doe)
SELECT res.reservation_id, ca.manufacturer, ca.car_model, res.pickup_date, res.return_date, res.status
FROM reservations res
JOIN cars ca ON res.car_id = ca.car_id
WHERE res.customer_id = 1
ORDER BY res.pickup_date DESC;

-- List all cars currently under maintenance
SELECT c.car_id, c.manufacturer, c.car_model, m.description, m.maintenance_date
FROM cars c
JOIN maintenances m ON c.car_id = m.car_id
WHERE c.availability = 'Maintenance' OR m.status = 'In Progress';


--===========================
--           UPDATE OPERATIONS
-- ======================
-- Update a customer's phone number and address
UPDATE customers
SET phone_number = '555-4321', address = '11 New Street, Capital City'
WHERE email = 'john.doe@example.com';

-- Extend a rental's expected return date and update total amount (e.g., rental_id = 1)
UPDATE rentals
SET expected_return_date = '2025-06-07 09:00:00', total_amount = total_amount + (2 * (SELECT rental_rate FROM cars WHERE car_id = rentals.car_id))
WHERE rental_id = 1 AND rental_end_date IS NULL; -- Only update if rental is active

-- Change a car's availability status after maintenance is completed (e.g., car_id from maintenance example, assuming car_id=3 if it was 'Maintenance')
-- Let's say car_id=3 (Ford Mustang) maintenance is completed
UPDATE cars
SET availability = 'Available'
WHERE car_id = 3 AND availability = 'Maintenance';
UPDATE maintenances
SET status = 'Completed', cost = 160.00 -- if cost changed or was finalized
WHERE car_id = 3 AND status = 'In Progress'; -- Assuming it was in progress, or find the specific maintenance_id

-- Modify a reservation status to 'Cancelled' (e.g., reservation_id = 4, which was already cancelled, let's use reservation_id=2)
UPDATE reservations
SET status = 'Cancelled'
WHERE reservation_id = 2;
-- If a car was reserved, it might become available again if no other reservations
UPDATE cars SET availability = 'Available'
WHERE car_id = (SELECT car_id FROM reservations WHERE reservation_id = 2)
  AND NOT EXISTS (SELECT 1 FROM reservations WHERE car_id = (SELECT car_id FROM reservations WHERE reservation_id = 2) AND status = 'Confirmed' AND pickup_date >= CURRENT_DATE)
  AND availability = 'Reserved';


-- Verify Updates
SELECT * FROM customers WHERE email = 'john.doe@example.com';
SELECT * FROM rentals WHERE rental_id = 1;
SELECT availability FROM cars WHERE car_id = 3;
SELECT status FROM reservations WHERE reservation_id = 2;

-- ======================
--           UPSERT OPERATIONS (INSERT ... ON CONFLICT)
-- ======================

-- Upserting a Customer: Insert if email doesn't exist, Update if email exists.
-- Example 1: Insert a new customer.
INSERT INTO customers (first_name, last_name, email, phone_number, address)
VALUES ('New', 'User', 'new.user@example.com', '555-9999', '77 Innovation Way')
ON CONFLICT (email)
DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    phone_number = EXCLUDED.phone_number,
    address = EXCLUDED.address;

-- Example 2: Update an existing customer (John Doe, email: john.doe@example.com)
-- This will update his name (if changed), phone number, and address.
INSERT INTO customers (first_name, last_name, email, phone_number, address)
VALUES ('Jonathan', 'Doe-Smith', 'john.doe@example.com', '555-1111', '10 Downing Street, Capital City')
ON CONFLICT (email)
DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    phone_number = EXCLUDED.phone_number,
    address = EXCLUDED.address;

-- Upserting an Insurance Policy: Insert if policy_number doesn't exist, Update if policy_number exists.
-- Note: This assumes you know the car_id for the policy.
-- Example 1: Insert a new insurance policy for an existing car (e.g., car_id=6).
-- We need a car_id for this. Let's use car_id=6 (Outback)
INSERT INTO insurances (car_id, insurance_provider, policy_number, start_date, end_date)
VALUES (6, 'BestCoverage Inc.', 'POL54321F', '2025-06-01', '2026-05-31')
ON CONFLICT (policy_number)
DO UPDATE SET
    car_id = EXCLUDED.car_id, -- Update car_id if policy transferred
    insurance_provider = EXCLUDED.insurance_provider,
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date;

-- Example 2: Update an existing insurance policy (e.g., policy_number='POL12345A' for car_id=1).
-- This will update the end date and provider for policy 'POL12345A'.
INSERT INTO insurances (car_id, insurance_provider, policy_number, start_date, end_date)
VALUES (1, 'AllSecure Insurers Updated', 'POL12345A', '2025-01-01', '2026-12-31') -- New end_date
ON CONFLICT (policy_number)
DO UPDATE SET
    car_id = EXCLUDED.car_id,
    insurance_provider = EXCLUDED.insurance_provider,
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date;

-- Verify Upserts
SELECT * FROM customers WHERE email IN ('new.user@example.com', 'john.doe@example.com');
SELECT * FROM insurances WHERE policy_number IN ('POL54321F', 'POL12345A');

-- ======================
  -- DELETE OPERATIONS  
-- ===================
-- Delete a specific payment record (e.g., payment_id = 3)
DELETE FROM payments
WHERE payment_id = 3;

-- Cancel a reservation (e.g., reservation_id = 4 which was already cancelled, let's use a different one if needed or just delete)
-- If the reservation has not led to a rental.
DELETE FROM reservations
WHERE reservation_id = 4 AND status = 'Cancelled'; -- Only delete if it's safe to do so.

-- Remove an insurance policy that has expired long ago (e.g., for car_id=3, find an old policy_number)
-- First find an old policy_number if unknown: SELECT policy_number FROM insurances WHERE car_id = 3 AND end_date < '2025-01-01';
-- Assuming policy 'POL24680C' is old.
DELETE FROM insurances
WHERE policy_number = 'POL24680C';

-- Delete a customer who has no rentals or reservations (e.g., create a dummy customer then delete)
INSERT INTO customers (first_name, last_name, email, phone_number, address)
VALUES ('Temp', 'User', 'temp.user@example.com', '555-0000', '1 Delete St');
DELETE FROM customers
WHERE email = 'temp.user@example.com'
  AND NOT EXISTS (SELECT 1 FROM rentals WHERE customer_id = (SELECT customer_id from customers where email = 'temp.user@example.com'))
  AND NOT EXISTS (SELECT 1 FROM reservations WHERE customer_id = (SELECT customer_id from customers where email = 'temp.user@example.com'));

-- Delete a maintenance record (e.g., maintenance_id = 2 which was scheduled)
DELETE FROM maintenances
WHERE maintenance_id = 2 AND status = 'Scheduled';

-- Verify Deletions
SELECT * FROM payments WHERE payment_id = 3;
SELECT * FROM reservations WHERE reservation_id = 4;
SELECT * FROM insurances WHERE policy_number = 'POL24680C';
SELECT * FROM customers WHERE email = 'temp.user@example.com';
SELECT * FROM maintenances WHERE maintenance_id = 2;