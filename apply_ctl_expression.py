import os
import re

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/02_Data'
MEMBERS = {
    'SH': '1021027',
    'CH': '1021034',
    'MD': '1021035',
    'NM': '1021052'
}

SEQ_MAP = {
    'HMS_HOSPITAL_MASTER': 'HMS_HOSP_MASTER_STG_SEQ',
    'HMS_BRANCH': 'HMS_HOSP_BRANCH_STG_SEQ',
    'HMS_DEPT': 'HMS_DEPT_STG_SEQ',
    'HMS_EMPLOYEE': 'HMS_EMP_STG_SEQ',
    'HMS_PATIENT': 'HMS_PAT_STG_SEQ',
    'HMS_EMP_PHONE': 'HMS_EMP_PHONE_STG_SEQ',
    'HMS_DOC_AVAIL': 'HMS_DOC_AVAIL_STG_SEQ'
}

for suffix, uid in MEMBERS.items():
    member_dir = os.path.join(BASE_DIR, suffix)
    if not os.path.exists(member_dir): continue
    
    for ctl_base, seq_base in SEQ_MAP.items():
        ctl_path = os.path.join(member_dir, f"{ctl_base}_{suffix}.ctl")
        if not os.path.exists(ctl_path): continue
        
        with open(ctl_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # We must add EXPRESSION so SQL*Loader doesn't consume the CSV column
        if f'STG_ID "{seq_base}_{suffix}.NEXTVAL"' in content:
            content = content.replace(f'STG_ID "{seq_base}_{suffix}.NEXTVAL"', f'STG_ID EXPRESSION "{seq_base}_{suffix}.NEXTVAL"')
            with open(ctl_path, 'w', encoding='utf-8') as f:
                f.write(content)

print("Safely injected EXPRESSION keyword to prevent CSV column consumption.")
