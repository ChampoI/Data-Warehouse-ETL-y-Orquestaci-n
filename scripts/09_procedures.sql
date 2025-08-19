-- 09_procedures.sql
USE DWH_Demo;
GO

-- Upsert SCD2 para clientes
IF OBJECT_ID('dwh.usp_upsert_DimCustomer_SCD2') IS NOT NULL DROP PROCEDURE dwh.usp_upsert_DimCustomer_SCD2;
GO
CREATE PROCEDURE dwh.usp_upsert_DimCustomer_SCD2
AS
BEGIN
  SET NOCOUNT ON;

  -- Fuente con hash
  WITH src AS (
    SELECT
      CustomerId   AS CustomerIdBK,
      FullName,
      City,
      Segment,
      CONVERT(VARBINARY(32), HASHBYTES('SHA2_256', CONCAT(FullName, '|', City, '|', Segment))) AS RowHash
    FROM stg.Customer
  )
  MERGE dwh.DimCustomer AS tgt
  USING src
    ON tgt.CustomerIdBK = src.CustomerIdBK
   AND tgt.IsCurrent = 1
  WHEN MATCHED AND tgt.RowHash <> src.RowHash THEN
    UPDATE SET tgt.IsCurrent = 0,
               tgt.ValidTo   = SYSUTCDATETIME()
  WHEN NOT MATCHED BY TARGET THEN
    INSERT (CustomerIdBK, FullName, City, Segment, ValidFrom, ValidTo, IsCurrent, RowHash)
    VALUES (src.CustomerIdBK, src.FullName, src.City, src.Segment, SYSUTCDATETIME(), '9999-12-31', 1, src.RowHash);

  -- Insertar nuevas versiones para los que fueron cerrados
  INSERT INTO dwh.DimCustomer (CustomerIdBK, FullName, City, Segment, ValidFrom, ValidTo, IsCurrent, RowHash)
  SELECT s.CustomerIdBK, s.FullName, s.City, s.Segment, SYSUTCDATETIME(), '9999-12-31', 1, s.RowHash
  FROM stg.Customer s
  JOIN dwh.DimCustomer c
    ON c.CustomerIdBK = s.CustomerIdBK
   AND c.IsCurrent = 0
   AND c.ValidTo >= DATEADD(SECOND, -1, SYSUTCDATETIME())
  WHERE NOT EXISTS (
    SELECT 1 FROM dwh.DimCustomer cur
    WHERE cur.CustomerIdBK = s.CustomerIdBK
      AND cur.IsCurrent = 1
      AND cur.RowHash = s.RowHash
  );
END
GO

-- Upsert SCD1 para productos
IF OBJECT_ID('dwh.usp_upsert_DimProduct_SCD1') IS NOT NULL DROP PROCEDURE dwh.usp_upsert_DimProduct_SCD1;
GO
CREATE PROCEDURE dwh.usp_upsert_DimProduct_SCD1
AS
BEGIN
  SET NOCOUNT ON;

  WITH src AS (
    SELECT
      ProductId   AS ProductIdBK,
      ProductName,
      Category,
      Price,
      CONVERT(VARBINARY(32), HASHBYTES('SHA2_256', CONCAT(ProductName, '|', Category, '|', FORMAT(Price,'N2')))) AS RowHash
    FROM stg.Product
  )
  MERGE dwh.DimProduct AS tgt
  USING src
    ON tgt.ProductIdBK = src.ProductIdBK
  WHEN MATCHED AND tgt.RowHash <> src.RowHash THEN
    UPDATE SET tgt.ProductName = src.ProductName,
               tgt.Category    = src.Category,
               tgt.Price       = src.Price,
               tgt.RowHash     = src.RowHash
  WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductIdBK, ProductName, Category, Price, RowHash)
    VALUES (src.ProductIdBK, src.ProductName, src.Category, src.Price, src.RowHash);
END
GO

-- Carga hechos
IF OBJECT_ID('dwh.usp_load_FactSales') IS NOT NULL DROP PROCEDURE dwh.usp_load_FactSales;
GO
CREATE PROCEDURE dwh.usp_load_FactSales
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dwh.FactSales (DateKey, CustomerKey, ProductKey, Quantity, NetAmount, DiscountAmount)
  SELECT
    CONVERT(INT, FORMAT(s.[Date], 'yyyyMMdd')) AS DateKey,
    dc.CustomerKey,
    dp.ProductKey,
    s.Quantity,
    s.NetAmount,
    s.Discount
  FROM stg.Sales s
  JOIN dwh.DimCustomer dc
    ON dc.CustomerIdBK = s.CustomerId
   AND dc.IsCurrent = 1
  JOIN dwh.DimProduct dp
    ON dp.ProductIdBK = s.ProductId;
END
GO
