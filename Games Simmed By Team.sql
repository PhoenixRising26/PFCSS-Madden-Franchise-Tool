SELECT team, count(*) as gamesNotPlayed
FROM (
	SELECT awayTeam as team
	FROM gameData
	WHERE simmed = 'True' OR home_fw = 'True' OR away_fw = 'True'

	UNION ALL

	SELECT homeTeam as team
	FROM gameData
	WHERE simmed = 'True' OR home_fw = 'True' OR away_fw = 'True'
) AS unplayedGames
GROUP BY team
ORDER BY gamesNotPlayed DESC;