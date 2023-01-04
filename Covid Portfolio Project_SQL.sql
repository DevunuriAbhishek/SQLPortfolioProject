
select * 
from [dbo].[CovidDeaths]
where continent is not null
order by 3,4

--select * 
--from [dbo].[CovidVaccinations] 
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from [dbo].[CovidDeaths]
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Took Location as India. It resulted in Total cases as 44680355 and Total Deaths as 530707. Death% as 1.19 as on 03.01.2023

select location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) as DeathPercentage
from [dbo].[CovidDeaths]
where location = 'India' and continent is not null
order by 1,2

-- Total Cases vs Population. Displays % of population infeceted with covid in India

select location,date,population,total_cases,round((total_cases/population)*100,2) as '% Of Population Infecetd With Covid'
from [dbo].[CovidDeaths]
where location = 'India' and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select location,population,max(total_cases) as HighestInfected,round(max((total_cases/population))*100,2) as '% Of Population Infecetd With Covid'
from [dbo].[CovidDeaths]
where continent is not null
group by location,population
order by 4 desc

-- Countries with Highest Mortality Count against Population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by location,population
order by TotalDeathCount desc

-- Continents with Highest Mortality Count against Population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by continent
order by TotalDeathCount desc

-- Across the World Cases Details

select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage
from [dbo].[CovidDeaths]
--where location = 'India' and continent is not null
where continent is not null
group by date
order by 1,2

--High Level Info of Covid world wide

select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage
from [dbo].[CovidDeaths]
--where location = 'India' and continent is not null
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccination across the world

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations )) over (partition by CD.location order by CD.location,CD.date) as VaccinationRunningTotal
from [dbo].[CovidDeaths] as CD
join [dbo].[CovidVaccinations] as CV
on CD.location=CV.location
and CD.date=CV.date
where cd.continent is not null -- and cd.location='India'
order by 2,3


-- CTE

with PopvsVac (Continent,location,date,population,new_vaccinations,VaccinationRunningTotal)

as
(

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations )) over (partition by CD.location order by CD.location,CD.date) as VaccinationRunningTotal
from [dbo].[CovidDeaths] as CD
join [dbo].[CovidVaccinations] as CV
on CD.location=CV.location
and CD.date=CV.date
where cd.continent is not null -- and cd.location='India'
--order by 2,3
)
select *, round((VaccinationRunningTotal/population)*100,2) as '%Vaccinated'
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationRunningTotal numeric
)


insert into #PercentPopulationVaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations )) over (partition by CD.location order by CD.location,CD.date) as VaccinationRunningTotal
from [dbo].[CovidDeaths] as CD
join [dbo].[CovidVaccinations] as CV
on CD.location=CV.location
and CD.date=CV.date
where cd.continent is not null -- and cd.location='India'
--order by 2,3

select *, round((VaccinationRunningTotal/population)*100,2) as '%Vaccinated'
from #PercentPopulationVaccinated


-- Creation of View

create view PercentPopulationVaccinated as 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations )) over (partition by CD.location order by CD.location,CD.date) as VaccinationRunningTotal
from [dbo].[CovidDeaths] as CD
join [dbo].[CovidVaccinations] as CV
on CD.location=CV.location
and CD.date=CV.date
where cd.continent is not null  and cd.location='India'
--order by 2,3

select *
from PercentPopulationVaccinated