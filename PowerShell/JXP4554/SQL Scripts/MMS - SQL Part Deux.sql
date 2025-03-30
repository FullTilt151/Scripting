-- Data types

-- https://msdn.microsoft.com/en-us/library/ms187752.aspx
-- https://msdn.microsoft.com/en-us/library/ms187928.aspx

USE TSQL;
GO

--Demonstrate implicit conversion from the lower type (varchar)
-- to the higher (int)
SELECT 1 + '2' AS result;


--Demonstrate implicit conversion from the lower type (varchar) 
-- to the higher (int)
--NOTE: THIS WILL FAIL

SELECT 1 + 'abc' AS result;

--Use explicit conversion in a query

SELECT CAST(1 AS VARCHAR(10)) + 'abc' AS result;

USE TSQL;
GO
-- Use collation in a query
SELECT empid, lastname 
FROM HR.employees
WHERE lastname = N'funk';

SELECT empid, lastname 
FROM HR.employees
WHERE lastname COLLATE Latin1_General_CS_AS = N'Funk';

-- Use concatenation in a query
SELECT empid, lastname, firstname, firstname + N' ' + lastname AS fullname
FROM HR.Employees;

-- Use string functions in a query
SELECT SUBSTRING('Microsoft SQL Server',11,3);
SELECT LEFT('Microsoft SQL Server',9);
SELECT RIGHT('Microsoft SQL Server',6);
SELECT LEN('Microsoft SQL Server     ');
SELECT DATALENGTH('Microsoft SQL Server     ');
SELECT CHARINDEX('SQL','Microsoft SQL Server');
SELECT REPLACE('Microsoft SQL Server Denali','Denali','2012');
SELECT UPPER('Microsoft SQL Server');
SELECT LOWER('Microsoft SQL Server');

-- https://msdn.microsoft.com/en-us/library/ms179859.aspx
-- Use the LIKE predicate in a query
SELECT categoryid, categoryname, description
FROM Production.Categories
WHERE description LIKE 'Sweet%';

USE TSQL;
GO

-- Display various current date and time functions

SELECT
	GETDATE()			AS [GetDate],
	CURRENT_TIMESTAMP	AS [Current_Timestamp],
	GETUTCDATE()		AS [GetUTCDate],
	SYSDATETIME()		AS [SYSDateTime],
	SYSUTCDATETIME()	AS [SYSUTCDateTime],
	SYSDATETIMEOFFSET()	AS [SYSDateTimeOffset];
	
-- Display various functions which return a portion of a date or time
SELECT DATENAME(year,'20120212');
SELECT DAY('20120212') AS [Day], MONTH('20120212') AS [Month],YEAR('20120212') AS [Year];

	
-- Display various functions which return a date or time from parts
SELECT DATETIMEFROMPARTS(2012,2,12,8,30,0,0) AS Result; --7 arguments
SELECT DATETIME2FROMPARTS(2012,2,12,8,30,00,0,0) AS Result; -- 8 arguments
SELECT DATEFROMPARTS(2012,2,12) AS Result; -- 3args
SELECT DATETIMEOFFSETFROMPARTS(2012,2,12,8,30,0,0,-7,0,0) AS Result;


-- Demonstrate DATEDIFF with  this to show difference in precision:
SELECT DATEDIFF(millisecond, GETDATE(), SYSDATETIME()); 

--  Use ISDATE to check validity of inputs:
SELECT ISDATE('20120212'); --is valid
SELECT ISDATE('20120230'); --February doesn't have 30 days


USE TSQL;
GO

-- SInsert a row into the Employees table

INSERT INTO HR.Employees
(
Title,
titleofcourtesy,
FirstName,
Lastname,
hiredate,
birthdate,
address,
city,
country,
phone
)
VALUES
(
'Sales Representative',
'Mr',
'Stephen',
'Rutter',
'05/07/2013',
'09/15/1978',
'4567 2nd Ave. N.E.',
'Seattle',
'USA',
'(206)555-0109'
);
	
-- Insert all of the rows from the PotentialCustomers table into the Customers table

INSERT INTO Sales.Customers
(
companyname,
contactname,
contacttitle,
address,
city,
region,
postalcode,
country,
phone,
fax
)
SELECT * FROM dbo.PotentialCustomers;



USE TSQL;
GO

-- Update a row in the Employees table

UPDATE HR.Employees
SET title='Sales Manager'
WHERE EmpID=7

-- Merge update the Products table

--View products

SELECT * FROM Production.Products

--View ProductsStaging

SELECT * FROM Production.Categories

--Perform Merge Update

MERGE INTO Production.Products as P
	USING Production.ProductsStaging as S
		ON P.ProductID=S.ProductID
WHEN MATCHED THEN
	UPDATE SET
	P.Discontinued=S.Discontinued
WHEN NOT MATCHED THEN
	INSERT (productname,supplierid,categoryid,unitprice,discontinued)
	VALUES (S.productname,S.supplierid,S.categoryid,S.unitprice,S.discontinued);

--View products

SELECT * FROM Production.Products

-- Delete a row in the Products table

DELETE Production.PRODUCTS
WHERE ProductID=78

-- Truncate the ProductsStaging table

TRUNCATE TABLE Production.ProductsStaging

-- Discuss tables with IDENTITY

-- Built in functions

USE TSQL;
GO

-- scalar functions

SELECT orderid, YEAR(orderdate) AS orderyear
FROM Sales.Orders;

SELECT ABS(-1.0), ABS(0.0), ABS(1.0);

SELECT CAST(SYSDATETIME() AS DATE) AS [current_date];

SELECT DB_NAME() AS [Current Database];

-- a simple Aggregate function demo without GROUP BY

SELECT COUNT(*) AS numorders, SUM(unitprice) AS totalsales
FROM	Sales.OrderDetails;

-- a simple ranking function
SELECT TOP(5) productid, productname, unitprice,
	RANK() OVER(ORDER BY unitprice DESC) AS rankbyprice
FROM Production.Products
ORDER BY rankbyprice;

--the ISNUMERIC function with a character input
SELECT ISNUMERIC('SQL') AS isnmumeric_result;

--the ISNUMERIC function with a float input
SELECT ISNUMERIC('1E3') AS isnumeric_result;

--the IIF Function
SELECT 	productid, unitprice, IIF(unitprice > 50, 'high','low') AS pricepoint
FROM Production.Products;

USE TSQL;
GO

-- The ISNULL function
SELECT custid, city, ISNULL(region, 'N/A') AS region, country
FROM Sales.Customers;

-- COALESCE function

SELECT	custid, country, region, city, 
			country + ',' + region + ', ' + city as location
FROM Sales.Customers;

SELECT	custid, country, region, city, 
			country + ',' + COALESCE(region, ' ') + ', ' + city as location
FROM Sales.Customers;



USE TSQL;
GO

-- THIS WILL FAIL, since some columns are not aggregated
-- and there is no explicit GROUP BY clause
SELECT orderid, productid, AVG(unitprice), MAX(qty), MAX(discount)
FROM Sales.OrderDetails;

-- This will succeed and return the AVG/MIN/MAX of all rows:
SELECT AVG(unitprice) AS avg_price, MIN(qty)AS min_price, MAX(discount) AS max_discount
FROM Sales.OrderDetails;

-- The use of aggregates with non-numeric data types:
SELECT MIN(companyname) AS first_customer, MAX(companyname) AS last_customer
FROM Sales.Customers;

-- The use of aggregates with non-numeric data types:
SELECT MIN(orderdate)AS earliest,MAX(orderdate) AS latest
FROM Sales.Orders;

-- the use of DISTINCT with aggregate functions:
SELECT empid, YEAR(orderdate) AS orderyear,
COUNT(custid) AS all_custs,
COUNT(DISTINCT custid) AS unique_custs
FROM Sales.Orders
GROUP BY empid, YEAR(orderdate);

-- the impact of NULL on aggregate functions
-- First, show the existence of NULLs in Sales.Orders
SELECT DISTINCT shippeddate
FROM Sales.Orders
ORDER BY shippeddate;

-- Then show that MIN, MAX and COUNT ignore NULL, COUNT(*) doesn't.
-- Show the messages tab in the SSMS results pane
-- for Warning: Null value is eliminated by an aggregate or other SET operation.
SELECT MIN(shippeddate) AS earliest, MAX(shippeddate) AS latest, COUNT(shippeddate) AS [count_shippeddate], COUNT(*) AS COUNT_all
FROM Sales.Orders;

-- Create an example table
CREATE TABLE dbo.t1(
	c1 INT IDENTITY NOT NULL PRIMARY KEY,
	c2 INT NULL);
-- Populate it	
INSERT INTO dbo.t1(c2)
VALUES(NULL),(10),(20),(30),(40),(50);
-- View the contents. Note the NULL
SELECT c1, c2
FROM dbo.t1;
-- Execute this query to compare the behavior of AVG to an aritmetic average (SUM/COUNT)
SELECT SUM(c2) AS sum_nonnulls, COUNT(*)AS count_all_rows, COUNT(c2)AS count_nonnulls, AVG(c2) AS [avg], (SUM(c2)/COUNT(*))AS arith_avg
FROM dbo.t1;

-- Execute this query to demonstrate replacement of NULL before aggregating
-- Create test table
CREATE TABLE dbo.t2
    (
      c1 INT IDENTITY NOT NULL PRIMARY KEY,
      c2 INT NULL
    ) ;
GO
-- Populate test table
INSERT INTO dbo.t2
VALUES(1),(10),(1),(NULL),(1),(10),(1),(NULL),(1),(10),(1),(10);
GO
-- Show table contents
SELECT c1, c2
FROM dbo.t2;
-- Show standard AVG versus replacement of NULL with zero
SELECT AVG(c2) AS AvgWithNULLs, AVG(COALESCE(c2,0)) AS AvgWithNULLReplace
FROM dbo.t2;

-- clean up
DROP TABLE dbo.t1;
DROP TABLE dbo.t2;

-- Open a new query window to the TSQL database
USE TSQL;
GO

SELECT empid, COUNT(*) AS cnt
FROM Sales.Orders
GROUP BY empid
ORDER BY cnt desc;

SELECT custid, YEAR(orderdate) AS [year], COUNT(*) AS cnt
FROM Sales.Orders
WHERE empid = 4
GROUP BY custid, YEAR(orderdate);

SELECT orderid, empid, custid
FROM Sales.Orders;

SELECT orderid, empid, custid
FROM Sales.Orders
WHERE custid <>3;

SELECT empid, COUNT(*)
FROM Sales.Orders
WHERE CUSTID <>3
GROUP BY empid;


SELECT custid, COUNT(*) AS cnt
FROM Sales.Orders
GROUP BY custid;

SELECT productid, MAX(qty) AS largest_order
FROM Sales.OrderDetails
GROUP BY productid;

-- https://msdn.microsoft.com/en-us/library/ms173454.aspx

USE TSQL;
GO

SELECT custid, COUNT(*) AS count_orders
FROM Sales.Orders
GROUP BY custid;

-- This query uses a HAVING clause to filter out customers with fewer than 10 orders
SELECT custid, COUNT(*) AS count_orders
FROM Sales.Orders
GROUP BY custid
HAVING COUNT(*) >= 10

-- Review the logical order of operations
-- the column alias for COUNT(*) hasn't been processed yet
-- when HAVING refers to it
-- THIS WILL FAIL
SELECT custid, COUNT(*) AS count_orders
FROM Sales.Orders
GROUP BY custid
HAVING count_orders >= 10


-- difference between WHERE filter and HAVING filter:
-- The following query uses a WHERE clause to filter
-- orders

SELECT COUNT(*) AS cnt, AVG(qty) AS [avg_qty]
FROM Production.Products AS p
JOIN Sales.OrderDetails AS od
	ON p.productid = od.productid
WHERE od.qty > 20
GROUP BY p.categoryid;

-- This query uses a HAVING clause to filter groups
-- with an average quantity > 20
SELECT COUNT(*) AS cnt, AVG(qty) AS [avg_qty]
FROM Production.Products AS p
JOIN Sales.OrderDetails AS od
	ON p.productid = od.productid
GROUP BY p.categoryid
HAVING AVG(qty) > 20;

-- Select and execute the following query to show
-- All customers and how many orders they have placed
-- 89 rows - note custid 13
SELECT c.custid, COUNT(*) AS cnt
FROM Sales.Customers AS c
JOIN Sales.Orders AS o
ON c.custid = o.custid
GROUP BY c.custid
ORDER BY cnt DESC;

-- Use HAVING to filter only customers who have placed more than one order
SELECT c.custid, COUNT(*) AS cnt
FROM Sales.Customers AS c
JOIN Sales.Orders AS o
ON c.custid = o.custid
GROUP BY c.custid
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- Select and execute the following query to show
-- All products and in how many orders they appear
-- 77 rows, note bottom of list
SELECT p.productid, COUNT(*) AS cnt
FROM Production.Products AS p
JOIN Sales.OrderDetails AS od
ON p.productid = od.productid
GROUP BY p.productid
ORDER BY cnt DESC;

-- Use HAVING to filter only products which have been ordered 10 or more times:
-- 71 rows returned
SELECT p.productid, COUNT(*) AS cnt
FROM Production.Products AS p
JOIN Sales.OrderDetails AS od
ON p.productid = od.productid
GROUP BY p.productid
HAVING COUNT(*) >= 10
ORDER BY cnt DESC;

-- Subqueries

USE TSQL;
GO
-- Step 1: Scalar subqueres:
-- Select this query and execute it to
-- obtain most recent order
SELECT MAX(orderid) AS lastorder
FROM Sales.Orders;

-- Select this query and execute it to
-- find details in Sales.OrderDetails
-- for most recent order
SELECT orderid, productid, unitprice, qty
FROM Sales.OrderDetails
WHERE orderid = 
	(SELECT MAX(orderid) AS lastorder
	FROM Sales.Orders);

-- THIS WILL FAIL, since
-- subquery returns more than 
-- 1 value
SELECT orderid, productid, unitprice, qty
FROM Sales.OrderDetails
WHERE orderid = 
	(SELECT orderid AS O
	FROM Sales.Orders
	WHERE empid =2);

-- Step 3: Multi-valued subqueries 
-- Select this query and execute it to	
-- return order info for customers in Mexico
SELECT custid, orderid
FROM Sales.orders
WHERE custid IN (
	SELECT custid
	FROM Sales.Customers
	WHERE country = N'Mexico');

-- Same result expressed as a join:
SELECT c.custid, o.orderid
FROM Sales.Customers AS c JOIN Sales.Orders AS o
ON c.custid = o.custid
WHERE c.country = N'Mexico';

USE TSQL;
GO

-- Step 2: Correlated subqueries
-- Select this query and execute it to show
-- Customers with most recent order info per customer
-- 
-- (Note that this query may return more than one row per
-- customer if there are multiple orders placed per customer
-- per date. Be sure to test your own data
-- when adapting this query to other data sources. There is no
-- logic in this example to handle ties.)

SELECT custid, orderid, orderdate
FROM Sales.Orders AS outerorders
WHERE orderdate =
	(SELECT MAX(orderdate)
	FROM Sales.Orders AS innerorders
	WHERE innerorders.custid = outerorders.custid)
ORDER BY custid;

-- Select and execute the following query to 
-- show the use of a correlated subquery that
-- uses the empid from Sales.Orders to retrieve
-- orders placed by an employee on the latest order 
-- date for each employee
SELECT orderid, empid, orderdate
FROM Sales.Orders AS O1
WHERE orderdate =
	(SELECT MAX(orderdate)
	 FROM Sales.Orders AS O2
	 WHERE O2.empid = O1.empid)
ORDER BY empid, orderdate;

-- Select and execute the following query to 
-- show the use of a correlated subquery 
SELECT custid, ordermonth, qty
FROM Sales.Custorders AS outercustorders
WHERE qty =
	(SELECT MAX(qty)
		FROM Sales.CustOrders AS innercustorders
		WHERE innercustorders.custid =outercustorders.custid
	)
ORDER BY custid;	


USE TSQL;
GO

-- Step 2: Using EXISTS
-- Select this query and execute it to show
-- any customer who placed an order
SELECT custid, companyname
FROM Sales.Customers AS c
WHERE EXISTS (
	SELECT * 
	FROM Sales.Orders AS o
	WHERE c.custid=o.custid);

-- Step 3: Using NOT EXISTS	
-- Return any customer who has not placed an order
SELECT custid, companyname
FROM Sales.Customers AS c
WHERE NOT EXISTS (
	SELECT * 
	FROM Sales.Orders AS o
	WHERE c.custid=o.custid);
	
-- Step 4: Compare COUNT(*)>0 to EXISTS:
-- Use COUNT(*) > 0
SELECT empid, lastname
FROM HR.Employees AS e		
WHERE (SELECT COUNT(*)
		FROM Sales.Orders AS O
		WHERE O.empid = e.empid)>0;
-- Use EXISTS
SELECT empid, lastname
FROM HR.Employees AS e
WHERE EXISTS(	SELECT * 
		FROM Sales.Orders AS O
		WHERE O.empid = e.empid);		