-- BANK LOAN ANALYSIS - End to End SQL Project
-- Tables: Customers, Loans, Payments

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    join_date DATE
);

CREATE TABLE Loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_amount DECIMAL(12,2),
    loan_status VARCHAR(20),
    loan_purpose VARCHAR(50),
    loan_date DATE,
    interest_rate DECIMAL(4,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    amount_paid DECIMAL(12,2),
    status VARCHAR(20),
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id)
);

-- 1. Total Loans, Amount, Avg Interest
SELECT COUNT(*) AS total_loans,
SUM(loan_amount) AS total_amount,
AVG(interest_rate) AS avg_interest
FROM Loans;

-- 2. Loans by Status
SELECT loan_status, COUNT(*) AS count_loans, SUM(loan_amount) AS total_amount
FROM Loans GROUP BY loan_status;

-- 3. Default Rate by Purpose
SELECT loan_purpose,
COUNT(*) AS total_loans,
SUM(CASE WHEN loan_status='Default' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS default_rate
FROM Loans GROUP BY loan_purpose ORDER BY default_rate DESC;

-- 4. Top 5 Defaulters
SELECT c.customer_id, c.name, l.loan_id,
SUM(p.amount_paid) AS total_due,
DATEDIFF(CURRENT_DATE, MAX(p.payment_date)) AS days_overdue
FROM Customers c
JOIN Loans l ON c.customer_id = l.customer_id
JOIN Payments p ON l.loan_id = p.loan_id
WHERE l.loan_status = 'Default'
GROUP BY c.customer_id, c.name, l.loan_id
ORDER BY days_overdue DESC LIMIT 5;

-- 5. Monthly Disbursement
SELECT YEAR(loan_date) AS year, MONTH(loan_date) AS month,
SUM(loan_amount) AS monthly_amount
FROM Loans GROUP BY YEAR(loan_date), MONTH(loan_date) ORDER BY year, month;

-- 6. Customers With No Payment
SELECT c.* FROM Customers c
LEFT JOIN Loans l ON c.customer_id = l.customer_id
LEFT JOIN Payments p ON l.loan_id = p.loan_id
WHERE p.payment_id IS NULL;

-- 7. Running Total
SELECT loan_date, loan_amount,
SUM(loan_amount) OVER (ORDER BY loan_date) AS running_total
FROM Loans;

-- 8. Rank Customers by Loan Amount
SELECT customer_id, loan_purpose, loan_amount,
RANK() OVER (PARTITION BY loan_purpose ORDER BY loan_amount DESC) AS rank_in_purpose
FROM Loans;

-- 9. High Risk View
CREATE VIEW Risky_Loans AS
SELECT * FROM Loans WHERE interest_rate > 12 AND loan_status = 'Default';
