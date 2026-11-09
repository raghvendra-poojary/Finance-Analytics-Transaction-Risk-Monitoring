
-- SQL KPI RECONCILIATION
-- Step 1: Baseline transaction metrics
USE FinanceAnalyticsDB;

SELECT
    COUNT(*) AS TotalTransactions,

    COUNT(DISTINCT customer_id) AS ActiveCustomers,

    CAST(
        SUM(ABS(amount))
        AS DECIMAL(18,2)
    ) AS TotalTransactionAmount,

    CAST(
        AVG(ABS(amount))
        AS DECIMAL(18,2)
    ) AS AverageTransactionAmount,

    CAST(
        SUM(fee_amount)
        AS DECIMAL(18,2)
    ) AS RecordedFees,

    CAST(
        SUM(tax_amount)
        AS DECIMAL(18,2)
    ) AS TotalTax,

    SUM(CASE
        WHEN fee_amount IS NULL THEN 1
        ELSE 0
    END) AS MissingFees

FROM validated.clean_transactions;





-- Compare SQL with Power BI for 2023

WITH MeanFee AS (
    SELECT AVG(fee_amount) AS AverageFee
    FROM validated.clean_transactions
    WHERE fee_amount IS NOT NULL
)

SELECT
    COUNT(*) AS TotalTransactions,

    CAST(
        SUM(ABS(t.amount))
        AS DECIMAL(18,2)
    ) AS TotalAmount,

    CAST(
        AVG(ABS(t.amount))
        AS DECIMAL(18,2)
    ) AS AverageTransactionValue,

    CAST(
        SUM(COALESCE(t.fee_amount, m.AverageFee))
        AS DECIMAL(18,2)
    ) AS TotalAdjustedFees,

    CAST(
        SUM(t.tax_amount)
        AS DECIMAL(18,2)
    ) AS TotalTax

FROM validated.clean_transactions AS t
CROSS JOIN MeanFee AS m

WHERE t.transaction_date >= '2023-01-01'
  AND t.transaction_date < '2024-01-01';







SELECT
    COUNT(*) AS TotalTransactions,

    CAST(SUM(ABS(amount)) AS DECIMAL(18,2))
        AS TotalAmount,

    CAST(AVG(ABS(amount)) AS DECIMAL(18,2))
        AS AverageTransactionValue,

    CAST(
        SUM(COALESCE(fee_amount, 14.52))
        AS DECIMAL(18,2)
    ) AS TotalAdjustedFees,

    CAST(SUM(tax_amount) AS DECIMAL(18,2))
        AS TotalTax

FROM validated.clean_transactions

WHERE transaction_date >= '2024-01-01'
  AND transaction_date < '2025-01-01';



  
--  Validate the Transactions dashboard detail table
-- Year selected in Power BI: 2024

SELECT
    COUNT(*) AS TotalJoinedTransactions,
    COUNT(DISTINCT t.transaction_id) AS UniqueTransactionIDs,
    COUNT(DISTINCT t.customer_id) AS ActiveCustomers,

    SUM(ABS(t.amount)) AS TotalTransactionAmount,

    SUM(COALESCE(t.fee_amount, 14.52)) AS TotalAdjustedFees,

    SUM(t.tax_amount) AS TotalTax

FROM validated.clean_transactions AS t

LEFT JOIN validated.clean_customers AS c
    ON t.customer_id = c.customer_id

WHERE t.transaction_date >= '2024-01-01'
  AND t.transaction_date < '2025-01-01';





-------------------------------------------------------------------------------------------------------


-- Compare recorded and adjusted fees for 2024

SELECT
    COUNT(*) AS TotalTransactions,

    COUNT(fee_amount) AS TransactionsWithRecordedFees,

    SUM(CASE WHEN fee_amount IS NULL THEN 1 ELSE 0 END)
        AS MissingFeeTransactions,

    CAST(SUM(fee_amount) AS DECIMAL(18,2))
        AS RecordedFeeTotal,

    CAST(
        SUM(COALESCE(fee_amount, 14.52))
        AS DECIMAL(18,2)
    ) AS AdjustedFeeTotal

FROM validated.clean_transactions

WHERE transaction_date >= '2024-01-01'
  AND transaction_date < '2025-01-01';





-- Investigate the conflicting duplicate transaction

SELECT
    'Raw Data' AS DataSource,
    transaction_id,
    transaction_date,
    fee_amount
FROM raw.finance_transactions
WHERE transaction_id = 'T00000009'

UNION ALL

SELECT
    'Validated Data' AS DataSource,
    transaction_id,
    transaction_date,
    fee_amount
FROM validated.finance_transactions
WHERE transaction_id = 'T00000009';
