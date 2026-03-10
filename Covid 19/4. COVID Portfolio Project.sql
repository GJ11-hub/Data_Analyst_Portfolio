-- Covid Deaths and Vaccinations Data Analysis in 2020-2021

-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

Select *
From PortfolioProject..CovidVaccinations
order by 3, 4

-- Data that is going to be used for analysis

Select location, date, population, total_cases, new_cases, total_deaths
From PortfolioProject..CovidDeaths
Where population is not null
Order by 1,2


-- Total Cases vs Total Deaths
-- Likelihood of death based on total cases in your country

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where total_cases is not null
and location like '%Malay%'
Order by 1,2

-- Total Cases vs Population
-- Percentage of the population has been infected with Covid based on total cases in your country

Select location, date, population, total_cases,(total_cases/population)* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where population is not null
and location like '%Malay%'
Order by 1,2

-- Countries with the highest infection rates compared to population

Select location, population, max(total_cases) as HighestInfectionCountry,max((total_cases/population))* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where population is not null
Group by location, population
Order by 4 desc

-- Countries with the highest death count compared to population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by 2 desc

-- Breakdown by continent
-- Continent with the highest death count compared to population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by 2 desc

-- Global numbers

Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null

-- Combine Deaths and Vaccinations Data

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total population vs Vaccinations
-- Percentage of the population that has been vaccinated in your country

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.population is not null
Order by 2,3

-- Since 'RollingPeopleVaccinated' is a calculated column, it can't be directly used in the previous SELECT statement
-- Using Common Table Expression (CTE) or a subquery to perform calculation on Partition By in previous query.

With PopvcVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.population is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvcVac

-- Using Temp Table to perform calculation Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.population is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated

-- Create view to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.population is not null
