
-- ex_liujin.wei@tcl.com
select * from scm_pre_platform.iam_user
where login_name is not null and real_name is not null
# and email not like '%@%'
  and login_name = 'ex_liujin.wei';

select * from cfg_parameter where param_name = 'DATA_ALERT_ADMIN' ;
select * from dp_work_cycle_configuration ;


-- 《工作节拍配置表》
select * from dp_work_cycle_configuration ;

-- 《周计划工作节拍完成进度表》
select plan_version,last_update_date,last_updated_account,t.* from dp_work_pace_schedule t
    where plan_version = (select max(plan_version) from dp_work_pace_schedule);