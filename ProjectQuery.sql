-- Select the data I will be using for doing the analysis.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE location <> continent
ORDER BY location, date 


-- Looking at total cases vs total deaths.
-- Shows likelihood of dying if you got infected by covid in your country
SELECT location, date, total_cases, total_deaths, FORMAT((total_deaths/total_cases),'P') AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Colombia' AND location <> continent
ORDER BY 1,2


-- Looking at the total cases vs the Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, FORMAT((total_cases/population),'P') AS percent_population_infected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Colombia' AND location <> continent
ORDER BY 1,2


-- Looking at which country had the highest infection rate
-- Shows what country had the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, FORMAT((MAX(total_cases/population)),'P') AS percent_population_infected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location <> continent
GROUP BY location, population 
ORDER BY percent_population_infected DESC




-- Looking at which country had the highest Death rate
-- Shows what country had the highest death rate compared to population
SELECT location, MAX(CAST(total_deaths AS int)) AS total_deaths_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE location <> continent
GROUP BY location 
ORDER BY total_deaths_count DESC


--Breaks things out by continent

-- Looking at which country had the highest Death rate
-- Shows what country had the highest death rate compared to population
SELECT continent, MAX(CAST(total_deaths AS int)) AS total_deaths_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY total_deaths_count DESC


--Breaks things out by continent

-- Showing Continents with the highest death count per population
SELECT continent,population, MAX(CAST(total_deaths AS int)) AS total_deaths_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY population, continent 
ORDER BY total_deaths_count DESC


-- GLOBAL FIGURES

SELECT date, SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS int)) AS total_deaths, FORMAT(SUM(CAST(new_deaths AS int))/SUM(new_cases),'P') AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2

--Looking at total population vs total vaccinations

SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int, vac.new_vaccinations )) OVER (partition by dea.location order by dea.location, dea.location, dea.Date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

with popvsvac (continent, 
			   location,
			   date,
			   population,
			   new_vaccinations,
			   rolling_people_vaccinated)
AS
(
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int, vac.new_vaccinations )) OVER (partition by dea.location order by dea.location, dea.location, dea.Date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT *, (rolling_people_vaccinated/population)*100 
FROM popvsvac



--TEMP TABLE
--PENDING.


-- Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.Date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


SELECT * FROM sys.objects WHERE name = 'PercentPopulationVaccinated';

