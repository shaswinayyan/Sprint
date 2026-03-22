import os

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/06_EBS_Setup'
MASTER_FILE = os.path.join(BASE_DIR, 'HMS_EBS_GUI_GUIDE_TEMPLATE.md')
MEMBERS = ['SH', 'CH', 'MD', 'NM']

with open(MASTER_FILE, 'r', encoding='utf-8') as f:
    master_content = f.read()

# 1. Remove Seq 40 entirely from the Sub-Menu block
target_block1 = "Seq `30` | Prompt `Run Employee Report` | Function `HMS_EMP_RPT_<SUFFIX>` | Description `Submits the Employee Department Report`\n  * Seq `40` | Prompt `Submit Requests` | Function `Requests: Submit` | Description `CRITICAL: Opens native Oracle Request submission window to execute the PL/SQL`"
inject_block1 = "Seq `30` | Prompt `Run Employee Report` | Function `HMS_EMP_RPT_<SUFFIX>` | Description `Submits the Employee Department Report`"

master_content = master_content.replace(target_block1, inject_block1)

# 2. Add Seq 20 (Requests: Submit) back onto the Main Menu block
target_block2 = "Seq `10` | Prompt `Hospital Data Entry Forms` | Submenu `HMS_FORMS_SUBMENU_<SUFFIX>` | Description `Navigates into the Data Entry and Execution Sub-Menu`\n* -> **Save**"
inject_block2 = "Seq `10` | Prompt `Hospital Data Entry Forms` | Submenu `HMS_FORMS_SUBMENU_<SUFFIX>` | Description `Navigates into the Data Entry and Execution Sub-Menu`\n  * Seq `20` | Prompt `Submit Concurrent Requests` | Function `Requests: Submit` | Description `CRITICAL: Opens native Oracle Request submission window to execute your PL/SQL`\n* -> **Save**"

master_content = master_content.replace(target_block2, inject_block2)

# Save the MASTER
with open(MASTER_FILE, 'w', encoding='utf-8') as f:
    f.write(master_content)

# Save the 4 dedicated files
for suffix in MEMBERS:
    member_dir = os.path.join(BASE_DIR, suffix)
    member_file = os.path.join(member_dir, f'HMS_EBS_GUI_GUIDE_{suffix}.md')
    final_content = master_content.replace('<SUFFIX>', suffix)
    with open(member_file, 'w', encoding='utf-8') as f:
        f.write(final_content)

print("Restored Submit Requests exactly into Main Menu Seq 20 and purged Sub-Menu Seq 40.")
