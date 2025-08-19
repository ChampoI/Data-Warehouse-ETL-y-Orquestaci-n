-- 06_staging.sql
USE DWH_Demo;
GO

IF OBJECT_ID('stg.Sales') IS NOT NULL DROP TABLE stg.Sales;
GO

CREATE TABLE stg.Sales (
  SaleId      BIGINT,
  CustomerId  VARCHAR(50),
  ProductId   VARCHAR(50),
  [Date]      DATE,
  Quantity    INT,
  NetAmount   DECIMAL(18,2),
  Discount    DECIMAL(18,2),
  ExtractDT   DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
