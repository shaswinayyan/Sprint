import os
import shutil

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
SOURCE_FILE = os.path.join(BASE_DIR, '07_Forms_and_Reports', 'HMS_FORMS_AND_BIP_GUIDE.md')

if os.path.exists(SOURCE_FILE):
    with open(SOURCE_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split the content
    parts = content.split('## Part 2: MS Word BI Publisher Report (`.rtf`)')
    part1_forms = parts[0]
    part2_reports = '## Part 2: MS Word BI Publisher Report (`.rtf`)' + parts[1] if len(parts) > 1 else ''

    # Create 04_Forms
    form_dir = os.path.join(BASE_DIR, '04_Forms')
    os.makedirs(form_dir, exist_ok=True)
    with open(os.path.join(form_dir, 'HMS_FORMS_GUIDE.md'), 'w', encoding='utf-8') as f:
        f.write("# Oracle Forms Builder (`.fmb`) Guide\n\n" + part1_forms.replace('# Oracle Forms Builder & BI Publisher Development Guide\n\nThis document provides the exact, step-by-step instructions for building your physical Oracle Forms (`.fmb`) and your Microsoft Word BI Publisher Reporting Template (`.rtf`), perfectly fulfilling the capstone requirements.\n\n---\n\n', ''))

    # Create 05_Reports
    report_dir = os.path.join(BASE_DIR, '05_Reports')
    os.makedirs(report_dir, exist_ok=True)
    with open(os.path.join(report_dir, 'HMS_REPORTS_BIP_GUIDE.md'), 'w', encoding='utf-8') as f:
        f.write("# BI Publisher MS Word Reports (`.rtf`) Guide\n\n" + part2_reports)

    # Delete 07_Forms_and_Reports
    shutil.rmtree(os.path.join(BASE_DIR, '07_Forms_and_Reports'))
    print("Successfully structured into 04_Forms and 05_Reports!")
else:
    print("Source file not found or already moved.")
