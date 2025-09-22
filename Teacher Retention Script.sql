--Teacher Retention Code 
-- al

-- Set cohort year 
DECLARE @BaseHireYear INT = 2023; 

-- Manually set the last available school year in your system
-- i.e. If we have Employee_2024_2025 but NOT Employee_2025_2026, set it to 2024
DECLARE @MaxSchoolYear INT = 2024;  

-- Checks for whether 1yr and 2yr retention are possible
DECLARE @IncludeYr1 BIT = CASE WHEN @BaseHireYear + 1 <= @MaxSchoolYear THEN 1 ELSE 0 END;
DECLARE @IncludeYr2 BIT = CASE WHEN @BaseHireYear + 2 <= @MaxSchoolYear THEN 1 ELSE 0 END;

-- Database for cohort year
DECLARE @StartDB SYSNAME = QUOTENAME('Employee_' + CAST(@BaseHireYear AS VARCHAR(4)) + '_' + CAST(@BaseHireYear + 1 AS VARCHAR(4)));

-- ======================================
-- Create temp tables
-- ======================================
CREATE TABLE #Cohort (
    EmployeeID INT,
    HIRE_DATE DATE,
    TERDATE DATE,
    JOBCODE_01 VARCHAR(10),
    CAMPUS VARCHAR(10)
);

CREATE TABLE #Yr1 (
    EmployeeID INT,
    HIRE_DATE DATE,
    TERDATE DATE,
    JOBCODE_01 VARCHAR(10),
    CAMPUS VARCHAR(10)
);

CREATE TABLE #Yr2 (
    EmployeeID INT,
    HIRE_DATE DATE,
    TERDATE DATE,
    JOBCODE_01 VARCHAR(10),
    CAMPUS VARCHAR(10)
);


CREATE TABLE #CampusLookup (
    CampusCode VARCHAR(10) PRIMARY KEY,
    CampusName NVARCHAR(200),
	CampusType VARCHAR(10)
);

INSERT INTO #CampusLookup (CampusCode, CampusName,CampusType) VALUES
('001','LEE H S', 'HS'),('002','MACARTHUR H S','HS'),('003','CHURCHILL H S','HS'),
('004','ROOSEVELT H S','HS'),('','',''),('005','MADISON H S','HS'),('007','REAGAN H S','HS'),
('008','ACADEMY OF CREATIVE ED','HS'),('009','INTERNATIONAL SCHOOL OF THE AMERICAS','HS'),
('012','ALTER H S','AL'),('014','JOHNSON H S','HS'),('026','CTEC','HS'),('041','EISENHOWER MIDDLE', 'MS'),
('042','GARNER MIDDLE','MS'),('043','KRUEGER MIDDLE','MS'),('044','NIMITZ MIDDLE','MS'),
('045','JACKSON MIDDLE','MS'),('046','ED WHITE MIDDLE','MS'),('047','WOOD MIDDLE','MS'),
('048','BRADLEY MIDDLE','MS'),('049','DRISCOLL MIDDLE','MS'),('050','BUSH MIDDLE','MS'),
('053','ALTERNATIVE CENTER MS','AL'),('056','TEJEDA MIDDLE','MS'),('057','LOPEZ MIDDLE','MS'),
('058','HARRIS MIDDLE','MS'),('059','HILL MIDDLE','MS'),('101','CASTLE HILLS EL','EL'),
('102','COKER EL','EL'),('103','COLONIAL HILLS EL','EL'),('104','DELLVIEW EL','EL'),
('105','EAST TERRELL HILLS EL','EL'),('106','HARMONY HILLS EL','EL'),('107','JACKSON-KELLER EL','EL'),
('108','LARKSPUR EL','EL'),('109','NORTHWOOD EL','EL'),('110','OAK GROVE EL','EL'),
('111','OLMOS EL','EL'),('112','RIDGEVIEW EL','EL'),('113','SERNA EL','EL'),('114','WALZEM EL','EL'),
('115','WEST AVENUE','EL'),('116','WILSHIRE EL','EL'),('117','WINDCREST EL','EL'),
('118','CAMELOT EL','EL'),('119','CLEAR SPRING EL','EL'),('120','REGENCY PLACE EL','EL'),
('121','EL DORADO EL','EL'),('122','MONTGOMERY EL','EL'),('123','HIDDEN FOREST EL','EL'),
('124','WOODSTONE EL','EL'),('125','STAHL EL','EL'),('126','THOUSAND OAKS EL','EL'),
('127','NORTHERN HILLS EL','EL'),('128','REDLAND OAKS EL','EL'),('129','ENCINO PARK EL','EL'),
('130','FOX RUN EL','EL'),('131','OAK MEADOW EL','EL'),('133','STONE OAK EL','EL'),
('134','LONGS CREEK EL','EL'),('135','HUEBNER EL','EL'),('136','HARDY OAK EL','EL'),
('137','WETMORE EL','EL'),('138','ROYAL RIDGE EL','EL'),('139','ROAN FOREST EL','EL'),
('140','CANYON RIDGE EL','EL'),('141','STEUBING RANCH EL','EL'),('142','BULVERDE CREEK EL','EL'),
('143','WILDERNESS OAK EL','EL'),('144','TUSCANY HEIGHTS EL','EL'),('145','CIBOLO GREEN EL','EL'),
('146','LAS LOMAS EL','EL'),('147','VINEYARD RANCH EL','EL'),('148','PRE-K ACADEMY AT WEST AVENUE','EL'),
('160','ALTERNATIVE EL','AL'),('410','iCSI','HS'),('406','ROOSEVELT H S','HS');

-- ======================================
-- Populate Cohort
-- ======================================
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'
INSERT INTO #Cohort
SELECT EmployeeID, HIRE_DATE, TERDATE, JOBCODE_01, CAMPUS
FROM ' + @StartDB + '.dbo.Employees
WHERE JOBCODE_01 IN (''1000'',''1001'',''1002'',''1003'',''1004'',''1005'',
                     ''1006'',''1007'',''1008'',''1009'',''2046'')
  AND DATEPART(yy, HIRE_DATE) = ' + CAST(@BaseHireYear AS NVARCHAR(4));
EXEC(@sql);

-- Year 1 data only if available
IF @IncludeYr1 = 1
BEGIN
    DECLARE @Yr1DB SYSNAME = QUOTENAME('Employee_' + CAST(@BaseHireYear + 1 AS VARCHAR(4)) 
                                      + '_' + CAST(@BaseHireYear + 2 AS VARCHAR(4)));

    SET @sql = N'
    INSERT INTO #Yr1
    SELECT EmployeeID, HIRE_DATE, TERDATE, JOBCODE_01, CAMPUS
    FROM ' + @Yr1DB + '.dbo.Employees
    WHERE JOBCODE_01 IN (''1000'',''1001'',''1002'',''1003'',''1004'',''1005'',
                         ''1006'',''1007'',''1008'',''1009'',''2046'')';
    EXEC(@sql);
END;

-- Year 2 data only if available
IF @IncludeYr2 = 1
BEGIN
    DECLARE @Yr2DB SYSNAME = QUOTENAME('Employee_' + CAST(@BaseHireYear + 2 AS VARCHAR(4)) 
                                      + '_' + CAST(@BaseHireYear + 3 AS VARCHAR(4)));

    SET @sql = N'
    INSERT INTO #Yr2
    SELECT EmployeeID, HIRE_DATE, TERDATE, JOBCODE_01, CAMPUS
    FROM ' + @Yr2DB + '.dbo.Employees
    WHERE JOBCODE_01 IN (''1000'',''1001'',''1002'',''1003'',''1004'',''1005'',
                         ''1006'',''1007'',''1008'',''1009'',''2046'')';
    EXEC(@sql);
END;

-- ======================================
-- Per-Teacher Detail
-- ======================================
SELECT 
    c.EmployeeID,
    c.HIRE_DATE,
    c.TERDATE AS Cohort_TERDATE,
    CASE WHEN c.TERDATE IS NULL THEN 1 ELSE 0 END AS [0 Year Retained],
    CASE WHEN @IncludeYr1 = 1 
         THEN CASE WHEN y1.EmployeeID IS NOT NULL AND (y1.TERDATE IS NULL) THEN 1 ELSE 0 END
         ELSE NULL END AS [1 Year Retained],
    CASE WHEN @IncludeYr2 = 1 
         THEN CASE WHEN y2.EmployeeID IS NOT NULL AND (y2.TERDATE IS NULL) THEN 1 ELSE 0 END
         ELSE NULL END AS [2 Year Retained],
	cl.CampusCode,
	cl.CampusType
FROM #Cohort c
LEFT JOIN #Yr1 y1 ON c.EmployeeID = y1.EmployeeID
LEFT JOIN #Yr2 y2 ON c.EmployeeID = y2.EmployeeID
LEFT JOIN #CampusLookup cl on c.CAMPUS = cl.CampusCode;

-- ======================================
-- Summary
-- ======================================
SELECT
    COUNT(c.EmployeeID) AS CohortCount,
    SUM(CASE WHEN c.TERDATE IS NULL THEN 1 ELSE 0 END) AS [0 Year Retained],
    CASE WHEN @IncludeYr1 = 1 THEN SUM(CASE WHEN y1.EmployeeID IS NOT NULL AND (y1.TERDATE IS NULL) THEN 1 ELSE 0 END) END AS [1 Year Retained],
    CASE WHEN @IncludeYr2 = 1 THEN SUM(CASE WHEN y2.EmployeeID IS NOT NULL AND (y2.TERDATE IS NULL) THEN 1 ELSE 0 END) END AS [2 Year Retained]
FROM #Cohort c
LEFT JOIN #Yr1 y1 ON c.EmployeeID = y1.EmployeeID
LEFT JOIN #Yr2 y2 ON c.EmployeeID = y2.EmployeeID;


-- ======================================
-- Per School Type
-- ======================================
SELECT
	cl.CampusType,
    COUNT(c.EmployeeID) AS CohortCount,
    SUM(CASE WHEN c.TERDATE IS NULL THEN 1 ELSE 0 END) AS [0 Year Retained],
    CASE WHEN @IncludeYr1 = 1 THEN SUM(CASE WHEN y1.EmployeeID IS NOT NULL AND (y1.TERDATE IS NULL) THEN 1 ELSE 0 END) END AS [1 Year Retained],
    CASE WHEN @IncludeYr2 = 1 THEN SUM(CASE WHEN y2.EmployeeID IS NOT NULL AND (y2.TERDATE IS NULL) THEN 1 ELSE 0 END) END AS [2 Year Retained]
FROM #Cohort c
LEFT JOIN #Yr1 y1 ON c.EmployeeID = y1.EmployeeID
LEFT JOIN #Yr2 y2 ON c.EmployeeID = y2.EmployeeID
LEFT JOIN #CampusLookup cl on c.CAMPUS = cl.CampusCode
group by cl.CampusType;



-- Cleanup 
DROP TABLE #Cohort;
DROP TABLE #Yr1;
DROP TABLE #Yr2;
Drop TABLE #CampusLookup;