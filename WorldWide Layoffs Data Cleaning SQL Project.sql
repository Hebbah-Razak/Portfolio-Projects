select * 
from worldwidelayoffs..layoffs

--------*Create staging table and NOT use the raw data

CREATE TABLE layoffs_staging_1( 
company varchar(50), 
location varchar(50), 
industry varchar(50), 
total_laid_off int, 
percentage_laid_off float, 
[date] datetime, 
stage varchar(50), 
country varchar(50), 
funds_raised_millions int,
)

select *
from layoffs_staging_1

INSERT INTO layoffs_staging_1 (company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions)
SELECT company, location, industry, total_laid_off, 
TRY_CAST(percentage_laid_off as float), 
CONVERT(datetime, [date]), stage, country, funds_raised_millions
FROM layoffs;


--------1.*Remove Duplicates

SELECT company,location,industry,total_laid_off, percentage_laid_off,[date],stage,country,funds_raised_millions,
row_number() OVER (
	PARTITION BY company,
	location,
	industry,
	total_laid_off, 
	percentage_laid_off,
	[date],
	stage,country,
	funds_raised_millions
		order BY company,
		location,
		industry,
		total_laid_off, 
		percentage_laid_off,
		[date],
		stage,
		country,funds_raised_millions) as rownumbers

from layoffs_staging_1

--------*CTE to remove duplicates


WITH duplicate01_cte as (
SELECT company,location,industry,total_laid_off, percentage_laid_off,[date],stage,country,funds_raised_millions,
row_number() OVER (
	PARTITION BY company,
	location,
	industry,
	total_laid_off, 
	percentage_laid_off,
	[date],
	stage,country,
	funds_raised_millions
		order BY company,
		location,
		industry,
		total_laid_off, 
		percentage_laid_off,
		[date],
		stage,
		country,funds_raised_millions
		) as rownumbers

from layoffs_staging_1
) 


select *
FROM duplicate01_cte
WHERE rownumbers > 1;


delete
FROM duplicate01_cte
WHERE rownumbers > 1;

--------*Double -Checking that the two rows don't match

--------select * 
--------from layoffs_staging_1
--------where company = 'Casper' 

--------*2. Standarize the Data

SELECT company, LTRIM(RTRIM(company)) as trimcompany
FROM layoffs_staging_1;

Update layoffs_staging_1
set company= LTRIM(RTRIM(company));

SELECT*
FROM layoffs_staging_1;

--------*Crypto has multiple different variations. We need to standardize that 

select *
from layoffs_staging_1
where industry='crypto'

update layoffs_staging_1
set industry = 'crypto'
where industry like 'crypto currency' OR industry LIKE 'cryptocurrency';

select *
from layoffs_staging_1


select distinct (country)
from layoffs_staging_1
order by country

--------*Remove the periods at the end of the country name

select distinct country, replace(country, '.', '') 
from layoffs_staging_1
order by country


UPDATE layoffs_staging_1
SET country = REPLACE(country, '.', '')



select distinct (industry)
from layoffs_staging_1

--------*3. look at Null Values and populate those if possible

SELECT*
FROM layoffs_staging_1
where industry is null 
or industry= 'n'

select *
from layoffs_staging_1
where company = 'Airbnb' 


select *
from layoffs_staging_1 t1
join layoffs_staging_1 t2	
	ON t1.company = t2.company 
	WHERE (t1.industry IS NULL or t1.industry='' or t1.industry='n' )
	AND t2.industry IS NOT NULL 

update  t1
set t1.industry=t2.industry
FROM layoffs_staging_1 t1 
JOIN layoffs_staging_1 t2 
ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '' ) 
AND t2.industry IS NOT NULL;


--select t1.industry, t2.industry
--from layoffs_staging_1 t1
--join layoffs_staging_1 t2	
--	ON t1.company = t2.company 

--	WHERE (t1.industry IS NULL or t1.industry='' or t1.industry='' )
--	AND t2.industry IS NOT NULL
	
--------*4. Remove any Null columns that are not necessary 

select *
from layoffs_staging_1 
where total_laid_off is null 
and percentage_laid_off is null; 

delete 
from layoffs_staging_1 
where total_laid_off is null 
and percentage_laid_off is null; 


select *
from layoffs_staging_1 