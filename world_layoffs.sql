
-- 1. show tables in this database
-- only one table is here layoffs
use world_layoffs;
SHOW TABLES;
select * from layoffs;


-- DATA CLEANING STEPS-
-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATA
-- 3. NULL VALUES AND BLANK VALUES
-- 4. REMOVE ANY  COLUMN


-- 2. COPY RAW DATA AND CREATE A NEW TABLE FOR STAGING
-- THIS IS DONE TO SAVE THE RAW DATA (IF THERE IS ANY FUTURE REQUIREMENT PURPOSE)
CREATE TABLE LAYOFFS_STAGING
LIKE LAYOFFS;                     -- ONLY CREATE THE TABLE NOT  THE DATA

-- INSERT THE LAYOFFS DATA INTO LAYOFFS_STAGING
INSERT INTO LAYOFFS_STAGING
SELECT * 
FROM LAYOFFS;


-- REMOVING DUPLICATES
-- I HAVE CREATE A ADDITIONAL COLUMN ROW_NUMBER USING WINDOW FUNCTION
--       WHERE THE WINDOW IS CREATED BY ALL THE COLUMNS, SO THAT IF 
--       ANY  DUPLICATE ROWS PRESENTS IN THE TABLE ROW NUMBER WILL be
--       GREATER THAN 1
/*
WITH DUPLICATE_CTE AS
(
SELECT * ,
       ROW_NUMBER() OVER(PARTITION BY COMPANY,LOCATION,INDUSTRY,TOTAL_LAID_OFF,
						 PERCENTAGE_LAID_OFF,date,STAGE,COUNTRY,FUNDS_RAISED_MILLIONS) AS ROW_NUM
FROM LAYOFFS_STAGING)
SELECT * FROM DUPLICATE_CTE
WHERE ROW_NUM >1 ;
*/

-- 3. COPY THE layoffs_staging table create query from the clipboard 
-- create the table columns 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT     
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- 4. INSERT DATA INTO layoffs_staging2 COPYING FROM THE layoffs_staging
INSERT INTO layoffs_staging2
SELECT * ,
       ROW_NUMBER() OVER(PARTITION BY COMPANY,LOCATION,INDUSTRY,TOTAL_LAID_OFF,
						 PERCENTAGE_LAID_OFF,date,STAGE,COUNTRY,FUNDS_RAISED_MILLIONS) AS ROW_NUM
FROM LAYOFFS_STAGING;

-- 5.  CHECK THE DUPLICATE DATE 
SELECT * 
FROM layoffs_staging2
WHERE ROW_NUM >1;



/*Safe update mode is a safety feature designed to prevent accidental updates or deletions of large numbers of rows.
 When this mode is enabled, MySQL requires that any UPDATE or DELETE statement must include a WHERE clause 
 that references a key column (such as a primary key or unique index)*/

-- 6. REMOVE THE DUPLICATE FROM THE LAYOFF_STAGING2
-- TEMPORARILY DISABLE SAFE UPDATE MODE
SET SQL_SAFE_UPDATES = 0;


-- DETETE THE DUPLICATE DATA
DELETE 
FROM layoffs_staging2
WHERE ROW_NUM >1;

-- RE-ENABLE SAFE UPDATE MODE
SET SQL_SAFE_UPDATES = 1;



--  STANDARDIZE THE DATA


-- TRIM COMPANY COLUMN 
/*SELECT COMPANY , TRIM(COMPANY)
FROM  LAYOFFS_STAGING2;*/


-- 6. UPADTE TRIM COMPANY COLUMN 
-- SQL SAFE UPDATE ON
SET SQL_SAFE_UPDATES =0;

-- UPDATE THE COLUMN
UPDATE LAYOFFS_STAGING2
SET COMPANY = TRIM(COMPANY);

-- SQL SAFE UPDATE OFF
SET SQL_SAFE_UPDATES =1;

-- 7. CHECK INDUSTRY 'CRYPTO' TYPE

SELECT *
FROM  LAYOFFS_STAGING2
WHERE INDUSTRY LIKE 'Crypto%' ; 


-- 8. STANDARDIZE THE INDUSTRY COLUMN  
-- SQL SAFE MODE DISABLE
SET SQL_SAFE_UPDATES =0;

-- UPDATE
UPDATE LAYOFFS_STAGING2
SET  INDUSTRY = 'Crypto'
WHERE INDUSTRY LIKE 'Crypto%';


-- 9. CHECK  COUNTRY TABLE FOR THE COLUMN ELEMENT 'UNITED STATES'
SELECT * ,  COUNTRY  ,TRIM(TRAILING '.' FROM COUNTRY)
FROM  LAYOFFS_STAGING2
WHERE COUNTRY LIKE 'UNITED STATES%';


-- 10. UPDATE COUNTRY COLUMN and standardize the 'United States'
UPDATE LAYOFFS_STAGING2
SET COUNTRY = TRIM(TRAILING '.' FROM COUNTRY)
WHERE COUNTRY LIKE 'UNITED STATES%';

-- 11. Check AND CONVERT DATE COLUMN FORM STRING TO DATE FORMAT-
SELECT `DATE` ,str_to_date(`DATE`, '%m/%d/%Y')
FROM  LAYOFFS_STAGING2 ;


-- 12. UPDATE THE DATE COLUMN
UPDATE LAYOFFS_STAGING2
SET `DATE` = str_to_date(`DATE`, '%m/%d/%Y');
-- AFTER THIS I CAN MAKE IT IN DATE FORMAT BUT DATA TYPE DOESN'T CHANGE

-- MODIFY THE DATE COLUMN DATA TYPE TO 'DATE'
ALTER TABLE LAYOFFS_STAGING2
MODIFY COLUMN `DATE` DATE;


--  NULL VALUES AND BLANK VALUES

-- 13. BEFORE MODIFY FURTHER CREATE STAGING 3
-- CREATE THE TBALE COLUMNS
CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `DATE` date DEFAULT NULL,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 14. INSERT THE VALUES IN THE COLUMNS
INSERT INTO LAYOFFS_STAGING3
SELECT * 
FROM LAYOFFS_STAGING2;




-- 15. NOW TAKE A LOOK Airbnb,Bally's Interactive,Carvana,Juul IS WHICH TYPE OF INDUSTRY
SELECT COMPANY , INDUSTRY
FROM  LAYOFFS_STAGING3
WHERE COMPANY IN (SELECT DISTINCT COMPANY
                    FROM  LAYOFFS_STAGING2
				   WHERE INDUSTRY IS NULL
                                  OR INDUSTRY = '' );

/*
Airbnb-Travel
Bally's Interactive-
Carvana- Transportation
Juul- Consumer */

-- 16. self join to fill the null blank in the industry column-
select t1.company,t1.industry ,t2.industry
from LAYOFFS_STAGING3 t1
join LAYOFFS_STAGING3 t2
on t1.company = t2.company        
   and t1.location = t2.location  -- assuming same location and same company have same industry (depend on use case) 
where (t1.industry is null or t1.industry = '')
  and t2.industry is not null  ;



-- 17. UPDATE INDUSTRY COLUMN TO NULL  WHERE THE VALUE IS BLANK IN THE COLUMN
 /*THIS STEP IS NECESSARY AS I CAN'T UPDATE THE TABLE (filling the blank) ,
 IF THERE IS PRESENT ANY BLANK IN THE COLUMN (INDUSTRY)*/
SET SQL_SAFE_UPDATES = 0;

UPDATE LAYOFFS_STAGING3
SET INDUSTRY = null
WHERE INDUSTRY = '' ;

-- 18. self join to CHECK the null blank in the industry column-
select t1.company,t1.industry ,t2.industry
from LAYOFFS_STAGING3 t1
join LAYOFFS_STAGING3 t2
on t1.company = t2.company        
   and t1.location = t2.location  -- assuming same location and same company have same industry (depend on use case) 
where (t1.industry is null )
  and t2.industry is not null  ;


-- 19. NOW UPDATE THE TABLE AND FILL THE NULL VALUES
UPDATE LAYOFFS_STAGING3 T1     -- UPDATE THIS TABLE
JOIN LAYOFFS_STAGING3 T2       
ON T1.COMPANY = T2.COMPANY    -- JOIN ON COMPAY
SET T1.INDUSTRY = T2.INDUSTRY
where (t1.industry is null )
  and t2.industry is not null  ;



-- 20. CHECK NULLS IN total_laid_off AND percentage_laid_off
SELECT * 
FROM  LAYOFFS_STAGING3
WHERE total_laid_off IS NULL
      AND percentage_laid_off IS NULL;

-- 21. DELETE THE ABOVE DATA AS THERE ARE NO EXTRA COLUMN NUMBER OF EMPLOYEE.
DELETE
FROM  LAYOFFS_STAGING3
WHERE total_laid_off IS NULL
      AND percentage_laid_off IS NULL;
      
      
      
-- 22. DROP THE ROW_NUM COLUMN FROM THE TABLE 'LAYOFFS_STAGING3'  
ALTER TABLE LAYOFFS_STAGING3
DROP COLUMN ROW_NUM;

