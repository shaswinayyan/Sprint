# Oracle EBS GUI — Step-by-Step Setup Guide
## Hospital Management System (HMS)
> **Oracle EBS 12.2.8** | **Application:** Application Object Library (AOL)
> **Schema:** APPS | **Team:** SH (Shaswin), CH (Chandana), MD (Manideep), NM (Namitha)

---

## 📋 PART 1 — SQL Developer: Run DDL & PL/SQL

### Step 1.1 — Open SQL Developer & Connect

1. Launch **SQL Developer** on your system
2. Click **New Connection** (green `+` icon)
3. Fill in the connection form:

| Field | Value |
|-------|-------|
| **Connection Name** | `HMS_APPS_<YOUR_SUFFIX>` (e.g., `HMS_APPS_SH`) |
| **Username** | `APPS` |
| **Password** | *(as provided by your institute)* |
| **Connection Type** | `Basic` |
| **Hostname** | *(your Oracle server hostname/IP)* |
| **Port** | `1521` *(default; confirm with lab)* |
| **SID** | *(your Oracle SID, e.g.,* `EBSDEV`*)* |

4. Click **Test** → should say **Success**
5. Click **Connect**

---

### Step 1.2 — Run DDL (Create Tables & Staging)

1. Go to **File → Open** → select `01_DDL\<YOUR_SUFFIX>\HMS_CREATE_TABLES_<YOUR_SUFFIX>.sql`
2. Press **F5** (Run Script) — runs the entire file
3. Next, open `01_DDL\<YOUR_SUFFIX>\HMS_CREATE_STAGING_TABLES_<YOUR_SUFFIX>.sql` and run it too.
4. Verify in the Script Output panel: no errors shown
5. To confirm your tables exist, run:
   ```sql
   SELECT table_name FROM user_tables WHERE table_name LIKE 'HMS_%\_<YOUR_SUFFIX>' ESCAPE '\' ORDER BY 1;
   ```
   You should see **12 tables** listed (7 base + 5 staging).

---

### Step 1.3 — Run Bulk Upload (SQL*Loader)

> Run this from **Command Prompt** (Windows CMD), not SQL Developer.

1. Open Command Prompt (`cmd`)
2. Navigate to your data folder:
   ```cmd
   cd G:\IITM\Sprint\HMS_Project\02_Data\SH
   ```
   *(Replace `SH` with your suffix: CH / MD / NM)*

3. Run your automated double-click SQL*Loader batch script to load all 7 tables instantly:
   ```cmd
   load_all_data_SH.bat
   ```
   *(Replace `SH` with your suffix: CH / MD / NM. Ensure your connection VPN/network allows traffic to `150.136.96.10:1521`)*

4. After each run, open the `.log` file to confirm **0 rows rejected**.

5. Verify row counts in SQL Developer:
   ```sql
   SELECT 'HMS_HOSPITAL_MASTER' tbl, COUNT(*) cnt FROM HMS_HOSPITAL_MASTER UNION ALL
   SELECT 'HMS_DEPARTMENT',          COUNT(*)     FROM HMS_DEPARTMENT        UNION ALL
   SELECT 'HMS_EMPLOYEES',           COUNT(*)     FROM HMS_EMPLOYEES         UNION ALL
   SELECT 'HMS_PATIENT',             COUNT(*)     FROM HMS_PATIENT;
   ```

---

### Step 1.4 — Compile & Test PL/SQL Package

1. In SQL Developer, open your package file:
   - SH → `03_PLSQL\SH\HMS_PKG_SH.sql`
   - CH → `03_PLSQL\CH\HMS_PKG_CH.sql`
   - MD → `03_PLSQL\MD\HMS_PKG_MD.sql`
   - NM → `03_PLSQL\NM\HMS_PKG_NM.sql`

2. Press **F5** to compile. Check for **"Package compiled"** messages.

3. Enable output and test:
   ```sql
   SET SERVEROUTPUT ON SIZE UNLIMITED;

   -- Test 1: Branch Summary (Hospital ID = 1)
   EXEC HMS_PKG_SH.GET_BRANCH_SUMMARY(1);

   -- Test 2: Employee List (Hospital ID = 1)
   EXEC HMS_PKG_SH.GET_EMPLOYEES_LIST(1);

   -- Test 3: Dept Patients (Hospital ID 1, Dept ID 1)
   EXEC HMS_PKG_SH.GET_DEPT_PATIENTS(1, 1);
   ```
   *(Replace `HMS_PKG_SH` with your suffix's package name)*

---

## 📋 PART 2 — Oracle EBS GUI: AOL Setup

> **How to navigate:** Log into Oracle EBS → click **Navigator** hamburger icon → choose the Responsibility → follow the menu path shown below each step.

---

### Step 2.1 — Create Oracle EBS User

**Navigation:** `System Administrator` responsibility → **Security → User → Define**

| Field | SH Value | CH Value | MD Value | NM Value |
|-------|----------|----------|----------|----------|
| **User Name** | `HMS_USER_SH` | `HMS_USER_CH` | `HMS_USER_MD` | `HMS_USER_NM` |
| **Password** | Set any password | Same | Same | Same |
| **Password Expiration** | `None` | Same | Same | Same |
| **Description** | `HMS User - Shaswin` | `HMS User - Chandana` | `HMS User - Manideep` | `HMS User - Namitha` |

**After filling fields:**
1. Click the **Responsibilities** tab at the bottom
2. Add the responsibility you will create in Step 2.2
3. Click **Save** (floppy disk icon or Ctrl+S)

---

### Step 2.2 — Create Responsibility

**Navigation:** `System Administrator` → **Security → Responsibility → Define**

| Field | SH Value | CH Value | MD Value | NM Value |
|-------|----------|----------|----------|----------|
| **Responsibility Name** | `HMS Responsibility SH` | `HMS Responsibility CH` | `HMS Responsibility MD` | `HMS Responsibility NM` |
| **Application** | `Application Object Library` | Same | Same | Same |
| **Responsibility Key** | `HMS_RESP_SH` | `HMS_RESP_CH` | `HMS_RESP_MD` | `HMS_RESP_NM` |
| **Effective Date From** | Today's date | Same | Same | Same |
| **Data Group Name** | `Standard` | Same | Same | Same |
| **Data Group Application** | `Application Object Library` | Same | Same | Same |
| **Menu** | `HMS_MENU_SH` | `HMS_MENU_CH` | `HMS_MENU_MD` | `HMS_MENU_NM` |
| **Request Group** | `HMS_REQ_GROUP_SH` | `HMS_REQ_GROUP_CH` | `HMS_REQ_GROUP_MD` | `HMS_REQ_GROUP_NM` |
| **Description** | `HMS Project Responsibility for Shaswin` | ...Chandana | ...Manideep | ...Namitha |

> ⚠️ **Leave Menu and Request Group blank for now** — you'll come back and fill them after creating the Menu and Request Group in Steps 2.4 and 2.7. Save with them filled in finally.

Click **Save**.

---

### Step 2.3 — Create Functions (one per Form/Report)

**Navigation:** `Application Developer` responsibility → **Application → Function → Define**

> You will create **3 functions** per member. Follow this for each:

#### Function 1 — Patient Form

| Field | SH | CH | MD | NM |
|-------|----|----|----|----|
| **Function Name** | `HMS_PAT_FORM_SH` | `HMS_PAT_FORM_CH` | `HMS_PAT_FORM_MD` | `HMS_PAT_FORM_NM` |
| **User Function Name** | `HMS Patient Form SH` | `...CH` | `...MD` | `...NM` |
| **Type** | `FORM` | Same | Same | Same |
| **Application** | `Application Object Library` | Same | Same | Same |
| **Form** | `HMS_PATIENT_FORM` | Same | Same | Same |
| **Description** | `Opens Patient Information Form for SH` | ...CH | ...MD | ...NM |

#### Function 2 — Employee Form

| Field | SH | CH | MD | NM |
|-------|----|----|----|----|
| **Function Name** | `HMS_EMP_FORM_SH` | `HMS_EMP_FORM_CH` | `HMS_EMP_FORM_MD` | `HMS_EMP_FORM_NM` |
| **User Function Name** | `HMS Employee Form SH` | Same pattern | Same | Same |
| **Type** | `FORM` | Same | Same | Same |
| **Form** | `HMS_EMPLOYEE_FORM` | Same | Same | Same |

#### Function 3 — Employee Report (links to Concurrent Program)

| Field | SH | CH | MD | NM |
|-------|----|----|----|----|
| **Function Name** | `HMS_EMP_RPT_SH` | `HMS_EMP_RPT_CH` | `HMS_EMP_RPT_MD` | `HMS_EMP_RPT_NM` |
| **User Function Name** | `HMS Emp Dept Report SH` | Same pattern | Same | Same |
| **Type** | `SUBFUNCTION` | Same | Same | Same |

Click **Save** after each function.

---

### Step 2.4 — Create Menu

**Navigation:** `Application Developer` → **Application → Menu → Define**

| Field | SH | CH | MD | NM |
|-------|----|----|----|----|
| **Menu** | `HMS_MENU_SH` | `HMS_MENU_CH` | `HMS_MENU_MD` | `HMS_MENU_NM` |
| **User Menu Name** | `HMS Menu SH` | `HMS Menu CH` | `HMS Menu MD` | `HMS Menu NM` |
| **Description** | `Navigation menu for HMS - Shaswin` | ...Chandana | ...Manideep | ...Namitha |

**In the Menu Entries table at the bottom, add 3 rows:**

| Seq | Navigator Prompt | Function | Submenu | Description |
|-----|-----------------|----------|---------|-------------|
| 10 | `Patient Information` | `HMS_PAT_FORM_<SUFFIX>` | | Opens patient form |
| 20 | `Employee Information` | `HMS_EMP_FORM_<SUFFIX>` | | Opens employee form |
| 30 | `Run Employee Report` | `HMS_EMP_RPT_<SUFFIX>` | | Runs employee dept report |

Click **Save**.

---

### Step 2.5 — Create Concurrent Executable

**Navigation:** `System Administrator` → **Concurrent → Program → Executable → Define**

| Field | SH | CH | MD | NM |
|-------|----|----|----|----|
| **Executable** | `HMS_EMP_EXEC_SH` | `HMS_EMP_EXEC_CH` | `HMS_EMP_EXEC_MD` | `HMS_EMP_EXEC_NM` |
| **Short Name** | `HMS_EMP_EXEC_SH` | Same pattern | Same | Same |
| **Application** | `Application Object Library` | Same | Same | Same |
| **Execution Method** | `Oracle Reports` | Same | Same | Same |
| **Execution File Name** | `HMS_EMP_DEPT_REPORT_SH` | `...CH` | `...MD` | `...NM` |
| **Description** | `Executable for HMS Employee Dept Report - SH` | | | |

Click **Save**.

---

### Step 2.6 — Create Concurrent Program

**Navigation:** `System Administrator` → **Concurrent → Program → Define**

| Field | SH | CH | MD | NM |
|-------|----|----|----|----|
| **Program** | `HMS Emp Dept Report SH` | `...CH` | `...MD` | `...NM` |
| **Short Name** | `HMS_EMP_PROG_SH` | `HMS_EMP_PROG_CH` | `HMS_EMP_PROG_MD` | `HMS_EMP_PROG_NM` |
| **Application** | `Application Object Library` | Same | Same | Same |
| **Executable Name** | `HMS_EMP_EXEC_SH` | `...CH` | `...MD` | `...NM` |
| **Execution Method** | `Oracle Reports` | Same | Same | Same |
| **Output Format** | `PDF` | Same | Same | Same |
| **Enable Trace** | Unchecked | Same | Same | Same |
| **Description** | `HMS Employee Department Report for SH` | | | |

**Add Parameters (click Parameters button):**

**Parameter 1 — Employee:**

| Field | Value |
|-------|-------|
| **Sequence** | `10` |
| **Parameter** | `P_EMPLOYEE` |
| **Description** | `Employee ID or Name` |
| **Value Set** | *(create or use existing employee LOV value set)* |
| **Display Size** | `30` |
| **Display** | Checked |
| **Required** | Checked |
| **Token** | `P_EMPLOYEE` |

**Parameter 2 — Department:**

| Field | Value |
|-------|-------|
| **Sequence** | `20` |
| **Parameter** | `P_DEPARTMENT` |
| **Description** | `Department ID or Name` |
| **Value Set** | *(create or use existing dept LOV value set)* |
| **Display Size** | `30` |
| **Required** | Checked |
| **Token** | `P_DEPARTMENT` |

Click **Save**.

---

### Step 2.7 — Create Request Group

**Navigation:** `System Administrator` → **Security → Responsibility → Request Group**

| Field | SH | CH | MD | NM |
|-------|----|----|----|----|
| **Group Name** | `HMS_REQ_GROUP_SH` | `HMS_REQ_GROUP_CH` | `HMS_REQ_GROUP_MD` | `HMS_REQ_GROUP_NM` |
| **Application** | `Application Object Library` | Same | Same | Same |
| **Description** | `Request group for HMS - Shaswin` | ...Chandana | ...Manideep | ...Namitha |

**In the Requests table below, add 1 row:**

| Type | Name |
|------|------|
| `Program` | `HMS_EMP_PROG_SH` *(your suffix's program)* |

Click **Save**.

---

### Step 2.8 — Link Menu & Request Group to Responsibility

**Navigation:** `System Administrator` → **Security → Responsibility → Define**
*(Search for your responsibility created in Step 2.2)*

1. Find your responsibility: e.g., `HMS Responsibility SH`
2. Fill in the two remaining fields:
   - **Menu** → `HMS_MENU_SH` *(choose your suffix's menu)*
   - **Request Group** → `HMS_REQ_GROUP_SH` *(choose your suffix's request group)*
3. Click **Save**

---

### Step 2.9 — Assign Responsibility to User

**Navigation:** `System Administrator` → **Security → User → Define**

1. Search for your user (e.g., `HMS_USER_SH`)
2. Scroll to the **Responsibilities** section at the bottom
3. Add a new row:

| Field | Value |
|-------|-------|
| **Responsibility** | `HMS Responsibility SH` *(your suffix)* |
| **Application** | `Application Object Library` |
| **Effective Date** | Today (auto-filled) |
| **End Date** | *(leave blank)* |

4. Click **Save**

---

## 📋 PART 3 — Verification Checklist

After completing all steps above, verify as follows:

### SQL Developer Verification
```sql
-- 1. Confirm all 13 tables exist for your suffix
SELECT table_name FROM user_tables WHERE table_name LIKE 'HMS_%\_<YOUR_SUFFIX>' ESCAPE '\' ORDER BY 1;

-- 2. Confirm row counts match CSV data (replace <SUFFIX> with your suffix)
SELECT 'HOSPITAL_MASTER' tbl, COUNT(*) FROM HMS_HOSPITAL_MASTER_<SUFFIX> UNION ALL
SELECT 'HOSPITAL_BRANCH',      COUNT(*) FROM HMS_HOSPITAL_BRANCH_<SUFFIX> UNION ALL
SELECT 'DEPARTMENT',           COUNT(*) FROM HMS_DEPARTMENT_<SUFFIX>       UNION ALL
SELECT 'EMPLOYEES',            COUNT(*) FROM HMS_EMPLOYEES_<SUFFIX>        UNION ALL
SELECT 'PATIENT',              COUNT(*) FROM HMS_PATIENT_<SUFFIX>;

-- 3. Confirm packages are valid
SELECT object_name, status FROM user_objects
WHERE object_type IN ('PACKAGE','PACKAGE BODY')
  AND object_name LIKE 'HMS_PKG_%';
-- Expected STATUS: VALID for all 4
```

### Oracle EBS Login Verification
1. Log out of System Administrator
2. Log in as your created user: e.g., `HMS_USER_SH` with the password you set
3. You should see **`HMS Responsibility SH`** in the responsibility list
4. Click it — the navigation menu should show:
   - Patient Information
   - Employee Information
   - Run Employee Report
5. Click **Patient Information** → Oracle Form should open
6. Click **Employee Information** → Oracle Form should open
7. Click **Run Employee Report** → Concurrent Request form opens
   - Fill P_EMPLOYEE and P_DEPARTMENT parameters
   - Click Submit
   - Navigate to **View → Requests** to see the request status → should complete as **Normal**

---

## 📋 PART 4 — File Naming Quick Reference

| Deliverable | SH (Shaswin) | CH (Chandana) | MD (Manideep) | NM (Namitha) |
|-------------|--------------|---------------|----------------|--------------|
| PL/SQL Package | `HMS_PKG_SH.sql` | `HMS_PKG_CH.sql` | `HMS_PKG_MD.sql` | `HMS_PKG_NM.sql` |
| Patient Form | `HMS_PATIENT_FORM_SH.fmb` | `...CH.fmb` | `...MD.fmb` | `...NM.fmb` |
| Employee Form | `HMS_EMPLOYEE_FORM_SH.fmb` | `...CH.fmb` | `...MD.fmb` | `...NM.fmb` |
| Report | `HMS_EMP_DEPT_REPORT_SH.rdf` | `...CH.rdf` | `...MD.rdf` | `...NM.rdf` |
| EBS User | `HMS_USER_SH` | `HMS_USER_CH` | `HMS_USER_MD` | `HMS_USER_NM` |
| Responsibility | `HMS Responsibility SH` | `...CH` | `...MD` | `...NM` |
| Menu | `HMS_MENU_SH` | `HMS_MENU_CH` | `HMS_MENU_MD` | `HMS_MENU_NM` |
| Request Group | `HMS_REQ_GROUP_SH` | `HMS_REQ_GROUP_CH` | `HMS_REQ_GROUP_MD` | `HMS_REQ_GROUP_NM` |
| Executable | `HMS_EMP_EXEC_SH` | `HMS_EMP_EXEC_CH` | `HMS_EMP_EXEC_MD` | `HMS_EMP_EXEC_NM` |
| Program | `HMS_EMP_PROG_SH` | `HMS_EMP_PROG_CH` | `HMS_EMP_PROG_MD` | `HMS_EMP_PROG_NM` |
