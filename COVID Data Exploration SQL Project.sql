select *
from [Covid Project].dbo. CovidDeaths 
order by 3,4

--select *
--from [Covid Project]..CovidVaccinations
--order by 3,4

----------*Selecting specific columns*

select location, date, total_cases new_cases, total_deaths, population
from [Covid Project].dbo. CovidDeaths
where location like '%Canada%'
order by 1,2


--------*TOTAL CASES VS TOTAL DEATHS*

select location, date, total_deaths, total_cases, ( total_deaths/ total_cases)*100 as deathpercentage
from [Covid Project].dbo. CovidDeaths
--where location like '%Canada%'
order by 1,2

--------*TOTAL CASES VS Population * Shows the percent of the population who got COVID*

select location, date, total_cases, population, ( total_cases/ population)*100 as percentofpopulationinfected
from [Covid Project].dbo. CovidDeaths
--where location like '%Canada%'
order by 1,2

--------*COUNTRIES WITH THE HIGHEST INFECTION RATES COMPARE TO POPULATION*

select location, population, max (total_cases) as highestnumberofcases, max ((total_cases/ population))*100 as percentpopinfected
from [Covid Project].dbo. CovidDeaths
group by location, population
order by percentpopinfected desc

------*COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION*

select location, max (cast(total_deaths as int)) as totaldeathcount
from [Covid Project].dbo. CovidDeaths
where continent is not NUll
group by location
order by totaldeathcount desc


------*CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION*

select location, max (cast(total_deaths as int)) as totaldeathcount
from [Covid Project].dbo. CovidDeaths
where continent is  NUll
group by location
order by totaldeathcount desc

--------*SHOWS THE SUM OF CASES AROUND THE WORLD EACH DAY*

select  date, sum(new_cases) as thetotalnumofcasesgloballyeachday
from [Covid Project].dbo. CovidDeaths
--where location like '%Canada%'
where continent is not null
group by date
order by 1,2


--------*SHOWS THE DEATH PERCENTAGE GLOBALLY PER DAY*

select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum (cast(new_deaths as int))/sum(new_cases)*100 as deathpercentagegloballyperday
from [Covid Project].dbo. CovidDeaths
--where location like '%Canada%'
where continent is not null
group by date
order by 1,2

--------*SHOWS THE DEATH PERCENTAGE GLOBALLY PER DAY*

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum (cast(new_deaths as int))/sum(new_cases)*100 as deathpercentageglobally
from [Covid Project].dbo. CovidDeaths
--where location like '%Canada%'
where continent is not null
--group by date
order by 1,2


select *
from [Covid Project]..CovidVaccinations vac
join [Covid Project]..CovidDeaths dea
on vac.location= dea.location 
and vac.date= dea.date

--------*TOTAL POPULATION AND THE NUMBER OF PEOPLE VACCINATED AROUND THE WORLD PER DAY*

select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
from [Covid Project]..CovidVaccinations vac
join [Covid Project]..CovidDeaths dea
on vac.location= dea.location 
and vac.date= dea.date
where dea.continent is not null
order by 2,3 


--------*ROLLING COUNT*

select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
,sum(convert(int,vac. new_vaccinations))over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Covid Project]..CovidVaccinations vac
join [Covid Project]..CovidDeaths dea
on vac.location= dea.location 
and vac.date= dea.date
where dea.continent is not null
order by 2,3

--------*CTE*SHOWS THE PERCENT OF PEOPLE VACCINATED IN THE POPULATION OF EACH COUNTRY*

with POPVSVAC (continent,location,date,population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
,sum(convert(int,vac. new_vaccinations))over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Covid Project]..CovidVaccinations vac
join [Covid Project]..CovidDeaths dea
on vac.location= dea.location 
and vac.date= dea.date
where dea.continent is not null
)
select * , (rollingpeoplevaccinated/population)*100 as percent_of_people_vaccinated_in_population
from POPVSVAC


--------*TEMP TABLE*SHOWS THE PERCENT OF PEOPLE VACCINATED IN THE POPULATION OF EACH COUNTRY

Drop table if exists #populatevaccinatedpercent
create table #populatevaccinatedpercent
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccations numeric,
rollingpeoplevaccinated numeric
)

insert into #populatevaccinatedpercent
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
,sum(convert(int,vac. new_vaccinations))over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Covid Project]..CovidVaccinations vac
join [Covid Project]..CovidDeaths dea
on vac.location= dea.location 
and vac.date= dea.date
where dea.continent is not null
--order by 2,3 

select * , (rollingpeoplevaccinated/population)*100
from #populatevaccinatedpercent




