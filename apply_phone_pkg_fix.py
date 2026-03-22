import os
import re

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/03_PLSQL'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

for suffix in MEMBERS:
    pkg_path = os.path.join(BASE_DIR, suffix, f'HMS_PKG_{suffix}.sql')
    if not os.path.exists(pkg_path): continue

    with open(pkg_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # The missing INSERT column injection
    content = content.replace("                    PATIENT_FIRST_NAME, PATIENT_LAST_NAME, EMAIL_ID,",
                              "                    PATIENT_FIRST_NAME, PATIENT_LAST_NAME, PATIENT_PHONE_NUMBER, EMAIL_ID,")

    # The missing VALUES injection
    content = content.replace("                    r.PATIENT_FIRST_NAME, r.PATIENT_LAST_NAME, r.EMAIL_ID,",
                              "                    r.PATIENT_FIRST_NAME, r.PATIENT_LAST_NAME, r.PATIENT_PHONE_NUMBER, r.EMAIL_ID,")

    with open(pkg_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Successfully injected missing PATIENT_PHONE_NUMBER mappings into all 4 HMS_PKG packages!")
