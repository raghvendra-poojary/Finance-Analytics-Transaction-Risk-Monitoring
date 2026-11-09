USE [FinanceAnalyticsDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [raw].[finance_transactions](
	[transaction_id] [nvarchar](50) NULL,
	[transaction_date] [nvarchar](50) NULL,
	[account_id] [nvarchar](50) NULL,
	[customer_id] [nvarchar](50) NULL,
	[transaction_type] [nvarchar](100) NULL,
	[channel] [nvarchar](100) NULL,
	[merchant_category] [nvarchar](100) NULL,
	[amount] [nvarchar](50) NULL,
	[fee_amount] [nvarchar](50) NULL,
	[tax_amount] [nvarchar](50) NULL,
	[currency] [nvarchar](20) NULL,
	[transaction_status] [nvarchar](50) NULL,
	[is_fraud] [nvarchar](20) NULL,
	[risk_score] [nvarchar](50) NULL,
	[reference_no] [nvarchar](100) NULL
) ON [PRIMARY]
GO


