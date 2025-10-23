-- UPDATES PLAYER DATA --

-- ---------------------------------------------
-- !!! IMPORTANT !!!
-- CONVERT THE PLAYER DATA FILE FROM CSV TO TXT (TAB DELIMITED)
-- OPEN IT IN EXCEL, SAVE AS TXT FILE (TAB DELIMITED)
------------------------------------------------

USE PFCSS;

EXEC ImportPlayerData 

----------------------------------
-- UPDATE THE SEASON AND WEEK DATA
@Season = 2025, 
@Week = 4;
----------------------------------