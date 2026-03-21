import os
import re

MEMBERS = ['SH', 'CH', 'MD', 'NM']
BASE_DIR = 'g:/IITM/Sprint/HMS_Project'

# Sort by length descending to prevent partial match issues
TABLES = [
    'HMS_EMPLOYEE_PHONE_MST',
    'HMS_PATIENT_PHONE_MST',
    'HMS_HOSPITAL_MASTER_STG',
    'HMS_HOSPITAL_BRANCH_STG',
    'HMS_DOCTOR_AVAILABILITY',
    'HMS_DEPARTMENT_STG',
    'HMS_EMPLOYEES_STG',
    'HMS_PATIENT_STG',
    'HMS_HOSPITAL_MASTER',
    'HMS_HOSPITAL_BRANCH',
    'HMS_DEPARTMENT',
    'HMS_EMPLOYEES',
    'HMS_PATIENT'
]

SEQUENCES = [
    'HMS_HOSP_MASTER_STG_SEQ',
    'HMS_HOSP_BRANCH_STG_SEQ',
    'HMS_HOSP_MASTER_SEQ',
    'HMS_HOSP_BRANCH_SEQ',
    'HMS_DEPT_STG_SEQ',
    'HMS_EMP_STG_SEQ',
    'HMS_PAT_STG_SEQ',
    'HMS_DEPT_SEQ',
    'HMS_EMP_SEQ',
    'HMS_PAT_SEQ'
]

CONSTRAINTS = [
    'FK_HMS_EMP_PHONE_EMP',
    'FK_HMS_PAT_PHONE_PAT',
    'FK_HMS_HOSP_BRANCH_MST',
    'CHK_HOSP_BASIC_FEES',
    'PK_HMS_HOSP_MASTER_STG',
    'PK_HMS_HOSP_BRANCH_STG',
    'PK_HMS_HOSP_MASTER',
    'PK_HMS_HOSP_BRANCH',
    'CHK_HOSP_STG_STATUS',
    'CHK_BRANCH_STG_STATUS',
    'CHK_DEPT_STG_STATUS',
    'CHK_EMP_STG_STATUS',
    'CHK_PAT_STG_STATUS',
    'PK_HMS_EMP_PHONE',
    'PK_HMS_DOC_AVAIL',
    'PK_HMS_PAT_PHONE',
    'FK_HMS_DEPT_HOSP',
    'FK_HMS_EMP_HOSP',
    'FK_HMS_EMP_DEPT',
    'FK_HMS_DOC_EMP',
    'FK_HMS_PAT_HOSP',
    'FK_HMS_PAT_DEPT',
    'CHK_PAT_PHONE_TYPE',
    'PK_HMS_DEPT_STG',
    'PK_HMS_EMP_STG',
    'PK_HMS_PAT_STG',
    'PK_HMS_DEPT',
    'PK_HMS_EMP',
    'PK_HMS_PATIENT',
    'CHK_DEPT_BEDS',
    'CHK_EMP_TYPE',
    'CHK_PHONE_TYPE',
    'CHK_DOC_DAY',
    'CHK_DOC_TIME'
]

def replace_in_text(text, suffix):
    # Process constraints (truncate to 26 chars before adding suffix to respect Oracle 30 char limit)
    for c in CONSTRAINTS:
        new_c = c[:26] + "_" + suffix
        text = re.sub(r'\b' + c + r'\b', new_c, text)
        
    for t in TABLES:
        new_t = t + "_" + suffix
        text = re.sub(r'\b' + t + r'\b', new_t, text)
        
    for s in SEQUENCES:
        new_s = s[:26] + "_" + suffix
        text = re.sub(r'\b' + s + r'\b', new_s, text)
        
    return text

def main():
    ddl_master = os.path.join(BASE_DIR, '01_DDL', 'HMS_CREATE_TABLES.sql')
    ddl_staging = os.path.join(BASE_DIR, '01_DDL', 'HMS_CREATE_STAGING_TABLES.sql')
    
    with open(ddl_master, 'r') as f:
        master_content = f.read()
    with open(ddl_staging, 'r') as f:
        staging_content = f.read()
        
    # 1. Process DDLs
    for suffix in MEMBERS:
        ddl_dir = os.path.join(BASE_DIR, '01_DDL', suffix)
        os.makedirs(ddl_dir, exist_ok=True)
        
        with open(os.path.join(ddl_dir, f'HMS_CREATE_TABLES_{suffix}.sql'), 'w') as f:
            f.write(replace_in_text(master_content, suffix))
            
        with open(os.path.join(ddl_dir, f'HMS_CREATE_STAGING_TABLES_{suffix}.sql'), 'w') as f:
            f.write(replace_in_text(staging_content, suffix))
            
    # 2. Process PL/SQL packages
    for suffix in MEMBERS:
        pkg_file = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
        with open(pkg_file, 'r') as f:
            pkg_content = f.read()
        with open(pkg_file, 'w') as f:
            f.write(replace_in_text(pkg_content, suffix))
            
    # 3. Process CTL files
    for suffix in MEMBERS:
        data_dir = os.path.join(BASE_DIR, '02_Data', suffix)
        if not os.path.exists(data_dir): continue
        for ctl_file in os.listdir(data_dir):
            if ctl_file.endswith('.ctl'):
                path = os.path.join(data_dir, ctl_file)
                with open(path, 'r') as f:
                    ctl_content = f.read()
                
                # Update INTO TABLE HMS_XXX to INTO TABLE HMS_XXX_STG before applying suffix
                for t in ['HMS_HOSPITAL_MASTER', 'HMS_DEPARTMENT', 'HMS_EMPLOYEES', 'HMS_PATIENT']:
                    ctl_content = re.sub(r'INTO TABLE\s+' + t + r'\b', 'INTO TABLE ' + t + '_STG', ctl_content, flags=re.IGNORECASE)
                
                new_ctl_content = replace_in_text(ctl_content, suffix)
                with open(path, 'w') as f:
                    f.write(new_ctl_content)
                    
    # Clean up old single DDLs
    try:
        os.remove(ddl_master)
        os.remove(ddl_staging)
    except Exception as e:
        print(f"Warning: Could not delete root DDLs: {e}")

if __name__ == '__main__':
    main()
    print("Refactoring complete.")
