-- Student breakdown
-- **Note: The output count is a duplicated count across courses but does control for intracourse duplicates.**
-- ** The ESL team has requested the counts to follow this format **

Use SkywardData;

/******************************************************************************************** 
					Setup of ESL Course Codes and Course Names Temp Table
*********************************************************************************************/
CREATE TABLE #ESLCourses 
	(CourseCode VARCHAR(10) PRIMARY KEY,
	CourseName NVARCHAR(200)); 

INSERT INTO #ESLCourses (CourseCode,CourseName) VALUES
('H1021','ESOL 1'), ('H1113','English 1'), ('H1213','English 2'), ('H1313','English 3'),
('H1413','English 4'),('H7631','ELDA 1 (Newcomers)'),('H7632','ELDA 2 (Newcomers)'),('H1635','Practical Writing'),
('H1641','Academic Literacy'), ('H1642','Academic Literacy'),('H1643','Academic Literacy'),('H1022','ESOL 2'),
('M0975','English 6/SOL'),  ('M0602','ELAR 6'),('M0604','ELAR 6 Honors'),('M0605','ELAR 6 Honors/GT'),('M0702','ELAR 7'),
('M0705','ELAR 7 Honors'), ('M0706' ,'ELAR 7/8 Honors/GT'),('M0802','ELAR 8'),('M0805','ELAR 8 Honors'),
('M0806','ELAR 8 Honors/GT'), ('M0973','English 7/SOL'), ('M0974','English 8/SOL'), ('M0499','Recent/SOL');


/**************************************************************************************************************** 
									    Student Data
*****************************************************************************************************************/ 
SELECT   
    DISTINCT gh.[Student Number],
	sd.[First Name],
	sd.[Last Name],
	sd.Grade,
	en.[Entity Name],
	sd.[State Parental Permission Code],
	sd.[State Years in US Schools Code],
    gh.[Course Code],
	el.CourseName
FROM dbo.[Grade History] gh
LEFT JOIN dbo.SkyDemog sd
    ON gh.[Student Number] = sd.[Student Number]
LEFT JOIN dbo.Entity en
	ON gh.[Entity Code] = en.[Entity Code]
LEFT JOIN #ESLCourses el 
	ON el.CourseCode = gh.[Course Code]
WHERE 
	gh.[Course Code] in ('M0973','M0974','M0975','M0499') AND sd.Active = 'true'
ORDER BY 
    gh.[Student Number]

	
/**************************************************************************************************************** 
						  Counts by Campus x Grades with Subtotals 

	 --This count is a duplicated count across courses but the code does control for intracourse duplicates--
	 
*****************************************************************************************************************/ 

SELECT 
	CASE 
        WHEN GROUPING(Campus) = 1 THEN 'ALL CAMPUSES'
        ELSE Campus
		END AS CampusName,
	COALESCE(Grade,'') AS Grade, 
    COALESCE([Course Description], '') AS [Course Description],
	COALESCE([Course Code], '') AS [Course Code],
	COUNT(CourseCount) AS CourseCount -- This COUNT counts students multiple times if they're found in multiple courses
	FROM 
	(
		SELECT 
			en.[Entity Name] AS Campus,
			sd.grade AS [Grade],
			gh.[Course Description] AS [Course Description],
			gh.[Course Code] AS [Course Code],
			COUNT(DISTINCT gh.[Student Number]) AS CourseCount-- This COUNT(DISTINCT ) ensures a student is only counted once per course
		FROM dbo.[Grade History] gh
		LEFT JOIN dbo.Entity en 
			ON en.[Entity Code] = gh.[Entity Code]
		LEFT JOIN dbo.SkyDemog sd
			ON gh.[Student Number] = sd.[Student Number]
		WHERE gh.[Course Code] IN ('M0973','M0974','M0975','M0499') AND sd.Active = 'true'
		GROUP BY gh.[Student Number],en.[Entity Name], gh.[Course Description], gh.[Course Code],sd.Grade 
	  ) eslcounts
GROUP BY GROUPING SETS 
(
	(Campus,Grade,[Course Description],[Course Code]),			-- this grouping is for detail rows
	(Campus),													-- this grouping gives us subtotals by campus
	()															-- this grouping gives us grand total at the very bottom
)
ORDER BY
	CASE WHEN GROUPING(Campus) = 1 THEN 1 ELSE 0 END ASC, -- put grand total last
	CampusName,
	Grade;

--Clean up

Drop table #ESLCourses
