import os

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

branch_ctl_template = """-- ============================================================
-- File        : HMS_BRANCH_{suffix}.ctl
-- Description : SQL*Loader control file for loading hospital branch data
--               into staging table HMS_HOSPITAL_BRANCH_STG_{suffix}
-- ============================================================

LOAD DATA
INFILE 'HMS_BRANCH_DATA_{suffix}.csv'

INTO TABLE HMS_HOSPITAL_BRANCH_STG_{suffix}
APPEND

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

TRAILING NULLCOLS

(
    HOSPITAL_ID,
    HOSPITAL_CODE,
    BRANCH_NAME,
    CITY,
    MANAGING_DIRECTOR,
    HELPDESK_NUMBER,
    EMERGENCY_NUMBER,
    CUSTOMER_CARE_EMAIL,
    CUSTOMER_CARE_PHONE
)
"""

plsql_branch_load = """
        -- ===================================================
        -- SECTION 1.5: Process HMS_HOSPITAL_BRANCH_STG_{suffix}
        -- ===================================================
        DBMS_OUTPUT.PUT_LINE('[1.5/4] Processing HMS_HOSPITAL_BRANCH_STG_{suffix} ...');
        FOR r IN (SELECT * FROM HMS_HOSPITAL_BRANCH_STG_{suffix} WHERE RECORD_STATUS = 'NEW' AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;

            IF r.HOSPITAL_CODE IS NULL OR r.BRANCH_NAME IS NULL THEN
                v_error_msg := 'HOSPITAL_CODE or BRANCH_NAME is NULL. ';
            END IF;

            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_HOSPITAL_BRANCH_STG_{suffix}
                   SET RECORD_STATUS      = 'ERROR',
                       ERROR_LOG          = v_error_msg,
                       LAST_UPDATED_BY    = C_USER_ID,
                       LAST_UPDATE_DATE   = v_now,
                       LAST_UPDATE_LOGIN  = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_HOSPITAL_BRANCH_{suffix} (
                    HOSPITAL_ID, HOSPITAL_CODE, BRANCH_NAME, CITY, MANAGING_DIRECTOR,
                    HELPDESK_NUMBER, EMERGENCY_NUMBER, CUSTOMER_CARE_EMAIL, CUSTOMER_CARE_PHONE
                ) VALUES (
                    r.HOSPITAL_ID, r.HOSPITAL_CODE, r.BRANCH_NAME, r.CITY, r.MANAGING_DIRECTOR,
                    r.HELPDESK_NUMBER, r.EMERGENCY_NUMBER, r.CUSTOMER_CARE_EMAIL, r.CUSTOMER_CARE_PHONE
                );

                UPDATE HMS_HOSPITAL_BRANCH_STG_{suffix}
                   SET RECORD_STATUS      = 'LOADED',
                       ERROR_LOG          = NULL,
                       LAST_UPDATED_BY    = C_USER_ID,
                       LAST_UPDATE_DATE   = v_now,
                       LAST_UPDATE_LOGIN  = v_login_id
                 WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;
"""

for suffix in MEMBERS:
    data_dir = os.path.join(BASE_DIR, '02_Data', suffix)
    # 1. Create missing CTL files
    ctl_file = os.path.join(data_dir, f'HMS_BRANCH_{suffix}.ctl')
    with open(ctl_file, 'w') as f:
        f.write(branch_ctl_template.format(suffix=suffix))
        
    # 2. Remove legacy duplicate CSVs
    legacy_file = os.path.join(data_dir, f'HMS_DEPT_DATA_{suffix}.csv')
    if os.path.exists(legacy_file):
        os.remove(legacy_file)
        
    # 3. Patch PL/SQL packages to load branch staging tables
    pkg_file = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
    if os.path.exists(pkg_file):
        with open(pkg_file, 'r') as f:
            content = f.read()
            
        load_block = plsql_branch_load.format(suffix=suffix)
        
        # Insert after section 1 if it hasn't been inserted already
        if "SECTION 1.5" not in content:
            marker = f"-- SECTION 2: Process HMS_DEPARTMENT_STG_{suffix}"
            if marker in content:
                content = content.replace(marker, load_block + "\n        -- ===================================================\n        " + marker)
                
            with open(pkg_file, 'w') as f:
                f.write(content)

print("Generated Branch CTL files and patched PL/SQL packages successfully.")
