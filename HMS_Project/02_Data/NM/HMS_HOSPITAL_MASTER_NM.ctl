-- ============================================================
-- File        : HMS_HOSPITAL_MASTER_NM.ctl
-- Member      : NM - Namitha
-- ============================================================
LOAD DATA
INFILE 'HMS_HOSPITAL_DATA_NM.csv'
INTO TABLE HMS_HOSPITAL_MASTER_STG_NM
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
( HOSPITAL_CODE, CITY_NAME, HOSPITAL_NAME, HOSPITAL_BASIC_FEES )
