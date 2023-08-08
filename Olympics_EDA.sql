-- 1)HOW MANY OLYMPICS GAMES HAVE BEEN HELD?

SELECT COUNT(DISTINCT GAMES) FROM olympics_history;

-- 2)LIST DOWN ALL OLYMPIC GAMES HELD SO FAR. Order the result by year.

SELECT DISTINCT GAMES FROM olympics_history;

-- 3)MENTION THE TOTAL NO OF NATIONS WHO PARTICIAPTED IN EACH OLYMPIC GAMES? Order the results by games.

-- SELECT COUNT(DISTINCT REGION) FROM olympics_history_noc_regions

SELECT DISTINCT GAMES,COUNT(DISTINCT REGION) 
FROM olympics_history OH JOIN olympics_history_noc_regions OHR 
ON OH.NOC=OHR.NOC
GROUP BY GAMES
ORDER BY GAMES;

-- Instead of using NOC for countries , used Region which is in another table. 
-- Since NOC is not accurate representation of country but region is.

-- 4)WHICH YEAR HAS THE HIGHEST AND LOWEST NO OF PARTICIPATING COUNTRIES IN OLYMPICS

WITH CTE AS 
(SELECT DISTINCT GAMES,COUNT(DISTINCT REGION) AS REGION_COUNT
FROM olympics_history OH JOIN olympics_history_noc_regions OHR 
ON OH.NOC=OHR.NOC
GROUP BY GAMES
ORDER BY GAMES)
SELECT DISTINCT
CONCAT(FIRST_VALUE(GAMES) OVER (ORDER BY REGION_COUNT),'-',FIRST_VALUE(REGION_COUNT) OVER (ORDER BY REGION_COUNT)),
CONCAT(FIRST_VALUE(GAMES) OVER (ORDER BY REGION_COUNT DESC),'-',FIRST_VALUE(REGION_COUNT) OVER (ORDER BY REGION_COUNT DESC))
FROM CTE;

-- 5) WHICH COUNTRY HAS PARTICIPATED IN ALL THE OLYMPIC GAMES
WITH CTE AS
(
SELECT DISTINCT OHR.REGION,COUNT(DISTINCT OH.GAMES) AS GAMES_COUNT FROM olympics_history OH 
JOIN olympics_history_noc_regions OHR ON OH.NOC=OHR.NOC
GROUP BY OHR.REGION
ORDER BY GAMES_COUNT DESC) 

SELECT * FROM CTE WHERE GAMES_COUNT = ALL(SELECT MAX(GAMES_COUNT) FROM CTE);

-- 6) IDENTIFY THE SPORT WHICH HAS PLAYED IN ALL SUMMER OLYMPICS

WITH CTE1 AS
	(SELECT COUNT(DISTINCT GAMES) TOTAL_SUMMER_GAMES FROM olympics_history WHERE SEASON='Summer'),
CTE2 AS
	(SELECT DISTINCT SPORT,GAMES FROM olympics_history WHERE SEASON='Summer'),
CTE3 AS
	(SELECT SPORT,COUNT(GAMES) AS GAME_COUNT FROM CTE2 GROUP BY SPORT)
	
SELECT * FROM CTE3 JOIN CTE1 ON CTE1.TOTAL_SUMMER_GAMES = CTE3.GAME_COUNT
ORDER BY GAME_COUNT DESC;

-- 7)WHICH SPORTS WERE PLAYED ONLY ONE IN THE OLYMPICS

WITH CTE1 AS 
(SELECT SPORT,COUNT(DISTINCT GAMES) D_GAMES FROM olympics_history GROUP BY SPORT),
CTE2 AS(
SELECT DISTINCT GAMES,SPORT FROM olympics_history
)
SELECT CTE1.SPORT,MIN(GAMES) GAME,COUNT(1) AS GAME_COUNT
FROM CTE2 JOIN CTE1 ON CTE1.SPORT=CTE2.SPORT
WHERE D_GAMES=1
GROUP BY CTE1.SPORT HAVING COUNT(1)=1;

-- 8) Fetch the total no of sports played in each olympic games.

SELECT DISTINCT GAMES, COUNT(DISTINCT SPORT) SPORT_COUNT FROM olympics_history
GROUP BY GAMES
ORDER BY SPORT_COUNT DESC;

-- 9)Top 5 athletes who have won the most gold medals. Order the results by gold medals in descending.

select Name, Team,count(Medal) as total_gold_medals
    from olympics_history 
    where Medal='Gold'
    group by Name,team
    order by total_gold_medals desc limit 5

-- 10)Top 5 athletes who have won the most medals (gold/silver/bronze). Order the results by medals in descending.

with CTE as (
    select name , team , count(medal) as Total_medal, dense_rank() over(order by count(medal) desc) as rnk
    from olympics_history
    where medal in ('Gold','Silver','Bronze')
    group by name,team
    order by Total_medal desc)
    
select name,team,Total_medal 
from CTE limit 5
	
-- 11) Top 5 most successful countries in olympics. Success is defined by no of medals won.

select region, count(Medal), dense_rank() over (order by count(Medal) desc) as rnk
from olympics_history oh 
join olympics_history_noc_regions ohr on oh.noc=ohr.noc
where oh.medal in ('Gold','Silver','Bronze')
group by region limit 5
	
-- 12) In which Sport/event, India has won highest medals.
select sport,count(medal) as medals_count
from olympics_history oh 
where team='India' and medal in ('Gold','Silver','Bronze')
group by sport
order by medals_count desc limit 1
	
-- 13) Break down all olympic games where india won medal for Hockey and how many medals in each olympic games and order the result by no of medals in descending.

select Team,sport,games,count(medal) as medal_count 
from olympics_history 
where Medal!='Medal-less' and team='India' and sport ='Hockey'
group by games,sport,team
order by medal_count desc

-- 14) 8.Fetch oldest athlete to win a gold medal

select * from (
    select Name, Sex, Age, Team, Games, City, Sport, Event, Medal,rank() over(order by age desc) rnk 
    from olympics_history where Medal='Gold') x
    where x.rnk=1 
