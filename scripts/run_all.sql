-- Ejecuta todo en orden. Úsalo en VS Code con la extensión mssql.
:r 01_create_database_and_schemas.sql
:r 02_dim_date.sql
:r 03_dim_customer.sql
:r 04_dim_product.sql
:r 05_fact_sales.sql
:r 06_staging.sql
:r 08_indexes.sql
:r 09_procedures.sql
:r 07_views.sql
-- Opcional: pipeline de ejemplo (requiere datos en staging)
-- :r 10_pipeline_example.sql
