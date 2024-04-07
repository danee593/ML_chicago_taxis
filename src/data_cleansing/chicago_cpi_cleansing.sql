/* Data retrieved from: https://data.bls.gov/timeseries/CUURS23ASA0?amp%253bdata_tool=XGtable&output_view=data&include_graphs=true 

1. unpivot the months column to make it long format
2. filter the years of interest 2013-2023
3. parse as date by concatenating the year and month columns
4. calculate the deflator

V1. Author: Daniel Enriquez 
2024-03-06

TO DO:
add exception handling.
*/

CREATE OR REPLACE TABLE  `big-data-taxis-416219.taxi.chicago_cpi_deflator_cleaned` AS
SELECT *
FROM(
WITH all_years_cpi AS(
SELECT -- This query transforms the chicago_cpi table from wide format to long format by unpivoting
  cpi_unp.year
  ,cpi_unp.months
  ,cpi_unp.cpi
FROM `big-data-taxis-416219.taxi.chicago_cpi` as cpi
UNPIVOT INCLUDE NULLS (cpi FOR months IN (cpi.jan, cpi.feb, cpi.mar, cpi.apr, cpi.may, cpi.jun,
                            cpi.jul, cpi.aug, cpi.sep, cpi.oct, cpi.nov, cpi.dec)) AS cpi_unp
)
, cpi_2013_2023 AS(
SELECT * -- select the important years for our case 2013-2023 inclusive
FROM all_years_cpi as yc
WHERE yc.year BETWEEN 2013 AND 2023
)
, cpi_format_date AS(
SELECT -- corrects the formating of the date by concatenating the monts and year and parsing as date
  PARSE_DATE('%b %Y', CONCAT(INITCAP(c.months)," ",c.year)) AS cpi_date
  ,c.cpi
FROM cpi_2013_2023 as c
)
, chicago_deflator AS(
SELECT -- calculates the deflator with base 2013. Divide each cpi by the cpi of jan 2013
  cfd.*
  ,(cfd.cpi / (SELECT cfd2.cpi 
    FROM cpi_format_date AS cfd2
    WHERE cfd2.cpi_date > '2012-12-01'
      AND cfd2.cpi_date < '2013-02-01')) AS deflator_base_jan_13
FROM cpi_format_date AS cfd
)
SELECT *
FROM chicago_deflator
);

