import os
import re

MEMBERS = ['SH', 'CH', 'MD', 'NM']
BASE_DIR = 'g:/IITM/Sprint/HMS_Project'

for suffix in MEMBERS:
    # 1. Update HMS_CREATE_TABLES_<SUFFIX>.sql
    ddl_file = os.path.join(BASE_DIR, '01_DDL', suffix, f'HMS_CREATE_TABLES_{suffix}.sql')
    if os.path.exists(ddl_file):
        with open(ddl_file, 'r') as f:
            content = f.read()
        
        # Remove DROP table
        content = re.sub(r'BEGIN\n\s*EXECUTE IMMEDIATE \'DROP TABLE HMS_PATIENT_PHONE_MST_' + suffix + r'\s+CASCADE CONSTRAINTS\';\nEXCEPTION WHEN OTHERS THEN NULL; END;\n/', '', content, flags=re.DOTALL)
        
        # Add column to HMS_PATIENT
        content = content.replace(
            f"PATIENT_LAST_NAME   VARCHAR2(50)    NOT NULL,  -- Patient last name",
            f"PATIENT_LAST_NAME   VARCHAR2(50)    NOT NULL,  -- Patient last name\n    PATIENT_PHONE_NUMBER VARCHAR2(15)    NOT NULL,  -- Patient's contact number"
        )
        
        # Remove TABLE 8 block
        content = re.sub(r'-- ===========================================================\n-- TABLE 8: HMS_PATIENT_PHONE_MST_' + suffix + r'.*?(?=-- ===========================================================\n-- SEQUENCES)', '', content, flags=re.DOTALL)
        
        # Remove sequence
        content = re.sub(r'CREATE SEQUENCE HMS_PAT_PHONE_SEQ_' + suffix + r'\s+START WITH 1 INCREMENT BY 1 NOCACHE;\n', '', content)
        
        with open(ddl_file, 'w') as f:
            f.write(content)

    # 2. Update HMS_CREATE_STAGING_TABLES_<SUFFIX>.sql
    stg_file = os.path.join(BASE_DIR, '01_DDL', suffix, f'HMS_CREATE_STAGING_TABLES_{suffix}.sql')
    if os.path.exists(stg_file):
        with open(stg_file, 'r') as f:
            content = f.read()
            
        content = content.replace(
            "PATIENT_LAST_NAME   VARCHAR2(50),",
            "PATIENT_LAST_NAME   VARCHAR2(50),\n    PATIENT_PHONE_NUMBER VARCHAR2(15),"
        )
        with open(stg_file, 'w') as f:
            f.write(content)
            
    # 3. Update HMS_PKG_<SUFFIX>.sql
    pkg_file = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
    if os.path.exists(pkg_file):
        with open(pkg_file, 'r') as f:
            content = f.read()
            
        # In c_patients cursor
        content = content.replace(
            "pp.PHONE_NUMBER, p.EMAIL_ID, p.ADDRESS_CITY",
            "p.PATIENT_PHONE_NUMBER AS PHONE_NUMBER, p.EMAIL_ID, p.ADDRESS_CITY"
        )
        # Remove join
        content = re.sub(r'LEFT JOIN HMS_PATIENT_PHONE_MST_' + suffix + r'\s+pp ON p\.PATIENT_ID = pp\.PATIENT_ID AND pp\.PHONE_TYPE = \'PRIMARY\'\n\s*', '', content)
        
        # In LOAD_STAGING_TO_BASE insert
        content = content.replace(
            "PATIENT_FIRST_NAME,PATIENT_LAST_NAME,EMAIL_ID,ADDRESS_STREET,ADDRESS_CITY,ADDRESS_STATE,ADDRESS_POSTAL_CODE",
            "PATIENT_FIRST_NAME,PATIENT_LAST_NAME,PATIENT_PHONE_NUMBER,EMAIL_ID,ADDRESS_STREET,ADDRESS_CITY,ADDRESS_STATE,ADDRESS_POSTAL_CODE"
        )
        content = content.replace(
            "r.PATIENT_FIRST_NAME,r.PATIENT_LAST_NAME,r.EMAIL_ID,r.ADDRESS_STREET,r.ADDRESS_CITY,r.ADDRESS_STATE,r.ADDRESS_POSTAL_CODE",
            "r.PATIENT_FIRST_NAME,r.PATIENT_LAST_NAME,r.PATIENT_PHONE_NUMBER,r.EMAIL_ID,r.ADDRESS_STREET,r.ADDRESS_CITY,r.ADDRESS_STATE,r.ADDRESS_POSTAL_CODE"
        )
        
        with open(pkg_file, 'w') as f:
            f.write(content)

    # 4. Update CSV
    csv_file = os.path.join(BASE_DIR, '02_Data', suffix, f'HMS_PATIENT_DATA_{suffix}.csv')
    if os.path.exists(csv_file):
        with open(csv_file, 'r') as f:
            lines = f.readlines()
        new_lines = []
        for i, line in enumerate(lines):
            parts = line.strip().split(',')
            if i == 0:
                parts.insert(5, 'PATIENT_PHONE_NUMBER')
            else:
                parts.insert(5, '9876543210')
            new_lines.append(','.join(parts) + '\n')
        with open(csv_file, 'w') as f:
            f.writelines(new_lines)
            
    # 5. Update CTL
    ctl_file = os.path.join(BASE_DIR, '02_Data', suffix, f'HMS_PATIENT_{suffix}.ctl')
    if os.path.exists(ctl_file):
        with open(ctl_file, 'r') as f:
            content = f.read()
            
        content = content.replace(
            "PATIENT_LAST_NAME,",
            "PATIENT_LAST_NAME,\n    PATIENT_PHONE_NUMBER,"
        )
        with open(ctl_file, 'w') as f:
            f.write(content)

print("Removed patient phone master successfully.")
