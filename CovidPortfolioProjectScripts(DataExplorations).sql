Select *
From CovidProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From CovidProject..CovidVaccinations
--Order By 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
--where location like '%cuba%'
Order By 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
--where location like '%cuba%'
Order By 1,2

--Looking at Countries with Highest Infection Rate to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
--where location like '%cuba%'
Group By location, population
Order By PercentPopulationInfected desc

--Showing the countries with Highest Death count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
--where location like '%cuba%'
Group By location
Order By TotalDeathCount desc

--By continent
--Showing continents with the highest death count per population

--Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
--From CovidProject..CovidDeaths
--Where continent is null
----where location like '%cuba%'
--Group By location
--Order By TotalDeathCount desc

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
--where location like '%cuba%'
Group By continent
Order By TotalDeathCount desc


--Global Numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
--where location like '%cuba%'
where continent is not null
--Group by date
Order By 1,2

--Looking total population vs vaccinations
--Using CTE

With PopVsVac (continent, location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,CONVERT(date,dea.date)) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/population)*100
From PopVsVac


--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,CONVERT(date,dea.date)) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated 

--Creating view for later visualizations

USE CovidProject
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,CONVERT(date,dea.date)) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
