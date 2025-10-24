-- UPDATES ALL DATA AT ONCE --

-- ---------------------------------------------
-- !!! IMPORTANT !!!
-- CONVERT THE PLAYER DATA FILE FROM CSV TO TXT (TAB DELIMITED)
-- OPEN IT IN EXCEL, SAVE AS TXT FILE (TAB DELIMITED)
------------------------------------------------

USE PFCSS;

DECLARE @Season INT = 2025;
DECLARE @Week INT = 7;

EXEC ImportPlayerData @Season = @Season, @Week = @Week;
EXEC ImportGameData @Season = @Season, @Week = @Week;
EXEC ImportAllWeeklyStats @Season = @Season, @Week = @Week;

GO


-- ---------------------------------------------
-- THIS WILL THROW AN ERROR FOR PRESEASON AS THERE IS NO WEEKLY DATA
------------------------------------------------