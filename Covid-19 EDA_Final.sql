/*
COVID-19 EXPLORATORY DATA ANALYSIS PROJECT
Dataset publicly available on https://ourworldindata.org/covid-deaths

Skills used: 
Joins, CTE's 
Temp Tables 
Windows Functions 
Aggregate Functions 
Creating Views
Converting Data Types
*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT *
From [Covid-19]..Covid_Deaths

--Select data to use

SELECT Location, Date, total_cases, new_cases, total_deaths, population
From [Covid-19]..Covid_Deaths
order by 1,2


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Looking at Total Cases vs Total Deaths
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 As Death_Percentage
From [Covid-19]..Covid_Deaths
order by 1,2




--Total Cases vs Total Deaths (Shows probability of dying if Covid is contracted in a certain country)
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 As Death_Percentage
From [Covid-19]..Covid_Deaths
Where Location like 'Nigeria'
order by 1,2



--Total Cases vs Population (Shows what percentage of the population contracted Covid)
SELECT Location, Date, total_cases, population, (total_cases/population)*100 As PercentPopulationInfected
From [Covid-19]..Covid_Deaths
Where Location like '%states%'
order by 1,2


SELECT Location, Date, total_cases, population, (total_cases/population)*100 As PercentPopulationInfected
From [Covid-19]..Covid_Deaths
Where Location like 'Nigeria'
order by 1,2





--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 As PercentPopulationInfected
From [Covid-19]..Covid_Deaths
group by Location, Population
order by PercentPopulationInfected desc




--Showing Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From [Covid-19]..Covid_Deaths
Where Continent is not null
group by Location
order by TotalDeathsCount desc



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BREAKING DOWN BY CONTINENT

--Showing continent with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From [Covid-19]..Covid_Deaths
Where Continent is null
group by location
order by TotalDeathsCount desc


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
From [Covid-19]..Covid_Deaths
Where Continent is not null
group by continent
order by TotalDeathsCount desc




--- Global Outlook
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Covid-19]..Covid_Deaths
Where Continent is not null
group by date
order by 1,2


SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Covid-19]..Covid_Deaths
Where Continent is not null
--group by date
order by 1,2

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Total Population Vs Vaccinations


SELECT *
From [Covid-19]..Covid_Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date )
as RollingCountVacc
From Covid_Deaths dea
JOIN Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by  2, 3


-- Using CTE to perform Calculation on Partition By in above query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
	over (Partition by dea.location order by dea.location, dea.date )
	as RollingCountVacc
From Covid_Deaths dea
JOIN Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by  2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Using Temp Table to perform Calculation on Partition By in previous query
--create table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

SELECT * From #PercentPopulationVaccinated

--Populate table

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date )
as RollingPeopleVacc
From Covid_Deaths dea
JOIN Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by  2, 3)


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating Views to store data for possible visualizations


Create View TotalCases as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid-19]..Covid_Deaths
where continent is not null 
--order by 1,2



Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date )
as RollingPeopleVacc
From [Covid-19]..Covid_Deaths dea
JOIN [Covid-19]..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by  2, 3


Create view TotalDeaths_by_continent as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
From [Covid-19]..Covid_Deaths
Where Continent is not null
--group by continent
--order by TotalDeaths desc


Create view Highest_death_by_population as
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeaths
From [Covid-19]..Covid_Deaths
Where Continent is not null
--group by Location
--order by TotalDeaths desc


Create view Percent_of_population_US as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid-19]..Covid_Deaths
--Where location like '%states%'
--Group by Location, Population
--order by PercentPopulationInfected desc




Create view Infection_rate_by_population as
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 As PercentPopulationInfected
From [Covid-19]..Covid_Deaths
--group by Location, Population
--order by PercentPopulationInfected desc

Create view Total_Cases_vs_Population as
SELECT Location, Date, total_cases, population, (total_cases/population)*100 As PercentPopulationInfected
From [Covid-19]..Covid_Deaths
Where Location like '%states%'
--order by 1,2


Create View Total_Death_Count as
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid-19]..Covid_Deaths
Where continent is null 
--Group by location
--order by TotalDeathCount desc


--------------------------------------------------------------------------------------------------------------------------------------------------------------
--This concludes the EDA process. Data will be visualized on Tableau. Thank you!!







