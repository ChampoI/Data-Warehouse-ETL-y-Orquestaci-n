-- 04_dim_product.sql
USE DWH_Demo;
GO

IF OBJECT_ID('dwh.DimProduct') IS NOT NULL DROP TABLE dwh.DimProduct;
IF OBJECT_ID('stg.Product')   IS NOT NULL DROP TABLE stg.Product;
GO

CREATE TABLE dwh.DimProduct (
  ProductKey   INT IDENTITY(1,1) PRIMARY KEY,
  ProductIdBK  VARCHAR(50) NOT NULL,
  ProductName  VARCHAR(200) NOT NULL,
  Category     VARCHAR(100) NULL,
  Price        DECIMAL(18,2) NULL,
  RowHash      VARBINARY(32) NULL
);
GO

CREATE UNIQUE INDEX UX_DimProduct_BK ON dwh.DimProduct(ProductIdBK);
GO

CREATE TABLE stg.Product (
  ProductId   VARCHAR(50),
  ProductName VARCHAR(200),
  Category    VARCHAR(100),
  Price       DECIMAL(18,2),
  ExtractDT   DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
