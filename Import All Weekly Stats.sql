-- UPDATES ALL WEEKLY STATS AT ONCE --

USE PFCSS;

EXEC ImportAllWeeklyStats 

----------------------------------
-- UPDATE THE SEASON AND WEEK DATA
@Season = 2025, 
@Week = 4;
----------------------------------