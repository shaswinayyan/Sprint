import os

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/01_DDL'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

for suffix in MEMBERS:
    target_dir = os.path.join(BASE_DIR, suffix)
    if not os.path.exists(target_dir): os.makedirs(target_dir)
    
    cleanup_path = os.path.join(target_dir, f'HMS_CLEANUP_STAGING_{suffix}.sql')
    content = f"""-- ============================================================
-- File        : HMS_CLEANUP_STAGING_{suffix}.sql
-- Project     : Hospital Management System (HMS)
-- Description : Utility script to quickly truncate all staging tables.
--               Use this if you want to wipe all staging data and reload
--               the CSV files freshly using SQL*Loader.
-- ============================================================

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

print("Created 4 staging cleanup SQL scripts.")
