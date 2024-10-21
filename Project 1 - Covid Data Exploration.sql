/* Covid 19- Data Exploration Project
SKills Used: Joins, Common Table Expressions's, Tem Tables, Window Functions, Agrregrate Functions, Creating Views, Converting Data TYpes*/

Use PortfolioProject1
Select * from CovidDeaths

Select count(*) from coviddeaths
Select * from CovidVaccinations

Select location, date, total_cases, new_cases, total_deaths, Population from Coviddeaths where total_deaths is not null
-- Total Cases versus total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
AS DeathPercentage from Coviddeaths where location like '%Canada%' order by location, date

--Select data that we are going to be using 
-- Looking at Total Cases Vs Total Deaths. Shows the likelyhood of dying if someone contracts covid in Canada 
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100
AS DeathPercentage from Coviddeaths where location like '%Canada%' and total_deaths is not null order by location, date 

-- Looking at Total Cases versus the population 

Select location, date, population, total_cases, (total_cases/Population)*100
AS CovidPercentage from Coviddeaths where location like '%Canada%'  order by location, date 

--Looking at countries at highest infection rate compared to population 

Select location, Population, MAX(Total_cases) AS HighInfection, MAX((total_cases/Population)*100) 
AS PercentPopulationInfected from Coviddeaths group by Location, Population order by location , population DESC

--Looking at countries at highest death count

Select location, MAX(Total_Deaths) AS DEATHCOUNT
from Coviddeaths group by Location order by DEATHCOUNT DESC

--Convert count total death to integer data type

Select location, MAX(Cast(Total_Deaths as int)) AS DEATHCOUNT
from Coviddeaths where continent is not null group by location order by DEATHCOUNT DESC
Delete from CovidDeaths

-- Look at the death counts of continent in descending order 

Select Continent, MAX(Cast(Total_Deaths as int)) AS DEATHCOUNT
from Coviddeaths where continent is not null group by continent order by DEATHCOUNT DESC
Delete from CovidDeaths

-- Showing continents with the highest death counts  per population 


-- Global Numbers of death percentage
Select date,Sum(new_cases) AS TotalCases, Sum(cast(New_deaths as int)) AS TotalDeaths, Sum(Cast(New_deaths as int))/Sum(New_cases)*100
As Deathpercent from Coviddeaths where continent is not null group by date order by date 

Select Sum(new_cases) AS TotalCases, Sum(cast(New_deaths as int)) AS TotalDeaths, Sum(Cast(New_deaths as int))/Sum(New_cases)*100
As Deathpercent from Coviddeaths where continent is not null

Select * from coviddeaths
Select * from CovidVaccinations


--Looking at Total Population Vs Vaccinations 

Select Cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
from coviddeaths AS CD JOIN Covidvaccinations AS CV on  cd.location = cv.location Order by 2

Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations from CovidDeaths 
AS CD JOIN Covidvaccinations AS CV on  cd.location = cv.location and cd.date=cv.date
where cd.continent is not null order by 2,3

--Rolling count for new vaccinations 

Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations, sum(Cast(cv.new_vaccinations as int)) OVER (Partition by cd.location, cd.date) 
as RollingPeopleVaccinated from CovidDeaths 
AS CD JOIN Covidvaccinations AS CV on  cd.location = cv.location and cd.date=cv.date
where cd.continent is not null order by 2,3

-- How much percentage of population were vaccinated?
--Using CTE (Learn about CTE's in SQLCommon table expressions) 

With PopVsVac ( Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS 
(
Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations, sum(Cast(cv.new_vaccinations as int)) OVER (Partition by cd.location, cd.date) 
as RollingPeopleVaccinated from CovidDeaths 
AS CD JOIN Covidvaccinations AS CV on  cd.location = cv.location and cd.date=cv.date
where cd.continent is not null --order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 from PopVsVac

-- Using temp table 

Drop table if exists #percentpopulationvaccinated
Create table #PPV
(
Continent  nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PPV
Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations, sum(Convert(float, cv.new_vaccinations)) 
OVER (Partition by cd.location order by cd.location,cd.date) 
as RollingPeopleVaccinated from CovidDeaths 
AS CD JOIN Covidvaccinations AS CV on  cd.location = cv.location and cd.date=cv.date
--where cd.continent is not null --order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 from #PPV

-- Creating view to store data for later visualizations

Create view VW_PPV
As
Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations, sum(Convert(float, cv.new_vaccinations)) 
OVER (Partition by cd.location order by cd.location,cd.date) 
as RollingPeopleVaccinated from CovidDeaths 
AS CD JOIN Covidvaccinations AS CV on  cd.location = cv.location and cd.date=cv.date
where cd.continent is not null 


Select * from VW_PPV