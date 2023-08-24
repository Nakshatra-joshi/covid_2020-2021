select * from coviddeaths;

select * from coviddeaths
where continent is not null
order by 3,4;

select * from covidvaccinations
order by 3,4;

select location , date , total_cases , new_cases, total_deaths , population
from coviddeaths
order by 1,2;

-- looking at total cases vs total deaths

select location , date , total_cases ,  total_deaths , (total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
where location like '%states%'
order by 1,2;

-- looking at total_cases vs population 

select location ,date ,total_cases , population , (total_cases/population)*100 as deathpercentage
from coviddeaths
where location like '%india%' and  continent is not null
order by 1,2;

-- looking at countries with highest infection rate compared to population 

select location  , population , max(total_cases)as highestinfectioncount , max((total_cases/population))*100 as percentagepopulationinfected
from coviddeaths
where continent is not null
group by location,population
order by percentagepopulationinfected desc;

-- showing countries with  highest death count per population

select location  ,  max(total_deaths)  as toatldeathcount
from coviddeaths
where continent is not null
group by location
order by toatldeathcount desc; 

-- lets break things down by continent

select continent  ,  max(total_deaths)  as toatldeathcount
from coviddeaths
where continent is not null
group by continent
order by toatldeathcount desc; 

-- showing contintents with the highest death count per population 

select continent  ,  max(total_deaths)  as toatldeathcount
from coviddeaths
where continent is not null
group by continent
order by toatldeathcount desc; 

-- global numbers

select date , sum(new_cases) as total_cases , sum(new_deaths) as total_deaths ,sum(new_deaths) / sum(new_cases)* 100 as  deathpercentage 
from coviddeaths
where continent is not null
group by date 
order by 1,2;

-- looking at toatl population vs vaccination

select dea.continent , dea.location ,dea.date , dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by  2,3;


-- use CTE 

with popvsvac (continent , location , date , population , new_vaccination, rollingpeoplevaccinated)
as
(
select dea.continent , dea.location ,dea.date , dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * ,(rollingpeoplevaccinated/population)*100
from popvsvac;

-- TEMP TABLE

drop table if exists percentpopulationvaccinated;
create table percentpopulationvaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
);
 
INSERT INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

select * ,(rollingpeoplevaccinated/population)*100
from percentpopulationvaccinated;

-- creating views to store data for later visualizations

create view percentpopulationvaccinated_1 as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

select* from percentpopulationvaccinated_1;


