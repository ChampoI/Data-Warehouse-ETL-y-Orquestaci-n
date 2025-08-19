-- 05_fact_sales.sql
USE DWH_Demo;
GO

IF OBJECT_ID('dwh.FactSales') IS NOT NULL DROP TABLE dwh.FactSales;
GO

CREATE TABLE dwh.FactSales (
  SalesKey       BIGINT IDENTITY(1,1) PRIMARY KEY,
  DateKey        INT           NOT NULL,  -- FK DimDate
  CustomerKey    INT           NOT NULL,  -- FK DimCustomer
  ProductKey     INT           NOT NULL,  -- FK DimProduct
  Quantity       INT           NOT NULL,
  NetAmount      DECIMAL(18,2) NOT NULL,
  DiscountAmount DECIMAL(18,2) NOT NULL,
  CreatedAt      DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
