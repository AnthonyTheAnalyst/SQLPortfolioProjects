
SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Select data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid 
SELECT location, date, population, total_cases,(total_cases/population)*100 as ContractionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infecction Reate compared to Population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null and location  not like '%inco%'
GROUP BY location
ORDER BY TotalDeathCount desc

-- Showing the continents with the highest death counts 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and location  not like '%inco%'
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS 

-- Death Percentage by Day 
SELECT date, SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total DeathPercentage
SELECT  SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Population vs Vaccination 
-- Different ways to do this 
-- Using a temp table get the percent of people vaccinated

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
Select *, (RollingPeopleVaccinated/population)*100
From  #PercentPopulationVaccinated


-- Using a CTE get the percent of people vaccinated
With PopvsVac (Continent, location,date,population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
From PopvsVac


--Creating View to store data for later visualizations 
Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select* 
From PercentPopulationVaccinated
