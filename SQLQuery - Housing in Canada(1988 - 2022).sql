SELECT*
FROM Canada_Housing_Units

--Let's clean this up by deleting the columns we don't need

ALTER TABLE Canada_Housing_Units
DROP COLUMN DGUID, SCALAR_FACTOR, VECTOR, COORDINATE

--Change some column names  e.g
--Change the name of the 'VALUE' column to 'Total_Units'

EXEC sp_rename 'Canada_Housing_Units.VALUE', 'Total_Units','Column';
EXEC sp_rename 'Canada_Housing_Units.Housing estimates', 'Housing_estimates','Column';
EXEC sp_rename 'Canada_Housing_Units.Type of unit', 'Housing_Types','Column';
EXEC sp_rename 'Canada_Housing_Units.Province', 'Location','Column';
EXEC sp_rename 'Canada_Housing_Units.REF_DATE', 'Reference_Date','Column';

--Let's also change the date format (Standardize Data Format)

SELECT Reference_Date_Converted, CONVERT(Date, Reference_Date)
FROM Canada_Housing_Units

UPDATE Canada_Housing_Units
SET Reference_Date = CONVERT(Date, Reference_Date)

ALTER TABLE Canada_Housing_Units
ADD Reference_Date_Converted Date;

UPDATE Canada_Housing_Units
SET Reference_Date_Converted = CONVERT(Date, Reference_Date)


-- Now lets work with our clean data

SELECT 
	Reference_Date_Converted, 
	Location, 
	Housing_estimates,
	Housing_Types, 
	Total_Units
FROM Canada_Housing_Units


SELECT DISTINCT Location
FROM Canada_Housing_Units
ORDER BY Location ASC
-- We have 11 locations we are working with.


-- Now let's only select the housing units from only Alberta

SELECT*
FROM Canada_Housing_Units
WHERE Location = 'Alberta'

--Let us select the total units in Alberta where the Total units are over 1000

SELECT*
FROM Canada_Housing_Units
WHERE Location = 'Alberta'
AND Total_Units > 1000
ORDER BY 1,2

-- Let us find the maximum number of units from each location in Canada


SELECT Location, SUM(Total_Units) AS All_Total_Units
FROM Canada_Housing_Units
GROUP BY Location
ORDER BY All_Total_Units DESC

-- This means the total units in Canada since 1988 for all the house types is 133,933,102 however, this counts the total units of house estimates again meaning this would not be the right number if we wanted to know the total units that were completed over each month over the years

SELECT Housing_estimates, SUM(Total_Units) AS Completed_Units
FROM Canada_Housing_Units
WHERE Housing_estimates = 'Housing completions' 
AND Location = 'Canada'
AND Housing_Types = 'Total units'
GROUP BY Housing_estimates

-- The total number of units that were built and completed in Canada since 1988 is 5,020,264


SELECT Reference_Date_Converted, Location, Housing_estimates, Housing_Types, Total_Units
FROM Canada_Housing_Units 
WHERE Housing_estimates = 'Housing completions'
AND Housing_Types = 'Total units'
AND Location = 'Alberta'
ORDER BY Reference_Date_Converted ASC

-- Here we have the total completed units in Alberta since 1988 July

-- Lets find out how many units were built and completed in Alberta since 1988 (Houses built and completed)

SELECT Housing_estimates, SUM(Total_Units) AS Completed_Units
FROM Canada_Housing_Units
WHERE Housing_estimates = 'Housing completions' 
AND Location = 'Alberta'
AND Housing_Types = 'Total units'
GROUP BY Housing_estimates

-- We have 732,426 completed houses/units in Alberta since 1988

-- Say we wanted to find out how many housing units were completed in the year 2000 for each month

SELECT Reference_Date_Converted, Location, Housing_estimates, Housing_Types, Total_Units
FROM Canada_Housing_Units 
WHERE Housing_estimates = 'Housing completions'
AND "Reference_Date_Converted" LIKE '2000%'
AND Housing_Types = 'Total units'
AND Location = 'Alberta'
ORDER BY Reference_Date_Converted ASC

-- What is the total amount of houses built in 2000?

SELECT Housing_estimates, SUM(Total_Units) AS Completed_Units
FROM Canada_Housing_Units
WHERE Housing_estimates = 'Housing completions' 
AND "Reference_Date_Converted" LIKE '2000%'
AND Location = 'Alberta'
AND Housing_Types = 'Total units'
GROUP BY Housing_estimates

--18,971 houses built in Alberta in 2000

SELECT Reference_Date_Converted, Location, Housing_Types, MAX(Total_Units) AS Maximum_Units
FROM Canada_Housing_Units
WHERE Housing_Types = 'Apartment and other units'
AND Location = 'Alberta'
GROUP BY Reference_Date_Converted, Location, Housing_Types
HAVING MAX(Total_Units) > 1500
ORDER BY Reference_Date_Converted ASC

-- Here we see that Apartments and other units over 1500 total in Alberta started in 1993 August

--	Lets play with some subqueries

SELECT Location, Total_Units, 
(
		SELECT AVG(Total_Units)
		FROM Canada_Housing_Units) AS AllAvgUnits
FROM Canada_Housing_Units
ORDER BY Location ASC


SELECT Reference_Date_Converted, Location, Housing_estimates, Total_Units, 
(
		SELECT AVG(Total_Units)
		FROM Canada_Housing_Units 
		WHERE Housing_estimates = 'Housing completions' 
		
)		
FROM Canada_Housing_Units
WHERE Location = 'Alberta'
AND Housing_estimates = 'Housing completions' 

-- Average houses completed is 886

SELECT DISTINCT Location, [Total units], [Single-detached units], [Semi-detached units], [Row units], [Apartment and other units]
FROM
		(SELECT Location, Housing_Types, Total_Units
		FROM Canada_Housing_Units) AS Source_Table
PIVOT
(COUNT(Housing_Types)
FOR
[Housing_Types] IN ( [Total units], [Single-detached units], [Semi-detached units], [Row units], [Apartment and other units]))
AS PIVOT_Table
