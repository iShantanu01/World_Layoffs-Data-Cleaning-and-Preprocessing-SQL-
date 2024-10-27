use world_layoffs;

SELECT * 
FROM LAYOFFS_STAGING3;


SELECT MAX(total_laid_off) , MAX(percentage_laid_off)
FROM LAYOFFS_STAGING3;



-- 1. YEARLY LAYFOFFS 
SELECT YEAR(`DATE`) , SUM(total_laid_off)
FROM LAYOFFS_STAGING3
GROUP BY YEAR(`DATE`)
ORDER BY 2 DESC;


-- 2. STAGE WISE LAYOFFS
SELECT STAGE , SUM(total_laid_off)
FROM LAYOFFS_STAGING3
GROUP BY STAGE
ORDER BY 2 DESC;


-- 3. TRACK  THE MONTHLY LAYOFFS AND THE INCREASING LAYOFF CASES(RUNNING TOTAL)
SELECT SUBSTRING(`DATE` , 1, 7) AS `MONTH` ,SUM(total_laid_off)
FROM  LAYOFFS_STAGING3
WHERE SUBSTRING(`DATE` , 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


WITH ROLLING_TOTAL AS 
                  (SELECT SUBSTRING(`DATE` , 1, 7) AS `MONTH` ,SUM(total_laid_off)  AS MONTHLY_LAYOFFS 
                   FROM  LAYOFFS_STAGING3
                   WHERE SUBSTRING(`DATE` , 1, 7) IS NOT NULL
                   GROUP BY `MONTH`
				   ORDER BY 1 ASC)
SELECT `MONTH` ,  MONTHLY_LAYOFFS ,SUM(MONTHLY_LAYOFFS) OVER( ORDER BY `MONTH` ASC )  AS RUNNING_TOTAL_LAYOFFS             
FROM ROLLING_TOTAL;




-- 4. YEARLY TOP LAYOFFS BY COMPANIES (TOP 5 EVERY YEAR)
SELECT COMPANY , YEAR(`DATE`) AS `YEAR` , SUM(total_laid_off)
FROM  LAYOFFS_STAGING3
GROUP BY  COMPANY , `YEAR`
ORDER BY 2,3 DESC;

WITH 
COMPANY_YEARLY_LAYOFFS (COMPANY , YEARS , YEARLY_LAYOFFS) AS
			(SELECT COMPANY , YEAR(`DATE`) AS `YEAR` , SUM(total_laid_off)
             FROM  LAYOFFS_STAGING3
             GROUP BY  COMPANY , `YEAR`),
COMPANY_YEARLY_RANKING  AS          
           (SELECT  * , DENSE_RANK() OVER(PARTITION BY YEARS ORDER BY YEARLY_LAYOFFS DESC)  AS RANKING      
            FROM COMPANY_YEARLY_LAYOFFS 
            WHERE YEARS IS NOT NULL)
SELECT *
FROM  COMPANY_YEARLY_RANKING    
WHERE RANKING <=5      















