import os
import random

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = ['SH', 'CH', 'MD', 'NM']
DEPARTMENTS = ['Kidney', 'Knee Replacements', 'Orthopedics', 'Critical Care']
CITIES = ['Mumbai', 'Delhi', 'Bangalore']

FIRST_NAMES = ['Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Reyansh', 'Ayaan', 'Krishna', 'Ishaan', 'Shaurya', 'Atharv', 'Ananya', 'Diya', 'Advika', 'Jiya', 'Saanvi', 'Aadhya', 'Pari', 'Avni', 'Riya', 'Aarohi', 'Neha', 'Pooja', 'Rahul', 'Rohit', 'Karan', 'Sneha', 'Shruti', 'Priya']
LAST_NAMES = ['Sharma', 'Verma', 'Gupta', 'Singh', 'Kumar', 'Patel', 'Desai', 'Joshi', 'Reddy', 'Rao', 'Yadav', 'Das', 'Chatterjee', 'Iyer', 'Menon', 'Nair', 'Pillai']
STREETS = ['MG Road', 'Linking Road', 'Brigade Road', 'Park Street', 'FC Road', 'Commercial Street', 'Colaba Causeway', 'Connaught Place', 'Andheri West', 'Bandra East']

def gen_phone():
    return f"9{random.randint(100000000, 999999999)}"

for suffix in MEMBERS:
    ddl_dir = os.path.join(BASE_DIR, '01_DDL', suffix)
    data_dir = os.path.join(BASE_DIR, '02_Data', suffix)
    os.makedirs(data_dir, exist_ok=True)
    
    # 1. Update DDL Comments
    ddl_file = os.path.join(ddl_dir, f'HMS_CREATE_TABLES_{suffix}.sql')
    if os.path.exists(ddl_file):
        with open(ddl_file, 'r') as f:
            content = f.read()
        content = content.replace('Cardiology, ICU', 'Kidney, Critical Care')
        content = content.replace('Orthopedics', 'Knee Replacements')
        with open(ddl_file, 'w') as f:
            f.write(content)
            
    # 2. Generate Hospital CSV
    with open(os.path.join(data_dir, f'HMS_HOSPITAL_DATA_{suffix}.csv'), 'w') as f:
        f.write("HOSPITAL_CODE,CITY_NAME,HOSPITAL_NAME,HOSPITAL_BASIC_FEES\n")
        for i, city in enumerate(CITIES, 1):
            f.write(f"H00{i},{city},HMS {city},{random.randint(4, 8) * 100}\n")
            
    # 3. Generate Branch CSV (Not staged currently, but keeping data intact)
    # 4. Generate Department CSV
    dept_id = 1
    with open(os.path.join(data_dir, f'HMS_DEPARTMENT_DATA_{suffix}.csv'), 'w') as f:
        f.write("DEPARTMENT_ID,HOSPITAL_ID,DEPARTMENT_NAME,DEPT_MANAGER,NUMBER_OF_BEDS\n")
        for hosp_id in range(1, 4):
            for dept in DEPARTMENTS:
                manager = f"Dr. {random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
                beds = random.randint(10, 50)
                f.write(f"{dept_id},{hosp_id},{dept},{manager},{beds}\n")
                dept_id += 1
                
    # 5. Generate Employees CSV (Doctors and Staff)
    emp_id = 1
    with open(os.path.join(data_dir, f'HMS_EMPLOYEE_DATA_{suffix}.csv'), 'w') as f:
        f.write("EMPLOYEE_ID,HOSPITAL_ID,DEPARTMENT_ID,EMPLOYEE_FIRST_NAME,EMPLOYEE_LAST_NAME,EMPLOYEE_TYPE,EMAIL_ID\n")
        d_id = 1
        for hosp_id in range(1, 4):
            for dept in DEPARTMENTS:
                # 2 Doctors
                for _ in range(2):
                    fn = random.choice(FIRST_NAMES)
                    ln = random.choice(LAST_NAMES)
                    f.write(f"{emp_id},{hosp_id},{d_id},{fn},{ln},DOCTOR,{fn.lower()}.{ln.lower()}@hms.com\n")
                    emp_id += 1
                # 2 Staff
                for _ in range(2):
                    fn = random.choice(FIRST_NAMES)
                    ln = random.choice(LAST_NAMES)
                    f.write(f"{emp_id},{hosp_id},{d_id},{fn},{ln},STAFF,{fn.lower()}.{ln.lower()}@hms.com\n")
                    emp_id += 1
                d_id += 1
                
    # 6. Generate Robust Patient CSV
    pat_id = 1
    with open(os.path.join(data_dir, f'HMS_PATIENT_DATA_{suffix}.csv'), 'w') as f:
        f.write("PATIENT_ID,HOSPITAL_ID,DEPARTMENT_ID,PATIENT_FIRST_NAME,PATIENT_LAST_NAME,PATIENT_PHONE_NUMBER,EMAIL_ID,ADDRESS_STREET,ADDRESS_CITY,ADDRESS_STATE,ADDRESS_POSTAL_CODE\n")
        d_id = 1
        for hosp_id in range(1, 4):
            for dept in DEPARTMENTS:
                # 5 Patients per department
                for _ in range(5):
                    fn = random.choice(FIRST_NAMES)
                    ln = random.choice(LAST_NAMES)
                    phone = gen_phone()
                    street = f"{random.randint(1, 999)} {random.choice(STREETS)}"
                    city = CITIES[hosp_id - 1]
                    zipc = f"{random.randint(10, 99)}00{random.randint(10, 99)}"
                    f.write(f"{pat_id},{hosp_id},{d_id},{fn},{ln},{phone},{fn.lower()}{random.randint(1,99)}@gmail.com,{street},{city},{city} State,{zipc}\n")
                    pat_id += 1
                d_id += 1

print("Robust Data Generation Complete!")
