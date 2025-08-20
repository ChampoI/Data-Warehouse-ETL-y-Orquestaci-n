# Data Warehouse – ETL y Orquestación

## 📖 Descripción General
Este proyecto es una **demostración de Data Warehouse** que simula un flujo ETL completo utilizando **SQL Server**, **Python** y **Docker**.  
Se muestran conceptos clave como:
- **Área de staging** para la ingestión de datos crudos.
- **Slowly Changing Dimensions (SCD)**:
  - SCD2 para clientes (histórico de cambios).
  - SCD1 para productos (último valor).
- **Carga de tabla de hechos** para transacciones de ventas.
- **Vistas analíticas** optimizadas con índices e índices columnstore.

El proyecto usa **datasets CSV** como fuente (`customers`, `products`, `sales`) y provee scripts de orquestación para Linux/macOS y Windows.

---

## 📂 Estructura del Proyecto
```
.
├── data/                  # Datasets fuente en CSV
│   ├── customers_initial.csv
│   ├── customers_changes.csv
│   ├── products.csv
│   └── sales.csv
│
├── etl/                   # Pipeline ETL en Python
│   ├── generate_and_load.py
│   └── requirements.txt
│
├── orchestration/          # Scripts de ejecución
│   ├── run_etl.sh          # Linux/macOS
│   └── run_etl.ps1         # Windows PowerShell
│
├── scripts/                # Definición del DWH en SQL
│   ├── 01_create_database_and_schemas.sql
│   ├── 02_dim_date.sql
│   ├── 03_dim_customer.sql
│   ├── 04_dim_product.sql
│   ├── 05_fact_sales.sql
│   ├── 06_staging.sql
│   ├── 07_views.sql
│   ├── 08_indexes.sql
│   ├── 09_procedures.sql
│   ├── 10_pipeline_example.sql
│   └── run_all.sql         # Script maestro
│
├── .env.sample             # Configuración de variables de entorno
├── docker-compose.yml      # Configuración Docker para SQL Server
```

---

## ⚙️ Prerrequisitos
- **Docker & Docker Compose**
- **Python 3.9+**
- **ODBC Driver 17 for SQL Server**
- **Herramienta cliente SQL** (SSMS, Azure Data Studio o VS Code con extensión `mssql`)

---

## 🚀 Ejecución

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-repo/dwh-demo.git
cd dwh-demo
```

### 2. Configurar variables de entorno
Copiar `.env.sample` a `.env` y editar con los parámetros de conexión:
```bash
cp .env.sample .env
```

Ejemplo:
```env
SQLSERVER_HOST=localhost
SQLSERVER_PORT=1433
SQLSERVER_USER=sa
SQLSERVER_PASSWORD=P@ssw0rd12345!
SQLSERVER_DB=DWH_Demo
```

### 3. Levantar SQL Server con Docker
```bash
docker-compose up -d
```

Esto inicia una instancia de **SQL Server** en `localhost:1433`.

### 4. Desplegar el Data Warehouse
Ejecutar el script maestro:
- Desde **VS Code con extensión mssql** o **sqlcmd**:
```sql
:r scripts/run_all.sql
```

Esto crea todos los esquemas, dimensiones, hechos, índices, vistas y procedimientos.

### 5. Ejecutar el ETL
- En **Linux/macOS**:
```bash
bash orchestration/run_etl.sh
```
- En **Windows**:
```powershell
.\orchestration
un_etl.ps1
```

Este proceso:
1. Carga tablas de staging desde los CSV.  
2. Ejecuta procedimientos almacenados para poblar dimensiones y hechos.  
3. Aplica cambios en clientes simulando SCD2.  

---

## 📊 Modelo de Datos
- **dwh.DimDate** → Dimensión de fechas (2019–2030).  
- **dwh.DimCustomer** → Clientes con histórico (SCD2).  
- **dwh.DimProduct** → Productos (SCD1).  
- **dwh.FactSales** → Hechos de ventas.  
- **dwh.vw_Sales** → Vista analítica uniendo hechos y dimensiones.  

Incluye índices B-Tree y un **Clustered Columnstore Index** para rendimiento en consultas analíticas.

---

## 🧪 Validación
Para validar la carga:
```sql
SELECT TOP 20 * FROM dwh.vw_Sales;
```

Deberías ver ventas enriquecidas con cliente y producto, y cambios históricos si se aplicó `customers_changes.csv`.

---

## 📌 Notas
- Puedes usar `scripts/10_pipeline_example.sql` para volver a correr manualmente la lógica del ETL.  
- El modelo puede ampliarse con más dimensiones/hechos.  
- Para producción, se recomienda orquestar con **Airflow**, **Azure Data Factory** o **SQL Agent**.  

---
