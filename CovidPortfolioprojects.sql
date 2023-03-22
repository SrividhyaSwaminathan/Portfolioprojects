/*
Covid19 Data Exploration
Skills :JOINS,Aggregate Functions,Creating Views,Temp Tables,Data Type Conversion,CTE
*/



select * from
PortfolioProject..CovidDeaths
order by 3,4

--select * from
--PortfolioProject..CovidVaccinations
----order by 3,4

-- Select the Data that we are going to start with
select location,date,total_cases,new_cases,total_deaths,population
from
PortfolioProject..CovidDeaths


--Total Death Percentage
select location,date,Population,total_deaths,(total_deaths/population)*100 AS Death_percentage
from
PortfolioProject..CovidDeaths
----where location like '%states%'
order by 1,2


--Total Cases Vs Total Population
--Shows what percentage of people are infected with COVID
select location,Population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
from
PortfolioProject..CovidDeaths
GROUP BY population,location
order by PercentPopulationInfected desc



--Countries with Highest Death count per population
select location,MAX(cast(total_deaths as int)) AS Total_DeathCount
from
PortfolioProject..CovidDeaths
where continent is NOT NULL
GROUP BY location
order by Total_DeathCount DESC

-- Showing contintents with the highest Death count per population
select continent,MAX(cast(total_deaths as int)) AS Total_DeathCount
from
PortfolioProject..CovidDeaths
where continent is NOT NULL
GROUP BY continent
order by Total_DeathCount DESC

--Global numbers
select SUM(new_cases) AS TotalCases,sum(cast(new_deaths as int)) AS TotalDeaths,sum(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from
PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths  Dea JOIN 
PortfolioProject..CovidVaccinations  Vac ON
Dea.location=Vac.location AND
Dea.date=Vac.date
where dea.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

	WITH PopvsVacc (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
	as
	(
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths  Dea JOIN 
	PortfolioProject..CovidVaccinations  Vac ON
	Dea.location=Vac.location AND
	Dea.date=Vac.date
	where dea.continent is not null
	--ORDER BY 2,3
	)
	select *,(RollingPeopleVaccinated/population)*100 from PopvsVacc


-- Using Temp Table to perform Calculation on Partition By in previous query


	DROP table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
	(Continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	Rollingpeoplevaccinated numeric)
	
	insert into #PercentPopulationVaccinated
		select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths  Dea JOIN 
	PortfolioProject..CovidVaccinations  Vac ON
	Dea.location=Vac.location AND
	Dea.date=Vac.date
	--where dea.continent is not null
	--ORDER BY 2,3
	select *,(RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated
	
	
	
	-- Creating View to store data for later visualizations


	Create View PercentPopulationVaccinated as
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths  Dea JOIN 
	PortfolioProject..CovidVaccinations  Vac ON
	Dea.location=Vac.location AND
	Dea.date=Vac.date
	where dea.continent is not null
	--ORDER BY 2,3

	select * from PercentPopulationVaccinated
