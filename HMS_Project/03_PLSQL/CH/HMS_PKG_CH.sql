-- ============================================================
-- File        : HMS_PKG_CH.sql
-- Project     : Hospital Management System (HMS)
-- Member      : CH - Chandana (FND_USER.USER_ID = 1021034)
-- Description : PL/SQL Package containing all HMS procedures:
--               PROCEDURE 1 : GET_BRANCH_SUMMARY
--               PROCEDURE 2 : GET_EMPLOYEES_LIST
--               PROCEDURE 3 : GET_DEPT_PATIENTS
--               PROCEDURE 4 : LOAD_STAGING_TO_BASE
-- Schema      : APPS
-- Coding Std  : Oracle EBS R12 PL/SQL Standards
-- Date        : 2026-03-21
-- Version     : 2.0 (added staging load procedure + WHO columns)
-- ============================================================

-- ============================================================
-- PACKAGE SPECIFICATION
-- ============================================================
CREATE OR REPLACE PACKAGE HMS_PKG_CH AS
    C_USER_ID   CONSTANT NUMBER := 1021034;
    PROCEDURE GET_BRANCH_SUMMARY (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER);
    PROCEDURE GET_EMPLOYEES_LIST (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER);
    PROCEDURE GET_DEPT_PATIENTS  (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER, p_department_id IN NUMBER);
    PROCEDURE LOAD_STAGING_TO_BASE (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_batch_id IN VARCHAR2 DEFAULT NULL);
END HMS_PKG_CH;
/

-- ============================================================
-- PACKAGE BODY
-- ============================================================
CREATE OR REPLACE PACKAGE BODY HMS_PKG_CH AS

    PROCEDURE GET_BRANCH_SUMMARY (
        errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER
    ) AS
        v_patient_count   NUMBER := 0;
        v_dept_count      NUMBER := 0;
        v_doctor_count    NUMBER := 0;
        v_employee_count  NUMBER := 0;
        v_branch_name     HMS_HOSPITAL_BRANCH_CH.BRANCH_NAME%TYPE;
    BEGIN
        BEGIN
            SELECT BRANCH_NAME INTO v_branch_name
              FROM HMS_HOSPITAL_BRANCH_CH WHERE HOSPITAL_ID = p_hospital_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR: Hospital ID ' || p_hospital_id || ' not found.');
                RETURN;
        END;
        SELECT COUNT(*) INTO v_patient_count  FROM HMS_PATIENT_CH    WHERE HOSPITAL_ID = p_hospital_id;
        SELECT COUNT(*) INTO v_dept_count     FROM HMS_DEPARTMENT_CH WHERE HOSPITAL_ID = p_hospital_id;
        SELECT COUNT(*) INTO v_doctor_count   FROM HMS_EMPLOYEES_CH  WHERE HOSPITAL_ID = p_hospital_id AND EMPLOYEE_TYPE = 'DOCTOR';
        SELECT COUNT(*) INTO v_employee_count FROM HMS_EMPLOYEES_CH  WHERE HOSPITAL_ID = p_hospital_id;
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

    PROCEDURE GET_EMPLOYEES_LIST (
        errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER
    ) AS
        CURSOR c_employees IS
            SELECT  e.EMPLOYEE_ID, e.EMPLOYEE_FIRST_NAME, e.EMPLOYEE_LAST_NAME,
                    ep.PHONE1 AS PHONE_NUMBER, e.EMAIL_ID, e.EMPLOYEE_TYPE
              FROM  HMS_EMPLOYEES_CH e
              LEFT JOIN HMS_EMPLOYEE_PHONE_MST_CH ep ON e.EMPLOYEE_ID = ep.EMPLOYEE_ID
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
                RPAD(r.EMPLOYEE_ID, 10) || RPAD(r.EMPLOYEE_FIRST_NAME, 15) ||
                RPAD(r.EMPLOYEE_LAST_NAME, 15) || RPAD(NVL(r.PHONE_NUMBER, 'N/A'), 18) ||
                RPAD(r.EMPLOYEE_TYPE, 8) || NVL(r.EMAIL_ID, 'N/A'));
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

    PROCEDURE GET_DEPT_PATIENTS (
        errbuf OUT VARCHAR2, retcode OUT VARCHAR2,
        p_hospital_id IN NUMBER, p_department_id IN NUMBER
    ) AS
        v_branch_name   HMS_HOSPITAL_BRANCH_CH.BRANCH_NAME%TYPE;
        v_dept_name     HMS_DEPARTMENT_CH.DEPARTMENT_NAME%TYPE;
        v_row_count     NUMBER := 0;
        CURSOR c_patients IS
            SELECT  p.PATIENT_ID, p.PATIENT_FIRST_NAME, p.PATIENT_LAST_NAME,
                    p.PATIENT_PHONE_NUMBER AS PHONE_NUMBER, p.EMAIL_ID, p.ADDRESS_CITY
              FROM  HMS_PATIENT_CH p
             WHERE  p.HOSPITAL_ID = p_hospital_id AND p.DEPARTMENT_ID = p_department_id
             ORDER BY p.PATIENT_ID;
    BEGIN
        BEGIN
            SELECT BRANCH_NAME INTO v_branch_name FROM HMS_HOSPITAL_BRANCH_CH WHERE HOSPITAL_ID = p_hospital_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR: Hospital ID ' || p_hospital_id || ' not found.'); RETURN;
        END;
        BEGIN
            SELECT DEPARTMENT_NAME INTO v_dept_name FROM HMS_DEPARTMENT_CH
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
                RPAD(r.PATIENT_ID, 8) || RPAD(r.PATIENT_FIRST_NAME, 15) ||
                RPAD(r.PATIENT_LAST_NAME, 15) || RPAD(NVL(r.PHONE_NUMBER, 'N/A'), 16) ||
                RPAD(NVL(r.ADDRESS_CITY, 'N/A'), 12) || NVL(r.EMAIL_ID, 'N/A'));
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

    PROCEDURE LOAD_STAGING_TO_BASE (
        errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_batch_id IN VARCHAR2 DEFAULT NULL
    ) AS
        v_now          DATE   := SYSDATE;
        v_login_id     NUMBER := NVL(FND_GLOBAL.LOGIN_ID, -1);
        v_loaded_count NUMBER := 0;
        v_error_count  NUMBER := 0;
        v_error_msg    VARCHAR2(4000);
        v_dup_count    NUMBER;
        CURSOR c_hosp_master IS SELECT * FROM HMS_HOSPITAL_MASTER_STG_CH WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID;
        CURSOR c_dept        IS SELECT * FROM HMS_DEPARTMENT_STG_CH       WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID;
        CURSOR c_emp         IS SELECT * FROM HMS_EMPLOYEES_STG_CH        WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID;
        CURSOR c_pat         IS SELECT * FROM HMS_PATIENT_STG_CH          WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID;
    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '==============================================');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'STAGING-TO-BASE LOAD  |  Member: CH (Chandana)');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Run By (USER_ID) : ' || C_USER_ID);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Run Timestamp    : ' || TO_CHAR(v_now,'YYYY-MM-DD HH24:MI:SS'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Filter     : ' || NVL(p_batch_id, 'ALL NEW ROWS'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '----------------------------------------------');

        -- [1/4] Hospital Master
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[1/4] Processing HMS_HOSPITAL_MASTER_STG_CH ...');
        FOR r IN c_hosp_master LOOP
            v_error_msg := NULL;
            IF r.HOSPITAL_CODE IS NULL THEN v_error_msg := 'HOSPITAL_CODE is NULL. '; END IF;
            IF v_error_msg IS NULL THEN
                SELECT COUNT(*) INTO v_dup_count FROM HMS_HOSPITAL_MASTER_CH WHERE HOSPITAL_CODE = r.HOSPITAL_CODE;
                IF v_dup_count > 0 THEN v_error_msg := 'Duplicate HOSPITAL_CODE [' || r.HOSPITAL_CODE || '] already exists in base table. '; END IF;
            END IF;
            IF v_error_msg IS NULL AND NVL(r.HOSPITAL_BASIC_FEES, 0) <= 0 THEN v_error_msg := 'HOSPITAL_BASIC_FEES must be > 0. '; END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_HOSPITAL_MASTER_STG_CH SET RECORD_STATUS='ERROR', ERROR_LOG=v_error_msg, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_HOSPITAL_MASTER_CH (HOSPITAL_CODE, CITY_NAME, HOSPITAL_NAME, HOSPITAL_BASIC_FEES) VALUES (r.HOSPITAL_CODE, r.CITY_NAME, r.HOSPITAL_NAME, r.HOSPITAL_BASIC_FEES);
                UPDATE HMS_HOSPITAL_MASTER_STG_CH SET RECORD_STATUS='LOADED', ERROR_LOG=NULL, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- [1.5/4] Hospital Branch
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[1.5/4] Processing HMS_HOSPITAL_BRANCH_STG_CH ...');
        FOR r IN (SELECT * FROM HMS_HOSPITAL_BRANCH_STG_CH WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;
            IF r.HOSPITAL_CODE IS NULL OR r.BRANCH_NAME IS NULL THEN v_error_msg := 'HOSPITAL_CODE or BRANCH_NAME is NULL. '; END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_HOSPITAL_BRANCH_STG_CH SET RECORD_STATUS='ERROR', ERROR_LOG=v_error_msg, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_HOSPITAL_BRANCH_CH (HOSPITAL_ID, HOSPITAL_CODE, BRANCH_NAME, CITY, MANAGING_DIRECTOR, HELPDESK_NUMBER, EMERGENCY_NUMBER, CUSTOMER_CARE_EMAIL, CUSTOMER_CARE_PHONE)
                VALUES (r.HOSPITAL_ID, r.HOSPITAL_CODE, r.BRANCH_NAME, r.CITY, r.MANAGING_DIRECTOR, r.HELPDESK_NUMBER, r.EMERGENCY_NUMBER, r.CUSTOMER_CARE_EMAIL, r.CUSTOMER_CARE_PHONE);
                UPDATE HMS_HOSPITAL_BRANCH_STG_CH SET RECORD_STATUS='LOADED', ERROR_LOG=NULL, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- [2/4] Departments
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[2/4] Processing HMS_DEPARTMENT_STG_CH ...');
        FOR r IN c_dept LOOP
            v_error_msg := NULL;
            IF r.DEPARTMENT_NAME IS NULL THEN v_error_msg := 'DEPARTMENT_NAME is NULL. '; END IF;
            IF v_error_msg IS NULL AND NVL(r.NUMBER_OF_BEDS, -1) < 0 THEN v_error_msg := 'NUMBER_OF_BEDS cannot be negative. '; END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_DEPARTMENT_STG_CH SET RECORD_STATUS='ERROR', ERROR_LOG=v_error_msg, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_DEPARTMENT_CH (DEPARTMENT_ID, HOSPITAL_ID, DEPARTMENT_NAME, DEPT_MANAGER, NUMBER_OF_BEDS) VALUES (r.DEPARTMENT_ID, r.HOSPITAL_ID, r.DEPARTMENT_NAME, r.DEPT_MANAGER, NVL(r.NUMBER_OF_BEDS, 0));
                UPDATE HMS_DEPARTMENT_STG_CH SET RECORD_STATUS='LOADED', ERROR_LOG=NULL, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- [3/4] Employees
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[3/4] Processing HMS_EMPLOYEES_STG_CH ...');
        FOR r IN c_emp LOOP
            v_error_msg := NULL;
            IF r.EMPLOYEE_FIRST_NAME IS NULL OR r.EMPLOYEE_LAST_NAME IS NULL THEN v_error_msg := 'Employee name (first/last) cannot be NULL. '; END IF;
            IF v_error_msg IS NULL AND r.EMPLOYEE_TYPE NOT IN ('DOCTOR','STAFF') THEN v_error_msg := 'Invalid EMPLOYEE_TYPE [' || r.EMPLOYEE_TYPE || ']. Must be DOCTOR or STAFF. '; END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_EMPLOYEES_STG_CH SET RECORD_STATUS='ERROR', ERROR_LOG=v_error_msg, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_EMPLOYEES_CH (EMPLOYEE_ID, HOSPITAL_ID, DEPARTMENT_ID, EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME, EMPLOYEE_TYPE, EMAIL_ID) VALUES (r.EMPLOYEE_ID, r.HOSPITAL_ID, r.DEPARTMENT_ID, r.EMPLOYEE_FIRST_NAME, r.EMPLOYEE_LAST_NAME, r.EMPLOYEE_TYPE, r.EMAIL_ID);
                UPDATE HMS_EMPLOYEES_STG_CH SET RECORD_STATUS='LOADED', ERROR_LOG=NULL, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- [3.5/7] Employee Phone Master
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[3.5/7] Processing HMS_EMPLOYEE_PHONE_MST_STG_CH ...');
        FOR r IN (SELECT * FROM HMS_EMPLOYEE_PHONE_MST_STG_CH WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;
            IF r.PHONE_RECORD_ID IS NULL OR r.EMPLOYEE_ID IS NULL OR r.PHONE1 IS NULL THEN v_error_msg := 'PK, FK, or PHONE1 is NULL. '; END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_EMPLOYEE_PHONE_MST_STG_CH SET RECORD_STATUS='ERROR', ERROR_LOG=v_error_msg, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_EMPLOYEE_PHONE_MST_CH (PHONE_RECORD_ID, EMPLOYEE_ID, PHONE1, PHONE2) VALUES (r.PHONE_RECORD_ID, r.EMPLOYEE_ID, r.PHONE1, r.PHONE2);
                UPDATE HMS_EMPLOYEE_PHONE_MST_STG_CH SET RECORD_STATUS='LOADED', ERROR_LOG=NULL, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- [3.6/7] Doctor Availability
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[3.6/7] Processing HMS_DOCTOR_AVAILABILITY_STG_CH ...');
        FOR r IN (SELECT * FROM HMS_DOCTOR_AVAILABILITY_STG_CH WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;
            IF r.AVAILABILITY_ID IS NULL OR r.DOCTOR_ID IS NULL OR r.DOCTOR_DEPARTMENT IS NULL OR r.AVAILABILITY_DAY IS NULL OR r.START_TIME IS NULL OR r.END_TIME IS NULL THEN v_error_msg := 'One or more required fields is NULL. '; END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_DOCTOR_AVAILABILITY_STG_CH SET RECORD_STATUS='ERROR', ERROR_LOG=v_error_msg, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_DOCTOR_AVAILABILITY_CH (AVAILABILITY_ID, DOCTOR_ID, DOCTOR_DEPARTMENT, AVAILABILITY_DAY, START_TIME, END_TIME) VALUES (r.AVAILABILITY_ID, r.DOCTOR_ID, r.DOCTOR_DEPARTMENT, r.AVAILABILITY_DAY, r.START_TIME, r.END_TIME);
                UPDATE HMS_DOCTOR_AVAILABILITY_STG_CH SET RECORD_STATUS='LOADED', ERROR_LOG=NULL, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- [4/4] Patients
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '[4/4] Processing HMS_PATIENT_STG_CH ...');
        FOR r IN c_pat LOOP
            v_error_msg := NULL;
            IF r.PATIENT_FIRST_NAME IS NULL OR r.PATIENT_LAST_NAME IS NULL THEN v_error_msg := 'Patient name (first/last) cannot be NULL. '; END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_PATIENT_STG_CH SET RECORD_STATUS='ERROR', ERROR_LOG=v_error_msg, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_PATIENT_CH (PATIENT_ID, HOSPITAL_ID, DEPARTMENT_ID, PATIENT_FIRST_NAME, PATIENT_LAST_NAME, PATIENT_PHONE_NUMBER, EMAIL_ID, ADDRESS_STREET, ADDRESS_CITY, ADDRESS_STATE, ADDRESS_POSTAL_CODE)
                VALUES (r.PATIENT_ID, r.HOSPITAL_ID, r.DEPARTMENT_ID, r.PATIENT_FIRST_NAME, r.PATIENT_LAST_NAME, r.PATIENT_PHONE_NUMBER, r.EMAIL_ID, r.ADDRESS_STREET, r.ADDRESS_CITY, r.ADDRESS_STATE, r.ADDRESS_POSTAL_CODE);
                UPDATE HMS_PATIENT_STG_CH SET RECORD_STATUS='LOADED', ERROR_LOG=NULL, LAST_UPDATED_BY=C_USER_ID, LAST_UPDATE_DATE=v_now, LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

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

END HMS_PKG_CH;
/

-- ============================================================
-- HOW TO TEST (run in SQL Developer):
-- EXEC HMS_PKG_CH.GET_BRANCH_SUMMARY(1);
-- EXEC HMS_PKG_CH.GET_EMPLOYEES_LIST(1);
-- EXEC HMS_PKG_CH.GET_DEPT_PATIENTS(1, 1);
-- EXEC HMS_PKG_CH.LOAD_STAGING_TO_BASE();
-- EXEC HMS_PKG_CH.LOAD_STAGING_TO_BASE('BATCH_CH_20260321');
-- SELECT STG_ID, RECORD_STATUS, ERROR_LOG, LAST_UPDATED_BY, LAST_UPDATE_DATE
--   FROM HMS_HOSPITAL_MASTER_STG_CH ORDER BY STG_ID;
-- ============================================================
-- END OF FILE: HMS_PKG_CH.sql  |  Version 2.0  |  Member: CH
-- ============================================================
