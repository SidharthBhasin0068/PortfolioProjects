
use CovidDeathsANDVaccinations


select *
from [CovidDeaths$]
where continent is not null
order by 3,4


--select *
--from [CovidVaccinations$]
--order by 3,4


--select the data that we are going to use

select location,date,total_cases,new_cases,total_deaths,population
from [CovidDeaths$]
where continent is not null
order by 1,2;

--looking at total cases and total deaths 
select location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as Death_percentage
from [CovidDeaths$]
where location like '%india%'
and continent is not null
order by 1,2 
 
--looking at total cases vs population
--shows what eprcentage of population got covid
select location,date,population,total_cases, (total_cases/population)*100 as percentpopulationinfected
from [CovidDeaths$]
--where location like '%india%'
order by 1,2 

--looking at countries with highest infection rate compared to populatuion
select location,population,max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentpopulationinfected
from [CovidDeaths$]
--where location like '%india%'
group by location,population
order by percentpopulationinfected desc


--countries with highest death per population
select location,max(cast(total_deaths as int )) as TotalDeathCount
from [CovidDeaths$]
--where location like '%india%'
where continent is not null
group by location,population
order by  TotalDeathCount desc


--Breaks things down by continent
--showing the continents with the highest death count per popution 
select continent,max(cast(total_deaths as int )) as TotalDeathCount
from [CovidDeaths$]
--where location like '%india%'
where continent is not   null
group by continent
order by  TotalDeathCount desc


--global numbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int )) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases )*100 as Death_percentage
from [CovidDeaths$]
--where location like '%india%'
where continent is not null
--group by date
order by 1,2



use CovidDeathsANDVaccinations

--usuage of second table with joins  (vacciantionincovid)

select *
from [CovidDeaths$] dea
join [CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date;


-- looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from [CovidDeaths$] dea
join [CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use of cte
with popvsvac (continent,location,date,population,new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from [CovidDeaths$] dea
join [CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100
from popvsvac


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric

)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from [CovidDeaths$] dea
join [CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *,(Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated


use CovidDeathsANDVaccinations

--create first view
create view percentpopulationvaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from [CovidDeaths$] dea
join [CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3