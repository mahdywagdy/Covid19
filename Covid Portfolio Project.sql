select *
from CovidDeaths
where continent is not  null 
order by 3,4

--select data that we are goning to be   using 

select location,date,total_cases,new_cases,total_deaths,population

from CovidDeaths
order by 1,2

--looking at Total cases vs Total deaths 

select location,date,total_cases,total_deaths ,(total_deaths/total_cases)*100 as "Death percentage"
from CovidDeaths
where location like 'Egypt'
order by 1,2

--looking at Total cases vs population
--show what percentage of population got covied
select location,date, population ,total_cases,(total_cases/ population)*100 as "Death percentage"
from CovidDeaths
where location like 'Egypt'
order by 1,2

--Countries with Highest Infection Rate compared to Population

select location, population ,MAX(total_cases) as "Highest Infection Count " ,MAX((total_cases/ population))*100 as " percentage Population Infection"
from CovidDeaths
--where location like 'Egypt'
group by location,  population
order by " percentage Population Infection" desc 



-- Countries with Highest Death Count per Population

select location,Max(cast( total_deaths as int)) as "Total Death Count"
from CovidDeaths
--where location like 'Egypt'
where continent is not  null 
group by location
order by "Total Death Count" desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent,Max(cast( total_deaths as int)) as "Total Death Count"
from CovidDeaths
--where location like 'Egypt'
where continent is not null 
group by continent
order by "Total Death Count" desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
--convert= cast 

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert ( int,cv.new_vaccinations )) over (partition by cd.location order by cd.location,cd.date)
as RollingPeopleVaccinated
-- ( "RollingPeopleVaccinated"/population)*100
from CovidDeaths CD join CovidVaccinations CV
on cd.location= CV.location and
cd.date=cv.date 
where cd.continent is not null 
order by 2,3 

--use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 