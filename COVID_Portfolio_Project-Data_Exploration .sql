show databases;
create database covid_test;
use covid_test;

use demo;

Select *
From demo.coviddeaths
Order by 3,4;

-- Select *
-- From demo.covidvaccinations
-- Order by 3,4;

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From demo.coviddeaths
order by 1,2;

-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying of you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From demo.coviddeaths
Where location like '%China%'
order by 1,2;

-- Looking at the Total cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From demo.coviddeaths
order by 1,2;

-- Lookiing at Countries with Highest Infection Rate compare to Population
--
-- in certain day?
Select location, population, Max(total_cases) as HighestInfectionCount, 
population, MAX((total_cases/population))*100 as PercentpopulationInfected
From demo.coviddeaths
Group by location, population
order by PercentpopulationInfected desc;

-- showing countries with highest death count per population

Select location, Max(cast( total_deaths as SIGNED)) as TotalDeathCount -- use SIGNED but not INT
From demo.coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc;

-- select *
-- from demo.coviddeaths
-- where continent is not null
-- order by 3,4;


-- let's break things down by continent 

-- showing continent with the highest death count per population

Select continent, Max(cast( total_deaths as SIGNED)) as TotalDeathCount -- use SIGNED but not INT
From demo.coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Select location, Max(cast( total_deaths as SIGNED)) as TotalDeathCount -- use SIGNED but not INT
-- From demo.coviddeaths
-- where continent is not null
-- Group by location
-- order by TotalDeathCount desc;


-- Global numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as SIGNED)) as total_deaths,-- sum(max(total_deaths)), (total_deaths/total_cases)*100 as DeathPercentage
sum(cast(new_deaths as SIGNED))/sum(new_cases)*100 as DeathPercentage
From demo.coviddeaths
-- Where location like '%China%'
where continent is not null
group by date
order by 1,2;


Select sum(new_cases) as total_cases, sum(cast(new_deaths as SIGNED)) as total_deaths,-- sum(max(total_deaths)), (total_deaths/total_cases)*100 as DeathPercentage
sum(cast(new_deaths as SIGNED))/sum(new_cases)*100 as DeathPercentage
From demo.coviddeaths
-- Where location like '%China%'
where continent is not null
-- group by date
order by 1,2;


--  Looking at total population vs Vaccinations

-- DESCRIBE demo.coviddeaths;
-- DESCRIBE demo.covidvaccinations;

SELECT dea.continent, dea.location ,STR_TO_DATE(dea.date, '%m/%d/%y') AS Date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From demo.coviddeaths dea
join demo.covidvaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Use CTE

with PopvsVac(Continent,location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From demo.coviddeaths dea
join demo.covidvaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null

)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;


-- TEMP TABLE


-- Create Table #PercentPopulationVaccinated
-- (
-- Continent nvarchar(255),
-- Location nvarchar(255),
-- Date datetime,
-- Population numeric,
-- New_vaccinations numeric,
-- RollingPeopleVaccinated numeric
-- )

DROP Table if exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
  Continent VARCHAR(255),
  Location VARCHAR(255),
  Date DATETIME,
  Population NUMERIC,
  New_vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT
  dea.continent,
  dea.location,
  STR_TO_DATE(dea.date, '%m/%d/%y') AS Date,
  CAST(dea.population AS DECIMAL(18,2)),
  CAST(vac.new_vaccinations AS DECIMAL(18,2)),
  SUM(CAST(vac.new_vaccinations AS DECIMAL(18,2)))
    OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
    AS RollingPeopleVaccinated
FROM demo.coviddeaths dea
JOIN demo.covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
  AND dea.population REGEXP '^[0-9.]+$'
  AND vac.new_vaccinations REGEXP '^[0-9.]+$';



SELECT *,
       (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM PercentPopulationVaccinated;



-- create View to store data for later visualization
DROP VIEW IF EXISTS PercentPopulationVaccinated;
create view PercentPopulationVaccinated as
SELECT
  dea.continent,
  dea.location,
  STR_TO_DATE(dea.date, '%m/%d/%y') AS Date,
  CAST(dea.population AS DECIMAL(18,2)),
  CAST(vac.new_vaccinations AS DECIMAL(18,2)),
  SUM(CAST(vac.new_vaccinations AS DECIMAL(18,2)))
    OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
    AS RollingPeopleVaccinated
FROM demo.coviddeaths dea
JOIN demo.covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
  AND dea.population REGEXP '^[0-9.]+$'
  AND vac.new_vaccinations REGEXP '^[0-9.]+$'
 ;

SELECT * FROM demo.percentpopulationvaccinated;