# Oracle EBS GUI — End-to-End Setup Guide
## Hospital Management System (HMS)
> **Oracle EBS 12.2.8** | **Application:** Application Object Library (AOL)
> **Schema:** APPS | **Team:** SH (Shaswin), CH (Chandana), MD (Manideep), NM (Namitha)

---

## 📋 PART 1 — SQL Developer: DDL, PL/SQL & Bulk Load

### Step 1.1 — Run DDL (Create Tables & Staging)
1. Open SQL Developer, connect to `APPS` using your credentials.
2. Go to **File → Open** → select `01_DDL\<YOUR_SUFFIX>\HMS_CREATE_TABLES_<YOUR_SUFFIX>.sql` and press **F5** (Run Script).
3. Next, open `01_DDL\<YOUR_SUFFIX>\HMS_CREATE_STAGING_TABLES_<YOUR_SUFFIX>.sql` and press **F5**.
4. Confirm 14 tables (7 base + 7 staging) have been successfully created without errors.

### Step 1.2 — Run Bulk Upload (SQL*Loader Automations)
> **Data must be loaded before Concurrent Programs can work smoothly!**
1. Open **Command Prompt** (Windows CMD).
2. Navigate to your data folder: `cd G:\IITM\Sprint\HMS_Project\02_Data\<YOUR_SUFFIX>`
3. Run your automated GUI script:
   ```cmd
   load_all_data_<YOUR_SUFFIX>.bat
   ```
4. This will instantly push all 7 Control Files securely to the Oracle backend. Review the local `.log` files to ensure zero rejected rows.

### Step 1.3 — Compile PL/SQL Package (EBS-Compatible)
1. In SQL Developer, open `03_PLSQL\<YOUR_SUFFIX>\HMS_PKG_<YOUR_SUFFIX>.sql`.
2. Ensure your `C_USER_ID` at the top matches your FND_USER account.
3. Press **F5** to compile. It is 100% compliant with the `errbuf` and `retcode` Concurrent Program native signatures.

---

## 📋 PART 2 — Oracle EBS GUI: Linear AOL Setup
> **Critical:** Perform these steps exactly in this order. Log into Oracle EBS as `System Administrator` or `Application Developer` where noted.

---

### Step 2.1 — Create Value Sets (LOVs)
**Navigation:** `Application Developer` → **Application → Validation → Set**
> We need to create Value Sets so your Oracle Concurrent Programs can use Dropdowns (Lists of Values) instead of typing IDs.

**Value Set 1: Hospital Branch LOV**
* **Value Set Name:** `HMS_HOSPITAL_LOV_<SUFFIX>`
* **Description:** LOV for Hospital Branches
* **List Type:** `List of Values`
* **Security Type:** `No Security`
* **Format Type:** `Char` / **Maximum Size:** `100` *(Justification: This exactly matches the `VARCHAR2(100)` constraint defined for `BRANCH_NAME` in the Database DDL to prevent truncation)*
* **Validation Type:** `Table`
* Click **Edit Information**:
  * **Table Name:** `HMS_HOSPITAL_BRANCH_<SUFFIX>`
  * **Value Column:** `BRANCH_NAME` (Size: `100` - matches DDL)
  * **ID Column:** `HOSPITAL_ID` (Size: `10` - matches DDL `NUMBER(10)`)
* -> **Save**

**Value Set 2: Department LOV**
* **Value Set Name:** `HMS_DEPT_LOV_<SUFFIX>`
* **Description:** LOV for Hospital Departments
* **List Type:** `List of Values` / **Format Type:** `Char`
* **Maximum Size:** `100` *(Justification: Matches the `VARCHAR2(100)` maximum length configured for `DEPARTMENT_NAME` in your DDL script)*
* **Validation Type:** `Table`
* Click **Edit Information**:
  * **Table Name:** `HMS_DEPARTMENT_<SUFFIX>`
  * **Value Column:** `DEPARTMENT_NAME` (Size: `100` - matches DDL)
  * **ID Column:** `DEPARTMENT_ID` (Size: `10` - matches DDL `NUMBER(10)`)
* -> **Save**

---

### Step 2.2 — Define Concurrent Executables
**Navigation:** `System Administrator` → **Concurrent → Program → Executable → Define**
> We will register 5 Executables (4 PL/SQL Procedures + 1 Oracle Report).

| Executable Name | Short Name | Execution Method | Execution File Name | Description |
|-----------------|------------|------------------|---------------------|-------------|
| `HMS_EMP_EXEC_<SUFFIX>` | `HMS_EMP_EXEC_<SUFFIX>` | **Oracle Reports** | `HMS_EMP_DEPT_REPORT_<SUFFIX>` | `Executable for HMS Employee Dept Report` |
| `HMS_LOAD_EXEC_<SUFFIX>`| `HMS_LOAD_EXEC_<SUFFIX>`| **PL/SQL Stored Procedure** | `HMS_PKG_<SUFFIX>.LOAD_STAGING_TO_BASE` | `Executable for Loading Staging Data to Base` |
| `HMS_SUMM_EXEC_<SUFFIX>`| `HMS_SUMM_EXEC_<SUFFIX>`| **PL/SQL Stored Procedure** | `HMS_PKG_<SUFFIX>.GET_BRANCH_SUMMARY` | `Executable for Fetching Branch Summary` |
| `HMS_LIST_EXEC_<SUFFIX>`| `HMS_LIST_EXEC_<SUFFIX>`| **PL/SQL Stored Procedure** | `HMS_PKG_<SUFFIX>.GET_EMPLOYEES_LIST` | `Executable for Fetching Employees List` |
| `HMS_DPAT_EXEC_<SUFFIX>`| `HMS_DPAT_EXEC_<SUFFIX>`| **PL/SQL Stored Procedure** | `HMS_PKG_<SUFFIX>.GET_DEPT_PATIENTS` | `Executable for Fetching Department Patients` |

*Note: Application is `Application Object Library` for all.* -> **Save after each.**

---

### Step 2.3 — Define Concurrent Programs
**Navigation:** `System Administrator` → **Concurrent → Program → Define**

> **Application Mandate:** For *all 5* programs below, set **Application** to `Application Object Library`.
> **Default Type Justification:** You will intentionally leave **Default Type** blank for all parameters. The justification is that we want to force the user to explicitly select a valid branch/department from our strict LOVs at runtime to guarantee absolute accuracy, rather than letting the system silently default to a static ID and generating wrong data.

**1. Employee Department Report (PDF)**
* **Program:** `HMS Emp Dept Report <SUFFIX>` / **Short Name:** `HMS_EMP_PROG_<SUFFIX>`
* **Description:** `HMS Employee Department Report for <SUFFIX>`
* **Executable Name:** `HMS_EMP_EXEC_<SUFFIX>` (Format: PDF)
* **Style:** `A4` *(Mandatory for standard Oracle PDF report layouts)*
* **Parameters:**
  * Seq `10` | Parameter: `P_DEPARTMENT` | Description: `Select Department` | Value Set: `HMS_DEPT_LOV_<SUFFIX>` | Token: `P_DEPARTMENT` | Required: Yes

**2. Load Staging to Base (Data Loading)**
* **Program:** `HMS Load Staging Data <SUFFIX>` / **Short Name:** `HMS_LOAD_PROG_<SUFFIX>`
* **Description:** `Concurrent Program to bulk load validated staging data to base tables`
* **Executable Name:** `HMS_LOAD_EXEC_<SUFFIX>`

**3. Get Branch Summary**
* **Program:** `HMS Branch Summary <SUFFIX>` / **Short Name:** `HMS_SUMM_PROG_<SUFFIX>`
* **Description:** `Concurrent Program to analyze hospital branch totals`
* **Executable Name:** `HMS_SUMM_EXEC_<SUFFIX>` (Format: Text)
* **Parameters:**
  * Seq `10` | Parameter: `P_HOSPITAL_ID` | Description: `Select Hospital Branch` | Value Set: `HMS_HOSPITAL_LOV_<SUFFIX>` | Token: `P_HOSPITAL_ID`

**4. Get Employees List**
* **Program:** `HMS Employees List <SUFFIX>` / **Short Name:** `HMS_LIST_PROG_<SUFFIX>`
* **Description:** `Concurrent Program to retrieve structured employee lists`
* **Executable Name:** `HMS_LIST_EXEC_<SUFFIX>` (Format: Text)
* **Parameters:**
  * Seq `10` | Parameter: `P_HOSPITAL_ID` | Description: `Select Hospital Branch` | Value Set: `HMS_HOSPITAL_LOV_<SUFFIX>` | Token: `P_HOSPITAL_ID`

**5. Get Dept Patients**
* **Program:** `HMS Dept Patients <SUFFIX>` / **Short Name:** `HMS_DPAT_PROG_<SUFFIX>`
* **Description:** `Concurrent Program to track admitted patients per department`
* **Executable Name:** `HMS_DPAT_EXEC_<SUFFIX>` (Format: Text)
* **Parameters:**
  * Seq `10` | Parameter: `P_HOSPITAL_ID` | Description: `Select Hospital Branch` | Value Set: `HMS_HOSPITAL_LOV_<SUFFIX>` | Token: `P_HOSPITAL_ID`
  * Seq `20` | Parameter: `P_DEPARTMENT_ID` | Description: `Select Department` | Value Set: `HMS_DEPT_LOV_<SUFFIX>` | Token: `P_DEPARTMENT_ID`

-> **Save all 5 programs.**

---

### Step 2.4 — Create Request Group
**Navigation:** `System Administrator` → **Security → Responsibility → Request Group**
* **Group Name:** `HMS_REQ_GROUP_<SUFFIX>`
* **Application:** `Application Object Library`
* **Code:** *(Leave blank as it is not mandated)*
* **Description:** `Request group containing all HMS analytical reports and staging data loaders for <SUFFIX>`
* **Requests Table (Add these 5):**
  * Type: `Program` | Name: `HMS Emp Dept Report <SUFFIX>`
  * Type: `Program` | Name: `HMS Load Staging Data <SUFFIX>`
  * Type: `Program` | Name: `HMS Branch Summary <SUFFIX>`
  * Type: `Program` | Name: `HMS Employees List <SUFFIX>`
  * Type: `Program` | Name: `HMS Dept Patients <SUFFIX>`
* -> **Save**

---

### Step 2.5 — Create Form Functions
**Navigation:** `Application Developer` → **Application → Function → Define**

> **How to fix "No Pages Found":** You previously tried leaving the **Form** field blank because you couldn't upload Custom Forms. However, if all functions in a menu have blank Form fields, Oracle evaluates them as "dead links" and completely hides the menu tree on the Web Homepage (giving you the `No pages found` error). 
> **The Fix:** We will use a standard Oracle native form as a "dummy" placeholder. Click the **List of Values (...)** button inside the Form field and literally select the **very first Form** that appears in the list (for example, `FNDSCSGN` or `FNDPOMPO`). Because the form exists on the backend server, Oracle will validate it successfully and actively display your entire menu tree for your presentation!

| Function Name | User Function Name | Type | Form *(Dummy)* |
|---------------|--------------------|------|------|
| `HMS_PAT_FORM_<SUFFIX>` | `HMS Patient Form <SUFFIX>` | `FORM` | *(Pick ANY Form from LOV)* |
| `HMS_EMP_FORM_<SUFFIX>` | `HMS Employee Form <SUFFIX>` | `FORM` | *(Pick ANY Form from LOV)* |
| `HMS_EMP_RPT_<SUFFIX>` | `HMS Run Emp Report <SUFFIX>` | `FORM` | *(Pick ANY Form from LOV)* |

*Note: Application is `Application Object Library`. Ensure Type is `FORM` for all 3.* -> **Save.**

---

### Step 2.6 — Create Menus & Sub-Menus
**Navigation:** `Application Developer` → **Application → Menu → Define**
> **Mandate:** Creating a hierarchical sub-menu structure for cleanliness.

**1. Create the Sub-Menu First**
* **Menu:** `HMS_FORMS_SUBMENU_<SUFFIX>`
* **User Menu Name:** `HMS Forms SubMenu <SUFFIX>`
* **Menu Type:** `Standard` *(Definition: Instructs EBS to render this menu as a standard expandable Navigator tree link, rather than a hidden security or toolbar menu)*
* **Description:** `Sub-Menu containing forms for data entry and execution`
* **Entries (leave Submenu blank here since we are assigning Functions):**
  * Seq `10` | Prompt `Manage Patients` | Function `HMS_PAT_FORM_<SUFFIX>` | Description `Opens the Patient Management Form`
  * Seq `20` | Prompt `Manage Employees` | Function `HMS_EMP_FORM_<SUFFIX>` | Description `Opens the Employee Management Form`
  * Seq `30` | Prompt `Run Employee Report` | Function `HMS_EMP_RPT_<SUFFIX>` | Description `Submits the Employee Department Report`
* -> **Save**

**2. Create the Main Menu & Connect the Sub-Menu**
> **How Routing Works:** You will create the Main Menu and physically attach your Sub-Menu to it by filling in the `Submenu` field on Seq `10`, intentionally leaving the `Function` field blank!

* **Menu:** `HMS_MAIN_MENU_<SUFFIX>`
* **User Menu Name:** `HMS Main Menu <SUFFIX>`
* **Menu Type:** `Standard` *(Definition: Renders the root menu natively in the Navigator pane)*
* **Description:** `Root Navigation Menu pointing to all custom HMS Sub-Menus`
* **Entries (leave Function blank and assign the Sub-Menu you just created):**
  * Seq `10` | Prompt `Hospital Data Entry Forms` | Submenu `HMS_FORMS_SUBMENU_<SUFFIX>` | Description `Navigates into the Data Entry and Execution Sub-Menu`
* -> **Save**
*(Note: Concurrent Programs are accessed via the Request Group automatically, not the Sub-Menu).*

---

### Step 2.7 — Create Responsibility & Link Everything
**Navigation:** `System Administrator` → **Security → Responsibility → Define**

* **Responsibility Name:** `HMS Responsibility <SUFFIX>`
* **Application:** `Application Object Library`
* **Responsibility Key:** `HMS_RESP_<SUFFIX>`
* **Description:** `Primary Responsibility for HMS Data Entry, Analysis, and Reporting operations for <SUFFIX>`
* **Data Group:** `Standard` / `Application Object Library`
  > *(Definition: The 'Standard' Data Group natively maps the AOL Application directly to the core `APPS` database schema, granting your Responsibility full read/write access to test the tables you created).*
* **Menu:** `HMS_MAIN_MENU_<SUFFIX>`
* **Request Group:** `HMS_REQ_GROUP_<SUFFIX>`
* -> **Save**

> **How PL/SQL Procedures connect to your Responsibility:**
> 1. Your custom **PL/SQL Package** is registered as a **Concurrent Executable**.
> 2. The Executable is bound to a **Concurrent Program**.
> 3. The Program is added to the **Request Group** (`HMS_REQ_GROUP`).
> 4. The **Request Group** is explicitly linked right here inside the **Responsibility**.
> 5. The **Responsibility** is assigned to your **User**.
> *Result: When you log in and select this Responsibility, you organically inherit full security clearance to execute your PL/SQL packages natively from the "Submit a New Request" window!*

---

### Step 2.8 — Create User & Assign
**Navigation:** `System Administrator` → **Security → User → Define**

* **User Name:** `HMS_USER_<SUFFIX>`
* **Password:** *(any password)*
* **Responsibilities Tab (bottom):** Add `HMS Responsibility <SUFFIX>`
* -> **Save**

---

## 📋 PART 3 — Running the System (Execution Phase)

**1. Log into your new user** (`HMS_USER_<SUFFIX>`).
**2. Select `HMS Responsibility <SUFFIX>`** from the Navigator.
**3. Test the Sub-Menu & Forms:**
   * Expand `Hospital Data Entry Forms` → you will see your mandate Sub-Menu options. Click `Manage Patients` to test the UI.
**4. Test Data Loading (The Concurrent Request):**
   * Go to **View → Requests → Submit a New Request** (Single Request)
   * Select `HMS Load Staging Data <SUFFIX>`
   * Submit! Oracle will natively fetch the raw data from staging and load it to the base schema. Since you used `FND_FILE.OUTPUT`, click **"View Output"** on the completed request to read your beautiful logs.
**5. Test Your 3 Analytical Procedures:**
   * Go to **Submit a New Request**
   * Select `HMS Branch Summary <SUFFIX>`. A perfect LOV Dropdown will appear asking for the Hospital ID! Select a hospital and Submit.
   * View the Output text file directly in your browser. All your PL/SQL output prints perfectly inside Oracle!
