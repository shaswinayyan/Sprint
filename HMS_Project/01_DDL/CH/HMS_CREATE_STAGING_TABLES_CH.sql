-- ============================================================
-- File        : HMS_CREATE_STAGING_TABLES_CH.sql
-- Project     : Hospital Management System (HMS)
-- Description : Creates staging tables for bulk data loading.
--               Staging tables contain all the columns of their
--               corresponding base tables PLUS the Oracle EBS
--               standard WHO columns for audit traceability:
--
--               WHO COLUMNS (Oracle EBS R12 Standard):
--               ----------------------------------------
--               CREATED_BY        NUMBER   - FND_USER.USER_ID of creator
--               CREATION_DATE     DATE     - Date/time the row was created
--               LAST_UPDATED_BY   NUMBER   - FND_USER.USER_ID of last updater
--               LAST_UPDATE_DATE  DATE     - Date/time of last update
--               LAST_UPDATE_LOGIN NUMBER   - FND_LOGINS.LOGIN_ID of session
--
--               TEAM USER IDs (FND_USER.USER_ID):
--               ----------------------------------------
--               SH - Shaswin   : 1021027
--               CH - Chandana  : (to be confirmed by Chandana)
--               MD - Manideep  : (to be confirmed by Manideep)
--               NM - Namitha   : (to be confirmed by Namitha)
--
--               USAGE:
--               ----------------------------------------
--               1. SQL*Loader/CTL loads raw CSV data into STAGING tables.
--               2. PL/SQL validation procedure validates and moves rows
--                  from STAGING to BASE tables, stamping WHO columns.
--               3. ERROR_LOG column captures any row-level errors.
--               4. STAGING tables are kept for audit and debugging.
--
-- Schema      : APPS
-- Application : Application Object Library (AOL)
-- Date        : 2026-03-21
-- Version     : 1.0
-- ============================================================


-- ===========================================================
-- STEP 0: Drop existing staging tables (safe re-run)
-- ===========================================================
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HMS_HOSPITAL_MASTER_STG_CH CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HMS_HOSPITAL_BRANCH_STG_CH CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HMS_DEPARTMENT_STG_CH      CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HMS_EMPLOYEES_STG_CH       CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HMS_PATIENT_STG_CH         CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/


-- ===========================================================
-- STAGING TABLE 1: HMS_HOSPITAL_MASTER_STG_CH
-- Purpose : Staging area for hospital master CSV loads.
--           Rows are validated here before moving to base table.
-- ===========================================================
CREATE TABLE HMS_HOSPITAL_MASTER_STG_CH (
    -- -------------------------------------------------------
    -- Staging Control Columns
    -- -------------------------------------------------------
    STG_ID              NUMBER          NOT NULL,   -- Surrogate PK for this staging row
    BATCH_ID            VARCHAR2(50),               -- Batch identifier (e.g., 'BATCH_SH_20260321')
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',  -- NEW / VALIDATED / LOADED / ERROR
    ERROR_LOG           VARCHAR2(4000),             -- Stores validation error messages if any

    -- -------------------------------------------------------
    -- Business Data Columns (mirrors HMS_HOSPITAL_MASTER_CH)
    -- -------------------------------------------------------
    HOSPITAL_CODE       VARCHAR2(10),               -- Hospital code from CSV
    CITY_NAME           VARCHAR2(50),               -- City name from CSV
    HOSPITAL_NAME       VARCHAR2(100),              -- Hospital name from CSV
    HOSPITAL_BASIC_FEES NUMBER(10, 2),              -- Basic fees from CSV

    -- -------------------------------------------------------
    -- WHO Columns (Oracle EBS R12 Standard)
    -- -------------------------------------------------------
    CREATED_BY          NUMBER          NOT NULL,   -- FND_USER.USER_ID who created this staging row
    CREATION_DATE       DATE            NOT NULL,   -- Date/time this staging row was inserted
    LAST_UPDATED_BY     NUMBER          NOT NULL,   -- FND_USER.USER_ID who last updated this row
    LAST_UPDATE_DATE    DATE            NOT NULL,   -- Date/time of last update to this row
    LAST_UPDATE_LOGIN   NUMBER,                     -- FND_LOGINS.LOGIN_ID of the active session

    CONSTRAINT PK_HMS_HOSP_MASTER_STG_CH  PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_HOSP_STG_STATUS_CH     CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);

COMMENT ON TABLE  HMS_HOSPITAL_MASTER_STG_CH                      IS 'Staging table for HMS_HOSPITAL_MASTER_CH bulk loads; includes Oracle EBS WHO columns';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.STG_ID               IS 'Surrogate PK for this staging record';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.BATCH_ID             IS 'Identifier linking rows loaded together in one batch (e.g., BATCH_SH_20260321)';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.RECORD_STATUS        IS 'Lifecycle status: NEW=just loaded, VALIDATED=passed checks, LOADED=moved to base, ERROR=failed';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.ERROR_LOG            IS 'Free-text field capturing validation or load error messages for this row';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.HOSPITAL_CODE        IS 'Raw HOSPITAL_CODE from CSV; validated against uniqueness before base load';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.CITY_NAME            IS 'City name loaded from CSV';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.HOSPITAL_NAME        IS 'Hospital name loaded from CSV';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.HOSPITAL_BASIC_FEES  IS 'Basic fees from CSV; must be > 0 to pass validation';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.CREATED_BY           IS 'WHO: FND_USER.USER_ID of the person who inserted this staging row';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.CREATION_DATE        IS 'WHO: SYSDATE at the time this staging row was inserted';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.LAST_UPDATED_BY      IS 'WHO: FND_USER.USER_ID of the person who last modified this row';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.LAST_UPDATE_DATE     IS 'WHO: SYSDATE at the time this row was last updated';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER_STG_CH.LAST_UPDATE_LOGIN    IS 'WHO: FND_LOGINS.LOGIN_ID of the active web session (can be NULL if not available)';

CREATE SEQUENCE HMS_HOSP_MASTER_STG_SEQ_CH START WITH 1 INCREMENT BY 1 NOCACHE;


-- ===========================================================
-- STAGING TABLE 2: HMS_HOSPITAL_BRANCH_STG_CH
-- Purpose : Staging area for hospital branch CSV loads.
-- ===========================================================
CREATE TABLE HMS_HOSPITAL_BRANCH_STG_CH (
    -- Staging Control Columns
    STG_ID              NUMBER          NOT NULL,
    BATCH_ID            VARCHAR2(50),
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',
    ERROR_LOG           VARCHAR2(4000),

    -- Business Data Columns (mirrors HMS_HOSPITAL_BRANCH_CH)
    HOSPITAL_ID         NUMBER(10),
    HOSPITAL_CODE       VARCHAR2(10),
    BRANCH_NAME         VARCHAR2(100),
    CITY                VARCHAR2(50),
    MANAGING_DIRECTOR   VARCHAR2(100),
    HELPDESK_NUMBER     VARCHAR2(15),
    EMERGENCY_NUMBER    VARCHAR2(15),
    CUSTOMER_CARE_EMAIL VARCHAR2(100),
    CUSTOMER_CARE_PHONE VARCHAR2(15),

    -- WHO Columns
    CREATED_BY          NUMBER          NOT NULL,
    CREATION_DATE       DATE            NOT NULL,
    LAST_UPDATED_BY     NUMBER          NOT NULL,
    LAST_UPDATE_DATE    DATE            NOT NULL,
    LAST_UPDATE_LOGIN   NUMBER,

    CONSTRAINT PK_HMS_HOSP_BRANCH_STG_CH  PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_BRANCH_STG_STATUS_CH   CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);

COMMENT ON TABLE  HMS_HOSPITAL_BRANCH_STG_CH               IS 'Staging table for HMS_HOSPITAL_BRANCH_CH bulk loads; includes Oracle EBS WHO columns';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.STG_ID        IS 'Surrogate PK for this staging record';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.BATCH_ID      IS 'Batch identifier for grouping rows loaded together';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.RECORD_STATUS IS 'Lifecycle status: NEW / VALIDATED / LOADED / ERROR';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.ERROR_LOG     IS 'Validation or load error messages captured for this row';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.CREATED_BY       IS 'WHO: FND_USER.USER_ID of row creator';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.CREATION_DATE    IS 'WHO: SYSDATE when row was inserted';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.LAST_UPDATED_BY  IS 'WHO: FND_USER.USER_ID of last updater';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.LAST_UPDATE_DATE IS 'WHO: SYSDATE when row was last updated';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH_STG_CH.LAST_UPDATE_LOGIN IS 'WHO: FND_LOGINS.LOGIN_ID of active session';

CREATE SEQUENCE HMS_HOSP_BRANCH_STG_SEQ_CH START WITH 1 INCREMENT BY 1 NOCACHE;


-- ===========================================================
-- STAGING TABLE 3: HMS_DEPARTMENT_STG_CH
-- Purpose : Staging area for department CSV loads.
-- ===========================================================
CREATE TABLE HMS_DEPARTMENT_STG_CH (
    -- Staging Control Columns
    STG_ID              NUMBER          NOT NULL,
    BATCH_ID            VARCHAR2(50),
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',
    ERROR_LOG           VARCHAR2(4000),

    -- Business Data Columns (mirrors HMS_DEPARTMENT_CH)
    DEPARTMENT_ID       NUMBER(10),
    HOSPITAL_ID         NUMBER(10),
    DEPARTMENT_NAME     VARCHAR2(100),
    DEPT_MANAGER        VARCHAR2(100),
    NUMBER_OF_BEDS      NUMBER(5),

    -- WHO Columns
    CREATED_BY          NUMBER          NOT NULL,
    CREATION_DATE       DATE            NOT NULL,
    LAST_UPDATED_BY     NUMBER          NOT NULL,
    LAST_UPDATE_DATE    DATE            NOT NULL,
    LAST_UPDATE_LOGIN   NUMBER,

    CONSTRAINT PK_HMS_DEPT_STG_CH      PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_DEPT_STG_STATUS_CH  CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);

COMMENT ON TABLE  HMS_DEPARTMENT_STG_CH               IS 'Staging table for HMS_DEPARTMENT_CH bulk loads; includes Oracle EBS WHO columns';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.STG_ID        IS 'Surrogate PK for this staging record';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.BATCH_ID      IS 'Batch identifier for grouping rows loaded together';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.RECORD_STATUS IS 'Lifecycle status: NEW / VALIDATED / LOADED / ERROR';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.ERROR_LOG     IS 'Validation or load error messages captured for this row';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.CREATED_BY       IS 'WHO: FND_USER.USER_ID of row creator';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.CREATION_DATE    IS 'WHO: SYSDATE when row was inserted';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.LAST_UPDATED_BY  IS 'WHO: FND_USER.USER_ID of last updater';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.LAST_UPDATE_DATE IS 'WHO: SYSDATE when row was last updated';
COMMENT ON COLUMN HMS_DEPARTMENT_STG_CH.LAST_UPDATE_LOGIN IS 'WHO: FND_LOGINS.LOGIN_ID of active session';

CREATE SEQUENCE HMS_DEPT_STG_SEQ_CH START WITH 1 INCREMENT BY 1 NOCACHE;


-- ===========================================================
-- STAGING TABLE 4: HMS_EMPLOYEES_STG_CH
-- Purpose : Staging area for employee CSV loads.
-- ===========================================================
CREATE TABLE HMS_EMPLOYEES_STG_CH (
    -- Staging Control Columns
    STG_ID              NUMBER          NOT NULL,
    BATCH_ID            VARCHAR2(50),
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',
    ERROR_LOG           VARCHAR2(4000),

    -- Business Data Columns (mirrors HMS_EMPLOYEES_CH)
    EMPLOYEE_ID         NUMBER(10),
    HOSPITAL_ID         NUMBER(10),
    DEPARTMENT_ID       NUMBER(10),
    EMPLOYEE_FIRST_NAME VARCHAR2(50),
    EMPLOYEE_LAST_NAME  VARCHAR2(50),
    EMPLOYEE_TYPE       VARCHAR2(20),
    EMAIL_ID            VARCHAR2(100),

    -- WHO Columns
    CREATED_BY          NUMBER          NOT NULL,
    CREATION_DATE       DATE            NOT NULL,
    LAST_UPDATED_BY     NUMBER          NOT NULL,
    LAST_UPDATE_DATE    DATE            NOT NULL,
    LAST_UPDATE_LOGIN   NUMBER,

    CONSTRAINT PK_HMS_EMP_STG_CH      PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_EMP_STG_STATUS_CH  CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);

COMMENT ON TABLE  HMS_EMPLOYEES_STG_CH               IS 'Staging table for HMS_EMPLOYEES_CH bulk loads; includes Oracle EBS WHO columns';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.STG_ID        IS 'Surrogate PK for this staging record';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.BATCH_ID      IS 'Batch identifier for grouping rows loaded together';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.RECORD_STATUS IS 'Lifecycle status: NEW / VALIDATED / LOADED / ERROR';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.ERROR_LOG     IS 'Validation or load error messages captured for this row';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.CREATED_BY       IS 'WHO: FND_USER.USER_ID of row creator';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.CREATION_DATE    IS 'WHO: SYSDATE when row was inserted';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.LAST_UPDATED_BY  IS 'WHO: FND_USER.USER_ID of last updater';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.LAST_UPDATE_DATE IS 'WHO: SYSDATE when row was last updated';
COMMENT ON COLUMN HMS_EMPLOYEES_STG_CH.LAST_UPDATE_LOGIN IS 'WHO: FND_LOGINS.LOGIN_ID of active session';

CREATE SEQUENCE HMS_EMP_STG_SEQ_CH START WITH 1 INCREMENT BY 1 NOCACHE;


-- ===========================================================
-- STAGING TABLE 5: HMS_PATIENT_STG_CH
-- Purpose : Staging area for patient CSV loads.
-- ===========================================================
CREATE TABLE HMS_PATIENT_STG_CH (
    -- Staging Control Columns
    STG_ID              NUMBER          NOT NULL,
    BATCH_ID            VARCHAR2(50),
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',
    ERROR_LOG           VARCHAR2(4000),

    -- Business Data Columns (mirrors HMS_PATIENT_CH)
    PATIENT_ID          NUMBER(10),
    HOSPITAL_ID         NUMBER(10),
    DEPARTMENT_ID       NUMBER(10),
    PATIENT_FIRST_NAME  VARCHAR2(50),
    PATIENT_LAST_NAME   VARCHAR2(50),
    PATIENT_PHONE_NUMBER VARCHAR2(15),
    EMAIL_ID            VARCHAR2(100),
    ADDRESS_STREET      VARCHAR2(100),
    ADDRESS_CITY        VARCHAR2(50),
    ADDRESS_STATE       VARCHAR2(50),
    ADDRESS_POSTAL_CODE VARCHAR2(10),

    -- WHO Columns
    CREATED_BY          NUMBER          NOT NULL,
    CREATION_DATE       DATE            NOT NULL,
    LAST_UPDATED_BY     NUMBER          NOT NULL,
    LAST_UPDATE_DATE    DATE            NOT NULL,
    LAST_UPDATE_LOGIN   NUMBER,

    CONSTRAINT PK_HMS_PAT_STG_CH      PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_PAT_STG_STATUS_CH  CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);

COMMENT ON TABLE  HMS_PATIENT_STG_CH               IS 'Staging table for HMS_PATIENT_CH bulk loads; includes Oracle EBS WHO columns';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.STG_ID        IS 'Surrogate PK for this staging record';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.BATCH_ID      IS 'Batch identifier for grouping rows loaded together';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.RECORD_STATUS IS 'Lifecycle status: NEW / VALIDATED / LOADED / ERROR';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.ERROR_LOG     IS 'Validation or load error messages captured for this row';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.CREATED_BY       IS 'WHO: FND_USER.USER_ID of row creator';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.CREATION_DATE    IS 'WHO: SYSDATE when row was inserted';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.LAST_UPDATED_BY  IS 'WHO: FND_USER.USER_ID of last updater';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.LAST_UPDATE_DATE IS 'WHO: SYSDATE when row was last updated';
COMMENT ON COLUMN HMS_PATIENT_STG_CH.LAST_UPDATE_LOGIN IS 'WHO: FND_LOGINS.LOGIN_ID of active session';

CREATE SEQUENCE HMS_PAT_STG_SEQ_CH START WITH 1 INCREMENT BY 1 NOCACHE;


-- ===========================================================

-- ===========================================================
-- STAGING TABLE 6: HMS_EMPLOYEE_PHONE_MST_STG_CH
-- ===========================================================
CREATE TABLE HMS_EMPLOYEE_PHONE_MST_STG_CH (
    STG_ID              NUMBER          NOT NULL,
    BATCH_ID            VARCHAR2(50),
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',
    ERROR_LOG           VARCHAR2(4000),

    PHONE_RECORD_ID     NUMBER(10),
    EMPLOYEE_ID         NUMBER(10),
    PHONE1              VARCHAR2(15),
    PHONE2              VARCHAR2(15),

    CREATED_BY          NUMBER          NOT NULL,
    CREATION_DATE       DATE            NOT NULL,
    LAST_UPDATED_BY     NUMBER          NOT NULL,
    LAST_UPDATE_DATE    DATE            NOT NULL,
    LAST_UPDATE_LOGIN   NUMBER,

    CONSTRAINT PK_EMP_PH_STG_CH  PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_EMP_PH_STG_ST_CH CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);
CREATE SEQUENCE HMS_EMP_PHONE_STG_SEQ_CH START WITH 1 INCREMENT BY 1 NOCACHE;

-- ===========================================================
-- STAGING TABLE 7: HMS_DOCTOR_AVAILABILITY_STG_CH
-- ===========================================================
CREATE TABLE HMS_DOCTOR_AVAILABILITY_STG_CH (
    STG_ID              NUMBER          NOT NULL,
    BATCH_ID            VARCHAR2(50),
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',
    ERROR_LOG           VARCHAR2(4000),

    AVAILABILITY_ID     NUMBER(10),
    DOCTOR_ID           NUMBER(10),
    DOCTOR_DEPARTMENT   NUMBER(10),
    AVAILABILITY_DAY    VARCHAR2(10),
    START_TIME          VARCHAR2(8),
    END_TIME            VARCHAR2(8),

    CREATED_BY          NUMBER          NOT NULL,
    CREATION_DATE       DATE            NOT NULL,
    LAST_UPDATED_BY     NUMBER          NOT NULL,
    LAST_UPDATE_DATE    DATE            NOT NULL,
    LAST_UPDATE_LOGIN   NUMBER,

    CONSTRAINT PK_DOC_AV_STG_CH   PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_DOC_AV_STG_ST_CH CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);
CREATE SEQUENCE HMS_DOC_AVAIL_STG_SEQ_CH START WITH 1 INCREMENT BY 1 NOCACHE;

-- END OF FILE: HMS_CREATE_STAGING_TABLES_CH.sql
-- Run AFTER HMS_CREATE_TABLES.sql (staging has no FK deps)
-- ===========================================================
