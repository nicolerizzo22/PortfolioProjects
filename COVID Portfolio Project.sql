SELECT *
FROM PortfolioProject.dbo.CovidVaccinations_csv
ORDER BY 3,4

SELECT *
FROM PortfolioProject.dbo.CovidDeaths_csv
ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths_csv
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in a specific country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths_csv
WHERE location like '%states%'
ORDER BY 1,2;


--Looking at Total Cases vs Population
--Shows what percentage of the population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopInfected
FROM PortfolioProject..CovidDeaths_csv
--WHERE location like '%states%'
ORDER BY 1,2;


--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopInfected
FROM PortfolioProject..CovidDeaths_csv
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopInfected desc;


--Showing countries with highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths_csv
--WHERE location like '%states%'
WHERE continent IS NOT null
GROUP BY location
ORDER BY TotalDeathCount desc;


--LET'S BREAK THINGS DOWN BY CONTINENT 
--Showing continents with the highest death count per population
--(this script is correct but for visualization purposes will use 'WHERE continent IS NOT NULL' and group by continent)

--SELECT location, MAX(total_deaths) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths_csv
--WHERE location like '%states%'
--WHERE continent IS null
--GROUP BY location
--ORDER BY TotalDeathCount desc;

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths_csv
--WHERE location like '%states%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount desc;

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM (new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths_csv
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths_csv dea
JOIN PortfolioProject..CovidVaccinations_csv vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths_csv dea
JOIN PortfolioProject..CovidVaccinations_csv vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 as TotalPercentPeopleVacc
FROM PopvsVac

--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations INT,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths_csv dea
JOIN PortfolioProject..CovidVaccinations_csv vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS CurrentPercentPopulationVacc
FROM #PercentPopulationVaccinated;

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths_csv dea
JOIN PortfolioProject..CovidVaccinations_csv vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

\