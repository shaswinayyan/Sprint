-- ============================================================
-- File        : HMS_PKG_NM.sql
-- Project     : Hospital Management System (HMS)
-- Member      : NM - Namitha
--               FND_USER.USER_ID = <NAMITHA_USER_ID>
--               Replace the C_USER_ID constant value below
--               with Namitha's actual Oracle EBS User ID.
-- Description : PL/SQL Package - all 4 HMS procedures.
--               GET_BRANCH_SUMMARY, GET_EMPLOYEES_LIST,
--               GET_DEPT_PATIENTS, LOAD_STAGING_TO_BASE.
--               WHO columns stamped using C_USER_ID on all DML.
-- Schema      : APPS
-- Application : Application Object Library (AOL)
-- Coding Std  : Oracle EBS R12 PL/SQL Standards
-- Date        : 2026-03-21
-- Version     : 2.0 (WHO columns + staging load)
-- ============================================================

CREATE OR REPLACE PACKAGE HMS_PKG_NM AS

    -- IMPORTANT: Replace with Namitha's actual EBS FND_USER.USER_ID
    C_USER_ID   CONSTANT NUMBER := 0;   -- TODO: Namitha to update this value

    PROCEDURE GET_BRANCH_SUMMARY  (p_hospital_id   IN NUMBER);
    PROCEDURE GET_EMPLOYEES_LIST  (p_hospital_id   IN NUMBER);
    PROCEDURE GET_DEPT_PATIENTS   (p_hospital_id   IN NUMBER,
                                   p_department_id IN NUMBER);
    PROCEDURE LOAD_STAGING_TO_BASE (p_batch_id IN VARCHAR2 DEFAULT NULL);

END HMS_PKG_NM;
/


CREATE OR REPLACE PACKAGE BODY HMS_PKG_NM AS

    -- ==========================================================
    -- Procedure: GET_BRANCH_SUMMARY
    -- ==========================================================
    PROCEDURE GET_BRANCH_SUMMARY (p_hospital_id IN NUMBER) AS
        v_patient_count   NUMBER := 0;
        v_dept_count      NUMBER := 0;
        v_doctor_count    NUMBER := 0;
        v_employee_count  NUMBER := 0;
        v_branch_name     HMS_HOSPITAL_BRANCH_NM.BRANCH_NAME%TYPE;
    BEGIN
        BEGIN SELECT BRANCH_NAME INTO v_branch_name FROM HMS_HOSPITAL_BRANCH_NM WHERE HOSPITAL_ID = p_hospital_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('ERROR: Hospital ID ' || p_hospital_id || ' not found.'); RETURN;
        END;
        SELECT COUNT(*) INTO v_patient_count  FROM HMS_PATIENT_NM    WHERE HOSPITAL_ID = p_hospital_id;
        SELECT COUNT(*) INTO v_dept_count     FROM HMS_DEPARTMENT_NM WHERE HOSPITAL_ID = p_hospital_id;
        SELECT COUNT(*) INTO v_doctor_count   FROM HMS_EMPLOYEES_NM  WHERE HOSPITAL_ID = p_hospital_id AND EMPLOYEE_TYPE = 'DOCTOR';
        SELECT COUNT(*) INTO v_employee_count FROM HMS_EMPLOYEES_NM  WHERE HOSPITAL_ID = p_hospital_id;
        DBMS_OUTPUT.PUT_LINE('==============================================');
        DBMS_OUTPUT.PUT_LINE('BRANCH SUMMARY REPORT - ' || v_branch_name);
        DBMS_OUTPUT.PUT_LINE('Hospital ID   : ' || p_hospital_id);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Total Patients    : ' || v_patient_count);
        DBMS_OUTPUT.PUT_LINE('Total Departments : ' || v_dept_count);
        DBMS_OUTPUT.PUT_LINE('Total Doctors     : ' || v_doctor_count);
        DBMS_OUTPUT.PUT_LINE('Total Employees   : ' || v_employee_count);
        DBMS_OUTPUT.PUT_LINE('==============================================');
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR in GET_BRANCH_SUMMARY: ' || SQLERRM);
    END GET_BRANCH_SUMMARY;

    -- ==========================================================
    -- Procedure: GET_EMPLOYEES_LIST
    -- ==========================================================
    PROCEDURE GET_EMPLOYEES_LIST (p_hospital_id IN NUMBER) AS
        -- Named cursor: employees with primary phone, sorted by ID
        CURSOR c_employees IS
            SELECT  e.EMPLOYEE_ID, e.EMPLOYEE_FIRST_NAME, e.EMPLOYEE_LAST_NAME,
                    ep.PHONE1 AS PHONE_NUMBER, e.EMAIL_ID, e.EMPLOYEE_TYPE
              FROM  HMS_EMPLOYEES_NM e
              LEFT JOIN HMS_EMPLOYEE_PHONE_MST_NM ep ON e.EMPLOYEE_ID = ep.EMPLOYEE_ID
             WHERE  e.HOSPITAL_ID = p_hospital_id
             ORDER BY e.EMPLOYEE_ID ASC;
        v_row_count NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('==============================================');
        DBMS_OUTPUT.PUT_LINE('EMPLOYEE LIST - Hospital ID: ' || p_hospital_id);
        DBMS_OUTPUT.PUT_LINE(RPAD('EMP_ID',10)||RPAD('FIRST NAME',15)||RPAD('LAST NAME',15)||RPAD('PHONE',18)||RPAD('TYPE',8)||'EMAIL');
        DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));
        FOR r IN c_employees LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD(r.EMPLOYEE_ID,10)||RPAD(r.EMPLOYEE_FIRST_NAME,15)||RPAD(r.EMPLOYEE_LAST_NAME,15)||
                RPAD(NVL(r.PHONE_NUMBER,'N/A'),18)||RPAD(r.EMPLOYEE_TYPE,8)||NVL(r.EMAIL_ID,'N/A'));
            v_row_count := v_row_count + 1;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));
        DBMS_OUTPUT.PUT_LINE('Total Records: ' || v_row_count);
        DBMS_OUTPUT.PUT_LINE('==============================================');
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR in GET_EMPLOYEES_LIST: ' || SQLERRM);
    END GET_EMPLOYEES_LIST;

    -- ==========================================================
    -- Procedure: GET_DEPT_PATIENTS
    -- ==========================================================
    PROCEDURE GET_DEPT_PATIENTS (p_hospital_id IN NUMBER, p_department_id IN NUMBER) AS
        v_branch_name   HMS_HOSPITAL_BRANCH_NM.BRANCH_NAME%TYPE;
        v_dept_name     HMS_DEPARTMENT_NM.DEPARTMENT_NAME%TYPE;
        v_row_count     NUMBER := 0;
        -- Named cursor: admitted patients with primary phone
        CURSOR c_patients IS
            SELECT  p.PATIENT_ID, p.PATIENT_FIRST_NAME, p.PATIENT_LAST_NAME,
                    p.PATIENT_PHONE_NUMBER AS PHONE_NUMBER, p.EMAIL_ID, p.ADDRESS_CITY
              FROM  HMS_PATIENT_NM p
              WHERE  p.HOSPITAL_ID = p_hospital_id AND p.DEPARTMENT_ID = p_department_id
             ORDER BY p.PATIENT_ID;
    BEGIN
        BEGIN SELECT BRANCH_NAME INTO v_branch_name FROM HMS_HOSPITAL_BRANCH_NM WHERE HOSPITAL_ID = p_hospital_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('ERROR: Hospital ID not found.'); RETURN; END;
        BEGIN SELECT DEPARTMENT_NAME INTO v_dept_name FROM HMS_DEPARTMENT_NM WHERE DEPARTMENT_ID = p_department_id AND HOSPITAL_ID = p_hospital_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('ERROR: Dept not found in this hospital.'); RETURN; END;
        DBMS_OUTPUT.PUT_LINE('==============================================');
        DBMS_OUTPUT.PUT_LINE('ADMITTED PATIENTS - Branch: '||v_branch_name||' / Dept: '||v_dept_name);
        DBMS_OUTPUT.PUT_LINE(RPAD('PAT_ID',8)||RPAD('FIRST NAME',15)||RPAD('LAST NAME',15)||RPAD('PHONE',16)||RPAD('CITY',12)||'EMAIL');
        DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));
        FOR r IN c_patients LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD(r.PATIENT_ID,8)||RPAD(r.PATIENT_FIRST_NAME,15)||RPAD(r.PATIENT_LAST_NAME,15)||
                RPAD(NVL(r.PHONE_NUMBER,'N/A'),16)||RPAD(NVL(r.ADDRESS_CITY,'N/A'),12)||NVL(r.EMAIL_ID,'N/A'));
            v_row_count := v_row_count + 1;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));
        DBMS_OUTPUT.PUT_LINE('Total Patients: '||v_row_count);
        DBMS_OUTPUT.PUT_LINE('==============================================');
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR in GET_DEPT_PATIENTS: ' || SQLERRM);
    END GET_DEPT_PATIENTS;

    -- ==========================================================
    -- Procedure: LOAD_STAGING_TO_BASE
    -- Validates staging rows and promotes to base tables.
    -- Stamps Oracle EBS WHO columns using C_USER_ID (Namitha's).
    -- ==========================================================
    PROCEDURE LOAD_STAGING_TO_BASE (p_batch_id IN VARCHAR2 DEFAULT NULL) AS
        v_now          DATE   := SYSDATE;
        v_login_id     NUMBER := NVL(FND_GLOBAL.LOGIN_ID, -1);
        v_loaded_count NUMBER := 0;
        v_error_count  NUMBER := 0;
        v_error_msg    VARCHAR2(4000);
        v_dup_count    NUMBER;
        CURSOR c_hosp_master IS SELECT * FROM HMS_HOSPITAL_MASTER_STG_NM WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID;
        CURSOR c_dept        IS SELECT * FROM HMS_DEPARTMENT_STG_NM       WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID;
        CURSOR c_emp         IS SELECT * FROM HMS_EMPLOYEES_STG_NM        WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID;
        CURSOR c_pat         IS SELECT * FROM HMS_PATIENT_STG_NM          WHERE RECORD_STATUS='NEW' AND (p_batch_id IS NULL OR BATCH_ID=p_batch_id) ORDER BY STG_ID;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('==============================================');
        DBMS_OUTPUT.PUT_LINE('STAGING-TO-BASE LOAD  |  Member: NM (Namitha)');
        DBMS_OUTPUT.PUT_LINE('Run By (USER_ID) : ' || C_USER_ID);
        DBMS_OUTPUT.PUT_LINE('Run Timestamp    : ' || TO_CHAR(v_now,'YYYY-MM-DD HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('Batch Filter     : ' || NVL(p_batch_id,'ALL NEW ROWS'));
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
        FOR r IN c_hosp_master LOOP
            v_error_msg := NULL;
            IF r.HOSPITAL_CODE IS NULL THEN v_error_msg := 'HOSPITAL_CODE is NULL. '; END IF;
            IF v_error_msg IS NULL THEN SELECT COUNT(*) INTO v_dup_count FROM HMS_HOSPITAL_MASTER_NM WHERE HOSPITAL_CODE = r.HOSPITAL_CODE; IF v_dup_count > 0 THEN v_error_msg := 'Duplicate HOSPITAL_CODE. '; END IF; END IF;
            IF v_error_msg IS NULL AND NVL(r.HOSPITAL_BASIC_FEES,0) <= 0 THEN v_error_msg := 'HOSPITAL_BASIC_FEES must be > 0. '; END IF;
            IF v_error_msg IS NOT NULL THEN UPDATE HMS_HOSPITAL_MASTER_STG_NM SET RECORD_STATUS='ERROR',ERROR_LOG=v_error_msg,LAST_UPDATED_BY=C_USER_ID,LAST_UPDATE_DATE=v_now,LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID; v_error_count:=v_error_count+1;
            ELSE INSERT INTO HMS_HOSPITAL_MASTER_NM (HOSPITAL_CODE,CITY_NAME,HOSPITAL_NAME,HOSPITAL_BASIC_FEES) VALUES (r.HOSPITAL_CODE,r.CITY_NAME,r.HOSPITAL_NAME,r.HOSPITAL_BASIC_FEES); UPDATE HMS_HOSPITAL_MASTER_STG_NM SET RECORD_STATUS='LOADED',ERROR_LOG=NULL,LAST_UPDATED_BY=C_USER_ID,LAST_UPDATE_DATE=v_now,LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID; v_loaded_count:=v_loaded_count+1; END IF;
        END LOOP;
        FOR r IN c_dept LOOP
            v_error_msg := NULL;
            IF r.DEPARTMENT_NAME IS NULL THEN v_error_msg := 'DEPARTMENT_NAME is NULL. '; END IF;
            IF v_error_msg IS NULL AND NVL(r.NUMBER_OF_BEDS,-1) < 0 THEN v_error_msg := 'NUMBER_OF_BEDS cannot be negative. '; END IF;
            IF v_error_msg IS NOT NULL THEN UPDATE HMS_DEPARTMENT_STG_NM SET RECORD_STATUS='ERROR',ERROR_LOG=v_error_msg,LAST_UPDATED_BY=C_USER_ID,LAST_UPDATE_DATE=v_now,LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID; v_error_count:=v_error_count+1;
            ELSE INSERT INTO HMS_DEPARTMENT_NM (DEPARTMENT_ID,HOSPITAL_ID,DEPARTMENT_NAME,DEPT_MANAGER,NUMBER_OF_BEDS) VALUES (r.DEPARTMENT_ID,r.HOSPITAL_ID,r.DEPARTMENT_NAME,r.DEPT_MANAGER,NVL(r.NUMBER_OF_BEDS,0)); UPDATE HMS_DEPARTMENT_STG_NM SET RECORD_STATUS='LOADED',ERROR_LOG=NULL,LAST_UPDATED_BY=C_USER_ID,LAST_UPDATE_DATE=v_now,LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID; v_loaded_count:=v_loaded_count+1; END IF;
        END LOOP;
        FOR r IN c_emp LOOP
            v_error_msg := NULL;
            IF r.EMPLOYEE_FIRST_NAME IS NULL OR r.EMPLOYEE_LAST_NAME IS NULL THEN v_error_msg := 'Employee name cannot be NULL. '; END IF;
            IF v_error_msg IS NULL AND r.EMPLOYEE_TYPE NOT IN ('DOCTOR','STAFF') THEN v_error_msg := 'Invalid EMPLOYEE_TYPE. '; END IF;
            IF v_error_msg IS NOT NULL THEN UPDATE HMS_EMPLOYEES_STG_NM SET RECORD_STATUS='ERROR',ERROR_LOG=v_error_msg,LAST_UPDATED_BY=C_USER_ID,LAST_UPDATE_DATE=v_now,LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID; v_error_count:=v_error_count+1;
            ELSE INSERT INTO HMS_EMPLOYEES_NM (EMPLOYEE_ID,HOSPITAL_ID,DEPARTMENT_ID,EMPLOYEE_FIRST_NAME,EMPLOYEE_LAST_NAME,EMPLOYEE_TYPE,EMAIL_ID) VALUES (r.EMPLOYEE_ID,r.HOSPITAL_ID,r.DEPARTMENT_ID,r.EMPLOYEE_FIRST_NAME,r.EMPLOYEE_LAST_NAME,r.EMPLOYEE_TYPE,r.EMAIL_ID); UPDATE HMS_EMPLOYEES_STG_NM SET RECORD_STATUS='LOADED',ERROR_LOG=NULL,LAST_UPDATED_BY=C_USER_ID,LAST_UPDATE_DATE=v_now,LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID; v_loaded_count:=v_loaded_count+1; END IF;
        END LOOP;
        FOR r IN c_pat LOOP
            v_error_msg := NULL;
            IF r.PATIENT_FIRST_NAME IS NULL OR r.PATIENT_LAST_NAME IS NULL THEN v_error_msg := 'Patient name cannot be NULL. '; END IF;
            IF v_error_msg IS NOT NULL THEN UPDATE HMS_PATIENT_STG_NM SET RECORD_STATUS='ERROR',ERROR_LOG=v_error_msg,LAST_UPDATED_BY=C_USER_ID,LAST_UPDATE_DATE=v_now,LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID; v_error_count:=v_error_count+1;
            ELSE INSERT INTO HMS_PATIENT_NM (PATIENT_ID,HOSPITAL_ID,DEPARTMENT_ID,PATIENT_FIRST_NAME,PATIENT_LAST_NAME,PATIENT_PHONE_NUMBER,EMAIL_ID,ADDRESS_STREET,ADDRESS_CITY,ADDRESS_STATE,ADDRESS_POSTAL_CODE) VALUES (r.PATIENT_ID,r.HOSPITAL_ID,r.DEPARTMENT_ID,r.PATIENT_FIRST_NAME,r.PATIENT_LAST_NAME,r.PATIENT_PHONE_NUMBER,r.EMAIL_ID,r.ADDRESS_STREET,r.ADDRESS_CITY,r.ADDRESS_STATE,r.ADDRESS_POSTAL_CODE); UPDATE HMS_PATIENT_STG_NM SET RECORD_STATUS='LOADED',ERROR_LOG=NULL,LAST_UPDATED_BY=C_USER_ID,LAST_UPDATE_DATE=v_now,LAST_UPDATE_LOGIN=v_login_id WHERE STG_ID=r.STG_ID; v_loaded_count:=v_loaded_count+1; END IF;
        END LOOP;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('LOAD COMPLETE  |  Loaded: '||v_loaded_count||'  |  Errors: '||v_error_count);
        DBMS_OUTPUT.PUT_LINE('Committed by USER_ID : ' || C_USER_ID);
        DBMS_OUTPUT.PUT_LINE('==============================================');
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('CRITICAL ERROR: ' || SQLERRM || ' - Transaction rolled back.');
    END LOAD_STAGING_TO_BASE;

END HMS_PKG_NM;
/
-- Test: SET SERVEROUTPUT ON SIZE UNLIMITED;
-- EXEC HMS_PKG_NM.GET_BRANCH_SUMMARY(1);
-- EXEC HMS_PKG_NM.LOAD_STAGING_TO_BASE();
-- ============================================================
-- END OF FILE: HMS_PKG_NM.sql  |  Version 2.0  |  Member: NM
-- ============================================================
