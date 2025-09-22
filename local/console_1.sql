select * from students;


select id, area, stu_type, sum(score) score
from students
group by grouping sets ((id, area, stu_type), (id, area), id)
order by id, area, stu_type;


--                 EXTRACT(MONTH FROM (ADD_MONTHS(SYSDATE, v3))),
select EXTRACT(MONTH FROM (ADD_MONTHS(SYSDATE, 2))) from dual;


