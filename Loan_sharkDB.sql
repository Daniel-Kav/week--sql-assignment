-- =====================================================
-- EXPANDED LOAN SHARK BUSINESS DATABASE IMPLEMENTATION (8 TABLES)
-- =====================================================

-- =====================================================
-- TABLE CREATION (DDL) - 8 TABLES
-- =====================================================

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS loan_officers CASCADE;
DROP TABLE IF EXISTS collateral CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS borrowers CASCADE;
DROP TABLE IF EXISTS lenders CASCADE;
DROP TABLE IF EXISTS territories CASCADE;

-- Create TERRITORIES table
CREATE TABLE territories (
    territory_id SERIAL PRIMARY KEY,
    territory_name VARCHAR(100) UNIQUE NOT NULL,
    district VARCHAR(100) NOT NULL,
    risk_level VARCHAR(20) DEFAULT 'MEDIUM' CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'EXTREME')),
    population INTEGER CHECK (population > 0),
    avg_income DECIMAL(10,2) CHECK (avg_income >= 0)
);

-- Create LENDERS table
CREATE TABLE lenders (
    lender_id SERIAL PRIMARY KEY,
    territory_id INTEGER,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    commission_rate DECIMAL(5,4) DEFAULT 0.1000,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    FOREIGN KEY (territory_id) REFERENCES territories(territory_id) ON DELETE SET NULL
);

-- Create BORROWERS table
CREATE TABLE borrowers (
    borrower_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    occupation VARCHAR(100),
    monthly_income DECIMAL(10,2),
    credit_score INTEGER CHECK (credit_score BETWEEN 300 AND 850),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Create LOANS table
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    borrower_id INTEGER NOT NULL,
    lender_id INTEGER NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL CHECK (principal_amount > 0),
    interest_rate DECIMAL(6,4) NOT NULL CHECK (interest_rate > 0),
    loan_term_days INTEGER NOT NULL CHECK (loan_term_days > 0),
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PAID', 'OVERDUE', 'DEFAULT')),
    total_amount_due DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (borrower_id) REFERENCES borrowers(borrower_id) ON DELETE CASCADE,
    FOREIGN KEY (lender_id) REFERENCES lenders(lender_id) ON DELETE CASCADE
);

-- Create PAYMENTS table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL CHECK (payment_amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(20) DEFAULT 'CASH' CHECK (payment_method IN ('CASH', 'BANK_TRANSFER', 'CHECK', 'DIGITAL')),
    remaining_balance DECIMAL(12,2) NOT NULL CHECK (remaining_balance >= 0),
    transaction_ref VARCHAR(50) UNIQUE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
);

-- Create COLLATERAL table
CREATE TABLE collateral (
    collateral_id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL,
    item_description TEXT NOT NULL,
    estimated_value DECIMAL(10,2) NOT NULL CHECK (estimated_value > 0),
    item_type VARCHAR(50) NOT NULL,
    storage_location VARCHAR(200),
    condition_status VARCHAR(20) DEFAULT 'GOOD' CHECK (condition_status IN ('EXCELLENT', 'GOOD', 'FAIR', 'POOR')),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
);

-- Create LOAN_OFFICERS table
CREATE TABLE loan_officers (
    officer_id SERIAL PRIMARY KEY,
    lender_id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    specialization VARCHAR(100),
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    performance_rating DECIMAL(3,2) CHECK (performance_rating BETWEEN 0.00 AND 5.00),
    FOREIGN KEY (lender_id) REFERENCES lenders(lender_id) ON DELETE CASCADE
);

-- Create AUDIT_LOGS table
CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation_type VARCHAR(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id INTEGER NOT NULL,
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100) DEFAULT CURRENT_USER,
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CREATE OPERATIONS - INSERT DUMMY DATA 
-- =====================================================

-- Insert 5 TERRITORIES
INSERT INTO territories (territory_name, district, risk_level, population, avg_income) VALUES
('Downtown Core', 'Central District', 'HIGH', 125000, 45000.00),
('North Side', 'Northern District', 'MEDIUM', 85000, 38000.00),
('East End', 'Eastern District', 'HIGH', 95000, 32000.00),
('West Hills', 'Western District', 'LOW', 65000, 62000.00),
('South Harbor', 'Southern District', 'EXTREME', 110000, 28000.00);

-- Insert 5 LENDERS
INSERT INTO lenders (territory_id, first_name, last_name, phone_number, email, commission_rate, hire_date, status) VALUES
(1, 'Vincent', 'Torrino', '+1-555-0101', 'v.torrino@loanshark.com', 0.1500, '2020-01-15', 'ACTIVE'),
(2, 'Marco', 'Salvatore', '+1-555-0102', 'm.salvatore@loanshark.com', 0.1200, '2019-05-20', 'ACTIVE'),
(3, 'Tony', 'Ricci', '+1-555-0103', 't.ricci@loanshark.com', 0.1300, '2021-03-10', 'ACTIVE'),
(4, 'Sofia', 'Castellano', '+1-555-0104', 's.castellano@loanshark.com', 0.1400, '2020-08-25', 'SUSPENDED'),
(5, 'Rocco', 'Benedetti', '+1-555-0105', 'r.benedetti@loanshark.com', 0.1100, '2018-11-30', 'ACTIVE');

-- Insert 5 BORROWERS
INSERT INTO borrowers (first_name, last_name, phone_number, address, occupation, monthly_income, credit_score) VALUES
('Michael', 'Johnson', '+1-555-1001', '123 Oak Street, Apartment 4B', 'Construction Worker', 3200.00, 580),
('Sarah', 'Williams', '+1-555-1002', '456 Elm Avenue, Unit 12', 'Waitress', 2100.00, 520),
('David', 'Brown', '+1-555-1003', '789 Pine Road, House 7', 'Mechanic', 2800.00, 610),
('Jessica', 'Davis', '+1-555-1004', '321 Maple Drive, Apt 3A', 'Retail Clerk', 1900.00, 480),
('Robert', 'Miller', '+1-555-1005', '654 Cedar Lane, Suite 5', 'Truck Driver', 3500.00, 640);

-- Insert 5 LOANS
INSERT INTO loans (borrower_id, lender_id, principal_amount, interest_rate, loan_term_days, issue_date, due_date, status, total_amount_due) VALUES
(1, 1, 5000.00, 0.2500, 30, '2024-04-01', '2024-05-01', 'ACTIVE', 6250.00),
(2, 2, 2500.00, 0.3000, 21, '2024-04-15', '2024-05-06', 'ACTIVE', 3250.00),
(3, 3, 8000.00, 0.2000, 45, '2024-03-20', '2024-05-04', 'OVERDUE', 9600.00),
(4, 4, 1500.00, 0.3500, 14, '2024-04-20', '2024-05-04', 'PAID', 2025.00),
(5, 5, 10000.00, 0.1800, 60, '2024-03-01', '2024-04-30', 'DEFAULT', 11800.00);

-- Insert 5 PAYMENTS
INSERT INTO payments (loan_id, payment_amount, payment_date, payment_method, remaining_balance, transaction_ref) VALUES
(1, 1000.00, '2024-04-15', 'CASH', 5250.00, 'TXN-001-2024-04-15'),
(2, 500.00, '2024-04-25', 'DIGITAL', 2750.00, 'TXN-002-2024-04-25'),
(3, 2000.00, '2024-04-01', 'BANK_TRANSFER', 7600.00, 'TXN-003-2024-04-01'),
(4, 2025.00, '2024-05-03', 'CASH', 0.00, 'TXN-004-2024-05-03'),
(1, 1500.00, '2024-04-28', 'CASH', 3750.00, 'TXN-005-2024-04-28');

-- Insert 5 COLLATERAL items
INSERT INTO collateral (loan_id, item_description, estimated_value, item_type, storage_location, condition_status) VALUES
(1, '2018 Honda Civic - Silver, 85K miles', 12000.00, 'Vehicle', 'Lot A - Space 15', 'GOOD'),
(2, 'Gold Wedding Ring - 14K, 5.2g', 800.00, 'Jewelry', 'Safe Deposit Box 23', 'EXCELLENT'),
(3, 'Rolex Submariner Watch - Stainless Steel', 15000.00, 'Jewelry', 'Safe Deposit Box 12', 'EXCELLENT'),
(5, '2019 Harley Davidson Sportster', 18000.00, 'Vehicle', 'Lot B - Space 8', 'GOOD'),
(3, 'Samsung 65" QLED TV', 1200.00, 'Electronics', 'Warehouse Section C', 'FAIR');

-- Insert 5 LOAN_OFFICERS
INSERT INTO loan_officers (lender_id, first_name, last_name, phone_number, specialization, hire_date, performance_rating) VALUES
(1, 'Anthony', 'Russo', '+1-555-2001', 'High-Value Loans', '2021-02-01', 4.25),
(2, 'Maria', 'Genovese', '+1-555-2002', 'Risk Assessment', '2020-09-15', 4.50),
(3, 'Frank', 'Luciano', '+1-555-2003', 'Collections', '2019-12-10', 3.75),
(1, 'Isabella', 'Romano', '+1-555-2004', 'New Client Acquisition', '2022-01-20', 4.80),
(5, 'Dante', 'Moretti', '+1-555-2005', 'Collateral Evaluation', '2020-06-30', 4.10);

-- Insert 5 AUDIT_LOGS (sample audit entries)
INSERT INTO audit_logs (table_name, operation_type, record_id, old_values, new_values, changed_by) VALUES
('loans', 'UPDATE', 1, '{"status": "ACTIVE"}', '{"status": "OVERDUE"}', 'system_admin'),
('payments', 'INSERT', 1, NULL, '{"payment_id": 1, "loan_id": 1, "amount": 1000.00}', 'loan_officer'),
('borrowers', 'UPDATE', 2, '{"monthly_income": 2000.00}', '{"monthly_income": 2100.00}', 'data_admin'),
('lenders', 'UPDATE', 4, '{"status": "ACTIVE"}', '{"status": "SUSPENDED"}', 'hr_admin'),
('collateral', 'INSERT', 1, NULL, '{"collateral_id": 1, "loan_id": 1, "value": 12000.00}', 'loan_officer');

-- =====================================================
-- READ OPERATIONS - SELECT QUERIES
-- =====================================================

-- 1. View all territories with their risk levels and lender counts
SELECT 
    t.territory_id,
    t.territory_name,
    t.district,
    t.risk_level,
    t.population,
    t.avg_income,
    COUNT(l.lender_id) AS active_lenders
FROM territories t
LEFT JOIN lenders l ON t.territory_id = l.territory_id AND l.status = 'ACTIVE'
GROUP BY t.territory_id, t.territory_name, t.district, t.risk_level, t.population, t.avg_income
ORDER BY t.risk_level, t.territory_name;

-- 2. View comprehensive loan details with all related information
SELECT 
    lo.loan_id,
    CONCAT(b.first_name, ' ', b.last_name) AS borrower_name,
    CONCAT(len.first_name, ' ', len.last_name) AS lender_name,
    t.territory_name,
    lo.principal_amount,
    lo.interest_rate,
    lo.due_date,
    lo.status,
    lo.total_amount_due,
    COUNT(p.payment_id) AS payment_count,
    COALESCE(SUM(p.payment_amount), 0) AS total_paid,
    COUNT(c.collateral_id) AS collateral_items
FROM loans lo
JOIN borrowers b ON lo.borrower_id = b.borrower_id
JOIN lenders len ON lo.lender_id = len.lender_id
LEFT JOIN territories t ON len.territory_id = t.territory_id
LEFT JOIN payments p ON lo.loan_id = p.loan_id
LEFT JOIN collateral c ON lo.loan_id = c.loan_id
GROUP BY lo.loan_id, b.first_name, b.last_name, len.first_name, len.last_name, 
         t.territory_name, lo.principal_amount, lo.interest_rate, lo.due_date, 
         lo.status, lo.total_amount_due
ORDER BY lo.issue_date DESC;

-- 3. View loan officers performance by lender
SELECT 
    CONCAT(len.first_name, ' ', len.last_name) AS lender_name,
    t.territory_name,
    CONCAT(lo.first_name, ' ', lo.last_name) AS officer_name,
    lo.specialization,
    lo.performance_rating,
    lo.hire_date
FROM loan_officers lo
JOIN lenders len ON lo.lender_id = len.lender_id
LEFT JOIN territories t ON len.territory_id = t.territory_id
ORDER BY lo.performance_rating DESC;

-- 4. View payment history with transaction details
SELECT 
    p.payment_id,
    l.loan_id,
    CONCAT(b.first_name, ' ', b.last_name) AS borrower_name,
    p.payment_amount,
    p.payment_date,
    p.payment_method,
    p.remaining_balance,
    p.transaction_ref
FROM payments p
JOIN loans l ON p.loan_id = l.loan_id
JOIN borrowers b ON l.borrower_id = b.borrower_id
ORDER BY p.payment_date DESC;

-- 5. View collateral inventory with loan details
SELECT 
    c.collateral_id,
    l.loan_id,
    CONCAT(b.first_name, ' ', b.last_name) AS borrower_name,
    c.item_description,
    c.estimated_value,
    c.item_type,
    c.storage_location,
    c.condition_status,
    l.status AS loan_status
FROM collateral c
JOIN loans l ON c.loan_id = l.loan_id
JOIN borrowers b ON l.borrower_id = b.borrower_id
ORDER BY c.estimated_value DESC;

-- 6. Territory risk analysis with financial metrics
SELECT 
    t.territory_name,
    t.risk_level,
    COUNT(DISTINCT len.lender_id) AS lenders_count,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    SUM(l.principal_amount) AS total_principal,
    AVG(l.interest_rate) AS avg_interest_rate,
    COUNT(CASE WHEN l.status = 'DEFAULT' THEN 1 END) AS defaulted_loans,
    ROUND(
        (COUNT(CASE WHEN l.status = 'DEFAULT' THEN 1 END)::DECIMAL / 
         NULLIF(COUNT(l.loan_id), 0)) * 100, 2
    ) AS default_rate_percent
FROM territories t
LEFT JOIN lenders len ON t.territory_id = len.territory_id
LEFT JOIN loans l ON len.lender_id = l.lender_id
GROUP BY t.territory_id, t.territory_name, t.risk_level
ORDER BY default_rate_percent DESC NULLS LAST;

-- 7. Recent audit log activity
SELECT 
    al.log_id,
    al.table_name,
    al.operation_type,
    al.record_id,
    al.changed_by,
    al.change_timestamp,
    al.old_values,
    al.new_values
FROM audit_logs al
ORDER BY al.change_timestamp DESC
LIMIT 10;

-- =====================================================
-- UPDATE OPERATIONS WITH UPSERT (ON CONFLICT)
-- =====================================================

-- 1. Bulk update overdue loan statuses
UPDATE loans 
SET status = 'OVERDUE' 
WHERE due_date < CURRENT_DATE 
AND status = 'ACTIVE';

-- 2. Update lender commission or insert if doesn't exist
INSERT INTO lenders (lender_id, territory_id, first_name, last_name, phone_number, email, commission_rate, hire_date, status)
VALUES 
    (1, 1, 'Vincent', 'Torrino', '+1-555-0101', 'v.torrino@loanshark.com', 0.1600, '2020-01-15', 'ACTIVE'),
    (6, 2, 'Giuseppe', 'Fontana', '+1-555-0106', 'g.fontana@loanshark.com', 0.1250, CURRENT_DATE, 'ACTIVE')
ON CONFLICT (lender_id) 
DO UPDATE SET 
    commission_rate = EXCLUDED.commission_rate,
    status = EXCLUDED.status,
    email = EXCLUDED.email;

-- 2. Update borrower information or insert new borrower
INSERT INTO borrowers (borrower_id, first_name, last_name, phone_number, address, occupation, monthly_income, credit_score)
VALUES 
    (1, 'Michael', 'Johnson', '+1-555-1001', '123 Oak Street, Apartment 4B', 'Construction Foreman', 3800.00, 590),
    (6, 'Lisa', 'Anderson', '+1-555-1006', '987 Birch Street, Unit 8', 'Nurse', 4200.00, 680)
ON CONFLICT (borrower_id)
DO UPDATE SET 
    occupation = EXCLUDED.occupation,
    monthly_income = EXCLUDED.monthly_income,
    credit_score = EXCLUDED.credit_score,
    address = EXCLUDED.address;

-- 3. UPSERT: Insert or update payment with unique transaction reference
INSERT INTO payments (loan_id, payment_amount, payment_date, payment_method, remaining_balance, transaction_ref)
VALUES 
    (1, 2000.00, CURRENT_DATE, 'BANK_TRANSFER', 1750.00, 'TXN-006-2024-05-23'),
    (2, 1000.00, CURRENT_DATE, 'DIGITAL', 1750.00, 'TXN-007-2024-05-23')
ON CONFLICT (transaction_ref)
DO UPDATE SET 
    payment_amount = EXCLUDED.payment_amount,
    remaining_balance = EXCLUDED.remaining_balance,
    payment_date = EXCLUDED.payment_date;

-- 4. UPSERT: Update territory information or create new territory
INSERT INTO territories (territory_id, territory_name, district, risk_level, population, avg_income)
VALUES 
    (1, 'Downtown Core', 'Central District', 'EXTREME', 135000, 47000.00),
    (6, 'Industrial Zone', 'Manufacturing District', 'HIGH', 45000, 35000.00)
ON CONFLICT (territory_id)
DO UPDATE SET 
    risk_level = EXCLUDED.risk_level,
    population = EXCLUDED.population,
    avg_income = EXCLUDED.avg_income;

-- 5. UPSERT: Update loan officer performance or add new officer
INSERT INTO loan_officers (officer_id, lender_id, first_name, last_name, phone_number, specialization, hire_date, performance_rating)
VALUES 
    (1, 1, 'Anthony', 'Russo', '+1-555-2001', 'High-Value Loans', '2021-02-01', 4.50),
    (6, 2, 'Carmen', 'Vitale', '+1-555-2006', 'Debt Recovery', CURRENT_DATE, 4.00)
ON CONFLICT (officer_id)
DO UPDATE SET 
    performance_rating = EXCLUDED.performance_rating,
    specialization = EXCLUDED.specialization,
    lender_id = EXCLUDED.lender_id;

-- 6. UPSERT: Bulk update loan statuses with conditional logic
INSERT INTO loans (loan_id, borrower_id, lender_id, principal_amount, interest_rate, loan_term_days, issue_date, due_date, status, total_amount_due)
SELECT 
    loan_id, borrower_id, lender_id, principal_amount, interest_rate, loan_term_days, 
    issue_date, due_date,
    CASE 
        WHEN due_date < CURRENT_DATE AND status = 'ACTIVE' THEN 'OVERDUE'
        ELSE status 
    END as status,
    total_amount_due
FROM loans
WHERE loan_id IN (1, 2, 3)
ON CONFLICT (loan_id)
DO UPDATE SET 
    status = EXCLUDED.status;

-- 7.  Update collateral conditions with audit trail
WITH collateral_updates AS (
    INSERT INTO collateral (collateral_id, loan_id, item_description, estimated_value, item_type, storage_location, condition_status)
    VALUES 
        (1, 1, '2018 Honda Civic - Silver, 85K miles', 11500.00, 'Vehicle', 'Lot A - Space 15', 'FAIR'),
        (6, 2, 'iPhone 14 Pro Max - 256GB', 900.00, 'Electronics', 'Safe Deposit Box 25', 'GOOD')
    ON CONFLICT (collateral_id)
    DO UPDATE SET 
        estimated_value = EXCLUDED.estimated_value,
        condition_status = EXCLUDED.condition_status,
        storage_location = EXCLUDED.storage_location
    RETURNING collateral_id, 'collateral' as table_name, estimated_value, condition_status
)
INSERT INTO audit_logs (table_name, operation_type, record_id, new_values, changed_by)
SELECT 
    table_name,
    'UPDATE' as operation_type,
    collateral_id,
    jsonb_build_object('estimated_value', estimated_value, 'condition_status', condition_status),
    'upsert_operation'
FROM collateral_updates;


-- =====================================================
-- TRADITIONAL UPDATE OPERATIONS
-- =====================================================

-- 9. Update loan interest rates based on borrower credit scores
UPDATE loans 
SET interest_rate = CASE 
    WHEN b.credit_score >= 650 THEN loans.interest_rate * 0.95  -- 5% reduction
    WHEN b.credit_score >= 600 THEN loans.interest_rate * 0.98  -- 2% reduction  
    WHEN b.credit_score < 500 THEN loans.interest_rate * 1.05   -- 5% increase
    ELSE loans.interest_rate
END,
total_amount_due = principal_amount * (1 + 
    CASE 
        WHEN b.credit_score >= 650 THEN loans.interest_rate * 0.95
        WHEN b.credit_score >= 600 THEN loans.interest_rate * 0.98
        WHEN b.credit_score < 500 THEN loans.interest_rate * 1.05
        ELSE loans.interest_rate
    END
)
FROM borrowers b 
WHERE loans.borrower_id = b.borrower_id 
AND loans.status = 'ACTIVE';


-- =====================================================
-- DELETE OPERATIONS
-- =====================================================

-- 1. Delete old audit logs (older than 6 months)
DELETE FROM audit_logs 
WHERE change_timestamp < CURRENT_DATE - INTERVAL '6 months';

-- 2. Delete inactive loan officers with poor performance
DELETE FROM loan_officers 
WHERE performance_rating < 3.0 
AND hire_date < CURRENT_DATE - INTERVAL '1 year';

-- 3. Remove collateral for fully paid loans
DELETE FROM collateral 
WHERE loan_id IN (
    SELECT loan_id FROM loans WHERE status = 'PAID'
);

-- 4. Delete suspended lenders with no active loans
DELETE FROM lenders 
WHERE status = 'SUSPENDED' 
AND lender_id NOT IN (
    SELECT DISTINCT lender_id FROM loans WHERE status IN ('ACTIVE', 'OVERDUE')
);

-- 5. Clean up duplicate or invalid payment records
DELETE FROM payments p1
WHERE EXISTS (
    SELECT 1 FROM payments p2 
    WHERE p1.loan_id = p2.loan_id 
    AND p1.payment_date = p2.payment_date 
    AND p1.payment_amount = p2.payment_amount 
    AND p1.payment_id > p2.payment_id
);


-- =====================================================
--             THE END
-- =====================================================