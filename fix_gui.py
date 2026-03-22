import os
import shutil

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/06_EBS_Setup'
MASTER_FILE = os.path.join(BASE_DIR, 'HMS_EBS_GUI_GUIDE_TEMPLATE.md')
MEMBERS = ['SH', 'CH', 'MD', 'NM']

with open(MASTER_FILE, 'r', encoding='utf-8') as f:
    master_content = f.read()

# Remove the Request Help injection and replace it with Submit Requests
target_block1 = "Seq `30` | Prompt `Run Employee Report` | Function `HMS_EMP_RPT_<SUFFIX>` | Description `Submits the Employee Department Report`\n  * Seq `40` | Prompt `Request Help` | Function `Request Help` | Description `Opens standard Oracle Help dialog`"
inject_block1 = "Seq `30` | Prompt `Run Employee Report` | Function `HMS_EMP_RPT_<SUFFIX>` | Description `Submits the Employee Department Report`\n  * Seq `40` | Prompt `Submit Requests` | Function `Requests: Submit` | Description `CRITICAL: Opens native Oracle Request submission window to execute the PL/SQL`"

master_content = master_content.replace(target_block1, inject_block1)

# Remove the Main Menu redundant Seq 20 Submit Request
target_block2 = "Seq `10` | Prompt `Hospital Data Entry Forms` | Submenu `HMS_FORMS_SUBMENU_<SUFFIX>` | Description `Navigates into the Data Entry and Execution Sub-Menu`\n  * Seq `20` | Prompt `Submit Concurrent Requests` | Function `Requests: Submit` | Description `CRITICAL: Opens the native Oracle Concurrent Manager UI so you can run your PL/SQL Reports`"
inject_block2 = "Seq `10` | Prompt `Hospital Data Entry Forms` | Submenu `HMS_FORMS_SUBMENU_<SUFFIX>` | Description `Navigates into the Data Entry and Execution Sub-Menu`"

master_content = master_content.replace(target_block2, inject_block2)

# Write master back just in case
with open(MASTER_FILE, 'w', encoding='utf-8') as f:
    f.write(master_content)

# Regenerate the 4 suffixes
for suffix in MEMBERS:
    member_dir = os.path.join(BASE_DIR, suffix)
    member_file = os.path.join(member_dir, f'HMS_EBS_GUI_GUIDE_{suffix}.md')
    final_content = master_content.replace('<SUFFIX>', suffix)
    with open(member_file, 'w', encoding='utf-8') as f:
        f.write(final_content)

print("Pushed Submit Request directly into Submenu Seq 40 and purged redundancies.")
