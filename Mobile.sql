 Input Values
 
 
	CREATE TABLE DIM_MANUFACTURER
(IDMANUFACTURER INT PRIMARY KEY , 
MANUFACTURER_NAME VARCHAR(20))

CREATE TABLE DIM_MODEL
(IDMODEL INT PRIMARY KEY, 
MODEL_NAME VARCHAR(20), 
UNIT_PRICE MONEY, 
IDMANUFACTURER INT REFERENCES DIM_MANUFACTURER (IDMANUFACTURER))

CREATE TABLE DIM_DATE
(DTE DATE PRIMARY KEY, 
YEAR INT, 
QUATER VARCHAR(20), 
MONTH VARCHAR (20))

CREATE TABLE DIM_CUSTOMER
(IDCUSTOMER INT PRIMARY KEY, 
CUSTOMER_NAME VARCHAR(20), 
EMAIL VARCHAR(100), 
PHONE INT)

CREATE TABLE DIM_LOCATION
(ID_LOCATION INT PRIMARY KEY, 
ZIPCODE INT, 
COUNTRY VARCHAR (20), 
STATE VARCHAR (20), 
CITY VARCHAR (20))

CREATE TABLE FACT_TRANSACTION
(IDMODEL INT REFERENCES DIM_MODEL(IDMODEL), 
IDCUSTOMER INT REFERENCES DIM_CUSTOMER(IDCUSTOMER), 
IDLOCATION INT REFERENCES DIM_LOCATION(ID_LOCATION), 
DTE DATE REFERENCES DIM_DATE(DTE),
TOTALPRICE MONEY,
QUANTITY INT
)

/*********************************/

USE CASE_STUDY

SELECT * FROM DIM_LOCATION
SELECT * FROM DIM_CUSTOMER
SELECT * FROM DIM_DATE
SELECT * FROM DIM_MANUFACTURER
SELECT * FROM DIM_MODEL
SELECT * FROM FACT_TRANSACTION
	
	
	--Q1--BEGIN
	
	
	SELECT STATE
FROM FACT_TRANSACTIONS T1
INNER JOIN DIM_LOCATION T2 ON T1.IDLOCATION= T2.IDLOCATION
INNER JOIN DIM_MODEL T3 ON T1.IDMODEL= T3.IDMODEL
WHERE "DATE" BETWEEN '01-01-2005' AND GETDATE()




--Q1--END

--Q2--BEGIN
	
	

	SELECT TOP 1 STATE FROM DIM_LOCATION
INNER JOIN FACT_TRANSACTIONS ON DIM_LOCATION.IDLOCATION=FACT_TRANSACTIONS.IDLOCATION
INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDMODEL = DIM_MODEL.IDMODEL
INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDMANUFACTURER= DIM_MODEL.IDMANUFACTURER
WHERE MANUFACTURER_NAME = 'Samsung'
GROUP BY STATE
ORDER BY SUM(QUANTITY) DESC
	



--Q2--END

--Q3--BEGIN      
	
	select Model_Name, ZipCode,State, Count(IdCustomer) as No_of_Transactions from DIM_LOCATION 
	inner join FACT_TRANSACTIONS on DIM_LOCATION.IDLocation=FACT_TRANSACTIONS.IDLocation
	inner join DIM_MODEL ON FACT_TRANSACTIONS.IDMODEL=DIM_MODEL.IDModel
	Group by MODEL_NAME, ZIPCODE, STATE

	
		

--Q3--END

--Q4--BEGIN


select TOP 1 Model_Name, Unit_Price,IDModel from DIM_MODEL
ORDER BY (Unit_price) 





--Q4--END

--Q5--BEGIN



 SELECT A.MODEL_NAME, round(AVG(B.TOTALPRICE),2) AS AVERAGE_PRICE 
  FROM DIM_MODEL A LEFT JOIN FACT_TRANSACTIONS B
	ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C
	ON A.IDManufacturer = C.IDManufacturer 
	WHERE C.Manufacturer_Name IN  (
	SELECT TOP 5 (C.Manufacturer_Name) 
    FROM DIM_MODEL A LEFT JOIN FACT_TRANSACTIONS B 
	ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C
	ON A.IDManufacturer = C.IDManufacturer 
	GROUP BY C.Manufacturer_Name
	ORDER BY SUM(B.Quantity) DESC)
	GROUP BY A.Model_Name	
	ORDER BY AVG(B.TOTALPRICE) DESC


--Q5--END

--Q6--BEGIN

select Customer_Name, avg(TotalPrice) as Average_Spent  from FACT_TRANSACTIONS 
inner join DIM_CUSTOMER ON DIM_CUSTOMER.IDCustomer=FACT_TRANSACTIONS.IDCustomer
where year("Date")= 2009
GROUP BY Customer_Name
having avg(TotalPrice)> 500


--Q6--END
	
--Q7--BEGIN  
	

		  SELECT * FROM 
		(SELECT * FROM 
		(SELECT TOP 5 A.Model_Name FROM DIM_MODEL A 
		LEFT JOIN FACT_TRANSACTIONS B
		ON A.IdModel = B.IdModel 
		WHERE YEAR(DATE) = 2008
		GROUP BY A.Model_Name
	    ORDER BY SUM(B.Quantity) DESC)X
   UNION ALL
		SELECT * FROM 
		(SELECT TOP 5 A.Model_Name  FROM DIM_MODEL A
		LEFT JOIN FACT_TRANSACTIONS B
		ON A.IdModel = B.IdModel 
        WHERE YEAR(DATE) = 2009
		GROUP BY A.Model_Name
	    ORDER BY SUM(B.Quantity) DESC)X
  UNION ALL
	    SELECT * FROM 
		(SELECT TOP 5 A.Model_Name   FROM DIM_MODEL A
		LEFT JOIN FACT_TRANSACTIONS B
		ON A.IdModel = B.IdModel 
		WHERE YEAR(DATE) = 2010
		GROUP BY A.Model_Name
		ORDER BY SUM(B.Quantity) DESC)X
		) as tt
		GROUP BY Model_Name
		HAVING COUNT(MODEL_NAME) = 3


--Q7--END	
--Q8--BEGIN


 SELECT DISTINCT(YEAR(C.DATE)) AS YEAR, A.MANUFACTURER_NAME
		FROM DIM_MANUFACTURER A 
		LEFT JOIN DIM_MODEL B
		ON A.IdManufacturer = B.IdManufacturer
	    LEFT JOIN FACT_TRANSACTIONS C
		ON B.IdModel = C.IdModel
		WHERE 
		(YEAR(C.DATE) = 2009 )
	   AND C.TotalPrice =  (SELECT MAX(TotalPrice) 
	   FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2009 AND TotalPrice NOT IN(SELECT MAX(TotalPrice) 
	   FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2009)  )
        OR(YEAR(C.DATE) = 2010) AND C.TotalPrice =  (SELECT MAX(TotalPrice) 
		 FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2010 AND TotalPrice NOT IN(SELECT MAX(TotalPrice) 
		 FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2010)  )


--Q8--END
--Q9--BEGIN
	


SELECT DISTINCT(A.MANUFACTURER_NAME) 
		FROM DIM_MANUFACTURER A 
		INNER JOIN DIM_MODEL B
	   ON A.IdManufacturer = B.IdManufacturer 
		INNER JOIN FACT_TRANSACTIONS C
		ON B.IdModel = C.IdModel
		WHERE YEAR(C.DATE) = 2010 AND YEAR(C.DATE) != 2009


--Q9--END

--Q10--BEGIN
	
   SELECT TOP 100 A.CUSTOMER_NAME 
	,	AVG(CASE WHEN YEAR(B.DATE) = 2003 THEN (B.TOTALPRICE) END) AS AVG_SPENT_2003
	,	AVG(CASE WHEN YEAR(B.DATE) = 2003 THEN (B.QUANTITY) END) AS AVG_QUANTITY_2003
	,	AVG(CASE WHEN YEAR(B.DATE) = 2004 THEN (B.TOTALPRICE) END) AS AVG_SPENT_2004
	,	AVG(CASE WHEN YEAR(B.DATE) = 2004 THEN (B.QUANTITY) END) AS AVG_QUANTITY_2004
	,	AVG(CASE WHEN YEAR(B.DATE) = 2005 THEN (B.TOTALPRICE) END) AS AVG_SPENT_2005
	,	AVG(CASE WHEN YEAR(B.DATE) = 2005 THEN (B.QUANTITY) END) AS AVG_QUANTITY_2005
	,	AVG(CASE WHEN YEAR(B.DATE) = 2006 THEN (B.TOTALPRICE) END) AS AVG_SPENT_2006
	,	AVG(CASE WHEN YEAR(B.DATE) = 2016 THEN (B.QUANTITY) END) AS AVG_QUANTITY_IN_2006
	,	AVG(CASE WHEN YEAR(B.DATE) = 2007 THEN (B.TOTALPRICE) END) AS AVG_SPENT_2007
	,	AVG(CASE WHEN YEAR(B.DATE) = 2007 THEN (B.QUANTITY) END) AS AVG_QUANTITY_2007
	,	AVG(CASE WHEN YEAR(B.DATE) = 2008 THEN (B.TOTALPRICE) END) AS AVG_SPENT_2008
	,	AVG(CASE WHEN YEAR(B.DATE) = 2008 THEN (B.QUANTITY) END) AS AVG_QUANTITY_2008
	,	AVG(CASE WHEN YEAR(B.DATE) = 2009 THEN (B.TOTALPRICE) END) AS AVG_SPENT_2009
	,	AVG(CASE WHEN YEAR(B.DATE) = 2009 THEN (B.QUANTITY) END) AS AVG_QUANTITY_2009
	,	AVG(CASE WHEN YEAR(B.DATE) = 2010 THEN (B.TOTALPRICE) END) AS AVG_SPENT_2010
	,	AVG(CASE WHEN YEAR(B.DATE) = 2010 THEN (B.QUANTITY) END) AS AVG_QUANTITY_2010												
	   FROM DIM_CUSTOMER A 
	   LEFT JOIN FACT_TRANSACTIONS B
	   ON A.IdCustomer = B.IdCustomer
	   GROUP BY  A.CUSTOMER_NAME
	   ORDER BY SUM(B.TOTALPRICE)

--Q10--END
