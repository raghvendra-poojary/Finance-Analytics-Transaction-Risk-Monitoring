
USE FinanceAnalyticsDB;


SELECT
    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN NULLIF(TRIM(transaction_id), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingTransactionID,

    SUM(CASE
        WHEN NULLIF(TRIM(customer_id), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingCustomerID,

    SUM(CASE
        WHEN NULLIF(TRIM(transaction_date), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingTransactionDate,

    SUM(CASE
        WHEN NULLIF(TRIM(amount), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingAmount,

    SUM(CASE
        WHEN NULLIF(TRIM(fee_amount), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingFee,

    SUM(CASE
        WHEN NULLIF(TRIM(tax_amount), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingTax,

    SUM(CASE
        WHEN NULLIF(TRIM(transaction_status), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingStatus,

    SUM(CASE
        WHEN NULLIF(TRIM(is_fraud), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingFraudFlag,

    SUM(CASE
        WHEN NULLIF(TRIM(risk_score), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingRiskScore

FROM validated.finance_transactions;






-- Checking duplicates in customers
SELECT
    COUNT(*) AS TotalCustomers,

    SUM(CASE
        WHEN NULLIF(TRIM(customer_id), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingCustomerID,

    SUM(CASE
        WHEN NULLIF(TRIM(fisrt_name), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingFirstName,

    SUM(CASE
        WHEN NULLIF(TRIM(gender), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingGender,

    SUM(CASE
        WHEN NULLIF(TRIM(date_of_birth), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingDOB,

    SUM(CASE
        WHEN NULLIF(TRIM(state), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingState,

    SUM(CASE
        WHEN NULLIF(TRIM(occupation), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingOccupation,

    SUM(CASE
        WHEN NULLIF(TRIM(customer_segment), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingSegment,

    SUM(CASE
        WHEN NULLIF(TRIM(annual_income), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingAnnualIncome

FROM raw.customers;


-- Missing Fee
SELECT
    transaction_id,
    transaction_date,
    transaction_type,
    amount,
    fee_amount,
    transaction_status
FROM validated.finance_transactions
WHERE NULLIF(TRIM(fee_amount), '') IS NULL;



-- checking if missing fee amount is due to failed transaction status or anything other also
SELECT
    transaction_type,
    transaction_status,
    COUNT(*) AS MissingFeeCount
FROM validated.finance_transactions
WHERE NULLIF(TRIM(fee_amount), '') IS NULL
GROUP BY
    transaction_type,
    transaction_status
ORDER BY MissingFeeCount DESC;





USE FinanceAnalyticsDB;

SELECT
    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN NULLIF(TRIM(amount), '') IS NOT NULL
         AND TRY_CONVERT(DECIMAL(18,2), amount) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidAmount,

    SUM(CASE
        WHEN NULLIF(TRIM(fee_amount), '') IS NOT NULL
         AND TRY_CONVERT(DECIMAL(18,2), fee_amount) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidFee,

    SUM(CASE
        WHEN NULLIF(TRIM(tax_amount), '') IS NOT NULL
         AND TRY_CONVERT(DECIMAL(18,2), tax_amount) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidTax,

    SUM(CASE
        WHEN NULLIF(TRIM(risk_score), '') IS NOT NULL
         AND TRY_CONVERT(INT, risk_score) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidRiskScore,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(18,2), amount) < 0
        THEN 1 ELSE 0
    END) AS NegativeAmount,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(18,2), fee_amount) < 0
        THEN 1 ELSE 0
    END) AS NegativeFee,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(18,2), tax_amount) < 0
        THEN 1 ELSE 0
    END) AS NegativeTax

FROM validated.finance_transactions;



--Investigating negative amount

USE FinanceAnalyticsDB;

SELECT
    transaction_id,
    transaction_date,
    transaction_type,
    channel,
    merchant_category,
    amount,
    fee_amount,
    tax_amount,
    transaction_status,
    is_fraud,
    risk_score
FROM validated.finance_transactions
WHERE TRY_CONVERT(DECIMAL(18,2), amount) < 0
ORDER BY TRY_CONVERT(DECIMAL(18,2), amount);



--Validate Transaction dates

USE FinanceAnalyticsDB;

SELECT
    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN NULLIF(TRIM(transaction_date), '') IS NULL
        THEN 1 ELSE 0
    END) AS MissingDates,

    SUM(CASE
        WHEN NULLIF(TRIM(transaction_date), '') IS NOT NULL
         AND TRY_CONVERT(DATE, TRIM(transaction_date), 105) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidDates,

    MIN(TRY_CONVERT(DATE, TRIM(transaction_date), 105))
        AS EarliestTransactionDate,

    MAX(TRY_CONVERT(DATE, TRIM(transaction_date), 105))
        AS LatestTransactionDate

FROM validated.finance_transactions;




-- Checking inconsistency in categorical columns

SELECT
    currency,
    COUNT(*) AS TransactionCount
FROM validated.finance_transactions
GROUP BY currency
ORDER BY TransactionCount DESC;



SELECT
    channel,
    COUNT(*) AS TransactionCount
FROM validated.finance_transactions
GROUP BY channel
ORDER BY TransactionCount DESC;



SELECT
    transaction_status,
    COUNT(*) AS TransactionCount
FROM validated.finance_transactions
GROUP BY transaction_status
ORDER BY TransactionCount DESC;



SELECT
    transaction_type,
    COUNT(*) AS TransactionCount
FROM validated.finance_transactions
GROUP BY transaction_type
ORDER BY TransactionCount DESC;





-- Identify exact channel and currency variations

USE FinanceAnalyticsDB;

-- Check exact channel values
WITH ChannelData AS (
    SELECT
        channel COLLATE Latin1_General_100_BIN2 AS ExactChannel,
        DATALENGTH(channel) AS StorageBytes
    FROM validated.finance_transactions
)
SELECT
    CONCAT('[', ExactChannel, ']') AS OriginalChannel,
    StorageBytes,
    COUNT(*) AS TransactionCount
FROM ChannelData
GROUP BY ExactChannel, StorageBytes
ORDER BY TransactionCount DESC;


-- Check exact currency values
WITH CurrencyData AS (
    SELECT
        currency COLLATE Latin1_General_100_BIN2 AS ExactCurrency
    FROM validated.finance_transactions
)
SELECT
    CONCAT('[', ExactCurrency, ']') AS OriginalCurrency,
    COUNT(*) AS TransactionCount
FROM CurrencyData
GROUP BY ExactCurrency
ORDER BY TransactionCount DESC;





USE FinanceAnalyticsDB;
GO

CREATE OR ALTER VIEW validated.clean_transactions AS
SELECT
    transaction_id,

    TRY_CONVERT(DATE, TRIM(transaction_date), 105)
        AS transaction_date,

    account_id,
    customer_id,

    TRIM(transaction_type) AS transaction_type,

    CASE
        WHEN UPPER(TRIM(channel)) = 'M@BILE APP'
            THEN 'Mobile App'
        ELSE TRIM(channel)
    END AS channel,

    TRIM(merchant_category) AS merchant_category,

    TRY_CONVERT(DECIMAL(18,2), amount) AS amount,

    TRY_CONVERT(
        DECIMAL(18,2),
        NULLIF(TRIM(fee_amount), '')
    ) AS fee_amount,

    TRY_CONVERT(DECIMAL(18,2), tax_amount)
        AS tax_amount,

    UPPER(TRIM(currency)) AS currency,

    TRIM(transaction_status) AS transaction_status,

    TRIM(is_fraud) AS is_fraud,

    TRY_CONVERT(INT, risk_score) AS risk_score,

    reference_no,

    CASE
        WHEN TRY_CONVERT(DECIMAL(18,2), amount) < 0
            THEN 'Review Required'
        ELSE 'Normal'
    END AS amount_quality_flag,

    CASE
        WHEN NULLIF(TRIM(fee_amount), '') IS NULL
            THEN 'Missing Fee'
        ELSE 'Available'
    END AS fee_quality_flag

FROM validated.finance_transactions;
GO


SELECT
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ViewName
FROM sys.views
WHERE name = 'clean_transactions';



-- Verify transaction count
SELECT COUNT(*) AS TotalTransactions
FROM validated.clean_transactions;

-- Verify standardized channels
SELECT
    channel,
    COUNT(*) AS TransactionCount
FROM validated.clean_transactions
GROUP BY channel
ORDER BY TransactionCount DESC;

-- Verify quality flags
SELECT
    SUM(CASE WHEN currency = 'INR' THEN 1 ELSE 0 END)
        AS INRTransactions,

    SUM(CASE WHEN amount_quality_flag = 'Review Required'
        THEN 1 ELSE 0 END) AS NegativeAmountFlags,

    SUM(CASE WHEN fee_quality_flag = 'Missing Fee'
        THEN 1 ELSE 0 END) AS MissingFeeFlags
FROM validated.clean_transactions;
