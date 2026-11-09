
USE FinanceAnalyticsDB;
GO

-- =====================================================
-- CSV DATA IMPORT
-- Finance Analytics & Transaction Risk Monitoring
-- =====================================================

-- Update these paths to the location of your CSV files.
-- SQL Server must have permission to read these files.

DECLARE @CustomersPath NVARCHAR(4000) =
    N'C:\FinanceAnalytics\data\customers.csv';

DECLARE @TransactionsPath NVARCHAR(4000) =
    N'C:\FinanceAnalytics\data\finance_transactions.csv';

DECLARE @SQL NVARCHAR(MAX);

-- Import customers
SET @SQL = N'
BULK INSERT raw.customers
FROM ''' + REPLACE(@CustomersPath, '''', '''''') + N'''
WITH (
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDQUOTE = ''"'',
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0a'',
    CODEPAGE = ''65001'',
    TABLOCK
);';

EXEC sys.sp_executesql @SQL;

-- Import transactions
SET @SQL = N'
BULK INSERT raw.finance_transactions
FROM ''' + REPLACE(@TransactionsPath, '''', '''''') + N'''
WITH (
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDQUOTE = ''"'',
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0a'',
    CODEPAGE = ''65001'',
    TABLOCK
);';

EXEC sys.sp_executesql @SQL;

-- Verify imported record counts
SELECT
    'Customers' AS Dataset,
    COUNT(*) AS TotalRecords
FROM raw.customers

UNION ALL

SELECT
    'Transactions',
    COUNT(*)
FROM raw.finance_transactions;
