USE [FinanceAnalyticsDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [raw].[customers](
	[customer_id] [nvarchar](50) NULL,
	[fisrt_name] [nvarchar](100) NULL,
	[second_name] [nvarchar](100) NULL,
	[gender] [nvarchar](50) NULL,
	[date_of_birth] [nvarchar](50) NULL,
	[city] [nvarchar](100) NULL,
	[state] [nvarchar](100) NULL,
	[occupation] [nvarchar](100) NULL,
	[customer_segment] [nvarchar](100) NULL,
	[annual_income] [nvarchar](50) NULL,
	[join_date] [nvarchar](50) NULL
) ON [PRIMARY]
GO


