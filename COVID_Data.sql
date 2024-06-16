SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

SELECT * FROM PortfolioProject..CovidVaccinations$
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where Location like 'Nepal'
order by 1,2;

--Looking at Total cases versus Population
--Shows what percentage of people got covid

SELECT location, date, population, total_cases, (total_cases/population)* 100 as CoronaPercentage
FROM PortfolioProject..CovidDeaths
Where Location like 'Nepal'
order by 1,2;

--Looking at continent with highest infection rate compared to population

SELECT continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as CoronaPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY continent, population
ORDER BY CoronaPercentage DESC;

----Looking at countries with highest death rate compared to population

SELECT location, MAX(cast(total_deaths as INT)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC;


-- Showing continents with highest death count


SELECT continent, MAX(cast(total_deaths as INT)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC;

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where Location like 'Nepal'
WHERE continent is not null
GROUP BY date
order by 1,2;

--AS Whole Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where Location like 'Nepal'
WHERE continent is not null
--GROUP BY date
order by 1,2;


--Looking at Total population vs Vaccinations




-- USE CTE

With popVSvac (Continent, Location, Date, Population,NEW_Vaccinations, Rolling_People_Vaccinated)
as 
(
 SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	and dea.date=vac.date
	WHERE dea.continent is not null
	--order by 2,3
	)
	SELECT *, (Rolling_People_Vaccinated/population)*100
	FROM popVSvac;



-- TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
 SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	and dea.date=vac.date
	--WHERE dea.continent is not null
	--order by 2,3

	SELECT *, (Rolling_People_Vaccinated/population)*100
	FROM #PercentPopulationVaccinated;



-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

	CREATE VIEW PercentPopulationVaccinated as
	 SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	and dea.date=vac.date
	WHERE dea.continent is not null
	--order by 2,3

	SELECT * FROM PercentPopulationVaccinated
