-- ============================================================
-- File        : HMS_CLEANUP_ALL_CH.sql
-- Project     : Hospital Management System (HMS)
-- Description : Utility script to quickly wipe ALL custom HMS data
--               across both Base tables and Staging tables.
--               Used to completely reset the environment for fresh loads.
-- ============================================================

-- ------------------------------------------------------------
-- 1. DELETE FROM BASE TABLES (Bottom-Up to avoid FK Violations)
-- ------------------------------------------------------------
DELETE FROM HMS_PATIENT_CH;
DELETE FROM HMS_DOCTOR_AVAILABILITY_CH;
DELETE FROM HMS_EMPLOYEE_PHONE_MST_CH;
DELETE FROM HMS_EMPLOYEES_CH;
DELETE FROM HMS_DEPARTMENT_CH;
DELETE FROM HMS_HOSPITAL_BRANCH_CH;
DELETE FROM HMS_HOSPITAL_MASTER_CH;

COMMIT;

-- ------------------------------------------------------------
-- 2. TRUNCATE STAGING TABLES (No FK constraints exist here)
-- ------------------------------------------------------------
TRUNCATE TABLE HMS_PATIENT_STG_CH;
TRUNCATE TABLE HMS_EMPLOYEES_STG_CH;
TRUNCATE TABLE HMS_DEPARTMENT_STG_CH;
TRUNCATE TABLE HMS_HOSPITAL_BRANCH_STG_CH;
TRUNCATE TABLE HMS_HOSPITAL_MASTER_STG_CH;
TRUNCATE TABLE HMS_EMPLOYEE_PHONE_MST_STG_CH;
TRUNCATE TABLE HMS_DOCTOR_AVAILABILITY_STG_CH;

COMMIT;
