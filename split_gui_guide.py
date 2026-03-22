import os

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/06_EBS_Setup'
MASTER_FILE = os.path.join(BASE_DIR, 'HMS_EBS_GUI_GUIDE.md')
MEMBERS = ['SH', 'CH', 'MD', 'NM']

if not os.path.exists(MASTER_FILE):
    print("Master guide not found!")
    exit(1)

with open(MASTER_FILE, 'r', encoding='utf-8') as f:
    master_content = f.read()

# 1. We must explicitly inject the user's specific "Request Help" parameter into the custom sub-menu.
if "Prompt `Request Help`" not in master_content:
    target_block = "Seq `30` | Prompt `Run Employee Report` | Function `HMS_EMP_RPT_<SUFFIX>` | Description `Submits the Employee Department Report`"
    injected_block = "Seq `30` | Prompt `Run Employee Report` | Function `HMS_EMP_RPT_<SUFFIX>` | Description `Submits the Employee Department Report`\n  * Seq `40` | Prompt `Request Help` | Function `Request Help` | Description `Opens standard Oracle Help dialog`"
    master_content = master_content.replace(target_block, injected_block)

# 2. We must explicitly add "Requests: Submit" into the Main Menu, otherwise the user has literally no way 
# to open the Concurrent Programs screen to execute their packages!
if "Requests: Submit" not in master_content:
    main_menu_target = "Seq `10` | Prompt `Hospital Data Entry Forms` | Submenu `HMS_FORMS_SUBMENU_<SUFFIX>` | Description `Navigates into the Data Entry and Execution Sub-Menu`"
    main_menu_inject = "Seq `10` | Prompt `Hospital Data Entry Forms` | Submenu `HMS_FORMS_SUBMENU_<SUFFIX>` | Description `Navigates into the Data Entry and Execution Sub-Menu`\n  * Seq `20` | Prompt `Submit Concurrent Requests` | Function `Requests: Submit` | Description `CRITICAL: Opens the native Oracle Concurrent Manager UI so you can run your PL/SQL Reports`"
    master_content = master_content.replace(main_menu_target, main_menu_inject)


# Generate 4 precise, copy-pasteable files.
for suffix in MEMBERS:
    member_dir = os.path.join(BASE_DIR, suffix)
    if not os.path.exists(member_dir):
        os.makedirs(member_dir)
        
    final_content = master_content.replace('<SUFFIX>', suffix)
    
    # We also have to ensure formatting for exact FND mappings isn't broken.
    member_file = os.path.join(member_dir, f'HMS_EBS_GUI_GUIDE_{suffix}.md')
    with open(member_file, 'w', encoding='utf-8') as f:
        f.write(final_content)

# We leave the MASTER_FILE intact for tracking, or delete it so they use the dedicated ones.
# Actually, renaming it to HMS_EBS_GUI_GUIDE_TEMPLATE.md is safer.
os.rename(MASTER_FILE, os.path.join(BASE_DIR, 'HMS_EBS_GUI_GUIDE_TEMPLATE.md'))

print("Successfully generated 4 dedicated member EBS GUI Guides.")
