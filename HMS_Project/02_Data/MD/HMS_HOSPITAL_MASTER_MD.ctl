-- ============================================================
-- File        : HMS_HOSPITAL_MASTER_MD.ctl
-- Member      : MD - Manideep
-- ============================================================
LOAD DATA
INFILE 'HMS_HOSPITAL_DATA_MD.csv'
INTO TABLE HMS_HOSPITAL_MASTER
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
( HOSPITAL_CODE, CITY_NAME, HOSPITAL_NAME, HOSPITAL_BASIC_FEES )
