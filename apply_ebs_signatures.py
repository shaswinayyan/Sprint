import os
import re

BASE_DIR = 'g:/IITM/Sprint/HMS_Project'
MEMBERS = ['SH', 'CH', 'MD', 'NM']

for suffix in MEMBERS:
    pkg_file = os.path.join(BASE_DIR, '03_PLSQL', suffix, f'HMS_PKG_{suffix}.sql')
    if not os.path.exists(pkg_file): continue
    with open(pkg_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Specifications
    content = content.replace(
        'PROCEDURE GET_BRANCH_SUMMARY (p_hospital_id IN NUMBER);',
        'PROCEDURE GET_BRANCH_SUMMARY (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER);'
    )
    content = content.replace(
        'PROCEDURE GET_BRANCH_SUMMARY (\n        p_hospital_id IN NUMBER\n    );',
        'PROCEDURE GET_BRANCH_SUMMARY (\n        errbuf OUT VARCHAR2,\n        retcode OUT VARCHAR2,\n        p_hospital_id IN NUMBER\n    );'
    )
    
    content = content.replace(
        'PROCEDURE GET_EMPLOYEES_LIST (p_hospital_id IN NUMBER);',
        'PROCEDURE GET_EMPLOYEES_LIST (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER);'
    )
    content = content.replace(
        'PROCEDURE GET_EMPLOYEES_LIST (\n        p_hospital_id IN NUMBER\n    );',
        'PROCEDURE GET_EMPLOYEES_LIST (\n        errbuf OUT VARCHAR2,\n        retcode OUT VARCHAR2,\n        p_hospital_id IN NUMBER\n    );'
    )
    
    content = content.replace(
        'PROCEDURE GET_DEPT_PATIENTS   (p_hospital_id   IN NUMBER,\n                                   p_department_id IN NUMBER);',
        'PROCEDURE GET_DEPT_PATIENTS   (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER, p_department_id IN NUMBER);'
    )
    content = content.replace(
        'PROCEDURE GET_DEPT_PATIENTS (\n        p_hospital_id   IN NUMBER,\n        p_department_id IN NUMBER\n    );',
        'PROCEDURE GET_DEPT_PATIENTS (\n        errbuf OUT VARCHAR2,\n        retcode OUT VARCHAR2,\n        p_hospital_id   IN NUMBER,\n        p_department_id IN NUMBER\n    );'
    )
    
    content = content.replace(
        'PROCEDURE LOAD_STAGING_TO_BASE (p_batch_id IN VARCHAR2 DEFAULT NULL);',
        'PROCEDURE LOAD_STAGING_TO_BASE (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_batch_id IN VARCHAR2 DEFAULT NULL);'
    )
    content = content.replace(
        'PROCEDURE LOAD_STAGING_TO_BASE (\n        p_batch_id IN VARCHAR2 DEFAULT NULL\n    );',
        'PROCEDURE LOAD_STAGING_TO_BASE (\n        errbuf OUT VARCHAR2,\n        retcode OUT VARCHAR2,\n        p_batch_id IN VARCHAR2 DEFAULT NULL\n    );'
    )

    # Body Definitions
    content = content.replace(
        'PROCEDURE GET_BRANCH_SUMMARY (p_hospital_id IN NUMBER) AS',
        'PROCEDURE GET_BRANCH_SUMMARY (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER) AS'
    )
    content = content.replace(
        'PROCEDURE GET_BRANCH_SUMMARY (\n        p_hospital_id IN NUMBER\n    ) AS',
        'PROCEDURE GET_BRANCH_SUMMARY (\n        errbuf OUT VARCHAR2,\n        retcode OUT VARCHAR2,\n        p_hospital_id IN NUMBER\n    ) AS'
    )

    content = content.replace(
        'PROCEDURE GET_EMPLOYEES_LIST (p_hospital_id IN NUMBER) AS',
        'PROCEDURE GET_EMPLOYEES_LIST (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER) AS'
    )
    content = content.replace(
        'PROCEDURE GET_EMPLOYEES_LIST (\n        p_hospital_id IN NUMBER\n    ) AS',
        'PROCEDURE GET_EMPLOYEES_LIST (\n        errbuf OUT VARCHAR2,\n        retcode OUT VARCHAR2,\n        p_hospital_id IN NUMBER\n    ) AS'
    )

    content = content.replace(
        'PROCEDURE GET_DEPT_PATIENTS (p_hospital_id IN NUMBER, p_department_id IN NUMBER) AS',
        'PROCEDURE GET_DEPT_PATIENTS (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_hospital_id IN NUMBER, p_department_id IN NUMBER) AS'
    )
    content = content.replace(
        'PROCEDURE GET_DEPT_PATIENTS (\n        p_hospital_id   IN NUMBER,\n        p_department_id IN NUMBER\n    ) AS',
        'PROCEDURE GET_DEPT_PATIENTS (\n        errbuf OUT VARCHAR2,\n        retcode OUT VARCHAR2,\n        p_hospital_id   IN NUMBER,\n        p_department_id IN NUMBER\n    ) AS'
    )
    
    content = content.replace(
        'PROCEDURE LOAD_STAGING_TO_BASE (p_batch_id IN VARCHAR2 DEFAULT NULL) AS',
        'PROCEDURE LOAD_STAGING_TO_BASE (errbuf OUT VARCHAR2, retcode OUT VARCHAR2, p_batch_id IN VARCHAR2 DEFAULT NULL) AS'
    )
    content = content.replace(
        'PROCEDURE LOAD_STAGING_TO_BASE (\n        p_batch_id IN VARCHAR2 DEFAULT NULL\n    ) AS',
        'PROCEDURE LOAD_STAGING_TO_BASE (\n        errbuf OUT VARCHAR2,\n        retcode OUT VARCHAR2,\n        p_batch_id IN VARCHAR2 DEFAULT NULL\n    ) AS'
    )

    # Change exceptions to handle EBS retcode
    content = content.replace(
        "FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_BRANCH_SUMMARY: ' || SQLERRM);",
        "errbuf := SQLERRM; retcode := '2';\n            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_BRANCH_SUMMARY: ' || SQLERRM);"
    )
    content = content.replace(
        "FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_EMPLOYEES_LIST: ' || SQLERRM);",
        "errbuf := SQLERRM; retcode := '2';\n            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_EMPLOYEES_LIST: ' || SQLERRM);"
    )
    content = content.replace(
        "FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_DEPT_PATIENTS: ' || SQLERRM);",
        "errbuf := SQLERRM; retcode := '2';\n            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UNEXPECTED ERROR in GET_DEPT_PATIENTS: ' || SQLERRM);"
    )
    content = content.replace(
        "DBMS_OUTPUT.PUT_LINE('CRITICAL ERROR: ' || SQLERRM || ' - Transaction rolled back.');",
        "errbuf := SQLERRM; retcode := '2';\n        DBMS_OUTPUT.PUT_LINE('CRITICAL ERROR: ' || SQLERRM || ' - Transaction rolled back.');"
    )
    content = content.replace(
        "FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'CRITICAL ERROR in LOAD_STAGING_TO_BASE: ' || SQLERRM);",
        "errbuf := SQLERRM; retcode := '2';\n            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'CRITICAL ERROR in LOAD_STAGING_TO_BASE: ' || SQLERRM);"
    )
    
    with open(pkg_file, 'w', encoding='utf-8') as f:
        f.write(content)

print("EBS Concurrent Standard signatures applied correctly.")
