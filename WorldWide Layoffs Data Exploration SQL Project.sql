select *
from layoffs_staging_1

select max (total_laid_off) as max_total_laid_off, max (percentage_laid_off) as max_percentage_laid_off
from layoffs_staging_1

--------*Shows the companies that had 100 percent of they company laid off
select *
from layoffs_staging_1
where percentage_laid_off= 1
order by total_laid_off desc

--------funcs_raised_millions shows how big some of these companies were 
select *
from layoffs_staging_1
where percentage_laid_off= 1
order by funds_raised_millions desc

--------*Companies and the sum of layoffs

select company, sum(total_laid_off ) as sum_total_laid_off 
from layoffs_staging_1
group by company
order by 2 desc


select min (date) as firstday , max (date) as lastday 
from layoffs_staging_1 

--------*Industries and the sum of layoffs

select industry, sum(total_laid_off ) as sum_total_laid_off 
from layoffs_staging_1
group by industry
order by 2 desc

--------*Country and the sum of layoffs

select country, sum(total_laid_off ) as sum_total_laid_off 
from layoffs_staging_1
group by country
order by 2 desc

--------*The sum of layoffs each year

select year (date) as year,  sum(total_laid_off ) as sum_total_laid_off 
from layoffs_staging_1
group by year (date)
order by 1 desc

--------*The sum of layoffs each month of each year

SELECT SUBSTRING(CONVERT(VARCHAR(10), date, 120), 1, 7) AS thedate, sum(total_laid_off )
FROM layoffs_staging_1
where SUBSTRING(CONVERT(VARCHAR(10), date, 120), 1, 7)is not null 
group by SUBSTRING(CONVERT(VARCHAR(10), date, 120), 1,7)
order by 1 asc 

--------*Rolling Total of Layoffs Per Month

with rolling_total as 
(
SELECT SUBSTRING(CONVERT(VARCHAR(10), date, 120), 1, 7) AS thedate, sum(total_laid_off ) as total_off
FROM layoffs_staging_1
where SUBSTRING(CONVERT(VARCHAR(10), date, 120), 1, 7)is not null 
group by SUBSTRING(CONVERT(VARCHAR(10), date, 120), 1,7)
)
select thedate,total_off, sum(total_off) over ( order by thedate) as Rolling_total
from rolling_total 

--------*Shows the total of layoffs in each company in descending order

select company, year (date) as theyear , sum(total_laid_off ) as sum_total_laid_off 
from layoffs_staging_1
group by company, year (date)
order by 3 desc

--------*Temp table assigning a ranking to each company based on the total number of employees laid off each year

with company_year as 
( 
select company, year (date) as theyear , sum(total_laid_off ) as sum_total_laid_off 
from layoffs_staging_1
group by company, year (date)
)
select *, DENSE_RANK () over (partition by theyear order by sum_total_laid_off  desc) as ranking
from company_year
where theyear is not null 
order by  ranking asc


----------* Temp table shows the top 5 companies for each year based on the number of employees they laid off

with company_year as 
( 
select company, year (date) as theyear , sum(total_laid_off ) as sum_total_laid_off 
from layoffs_staging_1
group by company, year (date)

), company_year_rank as 
(
select *, DENSE_RANK () over (partition by theyear order by sum_total_laid_off  desc) as ranking
from company_year
where theyear is not null 
)
select *
from company_year_rank
where ranking <= 5
