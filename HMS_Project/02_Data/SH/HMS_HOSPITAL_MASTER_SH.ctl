-- ============================================================
-- File        : HMS_HOSPITAL_MASTER_SH.ctl
-- Project     : Hospital Management System (HMS)
-- Member      : SH - Shaswin
-- Description : SQL*Loader control file for bulk loading
--               hospital master records from CSV into the
--               HMS_HOSPITAL_MASTER table under APPS schema.
-- Usage       : sqlldr userid=APPS/<password>@<SID>
--                      control=HMS_HOSPITAL_MASTER_SH.ctl
--                      log=HMS_HOSPITAL_MASTER_SH.log
-- Date        : 2026-03-21
-- Version     : 1.0
-- ============================================================

LOAD DATA
-- Source CSV file for hospital master data
INFILE 'HMS_HOSPITAL_DATA_SH.csv'

-- Append adds rows without truncating existing data
-- Use TRUNCATE instead if you want to clear table first
INTO TABLE HMS_HOSPITAL_MASTER
APPEND

-- Fields are comma-separated; strings optionally quoted
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

-- Allows missing trailing columns to default to NULL
TRAILING NULLCOLS

(
    -- HOSPITAL_CODE : Alphanumeric hospital code (e.g., H001)
    HOSPITAL_CODE,

    -- CITY_NAME : City where the hospital is located
    CITY_NAME,

    -- HOSPITAL_NAME : Full name of the hospital
    HOSPITAL_NAME,

    -- HOSPITAL_BASIC_FEES : Base fee in INR (numeric)
    HOSPITAL_BASIC_FEES
)
