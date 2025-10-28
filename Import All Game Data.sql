-- UPDATES ALL WEEKLY STATS AT ONCE --

USE PFCSS;

EXEC ImportGameData 

----------------------------------
-- UPDATE THE SEASON AND WEEK DATA
@Season = 2025, 
@Week = 11;
----------------------------------