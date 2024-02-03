SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4;


--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4;

-- SELECT Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contracted covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%ireland%'
order by 1,2 

-- Looking at total cases vs Population
-- What percetentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS covid_percentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%ireland%'
order by 1,2 

-- What countries have highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 AS covid_infected_percentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%ireland%'
GROUP By Location, population
order by covid_infected_percentage DESC

-- What countries have highest death count per population
SELECT Location, population, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
GROUP By Location, population
order by highest_death_count DESC

-- What countries have highest death rate compared to population
SELECT Location, population, MAX(cast(total_deaths as int)) as highest_death_count, MAX((cast(total_deaths as int)/population))*100 AS covid_death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
--WHERE location like '%ireland%'
GROUP By Location, population
order by covid_death_percentage DESC

-- Broken down by continent
-- Continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent is NULL
GROUP By location
order by highest_death_count DESC



-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%ireland%'
WHERE continent is not null
--GROUP BY date
order by 1,2 



-- Covid Vaccinations 

SELECT * 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Total Population vs Vaccinations
-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_pop_vaccinated)
as
(
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as rolling_pop_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (rolling_pop_vaccinated/population)*100 as vaccinated_percentage
FROM PopvsVac


-- Temp Table

DROP TABLE if exists #Percent_Pop_Vaccinated
CREATE TABLE #Percent_Pop_Vaccinated
(
Continent nVARCHAR(255),
Location nVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_pop_vaccinated numeric
)

INSERT INTO #Percent_Pop_Vaccinated
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as rolling_pop_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (rolling_pop_vaccinated/population)*100 as vaccinated_percentage
FROM #Percent_Pop_Vaccinated


-- Creating view to store data for later visualisations

CREATE View Percent_Pop_Vaccinated as
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as rolling_pop_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM Percent_Pop_Vaccinated