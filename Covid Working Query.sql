select *
from CovidDeaths
order by 3,4

select *
from CovidVaccinations
order by 3,4

-- Select Data that we are going to use


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract COVID in the search term


select location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as "DeathPercentage"
from CovidDeaths
where Location like '%italy%'
order by 1,2


-- Looking at total cases vs population

select location, date, total_cases, population, (total_cases/population*100) as "CasesPercentage"
from CovidDeaths
-- where Location like '%italy%'
order by 1,2

-- What countres does have the highest infection rate?

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population*100) as "CasesPercentage"
from CovidDeaths
group by population, location
order by 4 desc,3

-- What countres does have the highest death rate/population?
-- Removing World and continent with Where continent is not null

select location, MAX(cast(total_deaths as int)) as TotalDeathCount--, MAX(total_deaths/population*100) as "DeathPercentage"
from CovidDeaths
Where continent is not null
group by population, location
order by 2 desc 

-- Showing the continents with the highest death count
--let's breack down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount--, MAX(total_deaths/population*100) as "DeathPercentage"
from CovidDeaths
Where continent is not null
group by continent
order by 2 desc 

---- Correct numbers

select location, MAX(cast(total_deaths as int)) as TotalDeathCount--, MAX(total_deaths/population*100) as "DeathPercentage"
from CovidDeaths
Where continent is null
group by location
order by 2 desc 

-- Global numbers

select date, sum(new_cases) as GlobalCases, SUM(cast(new_deaths as int)) as GlobalDeaths, (SUM(cast(new_deaths as int))/sum(new_cases)*100) as "GlobalDeathPercentage"
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Checking covid vaccination
select *
from CovidVaccinations
order by location,date

--Table join
select*
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =  vac.location
	and dea.date = vac.date

-- Global population vs Vaccination
select dea.continent, dea.location, dea.population, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date)  as VaccinationRollingCount
-- , (VaccinationRollingCount/population *100) as VaccinationRate			Non funziona perchè non si può usare un alias appena creato, serve una temp table o cte
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =  vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Soluzione CTE

With PopvsVac (Continent, Location, Population, Date, new_vaccinations, VaccinationRollingCount)
as
(
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date)  as VaccinationRollingCount
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =  vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 1,2,3
)

select *, (VaccinationRollingCount/population *100) as VaccinationRate
from PopvsVac


--Solutazione Temp Table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated 
(
continent nvarchar(255)
, location nvarchar(255)
, population numeric
, date datetime
, new_vaccinations numeric
, VaccinationRollingCount numeric
--, VaccinationRate numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date)  as VaccinationRollingCount
-- , (VaccinationRollingCount/population *100) as VaccinationRate			Non funziona perchè non si può usare un alias appena creato, serve una temp table o cte
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =  vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

select *, (VaccinationRollingCount/population *100) as VaccinationRate
from #PercentPopulationVaccinated

-- Create view for storing data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date)  as VaccinationRollingCount
-- , (VaccinationRollingCount/population *100) as VaccinationRate			Non funziona perchè non si può usare un alias appena creato, serve una temp table o cte
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =  vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

--Querying from view
select *
from PercentPopulationVaccinated