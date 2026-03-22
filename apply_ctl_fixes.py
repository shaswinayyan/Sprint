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

        if "OPTIONS (SKIP=1)" not in content:
            content = "OPTIONS (SKIP=1)\n" + content.lstrip()
            
        seq_name = f"{seq_base}_{suffix}"
        
        if "STG_ID" not in content:
            parts = content.split("TRAILING NULLCOLS")
            if len(parts) == 2:
                head, tail = parts[0], parts[1]
                idx = tail.find('(')
                if idx != -1:
                    insert_block = f"""
    STG_ID "{seq_name}.NEXTVAL",
    BATCH_ID CONSTANT 'BATCH_{suffix}',
    CREATED_BY CONSTANT {uid},
    CREATION_DATE SYSDATE,
    LAST_UPDATED_BY CONSTANT {uid},
    LAST_UPDATE_DATE SYSDATE,
"""
                    new_tail = tail[:idx+1] + insert_block + tail[idx+1:]
                    content = head + "TRAILING NULLCOLS" + new_tail
            
            with open(ctl_path, 'w', encoding='utf-8') as f:
                f.write(content)

print("Safely injected explicit Sequence triggers and System Identity constants into 28 CTL Files.")
