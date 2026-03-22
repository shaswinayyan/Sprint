# Oracle Forms Builder (`.fmb`) Guide

This document provides exact, manual, from-scratch instructions for building your physical Oracle Forms (`.fmb`), without using any automated wizards. This method demonstrates an advanced, deep-level comprehension of Oracle EBS UI mapping for your grading.

---

## Part 1: Building the Oracle Forms Manually From Scratch
Your requirements state: *"Create Two Oracle Forms to Display information for patients and Display information for employees... The form should display results based on search criteria."*

We will map the User Interface objects directly to your database tables manually using the Object Navigator. This automatically grants native **Query-By-Example (QBE)** technology, satisfying the search requirement instantly!

### Step 1.1: Create the Patient Form (Without Wizards)
1. Open **Oracle Forms Builder 10g/11g**.
2. Go to **File → Connect** and log into your Database (Username: `APPS`, Password: `<your_password>`, Database: `<your_database>`).

#### Step A: Build the Manual Data Block
1. In the Object Navigator, right-click **Data Blocks** and click **Create** (the `+` sign).
2. Select **Build a new data block manually** → click **OK**.
3. Right-click your new data block and open the **Property Palette**. Configure exactly:
   * **Name**: `HMS_PATIENT_BLK`
   * **Database Data Block**: `Yes`
   * **Query Data Source Type**: `Table`
   * **Query Data Source Name**: `HMS_PATIENT_<SUFFIX>` *(Your specific table name)*

#### Step B: Build the DB Items (Columns)
1. Expand your new `HMS_PATIENT_BLK` in the Object Navigator. 
2. Select **Items**, and click **Create** (`+`) to generate a new manual item.
3. Open the **Property Palette** for this Item and map it exactly to your first DB column:
   * **Name**: `PATIENT_FIRST_NAME`
   * **Item Type**: `Text Item`
   * **Database Item**: `Yes`
   * **Column Name**: `PATIENT_FIRST_NAME`
   * **Data Type**: `Char`
   * **Maximum Length**: `100` *(matches your DDL)*
   * **Prompt**: `First Name:`
4. **Repeat** Step B for every column inside your `HMS_PATIENT` table (Last Name, Phone Number, Email, City) mapping the Item Name and Column Name identically to the database.

#### Step C: Build the Canvas and Layout
1. In the Object Navigator, go down to **Canvases**, right-click and click **Create**.
2. Open its **Property Palette**:
   * **Name**: `HMS_PATIENT_CANVAS`
   * **Canvas Type**: `Content`
3. Right-click the Canvas and select **Layout Editor**.
4. With the Layout Editor open on your screen, click back to your Object Navigator, select all the physical **Items** you manually created in Step B, and literally **drag and drop** them onto your blank Canvas!
5. Manually resize, align, and organize the text item boxes geometrically on the screen to make it visually presentable.

#### Step D: Compile the Form
1. Finally, go to the **Windows** node, ensure `WINDOW1` has its `Primary Canvas` property set to `HMS_PATIENT_CANVAS`.
2. **Save your file** as `HMS_PAT_FORM_<SUFFIX>.fmb`.
3. **Compile** by pressing `Ctrl + T` (This seamlessly maps everything and generates the executable `.fmx` file).

### Step 1.2: Create the Employee Form (From Scratch)
Repeat the exact same manual Object Navigator steps above, but map the Data Block to `HMS_EMPLOYEES_<SUFFIX>`, and physically create the DB Items to match your exact Employee architectural fields (First Name, Last Name, Employee Type, etc). Save it manually as `HMS_EMP_FORM_<SUFFIX>.fmb`.

> **How to Demo the Search Functionality to your Mentor:**
> Because you properly mapped the `Database Data Block = Yes` parameter completely from scratch, Oracle Forms inherently activates its built-in search engine! During your presentation:
> 1. Press `F11` on your keyboard (the screen will turn blue/blank, formally entering "Search Mode").
> 2. Type an employee's first name into the 'First Name' field (e.g., `Rohit`).
> 3. Press `Ctrl + F11` (Execute Query).
> 4. *Result:* The form instantly triggers a native background SELECT query, fetching all doctors/staff matching that exact string parameter, perfectly fulfilling the *"fetch results by search criteria"* requirement without writing any complex PL/SQL search triggers!
