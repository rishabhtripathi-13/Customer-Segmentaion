SELECT * FROM project.project_data;
CREATE TEMPORARY TABLE max_orderdate1 AS
SELECT MAX(ORDERDATE) AS max_orderdate1
FROM project.project_data;

WITH rfm1 AS (
  SELECT 
    customername,
    COUNT(ordernumber) AS frequency,
    SUM(sales) AS monatary,
    DATEDIFF((SELECT max_orderdate1 FROM max_orderdate1), MAX(ORDERDATE)) AS recency
  FROM project.project_data
  GROUP BY customername
),
rfm_calc1 as
(
	select
		customername,
		recency,
		cast(monatary as decimal(16,0)) as monatary,
		frequency,
		NTILE(4) OVER (order by Recency desc) R,
		NTILE(4) OVER (order by Frequency asc) F,
		NTILE(4) OVER (order by Monatary asc) M
	FROM rfm1
),

rfm_finals as 
(
	select 
		 customername,
		 concat_ws('', R,F,M) as rfm_cell,
		cast((cast(R as float)+F+m)/3 as decimal(12,2)) as avg
	from rfm_calc1 
)
select * from rfm_finals;

SELECT
  customername,
  rfm_cell,
  CASE
    WHEN avg >= 3 THEN 'Highest value'
    WHEN avg >= 2 AND avg < 3 THEN 'Medium Value'
    WHEN avg >= 1 AND avg < 2 THEN 'Low Value'
  END AS avg_category,
  CASE
    WHEN rfm_cell IN ('444', '443', '344', '434') THEN 'Core-Best Customers'
    WHEN rfm_cell LIKE '__4' THEN 'Whales-Highest Paying'
    WHEN rfm_cell LIKE '_4_' or rfm_cell in ('432' , '433') THEN 'Loyal-Frequent Visitors'
    WHEN rfm_cell in  ('332' , '323' , '233' , '333' )  or rfm_cell like '42_' THEN 'Promising'
    WHEN  rfm_cell LIKE '41_' THEN 'Rookies'
    WHEN  rfm_cell LIKE '11_' OR rfm_cell like '12_'  or rfm_cell like '_11' THEN 'Lost'
	ELSE "Moderate Buyer"
  END AS rfm_category
FROM rfm_finals;

# Total Sales Amount for Each Order:
SELECT ORDERNUMBER, SUM(SALES) AS TotalSalesAmount
FROM project.project_data
GROUP BY ORDERNUMBER 
order by TotalSalesAmount desc limit 10 ;

#Top-Selling Products:
SELECT  PRODUCTLINE, SUM(QUANTITYORDERED) AS TotalQuantitySold
FROM project.project_data
GROUP BY  PRODUCTLINE
ORDER BY TotalQuantitySold DESC;

#Monthly Sales Trend:
SELECT YEAR_ID, MONTH_ID, SUM(SALES) AS MonthlySales
FROM project.project_data
GROUP BY YEAR_ID, MONTH_ID
ORDER BY YEAR_ID, MONTH_ID;

#Customer-wise Sales:
SELECT CUSTOMERNAME, SUM(SALES) AS TotalSalesByCustomer
FROM project.project_data
GROUP BY CUSTOMERNAME
ORDER BY TotalSalesByCustomer DESC;

#Average Sales and Quantity by Product Line:
SELECT PRODUCTLINE, AVG(SALES) AS AvgSales, AVG(QUANTITYORDERED) AS AvgQuantity
FROM project.project_data
GROUP BY PRODUCTLINE;

#Sales Distribution by Status:
SELECT STATUS, COUNT(*) AS SalesCount
FROM project.project_data
GROUP BY STATUS;

#Sales by Quarter and Year:
SELECT YEAR_ID, QTR_ID, SUM(SALES) AS QuarterlySales
FROM project.project_data
GROUP BY YEAR_ID, QTR_ID
ORDER BY YEAR_ID, QTR_ID;

#Customer Demographics:
SELECT COUNTRY, CITY, COUNT(*) AS CustomerCount
FROM project.project_data
GROUP BY COUNTRY,  CITY;

#Sales Performance by Contact Name:
SELECT CONTACTLASTNAME, CONTACTFIRSTNAME, SUM(SALES) AS TotalSalesByContact
FROM  project.project_data
GROUP BY CONTACTLASTNAME, CONTACTFIRSTNAME
ORDER BY TotalSalesByContact DESC;

#Sales and Quantity by Deal Size:
SELECT DEALSIZE, SUM(SALES) AS TotalSalesByDealSize, SUM(QUANTITYORDERED) AS TotalQuantityByDealSize
FROM project.project_data
GROUP BY DEALSIZE;