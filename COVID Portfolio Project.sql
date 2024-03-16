/*
COVID 19 Data Exploration

Skills used : Joins, CTE's, Temp Tables, Windows Function, Aggregate Function, Creating views, Converting Data Types

*/


SELECT *
FROM [Portfolio project]..CovidDeaths
where continent is not null
ORDER BY 3,4


-- Selecting Data that we use 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio project]..CovidDeaths
where continent is not null
ORDER BY 1,2

-- Total case vs Total Deaths
-- Shows likelihood of dying in our country.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercent
FROM [Portfolio project]..CovidDeaths
WHERE location = 'India' AND continent is not null
ORDER BY 1,2

-- Total case vs Population
--Shows what percent of population got Covid

SELECT location, population, total_cases, (total_cases/population) * 100 AS populationpercentinfected
FROM [Portfolio project]..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS populationpercentinfected
FROM [Portfolio project]..CovidDeaths
--WHERE location = 'India'
GROUP BY location, population
ORDER BY populationpercentinfected DESC

-- Countries with Highest Death Count per population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio project]..CovidDeaths
--WHERE location = 'India'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Break down By Continent

-- Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio project]..CovidDeaths
--WHERE location = 'India'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global analysis

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercent
FROM [Portfolio project]..CovidDeaths
--WHERE location = 'India' AND 
WHERE continent is not null
ORDER BY 1,2


-- Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS AggregatePeopleVaccinated
--,(AggregatePeopleVaccinated/population)*100
FROM [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE to perform calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, AggregatePeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS AggregatePeopleVaccinated
FROM [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (AggregatePeopleVaccinated/population)*100 
FROM PopvsVac

-- Using Temp Table to perform calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AggregatePeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS AggregatePeopleVaccinated
FROM [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent is not null


SELECT *, (AggregatePeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS AggregatePeopleVaccinated
FROM [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

