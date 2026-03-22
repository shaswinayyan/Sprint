-- ============================================================
-- File        : HMS_CLEANUP_ALL_MD.sql
-- Project     : Hospital Management System (HMS)
-- Description : Utility script to quickly wipe ALL custom HMS data
--               across both Base tables and Staging tables.
--               Used to completely reset the environment for fresh loads.
-- ============================================================

-- ------------------------------------------------------------
-- 1. DELETE FROM BASE TABLES (Bottom-Up to avoid FK Violations)
-- ------------------------------------------------------------
DELETE FROM HMS_PATIENT_MD;
DELETE FROM HMS_DOCTOR_AVAILABILITY_MD;
DELETE FROM HMS_EMPLOYEE_PHONE_MST_MD;
DELETE FROM HMS_EMPLOYEES_MD;
DELETE FROM HMS_DEPARTMENT_MD;
DELETE FROM HMS_HOSPITAL_BRANCH_MD;
DELETE FROM HMS_HOSPITAL_MASTER_MD;

COMMIT;

-- ------------------------------------------------------------
-- 2. TRUNCATE STAGING TABLES (No FK constraints exist here)
-- ------------------------------------------------------------
TRUNCATE TABLE HMS_PATIENT_STG_MD;
TRUNCATE TABLE HMS_EMPLOYEES_STG_MD;
TRUNCATE TABLE HMS_DEPARTMENT_STG_MD;
TRUNCATE TABLE HMS_HOSPITAL_BRANCH_STG_MD;
TRUNCATE TABLE HMS_HOSPITAL_MASTER_STG_MD;
TRUNCATE TABLE HMS_EMPLOYEE_PHONE_MST_STG_MD;
TRUNCATE TABLE HMS_DOCTOR_AVAILABILITY_STG_MD;

COMMIT;
