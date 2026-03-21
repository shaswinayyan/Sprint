import os
import re

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = {
    'SH': ('Shaswin', '1021027'),
    'CH': ('Chandana', '1021034'),
    'MD': ('Manideep', '1021035'),
    'NM': ('Namitha', '1021052')
}

# 1. Update README.md
readme_path = os.path.join(BASE_DIR, 'README.md')
if os.path.exists(readme_path):
    with open(readme_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for suffix, (name, uid) in MEMBERS.items():
        if suffix != 'SH':
            content = re.sub(rf'- \*\*{name} \({suffix}\)\*\* - User ID: .*', rf'- **{name} ({suffix})** - User ID: `{uid}`', content)
    
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write(content)

# 2. Append View Creation to DDLs to fix LOV visibility in EBS
for suffix in MEMBERS.keys():
    ddl_file = os.path.join(BASE_DIR, '01_DDL', suffix, f'HMS_CREATE_TABLES_{suffix}.sql')
    if os.path.exists(ddl_file):
        with open(ddl_file, 'r', encoding='utf-8') as f:
            ddl_content = f.read()
        
        view_str = f"""
-- ===========================================================
-- VIEWS FOR ORACLE EBS VALUE SETS (LOVs)
-- Purpose: Unregistered custom tables sometimes do not appear
-- in the Application Developer Value Set LOV. Creating a view
-- guarantees visibility across the EBS GUI layer.
-- ===========================================================
CREATE OR REPLACE VIEW HMS_HOSP_BRANCH_V_{suffix} AS 
SELECT HOSPITAL_ID, BRANCH_NAME FROM HMS_HOSPITAL_BRANCH_{suffix};

CREATE OR REPLACE VIEW HMS_DEPARTMENT_V_{suffix} AS 
SELECT DEPARTMENT_ID, DEPARTMENT_NAME FROM HMS_DEPARTMENT_{suffix};
"""
        if "VIEWS FOR ORACLE" not in ddl_content:
            if "-- END OF FILE:" in ddl_content:
                ddl_content = ddl_content.replace("-- END OF FILE:", view_str + "\n-- END OF FILE:")
            else:
                ddl_content += view_str
                
            with open(ddl_file, 'w', encoding='utf-8') as f:
                f.write(ddl_content)

# 3. Update the EBS GUI Guide to use the new Views
gui_guide_path = os.path.join(BASE_DIR, '06_EBS_Setup', 'HMS_EBS_GUI_GUIDE.md')
if os.path.exists(gui_guide_path):
    with open(gui_guide_path, 'r', encoding='utf-8') as f:
        gui = f.read()
        
    gui = gui.replace('**Table Name:** `HMS_HOSPITAL_BRANCH_<SUFFIX>`', '**Table Name:** `HMS_HOSP_BRANCH_V_<SUFFIX>` *(Use this View to bypass EBS LOV restrictions)*')
    gui = gui.replace('**Table Name:** `HMS_DEPARTMENT_<SUFFIX>`', '**Table Name:** `HMS_DEPARTMENT_V_<SUFFIX>` *(Use this View to bypass EBS LOV restrictions)*')
    
    with open(gui_guide_path, 'w', encoding='utf-8') as f:
        f.write(gui)

print("Updated README.md, created EBS UI Views in DDL, and updated GUI Guide.")
