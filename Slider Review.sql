/* SLIDER REVIEW */
USE PFCSS;



/* SET VARIABLES TO FILTER THE SEASON AND WEEKS IN QUESTION */
DECLARE @CurrentSeason INT = 2025;
DECLARE @StartWeek INT = 1;
DECLARE @EndWeek INT = 4;



/* DROP TEMP TABLES IF THEY ALREADY EXIST FROM A PREVIOUS RUN */
IF OBJECT_ID('tempdb..#PassingStatsForGamesPlayed') IS NOT NULL
    DROP TABLE #PassingStatsForGamesPlayed;

IF OBJECT_ID('tempdb..#RushingStatsForGamesPlayed') IS NOT NULL
    DROP TABLE #RushingStatsForGamesPlayed;

IF OBJECT_ID('tempdb..#ReceivingStatsForGamesPlayed') IS NOT NULL
    DROP TABLE #ReceivingStatsForGamesPlayed;

IF OBJECT_ID('tempdb..#DefensiveStatsForGamesPlayed') IS NOT NULL
    DROP TABLE #DefensiveStatsForGamesPlayed;

IF OBJECT_ID('tempdb..#PassingStatSums') IS NOT NULL
    DROP TABLE #PassingStatSums;

IF OBJECT_ID('tempdb..#RushingStatSums') IS NOT NULL
    DROP TABLE #RushingStatSums;

IF OBJECT_ID('tempdb..#ReceivingStatSums') IS NOT NULL
    DROP TABLE #ReceivingStatSums;

IF OBJECT_ID('tempdb..#DefensiveStatSums') IS NOT NULL
    DROP TABLE #DefensiveStatSums;


	   	  
/* CREATE TEMP TABLE OF THE PASSING STATS FOR ALL GAMES THAT WERE PLAYED DURING THE TIMEFRAME SPECIFIED ABOVE */
SELECT b.*
INTO	#PassingStatsForGamesPlayed
FROM	passingStats b
INNER JOIN gameData a ON (
		b.team_displayName IN (a.homeTeam, a.awayTeam)
		AND b.week = a.weekIndex + 1
		AND b.season = a.season
		AND a.simmed = 'False'
		AND a.home_fw = 'False'
		AND a.away_fw = 'False'
)
WHERE	b.season = @CurrentSeason 
		AND b.week BETWEEN @StartWeek AND @EndWeek
ORDER BY week, team_displayName;



/* CREATE TEMP TABLE OF THE RUSHING STATS FOR ALL GAMES THAT WERE PLAYED DURING THE TIMEFRAME SPECIFIED ABOVE */
SELECT b.*
INTO	#RushingStatsForGamesPlayed
FROM	rushingStats b
INNER JOIN gameData a ON (
		b.team_displayName IN (a.homeTeam, a.awayTeam)
		AND b.week = a.weekIndex + 1
		AND b.season = a.season
		AND a.simmed = 'False'
		AND a.home_fw = 'False'
		AND a.away_fw = 'False'
)
WHERE	b.season = @CurrentSeason 
		AND b.week BETWEEN @StartWeek AND @EndWeek
ORDER BY week, team_displayName;



/* CREATE TEMP TABLE OF THE RECEIVING STATS FOR ALL GAMES THAT WERE PLAYED DURING THE TIMEFRAME SPECIFIED ABOVE */
SELECT b.*
INTO	#ReceivingStatsForGamesPlayed
FROM	receivingStats b
INNER JOIN gameData a ON (
		b.team_displayName IN (a.homeTeam, a.awayTeam)
		AND b.week = a.weekIndex + 1
		AND b.season = a.season
		AND a.simmed = 'False'
		AND a.home_fw = 'False'
		AND a.away_fw = 'False'
)
WHERE	b.season = @CurrentSeason 
		AND b.week BETWEEN @StartWeek AND @EndWeek
ORDER BY week, team_displayName;



/* CREATE TEMP TABLE OF THE DEFENSIVE STATS FOR ALL GAMES THAT WERE PLAYED DURING THE TIMEFRAME SPECIFIED ABOVE */
SELECT b.*
INTO	#DefensiveStatsForGamesPlayed
FROM	defensiveStats b
INNER JOIN gameData a ON (
		b.team_displayName IN (a.homeTeam, a.awayTeam)
		AND b.week = a.weekIndex + 1
		AND b.season = a.season
		AND a.simmed = 'False'
		AND a.home_fw = 'False'
		AND a.away_fw = 'False'
)
WHERE	b.season = @CurrentSeason 
		AND b.week BETWEEN @StartWeek AND @EndWeek
ORDER BY week, team_displayName;



/* PASSING SUMS TEMP TABLE */
SELECT	CAST(SUM(passTotalAtt) AS FLOAT) AS totalPassAttempts, 
		CAST(SUM(passTotalComp) AS FLOAT) AS totalPassCompletions, 
		CAST(SUM(passTotalYds) AS FLOAT) AS totalPassYards,
		CAST(SUM(passTotalSacks) AS FLOAT) AS totalTimesSacked
INTO	#PassingStatSums
FROM	#PassingStatsForGamesPlayed;



/* RUSHING SUMS TEMP TABLE */
SELECT	CAST(SUM(rushTotalAtt) AS FLOAT) AS totalRushAttempts, 
		CAST(SUM(rushTotalYds) AS FLOAT) AS totalRushYards, 
		CAST(SUM(rushAvgYdsAfterContact) AS FLOAT) AS totalRushYardsAfterContact
INTO	#RushingStatSums
FROM	#RushingStatsForGamesPlayed;



/* RECEIVING SUMS TEMP TABLE */
SELECT	CAST(SUM(recTotalCatches) AS FLOAT) AS totalReceptions, 
		CAST(SUM(recTotalYds) AS FLOAT) AS totalReceivingYards,
		CAST(SUM(recTotalDrops) AS FLOAT) as totalDroppedPasses,
		CAST(SUM(recTotalYdsAfterCatch) AS FLOAT) AS totalYAC
INTO	#ReceivingStatSums
FROM	#ReceivingStatsForGamesPlayed;



/* DEFENSIVE SUMS TEMP TABLE */
SELECT	SUM(defTotalInts) AS totalInterceptions
INTO	#DefensiveStatSums
FROM	#DefensiveStatsForGamesPlayed;


/* COMPLETION PERCENTAGE (TARGET: 64.0%) */
/* YARDS PER PASS ATTEMPT (TARGET: 6.8) */
/* YARDS AFTER CATCH (TARGET: 1.5) */
/* YARDS PER CARRY (TARGET: 4.5) */
/* YARDS BEFORE CONTACT (TARGET: 2.5) */
/* WR DROP RATE (TARGET: 6.7) */
/* SACK PERCENTAGE PER DROPBACK (TARGET: 6.6%) */
/* INTERCEPTION RATE (TARGET: 2.2%) */
/* AVERAGE POINTS SCORED PER GAME PER TEAM (TARGET: 21.8) */
SELECT 
	(SELECT totalPassCompletions / totalPassAttempts FROM #PassingStatSums) AS completionPercentage,
	(SELECT totalPassYards / totalPassAttempts FROM #PassingStatSums) AS avgYardsPerPassAttempt,
	(SELECT totalYAC / totalReceptions FROM #ReceivingStatSums) AS avgYardsAfterCatch,
	(SELECT totalDroppedPasses / (totalDroppedPasses + totalReceptions) FROM #ReceivingStatSums) AS wrDropRate,
	(SELECT totalRushYards / totalRushAttempts FROM #RushingStatSums) AS avgYardsPerCarry,
	(SELECT (totalRushYards - totalRushYardsAfterContact) / totalRushAttempts FROM #RushingStatSums) AS avgYardsBeforeContact,
	(SELECT totalTimesSacked / (totalTimesSacked + totalPassAttempts) FROM #PassingStatSums) AS sackPercentagePerDropback,
	(SELECT d.totalInterceptions / p.totalPassAttempts FROM #DefensiveStatSums d CROSS JOIN #PassingStatSums p) AS interceptionRate,
	(SELECT (CAST(SUM(awayScore) AS FLOAT) + CAST(SUM(homeScore) AS FLOAT)) / 2 / Count(*)
		FROM gameData 
		WHERE weekIndex BETWEEN @StartWeek - 1 AND @EndWeek - 1
			AND season = @CurrentSeason 
			AND simmed = 'False'
			AND home_fw = 'False' 
			AND away_fw = 'False') AS averageGameScore,
	(SELECT Count(*)
		FROM gameData 
		WHERE weekIndex BETWEEN @StartWeek - 1 AND @EndWeek - 1
			AND season = @CurrentSeason 
			AND simmed = 'False'
			AND home_fw = 'False' 
			AND away_fw = 'False') AS gamesPlayed;
