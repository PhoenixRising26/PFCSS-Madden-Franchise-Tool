/* MADDEN 26 PFC-SS PITTSBURGH STEELERS */
USE PFCSS;



/* CREATE VARIABLES */
DECLARE @MyTeam NVARCHAR(50) = 'Steelers'; 
DECLARE @CurrentAdjustedCap MONEY = 339000000;




SELECT 
	cleanName AS 'Player Name', 
	position AS 'Position', 
	age AS 'Age', 
	playerBestOvr AS 'Overall Grade', 
	teamSchemeOvr AS 'Team Scheme Overall', 
	CASE devTrait
		WHEN 0 THEN 'Normal'
		WHEN 1 THEN 'Star'
		WHEN 2 THEN 'SuperStar'
		WHEN 3 THEN 'X-Factor'
	END AS 'Development Trait', 
	contractLength AS 'Contract Length', 
	contractYearsLeft AS 'Years Remaining', 
	CAST(contractSalary + contractBonus AS MONEY) AS 'Total Contract',
	CAST(contractSalary AS MONEY) AS 'Player Salary', 
	CAST(contractBonus AS MONEY) AS 'Signing Bonus',
	CAST(capReleaseNetSavings AS MONEY) AS 'Player Release Net Savings', 
	CAST(capReleasePenalty AS MONEY) AS 'Player Release Penalty', 
	CAST(capHit AS MONEY) AS 'Cap Hit', 
	CAST((capHit / @CurrentAdjustedCap) AS DECIMAL(8,6)) AS '% of Adjusted Cap',
	ROUND(
		((age - AVG(age) OVER()) / STDEV(age) OVER() * -1) +
		((teamSchemeOvr - AVG(teamSchemeOvr) OVER()) / STDEV(teamSchemeOvr) OVER()), 3) 
		AS 'Z-Score AgeScheme',
	ROUND(
		((age - AVG(age) OVER()) / STDEV(age) OVER() * -1) + 
		((playerBestOvr - AVG(playerBestOvr) OVER()) / STDEV(playerBestOvr) OVER()), 3) 
		AS 'Z-Score AgeOverall',
	ROUND(
		((age - AVG(age) OVER()) / STDEV(age) OVER() * -1) + 
		((teamSchemeOvr - AVG(teamSchemeOvr) OVER()) / STDEV(teamSchemeOvr) OVER()) + 
		((capHit - AVG(capHit) OVER()) / STDEV(capHit) OVER() * -1), 3) 
	AS 'Z-Score AgeSchemeCapHit',
	ROUND(
		((age - AVG(age) OVER()) / STDEV(age) OVER() * -1) + 
		((playerBestOvr - AVG(playerBestOvr) OVER()) / STDEV(playerBestOvr) OVER()) + 
		((capHit - AVG(capHit) OVER()) / STDEV(capHit) OVER() * -1), 3) 
	AS 'Z-Score AgeOverallCapHit',
	CASE
		WHEN position IN ('QB', 'HB', 'FB', 'WR', 'TE', 'LT', 'LG', 'C', 'RG', 'RT') THEN 'Offense'
		WHEN position IN ('LEDGE', 'DT', 'REDGE', 'SAM', 'MIKE', 'WILL', 'CB', 'FS', 'SS') THEN 'Defense'
		WHEN position IN ('P', 'K', 'LS') THEN 'Special Teams'
	END AS 'Side of Ball',
	CASE isOnPracticeSquad
		WHEN 'FALSE' THEN 'No'
		WHEN 'TRUE' THEN 'Yes'
	END AS 'Practice Squad?'
FROM playerData
WHERE team = @MyTeam AND lastUpdated = (SELECT MAX(lastUpdated) FROM playerData) AND isOnPracticeSquad = 'FALSE';