# Oracle Forms Builder — Complete Development Guide

> This guide provides **two complete, independent methods** for building both HMS Oracle Forms.
> - **Method A (Wizard):** Fast, automated, recommended for presentation.
> - **Method B (Manual):** Manual Object Navigator method, step by step without shortcuts.
> Both methods produce identical, functionally correct `.fmb` files.

---

## FORM 1: Patient Information Form (`HMS_PAT_FORM_<SUFFIX>.fmb`)

---

### METHOD A: Using the Data Block and Layout Wizards

#### A1. Connect to the Database
1. Open **Oracle Forms Builder**.
2. Go to **File → Connect**.
3. Enter:
   - **Username:** `APPS`
   - **Password:** `<your EBS password>`
   - **Database:** `<your database SID/service name>`
4. Click **Connect**.

#### A2. Launch the Data Block Wizard
1. In the Object Navigator on the left, find and right-click **Data Blocks**.
2. Click **Create** (the `+` plus icon).
3. A dialog appears. Select **Use the Data Block Wizard** → click **OK**.
4. On the Welcome screen → click **Next**.
5. Select **Table or View** → click **Next**.
6. In the "Table or View" field, click **Browse**. A database table picker appears.
7. Type `HMS_PATIENT_<SUFFIX>` in the search box → press Enter → select it.
8. Under **Available Columns**, click the `>>` (double arrow) button to move **all columns** into the **Database Items** list.
9. Click **Next**.
10. Leave block name as default or type `HMS_PATIENT_BLK` → click **Next**.
11. Select **Create the data block, then call the Layout Wizard** → click **Finish**.

#### A3. Configure the Layout Wizard
1. The Layout Wizard opens automatically.
2. On the first screen, select **New Canvas** → click **Next**.
3. Move all fields from **Available Items** into **Displayed Items** using the `>>` button → click **Next**.
4. Rename the field prompts for a clean UI:
   - `PATIENT_ID` → `Patient ID:`
   - `HOSPITAL_ID` → `Hospital Branch ID:`
   - `DEPARTMENT_ID` → `Department ID:`
   - `PATIENT_FIRST_NAME` → `First Name:`
   - `PATIENT_LAST_NAME` → `Last Name:`
   - `PATIENT_PHONE_NUMBER` → `Phone Number:`
   - `EMAIL_ID` → `Email Address:`
   - `ADDRESS_STREET` → `Street:`
   - `ADDRESS_CITY` → `City:`
   - `ADDRESS_STATE` → `State:`
   - `ADDRESS_POSTAL_CODE` → `Postal Code:`
5. Click **Next**.
6. Layout Style: Select **Tabular** → click **Next**.
7. Frame Title: type `Patient Information Directory`.
8. Records Displayed: `10`. Check **Display Scrollbar** → click **Next** → click **Finish**.
9. Go to **File → Save As** → name it `HMS_PAT_FORM_<SUFFIX>.fmb`.
10. Press `Ctrl + T` to compile the form into an `.fmx` executable.

---

### METHOD B: Building Manually (No Wizards)

#### B1. Connect to the Database
Identical to Method A Step A1 above.

#### B2. Create the Data Block Manually
1. In the Object Navigator, right-click **Data Blocks** and click **Create**.
2. On the dialog, select **Build a new data block manually** → click **OK**.
3. A new block called `BLOCK1` appears. Right-click it → select **Property Palette**.
4. Inside the Property Palette, set these exact values:

   | Property | Value |
   |---|---|
   | Name | `HMS_PATIENT_BLK` |
   | Database Data Block | `Yes` |
   | Query Data Source Type | `Table` |
   | Query Data Source Name | `HMS_PATIENT_<SUFFIX>` |
   | Number of Records Displayed | `10` |
   | Records Buffered | `15` |

5. Close the Property Palette.

#### B3. Create Every Item Manually
Expand `HMS_PATIENT_BLK` in the Object Navigator, right-click **Items** and click **Create** for each of the columns below. Open the **Property Palette** for each Item and set the values exactly as specified.

---

**Item 1 — Patient ID**
| Property | Value |
|---|---|
| Name | `PATIENT_ID` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `PATIENT_ID` |
| Data Type | `Number` |
| Maximum Length | `10` |
| Required | `Yes` |
| Prompt | `Patient ID:` |
| Primary Key | `Yes` |
| Query Allowed | `Yes` |
| Update Allowed | `No` |

---

**Item 2 — Hospital ID**
| Property | Value |
|---|---|
| Name | `HOSPITAL_ID` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `HOSPITAL_ID` |
| Data Type | `Number` |
| Maximum Length | `10` |
| Required | `Yes` |
| Prompt | `Hospital Branch ID:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 3 — Department ID**
| Property | Value |
|---|---|
| Name | `DEPARTMENT_ID` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `DEPARTMENT_ID` |
| Data Type | `Number` |
| Maximum Length | `10` |
| Required | `No` |
| Prompt | `Department ID:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 4 — Patient First Name**
| Property | Value |
|---|---|
| Name | `PATIENT_FIRST_NAME` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `PATIENT_FIRST_NAME` |
| Data Type | `Char` |
| Maximum Length | `50` |
| Required | `Yes` |
| Prompt | `First Name:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 5 — Patient Last Name**
| Property | Value |
|---|---|
| Name | `PATIENT_LAST_NAME` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `PATIENT_LAST_NAME` |
| Data Type | `Char` |
| Maximum Length | `50` |
| Required | `Yes` |
| Prompt | `Last Name:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 6 — Phone Number**
| Property | Value |
|---|---|
| Name | `PATIENT_PHONE_NUMBER` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `PATIENT_PHONE_NUMBER` |
| Data Type | `Char` |
| Maximum Length | `15` |
| Required | `Yes` |
| Prompt | `Phone Number:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 7 — Email ID**
| Property | Value |
|---|---|
| Name | `EMAIL_ID` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `EMAIL_ID` |
| Data Type | `Char` |
| Maximum Length | `100` |
| Required | `No` |
| Prompt | `Email Address:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 8 — Street Address**
| Property | Value |
|---|---|
| Name | `ADDRESS_STREET` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `ADDRESS_STREET` |
| Data Type | `Char` |
| Maximum Length | `100` |
| Required | `No` |
| Prompt | `Street:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 9 — Address City**
| Property | Value |
|---|---|
| Name | `ADDRESS_CITY` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `ADDRESS_CITY` |
| Data Type | `Char` |
| Maximum Length | `50` |
| Required | `No` |
| Prompt | `City:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 10 — Address State**
| Property | Value |
|---|---|
| Name | `ADDRESS_STATE` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `ADDRESS_STATE` |
| Data Type | `Char` |
| Maximum Length | `50` |
| Required | `No` |
| Prompt | `State:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 11 — Postal Code**
| Property | Value |
|---|---|
| Name | `ADDRESS_POSTAL_CODE` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `ADDRESS_POSTAL_CODE` |
| Data Type | `Char` |
| Maximum Length | `10` |
| Required | `No` |
| Prompt | `Postal Code:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

#### B4. Create the Canvas Manually
1. In the Object Navigator, right-click **Canvases** → click **Create**.
2. Right-click the new canvas → **Property Palette**:

   | Property | Value |
   |---|---|
   | Name | `HMS_PATIENT_CANVAS` |
   | Canvas Type | `Content` |

3. Right-click `HMS_PATIENT_CANVAS` → select **Layout Editor**. The blank design surface opens.
4. Go back to the Object Navigator. Select **all 11 Items** under `HMS_PATIENT_BLK` by holding `Ctrl` and clicking each.
5. Drag the selected Items onto the blank **Layout Editor** canvas. Oracle will draw them as editable text boxes.
6. Use the mouse to arrange and resize the boxes cleanly. You can also align them using **Layout → Align Objects**.

#### B5. Attach the Canvas to the Window
1. In the Object Navigator, expand **Windows** → right-click `WINDOW1` → open **Property Palette**.
2. Set **Primary Canvas** to `HMS_PATIENT_CANVAS`.

#### B6. Compile
1. **File → Save As** → name `HMS_PAT_FORM_<SUFFIX>.fmb`.
2. Press `Ctrl + T` to compile into `.fmx`.

---

## FORM 2: Employee Information Form (`HMS_EMP_FORM_<SUFFIX>.fmb`)

---

### METHOD A: Using the Wizard
Follow the exact same steps as Method A above for Form 1, but change:
- Table: `HMS_EMPLOYEES_<SUFFIX>`
- Block Name: `HMS_EMPLOYEE_BLK`
- Canvas title: `Employee Information Directory`
- Frame Title: `Employee Information Directory`
- Rename prompts as follows:
  - `EMPLOYEE_ID` → `Employee ID:`
  - `HOSPITAL_ID` → `Hospital Branch ID:`
  - `DEPARTMENT_ID` → `Department ID:`
  - `EMPLOYEE_FIRST_NAME` → `First Name:`
  - `EMPLOYEE_LAST_NAME` → `Last Name:`
  - `EMPLOYEE_TYPE` → `Employee Type:`
  - `EMAIL_ID` → `Email Address:`
- Save as `HMS_EMP_FORM_<SUFFIX>.fmb`.

---

### METHOD B: Building Manually

#### Data Block Property Palette
| Property | Value |
|---|---|
| Name | `HMS_EMPLOYEE_BLK` |
| Database Data Block | `Yes` |
| Query Data Source Type | `Table` |
| Query Data Source Name | `HMS_EMPLOYEES_<SUFFIX>` |
| Number of Records Displayed | `10` |

#### Items — Create Each Manually

---

**Item 1 — Employee ID**
| Property | Value |
|---|---|
| Name | `EMPLOYEE_ID` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `EMPLOYEE_ID` |
| Data Type | `Number` |
| Maximum Length | `10` |
| Required | `Yes` |
| Prompt | `Employee ID:` |
| Primary Key | `Yes` |
| Query Allowed | `Yes` |
| Update Allowed | `No` |

---

**Item 2 — Hospital ID**
| Property | Value |
|---|---|
| Name | `HOSPITAL_ID` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `HOSPITAL_ID` |
| Data Type | `Number` |
| Maximum Length | `10` |
| Required | `Yes` |
| Prompt | `Hospital Branch ID:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 3 — Department ID**
| Property | Value |
|---|---|
| Name | `DEPARTMENT_ID` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `DEPARTMENT_ID` |
| Data Type | `Number` |
| Maximum Length | `10` |
| Required | `No` |
| Prompt | `Department ID:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 4 — Employee First Name**
| Property | Value |
|---|---|
| Name | `EMPLOYEE_FIRST_NAME` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `EMPLOYEE_FIRST_NAME` |
| Data Type | `Char` |
| Maximum Length | `50` |
| Required | `Yes` |
| Prompt | `First Name:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 5 — Employee Last Name**
| Property | Value |
|---|---|
| Name | `EMPLOYEE_LAST_NAME` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `EMPLOYEE_LAST_NAME` |
| Data Type | `Char` |
| Maximum Length | `50` |
| Required | `Yes` |
| Prompt | `Last Name:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 6 — Employee Type**
| Property | Value |
|---|---|
| Name | `EMPLOYEE_TYPE` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `EMPLOYEE_TYPE` |
| Data Type | `Char` |
| Maximum Length | `20` |
| Required | `Yes` |
| Prompt | `Employee Type:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

**Item 7 — Email ID**
| Property | Value |
|---|---|
| Name | `EMAIL_ID` |
| Item Type | `Text Item` |
| Database Item | `Yes` |
| Column Name | `EMAIL_ID` |
| Data Type | `Char` |
| Maximum Length | `100` |
| Required | `No` |
| Prompt | `Email Address:` |
| Query Allowed | `Yes` |
| Update Allowed | `Yes` |

---

#### Canvas Property Palette
| Property | Value |
|---|---|
| Name | `HMS_EMPLOYEE_CANVAS` |
| Canvas Type | `Content` |

Drag all 7 Items onto the Layout Editor → arrange cleanly → set `WINDOW1` Primary Canvas to `HMS_EMPLOYEE_CANVAS`.

**File → Save As** → `HMS_EMP_FORM_<SUFFIX>.fmb` → Press `Ctrl + T` to compile.

---

## Demonstrating the Search Functionality During Your Presentation

> This applies to both forms built by either method!

1. Press **`F11`** — The form enters "Enter Query" mode (screen turns slightly dark).
2. Type a search value in any field. For example, type `Rohit` in the **First Name** field.
3. Press **`Ctrl + F11`** — Oracle executes the search against your live HMS database.
4. All matching patient/employee records are fetched and displayed dynamically.

This natively fulfills the requirement: *"The form should display results based on search criteria by Hospital name, Employee name or Patient name."*
