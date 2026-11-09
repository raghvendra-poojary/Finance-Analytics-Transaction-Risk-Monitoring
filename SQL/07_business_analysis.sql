--Create the analytics schema
USE FinanceAnalyticsDB;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'analytics'
)
BEGIN
    EXEC('CREATE SCHEMA analytics');
END;
GO



-- =====================================================
-- BUSINESS QUESTION 1: OVERALL TRANSACTION PERFORMANCE
-- =====================================================

SELECT
    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN transaction_status = 'Success'
        THEN 1 ELSE 0
    END) AS SuccessfulTransactions,

    SUM(CASE
        WHEN transaction_status = 'Failed'
        THEN 1 ELSE 0
    END) AS FailedTransactions,

    SUM(CASE
        WHEN transaction_status = 'Pending'
        THEN 1 ELSE 0
    END) AS PendingTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN transaction_status = 'Success'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS SuccessRatePercentage,

    CAST(
        SUM(CASE
            WHEN transaction_status = 'Success'
            THEN ABS(amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS SuccessfulTransactionValue

FROM validated.clean_transactions;




-- =====================================================
-- BUSINESS QUESTION 2: CHANNEL PERFORMANCE
-- =====================================================

SELECT
    channel AS TransactionChannel,

    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN transaction_status = 'Success'
        THEN 1 ELSE 0
    END) AS SuccessfulTransactions,

    SUM(CASE
        WHEN transaction_status = 'Failed'
        THEN 1 ELSE 0
    END) AS FailedTransactions,

    SUM(CASE
        WHEN transaction_status = 'Pending'
        THEN 1 ELSE 0
    END) AS PendingTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN transaction_status = 'Success'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS SuccessRatePercentage,

    CAST(
        SUM(CASE
            WHEN transaction_status = 'Success'
            THEN ABS(amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS SuccessfulTransactionValue

FROM validated.clean_transactions

GROUP BY channel

ORDER BY SuccessRatePercentage DESC;




-- =====================================================
-- BUSINESS QUESTION 3: MONTHLY TRANSACTION TRENDS
-- =====================================================

SELECT
    YEAR(transaction_date) AS TransactionYear,
    MONTH(transaction_date) AS TransactionMonth,

    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN transaction_status = 'Success'
        THEN 1 ELSE 0
    END) AS SuccessfulTransactions,

    SUM(CASE
        WHEN transaction_status = 'Failed'
        THEN 1 ELSE 0
    END) AS FailedTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN transaction_status = 'Success'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS SuccessRatePercentage,

    SUM(CASE
        WHEN transaction_status = 'Success'
        THEN ABS(amount)
        ELSE 0
    END) AS SuccessfulTransactionValue

FROM validated.clean_transactions

GROUP BY
    YEAR(transaction_date),
    MONTH(transaction_date)

ORDER BY
    TransactionYear,
    TransactionMonth;




-- =====================================================
-- BUSINESS QUESTION 3A: MONTH-OVER-MONTH GROWTH
-- =====================================================

WITH MonthlyData AS (
    SELECT
        DATEFROMPARTS(
            YEAR(transaction_date),
            MONTH(transaction_date),
            1
        ) AS TransactionMonth,

        COUNT(*) AS TotalTransactions,

        SUM(CASE
            WHEN transaction_status = 'Success'
            THEN ABS(amount)
            ELSE 0
        END) AS SuccessfulTransactionValue

    FROM validated.clean_transactions

    GROUP BY
        YEAR(transaction_date),
        MONTH(transaction_date)
),

MonthlyComparison AS (
    SELECT
        TransactionMonth,
        TotalTransactions,
        SuccessfulTransactionValue,

        LAG(TotalTransactions) OVER (
            ORDER BY TransactionMonth
        ) AS PreviousMonthTransactions,

        LAG(SuccessfulTransactionValue) OVER (
            ORDER BY TransactionMonth
        ) AS PreviousMonthValue

    FROM MonthlyData
)

SELECT
    TransactionMonth,
    TotalTransactions,

    CAST(
        100.0 *
        (TotalTransactions - PreviousMonthTransactions)
        / NULLIF(PreviousMonthTransactions, 0)
        AS DECIMAL(10,2)
    ) AS TransactionCountMoMPercentage,

    SuccessfulTransactionValue,

    CAST(
        100.0 *
        (SuccessfulTransactionValue - PreviousMonthValue)
        / NULLIF(PreviousMonthValue, 0)
        AS DECIMAL(10,2)
    ) AS TransactionValueMoMPercentage

FROM MonthlyComparison

ORDER BY TransactionMonth;





-- =====================================================
-- BUSINESS QUESTION 4: TRANSACTION TYPE PERFORMANCE
-- =====================================================

SELECT
    transaction_type AS TransactionType,

    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN transaction_status = 'Success'
        THEN 1 ELSE 0
    END) AS SuccessfulTransactions,

    SUM(CASE
        WHEN transaction_status = 'Failed'
        THEN 1 ELSE 0
    END) AS FailedTransactions,

    SUM(CASE
        WHEN transaction_status = 'Pending'
        THEN 1 ELSE 0
    END) AS PendingTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN transaction_status = 'Success'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS SuccessRatePercentage,

    CAST(
        SUM(CASE
            WHEN transaction_status = 'Success'
            THEN ABS(amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS SuccessfulTransactionValue

FROM validated.clean_transactions

GROUP BY transaction_type

ORDER BY TotalTransactions DESC;




-- =====================================================
-- BUSINESS QUESTION 5: CUSTOMER SEGMENT PERFORMANCE
-- =====================================================

SELECT
    c.customer_segment AS CustomerSegment,

    COUNT(DISTINCT c.customer_id) AS ActiveCustomers,

    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN t.transaction_status = 'Success'
        THEN 1 ELSE 0
    END) AS SuccessfulTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN t.transaction_status = 'Success'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS SuccessRatePercentage,

    CAST(
        SUM(CASE
            WHEN t.transaction_status = 'Success'
            THEN ABS(t.amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS SuccessfulTransactionValue

FROM validated.clean_transactions AS t

INNER JOIN validated.clean_customers AS c
    ON t.customer_id = c.customer_id

GROUP BY
    c.customer_segment

ORDER BY
    SuccessfulTransactionValue DESC;




-- =====================================================
-- BUSINESS QUESTION 5A: CUSTOMER ACTIVITY BY SEGMENT
-- =====================================================

SELECT
    c.customer_segment AS CustomerSegment,

    COUNT(DISTINCT c.customer_id) AS ActiveCustomers,

    COUNT(*) AS TotalTransactions,

    CAST(
        1.0 * COUNT(*) /
        NULLIF(COUNT(DISTINCT c.customer_id), 0)
        AS DECIMAL(10,2)
    ) AS TransactionsPerActiveCustomer,

    CAST(
        1.0 * SUM(CASE
            WHEN t.transaction_status = 'Success'
            THEN ABS(t.amount)
            ELSE 0
        END) /
        NULLIF(COUNT(DISTINCT c.customer_id), 0)
        AS DECIMAL(18,2)
    ) AS SuccessfulValuePerActiveCustomer,

    CAST(
        1.0 * SUM(CASE
            WHEN t.transaction_status = 'Success'
            THEN ABS(t.amount)
            ELSE 0
        END) /
        NULLIF(
            SUM(CASE
                WHEN t.transaction_status = 'Success'
                THEN 1 ELSE 0
            END), 0
        )
        AS DECIMAL(18,2)
    ) AS AverageSuccessfulTransactionValue

FROM validated.clean_transactions AS t

INNER JOIN validated.clean_customers AS c
    ON t.customer_id = c.customer_id

GROUP BY
    c.customer_segment

ORDER BY
    TransactionsPerActiveCustomer DESC;






-- =====================================================
-- BUSINESS QUESTION 6: OVERALL FRAUD EXPOSURE
-- =====================================================

SELECT
    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN UPPER(TRIM(is_fraud)) = 'YES'
        THEN 1 ELSE 0
    END) AS FraudFlaggedTransactions,

    SUM(CASE
        WHEN UPPER(TRIM(is_fraud)) = 'NO'
        THEN 1 ELSE 0
    END) AS NonFraudTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN UPPER(TRIM(is_fraud)) = 'YES'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS FraudFlagRatePercentage,

    CAST(
        SUM(CASE
            WHEN UPPER(TRIM(is_fraud)) = 'YES'
            THEN ABS(amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS FraudFlaggedTransactionValue,

    CAST(
        AVG(CASE
            WHEN UPPER(TRIM(is_fraud)) = 'YES'
            THEN CAST(risk_score AS DECIMAL(10,2))
        END)
        AS DECIMAL(10,2)
    ) AS AverageFraudRiskScore

FROM validated.clean_transactions;



-- =====================================================
-- BUSINESS QUESTION 6A: FRAUD BY RISK SCORE BAND
-- =====================================================

WITH RiskBands AS (
    SELECT
        CASE
            WHEN risk_score BETWEEN 0 AND 20
                THEN '0-20'
            WHEN risk_score BETWEEN 21 AND 40
                THEN '21-40'
            WHEN risk_score BETWEEN 41 AND 60
                THEN '41-60'
            WHEN risk_score BETWEEN 61 AND 80
                THEN '61-80'
            WHEN risk_score BETWEEN 81 AND 100
                THEN '81-100'
            ELSE 'Outside Range / Missing'
        END AS RiskBand,

        CASE
            WHEN risk_score BETWEEN 0 AND 20 THEN 1
            WHEN risk_score BETWEEN 21 AND 40 THEN 2
            WHEN risk_score BETWEEN 41 AND 60 THEN 3
            WHEN risk_score BETWEEN 61 AND 80 THEN 4
            WHEN risk_score BETWEEN 81 AND 100 THEN 5
            ELSE 6
        END AS BandOrder,

        is_fraud,
        amount

    FROM validated.clean_transactions
)

SELECT
    RiskBand,

    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN UPPER(TRIM(is_fraud)) = 'YES'
        THEN 1 ELSE 0
    END) AS FraudFlaggedTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN UPPER(TRIM(is_fraud)) = 'YES'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS FraudFlagRatePercentage,

    CAST(
        SUM(CASE
            WHEN UPPER(TRIM(is_fraud)) = 'YES'
            THEN ABS(amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS FraudFlaggedTransactionValue

FROM RiskBands

GROUP BY
    RiskBand,
    BandOrder

ORDER BY BandOrder;






-- =====================================================
-- BUSINESS QUESTION 6B:
-- INVESTIGATE FRAUD FLAGS AND RISK SCORE BOUNDARIES
-- =====================================================

SELECT
    UPPER(TRIM(is_fraud)) AS FraudFlag,

    COUNT(*) AS TotalTransactions,

    MIN(risk_score) AS MinimumRiskScore,

    MAX(risk_score) AS MaximumRiskScore,

    CAST(
        AVG(CAST(risk_score AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageRiskScore

FROM validated.clean_transactions

GROUP BY UPPER(TRIM(is_fraud))

ORDER BY MinimumRiskScore;




-- =====================================================
-- BUSINESS QUESTION 6C:
-- RISK THRESHOLD PERFORMANCE ANALYSIS
-- =====================================================

WITH Thresholds AS (
    SELECT 60 AS RiskThreshold
    UNION ALL SELECT 65
    UNION ALL SELECT 70
    UNION ALL SELECT 75
    UNION ALL SELECT 80
    UNION ALL SELECT 85
),

ThresholdAnalysis AS (
    SELECT
        th.RiskThreshold,

        SUM(CASE
            WHEN t.risk_score >= th.RiskThreshold
            THEN 1 ELSE 0
        END) AS TransactionsSelectedForReview,

        SUM(CASE
            WHEN t.risk_score >= th.RiskThreshold
             AND UPPER(TRIM(t.is_fraud)) = 'YES'
            THEN 1 ELSE 0
        END) AS FraudFlagsCaptured,

        SUM(CASE
            WHEN t.risk_score >= th.RiskThreshold
             AND UPPER(TRIM(t.is_fraud)) = 'NO'
            THEN 1 ELSE 0
        END) AS NonFraudFlagsSelected

    FROM Thresholds AS th
    CROSS JOIN validated.clean_transactions AS t

    GROUP BY th.RiskThreshold
)

SELECT
    RiskThreshold,
    TransactionsSelectedForReview,
    FraudFlagsCaptured,
    NonFraudFlagsSelected,

    CAST(
        100.0 * FraudFlagsCaptured / 630
        AS DECIMAL(10,2)
    ) AS FraudFlagCapturePercentage,

    CAST(
        100.0 * TransactionsSelectedForReview / 50000
        AS DECIMAL(10,2)
    ) AS ReviewWorkloadPercentage

FROM ThresholdAnalysis

ORDER BY RiskThreshold;





-- =====================================================
-- BUSINESS QUESTION 6D:
-- FRAUD EXPOSURE BY TRANSACTION CHANNEL
-- =====================================================

SELECT
    channel AS TransactionChannel,

    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN UPPER(TRIM(is_fraud)) = 'YES'
        THEN 1 ELSE 0
    END) AS FraudFlaggedTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN UPPER(TRIM(is_fraud)) = 'YES'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS FraudFlagRatePercentage,

    CAST(
        SUM(CASE
            WHEN UPPER(TRIM(is_fraud)) = 'YES'
            THEN ABS(amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS FraudFlaggedTransactionValue,

    CAST(
        AVG(CASE
            WHEN UPPER(TRIM(is_fraud)) = 'YES'
            THEN CAST(risk_score AS DECIMAL(10,2))
        END)
        AS DECIMAL(10,2)
    ) AS AverageFlaggedRiskScore

FROM validated.clean_transactions

GROUP BY channel

ORDER BY FraudFlagRatePercentage DESC;




-- =====================================================
-- BUSINESS QUESTION 6E:
-- FRAUD EXPOSURE BY CUSTOMER SEGMENT
-- =====================================================

SELECT
    c.customer_segment AS CustomerSegment,

    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN UPPER(TRIM(t.is_fraud)) = 'YES'
        THEN 1 ELSE 0
    END) AS FraudFlaggedTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN UPPER(TRIM(t.is_fraud)) = 'YES'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS FraudFlagRatePercentage,

    CAST(
        SUM(CASE
            WHEN UPPER(TRIM(t.is_fraud)) = 'YES'
            THEN ABS(t.amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS FraudFlaggedTransactionValue,

    CAST(
        AVG(CASE
            WHEN UPPER(TRIM(t.is_fraud)) = 'YES'
            THEN CAST(t.risk_score AS DECIMAL(10,2))
        END)
        AS DECIMAL(10,2)
    ) AS AverageFlaggedRiskScore

FROM validated.clean_transactions AS t

INNER JOIN validated.clean_customers AS c
    ON t.customer_id = c.customer_id

GROUP BY
    c.customer_segment

ORDER BY FraudFlagRatePercentage DESC;



-- =====================================================
-- BUSINESS QUESTION 6F:
-- FRAUD-FLAGGED TRANSACTIONS BY PROCESSING STATUS
-- =====================================================

SELECT
    transaction_status AS TransactionStatus,

    COUNT(*) AS FraudFlaggedTransactions,

    CAST(
        100.0 * COUNT(*) /
        NULLIF(
            (SELECT COUNT(*)
             FROM validated.clean_transactions
             WHERE UPPER(TRIM(is_fraud)) = 'YES'),
            0
        )
        AS DECIMAL(10,2)
    ) AS ShareOfFraudFlagsPercentage,

    CAST(
        SUM(ABS(amount))
        AS DECIMAL(18,2)
    ) AS FraudFlaggedTransactionValue,

    CAST(
        AVG(CAST(risk_score AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageRiskScore

FROM validated.clean_transactions

WHERE UPPER(TRIM(is_fraud)) = 'YES'

GROUP BY transaction_status

ORDER BY FraudFlaggedTransactionValue DESC;




-- =====================================================
-- BUSINESS QUESTION 6G:
-- PRIORITY REVIEW OF SUCCESSFUL FRAUD-FLAGGED TRANSACTIONS
-- =====================================================

SELECT TOP 20
    transaction_id,
    transaction_date,
    customer_id,
    transaction_type,
    channel,

    ABS(amount) AS TransactionAmount,

    risk_score,

    transaction_status,
    is_fraud,

    CASE
        WHEN risk_score >= 85 THEN 'Critical'
        WHEN risk_score >= 75 THEN 'High'
        ELSE 'Review'
    END AS ReviewPriority

FROM validated.clean_transactions

WHERE UPPER(TRIM(is_fraud)) = 'YES'
  AND transaction_status = 'Success'

ORDER BY
    ABS(amount) DESC,
    risk_score DESC,
    transaction_id;






-- =====================================================
-- BUSINESS QUESTION 6H:
-- AMOUNT AND RISK-BASED INVESTIGATION PRIORITY
-- =====================================================

WITH FlaggedTransactions AS (
    SELECT
        transaction_id,
        transaction_date,
        customer_id,
        transaction_type,
        channel,
        ABS(amount) AS TransactionAmount,
        risk_score,
        transaction_status,
        is_fraud

    FROM validated.clean_transactions

    WHERE UPPER(TRIM(is_fraud)) = 'YES'
      AND transaction_status = 'Success'
),

PriorityAssessment AS (
    SELECT
        *,

        CASE
            WHEN risk_score >= 85
              OR TransactionAmount >= 100000
                THEN 'Critical'

            WHEN risk_score >= 75
              OR TransactionAmount >= 50000
                THEN 'High'

            ELSE 'Review'
        END AS ReviewPriority

    FROM FlaggedTransactions
)

SELECT TOP 20
    transaction_id,
    transaction_date,
    customer_id,
    transaction_type,
    channel,
    TransactionAmount,
    risk_score,
    ReviewPriority

FROM PriorityAssessment

ORDER BY
    CASE ReviewPriority
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        ELSE 3
    END,
    TransactionAmount DESC,
    risk_score DESC,
    transaction_id;






-- =====================================================
-- BUSINESS QUESTION 7:
-- FEE ANALYSIS AND MISSING FEE IMPUTATION
-- =====================================================

WITH AverageFee AS (
    SELECT
        AVG(fee_amount) AS MeanFee
    FROM validated.clean_transactions
    WHERE fee_amount IS NOT NULL
),

FeeAnalysis AS (
    SELECT
        t.transaction_id,
        t.transaction_status,
        t.fee_amount,

        COALESCE(
            t.fee_amount,
            a.MeanFee
        ) AS AdjustedFee

    FROM validated.clean_transactions AS t
    CROSS JOIN AverageFee AS a
)

SELECT
    COUNT(*) AS TotalTransactions,

    COUNT(fee_amount) AS TransactionsWithRecordedFee,

    SUM(CASE
        WHEN fee_amount IS NULL
        THEN 1 ELSE 0
    END) AS MissingFeeRecords,

    CAST(
        AVG(fee_amount)
        AS DECIMAL(18,2)
    ) AS MeanRecordedFee,

    CAST(
        SUM(fee_amount)
        AS DECIMAL(18,2)
    ) AS TotalRecordedFees,

    CAST(
        SUM(AdjustedFee)
        AS DECIMAL(18,2)
    ) AS TotalAdjustedFees,

    CAST(
        SUM(AdjustedFee) - SUM(fee_amount)
        AS DECIMAL(18,2)
    ) AS ImputedFeeDifference

FROM FeeAnalysis;





-- =====================================================
-- BUSINESS QUESTION 8:
-- CUSTOMER TRANSACTION VALUE CONCENTRATION
-- =====================================================

WITH CustomerActivity AS (
    SELECT
        customer_id,

        COUNT(*) AS TotalTransactions,

        SUM(CASE
            WHEN transaction_status = 'Success'
            THEN ABS(amount)
            ELSE 0
        END) AS SuccessfulTransactionValue

    FROM validated.clean_transactions

    GROUP BY customer_id
),

CustomerRanking AS (
    SELECT
        customer_id,
        TotalTransactions,
        SuccessfulTransactionValue,

        ROW_NUMBER() OVER (
            ORDER BY SuccessfulTransactionValue DESC,
                     customer_id
        ) AS CustomerRank,

        COUNT(*) OVER () AS TotalActiveCustomers

    FROM CustomerActivity
)

SELECT
    COUNT(*) AS TotalActiveCustomers,

    SUM(CASE
        WHEN CustomerRank <= CEILING(
            TotalActiveCustomers * 0.10
        )
        THEN 1 ELSE 0
    END) AS Top10PercentCustomerCount,

    CAST(
        SUM(SuccessfulTransactionValue)
        AS DECIMAL(18,2)
    ) AS TotalSuccessfulTransactionValue,

    CAST(
        SUM(CASE
            WHEN CustomerRank <= CEILING(
                TotalActiveCustomers * 0.10
            )
            THEN SuccessfulTransactionValue
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS Top10PercentTransactionValue,

    CAST(
        100.0 * SUM(CASE
            WHEN CustomerRank <= CEILING(
                TotalActiveCustomers * 0.10
            )
            THEN SuccessfulTransactionValue
            ELSE 0
        END)
        / NULLIF(SUM(SuccessfulTransactionValue), 0)
        AS DECIMAL(10,2)
    ) AS Top10PercentValueShare

FROM CustomerRanking;






-- =====================================================
-- BUSINESS QUESTION 9:
-- FAILED TRANSACTION ANALYSIS
-- BY CHANNEL AND TRANSACTION TYPE
-- =====================================================

SELECT
    channel AS TransactionChannel,
    transaction_type AS TransactionType,

    COUNT(*) AS TotalTransactions,

    SUM(CASE
        WHEN transaction_status = 'Failed'
        THEN 1 ELSE 0
    END) AS FailedTransactions,

    CAST(
        100.0 * SUM(CASE
            WHEN transaction_status = 'Failed'
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS FailureRatePercentage,

    CAST(
        SUM(CASE
            WHEN transaction_status = 'Failed'
            THEN ABS(amount)
            ELSE 0
        END)
        AS DECIMAL(18,2)
    ) AS FailedTransactionValue

FROM validated.clean_transactions

GROUP BY
    channel,
    transaction_type

ORDER BY
    FailedTransactions DESC,
    FailureRatePercentage DESC;
