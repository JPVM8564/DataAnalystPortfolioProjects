select location, fecha, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not NULL
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, fecha, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location = 'United States'
order by 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got covid

Select location, fecha, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from coviddeaths
where location like 'United States'
order by 1,2


-- Looking at countries with highest infection rates compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
from coviddeaths
where continent is not NULL
group by location, population 
order by InfectionPercentage desc

-- Showing the countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not NULL
group by location 
order by TotalDeathCount desc


-- Let's break things down by continent
-- Showing the continents with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is NULL
group by location 
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not NULL
group by continent 
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select fecha, SUM(new_cases), SUM(new_deaths), SUM (new_deaths)/SUM(new_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null and new_cases <> 0 and new_deaths <> 0
group by fecha 
order by 1,2

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM (new_deaths)/SUM(new_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null and new_cases <> 0 and new_deaths <> 0
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.fecha, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.fecha) as Rolling_vaccinations
--, (Rolling_vaccinations/population)*100
from coviddeaths Dea
join covidvaccinations Vac
    on dea.location = Vac.location 
    and Dea.fecha = Vac.fecha
where dea.continent is not NULL
order by 2,3 


-- Use CTE

With PopvsVac (continent, location, fecha, population, new_vaccinations, Rolling_vaccinations)
as
(
select dea.continent, dea.location, dea.fecha, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.fecha) as Rolling_vaccinations
--, (Rolling_vaccinations/population)*100
from coviddeaths Dea
join covidvaccinations Vac
    on dea.location = Vac.location 
    and Dea.fecha = Vac.fecha
where dea.continent is not NULL
--order by 2,3 
)
select PopvsVac.*, (Rolling_vaccinations/population)*100
from PopvsVac
 


-- TEMP TABLE

create global temporary table PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
fecha date,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.fecha, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.fecha) as Rolling_vaccinations
from coviddeaths dea
join covidvaccinations vac
    on dea.location = vac.location 
    and dea.fecha = vac.fecha
where dea.continent is not NULL 

select PercentPopulationVaccinated.*, (Rolling_vaccinations/population)*100
from PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create view ViewPercentPopulationVaccinated as
select dea.continent, dea.location, dea.fecha, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.fecha) as Rolling_vaccinations
--, (Rolling_vaccinations/population)*100
from coviddeaths Dea
join covidvaccinations Vac
    on dea.location = Vac.location 
    and Dea.fecha = Vac.fecha
where dea.continent is not NULL

select *
from viewpercentpopulationvaccinated