--exploring sales person in ech territoer


SELECT DISTINCT
	ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name, 
	SalesPersonID
FROM Sales.SalesTerritory  ST
JOIN Sales.SalesOrderHeader  soh 
ON 
	ST.TerritoryID=soh.TerritoryID
JOIN 
	Sales.SalesPerson  spr
ON 
	soh.SalesPersonID =spr.BusinessEntityID
JOIN 
	Person.Person  pp
ON 
	spr.BusinessEntityID=pp.BusinessEntityID
WHERE  pp.PersonType='SP'
group by ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName),
	SalesPersonID
order by SalesPersonID
--- then how many sales sp




SELECT DISTINCT CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	     
FROM 
	Sales.SalesPerson  spr

JOIN 
	Person.Person  pp
	on spr.BusinessEntityID=pp.BusinessEntityID

WHERE  pp.PersonType='SP'



--so i have 17 sale person







SELECT DISTINCT
	ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name, 
	SalesPersonID,--COUNT(CONCAT(FirstName,' ',MiddleName,' ',LastName)) over (partition by salespersonid order by salespersonid ) count_person_in_defernt_area,
	sum(TotalDue) total_person_in_each_terr
	--,sum(sum(TotalDue)) over(partition by salespersonid order by sum(TotalDue ) desc) runinig_total
	--,rank() over ( partition by salespersonid order by sum(TotalDue )) ordering
FROM Sales.SalesTerritory  ST
JOIN Sales.SalesOrderHeader  soh 
ON 
	ST.TerritoryID=soh.TerritoryID
JOIN 
	Sales.SalesPerson  spr
ON 
	soh.SalesPersonID =spr.BusinessEntityID
JOIN 
	Person.Person  pp
ON 
	spr.BusinessEntityID=pp.BusinessEntityID
WHERE  pp.PersonType='SP'
group by ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName),
	SalesPersonID,soh.TerritoryID
	order by SalesPersonID


















-- are the same person when he work in malti territory affect on salary?

with total as(
SELECT DISTINCT
	ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name, 
	SalesPersonID,COUNT(CONCAT(FirstName,' ',MiddleName,' ',LastName)) over (partition by salespersonid order by salespersonid ) count_person_in_defernt_area,
	sum(TotalDue) total_person_in_each_terr ,sum(sum(TotalDue)) over(partition by salespersonid order by sum(TotalDue ) desc) total_revenue,
	rank() over ( partition by salespersonid order by sum(TotalDue )) ordering
FROM Sales.SalesTerritory  ST
JOIN Sales.SalesOrderHeader  soh 
ON 
	ST.TerritoryID=soh.TerritoryID
JOIN 
	Sales.SalesPerson  spr
ON 
	soh.SalesPersonID =spr.BusinessEntityID
JOIN 
	Person.Person  pp
ON 
	spr.BusinessEntityID=pp.BusinessEntityID
WHERE  pp.PersonType='SP'
group by ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName),
	SalesPersonID,soh.TerritoryID

)
select Sales_Person_Name,SalesPersonID,count_person_in_defernt_area,total_revenue

from total
where ordering = 1
order by total_revenue desc


-- Conclusion 1 : The person with the id of 276 is the highest in terms of the revenue , also we must say that he works in multiple territories

-- Answer to the previous Question : Because their exists a sales person who work in 1 territory and makes sales higher than another person who work in 6 territory


----------------------------------------------------------------------------------------------------------
-- select person where revenue <1000000
with total as(
SELECT DISTINCT
	ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name, 
	SalesPersonID,COUNT(CONCAT(FirstName,' ',MiddleName,' ',LastName)) over (partition by salespersonid order by salespersonid ) count_person_in_defernt_area,
	sum(TotalDue) total_person_in_each_terr ,sum(sum(TotalDue)) over(partition by salespersonid order by sum(TotalDue ) desc) runinig_total,
	rank() over ( partition by salespersonid order by sum(TotalDue )) ordering
FROM Sales.SalesTerritory  ST
JOIN Sales.SalesOrderHeader  soh 
ON 
	ST.TerritoryID=soh.TerritoryID
JOIN 
	Sales.SalesPerson  spr
ON 
	soh.SalesPersonID =spr.BusinessEntityID
JOIN 
	Person.Person  pp
ON 
	spr.BusinessEntityID=pp.BusinessEntityID
WHERE  pp.PersonType='SP'
group by ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName),
	SalesPersonID,soh.TerritoryID

)
select Sales_Person_Name,SalesPersonID,count_person_in_defernt_area,runinig_total

from total
where ordering=1 and runinig_total<1000000
order by SalesPersonID,runinig_total desc

-- so i have tow person who msde less than 1000000

-- i will search for hire date




SELECT 
    CONCAT(FirstName,' ',MiddleName,' ',LastName)  Sales_Person_Name
	,HireDate
FROM  
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID=EMP.BusinessEntityID
WHERE 
    PER.PersonType='SP' AND CONCAT(FirstName,' ',MiddleName,' ',LastName) in ('Syed E Abbas','Amy E Alberts')-- and CONCAT(FirstName,' ',MiddleName,' ',LastName)='Amy E Alberts'

	-- so sayed work since 2013-03-14
	-- while el madam Amy E Alberts  since 2012-04-16

-- FOLLOW UP QUESTION : Does the years of experience make the differnece in terms of the revenue

--  ther exist Ranjit R Varkey Chudukatil	2012-05-30	12	5087977.212  while el madam Amy E Alberts  since 2012-04-16
			
			
SELECT distinct 
    CONCAT(FirstName,' ',MiddleName,' ',LastName)  Sales_Person_Name
	,HireDate,DATEDIFF(year,HireDate,GETDATE()) age,sum(TotalDue) tot
FROM  
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID=EMP.BusinessEntityID
	join Sales.SalesOrderHeader soh
	on SPR.BusinessEntityID=soh.SalesPersonID
WHERE 
    PER.PersonType='SP'
	group by  CONCAT(FirstName,' ',MiddleName,' ',LastName)  
	,HireDate,DATEDIFF(year,HireDate,GETDATE())
	order by tot desc
	------------------------------------------------------------------------------------------------------
	-- FOLLOW UP QUESTION : find threshld for each person i need avg for sales to determin threshold 
	-- then filter person 
	--not completed
	
			
SELECT distinct YEAR(OrderDate),
    SalesPersonID,CONCAT(FirstName,' ',MiddleName,' ',LastName)  Sales_Person_Name
,DATEDIFF(year,HireDate,GETDATE()) age,sum(TotalDue) tot,month (OrderDate)
FROM  
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID=EMP.BusinessEntityID
	join Sales.SalesOrderHeader soh
	on SPR.BusinessEntityID=soh.SalesPersonID
WHERE 
    PER.PersonType='SP'
	group by  CONCAT(FirstName,' ',MiddleName,' ',LastName)  
	,HireDate,DATEDIFF(year,HireDate,GETDATE()),month(orderdate),SalesPersonID,year(OrderDate)
	order by SalesPersonID,YEAR(OrderDate)
	----------------------------------


--  then gender and explore


select distinct Gender ,  CONCAT(pp.FirstName , pp.MiddleName , pp.LastName) namm 

from Sales.SalesOrderHeader soh 
join 
   Person.person pp
on
soh.SalesPersonID = pp.BusinessEntityID
join 
    HumanResources.Employee he
on 
   he.BusinessEntityID = pp.BusinessEntityID
group by CONCAT(pp.FirstName , pp.MiddleName , pp.LastName) , soh.TerritoryID ,gender
order by Gender



--- 7 f and 10 m
------------------------------------------------------------------------------------------------------
-- running for each geander
--for female 40866028.0777
-- for male  49909418.9154
with gend as(
select distinct Gender ,  CONCAT(pp.FirstName , pp.MiddleName , pp.LastName) namm ,sum(soh.TotalDue) total 
,sum( sum(soh.TotalDue)) over (partition by gender order by   sum(soh.TotalDue)desc ) running,
rank() over(partition by gender order by sum(soh.TotalDue)) ordering

from Sales.SalesOrderHeader soh 
join 
   Person.person pp
on
soh.SalesPersonID = pp.BusinessEntityID
join 
    HumanResources.Employee he
on 
   he.BusinessEntityID = pp.BusinessEntityID
group by CONCAT(pp.FirstName , pp.MiddleName , pp.LastName) , soh.TerritoryID ,gender
--order by Gender

)
select Gender, running
from gend
where ordering= 1
order by running desc

------------------------------------------------------------------------------------------------------

--Exploring Employee Demographics

SELECT DISTINCT
	
	CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,Gender,MaritalStatus

FROM Sales.SalesTerritory  sst

JOIN Sales.SalesOrderHeader  soh 

ON sst.TerritoryID=soh.TerritoryID

JOIN Sales.SalesPerson ssp

ON soh.SalesPersonID =ssp.BusinessEntityID

JOIN Person.Person pp

ON ssp.BusinessEntityID=pp.BusinessEntityID

JOIN HumanResources.Employee  EMP
ON pp.BusinessEntityID =EMP.BusinessEntityID
WHERE  pp.PersonType='SP'
order by Gender,MaritalStatus
------------------------------------------------------------------------------------------------------







--running salesperson based on martial statuse?
-- for single 38530705.4924
--for married 52244741.5007
with cte as(
SELECT DISTINCT
	CONCAT(FirstName,' ',MiddleName,' ',LastName)  Sales_Person_Name
	,Gender as gender,MaritalStatus as martial,sum(soh.TotalDue) total,sum(sum(soh.TotalDue)) over ( partition by MaritalStatus order by sum(soh.totaldue) desc ) runing_martial
	, rank() over (partition by MaritalStatus order by sum(soh.totaldue)) ordering
FROM Sales.SalesTerritory  sst

JOIN Sales.SalesOrderHeader  soh 

ON sst.TerritoryID=soh.TerritoryID

JOIN Sales.SalesPerson ssp

ON soh.SalesPersonID =ssp.BusinessEntityID

JOIN Person.Person pp

ON ssp.BusinessEntityID=pp.BusinessEntityID

JOIN HumanResources.Employee  EMP
ON pp.BusinessEntityID =EMP.BusinessEntityID

WHERE  pp.PersonType='SP'
group by
	CONCAT(FirstName,' ',MiddleName,' ',LastName)  
	,Gender,MaritalStatus 
	
)
select martial,runing_martial
from cte
where ordering=1
order by martial;
	------------------------------------------------------------------------------------------------------


	--running salesperson based on martial statuse and gender 
	 --3 women marieed 22106561.4749
	 -- 4 women single 18759466.6028
	 -- 7 men married 30138180.0258
	 -- 3 men single 19771238.8896
	 with cte2 as(
	SELECT DISTINCT
	
	CONCAT(FirstName,' ',MiddleName,' ',LastName)  Sales_Person_Name
	,Gender gender,MaritalStatus martial,sum(soh.TotalDue) total,
	sum(sum(soh.TotalDue)) over ( partition by MaritalStatus,gender order by sum(soh.totaldue)desc) runing_for_ech_category
	,rank() over (partition by  MaritalStatus,gender order by sum(soh.totaldue) ) ordering

FROM Sales.SalesTerritory  sst

JOIN Sales.SalesOrderHeader  soh 

ON sst.TerritoryID=soh.TerritoryID

JOIN Sales.SalesPerson ssp

ON soh.SalesPersonID =ssp.BusinessEntityID

JOIN Person.Person pp

ON ssp.BusinessEntityID=pp.BusinessEntityID

JOIN HumanResources.Employee  EMP
ON pp.BusinessEntityID =EMP.BusinessEntityID

WHERE  pp.PersonType='SP'
group by 
	CONCAT(FirstName,' ',MiddleName,' ',LastName)  
	,Gender,MaritalStatus 
	)
	select gender,martial,runing_for_ech_category
	from cte2
	where ordering=1

	--------------------------------------------------------------------------------------------------------------------

  -- best sales person in each territorey 
  with perrson as(
  select   distinct soh.SalesPersonID id,CONCAT(FirstName,MiddleName,LastName) nam,soh.TerritoryID  terr,
  DATEDIFF(year,BirthDate,GETDATE()) age ,sum(soh.TotalDue) total,
  rank() over(partition by territoryid order by sum(totaldue) desc) ran
from Sales.SalesOrderHeader soh join Person.person pp
on soh.SalesPersonID = pp.BusinessEntityID
join HumanResources.Employee hr
on hr.BusinessEntityID=pp.BusinessEntityID
group by  soh.SalesPersonID,CONCAT(FirstName,MiddleName,LastName),soh.TerritoryID ,DATEDIFF(year,BirthDate,GETDATE())
--order by soh.TerritoryID

)

select  id,nam,terr,age  , CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS AgeGroup, total,ran
from perrson
where ran = 1
order by terr  




---------------------------------------------------------------------------------------------------------------------------------
  -- best sales person in eeach territorey based on age and best product they sold and profit

  -- NEEEEEEEEEEEEEEDS REVISION

  with perrson as(
  select  distinct prp.name nameproduct, soh.SalesPersonID,CONCAT(FirstName,MiddleName,LastName) nam,soh.TerritoryID,

  SUM(sod.OrderQty * sod.UnitPrice) - SUM(sod.OrderQty * prp.StandardCost) AS Profit ,

  DATEDIFF(year,BirthDate,GETDATE()) age ,sum(soh.TotalDue) total, 
  SUM(sod.OrderQty * pch.StandardCost) AS TotalCost
  ,ROW_NUMBER() over(partition by soh.territoryid order by sum(totaldue) desc) ran
from Sales.SalesOrderHeader soh join Person.person pp
on soh.SalesPersonID = pp.BusinessEntityID
join HumanResources.Employee hr
on hr.BusinessEntityID=pp.BusinessEntityID
join Sales.SalesOrderDetail sod on sod.SalesOrderID =soh.SalesOrderID 
join Production.Product prp
on prp.ProductID=sod.ProductID
join
	Production.ProductCostHistory AS pch ON sod.ProductID = pch.ProductID

group by  soh.SalesPersonID,CONCAT(FirstName,MiddleName,LastName),
soh.TerritoryID ,DATEDIFF(year,BirthDate,GETDATE()), prp.name
--order by soh.TerritoryID

)

select nameproduct, SalesPersonID ,nam,age, CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS AgeGroup,TerritoryID,TotalCost , total,Profit,ran 
from perrson
where ran = 1
order by TerritoryID

--------------------------------------------------------

--For Each Sales Person What is the lastyearly sales
-- from thes query StephenYJiang and TeteAMensa-Annan and SyedEAbbas are null value for last yer why?
select pp.BusinessEntityID,concat(FirstName,MiddleName,LastName),SalesLastYear, (select sum(TotalDue)     from sales.salesorderheader) total_sales
, SalesLastYear / ((select sum(TotalDue)     from sales.salesorderheader) - SalesLastYear) *100  persenteg_last_year_depend_on_all_sales
from  Person.person pp

join sales.salesperson ssp
on ssp.BusinessEntityID = pp.BusinessEntityID



----------------------------------------------------------------------------------

--we should modify 274 = Stephen Y Jiang SalesLastYear Column in SalesPerson to 201288.5196
--we should modify 284 = Tete A Mensa-Annan SalesLastYear Column in SalesPerson to 677044.7791

--we should modify 285 = Syed E Abbas SalesLastYear Column in SalesPerson to 23922.192
-- so we tray 274   284 285
SELECT 
	ST.TerritoryID,ST.Name,SPR.BusinessEntityID
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,SUM(TotalDue) LastYearSales,year(OrderDate),
	sum(SUM(TotalDue)) over ( partition by SPR.BusinessEntityID  order by  SUM(TotalDue) )  runing_last_year
FROM Sales.SalesTerritory	ST 
JOIN 
	Sales.SalesOrderHeader  SOD 
ON 
	ST.TerritoryID = SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	  PER.PersonType='SP' AND SPR.BusinessEntityID=274 and year(OrderDate)=2014
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName),YEAR(OrderDate),SPR.BusinessEntityID


	--230173.8472    2944351.9886

	-------------------------------------------------------------------
	 --runing for all year for each salesperson
	 SELECT 
	ST.TerritoryID td,ST.Name nam,SPR.BusinessEntityID busines
	,CONCAT(FirstName,' ',MiddleName,' ',LastName)  Sales_Person_Name
	,SUM(TotalDue) total,year(OrderDate) yer,
	sum(SUM(TotalDue)) over ( partition by SPR.BusinessEntityID  order by  SUM(TotalDue) desc ) as runing_for_all_year
FROM Sales.SalesTerritory	ST 
JOIN 
	Sales.SalesOrderHeader  SOD 
ON 
	ST.TerritoryID = SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	  PER.PersonType='SP' 
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName),YEAR(OrderDate),SPR.BusinessEntityID


	-- Just for exploring the data even more






	--the last value in runing for all year for each salesperson

with nmr as (
	SELECT 
	ST.TerritoryID terr_id,ST.Name nam,SPR.BusinessEntityID busines
	,CONCAT(FirstName,' ',MiddleName,' ',LastName)  Sales_Person_Name
	,SUM(TotalDue) total,year(OrderDate) yer,
	sum(SUM(TotalDue)) over ( partition by SPR.BusinessEntityID  order by  SUM(TotalDue) desc ) as runing_for_all_year
FROM Sales.SalesTerritory	ST 
JOIN 
	Sales.SalesOrderHeader  SOD 
ON 
	ST.TerritoryID = SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	  PER.PersonType='SP' 
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName),YEAR(OrderDate),SPR.BusinessEntityID
	)
	
	select terr_id,nam, busines ,total ,runing_for_all_year,
	
	
	LAST_VALUE(runing_for_all_year) OVER (
        PARTITION BY busines 
        ORDER BY SUM(total) desc
        ROWS BETWEEN current row AND UNBOUNDED FOLLOWING

    ) as last_value

from nmr
group by total, busines,runing_for_all_year,terr_id,nam


-- Just for exploring the data even more


--"I want to get the first sales for each person in their first year 
--and then their sales rate for the first year they worked. Additionally, 
I 
--want to calculate the percentage difference between the current year and the previous year."



-- 1:  hire date


SELECT SalesPersonID ,
    CONCAT(FirstName,' ',MiddleName,' ',LastName)  Sales_Person_Name
	,year(HireDate),SUM(TotalDue)
FROM  
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID=EMP.BusinessEntityID
	join Sales.SalesOrderHeader soh
	on  soh.SalesPersonID = SPR.BusinessEntityID
WHERE 
    PER.PersonType='SP'
group by   CONCAT(FirstName,' ',MiddleName,' ',LastName)  
	,year(HireDate),SalesPersonID
	
	

	-- sum sales for each year and  growth rate precenteg from first yer 
with cte2 as(

	select year(OrderDate) yer,SalesPersonID sp,
	sum(sum(TotalDue)) over (partition by salespersonid,year(orderdate) order by sum(totaldue)) running,
	rank() over(partition by salespersonid ,year(orderdate) order by sum(totaldue)desc) ordering
	
	FROM  
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID=EMP.BusinessEntityID
	join Sales.SalesOrderHeader soh
	on  soh.SalesPersonID = SPR.BusinessEntityID
WHERE 
    PER.PersonType='SP' 
	group by TotalDue,SalesPersonID,year(OrderDate)
	
	)
	select yer , sp,running,FIRST_VALUE(running) over(partition by sp order by running ) first_year
	, running/FIRST_VALUE(running) over(partition by sp order by running ) 
	from cte2
	where ordering=1
	order by sp,yer;
	-------------------------------------------------------------------------

-- difrent btween the currunt year and previec
-- neeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeds modifications (ERROR CHECKING)


		with cte5 as(

	select year(OrderDate) yer,SalesPersonID sp,
	sum(sum(TotalDue)) over (partition by salespersonid,year(orderdate) order by sum(totaldue)) running
	,rank() over(partition by salespersonid ,year(orderdate) order by sum(totaldue)desc) ordering
	
	FROM  
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID=EMP.BusinessEntityID
	join Sales.SalesOrderHeader soh
	on  soh.SalesPersonID = SPR.BusinessEntityID
WHERE 
    PER.PersonType='SP' 
	group by TotalDue,SalesPersonID,year(OrderDate)
	
	)
	select yer , sp,running,LAG(running,1) over(partition by sp order by yer )
	,running - LAG(running,1) over(partition by sp order by running)
	from cte5
	where ordering=1
	order by sp,yer;

	--runing for each sals person
with cte3 as(
	select year(OrderDate) yer,SalesPersonID sp,
	sum(sum(TotalDue)) over (partition by salespersonid order by sum(totaldue)) running______
	,rank() over(partition by salespersonid order by sum(totaldue)desc) ordering
	FROM  
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID=EMP.BusinessEntityID
	join Sales.SalesOrderHeader soh
	on  soh.SalesPersonID = SPR.BusinessEntityID
WHERE 
    PER.PersonType='SP' 
	group by TotalDue,SalesPersonID,year(OrderDate)
	--order by SalesPersonID,yer
)
select running______,sp
from cte3
where ordering=1
order by sp
