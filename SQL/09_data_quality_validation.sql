
USE FinanceAnalyticsDB;
GO

-- ================================================
-- DATA QUALITY VALIDATION
-- Finance Analytics & Transaction Risk Monitoring
-- ================================================

-- 1. Transaction record counts
SELECT
    (SELECT COUNT(*)
     FROM raw.finance_transactions) AS RawTransactions,

    (SELECT COUNT(*)
     FROM validated.finance_transactions) AS DeduplicatedTransactions,

    (SELECT COUNT(*)
     FROM validated.clean_transactions) AS CleanTransactions;


-- 2. Customer uniqueness
SELECT
    COUNT(*) AS TotalCustomers,
    COUNT(DISTINCT customer_id) AS UniqueCustomerIDs,
    COUNT(*) - COUNT(DISTINCT customer_id)
        AS DuplicateCustomerIDs
FROM validated.clean_customers;


-- 3. Transaction referential integrity
SELECT
    COUNT(*) AS TotalTransactions,
    SUM(
        CASE
            WHEN c.customer_id IS NULL THEN 1
            ELSE 0
        END
    ) AS TransactionsWithoutCustomer
FROM validated.clean_transactions AS t
LEFT JOIN validated.clean_customers AS c
    ON t.customer_id = c.customer_id;


-- 4. Transaction ID uniqueness
SELECT
    COUNT(*) AS TotalTransactions,
    COUNT(DISTINCT transaction_id) AS UniqueTransactionIDs,
    COUNT(*) - COUNT(DISTINCT transaction_id)
        AS DuplicateTransactionIDs
FROM validated.clean_transactions;
