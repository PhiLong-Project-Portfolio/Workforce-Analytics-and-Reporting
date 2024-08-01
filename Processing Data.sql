-- Processing dataset
-- Find duplicate values
SELECT 
	[EmpID], COUNT(*)
FROM HumanResources.dbo.HRDataset
GROUP BY [EmpID]
HAVING COUNT(*) > 1

-- Find missing value

DECLARE @tb nvarchar(512) = N'dbo.[HRDataset]';

DECLARE @sql nvarchar(max) = N'SELECT * FROM ' + @tb
    + N' WHERE 1 = 0';
SELECT @sql += N' OR ' + QUOTENAME(name) + N' IS NULL'
    FROM sys.columns 
    WHERE [object_id] = OBJECT_ID(@tb)
    AND is_nullable = 1;

EXEC sys.sp_executesql @sql;

-- Transform data
ALTER TABLE HumanResources.dbo.HRDataset
ALTER COLUMN DateofHire date

ALTER TABLE HumanResources.dbo.HRDataset
ALTER COLUMN DateofTermination date

ALTER TABLE HumanResources.dbo.HRDataset
ALTER COLUMN LastPerformanceReview_Date date

-- Update data 
UPDATE HumanResources.dbo.HRDataset
SET DeptID = 4
WHERE EmpID = 10131
----
UPDATE HumanResources.dbo.HRDataset
SET DeptID = 5
WHERE EmpID = 10311
----
UPDATE HumanResources.dbo.HRDataset
SET PerfScoreID = 3
WHERE EmpID = 10311
----
UPDATE HumanResources.dbo.HRDataset
SET PerfScoreID = 1
WHERE EmpID = 10305 
----
UPDATE HumanResources.dbo.HRDataset
SET EmpStatusID = 3
WHERE EmpID = 10182 OR EmpID = 10305
--------
UPDATE HumanResources.dbo.HRDataset
SET EmpStatusID = 1
WHERE EmpStatusID = 2
----
UPDATE HumanResources.dbo.HRDataset
SET EmpStatusID = 3
WHERE EmpID = 10305 OR EmpID = 10182  
------
UPDATE HumanResources.dbo.HRDataset
SET EmpStatusID = 1
WHERE EmpStatusID = 3
----
UPDATE HumanResources.dbo.HRDataset
SET EmpStatusID = 2
WHERE EmpStatusID = 4
-----
UPDATE HumanResources.dbo.HRDataset
SET EmpStatusID = 3
WHERE EmpStatusID = 5
------
UPDATE HumanResources.dbo.HRDataset
SET LastPerformanceReview_Date = '2018-08-19'
WHERE EmpID = 10305 

-- Create necessary table
-- Deparment
SELECT
	DeptID,
	Department
INTO HumanResources.dbo.Department 
FROM HumanResources.dbo.HRDataset 
GROUP BY DeptID, Department
ORDER BY 1

-- Marital
SELECT
	MaritalStatusID,
	MaritalDesc
INTO HumanResources.dbo.MaritalStatus 
FROM HumanResources.dbo.HRDataset 
GROUP BY MaritalStatusID, MaritalDesc
ORDER BY 1

-- Performance

SELECT
	PerfScoreID,
	PerformanceScore
INTO HumanResources.dbo.Performance 
FROM HumanResources.dbo.HRDataset 
GROUP BY PerfScoreID, PerformanceScore
ORDER BY 1

-- Gender

SELECT 
	GenderID,
	Sex
INTO HumanResources.dbo.Gender
FROM HumanResources.dbo.HRDataset
GROUP BY GenderID, Sex

-- Employment Status

SELECT 
	EmpStatusID,
	EmploymentStatus
INTO HumanResources.dbo.EmploymentStatus
FROM HumanResources.dbo.HRDataset
GROUP BY EmpStatusID, EmploymentStatus

-- EMployee 

SELECT
	EmpID,
	Employee_Name,
	MarriedID,
	MaritalStatusID,
	EmpStatusID,
	DeptID,
	PerfScoreID,
	FromDiversityJobFairID,
	Sex AS Gender,
	Salary,
	Termd,
	PositionID,
	State,
	Zip,
	DOB,
	CitizenDesc,
	HispanicLatino,
	RaceDesc,
	DateofHire,
	DateofTermination,
	TermReason,
	ManagerID,
	RecruitmentSource,
	EngagementSurvey,
	EmpSatisfaction,
	SpecialProjectsCount,
	LastPerformanceReview_Date,
	DaysLateLast30,
	Absences
INTO HumanResources.dbo.Employee
FROM HumanResources.dbo.HRDataset

-- Manager
SELECT 
	ManagerID,
	ManagerName,
	COUNT(*) AS Num_Employee
INTO HumanResources.dbo.Manager
FROM HumanResources.dbo.HRDataset
GROUP BY ManagerID, ManagerName
ORDER BY 1

-- Employee change

WITH Employ_Change AS(
	SELECT
		EmpID,
		DateofHire AS Date_Time,
		CASE 
			WHEN DateofHire IS NOT NULL THEN 1
		END AS EmpIn,
		CASE 
			WHEN DateofHire IS NOT NULL THEN 0
		END AS EmpOut
	FROM HumanResources.dbo.Employee
	UNION ALL
	SELECT 
		EmpID,
		DateofTermination,
		CASE 
			WHEN DateofTermination IS NOT NULL THEN 0
		END AS EmpIn,
		CASE 
			WHEN DateofHire IS NOT NULL THEN 1
		END AS EmpOut
	FROM HumanResources.dbo.Employee
	WHERE DateofTermination is not null
)
SELECT 
	EmpID,
	Date_Time,
	EmpIn,
	EmpOut,
	SUM(EmpIn - EmpOut) OVER (ORDER BY Date_Time, EmpID) AS NumberOfEmployee,
	SUM(EmpIn) OVER (ORDER BY Date_Time, EmpID) AS Hired_Cumulative
INTO HumanResources.dbo.Employee_Change
FROM Employ_Change
ORDER BY 2


-- Update data in Manager table
UPDATE HumanResources.dbo.Employee
SET ManagerID = 22
WHERE EmpID = 10195

UPDATE HumanResources.dbo.Employee
SET ManagerID = 23
WHERE ManagerID = 39 OR ManagerID is null

-- Set keys and relationships in tables

ALTER TABLE HumanResources.dbo.Employee
ALTER COLUMN EmpID int NOT NULL;

ALTER TABLE HumanResources.dbo.Employee
ADD PRIMARY KEY (EmpID)
----

ALTER TABLE HumanResources.dbo.Department
ALTER COLUMN DeptID int NOT NULL;

ALTER TABLE HumanResources.dbo.Department
ADD PRIMARY KEY (DeptID)
-------

ALTER TABLE HumanResources.dbo.EmploymentStatus
ALTER COLUMN EmpStatusID int NOT NULL;

ALTER TABLE HumanResources.dbo.EmploymentStatus
ADD PRIMARY KEY (EmpStatusID)
-----

ALTER TABLE HumanResources.dbo.MaritalStatus
ALTER COLUMN MaritalStatusID int NOT NULL;

ALTER TABLE HumanResources.dbo.MaritalStatus
ADD PRIMARY KEY (MaritalStatusID)
--------
ALTER TABLE HumanResources.dbo.Performance
ALTER COLUMN PerfScoreID int NOT NULL;

ALTER TABLE HumanResources.dbo.Performance
ADD PRIMARY KEY (PerfScoreID)

-----
ALTER TABLE HumanResources.dbo.Employee
ADD FOREIGN KEY (MaritalStatusID) REFERENCES HumanResources.dbo.MaritalStatus(MaritalStatusID)

-----
ALTER TABLE HumanResources.dbo.Employee
ADD FOREIGN KEY (DeptID) REFERENCES HumanResources.dbo.Department(DeptID)

-----
ALTER TABLE HumanResources.dbo.Employee
ADD FOREIGN KEY (EmpStatusID) REFERENCES HumanResources.dbo.EmploymentStatus(EmpStatusID)
-----

ALTER TABLE HumanResources.dbo.Employee
ADD FOREIGN KEY (PerfScoreID) REFERENCES HumanResources.dbo.Performance(PerfScoreID)

----

ALTER TABLE HumanResources.dbo.Manager
ALTER COLUMN ManagerID int NOT NULL;

ALTER TABLE HumanResources.dbo.Manager
ADD PRIMARY KEY (ManagerID)

ALTER TABLE HumanResources.dbo.Employee
ADD FOREIGN KEY (ManagerID) REFERENCES HumanResources.dbo.Manager(ManagerID)

----

ALTER TABLE HumanResources.dbo.Employee_Change
ADD PRIMARY KEY (EmpID,Date_time)

ALTER TABLE HumanResources.dbo.Employee_Change
ADD FOREIGN KEY (EmpID) REFERENCES HumanResources.dbo.Employee(EmpID)

ALTER TABLE HumanResources.dbo.Employee
ALTER COLUMN EmpID int NOT NULL;

ALTER TABLE HumanResources.dbo.Employee
ADD PRIMARY KEY (EmpID)

ALTER TABLE HumanResources.dbo.Employee_Change
ALTER COLUMN Date_Time date NOT NULL;
