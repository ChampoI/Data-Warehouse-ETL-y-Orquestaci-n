-- 07_views.sql
USE DWH_Demo;
GO

IF OBJECT_ID('dwh.vw_Sales') IS NOT NULL DROP VIEW dwh.vw_Sales;
GO

CREATE VIEW dwh.vw_Sales
AS
SELECT
  fs.SalesKey,
  dd.[Date],
  YEAR(dd.[Date]) AS [Year],
  dd.MonthName,
  dc.FullName AS Customer,
  dp.ProductName AS Product,
  dp.Category,
  fs.Quantity,
  fs.NetAmount,
  fs.DiscountAmount
FROM dwh.FactSales fs
JOIN dwh.DimDate dd     ON dd.DateKey = fs.DateKey
JOIN dwh.DimCustomer dc ON dc.CustomerKey = fs.CustomerKey
JOIN dwh.DimProduct dp  ON dp.ProductKey = fs.ProductKey;
GO
