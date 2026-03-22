OPTIONS (SKIP=1)
-- ============================================================
-- File        : HMS_EMPLOYEE_MD.ctl  /  HMS_DEPT_MD.ctl
--               HMS_PATIENT_MD.ctl
-- Member      : MD - Manideep
-- ============================================================

-- [Save each block as its own .ctl file as shown below]

-- *** HMS_EMPLOYEE_MD.ctl ***
-- LOAD DATA
-- INFILE 'HMS_EMPLOYEE_DATA_MD.csv'
-- INTO TABLE HMS_EMPLOYEES_STG_MD APPEND
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' TRAILING NULLCOLS
-- (
    STG_ID EXPRESSION "HMS_EMP_STG_SEQ_MD.NEXTVAL",
    BATCH_ID CONSTANT 'BATCH_MD',
    CREATED_BY CONSTANT 1021035,
    CREATION_DATE SYSDATE,
    LAST_UPDATED_BY CONSTANT 1021035,
    LAST_UPDATE_DATE SYSDATE,
 EMPLOYEE_ID, HOSPITAL_ID, DEPARTMENT_ID,
--   EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME, EMPLOYEE_TYPE, EMAIL_ID )
