--Project on Analysing Athletic events and Athletes
--Our Data
select * from athletes;
select * from athlete_events;	

--Creating a backup
select * into athletes_backup from athletes;
select * into athlete_events_backup from athlete_events;
--..............................................................................................................
--Exploring the dataset
--Getting only top 5 rows
select top 5* from athletes;
select top 5* from athlete_events;

--Different teams we have in our data
select distinct team from athletes;

--Different city we have in our data
select distinct city from athlete_events;

--Different sport we have in our data
select distinct sport from athlete_events;

--The duration of our dataset
select min(year) as minimum_year
,max(year) as maximum_year
from athlete_events;
-- so, we have data from 1896 to 2016

........................................................................................................
--Extracting Insights
-- Joining the table and saving a new table
Select * into table_name 
from athletes a
inner join athlete_events e on a.id = e.athlete_id;

select * from table_name

-- Querry to print which team has won the maximum gold medals over the years.
select top 1 team, count(case when medal = 'Gold' then medal end) as gold_medal_won
from table_name
group by team
order by count(case when medal = 'Gold' then medal end) desc

--Querry for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
With A as (select team, Count(case when medal = 'Silver' then medal end) as silver_medals,
year, rank() over( partition by team order by Count(case when medal = 'Silver' then medal end) desc) as rn
from table_name
group by team, year)
select team,sum(silver_medals) as total_silver_medals, max(case when rn=1 then year end) as  year_of_max_silver
from A
group by team;

--Querry for which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
select top 1 name, Count(case when medal = 'Gold' then medal end) as gold_medals
,Count(case when medal = 'Silver' then medal end) as silver_medals
,Count(case when medal = 'Bronze' then medal end) as bronze_medals
from table_name
group by name
having Count(case when medal = 'Gold' then medal end) >0
and Count(case when medal = 'Silver' then medal end) = 0 
and Count(case when medal = 'Bronze' then medal end)= 0
order by Count(case when medal = 'Gold' then medal end) desc

--In each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
With A as (select year, name, Count(case when medal = 'Gold' then medal end) as gold_medals
, rank() over(partition by year order by Count(case when medal = 'Gold' then medal end) desc) as rn
from table_name
group by year, name)
Select year, string_agg(name, ',') as players_name, gold_medals
from A
where rn = 1
group by year, gold_medals
order by year

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
With A as (select medal, year, event, sport
, rank() over( partition by medal order by year) as rn
from table_name
where team = 'India' and medal ! = 'NA')
select distinct * from A
where rn = 1

--6 find players who won gold medal in summer and winter olympics both.
select name, Count (distinct season) as summer_winter_both
from table_name
where medal = 'Gold'
group by name
having Count (distinct season) = 2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select year, name
from table_name
where medal ! ='NA'
group by year, name
having count(distinct medal)= 3
order by year

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with A as (select name, event, year 
from table_name
where medal = 'Gold' and year > 2000 and season ='Summer'
group by name, year, event)
, B as ( select *, lag(year,1) over(partition by name, event order by year) as previous_year
, lead (year,1) over(partition by name, event order by year) as next_year
from A)
select *
from B
where year = previous_year + 4 and year = next_year - 4

--...............................................................................................................................