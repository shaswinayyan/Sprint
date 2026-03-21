import os

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

# 1. Remove Views from DDLs
for suffix in MEMBERS:
    ddl_file = os.path.join(BASE_DIR, '01_DDL', suffix, f'HMS_CREATE_TABLES_{suffix}.sql')
    if os.path.exists(ddl_file):
        with open(ddl_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Split off everything from the "VIEWS FOR ORACLE EBS VALUE SETS" marker
        if "-- ==========================================================\n-- VIEWS FOR ORACLE EBS VALUE SETS (LOVs)" in content:
            parts = content.split("-- ==========================================================\n-- VIEWS FOR ORACLE EBS VALUE SETS (LOVs)")
            new_content = parts[0].strip() + "\n\n-- ===========================================================\n-- END OF FILE: HMS_CREATE_TABLES_" + suffix + ".sql\n-- ===========================================================\n"
            with open(ddl_file, 'w', encoding='utf-8') as f:
                f.write(new_content)

# 2. Revert the EBS GUI Guide to use Table Names instead of Views
gui_guide_path = os.path.join(BASE_DIR, '06_EBS_Setup', 'HMS_EBS_GUI_GUIDE.md')
if os.path.exists(gui_guide_path):
    with open(gui_guide_path, 'r', encoding='utf-8') as f:
        gui = f.read()
        
    gui = gui.replace('**Table Name:** `HMS_HOSP_BRANCH_V_<SUFFIX>` *(Use this View to bypass EBS LOV restrictions)*', '**Table Name:** `HMS_HOSPITAL_BRANCH_<SUFFIX>`')
    gui = gui.replace('**Table Name:** `HMS_DEPARTMENT_V_<SUFFIX>` *(Use this View to bypass EBS LOV restrictions)*', '**Table Name:** `HMS_DEPARTMENT_<SUFFIX>`')
    
    with open(gui_guide_path, 'w', encoding='utf-8') as f:
        f.write(gui)

print("Successfully reverted LOV view definitions and restored table names in GUI guide.")
