select *
from [Olympics].[dbo].[athlete_events$]

select *
from [Olympics].[dbo].[noc_regions]



--Identify the sports which were played in all summer olympics


	select count(distinct games) as total_summer_games 
	from [Olympics].[dbo].[athlete_events$]
	where Season= 'summer'

with t2 AS
	(select distinct sport,games
	from [Olympics].[dbo].[athlete_events$]
	where Season= 'summer')

	select sport,count(games) as no_of_games
	from t2
	group by Sport
	having count(games) = 29
	

--fetch the top 5 athletes who have won the most gold medals

with t1 as (select top 20 Name, count(1) as total_gold_medals
	from [Olympics].[dbo].[athlete_events$]
	where medal = 'gold'
	group by name
	order by 2 desc)

select *, dense_rank() over (order by total_gold_medals desc) as rnk
from t1
where 2 <= 5;

--List down total gold, silver and bronze medals won by each country

select *
from [Olympics].[dbo].[athlete_events$]
where medal <> 'NA'

select *
from [Olympics].[dbo].[noc_regions]

select country,Bronze, gold, silver
from
(select nr.region as country, oh.Medal,count(2) as medals_won
from [Olympics].[dbo].[athlete_events$] oh
join [Olympics].[dbo].[noc_regions] nr
on oh.NOC= nr.NOC
group by nr.region, oh.medal) as t1

pivot( sum(medals_won) for[medal] in (Bronze,gold,silver)) as pv
order by gold desc
--Identify which country won the most gold, most silver and most bronze medals in each olympic

with CTE2 as(
select SUBSTRING(gamescountry,1,12)as games, SUBSTRING(gamescountry,12,15) as country,Bronze, gold, silver
from
(select concat(games,' ',nr.region) as gamescountry, oh.Medal,count(2) as medals_won
from [Olympics].[dbo].[athlete_events$] oh
join [Olympics].[dbo].[noc_regions] nr
on oh.NOC= nr.NOC
group by games,nr.region, oh.medal) as t1

pivot( sum(medals_won) for[medal] in (Bronze,gold,silver)) as pv
)

select distinct games, concat(FIRST_VALUE(gold) over(partition by games order by gold desc),'-',FIRST_VALUE(country) over(partition by games order by gold desc)) as gold,
concat(FIRST_VALUE(silver) over(partition by games order by silver desc),'-',FIRST_VALUE(country) over(partition by games order by silver desc)) as silver,
concat(FIRST_VALUE(bronze) over(partition by games order by bronze desc),'-',FIRST_VALUE(country) over(partition by games order by bronze desc)) as bronze
from CTE2
order by games
