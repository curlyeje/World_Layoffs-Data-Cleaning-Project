-- Exploratory Data Analysis 

SELECT * 
FROM layoffs_staging;

# Look for the MAX total laid off

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging;

# Look for businesses that did 100% layoffs
# Highest amount of employees laid off 

SELECT * 
FROM layoffs_staging 
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

# Check for SUM of total laid off with respect to each company

SELECT company, SUM(total_laid_off)
FROM layoffs_staging 
GROUP BY company
ORDER BY 2 DESC;

# Check for Date Ranges 

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging ;

# Which industry got hit the most 

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY industry 
ORDER BY 2 DESC;

# Which country was heavily impacted by layoffs (USA, Sweden)

SELECT country, SUM(total_laid_off)
FROM layoffs_staging 
GROUP BY country 
ORDER BY 2 DESC;

# Check SUM of total layoffs by Year/ 3 months for 2022 into 2023


SELECT YEAR (`date`), SUM(total_laid_off)
FROM layoffs_staging 
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


# Check stage column to see total laid off

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging 
GROUP BY stage
ORDER BY 2 DESC;

# Check percentage laid off 
# Not needed 

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging 
GROUP BY company
ORDER BY 2 DESC;

# Check the rolling total of layoffs 

SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging 
WHERE SUBSTRING(`date`, 1,7)  IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

# CREATE CTE to check for the Rolling SUM based off of rolling total of layoffs


WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging 
WHERE SUBSTRING(`date`, 1,7)  IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

# Look at company layoffs per month

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging 
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

# Create two CTEs that show company, years, total laid off, and ranks them by year

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging 
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking  
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;