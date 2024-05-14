select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (replace states with your country)
Select Location, date, total_cases, total_deaths, (1.0*total_deaths/total_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (1.0*total_cases/Population)*100 AS Percent_Population_Infected
From PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((1.0*total_cases/Population))*100 AS Percent_Population_Infected
From PortfolioProject..CovidDeaths
--where location like '%states%'
group by Location, Population
order by Percent_Population_Infected DESC

-- Showing countries with Highest Death Count Per Population

Select Location, MAX(Total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location, Population
order by Total_Death_Count DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per popolutation

Select continent, MAX(Total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by Total_Death_Count DESC

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 1.0*SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 1.0*SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT * , (1.0*RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT * , (1.0*RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * FROM 
PercentPopulationVaccinated

