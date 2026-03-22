OPTIONS (SKIP=1)
-- ============================================================
-- File        : HMS_DEPT_SH.ctl
-- Project     : Hospital Management System (HMS)
-- Member      : SH - Shaswin
-- Description : SQL*Loader CTL for bulk loading department data
--               from HMS_DEPT_DATA_SH.csv into HMS_DEPARTMENT_SH.
-- Usage       : sqlldr userid=APPS/<password>@<SID>
--                      control=HMS_DEPT_SH.ctl
--                      log=HMS_DEPT_SH.log
-- Date        : 2026-03-21
-- Version     : 1.0
-- ============================================================

LOAD DATA
INFILE 'HMS_DEPT_DATA_SH.csv'
INTO TABLE HMS_DEPARTMENT_STG_SH
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    STG_ID "HMS_DEPT_STG_SEQ_SH.NEXTVAL",
    BATCH_ID CONSTANT 'BATCH_SH',
    CREATED_BY CONSTANT 1021027,
    CREATION_DATE SYSDATE,
    LAST_UPDATED_BY CONSTANT 1021027,
    LAST_UPDATE_DATE SYSDATE,

    DEPARTMENT_ID,    -- Unique department identifier
    HOSPITAL_ID,      -- Branch this department belongs to
    DEPARTMENT_NAME,  -- Name of the department
    DEPT_MANAGER,     -- Name of the department manager
    NUMBER_OF_BEDS    -- Number of beds in this department
)
