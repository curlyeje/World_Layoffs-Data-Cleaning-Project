-- Data Cleaning  

-- Created Database (world_layoffs) 
-- Created Table (layoffs)

SELECT * 
FROM layoffs;

-- Will be going through multiple steps in order to clean data
-- 1. Remove Duplicates 
-- 2. Standardize the Data 
-- 3. NULL values or blank files 
-- 4. Remove Any Unnecessary Colums

# Going to CREATE TABLE to copy all of the raw data into layoffs_staging table 

CREATE TABLE layoffs_staging
LIKE layoffs;

# Will open our new table. Has empty colums

SELECT * 
FROM layoffs_staging;

# Will use the INSERT clause to copy all data from layoffs to layoffs_staging

INSERT layoffs_staging 
SELECT * 
FROM layoffs; 

# Checking for duplicates by creating a row_num column

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

# Will create a CTE to double check for row_num duplicates > 1

# There were not any duplicates in the data. 

WITH duplicate_cte AS 
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

# Now, we will look into Standarzing the Data 
# We will first TRIM the company column to remove white spaces

SELECT company,(TRIM(company))
FROM layoffs_staging
ORDER BY company;

# Will update layoffs_staging table to include the removed white spaces

UPDATE layoffs_staging 
SET company = (TRIM(company));

# Now, we will take a look at the DISTINCT industry column 
# Will apply the ORDER BY 1 
# No changes needed to be made to location, and industry column

SELECT DISTINCT(industry) 
FROM layoffs_staging 
ORDER BY 1;

# Will check for errors in the country column by using DISTINCT clause 
# Found an error in Country column (United States.) 
# The . should not be there
# Will use the TRIM and TRAILING function to remove the . from United States

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) 
FROM layoffs_staging
ORDER BY 1;

# Will now UPDATE the layoffs_staging table 

UPDATE layoffs_staging 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

# Change date text column from text to DATE
# Will use the STR_TO_DATE function to change from text to date format

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging;

# Will update date text column to reflect the new STR_TO_DATE format for the date column.

UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

# Double check date column to make sure update executed properly

SELECT `date`
FROM layoffs_staging;

# Change the date text column to date column 

ALTER TABLE layoffs_staging 
MODIFY COLUMN `date` DATE; 

# Check the layoffs_staging table to ensure the date column has been altered

SELECT * 
FROM layoffs_staging; 

# Check for NULLS and blank values in total laid off and percentage laid off columns

SELECT * 
FROM layoffs_staging 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Check for NULLS and blank values in the industry column
# There were one blank and NULL values in Airbnb and Bally's in the industry column

SELECT DISTINCT *
FROM layoffs_staging 
WHERE industry IS NULL
OR industry = '';  

# Check for the Airbnb industry column 

SELECT * 
FROM layoffs_staging 
WHERE company = 'Airbnb';

# Will use the UPDATE statement 
#to add value Travel for Airbnb into industry column


UPDATE layoffs_staging
SET industry = 'Travel' 
WHERE industry = '';

# Will use the UPDATE STATEMENT 
# To add value Other for Bally's interactive industry column

UPDATE layoffs_staging 
SET industry = 'Other'
WHERE industry IS NULL;

# Check to make sure changes have been made 
# No more NULLS or blank values in the Industry Column

SELECT industry 
FROM layoffs_staging
ORDER BY 1;

# CHECK for NULLS in total laid off and percentage laid off

SELECT * 
FROM layoffs_staging 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

# Rolls with NULLS in total laid off and percentage laid off was deleted

DELETE 
FROM layoffs_staging 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

# Check layoffs_staging for any further data cleaning

SELECT * 
FROM layoffs_staging;
 

