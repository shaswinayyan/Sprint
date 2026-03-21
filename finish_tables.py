import os
import random

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = ['SH', 'CH', 'MD', 'NM']
DAYS = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY']

def gen_phone():
    return f"9{random.randint(100000000, 999999999)}"

for suffix in MEMBERS:
    # 1. Append Staging Tables to DDL
    stg_sql = os.path.join(BASE_DIR, '01_DDL', suffix, f'HMS_CREATE_STAGING_TABLES_{suffix}.sql')
    if os.path.exists(stg_sql):
        with open(stg_sql, 'r') as f:
            content = f.read()
            
        if "HMS_EMPLOYEE_PHONE_MST_STG" not in content:
            new_tables = f"""
-- ===========================================================
-- STAGING TABLE 6: HMS_EMPLOYEE_PHONE_MST_STG_{suffix}
-- ===========================================================
CREATE TABLE HMS_EMPLOYEE_PHONE_MST_STG_{suffix} (
    STG_ID              NUMBER          NOT NULL,
    BATCH_ID            VARCHAR2(50),
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',
    ERROR_LOG           VARCHAR2(4000),

    PHONE_RECORD_ID     NUMBER(10),
    EMPLOYEE_ID         NUMBER(10),
    PHONE1              VARCHAR2(15),
    PHONE2              VARCHAR2(15),

    CREATED_BY          NUMBER          NOT NULL,
    CREATION_DATE       DATE            NOT NULL,
    LAST_UPDATED_BY     NUMBER          NOT NULL,
    LAST_UPDATE_DATE    DATE            NOT NULL,
    LAST_UPDATE_LOGIN   NUMBER,

    CONSTRAINT PK_EMP_PH_STG_{suffix}  PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_EMP_PH_STG_ST_{suffix} CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);
CREATE SEQUENCE HMS_EMP_PHONE_STG_SEQ_{suffix} START WITH 1 INCREMENT BY 1 NOCACHE;

-- ===========================================================
-- STAGING TABLE 7: HMS_DOCTOR_AVAILABILITY_STG_{suffix}
-- ===========================================================
CREATE TABLE HMS_DOCTOR_AVAILABILITY_STG_{suffix} (
    STG_ID              NUMBER          NOT NULL,
    BATCH_ID            VARCHAR2(50),
    RECORD_STATUS       VARCHAR2(20)    DEFAULT 'NEW',
    ERROR_LOG           VARCHAR2(4000),

    AVAILABILITY_ID     NUMBER(10),
    DOCTOR_ID           NUMBER(10),
    DOCTOR_DEPARTMENT   NUMBER(10),
    AVAILABILITY_DAY    VARCHAR2(10),
    START_TIME          VARCHAR2(8),
    END_TIME            VARCHAR2(8),

    CREATED_BY          NUMBER          NOT NULL,
    CREATION_DATE       DATE            NOT NULL,
    LAST_UPDATED_BY     NUMBER          NOT NULL,
    LAST_UPDATE_DATE    DATE            NOT NULL,
    LAST_UPDATE_LOGIN   NUMBER,

    CONSTRAINT PK_DOC_AV_STG_{suffix}   PRIMARY KEY (STG_ID),
    CONSTRAINT CHK_DOC_AV_STG_ST_{suffix} CHECK (RECORD_STATUS IN ('NEW','VALIDATED','LOADED','ERROR'))
);
CREATE SEQUENCE HMS_DOC_AVAIL_STG_SEQ_{suffix} START WITH 1 INCREMENT BY 1 NOCACHE;
"""
            if "-- END OF FILE:" in content:
                content = content.replace("-- END OF FILE:", new_tables + "\n-- END OF FILE:")
            else:
                content += new_tables
            with open(stg_sql, 'w') as f:
                f.write(content)

    # 2. Append PL/SQL Processing blocks
    pkg = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
    if os.path.exists(pkg):
        with open(pkg, 'r') as f:
            content = f.read()
            
        if "SECTION 3.5" not in content:
            new_blocks = f"""
        -- ===================================================
        -- SECTION 3.5: Process HMS_EMPLOYEE_PHONE_MST_STG_{suffix}
        -- ===================================================
        DBMS_OUTPUT.PUT_LINE('[3.5/7] Processing HMS_EMPLOYEE_PHONE_MST_STG_{suffix} ...');
        FOR r IN (SELECT * FROM HMS_EMPLOYEE_PHONE_MST_STG_{suffix} WHERE RECORD_STATUS = 'NEW' AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;
            IF r.PHONE_RECORD_ID IS NULL OR r.EMPLOYEE_ID IS NULL OR r.PHONE1 IS NULL THEN
                v_error_msg := 'PK, FK, or PHONE1 is NULL. ';
            END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_EMPLOYEE_PHONE_MST_STG_{suffix} SET RECORD_STATUS = 'ERROR', ERROR_LOG = v_error_msg, LAST_UPDATED_BY = C_USER_ID, LAST_UPDATE_DATE = v_now, LAST_UPDATE_LOGIN = v_login_id WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_EMPLOYEE_PHONE_MST_{suffix} (PHONE_RECORD_ID, EMPLOYEE_ID, PHONE1, PHONE2) VALUES (r.PHONE_RECORD_ID, r.EMPLOYEE_ID, r.PHONE1, r.PHONE2);
                UPDATE HMS_EMPLOYEE_PHONE_MST_STG_{suffix} SET RECORD_STATUS = 'LOADED', ERROR_LOG = NULL, LAST_UPDATED_BY = C_USER_ID, LAST_UPDATE_DATE = v_now, LAST_UPDATE_LOGIN = v_login_id WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;

        -- ===================================================
        -- SECTION 3.6: Process HMS_DOCTOR_AVAILABILITY_STG_{suffix}
        -- ===================================================
        DBMS_OUTPUT.PUT_LINE('[3.6/7] Processing HMS_DOCTOR_AVAILABILITY_STG_{suffix} ...');
        FOR r IN (SELECT * FROM HMS_DOCTOR_AVAILABILITY_STG_{suffix} WHERE RECORD_STATUS = 'NEW' AND (p_batch_id IS NULL OR BATCH_ID = p_batch_id) ORDER BY STG_ID) LOOP
            v_error_msg := NULL;
            IF r.AVAILABILITY_ID IS NULL OR r.DOCTOR_ID IS NULL OR r.DOCTOR_DEPARTMENT IS NULL OR r.AVAILABILITY_DAY IS NULL OR r.START_TIME IS NULL OR r.END_TIME IS NULL THEN
                v_error_msg := 'One or more required fields is NULL. ';
            END IF;
            IF v_error_msg IS NOT NULL THEN
                UPDATE HMS_DOCTOR_AVAILABILITY_STG_{suffix} SET RECORD_STATUS = 'ERROR', ERROR_LOG = v_error_msg, LAST_UPDATED_BY = C_USER_ID, LAST_UPDATE_DATE = v_now, LAST_UPDATE_LOGIN = v_login_id WHERE STG_ID = r.STG_ID;
                v_error_count := v_error_count + 1;
            ELSE
                INSERT INTO HMS_DOCTOR_AVAILABILITY_{suffix} (AVAILABILITY_ID, DOCTOR_ID, DOCTOR_DEPARTMENT, AVAILABILITY_DAY, START_TIME, END_TIME) VALUES (r.AVAILABILITY_ID, r.DOCTOR_ID, r.DOCTOR_DEPARTMENT, r.AVAILABILITY_DAY, r.START_TIME, r.END_TIME);
                UPDATE HMS_DOCTOR_AVAILABILITY_STG_{suffix} SET RECORD_STATUS = 'LOADED', ERROR_LOG = NULL, LAST_UPDATED_BY = C_USER_ID, LAST_UPDATE_DATE = v_now, LAST_UPDATE_LOGIN = v_login_id WHERE STG_ID = r.STG_ID;
                v_loaded_count := v_loaded_count + 1;
            END IF;
        END LOOP;
"""
            marker = f"-- SECTION 4: Process HMS_PATIENT_STG_{suffix}"
            if marker in content:
                content = content.replace(marker, new_blocks + "\n        " + marker)
            with open(pkg, 'w') as f:
                f.write(content)
                
    # 3. Generating CSVs
    data_dir = os.path.join(BASE_DIR, '02_Data', suffix)
    os.makedirs(data_dir, exist_ok=True)
    
    with open(os.path.join(data_dir, f'HMS_EMP_PHONE_DATA_{suffix}.csv'), 'w') as f:
        f.write("PHONE_RECORD_ID,EMPLOYEE_ID,PHONE1,PHONE2\n")
        for i in range(1, 49):
            f.write(f"{i},{i},{gen_phone()},\n")
            
    avail_id = 1
    with open(os.path.join(data_dir, f'HMS_DOC_AVAIL_DATA_{suffix}.csv'), 'w') as f:
        f.write("AVAILABILITY_ID,DOCTOR_ID,DOCTOR_DEPARTMENT,AVAILABILITY_DAY,START_TIME,END_TIME\n")
        d_id = 1
        emp_id = 1
        for hosp_id in range(1, 4):
            for dept in range(4):
                for day in ['MONDAY', 'WEDNESDAY', 'FRIDAY']:
                    f.write(f"{avail_id},{emp_id},{d_id},{day},09:00 AM,05:00 PM\n")
                    avail_id += 1
                emp_id += 1
                for day in ['TUESDAY', 'THURSDAY', 'SATURDAY']:
                    f.write(f"{avail_id},{emp_id},{d_id},{day},10:00 AM,06:00 PM\n")
                    avail_id += 1
                emp_id += 1
                emp_id += 2
                d_id += 1

    # 4. Generate CTL Files
    ctl1 = f"""LOAD DATA\nINFILE 'HMS_EMP_PHONE_DATA_{suffix}.csv'\nINTO TABLE HMS_EMPLOYEE_PHONE_MST_STG_{suffix}\nAPPEND\nFIELDS TERMINATED BY ','\nOPTIONALLY ENCLOSED BY '"'\nTRAILING NULLCOLS\n(PHONE_RECORD_ID, EMPLOYEE_ID, PHONE1, PHONE2)\n"""
    with open(os.path.join(data_dir, f'HMS_EMP_PHONE_{suffix}.ctl'), 'w') as f:
        f.write(ctl1)
        
    ctl2 = f"""LOAD DATA\nINFILE 'HMS_DOC_AVAIL_DATA_{suffix}.csv'\nINTO TABLE HMS_DOCTOR_AVAILABILITY_STG_{suffix}\nAPPEND\nFIELDS TERMINATED BY ','\nOPTIONALLY ENCLOSED BY '"'\nTRAILING NULLCOLS\n(AVAILABILITY_ID, DOCTOR_ID, DOCTOR_DEPARTMENT, AVAILABILITY_DAY, START_TIME, END_TIME)\n"""
    with open(os.path.join(data_dir, f'HMS_DOC_AVAIL_{suffix}.ctl'), 'w') as f:
        f.write(ctl2)

print("Generated staging tables, CSV data, CTL files, and PL/SQL for Employee Phones and Doc Availability.")
