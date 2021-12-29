Select *
From CovidProject..CovidDeaths
where continent is not null
order by 3,4


--Select *
--From CovidProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
where continent is not null
order by 1,2

-- Total cases vs total deaths
-- Likelihood of death due to Covid in Canada

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%Canada%'
order by 1,2

-- Total cases vs population
-- Percentage of population that were tested positive for covid

Select Location, date, total_cases, Population, (total_cases/Population)*100 as InfectedPercentage
From CovidProject..CovidDeaths
Where location like '%Canada%'
order by 1,2

-- Highest Infection Percentage
Select Location, MAX(total_cases) as HighestInfectionCount, Population, MAX((total_cases/Population))*100 as 
InfectedPercentage
From CovidProject..CovidDeaths
--Where location like '%Canada%'
Group by Location, Population
order by 4 desc

-- Countries with highest deaths per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeaths
From CovidProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null
Group by Location
order by 2 desc

-- Continents with highest deaths per population
Select location, MAX(cast(total_deaths as int)) as TotalDeaths
From CovidProject..CovidDeaths
Where continent is null and location not like '%income%'
Group by location
order by TotalDeaths desc

--Total deaths based on income
Select location, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(total_cases) as total_cases, ((MAX(cast(total_deaths as int)))/MAX(total_cases))* 100
as DeathPercentage
From CovidProject..CovidDeaths
--Where location like '%Canada%'
Where continent is null and location  like '%income%'
Group by location
order by DeathPercentage desc

-- Highest Infection Percentage by income
Select Location, MAX(total_cases) as HighestInfectionCount, Population, MAX((total_cases/Population))*100 as 
InfectedPercentage
From CovidProject..CovidDeaths
Where continent is null and location  like '%income%'
Group by Location, Population
order by HighestInfectionCount desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
--Group By date
order by 1,2


-- Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, convert(bigint, vac.new_vaccinations) as new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, convert(bigint, vac.new_vaccinations) as new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From popvsVac

--Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, convert(bigint, vac.new_vaccinations) as new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


--Create view for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, convert(bigint, vac.new_vaccinations) as new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
