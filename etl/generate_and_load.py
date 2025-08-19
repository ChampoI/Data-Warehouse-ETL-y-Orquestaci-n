# etl/generate_and_load.py
"""
Genera y carga datos ficticios a SQL Server (staging) y ejecuta procedimientos para dimensiones y hechos.
- Usa variables de entorno (.env) o defaults para conexión.
- Inserciones rápidas con pyodbc (fast_executemany).
- Incluye etapa de cambios en clientes para probar SCD2.
"""
import os
import time
import random
import pandas as pd
from datetime import datetime, date, timedelta

from dotenv import load_dotenv
import pyodbc

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")

load_dotenv(os.path.join(BASE_DIR, ".env")) if os.path.exists(os.path.join(BASE_DIR, ".env")) else None

SERVER   = os.getenv("SQLSERVER_HOST", "localhost")
PORT     = int(os.getenv("SQLSERVER_PORT", "1433"))
USER     = os.getenv("SQLSERVER_USER", "sa")
PWD      = os.getenv("SQLSERVER_PASSWORD", "P@ssw0rd12345!")
DB       = os.getenv("SQLSERVER_DB", "DWH_Demo")

def connect():
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={SERVER},{PORT};DATABASE={DB};UID={USER};PWD={PWD};TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str)

def load_table(cursor, table, df):
    cols = ",".join(f"[{c}]" for c in df.columns)
    placeholders = ",".join("?" for _ in df.columns)
    sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    cursor.fast_executemany = True
    cursor.executemany(sql, df.itertuples(index=False, name=None))

def exec_proc(cursor, proc_name):
    cursor.execute(f"EXEC {proc_name};")

def main():
    print(f"Connecting to SQL Server at {SERVER}:{PORT}, DB={DB} ...")
    with connect() as cn:
        cn.autocommit = False
        cur = cn.cursor()

        # Clear staging tables
        for t in ["stg.Sales", "stg.Customer", "stg.Product"]:
            try:
                cur.execute(f"TRUNCATE TABLE {t};")
            except Exception:
                pass

        # Load CSVs
        customers_initial = pd.read_csv(os.path.join(DATA_DIR, "customers_initial.csv"))
        customers_changes = pd.read_csv(os.path.join(DATA_DIR, "customers_changes.csv"))
        products = pd.read_csv(os.path.join(DATA_DIR, "products.csv"))
        sales = pd.read_csv(os.path.join(DATA_DIR, "sales.csv"),
                            parse_dates=["Date"])

        print("Loading initial customers into stg.Customer ...")
        load_table(cur, "stg.Customer", customers_initial)
        print("Upserting DimCustomer (SCD2) ...")
        exec_proc(cur, "dwh.usp_upsert_DimCustomer_SCD2")

        print("Loading products into stg.Product ...")
        load_table(cur, "stg.Product", products)
        print("Upserting DimProduct (SCD1) ...")
        exec_proc(cur, "dwh.usp_upsert_DimProduct_SCD1")

        print("Loading sales into stg.Sales ...")
        load_table(cur, "stg.Sales", sales)

        print("Loading FactSales ...")
        exec_proc(cur, "dwh.usp_load_FactSales")

        # Simulate a change set (SCD2)
        print("Applying customer changes (SCD2 demo) ...")
        cur.execute("TRUNCATE TABLE stg.Customer;")
        load_table(cur, "stg.Customer", customers_changes)
        exec_proc(cur, "dwh.usp_upsert_DimCustomer_SCD2")

        cn.commit()
        print("ETL completed successfully.")

if __name__ == "__main__":
    main()
