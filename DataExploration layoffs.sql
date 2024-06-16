-- EXPLORATORY DATA ANALYSIS
SELECT *
FROM layoffs_staging2
;

SELECT MIN(date),MAX(date)
FROM layoffs_staging2;

SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company 
ORDER BY 3 DESC;

SELECT country , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country 
ORDER BY 2 DESC;

SELECT Year(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY Year(date) 
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage 
ORDER BY 1 DESC;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Progression of layoffs

SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(Total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ;

-- (Rolling total)

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(Total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`
date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`,total_off, SUM(total_off) OVER(ORDER BY`Month`) AS rolling_total
FROM Rolling_Total;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
ORDER BY 3 desc;


WITH Company_year (company, years, total_laid_offs) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
), COmpany_year_rank AS (
SELECT *, DENSE_RANK () OVER (Partition BY years ORDER BY total_laid_offs DESC) AS Ranking
 FROM COMPANY_YEAR
 WHERE years IS NOT NULL
 )
 SELECT * FROM COmpany_year_rank
 WHERE Ranking<=5;