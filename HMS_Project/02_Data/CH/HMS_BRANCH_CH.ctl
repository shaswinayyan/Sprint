-- ============================================================
-- File        : HMS_BRANCH_CH.ctl
-- Description : SQL*Loader control file for loading hospital branch data
--               into staging table HMS_HOSPITAL_BRANCH_STG_CH
-- ============================================================

LOAD DATA
INFILE 'HMS_BRANCH_DATA_CH.csv'

INTO TABLE HMS_HOSPITAL_BRANCH_STG_CH
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

TRAILING NULLCOLS

(
    HOSPITAL_ID,
    HOSPITAL_CODE,
    BRANCH_NAME,
    CITY,
    MANAGING_DIRECTOR,
    HELPDESK_NUMBER,
    EMERGENCY_NUMBER,
    CUSTOMER_CARE_EMAIL,
    CUSTOMER_CARE_PHONE
)
