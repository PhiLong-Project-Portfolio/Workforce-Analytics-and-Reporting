--- EMPLOYEE OVERVIEW
-- Count number of current employees by gender
SELECT 
	Gender,
	COUNT(*)
FROM HumanResources.dbo.Employee
WHERE Termd = 0
GROUP BY Gender

-- Number of employees in each department by gender
SELECT
	Department,
	Gender,
	COUNT(Gender)
FROM HumanResources.dbo.Employee emp
JOIN HumanResources.dbo.Department dept
ON emp.DeptID = dept.DeptID
GROUP BY Department, Gender
ORDER BY 1,2

---- Create Age Group table 
WITH AgeGroupT AS (
	SELECT
		EmpID,
		DOB,
		GETDATE() AS CurrentDate,
		DATEDIFF(YEAR, DOB, GETDATE()) -
		CASE 
			WHEN MONTH(DOB) < MONTH(GETDATE()) AND DAY(DOB) < DAY(GETDATE()) THEN 1 ELSE 0
		END AS Age
	FROM HumanResources.dbo.Employee
	),

AgeCount AS (
SELECT
	CASE 
		WHEN AGE < 25 THEN '< 25'
		WHEN AGE >= 25 AND AGE < 35 THEN '25-35'
		WHEN AGE >= 35 AND AGE < 45 THEN '35-45'
		WHEN AGE >= 45 AND AGE < 55 THEN '45-55'
		ELSE '>55'
	END AS AgeGroup
FROM AgeGroupT
)
SELECT *,
	COUNT(*)
FROM AgeCount
GROUP BY AgeGroup		
ORDER BY 2

-- Avg. Salary 
SELECT 
	ROUND(AVG(Salary),2) AS AvgSalary
FROM HumanResources.dbo.Employee
WHERE Termd = 0

-- Employee Detail
-- Employee Satisfaction and Engagement Score
SELECT 
    ROUND(AVG(EmpSatisfaction),2) AS AvgEmployeeSatisfaction,
	MAX(EmpSatisfaction) AS MaxSatisScore,
    AVG(EngagementSurvey) AS AvgEngagementScore,
	MAX(EngagementSurvey) AS MaxEngageScore
FROM 
    HumanResources.dbo.Employee

-- Retention Rate 
SELECT 
	COUNT(Termd),
	SUM(Termd),
	ROUND((((COUNT(Termd) - SUM(Termd))/COUNT(Termd))*100),2) AS RetentionRate
FROM HumanResources.dbo.Employee

-- Employee leaving from a particular dept
SELECT 
	EmpID,
	DateofHire,
	DateofTermination,
	Department
FROM HumanResources.dbo.Employee emp
JOIN HumanResources.dbo.Department dept
ON emp.DeptID = dept.DeptID
WHERE DateofTermination is not null

-- Count the number of Employee leaving within a specific department
SELECT 
	Department,
	COUNT(EmpID)
FROM HumanResources.dbo.Employee emp
JOIN HumanResources.dbo.Department dept
ON emp.DeptID = dept.DeptID
WHERE DateofTermination is not null
GROUP BY dept.Department


-- Average yearly absenteeism
WITH EmployeeTenure AS (
    SELECT 
        EmpID,
        Absences,
		DateofHire,
		DateofTermination,
		LastPerformanceReview_Date,
		ROUND((DATEDIFF(DAY, DateofHire, LastPerformanceReview_Date) / 365.25),0) AS YearsToLastReview
    FROM 
        HumanResources.dbo.Employee
)
-- Calculate the average yearly absenteeism in days and rate
SELECT 
    ROUND((AVG(Absences / YearsToLastReview)),2) AS AvgYearlyAbsenteeism,
	ROUND(((AVG((Absences / YearsToLastReview))/231)*100),0) AS AbsenteeismRate
FROM 
    EmployeeTenure
WHERE 
    YearsToLastReview > 0 -- Ensure we exclude any erroneous zero values


---- Time To Quit Job
WITH QuitJob AS (
	SELECT 
		EmpID,
		DateofHire,
		DateofTermination,
		CONVERT(INT,(DATEDIFF(DAY, DateofHire, DateofTermination) / 365.25)) AS QuitTime
	FROM HumanResources.dbo.Employee
	WHERE DateofTermination is not null
	)
SELECT 
	QuitTime,
	COUNT(QuitTime)
FROM QuitJob
GROUP BY QuitTime

---- Avg. PerformanceScore
SELECT 
	EmpID,
	emp.PerfScoreID,
	PerformanceScore
FROM HumanResources.dbo.Employee emp
JOIN HumanResources.dbo.Performance pf
ON emp.PerfScoreID = pf.PerfScoreID
ORDER BY 2
