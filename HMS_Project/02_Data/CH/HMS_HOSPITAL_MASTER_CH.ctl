-- ============================================================
-- File        : HMS_HOSPITAL_MASTER_CH.ctl
-- Project     : Hospital Management System (HMS)
-- Member      : CH - Chandana
-- Description : SQL*Loader CTL for HMS_HOSPITAL_MASTER table.
-- Usage       : sqlldr userid=APPS/<password>@<SID>
--                      control=HMS_HOSPITAL_MASTER_CH.ctl
--                      log=HMS_HOSPITAL_MASTER_CH.log
-- Date        : 2026-03-21
-- Version     : 1.0
-- ============================================================
LOAD DATA
INFILE 'HMS_HOSPITAL_DATA_CH.csv'
INTO TABLE HMS_HOSPITAL_MASTER
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    HOSPITAL_CODE,
    CITY_NAME,
    HOSPITAL_NAME,
    HOSPITAL_BASIC_FEES
)
