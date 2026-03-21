import os

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

for suffix in MEMBERS:
    pkg_file = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
    if os.path.exists(pkg_file):
        with open(pkg_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # We need to replace the old c_patients cursor block if it has the LEFT JOIN.
        # It looks like:
        #         CURSOR c_patients IS
        #             SELECT  p.PATIENT_ID,
        #                     p.PATIENT_FIRST_NAME,
        #                     p.PATIENT_LAST_NAME,
        #                     pp.PHONE_NUMBER,
        #                     p.EMAIL_ID,
        #                     p.ADDRESS_CITY
        #               FROM  HMS_PATIENT_SH p
        #               LEFT JOIN HMS_PATIENT_PHONE_MST_SH pp
        #                      ON p.PATIENT_ID  = pp.PATIENT_ID
        #                     AND pp.PHONE_TYPE = 'PRIMARY'
        #              WHERE  p.HOSPITAL_ID   = p_hospital_id
        #                AND  p.DEPARTMENT_ID = p_department_id
        #              ORDER BY p.PATIENT_ID;

        # Let's cleanly replace the entire cursor logic by finding "CURSOR c_patients IS"
        # and replacing everything until "ORDER BY p.PATIENT_ID;"
        
        import re
        pattern = re.compile(r'CURSOR c_patients IS.*?ORDER BY p\.PATIENT_ID;', re.DOTALL)
        
        fixed_cursor = f"""CURSOR c_patients IS
            SELECT  p.PATIENT_ID,
                    p.PATIENT_FIRST_NAME,
                    p.PATIENT_LAST_NAME,
                    p.PATIENT_PHONE_NUMBER AS PHONE_NUMBER,
                    p.EMAIL_ID,
                    p.ADDRESS_CITY
              FROM  HMS_PATIENT_{suffix} p
             WHERE  p.HOSPITAL_ID   = p_hospital_id
               AND  p.DEPARTMENT_ID = p_department_id
             ORDER BY p.PATIENT_ID;"""
             
        if "LEFT JOIN HMS_PATIENT_PHONE_MST" in content:
            new_content = pattern.sub(fixed_cursor, content)
            
            with open(pkg_file, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed c_patients cursor in HMS_PKG_{suffix}.sql")
        else:
            print(f"HMS_PKG_{suffix}.sql already looks clean or pattern didn't match.")
