Basic Select
https://www.hackerrank.com/domains/sql/select/1

/*Revising the Select Query I*/
select * from city where population>100000 and CountryCode='USA';


/*Revising the Select Query II*/
select name  from city where population >120000 and CountryCode ='USA';


/*Select All*/
select * from city;

/*Select By ID*/
select * from city where id= 1661;

/*Japanese Cities' Attributes*/
select * from city where COUNTRYCODE ='JPN';


/*Japanese Cities' Names*/
select name from city where COUNTRYCODE ='JPN';

/*Weather Observation Station 1*/
select city,state from station;

/*Weather Observation Station 3*/
select distinct  city from station where mod(id , 2) = 0 order by city;

/*Weather Observation Station 4*/
select count(city) - count(DISTINCT city) as N from Station;

/*Weather Observation Station 5*/

ORACLE:
select city,LENGTH(city) from station where city=
(select * from (select city from station where LENGTH(city)=(select min(LENGTH(city)) from station) order by city) WHERE ROWNUM=1) or city=
(select * from (select city from station where LENGTH(city)=(select max(LENGTH(city)) from station) order by city) WHERE ROWNUM=1);
/*select city,length_city from (select a.*, rownum r from (select length(city) length_city,city from station order by length_city, city) a) where r in (1,(select count(*) from station));*/


select small.a,b from (select city a,length(city) b from station order by b, a)small where rownum=1 
union 
select big.a,b from (select city a , length(city)b from station order by b desc ,a desc)big where rownum=1;

MySQL
/*select CITY, length(CITY)from station order by length(CITY), city limit 1; 
select CITY, length(CITY)from station order by length(CITY) desc, city limit 1;*/


select city,length(city) from (select city , length(city) from station order by length(city),city limit 1) as b 
union all 
select city,length(city) from (select city , length(city) from station order by length(city) desc,city limit 1) as d



/*Weather Observation Station 6*/
select DISTINCT city from station where regexp_like(upper(city), '^(A|E|I|O|U)');
--select DISTINCT city from station where city like 'A%' or city like 'E%' or city like 'I%' or city like 'O%' or city like 'U%';


/*Weather Observation Station 7*/
ORACLE:
--select distinct city from station where regexp_like(city,'(a|e|i|o|u)$');
select distinct city from station where substr(city,LENGTH(city),1) in ('a','e','i','o','u');

MS slq
select distinct  city from station where upper(city) like '%[A|E|I|O|U]';


MySQL
select distinct city from station where city REGEXP  '(a|e|i|o|u)$';


/*Weather Observation Station 8*/
ORACLE
--select distinct city from station where regexp_like(lower(city),'^(a|e|i|o|u).*(a|e|i|o|u)$');
--select distinct city from station where substr(lower(city),LENGTH(city),1) in ('a','e','i','o','u') and substr(lower(city),1,1) in ---('a','e','i','o','u');
MSSQL
select distinct city from station where lower(city) like '[a|e|i|o|u]%' and lower(city) like '%[a|e|i|o|u]';
MySQL/*select distinct city from station where city regexp '^(a|e|i|o|u).*(a|e|i|o|u)$';*/
select distinct city from station where substr(lower(city),1,1) in ('a','e','i','o','u') and substr(lower(city),LENGTH(city),1) in ('a','e','i','o','u');


/*Weather Observation Station 9*/
select distinct city from station where regexp_like(lower(city),'^[^aeiou]');
--select distinct city from station where substr(lower(city),1,1) not in ('a','e','i','o','u');


/*Weather Observation Station 10*/
ORACLE
select distinct city from station where regexp_like(lower(city),'[^aeiou]$');
MSSQL
select distinct city from station where lower(city) like '[^aeiou]';
MySQL
select distinct city from station where lower(city) regexp'[^aeiou]$';


/*Weather Observation Station 11*/
ORACLE
select distinct city from station where  REGEXP_LIKE (lower(City), '^[^aeiou]|[^aeiou]$');


/*Weather Observation Station 12*/
select distinct city from station where regexp_like(lower(city),'^[^aeiou].*[^aeiou]$');


/*Higher Than 75 Marks*/
ORACLE
select name from students WHERE marks > 75 order by substr(name,-3), ID ASC;
MySQL
select name from students where marks>75 order by substr(name,-3), id;
MSSQL
select name from students where marks>75 order by right (name,3),id;


