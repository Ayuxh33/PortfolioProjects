USE world_layoffs;

SELECT * 
FROM layoffs;


CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- 1. **Remove Duplicates**  Since no unique values
-- create a row number column first then use cte to check duplicates that will be >1 row_num
-- then create another table wherer we can delete the rows with row_num>2
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY company , industry, total_laid_off,percentage_laid_off,'date') AS row_num
FROM layoffs_staging;

WITH duplicate_Cte AS
( 
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY company , location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_Cte
WHERE row_num>1;


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

SELECT * FROM layoffs_staging2;

INSERT  layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY company , location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
WHERE row_num > 1;

DELETE FROM layoffs_staging2
WHERE row_num > 1;



-- 2. **Standardize the Data**

SELECT * FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = Trim(company);

SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIkE 'Crypto%';

SELECT Distinct Country
FROM layoffs_staging;
SELECT Distinct Country
FROM layoffs_staging
WHERE Country Like 'United States%';


UPDATE layoffs_staging2
SET Country = TRIM(Trailing '.' FROM country)
WHERE COUNTRY LIKE 'United States%';

SELECT date,
STR_TO_DATE(date,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(date,'%m/%d/%Y');

SELECT *
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
CHANGE COLUMN `date` `Date` DATE;



-- 3. **Null or blank Values** finding the nulls and blanks and populating them with similar data from mother columns by joining



SELECT *
FROM layoffs_staging2
WHERE industry is null OR industry =''
;
UPDATE layoffs_staging2
SET industry = null
WHERE industry =''
;
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
	AND t1.location=t2.location
WHERE t1.industry IS null
and t2.industry is not null;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS null
and t2.industry is not null;

SELECT * 
FROM layoffs_staging2
WHERE company LIKE 'Bally%';




-- 4. Remove any columns/rows
SELECT  *
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null
;

DELETE
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null
;
ALTER TABLE layoffs_staging2
Drop column row_num;

SELECT  *
FROM layoffs_staging2;