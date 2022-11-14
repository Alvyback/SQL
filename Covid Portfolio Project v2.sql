SELECT *
FROM [Portfolio Project]..CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA that we are going to be using: 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2							--ORDER BY 1,2 = refers to location and date as Columns 
										-- two dashes = comment out the selected lines 

-- Looking at Total Cases vs Total Deaths 

SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage --use brackets for calculation 
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%canada%'
ORDER BY 1,2	

-- highlight only the query to show that query, only.
-- Data shows the liklihood of dying contract covid in the US - 1.78% as of 2021-04-30


-- Looking at Total Cases vs Population

-- shows what percentage of the population got Covid
 SELECT location, date, population, total_cases, (Total_cases/population)*100 as PercentofPopulationInfected --use brackets for calculation 
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%canada%'
ORDER BY 1,2	

-- Looking at Countries with Highest Infection Rate compared to Population 

 SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc
-- order by name of table "MAX((total_cases/population))" = PercentPopulationInfected 

-- Countries with Highest Death count per population 

 SELECT location, MAX(cast(Total_Deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null 
GROUP BY location, population
order by TotalDeathCount desc

-- "cast": changes variable "Total_Deaths" to either int, numerical, float(approximate value) ...
-- "Where continent is not null" = data shows location as Asia when it should only be in continent
								 -- 'is not null' removes all NULL continents 


-- Break things down by continent 

 SELECT location, MAX(cast(Total_Deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
Where continent is null 
GROUP BY location
order by TotalDeathCount desc

-- WHERE continent is null = copies all null values which would have been missing 

-- Showing continent with the highest death count per population 

 SELECT continent, MAX(cast(Total_Deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null 
GROUP BY continent 
order by TotalDeathCount desc

-- Global Death Numbers 

 SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null 
GROUP BY date 
order by 1,2

-- Total Death Numbers 

 SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null 
order by 1,2


-- Now working on CovidVaccinations Table 

SELECT *
FROM [Portfolio Project]..CovidVaccinations
ORDER BY 3,4


-- a. Looking at total population vs vaccinations (total amount of ppl in the world who are vaccinated)

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated		-- OVER partition by dea.location = rolls up values to the next day (the order by is necessary to sum up values in accordance to the date and location)
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location					-- common link = location
	AND dea.date = vac.date 
where dea.continent is not null 
Order by 2,3

-- b. we want to find the total vaccinated versus the population (ex.Albania: rollingpeoplevaccination/population)
-- USING CTE = because rollingpeoplevaccinated can not be divided by population. Rolling... is just the name
-- make sure the number of inputs in CTE () are equal to the number of values in SELECT : continent/continent, location/location, date/date, pop/pop, new_vaccinations/new_vaccinations 
-- add Select * From PopvsVac at the end of query with brackets 

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated		-- OVER partition by dea.location = rolls up values to the next day (the order by is necessary to sum up values in accordance to the date and location)
--("RollingPeopleVaccinated"/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location					-- common link = location
	AND dea.date = vac.date 
where dea.continent is not null 
--Order by 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100 AS VaccinatedPerPop
FROM PopvsVac

-- TEMP Table 

Drop Table if exists #PercentPopulationVaccinated		-- drops existing table in the database 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),			-- nvarchar: stores 255 characters
location nvarchar(255),
Date datetime,						
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
) 

INSERT into #PercentPopulationVaccinated			
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated		-- OVER partition by dea.location = rolls up values to the next day (the order by is necessary to sum up values in accordance to the date and location)
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location					-- common link = location
	AND dea.date = vac.date 
where dea.continent is not null 
Order by 2,3
														-- INSERTING TABLE into Query 
INSERT into #PercentPopulationVaccinated			
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated		-- OVER partition by dea.location = rolls up values to the next day (the order by is necessary to sum up values in accordance to the date and location)
--("RollingPeopleVaccinated"/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location					-- common link = location
	AND dea.date = vac.date 
--where dea.continent is not null 
--Order by 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100 AS VaccinatedPerPop
FROM #PercentPopulationVaccinated	

--Creating View to store data for later vsiualizations 

Create View PercentPopulationVaccinated as											-- Create view saves query for later 
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated		-- OVER partition by dea.location = rolls up values to the next day (the order by is necessary to sum up values in accordance to the date and location)
--("RollingPeopleVaccinated"/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location					-- common link = location
	AND dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

SELECT *								-- using view table for other queries
FROM PercentPopulationVaccinated
