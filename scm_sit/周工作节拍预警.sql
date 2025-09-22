-- 《工作节拍配置表》
select * from dp_work_cycle_configuration ;

-- 《周计划工作节拍完成进度表》
select plan_version,last_update_date,last_updated_account,t.* from dp_work_pace_schedule t
    where plan_version = (select max(plan_version) from dp_work_pace_schedule);

-- 权限配置
select * from cfg_parameter where param_name = 'DATA_ALERT_ADMIN' ;

select dimension2 from cfg_parameter where param_name = 'DATA_ALERT_ADMIN';


select * from scm_sit_platform.iam_user
where login_name is not null and real_name is not null
# and email not like '%@%'
  and login_name = 'ex_liujin.wei';


select * from iam_user
where login_name is not null and real_name is not null and login_name = 'ex_liujin.wei' ;
-- @tcl.com

select  * from  dp_pi1so2_open_cbu;
select t.inner_po_no,t.inner_po_item_no,etd_demand_date,inner_po_overdue_flag,t.*
from dp_pi1so2_open_cbu t order by inner_po_no,inner_po_item_no  ;

select pi_no,inner_po_item_no,demand_date from dp_inner_po_integration where pi_no is not null ;


/*
https://confluence.tclking.com/pages/viewpage.action?pageId=433756076
更新
*/
select a.inner_po_no,
       a.inner_po_item_no,
       a.etd_demand_date,
       a.inner_po_overdue_flag,
       CASE
           -- 首先判断：是否 >= 本周周一
           WHEN a.etd_demand_date >= DATE_SUB(CURDATE(), INTERVAL (WEEKDAY(CURDATE())) DAY) THEN 0
           -- 如果否，再判断：是否 >= 本月1号
           WHEN a.etd_demand_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01') THEN 2
           -- 如果上述两个条件都不满足
           ELSE 1
           END AS inner_po_overdue_flag_F,
       b.demand_date
from dp_pi1so2_open_cbu a
         join dp_inner_po_integration b
              on a.inner_po_no = b.pi_no and a.inner_po_item_no = b.inner_po_item_no
                     and a.etd_demand_date <> b.demand_date
order by a.inner_po_no, a.inner_po_item_no;


select * from dp_pi1so2_open_cbu where inner_po_no in ('PIKT01241111001','PIKT01250210003')
                                   and inner_po_item_no in ('1272793','1347287')  order by inner_po_no,inner_po_item_no;

select eta_demand_date,etd_demand_date,inner_po_overdue_flag from dp_pi1so2_open_cbu where inner_po_no = 'PIKT01241111001' ;

update dp_pi1so2_open_cbu set eta_demand_date='2025-09-17',etd_demand_date='2025-09-17',inner_po_overdue_flag=1 where inner_po_no='PIKT01241111001';

select demand_date,t.* from dp_inner_po_integration t where pi_no='PIKT01241111001' and inner_po_item_no='1272793' ;


/*编辑视图dp_inner_po_integration里的需求时间，通过视图里的pi_no关联 oms_prodt_notice_header_mst的pi_no，然后再关联行表*/
select t.* from oms_prodt_notice_line_mst t where po_no in (
    select po_no from oms_prodt_notice_header_mst where pi_no in ('PIKT01241111001')
    )  order by po_no;



select multi_delivery_flag,t.* from oms_prodt_notice_line_mst t where t.po_no = 'PIKT01241111001'

/*CASE
                     WHEN `pnl`.`multi_delivery_flag` = 'Y' THEN STR_TO_DATE(
                             REPLACE(`opnld`.`request_delivery_date`, '-', ''), '%Y%m%d')
                     ELSE STR_TO_DATE(REPLACE(`pnl`.`request_delivery_date`, '-', ''),
                                      '%Y%m%d') END)                                                  AS `demand_date`,*/