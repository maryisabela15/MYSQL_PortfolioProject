/*
  Project 1: Covid 19 Data Exploration

  Tables used: CovidDeaths and Covid Vaccinations

  Skill used: Aggregate Functions, Converting Data Types, Joins, CTE's, Temporary Tables, Crteating Views

  Language used: MySQL
*/


-- Exploring Data

SELECT *
FROM PortafolioProject.CovidDeaths;

SELECT *
FROM PortafolioProject.CovidVaccinations;


-- Select Data that I'm going to analize

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortafolioProject.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY Location;


-- Looking Total Deaths over Total Cases

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS TotalDeathsPercentage
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY Location, TotalDeathsPercentage;


-- Looking Total Cases over Population
-- What percentage of population got covid?

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY Location;


-- Looking at Countries with the Highest Infection Rate compare to Population

SELECT Location, population, MAX(total_cases) AS HighInfection, 
	   MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;


-- Looking for the Countries with the Highest Death Count per Population
-- I have to change the datatype for total_death to int(signed)

SELECT Location, MAX(cast(total_deaths as signed)) AS TotalDeathCount
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- 2) I WANT TO ANALIZE THE DATA IN FUNCTION OF CONTINENT

-- Looking the Highest Death Count Per Continent/Country

SELECT Continent, Location, MAX(cast(total_deaths as signed)) AS TotalDeathCount
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent, Location
ORDER BY TotalDeathCount DESC;


-- Looking the Total New Cases Per Day

SELECT date, SUM(new_cases) AS TotalNewCases
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 2;


-- Looking the Total New Deaths Per Day

SELECT date, SUM(cast(new_deaths as signed)) AS TotalNewDeaths
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 2;


-- Looking the Total New Cases, New Deaths, and the Percentage of New Deaths over New Cases per Day

SELECT date, SUM(new_cases) AS TotalNewCases, 
             SUM(cast(new_deaths as signed)) AS TotalNewDeaths,
             SUM(cast(new_deaths as signed))/SUM(new_cases)*100 AS PercentageNewDeaths
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY PercentageNewDeaths;


-- Looking the Total Cases, Deaths, and the Percentage of Deaths over Cases per Continent

SELECT Continent, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as signed)) AS TotalDeaths,
	   SUM(cast(new_deaths as signed))/SUM(new_cases)*100 AS PercentageDeaths
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY PercentageDeaths;


-- Lookinf Values around the World

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as signed)) AS TotalDeaths,
	   SUM(cast(new_deaths as signed))/SUM(new_cases)*100 AS PercentageDeaths
FROM PortafolioProject.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY PercentageDeaths;



/* SECOND PART: LOOKING FOR DATA FROM TABLE CovidVaccinations */

SELECT *
FROM PortafolioProject.CovidVaccinations;


-- Looking for the Total of New Test and Total Test Per Country

SELECT distinct location, SUM(cast(new_tests as signed)) AS TotalNewTest,
       SUM(cast(total_tests as signed)) AS TotalTest        
FROM PortafolioProject.CovidVaccinations
GROUP BY location
ORDER BY 2 DESC;


     
-- Looking at Total Population over Vaccinations Per Country
-- Join 2 tables based on date and location
-- We use PARTITION BY to separate the Total Vaccinations per Country

SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
       SUM(cast(Vac.new_vaccinations as signed)) OVER 
       (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinations
FROM PortafolioProject.CovidDeaths AS Death
JOIN PortafolioProject.CovidVaccinations as Vac
     ON Death.date = Vac.date AND Death.location = Vac.location
WHERE Death.continent IS NOT NULL
ORDER BY 1,2,3;    


-- Create a CTE to perform calculation in previous query

WITH RollPeople (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinations) 
AS
(SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
       SUM(cast(Vac.new_vaccinations as signed)) OVER 
       (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinations
FROM PortafolioProject.CovidDeaths AS Death
JOIN PortafolioProject.CovidVaccinations as Vac
     ON Death.date = Vac.date 
     AND Death.location = Vac.location
WHERE Death.continent IS NOT NULL
ORDER BY 1,2,3
)
SELECT *,(RollingPeopleVaccinations/Population)*100 AS PercentageRollingPeople
FROM RollPeople;


-- Create a Temporary Table to perform calculation in previous query

CREATE TEMPORARY TABLE PortafolioProject.PercentPopulationVaccinated
(Continent nvarchar(150),
Location nvarchar(150),
Date text,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinations numeric);

INSERT INTO PortafolioProject.PercentPopulationVaccinated
SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
       SUM(cast(Vac.new_vaccinations as signed)) OVER 
       (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinations
FROM PortafolioProject.CovidDeaths AS Death
JOIN PortafolioProject.CovidVaccinations as Vac
     ON Death.date = Vac.date 
     AND Death.location = Vac.location
WHERE Death.continent IS NOT NULL;

SELECT *,(RollingPeopleVaccinations/Population)*100 AS PercentageRollingPeople
FROM PortafolioProject.PercentPopulationVaccinated;



-- Creating View to store data for Visualization

CREATE VIEW PortafolioProject.PercentPopulationVaccinated AS
SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
       SUM(cast(Vac.new_vaccinations as signed)) OVER 
       (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinations
FROM PortafolioProject.CovidDeaths AS Death
JOIN PortafolioProject.CovidVaccinations as Vac
     ON Death.date = Vac.date 
     AND Death.location = Vac.location
WHERE Death.continent IS NOT NULL
ORDER BY 1,2,3
