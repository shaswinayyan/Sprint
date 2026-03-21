# 🏥 Hospital Management System (HMS)

> **Platform:** Oracle EBS 12.2.8
> **Application:** Application Object Library (AOL)
> **Schema:** APPS

Welcome to the HMS Project! This README provides a comprehensive overview of how to use all the files generated in this repository to set up the system within your Oracle EBS environment.

## 👥 Team Constraints & Setup
This project is built for a team of 4 members. Every member must set up their own independent system within the same Oracle EBS environment without causing conflicts. 
- **Shaswin (SH)** - User ID: `1021027`
- **Chandana (CH)** - User ID: *(Update in PL/SQL package)*
- **Manideep (MD)** - User ID: *(Update in PL/SQL package)*
- **Namitha (NM)** - User ID: *(Update in PL/SQL package)*

We avoid creating new Oracle applications and rely strictly on Oracle EBS frontend forms, alongside SQL Developer for backend data setup.

---

## 📂 Repository Structure & How to Use It

The project is executed in a sequential pipeline. Follow the steps below **in order**.

### Step 1: DDL — Create the Database Objects
*Located in:* `01_DDL/`
1. Open SQL Developer and connect to the `APPS` schema.
2. Run `01_DDL/<SUFFIX>/HMS_CREATE_TABLES_<SUFFIX>.sql` to create your 7 isolated base tables.
3. Run `01_DDL/<SUFFIX>/HMS_CREATE_STAGING_TABLES_<SUFFIX>.sql` to create your 5 isolated staging tables. These include Oracle EBS standard **WHO Audit Columns** (`CREATED_BY`, `LAST_UPDATED_BY`, etc.).

### Step 2: Data Loading — Bulk Upload via SQL*Loader
*Located in:* `02_Data/`
The data loading process involves an intermediate staging table to validate data and stamp the audit trail before moving it to the base table.

1. Open a Command Prompt (Windows `cmd`).
2. Navigate to your specific member folder (e.g., `cd 02_Data/SH/`).
3. Run the SQL*Loader `.ctl` files to pump the provided CSV data into the **staging tables**. 
   - Execute the 4 commands exactly as documented in the `HMS_EBS_GUI_GUIDE.md` (Part 1.3).
   - This marks the data as `RECORD_STATUS = 'NEW'` in the staging environment.

### Step 3: PL/SQL — Validation & Business Logic
*Located in:* `03_PLSQL/`
Each member has an independent PL/SQL package (`HMS_PKG_<SUFFIX>.sql`).

1. **Important:** Open your member's package file in a text editor. Find the `C_USER_ID` constant and update it with your actual Oracle EBS `FND_USER.USER_ID` (Shaswin's is pre-filled as `1021027`).
2. Open the file in SQL Developer and compile the package (Spec & Body).
3. **Load Staging to Base:** Run the `LOAD_STAGING_TO_BASE()` procedure.
   ```sql
   EXEC HMS_PKG_SH.LOAD_STAGING_TO_BASE();
   ```
   *What this does:* It reads the `NEW` rows you just loaded into the staging tables, validates them, stamps them with your `C_USER_ID` in the WHO columns, and moves them to the base tables. It updates the staging `RECORD_STATUS` to `LOADED` (or `ERROR` if validation fails).
4. You can also test the other reporting procedures (e.g., `GET_BRANCH_SUMMARY(1)`).

### Step 4: Oracle EBS GUI Setup
*Located in:* `06_EBS_Setup/`
The `HMS_EBS_GUI_GUIDE.md` document is your Bible for this step. It contains the **exact** screen-by-screen navigation paths and field values you must type into Oracle EBS forms.

You will use Oracle Forms Builder and Oracle Reports Builder to create your frontend displays, and then use the `System Administrator` and `Application Developer` responsibilities in EBS to configure:
- Users & Responsibilities
- Functions & Menus
- Concurrent Programs & Executables
- Request Groups

### Step 5: Master Document Tracker
*Located in:* `brain/tasks.md` and `brain/implementation_plan.md` (System Use)
These internal artifacts track the project completion status and exact implementation plan.

---

## 🔄 The Data Flow Architecture

To ensure adherence to coding standards, data is not blindly loaded into the main tables. 

1. **CSV (Raw Data)** ➔ `SQL*Loader` ➔ **Staging Tables** (e.g., `HMS_PATIENT_STG`)
2. **Staging Tables** ➔ `LOAD_STAGING_TO_BASE procedure` ➔ **Base Tables** (e.g., `HMS_PATIENT`)

During step 2, the procedure performs data integrity checks (e.g., missing names, negative numbers, duplicate IDs) and injects the active Oracle EBS user's session variables into the record. All errors are safely logged into the `ERROR_LOG` column in the staging table without crashing the bulk load.
