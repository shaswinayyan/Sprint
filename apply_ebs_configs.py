import os
import re

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = {
    'SH': ('Shaswin', '1021027'),
    'CH': ('Chandana', '1021034'),
    'MD': ('Manideep', '1021035'),
    'NM': ('Namitha', '1021052')
}

CTL_FILES = [
    'HMS_HOSPITAL_MASTER',
    'HMS_BRANCH',
    'HMS_DEPT',
    'HMS_EMPLOYEE',
    'HMS_EMP_PHONE',
    'HMS_DOC_AVAIL',
    'HMS_PATIENT'
]

# 1. Update PL/SQL Packages
for suffix, (name, uid) in MEMBERS.items():
    pkg_file = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
    if os.path.exists(pkg_file):
        with open(pkg_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace the C_USER_ID constant
        content = re.sub(r'C_USER_ID\s+CONSTANT NUMBER := [0-9]+;', f'C_USER_ID   CONSTANT NUMBER := {uid};', content)
        
        # Replace the member header comment
        content = re.sub(r'-- Member      : .*', f'-- Member      : {suffix} - {name} (FND_USER.USER_ID = {uid})', content)
        
        with open(pkg_file, 'w', encoding='utf-8') as f:
            f.write(content)

# 2. Create load_all_data_<SUFFIX>.bat scripts
for suffix, (name, uid) in MEMBERS.items():
    data_dir = os.path.join(BASE_DIR, '02_Data', suffix)
    bat_file = os.path.join(data_dir, f'load_all_data_{suffix}.bat')
    
    bat_content = f"@echo off\n"
    bat_content += f"echo =======================================================\n"
    bat_content += f"echo Loading Data for {name} ({suffix})\n"
    bat_content += f"echo Target DB: apps/apps@//150.136.96.10:1521/ebs_ebsdb\n"
    bat_content += f"echo =======================================================\n\n"
    
    for ctl in CTL_FILES:
        base_name = f"{ctl}_{suffix}"
        bat_content += f"echo Loading {base_name}...\n"
        bat_content += f"sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control={base_name}.ctl log={base_name}.log\n\n"
        
    bat_content += "echo All loads completed. Please review the .log files for any discarded/bad rows.\n"
    bat_content += "pause\n"
    
    os.makedirs(data_dir, exist_ok=True)
    with open(bat_file, 'w', encoding='utf-8') as f:
        f.write(bat_content)

print("Updated PL/SQL IDs and generated bat scripts safely.")
