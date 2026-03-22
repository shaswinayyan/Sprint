# Oracle Forms Builder (`.fmb`) Guide

## Part 1: Building the Oracle Forms (`.fmb`)
Your requirements state: *"Create Two Oracle Forms to Display information for patients and Display information for employees... The form should display results based on search criteria."*

We will use **Oracle Forms Builder** and rely on Oracle's native **Query-By-Example (QBE)** technology, which automatically satisfies exactly what the mentor wants without writing complex custom PL/SQL search triggers.

### Step 1.1: Create the Patient Form
1. Open **Oracle Forms Builder 10g/11g**.
2. Go to **File → Connect** and log into your Database (Username: `APPS`, Password: `<your_password>`, Database: `<your_database>`).
3. In the Object Navigator, select **Data Blocks** and click the **+ (Create)** button.
4. Choose **Data Block Wizard** → Next.
5. Select **Table or View** → Next.
6. Click **Browse** and select your table: `HMS_PATIENT_<SUFFIX>`.
7. Move **ALL** columns from "Available Columns" to "Database Items" using the `>>` button → Next.
8. Name the Data Block `HMS_PATIENT_BLK` → Next.
9. Choose **Create the data block, then call the Layout Wizard** → Finish.

**Inside the Layout Wizard:**
1. Canvas: **New Canvas** / Type: **Content** → Next.
2. Move all your patient fields into the **Displayed Items** list → Next.
3. Item Prompts: *Clean up the labels (e.g., change `PATIENT_FIRST_NAME` to `First Name`)* → Next.
4. Layout Style: Select **Tabular** (so you can view multiple patients dynamically) → Next.
5. Frame Title: type `Patient Information Directory`.
6. Records Displayed: Set to `10`. Check the box for **Display Scrollbar** → Next → Finish.
7. **Save your file** as `HMS_PAT_FORM_<SUFFIX>.fmb`.
8. **Compile** by pressing `Ctrl + T` (This builds the executable `.fmx` file).

### Step 1.2: Create the Employee Form
Repeat the exact same Data Block and Layout Wizard steps above, but select the `HMS_EMPLOYEES_<SUFFIX>` table. Save it as `HMS_EMP_FORM_<SUFFIX>.fmb`.

> **How to Demo the Search Functionality to your Mentor:**
> Oracle Forms has a built-in search engine! During your presentation, run the form. 
> 1. Press `F11` on your keyboard (the screen will turn blue/blank, entering "Search Mode").
> 2. Type an employee's first name into the 'First Name' field (e.g., `Rohit`).
> 3. Press `Ctrl + F11` (Execute Query).
> 4. *Result:* The form will instantly query the database and fetch all doctors/staff matching that name, perfectly fulfilling the *"fetch results by search criteria"* requirement!

---

