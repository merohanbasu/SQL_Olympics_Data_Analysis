create database if not exists olympics;
use olympics;

-- tables imported...

-- --------------query-------------

select * from athlete_events;
select * from noc_regions;


-- q1: How many olympics games have been held?
select count(distinct games) as total_number_olympic_games
from athlete_events;

-- q2: List down all Olympics games held so far.
select distinct games
from athlete_events
order by games;

-- q3: Mention the total no of nations who participated in each olympics game?
select count(distinct team) as total_no_of_nations
from athlete_events;

-- q4: Which year saw the highest and lowest no of countries participating in olympics?
with cts as 
	(select year, count(team) as total_number_of_countries
	from athlete_events
	group by year)
select max(total_number_of_countries) as Highest, min(total_number_of_countries) as Lowest
from cts;

-- q5: Which nation has participated in all of the olympic games?
select team, count(distinct games) as no_games_participated
from athlete_events
group by team
having no_games_participated = (select count(distinct games) from athlete_events);

-- q6: Identify the sport which was played in all summer olympics.
select * from athlete_events;

with t1 as
 	(select count(distinct games) as total_summer_games
     from athlete_events
     where season = "summer"),
t2 as
	(select distinct sport, games
	from athlete_events
	where season = "summer"
	order by games),
t3 as 
	(select sport, count(games) as no_of_games
    from t2
    group by sport)
select *
from t3
join t1
on t1.total_summer_games = t3.no_of_games;

-- q7: Which Sports were just played only once in the olympics?
with t1 as
	(select sport, count(distinct games) as no_of_games
	from athlete_events
	group by sport)
select sport
from t1
where no_of_games = 1;

-- q8: Fetch the total no of sports played in each olympic games
select distinct games, count(sport) as total_number_of_games
from athlete_events
group by games;

-- q9: Fetch details of the oldest athletes to win a gold medal.
select *
from athlete_events
where medal = "gold"
order by year
limit 1;

-- q10: Find the Ratio of male and female athletes participated in all olympic games.
with t1 as
	(select count(distinct name )as no_of_male_athlets
	from athlete_events
	where sex = "m"),
t2 as
	(select count(distinct name )as no_of_female_athlets
	from athlete_events
	where sex = "f")
select (no_of_male_athlets / no_of_female_athlets) as ratio
from t1, t2;

-- q11: Fetch the top 5 athletes who have won the most gold medals.
select name, count(medal) as no_of_medals
from athlete_events
where medal = "gold"
group by name
order by no_of_medals desc
limit 5;

-- q12: Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
select name, count(medal) as no_of_medals
from athlete_events
group by name
order by no_of_medals desc
limit 5;

-- q13: Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
select team, count(medal) as total_no_of_medals
from athlete_events
group by team
order by total_no_of_medals desc
limit 5;

-- q14: List down total gold, silver and broze medals won by each country.
select nr.region as country, medal, count(medal) as total_medals
from athlete_events ae
join noc_regions nr on nr.noc = ae.noc
where medal <> "NA"
group by country, medal
order by country; 

-- q15: List down total gold, silver and broze medals won by each country corresponding to each olympic games.
select games, nr.region as Country, medal, count(medal) as total_medals
from athlete_events as ae
join noc_regions as nr on nr.noc = ae.noc
where medal <> "NA"
group by games, country, medal
order by games;

-- q16: Identify which country won the most gold, most silver and most bronze medals in each olympic games.
with t1 as
	(select team, count(medal) as Most_gold_medals
	from athlete_events
	where medal = "Gold"
	group by team
	order by Most_gold_medals desc
	limit 1),
t2 as 
	(select team, count(medal) as Most_Silver_medals
	from athlete_events
	where medal = "Silver"
	group by team
	order by Most_silver_medals desc
	limit 1),
t3 as
	(select team, count(medal) as Most_bronze_medals
	from athlete_events
	where medal = "Bronze"
	group by team
	order by Most_bronze_medals desc
	limit 1)
select t1.team as Country_with_most_gold, t2.team as Country_with_most_silver, t3.team as Country_with_most_bronze
from t1, t2, t3;

-- q17: Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
WITH medal_counts AS (
    SELECT 
        games, 
        team,
        SUM(CASE WHEN medal = 'gold' THEN 1 ELSE 0 END) AS gold_count,
        SUM(CASE WHEN medal = 'silver' THEN 1 ELSE 0 END) AS silver_count,
        SUM(CASE WHEN medal = 'bronze' THEN 1 ELSE 0 END) AS bronze_count
    FROM 
        athlete_events
    WHERE 
        medal IN ('gold', 'silver', 'bronze')
    GROUP BY 
        games, team
)
SELECT 
    games,
    MAX(CASE WHEN gold_count = MAX_gold_count THEN team END) AS country_with_most_gold,
    MAX(CASE WHEN silver_count = MAX_silver_count THEN team END) AS country_with_most_silver,
    MAX(CASE WHEN bronze_count = MAX_bronze_count THEN team END) AS country_with_most_bronze
FROM (
    SELECT 
        games,
        team,
        gold_count,
        silver_count,
        bronze_count,
        MAX(gold_count) OVER (PARTITION BY games) AS MAX_gold_count,
        MAX(silver_count) OVER (PARTITION BY games) AS MAX_silver_count,
        MAX(bronze_count) OVER (PARTITION BY games) AS MAX_bronze_count
    FROM 
        medal_counts
) AS max_counts
GROUP BY 
    games;

-- a18: Which countries have never won gold medal but have won silver/bronze medals?
with t1 as 
	(select count(distinct team) as gold
	from athlete_events
	where medal = "gold"),
t2 as
	(select count(distinct team) as total
	from athlete_events)
select (t2.total - t1.gold) as countries_never_won_gold
from t1, t2;








   
























