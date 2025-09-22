/* 关键物料风险承诺取数逻辑 */
select distinct material_no
from srm_fcst_commit_mst t
where material_no in (select km.material_no from sp_key_materials km where km.status = 1 and km.org_id = 'KT')
  and status in (select dimension1
                 from cfg_parameter
                 where param_name = 'KEY_MATERIAL_RISK_COMMITMENT_SRM_STATUS_FILTER_&_TRANSFORM'
                   and attr1 = 'Y') ;


-- 版本表
select * from version_master where biz_main_type = '1' and biz_sub_type = '101';

select max(version_id) from sp_key_material_risk_commitment_data ;
select *  from sp_key_material_risk_commitment_data order by creation_date desc limit 1;

-- 暂存表
select  * from sp_key_material_risk_commitment where material_code='95013-000022';
select * from srm_fcst_commit_mst where material_no='95013-000022';

select  * from sap_factory_material_mst where material_no='95013-000022' and factory_no in ('5500','5520') ;


-- 发布备份表
select *  from sp_key_material_risk_commitment_data order by creation_date desc ;



select status
from srm_fcst_commit_mst t where material_no = '92014-000980';


# update srm_fcst_commit_mst set status=5 where material_no ='92014-000927'


-- 供应商承诺和风险承诺
select site_code,
       date_format(period_date, '%Y%m') as month,
       sum(qty),
       case
           when qty_type = 1 then '供应商承诺'
           when qty_type = 2 then '风险承诺'
           else '其他'
           end                          as qty_type
from sp_key_material_risk_commitment_data
where version_id = (select id
                    from version_master
                    where biz_main_type = '1' and biz_sub_type = '101'
                    order by creation_date desc
                    limit 1)
  and qty_type in ('1', '2')
  and qty > 0
group by site_code, month, qty_type
order by site_code, month, qty_type;



-- 风险发布规则表
select * from sp_risk_commitment_publish_rule ;


select distinct site_code from sp_key_material_risk_commitment_data
union
select distinct factory_no from sp_factory_config ;


SELECT DISTINCT purchase_group FROM sap_purchase_group_mst ;

/*
 控制是否可编辑  跑job:870103初始化数据，param_value为1可编辑 ；跑JOB870102生成定版和备份数据param_value则置为0，不可编辑
*/
select  param_value  from cfg_parameter WHERE belong_domain='RSC_EDIT_CONTROL' ;

 select distinct param_value from cfg_parameter where param_name = 'KEY_MATERIAL_RISK_COMMITMENT_SRM_STATUS_FILTER_&_TRANSFORM' and attr1= 'Y';

select * from version_master where id = '1958008274507052363';
select * from version_master order by creation_date desc;

select t.*
from sp_key_material_risk_commitment_data t
where version_id =
      (select id from version_master where biz_main_type = 1 and biz_sub_type = '101' order by creation_date desc limit 1);

select * from version_master where biz_main_type = 1 and biz_sub_type = '101' order by creation_date desc limit 1 ;
select * from sp_key_material_risk_commitment ;
select distinct param_value from cfg_parameter WHERE param_name='RSC_PULISH_STATUS' ;
   select distinct param_value from cfg_parameter WHERE belong_domain='RSC_PULISH_STATUS' and attr1='Y' ;


select distinct param_value from cfg_parameter where param_name = 'KEY_MATERIAL_RISK_COMMITMENT_SRM_STATUS_FILTER_&_TRANSFORM' and attr1= 'Y' ;

select * from sap_factory_material_mst ;