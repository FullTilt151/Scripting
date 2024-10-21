-- Discuss Versions and Editions
	-- https://support.microsoft.com/en-us/kb/321185

-- Discuss instances

-- Tour SSMS
	-- Discuss SQL Server aliases
-- Disucss BOL

USE TEMPDB;
GO


-- DDL  https://msdn.microsoft.com/en-us/library/ff848799.aspx
-- DCL https://en.wikipedia.org/wiki/Data_control_language
-- DML  https://msdn.microsoft.com/en-us/library/ff848766.aspx
-- Point out the use of GO to delimit the batch.

CREATE TABLE dbo.orders
	( 
		orderid int, 
		custid int, 
		orderdate date,
		quantity int,
		amount money
	); 
GO 


INSERT INTO dbo.orders
VALUES(101,774,SYSDATETIME(),100,99.98),(102,775,SYSDATETIME(),32,49.99), 
	(103,774,SYSDATETIME(),101,99.98),(104,775,SYSDATETIME(),102,99.98),
	(105,774,SYSDATETIME(),103,99.98);

-- Predicates supported by T-SQL include the following 
	-- IN, used to determine whether a value matches any value in a list or subquery. 
	--BETWEEN, used to specify a range of values. 
	--LIKE, used to match characters against a pattern. 

--Operators include several common categories: 
	--Comparison for equality and inequality tests: =, <, >, >=, <=, !=, !>, !< (Note that !>, !< and != are not ISO standard. It is best practice to use standard options when they exist). 
	--Logical, for testing the validity of a condition: AND, OR, NOT 
	--Arithmetic, for performing mathematical operations: +, -, *, /, % (modulo) 
	--Concatenation, for combining character strings: + 
	--Assignment, for setting a value: = 

-- SQL Functions

	--String functions 
		-- SUBSTRING, LEFT, RIGHT, LEN, DATALENGTH 
		--REPLACE, REPLICATE 
		--UPPER, LOWER, RTRIM, LTRIM 
	--Date and time functions 
		--GETDATE, SYSDATETIME, GETUTCDATE 
		--DATEADD, DATEDIFF 
		--YEAR, MONTH, DAY 
	--Aggregate functions 
		--SUM, MIN, MAX, AVG 
		--COUNT, COUNTBIG 
	--Mathematical functions 
		--RAND, ROUND, POWER, ABS 
		--CEILING, FLOOR 


SELECT orderid, custid, orderdate, quantity, amount
FROM dbo.orders;

SELECT orderid, custid, orderdate, quantity, amount, (quantity * amount) as total_amount
FROM dbo.orders;

SELECT orderid, custid, orderdate, quantity, amount
FROM dbo.orders
WHERE quantity > 50;

SELECT orderid, custid, orderdate, quantity, amount
FROM dbo.orders
WHERE orderdate < SYSDATETIME();

DECLARE @customerid int = 775

SELECT orderid, custid, orderdate, quantity, amount
FROM dbo.orders
WHERE custid = @customerid;

--  More examples

SELECT *
FROM Sales.Orders;

SELECT * 
FROM Sales.Orders
WHERE custid =71;

-- Querying a table	with an invalid SELECT statement
-- THIS WILL CAUSE AN ERROR DUE TO THE SELECT LIST

SELECT *
FROM Sales.Orders
WHERE custid =71
GROUP BY empid, YEAR(orderdate);

-- Point out that the * in the SELECT list has been 
-- replaced with columns that are either in the GROUP BY expression
-- or are aggregate functions 

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) as numorders
FROM Sales.Orders
WHERE custid =71
GROUP BY empid,YEAR(orderdate);
 
-- Select and run the partial query to show results
-- Point out that a HAVING clause further filters the results
-- based on the groups

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) as numorders
FROM Sales.Orders
WHERE custid =71
GROUP BY empid,YEAR(orderdate)
HAVING COUNT(*) > 1;

-- Point out that the ORDER BY clause further has sorted the results

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) as numorders
FROM Sales.Orders
WHERE custid =71
GROUP BY empid,YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

-- Logical order of T-SQL
	--	5.    SELECT empid, YEAR(orderdate) AS orderyear 
	--	1. FROM Sales.Orders 
	--	2.    WHERE custid =71 
	--	3.    GROUP BY empid, YEAR(orderdate) 
	--	4.    HAVING COUNT(*) > 1 
	--	6.    ORDER BY empid, orderyear; 


SELECT productid, productname, categoryid, unitprice
FROM Production.Products;

-- Note the lack of name for the new calculated column.
SELECT productid, productname, unitprice, (unitprice * 1.1)
FROM Production.Products;

-- Note the name of the calculated column
SELECT orderid, productid, unitprice, qty, (unitprice * qty) as 'Total_Cost_On_Hand'
FROM Sales.OrderDetails;

-- Using distinct
SELECT orderid, custid, shipcity, shipcountry
FROM Sales.Orders;

SELECT DISTINCT orderid, custid, shipcity, shipcountry
FROM Sales.Orders;

-- Column and table aliases

SELECT empid as employeeid, firstname as given, lastname as surname
FROM HR.Employees;

SELECT productid, productname, unitprice, (unitprice * 1.1) as markup
FROM Production.Products;

SELECT empid, lastname as surname, YEAR(hiredate) as yearhired
FROM HR.Employees;

SELECT SO.orderid, SO.orderdate, SO.empid
FROM Sales.Orders as SO;

Select Sales.Orders.OrderID, Sales.Orders.OrderDate, Sales.Orders.EmpID
FROM Sales.Orders

-- Discuss one, two, three, four part queries

-- CASE

SELECT productid, productname, unitprice, 
	CASE discontinued
		WHEN 0 THEN 'Active'
		WHEN 1 THEN 'Discontinued'
		ELSE 'Something'
	END AS status
FROM Production.Products;

-- JOINS

USE TSQL;
GO

--  First off, NOBODY writes queries like this!

SELECT Sales.Customers.companyname, Sales.Orders.orderdate
FROM Sales.Customers, Sales.Orders
WHERE Sales.Customers.custid = Sales.Orders.custid;

-- to illustrate ANSI SQL-92 syntax

SELECT Sales.Customers.companyname, Sales.Orders.orderdate
FROM Sales.Customers JOIN Sales.Orders
ON Sales.Customers.custid = Sales.Orders.custid;

--  Describe table aliases


