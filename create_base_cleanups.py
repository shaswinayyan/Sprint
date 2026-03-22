import os

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/01_DDL'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

for suffix in MEMBERS:
    target_dir = os.path.join(BASE_DIR, suffix)
    if not os.path.exists(target_dir): os.makedirs(target_dir)
    
    cleanup_path = os.path.join(target_dir, f'HMS_CLEANUP_ALL_{suffix}.sql')
    content = f"""-- ============================================================
-- File        : HMS_CLEANUP_ALL_{suffix}.sql
-- Project     : Hospital Management System (HMS)
-- Description : Utility script to quickly wipe ALL custom HMS data
--               across both Base tables and Staging tables.
--               Used to completely reset the environment for fresh loads.
-- ============================================================

-- ------------------------------------------------------------
-- 1. DELETE FROM BASE TABLES (Bottom-Up to avoid FK Violations)
-- ------------------------------------------------------------
DELETE FROM HMS_PATIENT_{suffix};
DELETE FROM HMS_DOCTOR_AVAILABILITY_{suffix};
DELETE FROM HMS_EMPLOYEE_PHONE_MST_{suffix};
DELETE FROM HMS_EMPLOYEES_{suffix};
DELETE FROM HMS_DEPARTMENT_{suffix};
DELETE FROM HMS_HOSPITAL_BRANCH_{suffix};
DELETE FROM HMS_HOSPITAL_MASTER_{suffix};

COMMIT;

-- ------------------------------------------------------------
-- 2. TRUNCATE STAGING TABLES (No FK constraints exist here)
-- ------------------------------------------------------------
TRUNCATE TABLE HMS_PATIENT_STG_{suffix};
TRUNCATE TABLE HMS_EMPLOYEES_STG_{suffix};
TRUNCATE TABLE HMS_DEPARTMENT_STG_{suffix};
TRUNCATE TABLE HMS_HOSPITAL_BRANCH_STG_{suffix};
TRUNCATE TABLE HMS_HOSPITAL_MASTER_STG_{suffix};
TRUNCATE TABLE HMS_EMPLOYEE_PHONE_MST_STG_{suffix};
TRUNCATE TABLE HMS_DOCTOR_AVAILABILITY_STG_{suffix};

COMMIT;
"""
    with open(cleanup_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Created 4 comprehensive DB cleanup SQL scripts.")
