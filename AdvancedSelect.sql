Advanced Select Challenges
https://www.hackerrank.com/domains/sql/advanced-select

/*Type of Triangle*/
ORACLE,MySql,MSSQL



select 
    case 
        when ((A+B)<=C) or ((B+C)<=A) or ((A+C)<=B) then 'Not A Triangle'
        when A=B and B=C and C=A  then 'Equilateral'
        when (A=B AND A<>C) OR (A=c AND B<>C ) THEN 'Isosceles'
        else 'Scalene'
    end
from TRIANGLES ;


/*The PADS*/

ORACLE
select name||'('||substr(occupation,1,1)||')'
from OCCUPATIONS
order by name;
select 'There are a total of '||count(*)||' '||lower(occupation)||'s.'
from OCCUPATIONS
group by occupation
order by count(*) asc,occupation;
  
MSSQL
select name+'('+substring(occupation,1,1)+')'
from OCCUPATIONS
order by name;
select 'There are a total of '+convert(varchar,count(*))+' '+lower(occupation)+'s.'
from OCCUPATIONS
group by occupation
order by count(*) asc, occupation;

  
  
MySql
select concat(name,'(',substring(occupation,1,1),')')
from OCCUPATIONS
order by name;
select concat('There are a total of ',count(*),' ',lower(occupation),'s.')
from OCCUPATIONS
group by occupation
order by count(*) asc, occupation;

  
  
/*Occupations*/ 
/*pivot and rank over example*/
[MEDIUM]

ORACLE
select d,p,s,a from
(
    select name,occupation,dense_rank() over (partition by occupation order by name) rnk from occupations
) sorce
pivot
(
    max(name) 
    for occupation 
    in ('Doctor' as d, 'Professor' as p, 'Singer' as s, 'Actor' as a)
)
order by rnk;


MSSQL

SELECT 
max(doctor),max(professor),
max(singer),max(actor)
FROM
    (SELECT 
     case occupation when 'Doctor' then name end as doctor,
     case occupation when 'Professor' then name end as professor,
     case occupation when 'Singer' then name end as singer,
     case occupation when 'Actor' then name end as actor,
     rank() over(partition by occupation order by name) as rank
    FROM Occupations) x
group by rank;

MySql

set @r1=0, @r2=0, @r3=0, @r4=0;
select min(Doctor), min(Professor), min(Singer), min(Actor)
from
  (select case when Occupation='Doctor' then (@r1:=@r1+1)
            when Occupation='Professor' then (@r2:=@r2+1)
            when Occupation='Singer' then (@r3:=@r3+1)
            when Occupation='Actor' then (@r4:=@r4+1) end as RowNumber,
    case when Occupation='Doctor' then Name end as Doctor,
    case when Occupation='Professor' then Name end as Professor,
    case when Occupation='Singer' then Name end as Singer,
    case when Occupation='Actor' then Name end as Actor
  from OCCUPATIONS
  order by Name) temp
group by RowNumber



/*Binary Tree Nodes*/
[MEDIUM]	

ORACLE,MySql,MSSQL
select
b3.n,
case 
    when b3.p is null then 'Root'
    when b4.counter>1 then 'Inner'
    else 'Leaf'
end
from bst b3
    left join 
        (select 
        b1.n as num,count(*) as counter
        from bst b1
            left join bst b2
                on b1.n=b2.p
        where b1.p is not null
        group by b1.n) b4
                on b3.n=b4.num
order by b3.n;	


--Next solution
ORACLE,MySql,MSSQL

SELECT 
    b2.n, 
case 
    when b2.p is null then 'Root'
    when (select count(*) from bst b1 where b1.p=b2.n)>0 then 'Inner'
    else 'Leaf'
end
FROM bst b2
order by b2.n;
--another solution
SELECT 
    b2.n, 
case 
    when b2.p is null then 'Root'
    when b2.n in (select b1.p from bst b1 ) then 'Inner'
    else 'Leaf'
end
FROM bst b2
order by b2.n;

--only MySql
SELECT N, 
IF(P IS NULL,'Root',IF((SELECT COUNT(*) FROM BST WHERE P=B.N)>0,'Inner','Leaf')) 
FROM BST AS B 
ORDER BY N;








