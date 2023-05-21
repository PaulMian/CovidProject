select * from PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 3, 4

select location, date, total_cases, new_cases, total_deaths,population 
from PortfolioProject.dbo.CovidDeaths$
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you get covid in your country
select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1, 2

--shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
where location like '%states%'
order by 1, 2

--looking at countries with highest infection rate compared to population
select location, population,  Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
--where location like '%states%'
group by Location, Population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing Continents with highest death count per population

select location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc



--GLOBAL NUMBERS


select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum
(New_Cases)*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group By date 
order by 1, 2


--looking at total population vs vaccinations

With PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2, 3
)
select * from PopvsVac
--USE CTE


--temp table

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) 
 as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by  2, 3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
