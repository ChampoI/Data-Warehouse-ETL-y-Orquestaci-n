-- 02_dim_date.sql
USE DWH_Demo;
GO
IF OBJECT_ID('dwh.DimDate') IS NOT NULL DROP TABLE dwh.DimDate;
GO
CREATE TABLE dwh.DimDate (
  DateKey     INT         NOT NULL PRIMARY KEY, -- yyyymmdd
  [Date]      DATE        NOT NULL,
  [Year]      INT         NOT NULL,
  [Quarter]   TINYINT     NOT NULL,
  [Month]     TINYINT     NOT NULL,
  MonthName   VARCHAR(20) NOT NULL,
  [Day]       TINYINT     NOT NULL,
  DayName     VARCHAR(20) NOT NULL,
  IsWeekend   BIT         NOT NULL
);
GO

-- Poblar DimDate para un rango amplio (2019-01-01 a 2030-12-31)
WITH
E1(N) AS (SELECT 1 FROM (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) t(n)),
E2(N) AS (SELECT 1 FROM E1 a CROSS JOIN E1 b),       -- 10^2
E4(N) AS (SELECT 1 FROM E2 a CROSS JOIN E2 b),       -- 10^4
Nums(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 FROM E4)
INSERT INTO dwh.DimDate (DateKey, [Date], [Year], [Quarter], [Month], MonthName, [Day], DayName, IsWeekend)
SELECT
  CONVERT(INT, FORMAT(d, 'yyyyMMdd')) AS DateKey,
  d,
  DATEPART(YEAR, d),
  DATEPART(QUARTER, d),
  DATEPART(MONTH, d),
  DATENAME(MONTH, d),
  DATEPART(DAY, d),
  DATENAME(WEEKDAY, d),
  CASE WHEN DATEPART(WEEKDAY, d) IN (1,7) THEN 1 ELSE 0 END
FROM (
  SELECT DATEADD(DAY, N, '2019-01-01') AS d
  FROM Nums
) x
WHERE d <= '2030-12-31';
GO
