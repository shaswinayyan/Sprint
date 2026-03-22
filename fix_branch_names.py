import os
import csv

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/02_Data'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

for suffix in MEMBERS:
    target_path = os.path.join(BASE_DIR, suffix, f"HMS_BRANCH_DATA_{suffix}.csv")
    if not os.path.exists(target_path): continue

    rows = []
    with open(target_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader)
        rows.append(header)
        for row in reader:
            # Row index 2 is BRANCH_NAME, index 3 is CITY
            if len(row) > 3:
                # Replace the BRANCH_NAME exactly with the CITY name
                row[2] = row[3]
            rows.append(row)

    with open(target_path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerows(rows)

print("Successfully sanitized all Branch Names to match Cities precisely!")
