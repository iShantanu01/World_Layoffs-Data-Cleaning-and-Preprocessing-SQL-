PROJECT NAME: World Layoffs Data Cleaning and Preprocessing

---

1. INTRODUCTION:

In an era marked by economic uncertainty, layoffs have become a critical metric for understanding the health and dynamics of 
various industries globally. This project focuses on cleaning and preparing a comprehensive dataset of global layoffs, enabling analysts,
researchers, and decision-makers to derive meaningful insights. The dataset contains information on companies, locations, industries, 
total layoffs, and other relevant attributes, which after cleaning, will be ready for analysis or further processing.

---

2. OVERVIEW:

The dataset comprises multiple columns that capture various aspects of layoffs across different industries and regions. 
To ensure the dataset is accurate, consistent, and ready for analysis, we perform a series of data cleaning steps. 
These include removing duplicates, standardizing data formats, handling null and blank values, and eliminating irrelevant columns.
The clean dataset will serve as a reliable foundation for further analysis, aiding stakeholders in understanding patterns, trends, 
and the broader impact of layoffs.

---

3. OBJECTIVE:

The primary objective of this project is to clean and standardize a global layoffs dataset to improve its quality and usability. 
Specifically, the project aims to:

1. Remove Duplicates: Identify and eliminate any duplicate records to ensure data accuracy.
2. Standardize Data: Convert data into consistent formats, including standardizing text, dates, and numerical fields.
3. Handle Null and Blank Values: Address missing or blank values by either imputing or removing them, depending on the context.
4. Column Removal: Eliminate any columns that are irrelevant or do not add value to the analysis.

---

4. WORKFLOW:

   1. Create a Copy of the Original Table-
      Objective: To preserve the original dataset, create a working copy of the table.
      Action: Create a table named `LAYOFFS_STAGING`.

   2. LAYOFFS_STAGING2
      Objective: Create an additional working table with an indicator for duplicates.
      Action: Copy `LAYOFFS_STAGING` to a new table named `LAYOFFS_STAGING2`. 
              Add a new column named `row_num` to this table, assigning values to indicate duplicates 
              where `row_num` is greater than 1.

   3. Remove Duplicates-
      Objective: Eliminate duplicate records to improve data integrity.
      Action: Remove duplicate values from `LAYOFFS_STAGING2`.

   4. Standardize Data-
      Objective: Ensure data consistency by standardizing column entries.
      Actions:
         Country Column: Use the `TRIM()` function to remove unnecessary spaces; standardize `united_states`.
         Industry Column: Standardize values, especially entries like `Crypto`.
         Date Column: Convert the `date` column to the date data type from string format.

   5. Create LAYOFFS_STAGING3-
      Objective: Establish a final cleaned table version.
      Action: Create a copy of `LAYOFFS_STAGING2` and name it `LAYOFFS_STAGING3`.

   6. Manage Null and Blank Values-
      Objective: Address blank or null values to complete the dataset.
      Actions:
         Industry Column: Identify rows with blank values.
         Null Handling: Update the `industry` column to `NULL` where values are blank.
         Self-Join Check: Perform a self-join on `LAYOFFS_STAGING3` to identify null values in the table.
         Fill Nulls: Replace null values in the `industry` column using respective values from rows with the same `company` name.
         Total_laid_off and Percentage_laid_off Columns: Identify null values in these columns.
         Delete Nulls: Remove records with null values in these columns due to insufficient information.

   7. Drop the Row Number Column-
      Objective: Clean up the final table structure.
      Action: Drop the `row_num` column, which was used temporarily to identify and remove duplicates.

---

5. TOOL USED:

   MYSQL WORKBENCH: All data cleaning, standardization, and processing steps were performed using SQL queries 
                    to transform the dataset.

---

6.  RESULTS AND CONCLUTION:

    Results:
Upon completing these steps, the `LAYOFFS_STAGING3` table will:
- Initially there are total 2361 rows and after  cleaning the data it turns into 1995 rows.
- Contain only unique, accurate records with no duplicates.
- Have standardized entries for country, industry, and date columns.
- Be free of unnecessary columns and fully address blank or null values, 
  particularly in critical fields like `industry`, `total_laid_off`, and `percentage_laid_off`.


   Conclusion:
The cleaning and standardization processes in this project ensure that the global layoffs dataset is reliable, 
accurate, and ready for meaningful analysis. This refined dataset will allow stakeholders to explore patterns and 
trends in layoffs worldwide, offering insights into economic impacts and industry-specific dynamics during periods of 
economic uncertainty.

---

