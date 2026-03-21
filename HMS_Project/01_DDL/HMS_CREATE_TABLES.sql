-- ============================================================
-- File        : HMS_CREATE_TABLES.sql
-- Project     : Hospital Management System (HMS)
-- Description : Creates all required database tables for the HMS
--               project in the Oracle EBS 12.2.8 environment.
--               All tables are created under the APPS schema.
-- Team        : SH (Shaswin), CH (Chandana),
--               MD (Manideep), NM (Namitha)
-- Schema      : APPS
-- Application : Application Object Library (AOL)
-- Date        : 2026-03-21
-- Version     : 1.0
--
-- EXECUTION ORDER (respect FK dependencies):
--   1. HMS_HOSPITAL_MASTER
--   2. HMS_HOSPITAL_BRANCH
--   3. HMS_DEPARTMENT
--   4. HMS_EMPLOYEES
--   5. HMS_EMPLOYEE_PHONE_MST
--   6. HMS_DOCTOR_AVAILABILITY
--   7. HMS_PATIENT
--   8. HMS_PATIENT_PHONE_MST
-- ============================================================

-- ===========================================================
-- STEP 0: Drop existing tables if re-running (safe cleanup)
-- ===========================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HMS_PATIENT_PHONE_MST    CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HMS_PATIENT              CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HMS_DOCTOR_AVAILABILITY  CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HMS_EMPLOYEE_PHONE_MST   CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HMS_EMPLOYEES            CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HMS_DEPARTMENT           CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HMS_HOSPITAL_BRANCH      CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HMS_HOSPITAL_MASTER      CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/


-- ===========================================================
-- TABLE 1: HMS_HOSPITAL_MASTER
-- Purpose : Master table of all hospital branches across cities.
--           Stores city-level and fee information.
-- ===========================================================
CREATE TABLE HMS_HOSPITAL_MASTER (
    HOSPITAL_CODE       VARCHAR2(10)    NOT NULL,  -- Unique code for the hospital (e.g., H001)
    CITY_NAME           VARCHAR2(50)    NOT NULL,  -- City where the hospital is located
    HOSPITAL_NAME       VARCHAR2(100)   NOT NULL,  -- Full name of the hospital
    HOSPITAL_BASIC_FEES NUMBER(10, 2)   NOT NULL,  -- Base consultation fee in INR
    CONSTRAINT PK_HMS_HOSP_MASTER PRIMARY KEY (HOSPITAL_CODE)
);

-- Add descriptive comments for documentation
COMMENT ON TABLE  HMS_HOSPITAL_MASTER                     IS 'Master record of all HMS hospital branches and their city-level details';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER.HOSPITAL_CODE       IS 'Unique alphanumeric code identifying the hospital (PK)';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER.CITY_NAME           IS 'City in which this hospital branch operates';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER.HOSPITAL_NAME       IS 'Full legal name of the hospital';
COMMENT ON COLUMN HMS_HOSPITAL_MASTER.HOSPITAL_BASIC_FEES IS 'Standard base consultation fee charged by this hospital in INR';


-- ===========================================================
-- TABLE 2: HMS_HOSPITAL_BRANCH
-- Purpose : Stores detailed information for each hospital branch,
--           including its contact information and management.
-- ===========================================================
CREATE TABLE HMS_HOSPITAL_BRANCH (
    HOSPITAL_ID         NUMBER(10)      NOT NULL,  -- Internal Auto-ID for each branch record
    HOSPITAL_CODE       VARCHAR2(10)    NOT NULL,  -- FK -> HMS_HOSPITAL_MASTER
    BRANCH_NAME         VARCHAR2(100)   NOT NULL,  -- Name of the specific branch (e.g., HMS Mumbai Central)
    CITY                VARCHAR2(50)    NOT NULL,  -- City of this branch
    MANAGING_DIRECTOR   VARCHAR2(100)   NOT NULL,  -- Name of the managing director
    HELPDESK_NUMBER     VARCHAR2(15),              -- Helpdesk contact number
    EMERGENCY_NUMBER    VARCHAR2(15),              -- 24x7 emergency contact
    CUSTOMER_CARE_EMAIL VARCHAR2(100),             -- Customer care email address
    CUSTOMER_CARE_PHONE VARCHAR2(15),              -- Customer care phone number
    CONSTRAINT PK_HMS_HOSP_BRANCH  PRIMARY KEY (HOSPITAL_ID),
    CONSTRAINT FK_BRANCH_MASTER    FOREIGN KEY (HOSPITAL_CODE)
                                   REFERENCES HMS_HOSPITAL_MASTER (HOSPITAL_CODE)
);

COMMENT ON TABLE  HMS_HOSPITAL_BRANCH                        IS 'Detailed branch-level information for each HMS hospital location';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.HOSPITAL_ID            IS 'Surrogate primary key for each branch record';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.HOSPITAL_CODE          IS 'FK to HMS_HOSPITAL_MASTER; groups branches under a master hospital';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.BRANCH_NAME            IS 'Human-readable name of this specific branch';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.CITY                   IS 'City in which this branch operates';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.MANAGING_DIRECTOR      IS 'Full name of the branch Managing Director';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.HELPDESK_NUMBER        IS 'General helpdesk contact number for this branch';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.EMERGENCY_NUMBER       IS '24x7 emergency line number for this branch';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.CUSTOMER_CARE_EMAIL    IS 'Customer care email ID (single value)';
COMMENT ON COLUMN HMS_HOSPITAL_BRANCH.CUSTOMER_CARE_PHONE    IS 'Customer care phone number';


-- ===========================================================
-- TABLE 3: HMS_DEPARTMENT
-- Purpose : Each department within a hospital branch.
--           Stores bed availability and managing doctor info.
-- ===========================================================
CREATE TABLE HMS_DEPARTMENT (
    DEPARTMENT_ID       NUMBER(10)      NOT NULL,  -- Unique ID for the department
    HOSPITAL_ID         NUMBER(10)      NOT NULL,  -- FK -> HMS_HOSPITAL_BRANCH
    DEPARTMENT_NAME     VARCHAR2(100)   NOT NULL,  -- Name of the department (e.g., Orthopedics)
    DEPT_MANAGER        VARCHAR2(100),             -- Name of the department manager
    NUMBER_OF_BEDS      NUMBER(5)       DEFAULT 0, -- Total beds in this department
    CONSTRAINT PK_HMS_DEPARTMENT    PRIMARY KEY (DEPARTMENT_ID),
    CONSTRAINT FK_DEPT_BRANCH       FOREIGN KEY (HOSPITAL_ID)
                                    REFERENCES HMS_HOSPITAL_BRANCH (HOSPITAL_ID),
    CONSTRAINT CHK_BEDS_POSITIVE    CHECK (NUMBER_OF_BEDS >= 0)
);

COMMENT ON TABLE  HMS_DEPARTMENT                     IS 'Departments within each hospital branch; tracks bed capacity and management';
COMMENT ON COLUMN HMS_DEPARTMENT.DEPARTMENT_ID       IS 'Unique identifier for the department (PK)';
COMMENT ON COLUMN HMS_DEPARTMENT.HOSPITAL_ID         IS 'FK to HMS_HOSPITAL_BRANCH; identifies which branch this department belongs to';
COMMENT ON COLUMN HMS_DEPARTMENT.DEPARTMENT_NAME     IS 'Descriptive name of the department (e.g., Cardiology, ICU)';
COMMENT ON COLUMN HMS_DEPARTMENT.DEPT_MANAGER        IS 'Full name of the person managing this department';
COMMENT ON COLUMN HMS_DEPARTMENT.NUMBER_OF_BEDS      IS 'Total number of beds available in this department';


-- ===========================================================
-- TABLE 4: HMS_EMPLOYEES
-- Purpose : All staff members (doctors and non-doctor staff)
--           working across hospital branches.
-- ===========================================================
CREATE TABLE HMS_EMPLOYEES (
    EMPLOYEE_ID         NUMBER(10)      NOT NULL,  -- Unique employee identifier
    HOSPITAL_ID         NUMBER(10)      NOT NULL,  -- FK -> HMS_HOSPITAL_BRANCH (branch where they work)
    DEPARTMENT_ID       NUMBER(10),                -- FK -> HMS_DEPARTMENT (optional, for assigned dept)
    EMPLOYEE_FIRST_NAME VARCHAR2(50)    NOT NULL,  -- Employee's first name
    EMPLOYEE_LAST_NAME  VARCHAR2(50)    NOT NULL,  -- Employee's last name
    EMPLOYEE_TYPE       VARCHAR2(20)    NOT NULL,  -- Type: 'DOCTOR' or 'STAFF'
    EMAIL_ID            VARCHAR2(100),             -- Employee's email address
    CONSTRAINT PK_HMS_EMPLOYEES    PRIMARY KEY (EMPLOYEE_ID),
    CONSTRAINT FK_EMP_BRANCH       FOREIGN KEY (HOSPITAL_ID)
                                   REFERENCES HMS_HOSPITAL_BRANCH (HOSPITAL_ID),
    CONSTRAINT FK_EMP_DEPT         FOREIGN KEY (DEPARTMENT_ID)
                                   REFERENCES HMS_DEPARTMENT (DEPARTMENT_ID),
    CONSTRAINT CHK_EMP_TYPE        CHECK (EMPLOYEE_TYPE IN ('DOCTOR', 'STAFF'))
);

COMMENT ON TABLE  HMS_EMPLOYEES                      IS 'All employees (doctors and staff) across all hospital branches';
COMMENT ON COLUMN HMS_EMPLOYEES.EMPLOYEE_ID          IS 'Unique employee identifier (PK)';
COMMENT ON COLUMN HMS_EMPLOYEES.HOSPITAL_ID          IS 'FK to HMS_HOSPITAL_BRANCH; branch where the employee works';
COMMENT ON COLUMN HMS_EMPLOYEES.DEPARTMENT_ID        IS 'FK to HMS_DEPARTMENT; department the employee is assigned to (nullable for admin staff)';
COMMENT ON COLUMN HMS_EMPLOYEES.EMPLOYEE_FIRST_NAME  IS 'Employee first name';
COMMENT ON COLUMN HMS_EMPLOYEES.EMPLOYEE_LAST_NAME   IS 'Employee last name';
COMMENT ON COLUMN HMS_EMPLOYEES.EMPLOYEE_TYPE        IS 'Categorises the employee as DOCTOR or STAFF';
COMMENT ON COLUMN HMS_EMPLOYEES.EMAIL_ID             IS 'Official email address of the employee';


-- ===========================================================
-- TABLE 5: HMS_EMPLOYEE_PHONE_MST
-- Purpose : Stores multiple phone numbers per employee.
--           Each employee can have up to 2 phone numbers.
-- ===========================================================
CREATE TABLE HMS_EMPLOYEE_PHONE_MST (
    PHONE_RECORD_ID     NUMBER(10)      NOT NULL,  -- Surrogate PK for this phone record
    EMPLOYEE_ID         NUMBER(10)      NOT NULL,  -- FK -> HMS_EMPLOYEES
    PHONE1              VARCHAR2(15)    NOT NULL,  -- Primary phone number
    PHONE2              VARCHAR2(15),              -- Secondary phone number (optional)
    CONSTRAINT PK_EMP_PHONE     PRIMARY KEY (PHONE_RECORD_ID),
    CONSTRAINT FK_PHONE_EMP     FOREIGN KEY (EMPLOYEE_ID)
                                REFERENCES HMS_EMPLOYEES (EMPLOYEE_ID)
);

COMMENT ON TABLE  HMS_EMPLOYEE_PHONE_MST            IS 'Stores up to two phone numbers per employee';
COMMENT ON COLUMN HMS_EMPLOYEE_PHONE_MST.PHONE_RECORD_ID IS 'Surrogate PK for each phone record';
COMMENT ON COLUMN HMS_EMPLOYEE_PHONE_MST.EMPLOYEE_ID     IS 'FK to HMS_EMPLOYEES; which employee this phone belongs to';
COMMENT ON COLUMN HMS_EMPLOYEE_PHONE_MST.PHONE1          IS 'Primary contact phone number';
COMMENT ON COLUMN HMS_EMPLOYEE_PHONE_MST.PHONE2          IS 'Secondary contact phone number (optional)';


-- ===========================================================
-- TABLE 6: HMS_DOCTOR_AVAILABILITY
-- Purpose : Captures availability slots for each doctor
--           so patients can check which doctors are available.
-- ===========================================================
CREATE TABLE HMS_DOCTOR_AVAILABILITY (
    AVAILABILITY_ID     NUMBER(10)      NOT NULL,  -- Surrogate PK for availability record
    DOCTOR_ID           NUMBER(10)      NOT NULL,  -- FK -> HMS_EMPLOYEES (must be DOCTOR type)
    DOCTOR_DEPARTMENT   NUMBER(10)      NOT NULL,  -- FK -> HMS_DEPARTMENT
    AVAILABILITY_DAY    VARCHAR2(10)    NOT NULL,  -- Day of week (e.g., 'MONDAY')
    START_TIME          VARCHAR2(8)     NOT NULL,  -- Availability start time (HH:MI AM/PM)
    END_TIME            VARCHAR2(8)     NOT NULL,  -- Availability end time (HH:MI AM/PM)
    CONSTRAINT PK_HMS_DOC_AVAIL    PRIMARY KEY (AVAILABILITY_ID),
    CONSTRAINT FK_AVAIL_DOCTOR     FOREIGN KEY (DOCTOR_ID)
                                   REFERENCES HMS_EMPLOYEES (EMPLOYEE_ID),
    CONSTRAINT FK_AVAIL_DEPT       FOREIGN KEY (DOCTOR_DEPARTMENT)
                                   REFERENCES HMS_DEPARTMENT (DEPARTMENT_ID),
    CONSTRAINT CHK_AVAIL_DAY       CHECK (AVAILABILITY_DAY IN (
                                       'MONDAY','TUESDAY','WEDNESDAY',
                                       'THURSDAY','FRIDAY','SATURDAY','SUNDAY'))
);

COMMENT ON TABLE  HMS_DOCTOR_AVAILABILITY                IS 'Weekly availability schedule of doctors by department';
COMMENT ON COLUMN HMS_DOCTOR_AVAILABILITY.AVAILABILITY_ID     IS 'Surrogate PK for each availability slot';
COMMENT ON COLUMN HMS_DOCTOR_AVAILABILITY.DOCTOR_ID           IS 'FK to HMS_EMPLOYEES (DOCTOR type only)';
COMMENT ON COLUMN HMS_DOCTOR_AVAILABILITY.DOCTOR_DEPARTMENT   IS 'FK to HMS_DEPARTMENT; which department this slot is for';
COMMENT ON COLUMN HMS_DOCTOR_AVAILABILITY.AVAILABILITY_DAY    IS 'Day of the week for this availability slot';
COMMENT ON COLUMN HMS_DOCTOR_AVAILABILITY.START_TIME          IS 'Start time of the availability window (e.g., 09:00 AM)';
COMMENT ON COLUMN HMS_DOCTOR_AVAILABILITY.END_TIME            IS 'End time of the availability window (e.g., 05:00 PM)';


-- ===========================================================
-- TABLE 7: HMS_PATIENT
-- Purpose : Registered patients across all hospital branches.
--           Each patient has a unique ID and personal details.
-- ===========================================================
CREATE TABLE HMS_PATIENT (
    PATIENT_ID          NUMBER(10)      NOT NULL,  -- Unique patient identifier
    HOSPITAL_ID         NUMBER(10)      NOT NULL,  -- FK -> HMS_HOSPITAL_BRANCH
    DEPARTMENT_ID       NUMBER(10),                -- FK -> HMS_DEPARTMENT (admitted dept)
    PATIENT_FIRST_NAME  VARCHAR2(50)    NOT NULL,  -- Patient first name
    PATIENT_LAST_NAME   VARCHAR2(50)    NOT NULL,  -- Patient last name
    EMAIL_ID            VARCHAR2(100),             -- Patient's email address
    ADDRESS_STREET      VARCHAR2(100),             -- Street address
    ADDRESS_CITY        VARCHAR2(50),              -- City of residence
    ADDRESS_STATE       VARCHAR2(50),              -- State / Province
    ADDRESS_POSTAL_CODE VARCHAR2(10),              -- Postal / ZIP code
    CONSTRAINT PK_HMS_PATIENT       PRIMARY KEY (PATIENT_ID),
    CONSTRAINT FK_PATIENT_BRANCH    FOREIGN KEY (HOSPITAL_ID)
                                    REFERENCES HMS_HOSPITAL_BRANCH (HOSPITAL_ID),
    CONSTRAINT FK_PATIENT_DEPT      FOREIGN KEY (DEPARTMENT_ID)
                                    REFERENCES HMS_DEPARTMENT (DEPARTMENT_ID)
);

COMMENT ON TABLE  HMS_PATIENT                        IS 'Patient registry across all HMS hospital branches';
COMMENT ON COLUMN HMS_PATIENT.PATIENT_ID             IS 'Unique identifier for each patient (PK)';
COMMENT ON COLUMN HMS_PATIENT.HOSPITAL_ID            IS 'FK to HMS_HOSPITAL_BRANCH; branch where patient is registered';
COMMENT ON COLUMN HMS_PATIENT.DEPARTMENT_ID          IS 'FK to HMS_DEPARTMENT; department where the patient is admitted (nullable for outpatients)';
COMMENT ON COLUMN HMS_PATIENT.PATIENT_FIRST_NAME     IS 'Patient first name';
COMMENT ON COLUMN HMS_PATIENT.PATIENT_LAST_NAME      IS 'Patient last name';
COMMENT ON COLUMN HMS_PATIENT.EMAIL_ID               IS 'Patient email address for communications';
COMMENT ON COLUMN HMS_PATIENT.ADDRESS_STREET         IS 'Street portion of patient mailing address';
COMMENT ON COLUMN HMS_PATIENT.ADDRESS_CITY           IS 'City portion of patient mailing address';
COMMENT ON COLUMN HMS_PATIENT.ADDRESS_STATE          IS 'State or province of patient mailing address';
COMMENT ON COLUMN HMS_PATIENT.ADDRESS_POSTAL_CODE    IS 'Postal or ZIP code of patient mailing address';


-- ===========================================================
-- TABLE 8: HMS_PATIENT_PHONE_MST
-- Purpose : Stores one or more phone numbers per patient.
-- ===========================================================
CREATE TABLE HMS_PATIENT_PHONE_MST (
    PHONE_RECORD_ID     NUMBER(10)      NOT NULL,  -- Surrogate PK
    PATIENT_ID          NUMBER(10)      NOT NULL,  -- FK -> HMS_PATIENT
    PHONE_NUMBER        VARCHAR2(15)    NOT NULL,  -- Contact phone number
    PHONE_TYPE          VARCHAR2(10)    DEFAULT 'PRIMARY', -- Type: PRIMARY / SECONDARY
    CONSTRAINT PK_PAT_PHONE    PRIMARY KEY (PHONE_RECORD_ID),
    CONSTRAINT FK_PHONE_PAT    FOREIGN KEY (PATIENT_ID)
                               REFERENCES HMS_PATIENT (PATIENT_ID),
    CONSTRAINT CHK_PHONE_TYPE  CHECK (PHONE_TYPE IN ('PRIMARY', 'SECONDARY'))
);

COMMENT ON TABLE  HMS_PATIENT_PHONE_MST              IS 'Multiple contact phone numbers for a single patient';
COMMENT ON COLUMN HMS_PATIENT_PHONE_MST.PHONE_RECORD_ID IS 'Surrogate PK for each phone record';
COMMENT ON COLUMN HMS_PATIENT_PHONE_MST.PATIENT_ID      IS 'FK to HMS_PATIENT';
COMMENT ON COLUMN HMS_PATIENT_PHONE_MST.PHONE_NUMBER    IS 'Actual phone number string';
COMMENT ON COLUMN HMS_PATIENT_PHONE_MST.PHONE_TYPE      IS 'Classifies as PRIMARY or SECONDARY contact number';


-- ===========================================================
-- SEQUENCES: Auto-increment primary keys
-- ===========================================================
CREATE SEQUENCE HMS_HOSPITAL_BRANCH_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE HMS_DEPARTMENT_SEQ       START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE HMS_EMPLOYEES_SEQ        START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE HMS_EMP_PHONE_SEQ        START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE HMS_DOC_AVAIL_SEQ        START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE HMS_PATIENT_SEQ          START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE HMS_PAT_PHONE_SEQ        START WITH 1 INCREMENT BY 1 NOCACHE;

-- ============================================================
-- END OF FILE: HMS_CREATE_TABLES.sql
-- ============================================================
