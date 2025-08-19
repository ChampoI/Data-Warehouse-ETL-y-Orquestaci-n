-- 08_indexes.sql
USE DWH_Demo;
GO
-- Índices útiles
CREATE INDEX IX_FactSales_DateKey     ON dwh.FactSales(DateKey);
CREATE INDEX IX_FactSales_CustomerKey ON dwh.FactSales(CustomerKey);
CREATE INDEX IX_FactSales_ProductKey  ON dwh.FactSales(ProductKey);
GO
-- Columnstore para analítica (opcional; excelente rendimiento en agregaciones)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'CCI_FactSales')
  CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactSales ON dwh.FactSales;
GO
