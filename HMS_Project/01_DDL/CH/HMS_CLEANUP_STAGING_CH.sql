-- ============================================================
-- File        : HMS_CLEANUP_STAGING_CH.sql
-- Project     : Hospital Management System (HMS)
-- Description : Utility script to quickly truncate all staging tables.
--               Use this if you want to wipe all staging data and reload
--               the CSV files freshly using SQL*Loader.
-- ============================================================

TRUNCATE TABLE HMS_PATIENT_STG_CH;
TRUNCATE TABLE HMS_EMPLOYEES_STG_CH;
TRUNCATE TABLE HMS_DEPARTMENT_STG_CH;
TRUNCATE TABLE HMS_HOSPITAL_BRANCH_STG_CH;
TRUNCATE TABLE HMS_HOSPITAL_MASTER_STG_CH;
TRUNCATE TABLE HMS_EMPLOYEE_PHONE_MST_STG_CH;
TRUNCATE TABLE HMS_DOCTOR_AVAILABILITY_STG_CH;

COMMIT;
