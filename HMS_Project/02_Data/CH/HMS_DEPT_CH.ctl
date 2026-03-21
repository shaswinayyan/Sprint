-- ============================================================
-- File        : HMS_DEPT_CH.ctl
-- Member      : CH - Chandana
-- ============================================================
LOAD DATA
INFILE 'HMS_DEPT_DATA_CH.csv'
INTO TABLE HMS_DEPARTMENT
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    DEPARTMENT_ID, HOSPITAL_ID, DEPARTMENT_NAME,
    DEPT_MANAGER, NUMBER_OF_BEDS
)
