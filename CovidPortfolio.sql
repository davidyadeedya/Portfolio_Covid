USE portfolio_project

--IMPORTING DATA 
SELECT *
FROM portfolio_project..CovidDeath$
WHERE location IS NOT NULL
ORDER BY 3,4


SELECT *
FROM portfolio_project..Covidvaccination$
ORDER BY 3,4




SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolio_project..CovidDeath$
--ORDER BY location,date

--Total Cases vs Total deaths
--Likelihood of dying when you contract covid in your country
SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_percetntage
FROM portfolio_project..CovidDeath$
WHERE location LIKE '%states%'
ORDER BY location,date

--Total cases vs population
--Shows what percentage pf population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 AS Percentage_infected0000000
FROM portfolio_project..CovidDeath$
WHERE location LIKE '%states%'
ORDER BY location,date



--Countries with Highest percentage of people infected
SELECT location,date,total_cases,population,(total_cases/population)*100 AS Percentage_infected
FROM portfolio_project..CovidDeath$
ORDER BY Percentage_infected0000000 DESC

--Countries with higest infection rate as compared to pupolation
SELECT location,MAX(total_cases) AS highest_infection_count,population,MAX((total_cases/population)*100 )AS Percentage_infected==
FROM portfolio_project..CovidDeath$
GROUP BY location,population
ORDER BY Percentage_infected DESC


--Countries with highestdeath count
SELECT location,MAX(total_deaths) AS Total_death_count, 
FROM portfolio_project..CovidDeath$
GROUP BY location
ORDER BY Total_death_count DESC

--Continents with the highest death count per population
SELECT continent,location,MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM portfolio_project..CovidDeath$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- Global Numbers

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)),SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100  AS Death_percentage--total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_percetntage
FROM portfolio_project..CovidDeath$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY SUM(new_cases),SUM(CAST(new_deaths AS INT))

USE portfolio_project
SELECT Cd.continent,Cd.location,Cd.date,Cd.population,Cv.new_vaccinations,SUM(CAST(Cv.new_vaccinations AS INT)) OVER (PARTITION BY Cd.location  ORDER BY Cd.location,Cd.date) AS Rolling_People_vaccinated
FROM CovidDeath$ Cd
JOIN Covidvaccination$ Cv
ON Cd.location=Cv.location
AND Cd.date=Cv.date
WHERE Cd.continent IS NOT NULL
ORDER BY 2,3


--CTE
WITH PopvsVac(continent,location,date,population,new_vaccinations,Rolling_People_vaccinated)
AS
(SELECT Cd.continent,Cd.location,Cd.date,Cd.population,Cv.new_vaccinations,SUM(CAST(Cv.new_vaccinations AS INT)) OVER (PARTITION BY Cd.location  ORDER BY Cd.location,Cd.date) AS Rolling_People_vaccinated
FROM CovidDeath$ Cd
JOIN Covidvaccination$ Cv
ON Cd.location=Cv.location
AND Cd.date=Cv.date
WHERE Cd.continent IS NOT NULL

)

SELECT *,(Rolling_People_vaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS  #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated

(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_vaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT Cd.continent,Cd.location,Cd.date,Cd.population,Cv.new_vaccinations,SUM(CONVERT(INT,Cv.new_vaccinations)) OVER (PARTITION BY Cd.location  ORDER BY Cd.location,Cd.date) AS Rolling_People_vaccinated
FROM CovidDeath$ Cd
JOIN Covidvaccination$ Cv
ON Cd.location=Cv.location
AND Cd.date=Cv.date
WHERE Cd.continent IS NOT NULL


SELECT *,(Rolling_People_vaccinated/population)*100
FROM #PercentagePopulationVaccinated

--Creating Data for later visualisations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT Cd.continent,Cd.location,Cd.date,Cd.population,Cv.new_vaccinations,SUM(CONVERT(INT,Cv.new_vaccinations)) OVER (PARTITION BY Cd.location  ORDER BY Cd.location,Cd.date) AS Rolling_People_vaccinated
FROM CovidDeath$ Cd
JOIN Covidvaccination$ Cv
ON Cd.location=Cv.location
AND Cd.date=Cv.date
WHERE Cd.continent IS NOT NULL

