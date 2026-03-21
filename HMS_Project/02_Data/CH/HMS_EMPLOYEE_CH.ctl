-- ============================================================
-- File        : HMS_EMPLOYEE_CH.ctl
-- Member      : CH - Chandana
-- ============================================================
LOAD DATA
INFILE 'HMS_EMPLOYEE_DATA_CH.csv'
INTO TABLE HMS_EMPLOYEES_STG_CH
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    EMPLOYEE_ID, HOSPITAL_ID, DEPARTMENT_ID,
    EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME,
    EMPLOYEE_TYPE, EMAIL_ID
)
