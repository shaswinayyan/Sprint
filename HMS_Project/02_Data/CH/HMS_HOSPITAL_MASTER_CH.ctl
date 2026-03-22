OPTIONS (SKIP=1)
-- ============================================================
-- File        : HMS_HOSPITAL_MASTER_CH.ctl
-- Project     : Hospital Management System (HMS)
-- Member      : CH - Chandana
-- Description : SQL*Loader CTL for HMS_HOSPITAL_MASTER_CH table.
-- Usage       : sqlldr userid=APPS/<password>@<SID>
--                      control=HMS_HOSPITAL_MASTER_CH.ctl
--                      log=HMS_HOSPITAL_MASTER_CH.log
-- Date        : 2026-03-21
-- Version     : 1.0
-- ============================================================
LOAD DATA
INFILE 'HMS_HOSPITAL_DATA_CH.csv'
INTO TABLE HMS_HOSPITAL_MASTER_STG_CH
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    STG_ID EXPRESSION "HMS_HOSP_MASTER_STG_SEQ_CH.NEXTVAL",
    BATCH_ID CONSTANT 'BATCH_CH',
    CREATED_BY CONSTANT 1021034,
    CREATION_DATE SYSDATE,
    LAST_UPDATED_BY CONSTANT 1021034,
    LAST_UPDATE_DATE SYSDATE,

    HOSPITAL_CODE,
    CITY_NAME,
    HOSPITAL_NAME,
    HOSPITAL_BASIC_FEES
)
