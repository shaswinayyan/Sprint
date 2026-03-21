import os
import re

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = {
    'SH': 'Shaswin',
    'CH': 'Chandana',
    'MD': 'Manideep',
    'NM': 'Namitha'
}

for suffix, name in MEMBERS.items():

    # 1. HMS_CREATE_TABLES
    fpath = os.path.join(BASE_DIR, '01_DDL', suffix, f'HMS_CREATE_TABLES_{suffix}.sql')
    if os.path.exists(fpath):
        with open(fpath, 'r') as f:
            content = f.read()
        
        # File headers
        content = content.replace('-- File        : HMS_CREATE_TABLES.sql', f'-- File        : HMS_CREATE_TABLES_{suffix}.sql')
        content = content.replace('-- END OF FILE: HMS_CREATE_TABLES.sql', f'-- END OF FILE: HMS_CREATE_TABLES_{suffix}.sql')
        
        # Remove --   8. HMS_PATIENT_PHONE_MST_<SUFFIX>
        content = re.sub(r'--\s+8\.\s+HMS_PATIENT_PHONE_MST_[A-Z]{2}\n', '', content)
        
        # Sequences (missed previously)
        content = re.sub(r'CREATE SEQUENCE HMS_EMP_PHONE_SEQ\s', f'CREATE SEQUENCE HMS_EMP_PHONE_SEQ_{suffix} ', content)
        content = re.sub(r'CREATE SEQUENCE HMS_DOC_AVAIL_SEQ\s', f'CREATE SEQUENCE HMS_DOC_AVAIL_SEQ_{suffix} ', content)
        
        # Missed constraints
        content = content.replace('CONSTRAINT PK_EMP_PHONE     PRIMARY KEY', f'CONSTRAINT PK_EMP_PHONE_{suffix}     PRIMARY KEY')
        content = content.replace('CONSTRAINT PK_HMS_DEPARTMENT    PRIMARY KEY', f'CONSTRAINT PK_HMS_DEPARTMENT_{suffix}    PRIMARY KEY')

        with open(fpath, 'w') as f:
            f.write(content)

    # 2. HMS_CREATE_STAGING_TABLES
    fpath = os.path.join(BASE_DIR, '01_DDL', suffix, f'HMS_CREATE_STAGING_TABLES_{suffix}.sql')
    if os.path.exists(fpath):
        with open(fpath, 'r') as f:
            content = f.read()

        content = content.replace('-- File        : HMS_CREATE_STAGING_TABLES.sql', f'-- File        : HMS_CREATE_STAGING_TABLES_{suffix}.sql')
        content = content.replace('-- END OF FILE: HMS_CREATE_STAGING_TABLES.sql', f'-- END OF FILE: HMS_CREATE_STAGING_TABLES_{suffix}.sql')
        
        with open(fpath, 'w') as f:
            f.write(content)

    # 3. HMS_PKG
    fpath = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
    if os.path.exists(fpath):
        with open(fpath, 'r') as f:
            content = f.read()
            
        content = content.replace('-- File        : HMS_PKG_SH.sql', f'-- File        : HMS_PKG_{suffix}.sql')
        
        # Member header line
        user_id_str = "1021027" if suffix == 'SH' else "0 /*UPDATE*/"
        content = re.sub(r'-- Member\s+: SH - Shaswin \(FND_USER\.USER_ID = 1021027\)', 
                         f'-- Member      : {suffix} - {name} (FND_USER.USER_ID = {user_id_str})', content)
                         
        content = re.sub(r'-- END OF FILE: HMS_PKG_SH\.sql(.*?)Member: SH',
                         f'-- END OF FILE: HMS_PKG_{suffix}.sql\\1Member: {suffix}', content)
                         
        # C_USER_ID mapping
        if suffix != 'SH':
            content = re.sub(r'C_USER_ID\s+CONSTANT NUMBER := 1021027;\s+-- Shaswin\'s EBS User ID',
                             f'C_USER_ID   CONSTANT NUMBER := {user_id_str};   -- {name}\'s EBS User ID', content)
                             
        # DBMS_OUTPUT string
        content = re.sub(r'Member: SH \(Shaswin\)', f'Member: {suffix} ({name})', content)

        # Also HMS_PKG_SH to HMS_PKG_{SUFFIX}
        content = content.replace('CREATE OR REPLACE PACKAGE HMS_PKG_SH', f'CREATE OR REPLACE PACKAGE HMS_PKG_{suffix}')
        content = content.replace('END HMS_PKG_SH;', f'END HMS_PKG_{suffix};')
        content = content.replace('CREATE OR REPLACE PACKAGE BODY HMS_PKG_SH', f'CREATE OR REPLACE PACKAGE BODY HMS_PKG_{suffix}')
        
        # Test EXEC commands at the bottom
        content = content.replace('EXEC HMS_PKG_SH.', f'EXEC HMS_PKG_{suffix}.')

        with open(fpath, 'w') as f:
            f.write(content)

print("Comments and minor mappings successfully updated.")
