
-- Finance Analytics & Transaction Risk Monitoring
-- Database and Schema Setup

IF DB_ID('FinanceAnalyticsDB') IS NULL
BEGIN
    CREATE DATABASE FinanceAnalyticsDB;
END;
GO

USE FinanceAnalyticsDB;
GO

IF SCHEMA_ID('raw') IS NULL
    EXEC('CREATE SCHEMA raw');
GO

IF SCHEMA_ID('validated') IS NULL
    EXEC('CREATE SCHEMA validated');
GO

IF SCHEMA_ID('analytics') IS NULL
    EXEC('CREATE SCHEMA analytics');
GO
