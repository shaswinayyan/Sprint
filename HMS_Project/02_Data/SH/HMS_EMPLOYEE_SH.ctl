OPTIONS (SKIP=1)
-- ============================================================
-- File        : HMS_EMPLOYEE_SH.ctl
-- Project     : Hospital Management System (HMS)
-- Member      : SH - Shaswin
-- Description : SQL*Loader CTL for bulk loading employee data
--               from HMS_EMPLOYEE_DATA_SH.csv into HMS_EMPLOYEES_SH.
-- Usage       : sqlldr userid=APPS/<password>@<SID>
--                      control=HMS_EMPLOYEE_SH.ctl
--                      log=HMS_EMPLOYEE_SH.log
-- Date        : 2026-03-21
-- Version     : 1.0
-- ============================================================

LOAD DATA
INFILE 'HMS_EMPLOYEE_DATA_SH.csv'
INTO TABLE HMS_EMPLOYEES_STG_SH
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    STG_ID EXPRESSION "HMS_EMP_STG_SEQ_SH.NEXTVAL",
    BATCH_ID CONSTANT 'BATCH_SH',
    CREATED_BY CONSTANT 1021027,
    CREATION_DATE SYSDATE,
    LAST_UPDATED_BY CONSTANT 1021027,
    LAST_UPDATE_DATE SYSDATE,

    EMPLOYEE_ID,          -- Unique employee number
    HOSPITAL_ID,          -- Hospital branch this employee works at
    DEPARTMENT_ID,        -- Department (NULL for admin/general staff)
    EMPLOYEE_FIRST_NAME,  -- First name
    EMPLOYEE_LAST_NAME,   -- Last name
    EMPLOYEE_TYPE,        -- DOCTOR or STAFF
    EMAIL_ID              -- Official email
)
