
SELECT
    customer_id,
    COUNT(*) AS DuplicateCount
FROM raw.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;



SELECT
    transaction_id,
    COUNT(*) AS DuplicateCount
FROM raw.finance_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC;



SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT transaction_id) AS UniqueTransactionIDs,
    COUNT(*) - COUNT(DISTINCT transaction_id) AS ExtraRows
FROM raw.finance_transactions;


-- Identifying exact duplicate rows and conflicting rows
WITH DuplicateGroups AS (
    SELECT
        transaction_id,
        transaction_date,
        account_id,
        customer_id,
        transaction_type,
        channel,
        merchant_category,
        amount,
        fee_amount,
        tax_amount,
        currency,
        transaction_status,
        is_fraud,
        risk_score,
        reference_no,
        COUNT(*) AS RecordCount
    FROM raw.finance_transactions
    GROUP BY
        transaction_id,
        transaction_date,
        account_id,
        customer_id,
        transaction_type,
        channel,
        merchant_category,
        amount,
        fee_amount,
        tax_amount,
        currency,
        transaction_status,
        is_fraud,
        risk_score,
        reference_no
    HAVING COUNT(*) > 1
)
SELECT
    COUNT(*) AS ExactDuplicateGroups,
    COALESCE(SUM(RecordCount - 1), 0) AS ExtraExactDuplicateRows
FROM DuplicateGroups;



--Identifying conflicting rows
WITH DistinctRecords AS (
    SELECT DISTINCT *
    FROM raw.finance_transactions
),
ConflictingIDs AS (
    SELECT
        transaction_id
    FROM DistinctRecords
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
)
SELECT
    t.*
FROM raw.finance_transactions AS t
INNER JOIN ConflictingIDs AS c
    ON t.transaction_id = c.transaction_id
ORDER BY t.transaction_id;





-- Creating a view of the validated transaction ID


USE FinanceAnalyticsDB;


-- Create the validated schema
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'validated'
)
BEGIN
    EXEC('CREATE SCHEMA validated');
END;

GO

-- Create a view with one record per transaction ID
CREATE OR ALTER VIEW validated.finance_transactions AS
WITH RankedTransactions AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id
            ORDER BY
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(fee_amount)), '') IS NOT NULL
                    THEN 0
                    ELSE 1
                END
        ) AS row_num
    FROM raw.finance_transactions
)
SELECT
    transaction_id,
    transaction_date,
    account_id,
    customer_id,
    transaction_type,
    channel,
    merchant_category,
    amount,
    fee_amount,
    tax_amount,
    currency,
    transaction_status,
    is_fraud,
    risk_score,
    reference_no
FROM RankedTransactions
WHERE row_num = 1;
GO

-- Compare raw and validated records
SELECT
    'Raw' AS Dataset,
    COUNT(*) AS TotalRecords
FROM raw.finance_transactions

UNION ALL

SELECT
    'Validated',
    COUNT(*)
FROM validated.finance_transactions;



SELECT
    transaction_id,
    fee_amount
FROM validated.finance_transactions
WHERE transaction_id = 'T00000009';