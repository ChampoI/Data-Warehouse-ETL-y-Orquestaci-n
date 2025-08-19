# SQL Server Data Warehouse Starter 

Este proyecto crea un **Data Warehouse** en **SQL Server** con datos ficticios. 
Incluye modelo dimensional (star schema), **SCD Tipo 2** para clientes, staging, hechos, vistas de presentación, datos de ejemplo y opciones de ejecución local o con **Docker**.

## Contenido
```
DWH_SQLServer_Starter/
├─ README.md
├─ docker-compose.yml
├─ .env.sample
├─ scripts/
│  ├─ run_all.sql
│  ├─ 01_create_database_and_schemas.sql
│  ├─ 02_dim_date.sql
│  ├─ 03_dim_customer.sql
│  ├─ 04_dim_product.sql
│  ├─ 05_fact_sales.sql
│  ├─ 06_staging.sql
│  ├─ 07_views.sql
│  ├─ 08_indexes.sql
│  ├─ 09_procedures.sql
│  └─ 10_pipeline_example.sql
├─ data/
│  ├─ customers_initial.csv
│  ├─ customers_changes.csv
│  ├─ products.csv
│  └─ sales.csv
├─ etl/
│  ├─ generate_and_load.py
│  └─ requirements.txt
└─ orchestration/
   ├─ run_etl.ps1
   └─ run_etl.sh
```

## Requisitos
- **Opción A (local)**: SQL Server local o remoto accesible y VS Code con extensión **SQL Server (mssql)**.
- **Opción B (Docker)**: Docker Desktop.
- **Python 3.10+** para ejecutar el ETL (opcional, ya vienen CSVs pre-generados).

## Ejecución rápida en VS Code (Opción A)
1. Asegúrate de tener un servidor SQL Server accesible (local o remoto).
2. Abre la carpeta del proyecto en VS Code. Instala la extensión **SQL Server (mssql)** si no la tienes.
3. Abre `scripts/run_all.sql` y conéctate al servidor (usa `DWH_Demo` como nombre de base).
4. Ejecuta el script completo. Esto creará la base, esquemas, tablas, vistas, índices y procedimientos, y poblará **DimDate**.
5. (Opcional) Para cargar datos desde CSVs: ejecuta `etl/generate_and_load.py` (configura `.env` si usarás Docker u otro servidor).

## Ejecución con Docker (Opción B)
1. Copia `.env.sample` a `.env` y ajusta credenciales si quieres.
2. `docker compose up -d`
3. Conéctate desde VS Code al servidor `localhost,1433` con usuario `sa` y la contraseña del `.env`.
4. Corre `scripts/run_all.sql` (igual que en la opción A).
5. Luego ejecuta el ETL: `python etl/generate_and_load.py`.

## Modelo (resumen)
- **DimDate** (calendario).
- **DimCustomer** (SCD Tipo 2 con `ValidFrom`, `ValidTo`, `IsCurrent`, `RowHash`).
- **DimProduct** (SCD Tipo 1).
- **FactSales** (hechos granulares por venta): referencias a Date, Customer y Product.

## Pipeline de ejemplo
1. Cargar staging (`stg.Customer`, `stg.Product`, `stg.Sales`) desde CSVs (el ETL ya lo hace).
2. Ejecutar `dwh.usp_upsert_DimCustomer_SCD2` y `dwh.usp_upsert_DimProduct_SCD1`.
3. Ejecutar `dwh.usp_load_FactSales` (resuelve FKs y carga el hecho).
4. Consultar `dwh.vw_Sales` desde Power BI/VS Code.

## Notas
- Los CSVs incluidos (`/data`) ya contienen datos ficticios para una primera carga y un set de cambios para probar SCD2.
- Si usas Docker, recuerda que **BULK INSERT** requiere rutas del contenedor; por eso el ETL usa `pyodbc` con inserciones rápidas (no BULK).


