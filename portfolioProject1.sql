--Exploring the covid dataset 
select * 
from covidDeaths
where continent is not null
order by 3,4

--Exploring important fields
select location,date,total_cases,total_deaths,population 
from covidDeaths
where continent is not null
order by 1,2

--Total cases vs Total Deaths
--SHows the likelihood of dying if you contract the covid by country
select location,date,total_cases,total_deaths,(CONVERT(decimal(16,1),total_deaths)/CONVERT(decimal(16,1),total_cases))*100 as DeathPercentage 
from covidDeaths
where continent is not null
order by 1,2

select location,date,total_cases,total_deaths,(CONVERT(decimal(16,1),total_cases)/CONVERT(decimal(16,1),population))*100 as PopulationInfectedPercentage 
from covidDeaths
where continent is not null
order by 1,PopulationInfectedPercentage desc

-- Contries with Highest Infection Rate compared to Population
select location,population,Max(total_cases) as HighestInfectionCount,Max((CONVERT(decimal(18,0),total_cases)/CONVERT(decimal(18,0),population)))*100 as PercentagePopulationInfected --decmal 18 and 0 are default values
from covidDeaths
where continent is not null
group by location, population
order by PercentagePopulationInfected desc

--Countries with Highest Death Count Per Population
select location,population,Max(total_deaths) as HighestInfectionCount,Max((CONVERT(decimal(18,0),total_deaths)/CONVERT(decimal(18,0),population)))*100 as PercentagePopulationInfected --decmal 18 and 0 are default values
from covidDeaths
where continent is not null
group by location, population
order by PercentagePopulationInfected desc

select location,Max(cast(total_deaths as decimal(18,0))) as TotalDeathCount --decmal 18 and 0 are default values
from covidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Continents with the highest death count
select location,Max(cast(total_deaths as float)) as TotalDeathCount 
from covidDeaths
where continent='Asia'  --location<>'World'
group by location
order by location asc

--Continents with the highest death count
select continent,Max(cast(total_deaths as decimal(18,0))) as TotalDeaths
from covidDeaths
where continent is not null 
group by continent
order by TotalDeaths desc

select location,max(cast(total_deaths as decimal(18,0))) as totalDeaths
from covidDeaths 
where continent='Africa' 
group by location 
order by totalDeaths desc


select sum(cast(totalDeaths as decimal(18,0))) from (
select location,max(cast(total_deaths as decimal(18,0))) as totalDeaths
from covidDeaths 
where continent='Africa' and location<>'World'
group by location 
) africa 


select sum(cast(totalDeaths as decimal(18,0))) from (
select location,max(cast(total_deaths as decimal(18,0))) as totalDeaths, 
case 
when location is null then 'Africa'
else 'Africa'
end as contin
from covidDeaths 
where continent='Africa' and location<>'World'
group by location 
) africa 

select location,continent,total_cases,cast(total_deaths as decimal(18,0)) as totalDeaths from covidDeaths order by location asc

DROP TABLE IF EXISTS #covidDeathcleaned
Create table #covidDeathcleaned (
location varchar(100),
totalDeaths int ,
continent varchar(100),
)

--Insert into #covidDeathcleaned
--select location,max(cast(total_deaths as decimal(18,0))) as totalDeaths, 
--case 
--when location is null then 'Oceania'
--else 'Oceania'
--end as contin
--from covidDeaths 
--where continent='Oceania' and location<>'World'
--group by location 

select sum(totalDeaths) as TotalDeaths,continent from #covidDeathcleaned group by continent order by TotalDeaths desc

--select date,sum(cast(new_cases as decimal(25,2) )),sum(cast(new_deaths as decimal(25,2)))
--from covidDeaths 
--where continent is not null 
--group by date 
--order by date

--decimal(18,0)

select SUM(cast(new_cases as decimal(18,0))) as total_cases, SUM(CONVERT(decimal(22,8),new_deaths)) as total_deaths--,SUM(cast(new_deaths as decimal(18,0)))/SUM(cast(New_Cases as decimal(18,0)))*100 as DeathPercentage
from covidDeaths 
where continent is not null 
--group by date 
order by 1 asc 


--update covidDeaths set new_deaths=0 where new_deaths is null

select cast(new_cases as decimal(18,0)) as new_cases ,
case
when ISNUMERIC(new_deaths)=1 then cast(new_deaths as decimal(18))
else 0
end as new_deaths
from covidDeaths 
where continent is not null --and location<>'World'

DROP TABLE IF EXISTS #globalNumbers
Create table #globalNumbers (
new_cases int ,
new_deaths int ,
)

Insert into #globalNumbers
select cast(new_cases as decimal(18,0)) as new_cases,
case
when ISNUMERIC(new_deaths)=1 then cast(new_deaths as decimal(18))
else 0
end as new_deaths 
from covidDeaths 
where continent is null and location<>'World'

select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage  from #globalNumbers --order by new_cases desc 

select sum(cast(new_cases as decimal(18))) from covidDeaths where continent is null and location<>'World'

--Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations--, sum(cast(vac.new_vaccinations as decimal(18))) over (Partition by dea.location, dea.date)
from covidDeaths dea 
join covidVaccinations vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

DROP TABLE IF EXISTS #cleanedCovidData
Create table #cleanedCovidData (
continent varchar(100),
location varchar(100),
date date,
population float ,
new_vaccinations float ,
)

Insert into #cleanedCovidData
select dea.continent,dea.location,dea.date, case
when ISNUMERIC(dea.population)=1 then cast(dea.population as decimal(18))
else 0
end as deaPopulation, 
case
when ISNUMERIC(vac.new_vaccinations)=1 then cast(vac.new_vaccinations as decimal(18))
else 0
end as vacNewVacinations
from covidDeaths dea 
join covidVaccinations vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null --and dea.location='Canada'
order by 1,2,3

select *,sum(new_vaccinations) over (Partition by location order by location,date) as RollingPeopleVaccinated from #cleanedCovidData where population=0 order by 1,2,3
--Modified table with values converted and nulls removed 
Create table cleanedCovidData (
continent varchar(100),
location varchar(100),
date date,
population float ,
new_vaccinations float ,
)

insert into cleanedCovidData
select *from #cleanedCovidData 


update cleanedCovidData set population=1 where population=0

With PopvsVac (Continent, Location, Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as (

select *,sum(new_vaccinations) over (Partition by location order by location,date) as RollingPeopleVaccinated
from #cleanedCovidData
--order by 1,2,3
)
select *,(cast(RollingPeopleVaccinated as float)/Population)*100 
from PopvsVac

select location,date,people_fully_vaccinated,* from covidVaccinations 


drop view if exists PercentPopulationVaccinated 
create view PercentPopulationVaccinated as
select *,sum(new_vaccinations) over (Partition by location order by location,date) as RollingPeopleVaccinated from cleanedCovidData 

select * from PercentPopulationVaccinated





