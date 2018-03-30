Aggregation ChallengesAggregation Challenges

https://www.hackerrank.com/domains/sql/aggregation


/*Revising Aggregations - Averages*/
select sum(population)/count(*) from city where district='California';


/*Average Population*/
select floor(sum(population)/count(*)) from city;

/*Population Density Difference*/
select max(population)-min(population) from city;

/*The Blunder*/
ORACLE
select ceil((sum(salary)/count(*))-((sum(to_number(replace(to_char(salary),'0'))))/count(*))) from EMPLOYEES;
MySql
select ceil((sum(salary)/count(*))-(sum(convert(replace(convert(salary,char),'0',''),signed))/count(*))) from EMPLOYEES;
MSSQL
select convert(int,ceiling(convert(float,sum(salary))/count(*)-(sum(convert(float,replace(CONVERT(char,salary),'0','')))/count(*))))  from EMPLOYEES; 


/*Top Earners*/
ORACLE
select *
from
    (select 
    e.salary*e.months, 
    (select count(*) from employee e1 where e1.salary*e1.months=e.salary*e.months)
    from employee e
    order by e.salary*e.months desc)
where rownum=1;

MySql
select 
e.salary*e.months, 
(select count(*) from employee e1 where e1.salary*e1.months=e.salary*e.months)
from employee e
order by e.salary*e.months desc
LIMIT 1;



MSSQL
select m,num
from
    (select 
    e.salary*e.months as m, 
    (select count(*) from employee e1 where e1.salary*e1.months=e.salary*e.months) as num,
    ROW_NUMBER() over(order by e.salary*e.months desc) as rnum
    from employee e) e2
where e2.rnum=1;



Another solution
select (salary * months)as earnings ,count(*) from employee group by 1 order by earnings desc limit 1;




