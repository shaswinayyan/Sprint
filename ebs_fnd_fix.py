import os

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

for suffix in MEMBERS:
    # 1. Rename CSV and update CTL
    data_dir = os.path.join(BASE_DIR, '02_Data', suffix)
    old_csv = os.path.join(data_dir, f'HMS_DEPARTMENT_DATA_{suffix}.csv')
    new_csv = os.path.join(data_dir, f'HMS_DEPT_DATA_{suffix}.csv')
    
    if os.path.exists(old_csv):
        os.rename(old_csv, new_csv)
        
    ctl_file = os.path.join(data_dir, f'HMS_DEPT_{suffix}.ctl')
    if os.path.exists(ctl_file):
        with open(ctl_file, 'r') as f:
            content = f.read()
        content = content.replace(f'HMS_DEPARTMENT_DATA_{suffix}.csv', f'HMS_DEPT_DATA_{suffix}.csv')
        with open(ctl_file, 'w') as f:
            f.write(content)

    # 2. Update PL/SQL to use FND_FILE.OUTPUT instead of DBMS_OUTPUT
    pkg_file = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
    if os.path.exists(pkg_file):
        with open(pkg_file, 'r') as f:
            content = f.read()
            
        content = content.replace('DBMS_OUTPUT.PUT_LINE(', 'FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ')
        
        # Also fix the HOW TO TEST comments at the bottom to reflect this
        content = content.replace('-- SET SERVEROUTPUT ON SIZE UNLIMITED;', '-- Note: In SQL Developer, FND_FILE output goes to a temp server directory if not initialized.\n-- To test FND_FILE locally in SQL Developer, you may need a wrapper or revert to DBMS_OUTPUT locally.')
        
        with open(pkg_file, 'w') as f:
            f.write(content)

print("Renamed Dept CSVs, updated CTLs, and migrated all DBMS_OUTPUT to FND_FILE for EBS browser compatibility.")
