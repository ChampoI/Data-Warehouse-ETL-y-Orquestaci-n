-- 03_dim_customer.sql
USE DWH_Demo;
GO

IF OBJECT_ID('dwh.DimCustomer') IS NOT NULL DROP TABLE dwh.DimCustomer;
IF OBJECT_ID('stg.Customer')   IS NOT NULL DROP TABLE stg.Customer;
GO

CREATE TABLE dwh.DimCustomer (
  CustomerKey   INT IDENTITY(1,1) PRIMARY KEY,
  CustomerIdBK  VARCHAR(50) NOT NULL,
  FullName      VARCHAR(200) NOT NULL,
  City          VARCHAR(100) NULL,
  Segment       VARCHAR(50)  NULL,
  ValidFrom     DATETIME2    NOT NULL,
  ValidTo       DATETIME2    NOT NULL,
  IsCurrent     BIT          NOT NULL,
  RowHash       VARBINARY(32) NULL
);
GO

CREATE UNIQUE INDEX UX_DimCustomer_BK_Current
  ON dwh.DimCustomer(CustomerIdBK, IsCurrent)
  WHERE IsCurrent = 1;
GO

CREATE TABLE stg.Customer (
  CustomerId  VARCHAR(50),
  FullName    VARCHAR(200),
  City        VARCHAR(100),
  Segment     VARCHAR(50),
  ExtractDT   DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
