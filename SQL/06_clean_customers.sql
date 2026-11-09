USE [FinanceAnalyticsDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [validated].[clean_customers] AS
SELECT
    TRIM(customer_id) AS customer_id,

    TRIM(fisrt_name) AS first_name,

    TRIM(second_name) AS second_name,

    TRIM(gender) AS gender,

    TRY_CONVERT(
        DATE,
        TRIM(date_of_birth),
        105
    ) AS date_of_birth,

    TRIM(city) AS city,

    TRIM(state) AS state,

    TRIM(occupation) AS occupation,

    TRIM(customer_segment) AS customer_segment,

    TRY_CONVERT(
        DECIMAL(18,2),
        NULLIF(TRIM(annual_income), '')
    ) AS annual_income,

    TRY_CONVERT(
        DATE,
        TRIM(REPLACE(join_date, CHAR(13), '')),
        105
    ) AS join_date

FROM raw.customers;
GO


