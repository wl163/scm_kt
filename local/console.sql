-- 字符串拼接
select 'A'||'B'||'C' from dual;
-- 数字截取
select trunc(100.345) from dual;
-- 日期截取
select trunc(sysdate) from dual;
select trunc(sysdate,'mm') from dual;
select trunc(sysdate,'yyyy') from dual;



select sysdate from dual;
select add_months(sysdate,2) from dual;
select last_day(sysdate) from dual;
select 111 from dual;
select to_char(111) from dual;

-- decode 条件判断
select decode(220,1,1,200,4,900) from dual;

-- 行转列
select b.name as                                           区域,
       sum(case when a.month = '01' then MONEY else 0 end) 一月,
       sum(case when a.month = '02' then MONEY else 0 end) 二月,
       sum(case when a.month = '03' then MONEY else 0 end) 三月,
       sum(case when a.month = '04' then MONEY else 0 end) 四月,
       sum(case when a.month = '05' then MONEY else 0 end) 五月,
       sum(case when a.month = '06' then MONEY else 0 end) 六月,
       sum(case when a.month = '07' then MONEY else 0 end) 七月
from T_ACCOUNT a
         left join T_AREA b on a.AREAID = b.id
where a.YEAR='2012'
group by b.name, a.year;


/* 分析函数*/
-- 值相同 排名相同 序号跳跃
select rank() over (order by USENUM desc) 排名,USENUM from T_ACCOUNT t;
-- 值相同 排名相同 序号连续
select dense_rank() over (order by USENUM desc) 排名, USENUM from T_ACCOUNT t;
-- 序号连续 不管值是否相同
select row_number() over (order by USENUM desc) 排名, USENUM from T_ACCOUNT t;

-- 用row_number() 做分页
select *
from (select row_number() over (order by USENUM desc) rownumber, USENUM from T_ACCOUNT) t
where t.rownumber > 10
  and t.rownumber <= 20;


/*集合运算*/
-- 并集去重
select * from T_OWNERS where id > 5
union
select * from T_OWNERS where id < 8;

-- 并集不去重
select * from T_OWNERS where id > 5
union all
select * from T_OWNERS where id < 8;

-- 交集
select * from T_OWNERS where id > 5
intersect
select * from T_OWNERS where id < 8;

-- 差集 （第一个结果集中减去交集）
select * from T_OWNERS where id > 5
minus
select * from T_OWNERS where id < 8;

-- 用minus实现分页
select * from T_ACCOUNT where id <= 20
minus
select * from T_ACCOUNT where id <= 10;


-- 序列 oracle没有自增，需要用序列做自增
create sequence seq_01;
select seq_01.nextval from dual;
insert into T_AREA values (seq_01.nextval,'测试');


create sequence seq_02
    increment by 10 -- 每次递增10
    start with 10 -- 从10开始
    maxvalue 100; -- 最大值100

select seq_02.nextval from dual;

create sequence seq_04
    increment by 10 -- 每次递增10
    start with 10 -- 从10开始
    minvalue 5
    maxvalue 200 -- 最大值100
    cycle;

select seq_04.nextval from dual;





