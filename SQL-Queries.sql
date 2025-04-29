-- Basic CovidDeaths Table view 
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- Looking at total cases Vs Total Deaths
-- Percentage of deaths if infected by covid 
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

-- Total Cases vs Population
-- Percentage of population infected with Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Worldwide impact of covid 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

-- Basic view of Covid Vaccination table 
Select * 
From CovidVaccinations


Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(cast(V.new_vaccinations as int)) OVER (Partition by D.Location order by D.Location, D.date) AS RollingPeopleVaccinated
From CovidDeaths as D
Join CovidVaccinations as V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
Order by 2, 3


-- CTE
With PopulVaccina (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(cast(V.new_vaccinations as int)) OVER (Partition by D.Location order by D.Location, D.date) AS RollingPeopleVaccinated
From CovidDeaths as D
Join CovidVaccinations as V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopulVaccina


-- Temp Table

DROP table if exists #PopulationVaccinated
Create Table #PopulationVaccinated 
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
) 

Insert into #PopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(cast(V.new_vaccinations as int)) OVER (Partition by D.Location order by D.Location, D.date) AS RollingPeopleVaccinated
From CovidDeaths as D
Join CovidVaccinations as V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PopulationVaccinated


