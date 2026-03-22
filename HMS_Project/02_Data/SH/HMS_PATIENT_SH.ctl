OPTIONS (SKIP=1)
-- ============================================================
-- File        : HMS_PATIENT_SH.ctl
-- Project     : Hospital Management System (HMS)
-- Member      : SH - Shaswin
-- Description : SQL*Loader CTL for bulk loading patient data
--               from HMS_PATIENT_DATA_SH.csv into HMS_PATIENT_SH.
-- Usage       : sqlldr userid=APPS/<password>@<SID>
--                      control=HMS_PATIENT_SH.ctl
--                      log=HMS_PATIENT_SH.log
-- Date        : 2026-03-21
-- Version     : 1.0
-- ============================================================

LOAD DATA
INFILE 'HMS_PATIENT_DATA_SH.csv'
INTO TABLE HMS_PATIENT_STG_SH
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    STG_ID EXPRESSION "HMS_PAT_STG_SEQ_SH.NEXTVAL",
    BATCH_ID CONSTANT 'BATCH_SH',
    CREATED_BY CONSTANT 1021027,
    CREATION_DATE SYSDATE,
    LAST_UPDATED_BY CONSTANT 1021027,
    LAST_UPDATE_DATE SYSDATE,

    PATIENT_ID,            -- Unique patient identifier
    HOSPITAL_ID,           -- Branch where patient is registered
    DEPARTMENT_ID,         -- Admitted department (NULL = outpatient)
    PATIENT_FIRST_NAME,    -- Patient first name
    PATIENT_LAST_NAME,
    PATIENT_PHONE_NUMBER,     -- Patient last name
    EMAIL_ID,              -- Patient email
    ADDRESS_STREET,        -- Street address
    ADDRESS_CITY,          -- City of residence
    ADDRESS_STATE,         -- State/Province
    ADDRESS_POSTAL_CODE    -- Postal / ZIP code
)
