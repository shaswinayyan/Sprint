-- ============================================================
-- File        : HMS_PATIENT_CH.ctl
-- Member      : CH - Chandana
-- ============================================================
LOAD DATA
INFILE 'HMS_PATIENT_DATA_CH.csv'
INTO TABLE HMS_PATIENT_STG_CH
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    PATIENT_ID, HOSPITAL_ID, DEPARTMENT_ID,
    PATIENT_FIRST_NAME, PATIENT_LAST_NAME, EMAIL_ID,
    ADDRESS_STREET, ADDRESS_CITY, ADDRESS_STATE, ADDRESS_POSTAL_CODE
)
