Basic Join
https://www.hackerrank.com/domains/sql/join

/*Asian Population*/

ORACLE,MySql,MSSQL

select sum(c1.population)
from city c1 join country c2
on c1.countrycode=c2.code
where c2.CONTINENT='Asia' ;


/*African Cities*/

ORACLE,MySql,MSSQL

select c1.name
from city c1 join country c2
on c1.CountryCode = c2.Code 
where  c2.CONTINENT='Africa';


/*Average Population of Each Continent*/

ORACLE,MySql,MSSQL

select c2.continent,floor(sum(c1.population)/count(*))
from city c1 join country c2
on c1.CountryCode = c2.Code 
group by c2.continent;


/*The Report*/
[MEDIUM LEVEL]

ORACLE,MySql,MSSQL
select 
    case when g.grade<8 then 'NULL'
    else s.name 
    end,
g.grade,s.marks
from students s join grades g
on s.marks>=g.min_mark and s.marks<=g.max_mark
order by g.grade desc,s.name,s.marks;




/*Top Competitors*/
[MEDIUM LEVEL]
ORACLE,MySql,MSSQL

--FIRST SOLUTION
select s1.hacker_id as id,h.name as name
from Submissions s1 
    join Challenges c1
        on s1.challenge_id=c1.challenge_id
    join Difficulty d
        on d.difficulty_level=c1.difficulty_level
    join Hackers h
        on s1.hacker_id=h.hacker_id
where d.score=s1.score 
having count(*)>1
group by s1.hacker_id,h.name
order by count(*) desc, s1.hacker_id;

--SECEND SOLUTION
    select  s.hacker_id, h1.name
    from submissions s 
    join Hackers h1
    on s.hacker_id=h1.hacker_id
    where s.score=
        (select d.score
         from Difficulty d
         where d.Difficulty_level=
         (select c.Difficulty_level 
          from Challenges c
          where c.challenge_id=s.challenge_id) )
    group by s.hacker_id,h1.name
    having count(*)>1
    order by count(*) desc,s.hacker_id asc;
	
/*Challenges*/
[MEDIUM LEVEL]
ORACLE,MySql,MSSQL


select h.hacker_id as id,h.name as name,count(*) as count from hackers h join challenges c on h.hacker_id=c.hacker_id 
group by h.name,h.hacker_id 
having count(*) in 
(select count from 
 ((select count,count(*) from 
   (select h.hacker_id as id,h.name as name,count(*) as count from hackers h join challenges c on h.hacker_id=c.hacker_id 
group by h.name,h.hacker_id) 
   group by count having (count(*)>1 and count=
                          (select max(id) from 
                           (select count(hacker_id) as id from Challenges  group by hacker_id ) )) or count(*)=1))) 
  order by count(*) DESC,h.hacker_id;
  
  
  
/*Ollivander's Inventory*/
[MEDIUM LEVEL]
ORACLE,MySql,MSSQL



--solution 1
select s4.id, s3.age,s3.coins,s3.power
from
    (select s2.age as age,min(s1.coins_needed) as coins,s1.power as power
    from wands  s1
        join Wands_Property s2
            on s1.code=s2.code
    where s2.is_evil=0
    group by s2.age,s1.power) s3
    join wands s4
        on s4.coins_needed=s3.coins and s4.power=s3.power and s4.code=(select s5.code from wands_property s5 where s5.age=s3.age)
order by s3.power desc,s3.age desc;
--solution 2
select w.id, p.age, w.coins_needed, w.power 
from Wands as w 
    join Wands_Property as p 
        on (w.code = p.code) where p.is_evil = 0 
        and w.coins_needed = 
			select min(coins_needed) 
			from Wands as w1 
				join Wands_Property as p1 
				on (w1.code = p1.code) 
			where w1.power = w.power and p1.age = p.age) 
order by w.power desc, p.age desc


/*Contest Leaderboard*/
[MEDIUM LEVEL]
ORACLE,MySql,MSSQL




select s.h_id,h.name, sum(s.max)
from
    (select hacker_id as h_id,challenge_id as c_id, max(score) as max
    from Submissions s
    group by hacker_id,challenge_id) s
        join hackers h
            on s.h_id=h.hacker_id
group by s.h_id,h.name
having sum(s.max)>0
order by sum(s.max) desc,s.h_id;
