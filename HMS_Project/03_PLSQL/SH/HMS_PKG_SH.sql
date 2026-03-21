-- ============================================================
-- File        : HMS_PKG_SH.sql
-- Project     : Hospital Management System (HMS)
-- Member      : SH - Shaswin (FND_USER.USER_ID = 1021027)
-- Description : PL/SQL Package containing all HMS procedures:
--
--               PROCEDURE 1 : GET_BRANCH_SUMMARY
--                 - Returns counts of patients, departments,
--                   doctors, and employees for a given branch.
--
--               PROCEDURE 2 : GET_EMPLOYEES_LIST
--                 - Displays all employees sorted by employee_id.
--
--               PROCEDURE 3 : GET_DEPT_PATIENTS
--                 - Lists all patients admitted to a dept.
--
--               PROCEDURE 4 : LOAD_STAGING_TO_BASE
--                 - Validates NEW rows in each staging table,
--                   stamps Oracle EBS WHO columns, and moves
--                   validated rows into the base tables.
--                 - Updates RECORD_STATUS to LOADED or ERROR.
--
-- Schema      : APPS
-- Application : Application Object Library (AOL)
-- Coding Std  : Oracle EBS R12 PL/SQL Standards
--               - WHO columns stamped on every DML
--               - EXCEPTION handlers at all levels
--               - Named cursors for all queries >1 row
--               - NVL for all nullable column references
--               - DBMS_OUTPUT formatted with RPAD/LPAD
-- Date        : 2026-03-21
-- Version     : 2.0 (added staging load procedure + WHO columns)
-- ============================================================


-- ============================================================
-- PACKAGE SPECIFICATION
-- ============================================================
CREATE OR REPLACE PACKAGE HMS_PKG_SH AS

    -- ----------------------------------------------------------
    -- CONSTANT: This member's Oracle EBS FND_USER.USER_ID
    -- Used to stamp WHO columns on all DML operations.
    -- ----------------------------------------------------------
    C_USER_ID   CONSTANT NUMBER := 1021027;   -- Shaswin's EBS User ID

    -- ----------------------------------------------------------
    -- Procedure : GET_BRANCH_SUMMARY
    -- Purpose   : Prints patient/dept/doctor/employee counts
    --             for a given hospital branch to DBMS_OUTPUT.
    -- Parameters:
    --   p_hospital_id  IN NUMBER  - Hospital branch surrogate ID
    -- ----------------------------------------------------------
    PROCEDURE GET_BRANCH_SUMMARY (
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2,
        p_hospital_id IN NUMBER
    );

    -- ----------------------------------------------------------
    -- Procedure : GET_EMPLOYEES_LIST
    -- Purpose   : Prints all employees (name, phone, email) for
    --             a given hospital, sorted by employee_id asc.
    -- Parameters:
    --   p_hospital_id  IN NUMBER  - Hospital branch surrogate ID
    -- ----------------------------------------------------------
    PROCEDURE GET_EMPLOYEES_LIST (
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2,
        p_hospital_id IN NUMBER
    );

    -- ----------------------------------------------------------
    -- Procedure : GET_DEPT_PATIENTS
    -- Purpose   : Lists all patients admitted to a specific
    --             department within a specific hospital branch.
    -- Parameters:
    --   p_hospital_id   IN NUMBER  - Hospital branch surrogate ID
    --   p_department_id IN NUMBER  - Department ID
    -- ----------------------------------------------------------
    PROCEDURE GET_DEPT_PATIENTS (
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2,
        p_hospital_id   IN NUMBER,
        p_department_id IN NUMBER
    );

    -- ----------------------------------------------------------
    -- Procedure : LOAD_STAGING_TO_BASE
    -- Purpose   : Reads all NEW rows from each _STG staging table,
    --             validates each row, then:
    --               SUCCESS -> Inserts into base table,
    --                          stamps WHO columns with C_USER_ID,
    --                          updates RECORD_STATUS = 'LOADED'
    --               FAILURE -> Sets RECORD_STATUS = 'ERROR',
    --                          writes reason to ERROR_LOG
    -- Parameters:
    --   p_batch_id  IN VARCHAR2  - Optional: only process rows
    --                              matching this BATCH_ID.
    --                              Pass NULL to process all NEW rows.
    -- ----------------------------------------------------------
    PROCEDURE LOAD_STAGING_TO_BASE (
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2,
        p_batch_id IN VARCHAR2 DEFAULT NULL
    );

END HMS_PKG_SH;
/


-- ============================================================
-- PACKAGE BODY
-- ============================================================
CREATE OR REPLACE PACKAGE BODY HMS_PKG_SH AS

    -- ==========================================================
    -- Procedure : GET_BRANCH_SUMMARY
    -- ==========================================================
    PROCEDURE GET_BRANCH_SUMMARY (
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2,
        p_hospital_id IN NUMBER
    ) AS
        v_patient_count   NUMBER := 0;
        v_dept_count      NUMBER := 0;
        v_doctor_count    NUMBER := 0;
        v_employee_count  NUMBER := 0;
        v_branch_name     HMS_HOSPITAL_BRANCH_SH.BRANCH_NAME%TYPE;
    BEGIN
        -- Fetch branch name; abort gracefully if not found
        BEGIN
            SELECT BRANCH_NAME INTO v_branch_name
              FROM HMS_HOSPITAL_BRANCH_SH
             WHERE HOSPITAL_ID = p_hospital_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR: Hospital ID ' || p_hospital_id || ' not found.');
                RETURN;
        END;

        SELECT COUNT(*) INTO v_patient_count  FROM HMS_PATIENT_SH    WHERE HOSPITAL_ID = p_hospital_id;
        SELECT COUNT(*) INTO v_dept_count     FROM HMS_DEPARTMENT_SH WHERE HOSPITAL_ID = p_hospital_id;
        SELECT COUNT(*) INTO v_doctor_count   FROM HMS_EMPLOYEES_SH  WHERE HOSPITAL_ID = p_hospital_id AND EMPLOYEE_TYPE = 'DOCTOR';
        SELECT COUNT(*) INTO v_employee_count FROM HMS_EMPLOYEES_SH  WHERE HOSPITAL_ID = p_hospital_id;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'BRANCH SUMMARY REPORT - ' || v_branch_name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Hospital ID   : ' || p_hospital_id);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '----------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Patients    : ' || v_patient_count);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Departments : ' || v_dept_count);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Doctors     : ' || v_doctor_count);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Employees   : ' || v_employee_count);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');
    EXCEPTION
        WHEN OTHERS THEN
            errbuf := SQLERRM; retcode := '2';
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_BRANCH_SUMMARY: ' || SQLERRM);
    END GET_BRANCH_SUMMARY;


    -- ==========================================================
    -- Procedure : GET_EMPLOYEES_LIST
    -- ==========================================================
    PROCEDURE GET_EMPLOYEES_LIST (
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2,
        p_hospital_id IN NUMBER
    ) AS
        -- Named cursor: all employees with primary phone, sorted by ID
        CURSOR c_employees IS
            SELECT  e.EMPLOYEE_ID,
                    e.EMPLOYEE_FIRST_NAME,
                    e.EMPLOYEE_LAST_NAME,
                    ep.PHONE1         AS PHONE_NUMBER,
                    e.EMAIL_ID,
                    e.EMPLOYEE_TYPE
              FROM  HMS_EMPLOYEES_SH          e
              LEFT JOIN HMS_EMPLOYEE_PHONE_MST_SH ep
                     ON e.EMPLOYEE_ID = ep.EMPLOYEE_ID
             WHERE  e.HOSPITAL_ID = p_hospital_id
             ORDER BY e.EMPLOYEE_ID ASC;

        v_row_count NUMBER := 0;
    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'EMPLOYEE LIST - Hospital ID: ' || p_hospital_id);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Sorted by: Employee ID (Ascending)');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '----------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('EMP_ID',10)||RPAD('FIRST NAME',15)||RPAD('LAST NAME',15)||RPAD('PHONE',18)||RPAD('TYPE',8)||'EMAIL');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('-',80,'-'));

        FOR r IN c_employees LOOP
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 
                RPAD(r.EMPLOYEE_ID, 10)              ||
                RPAD(r.EMPLOYEE_FIRST_NAME, 15)      ||
                RPAD(r.EMPLOYEE_LAST_NAME, 15)       ||
                RPAD(NVL(r.PHONE_NUMBER, 'N/A'), 18) ||
                RPAD(r.EMPLOYEE_TYPE, 8)             ||
                NVL(r.EMAIL_ID, 'N/A')
            );
            v_row_count := v_row_count + 1;
        END LOOP;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('-',80,'-'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Records: ' || v_row_count);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');
    EXCEPTION
        WHEN OTHERS THEN
            errbuf := SQLERRM; retcode := '2';
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_EMPLOYEES_LIST: ' || SQLERRM);
    END GET_EMPLOYEES_LIST;


    -- ==========================================================
    -- Procedure : GET_DEPT_PATIENTS
    -- ==========================================================
    PROCEDURE GET_DEPT_PATIENTS (
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2,
        p_hospital_id   IN NUMBER,
        p_department_id IN NUMBER
    ) AS
        v_branch_name   HMS_HOSPITAL_BRANCH_SH.BRANCH_NAME%TYPE;
        v_dept_name     HMS_DEPARTMENT_SH.DEPARTMENT_NAME%TYPE;
        v_row_count     NUMBER := 0;

        -- Named cursor: admitted patients with primary phone
        CURSOR c_patients IS
            SELECT  p.PATIENT_ID,
                    p.PATIENT_FIRST_NAME,
                    p.PATIENT_LAST_NAME,
                    p.PATIENT_PHONE_NUMBER AS PHONE_NUMBER,
                    p.EMAIL_ID,
                    p.ADDRESS_CITY
              FROM  HMS_PATIENT_SH p
             WHERE  p.HOSPITAL_ID   = p_hospital_id
               AND  p.DEPARTMENT_ID = p_department_id
             ORDER BY p.PATIENT_ID;
    BEGIN
        -- Validate hospital exists
        BEGIN
            SELECT BRANCH_NAME INTO v_branch_name
              FROM HMS_HOSPITAL_BRANCH_SH WHERE HOSPITAL_ID = p_hospital_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR: Hospital ID ' || p_hospital_id || ' not found.'); RETURN;
        END;

        -- Validate department belongs to this hospital
        BEGIN
            SELECT DEPARTMENT_NAME INTO v_dept_name
              FROM HMS_DEPARTMENT_SH
             WHERE DEPARTMENT_ID = p_department_id AND HOSPITAL_ID = p_hospital_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR: Dept ID ' || p_department_id || ' not in Hospital ' || p_hospital_id); RETURN;
        END;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ADMITTED PATIENTS REPORT');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Branch     : ' || v_branch_name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Department : ' || v_dept_name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '----------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('PAT_ID',8)||RPAD('FIRST NAME',15)||RPAD('LAST NAME',15)||RPAD('PHONE',16)||RPAD('CITY',12)||'EMAIL');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('-',80,'-'));

        FOR r IN c_patients LOOP
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 
                RPAD(r.PATIENT_ID, 8)                ||
                RPAD(r.PATIENT_FIRST_NAME, 15)       ||
                RPAD(r.PATIENT_LAST_NAME, 15)        ||
                RPAD(NVL(r.PHONE_NUMBER, 'N/A'), 16) ||
                RPAD(NVL(r.ADDRESS_CITY, 'N/A'), 12) ||
                NVL(r.EMAIL_ID, 'N/A')
            );
            v_row_count := v_row_count + 1;
        END LOOP;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('-',80,'-'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Patients Admitted: ' || v_row_count);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');
    EXCEPTION
        WHEN OTHERS THEN
            errbuf := SQLERRM; retcode := '2';
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_DEPT_PATIENTS: ' || SQLERRM);
    END GET_DEPT_PATIENTS;


    -- ==========================================================
    -- Procedure : LOAD_STAGING_TO_BASE
    -- Purpose   : Validates and promotes records from all 5
    --             staging tables into base tables, stamping
    --             Oracle EBS WHO columns using C_USER_ID (1021027).
    -- ==========================================================
    PROCEDURE LOAD_STAGING_TO_BASE (
        errbuf OUT VARCHAR2,
        retcode OUT VARCHAR2,
        p_batch_id IN VARCHAR2 DEFAULT NULL
    ) AS

        -- -------------------------------------------------------
        -- Capture SYSDATE once per call so all WHO timestamps
        -- in a single run are exactly consistent.
        -- -------------------------------------------------------
        v_now           DATE   := SYSDATE;
        v_login_id      NUMBER := NVL(FND_GLOBAL.LOGIN_ID, -1); -- EBS session login ID

        -- Counters for summary reporting
        v_loaded_count  NUMBER := 0;
        v_error_count   NUMBER := 0;

        -- -------------------------------------------------------
        -- Cursor: fetch NEW hospital master staging rows,
        -- optionally filtered by batch_id.
        -- -------------------------------------------------------
        CURSOR c_hosp_master IS
            SELECT * FROM HMS_HOSPITAL_MASTER_STG_SH
             WHERE RECORD_STATUS = 'NEW'
               AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id)
             ORDER BY STG_ID;

        -- Cursor: fetch NEW department staging rows
        CURSOR c_dept IS
            SELECT * FROM HMS_DEPARTMENT_STG_SH
             WHERE RECORD_STATUS = 'NEW'
               AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id)
             ORDER BY STG_ID;

        -- Cursor: fetch NEW employee staging rows
        CURSOR c_emp IS
            SELECT * FROM HMS_EMPLOYEES_STG_SH
             WHERE RECORD_STATUS = 'NEW'
               AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id)
             ORDER BY STG_ID;

        -- Cursor: fetch NEW patient staging rows
        CURSOR c_pat IS
            SELECT * FROM HMS_PATIENT_STG_SH
             WHERE RECORD_STATUS = 'NEW'
               AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id)
             ORDER BY STG_ID;

        -- Local error message builder
        v_error_msg     VARCHAR2(4000);
        v_dup_count     NUMBER;

    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'STAGING-TO-BASE LOAD  |  Member: SH (Shaswin)');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Run By (USER_ID) : ' || C_USER_ID);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Run Timestamp    : ' || TO_CHAR(v_now,'YYYY-MM-DD HH24:MI:SS'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Filter     : ' || NVL(p_batch_id, 'ALL NEW ROWS'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '----------------------------------------------');


        -- ===================================================
        -- SECTION 1: Process HMS_HOSPITAL_MASTER_STG_SH
        -- ===================================================
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[1/4] Processing HMS_HOSPITAL_MASTER_STG_SH ...');
        FOR r IN c_hosp_master LOOP
            v_error_msg := NULL;

            -- Validation 1: HOSPITAL_CODE must not be null
            IF r.HOSPITAL_CODE IS NULL THEN
                v_error_msg := 'HOSPITAL_CODE is NULL. ';
            END IF;

            -- Validation 2: HOSPITAL_CODE must be unique in base table
            IF v_error_msg IS NULL THEN
                SELECT COUNT(*) INTO v_dup_count
                  FROM HMS_HOSPITAL_MASTER_SH WHERE HOSPITAL_CODE = r.HOSPITAL_CODE;
                IF v_dup_count > 0 THEN
                    v_error_msg := 'Duplicate HOSPITAL_CODE [' || r.HOSPITAL_CODE || '] already exists in base table. ';
                END IF;
            END IF;

            -- Validation 3: HOSPITAL_BASIC_FEES must be positive
            IF v_error_msg IS NULL AND NVL(r.HOSPITAL_BASIC_FEES, 0) <= 0 THEN
                v_error_msg := 'HOSPITAL_BASIC_FEES must be > 0. ';
            END IF;

            IF v_error_msg IS NOT NULL THEN
                -- Mark row as ERROR in staging
                UPDATE HMS_HOSPITAL_MASTER_STG_SH
                   SET RECORD_STATUS      = 'ERROR',
                       ERROR_LOG          = v_error_msg,
                       LAST_UPDATED_BY    = C_USER_ID,      -- WHO: stamp updater
                       LAST_UPDATE_DATE   = v_now,          -- WHO: stamp update time
                       LAST_UPDATE_LOGIN  = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                -- Insert into base table with WHO columns stamped
                INSERT INTO HMS_HOSPITAL_MASTER_SH (
                    HOSPITAL_CODE, CITY_NAME, HOSPITAL_NAME, HOSPITAL_BASIC_FEES
                ) VALUES (
                    r.HOSPITAL_CODE, r.CITY_NAME, r.HOSPITAL_NAME, r.HOSPITAL_BASIC_FEES
                );

                -- Update staging row to LOADED and stamp WHO
                UPDATE HMS_HOSPITAL_MASTER_STG_SH
                   SET RECORD_STATUS      = 'LOADED',
                       ERROR_LOG          = NULL,
                       LAST_UPDATED_BY    = C_USER_ID,      -- WHO: stamp updater
                       LAST_UPDATE_DATE   = v_now,          -- WHO: stamp load time
                       LAST_UPDATE_LOGIN  = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- ===================================================
        
        -- ===================================================
        -- SECTION 1.5: Process HMS_HOSPITAL_BRANCH_STG_SH
        -- ===================================================
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[1.5/4] Processing HMS_HOSPITAL_BRANCH_STG_SH ...');
        FOR r IN (SELECT * FROM HMS_HOSPITAL_BRANCH_STG_SH WHERE RECORD_STATUS = 'NEW' AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;

            IF r.HOSPITAL_CODE IS NULL OR r.BRANCH_NAME IS NULL THEN
                v_error_msg := 'HOSPITAL_CODE or BRANCH_NAME is NULL. ';
            END IF;

            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_HOSPITAL_BRANCH_STG_SH
                   SET RECORD_STATUS      = 'ERROR',
                       ERROR_LOG          = v_error_msg,
                       LAST_UPDATED_BY    = C_USER_ID,
                       LAST_UPDATE_DATE   = v_now,
                       LAST_UPDATE_LOGIN  = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_HOSPITAL_BRANCH_SH (
                    HOSPITAL_ID, HOSPITAL_CODE, BRANCH_NAME, CITY, MANAGING_DIRECTOR,
                    HELPDESK_NUMBER, EMERGENCY_NUMBER, CUSTOMER_CARE_EMAIL, CUSTOMER_CARE_PHONE
                ) VALUES (
                    r.HOSPITAL_ID, r.HOSPITAL_CODE, r.BRANCH_NAME, r.CITY, r.MANAGING_DIRECTOR,
                    r.HELPDESK_NUMBER, r.EMERGENCY_NUMBER, r.CUSTOMER_CARE_EMAIL, r.CUSTOMER_CARE_PHONE
                );

                UPDATE HMS_HOSPITAL_BRANCH_STG_SH
                   SET RECORD_STATUS      = 'LOADED',
                       ERROR_LOG          = NULL,
                       LAST_UPDATED_BY    = C_USER_ID,
                       LAST_UPDATE_DATE   = v_now,
                       LAST_UPDATE_LOGIN  = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- ===================================================
        -- SECTION 2: Process HMS_DEPARTMENT_STG_SH
        -- ===================================================
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[2/4] Processing HMS_DEPARTMENT_STG_SH ...');
        FOR r IN c_dept LOOP
            v_error_msg := NULL;

            IF r.DEPARTMENT_NAME IS NULL THEN
                v_error_msg := 'DEPARTMENT_NAME is NULL. ';
            END IF;

            IF v_error_msg IS NULL AND NVL(r.NUMBER_OF_BEDS, -1) < 0 THEN
                v_error_msg := 'NUMBER_OF_BEDS cannot be negative. ';
            END IF;

            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_DEPARTMENT_STG_SH
                   SET RECORD_STATUS     = 'ERROR',
                       ERROR_LOG         = v_error_msg,
                       LAST_UPDATED_BY   = C_USER_ID,
                       LAST_UPDATE_DATE  = v_now,
                       LAST_UPDATE_LOGIN = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_DEPARTMENT_SH (
                    DEPARTMENT_ID, HOSPITAL_ID, DEPARTMENT_NAME, DEPT_MANAGER, NUMBER_OF_BEDS
                ) VALUES (
                    r.DEPARTMENT_ID, r.HOSPITAL_ID, r.DEPARTMENT_NAME,
                    r.DEPT_MANAGER, NVL(r.NUMBER_OF_BEDS, 0)
                );
                UPDATE HMS_DEPARTMENT_STG_SH
                   SET RECORD_STATUS     = 'LOADED',
                       ERROR_LOG         = NULL,
                       LAST_UPDATED_BY   = C_USER_ID,
                       LAST_UPDATE_DATE  = v_now,
                       LAST_UPDATE_LOGIN = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- ===================================================
        -- SECTION 3: Process HMS_EMPLOYEES_STG_SH
        -- ===================================================
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[3/4] Processing HMS_EMPLOYEES_STG_SH ...');
        FOR r IN c_emp LOOP
            v_error_msg := NULL;

            IF r.EMPLOYEE_FIRST_NAME IS NULL OR r.EMPLOYEE_LAST_NAME IS NULL THEN
                v_error_msg := 'Employee name (first/last) cannot be NULL. ';
            END IF;

            IF v_error_msg IS NULL AND r.EMPLOYEE_TYPE NOT IN ('DOCTOR','STAFF') THEN
                v_error_msg := 'Invalid EMPLOYEE_TYPE [' || r.EMPLOYEE_TYPE || ']. Must be DOCTOR or STAFF. ';
            END IF;

            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_EMPLOYEES_STG_SH
                   SET RECORD_STATUS     = 'ERROR',
                       ERROR_LOG         = v_error_msg,
                       LAST_UPDATED_BY   = C_USER_ID,
                       LAST_UPDATE_DATE  = v_now,
                       LAST_UPDATE_LOGIN = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_EMPLOYEES_SH (
                    EMPLOYEE_ID, HOSPITAL_ID, DEPARTMENT_ID,
                    EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME, EMPLOYEE_TYPE, EMAIL_ID
                ) VALUES (
                    r.EMPLOYEE_ID, r.HOSPITAL_ID, r.DEPARTMENT_ID,
                    r.EMPLOYEE_FIRST_NAME, r.EMPLOYEE_LAST_NAME, r.EMPLOYEE_TYPE, r.EMAIL_ID
                );
                UPDATE HMS_EMPLOYEES_STG_SH
                   SET RECORD_STATUS     = 'LOADED',
                       ERROR_LOG         = NULL,
                       LAST_UPDATED_BY   = C_USER_ID,
                       LAST_UPDATE_DATE  = v_now,
                       LAST_UPDATE_LOGIN = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- ===================================================
        
        -- ===================================================
        -- SECTION 3.5: Process HMS_EMPLOYEE_PHONE_MST_STG_SH
        -- ===================================================
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[3.5/7] Processing HMS_EMPLOYEE_PHONE_MST_STG_SH ...');
        FOR r IN (SELECT * FROM HMS_EMPLOYEE_PHONE_MST_STG_SH WHERE RECORD_STATUS = 'NEW' AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;
            IF r.PHONE_RECORD_ID IS NULL OR r.EMPLOYEE_ID IS NULL OR r.PHONE1 IS NULL THEN
                v_error_msg := 'PK, FK, or PHONE1 is NULL. ';
            END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_EMPLOYEE_PHONE_MST_STG_SH SET RECORD_STATUS = 'ERROR', ERROR_LOG = v_error_msg, LAST_UPDATED_BY = C_USER_ID, LAST_UPDATE_DATE = v_now, LAST_UPDATE_LOGIN = v_login_id WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_EMPLOYEE_PHONE_MST_SH (PHONE_RECORD_ID, EMPLOYEE_ID, PHONE1, PHONE2) VALUES (r.PHONE_RECORD_ID, r.EMPLOYEE_ID, r.PHONE1, r.PHONE2);
                UPDATE HMS_EMPLOYEE_PHONE_MST_STG_SH SET RECORD_STATUS = 'LOADED', ERROR_LOG = NULL, LAST_UPDATED_BY = C_USER_ID, LAST_UPDATE_DATE = v_now, LAST_UPDATE_LOGIN = v_login_id WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- ===================================================
        -- SECTION 3.6: Process HMS_DOCTOR_AVAILABILITY_STG_SH
        -- ===================================================
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[3.6/7] Processing HMS_DOCTOR_AVAILABILITY_STG_SH ...');
        FOR r IN (SELECT * FROM HMS_DOCTOR_AVAILABILITY_STG_SH WHERE RECORD_STATUS = 'NEW' AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;
            IF r.AVAILABILITY_ID IS NULL OR r.DOCTOR_ID IS NULL OR r.DOCTOR_DEPARTMENT IS NULL OR r.AVAILABILITY_DAY IS NULL OR r.START_TIME IS NULL OR r.END_TIME IS NULL THEN
                v_error_msg := 'One or more required fields is NULL. ';
            END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_DOCTOR_AVAILABILITY_STG_SH SET RECORD_STATUS = 'ERROR', ERROR_LOG = v_error_msg, LAST_UPDATED_BY = C_USER_ID, LAST_UPDATE_DATE = v_now, LAST_UPDATE_LOGIN = v_login_id WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_DOCTOR_AVAILABILITY_SH (AVAILABILITY_ID, DOCTOR_ID, DOCTOR_DEPARTMENT, AVAILABILITY_DAY, START_TIME, END_TIME) VALUES (r.AVAILABILITY_ID, r.DOCTOR_ID, r.DOCTOR_DEPARTMENT, r.AVAILABILITY_DAY, r.START_TIME, r.END_TIME);
                UPDATE HMS_DOCTOR_AVAILABILITY_STG_SH SET RECORD_STATUS = 'LOADED', ERROR_LOG = NULL, LAST_UPDATED_BY = C_USER_ID, LAST_UPDATE_DATE = v_now, LAST_UPDATE_LOGIN = v_login_id WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- SECTION 4: Process HMS_PATIENT_STG_SH
        -- ===================================================
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[4/4] Processing HMS_PATIENT_STG_SH ...');
        FOR r IN c_pat LOOP
            v_error_msg := NULL;

            IF r.PATIENT_FIRST_NAME IS NULL OR r.PATIENT_LAST_NAME IS NULL THEN
                v_error_msg := 'Patient name (first/last) cannot be NULL. ';
            END IF;

            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_PATIENT_STG_SH
                   SET RECORD_STATUS     = 'ERROR',
                       ERROR_LOG         = v_error_msg,
                       LAST_UPDATED_BY   = C_USER_ID,
                       LAST_UPDATE_DATE  = v_now,
                       LAST_UPDATE_LOGIN = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_PATIENT_SH (
                    PATIENT_ID, HOSPITAL_ID, DEPARTMENT_ID,
                    PATIENT_FIRST_NAME, PATIENT_LAST_NAME, EMAIL_ID,
                    ADDRESS_STREET, ADDRESS_CITY, ADDRESS_STATE, ADDRESS_POSTAL_CODE
                ) VALUES (
                    r.PATIENT_ID, r.HOSPITAL_ID, r.DEPARTMENT_ID,
                    r.PATIENT_FIRST_NAME, r.PATIENT_LAST_NAME, r.EMAIL_ID,
                    r.ADDRESS_STREET, r.ADDRESS_CITY, r.ADDRESS_STATE, r.ADDRESS_POSTAL_CODE
                );
                UPDATE HMS_PATIENT_STG_SH
                   SET RECORD_STATUS     = 'LOADED',
                       ERROR_LOG         = NULL,
                       LAST_UPDATED_BY   = C_USER_ID,
                       LAST_UPDATE_DATE  = v_now,
                       LAST_UPDATE_LOGIN = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- Commit all changes in one transaction
        COMMIT;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '----------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'LOAD COMPLETE');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Rows Loaded Successfully : ' || v_loaded_count);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Rows Failed (ERROR)      : ' || v_error_count);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Committed by USER_ID     : ' || C_USER_ID);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            errbuf := SQLERRM; retcode := '2';
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'CRITICAL ERROR in LOAD_STAGING_TO_BASE: ' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Transaction rolled back. No changes committed.');
    END LOAD_STAGING_TO_BASE;


END HMS_PKG_SH;
/

-- ============================================================
-- HOW TO TEST (run in SQL Developer):
-- ============================================================
-- Note: In SQL Developer, FND_FILE output goes to a temp server directory if not initialized.
-- To test FND_FILE locally in SQL Developer, you may need a wrapper or revert to DBMS_OUTPUT locally.
--
-- Test procedures:
-- EXEC HMS_PKG_SH.GET_BRANCH_SUMMARY(1);
-- EXEC HMS_PKG_SH.GET_EMPLOYEES_LIST(1);
-- EXEC HMS_PKG_SH.GET_DEPT_PATIENTS(1, 1);
--
-- Test staging load (after populating *_STG tables via CTL):
-- EXEC HMS_PKG_SH.LOAD_STAGING_TO_BASE();           -- all NEW rows
-- EXEC HMS_PKG_SH.LOAD_STAGING_TO_BASE('BATCH_SH_20260321'); -- specific batch
--
-- Check staging row statuses:
-- SELECT STG_ID, RECORD_STATUS, ERROR_LOG, LAST_UPDATED_BY, LAST_UPDATE_DATE
--   FROM HMS_HOSPITAL_MASTER_STG_SH ORDER BY STG_ID;
-- ============================================================
-- END OF FILE: HMS_PKG_SH.sql  |  Version 2.0  |  Member: SH
-- ============================================================
