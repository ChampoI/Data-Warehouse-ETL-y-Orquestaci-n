-- 10_pipeline_example.sql
USE DWH_Demo;
GO
-- Este script asume que ya cargaste CSVs a staging.
EXEC dwh.usp_upsert_DimCustomer_SCD2;
EXEC dwh.usp_upsert_DimProduct_SCD1;
EXEC dwh.usp_load_FactSales;
GO
