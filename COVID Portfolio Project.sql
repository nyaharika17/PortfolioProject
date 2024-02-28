select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- Looking at Total cases vs Total Deths
--Shows likelihood of dying if you cntract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DethPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1, 2

--Looking at Total Cases Vs Populations
-- Shows what percentagee of Population got Covid

select location, date, population, total_cases,  (total_cases/population)*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1, 2


--Looking at countries with highest infection rate compared to populations

select location, population, max(total_cases) as HighetsInfectionCout, max((total_cases/population))*100 as 
PrecentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PrecentPopulationInfected desc

--Showing countries with Highest Deth count per Populations

select location, MAX(cast(total_deaths as int)) as TotalDethCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDethCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT




-- Showing continent with the hights deth count per population

select continent, MAX(cast(total_deaths as int)) as TotalDethCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDethCount desc


--GLOBAL NUMBERS

select sum(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DethPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1, 2


-- Looking at total population vs total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE

create table #PrecentPopulationVaccenated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
insert into #PrecentPopulationVaccenated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PrecentPopulationVaccenated


--Creating view to store data for later visualitions

create view PrecentPopulationVaccenated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select *
from PrecentPopulationVaccenated