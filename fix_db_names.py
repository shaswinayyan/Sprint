import os
import re

BASE_DIR = 'g:/IITM/Sprint/HMS_Project/01_DDL'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

def fix_file(filepath, suffix):
    with open(filepath, 'r') as f:
        content = f.read()

    # Fix constraints
    # Match: CONSTRAINT <NAME>
    pattern_c = r'(?i)CONSTRAINT\s+([A-Z0-9_]+)'
    unique_constraints = set(re.findall(pattern_c, content))
    
    for c_name in unique_constraints:
        if not c_name.endswith('_' + suffix):
            base_name = c_name[:26]
            new_name = base_name + '_' + suffix
            content = re.sub(r'\b' + c_name + r'\b', new_name, content)
            
    # Fix sequences
    # Match: CREATE SEQUENCE <NAME>
    pattern_s = r'(?i)CREATE\s+SEQUENCE\s+([A-Z0-9_]+)'
    unique_seqs = set(re.findall(pattern_s, content))
    
    for s_name in unique_seqs:
        if not s_name.endswith('_' + suffix):
            base_name = s_name[:26]
            new_name = base_name + '_' + suffix
            content = re.sub(r'\b' + s_name + r'\b', new_name, content)

    with open(filepath, 'w') as f:
        f.write(content)

for suffix in MEMBERS:
    # 1. Base tables
    f1 = os.path.join(BASE_DIR, suffix, f'HMS_CREATE_TABLES_{suffix}.sql')
    if os.path.exists(f1):
        fix_file(f1, suffix)
        
    # 2. Staging tables
    f2 = os.path.join(BASE_DIR, suffix, f'HMS_CREATE_STAGING_TABLES_{suffix}.sql')
    if os.path.exists(f2):
        fix_file(f2, suffix)

print("Constraints and sequences successfully suffixed!")
