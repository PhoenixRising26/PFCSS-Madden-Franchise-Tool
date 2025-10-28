SELECT team AS 'Team', 
    SUM(CASE 
        WHEN position IN ('QB', 'HB', 'FB', 'WR', 'TE') THEN 1 
        ELSE 0 
    END) AS 'Offense',
    SUM(CASE 
        WHEN position IN ('LEDGE', 'DT', 'REDGE', 'SAM', 'MIKE', 'WILL', 'CB', 'FS', 'SS') THEN 1 
        ELSE 0 
    END) AS 'Defense',
    SUM(CASE 
        WHEN position IN ('QB', 'HB', 'FB', 'WR', 'TE') THEN 1 
        ELSE 0 
    END) + 
    SUM(CASE 
        WHEN position IN ('LEDGE', 'DT', 'REDGE', 'SAM', 'MIKE', 'WILL', 'CB', 'FS', 'SS') THEN 1 
        ELSE 0 
    END) AS 'Total'
FROM playerData
WHERE devTrait IN ('3','2') AND season = 2025 AND week = 11
GROUP BY team
ORDER BY Total DESC