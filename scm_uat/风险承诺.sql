select * from cfg_parameter WHERE param_name='RSC_BUSINESS_TYPE' order by attr1 ;

SELECT * FROM cfg_parameter WHERE param_name like 'KEY_MATERIAL_RISK_COMMITMENT_DEFAULT_VALUE_CONFIG%' ;

SELECT * FROM srm_fcst_commit_mst ORDER BY creation_date DESC;

select * from sp_key_material_risk_commitment  order by creation_date desc ;

/*关建物料风险承诺发布表*/
select * from sp_key_material_risk_commitment_data ;

select qty_type,t.* from srm_fcst_commit_mst t
                    where  t.material_no = '92014-000980';

select * from sop_first_version_rtf_detail ;

select  dimension1,dimension2,dimension3,t.* from cfg_parameter t where param_name='PURCHASE_GROUP_CUSTOMIZE'

select qty_type,t.* from srm_fcst_commit_mst t where
material_no = '31101-002117_A' and supplier_code = '109294' ;

select last_update_date,t.* from srm_fcst_commit_mst t order by last_update_date desc;
select creation_date,t.* from srm_fcst_commit_mst t order by creation_date desc;


select * from srm_fcst_commit_mst t where qty_type in ('OD','OP','OC') order by creation_date desc ;



select distinct qty_type from srm_fcst_commit_mst t order by creation_date desc;
select  * from srm_fcst_commit_mst t  order by creation_date desc;



select * from sop_rtf_detail_upload ;

/* 关键物料风险承诺取数逻辑 */
select distinct purchase_group_code
from srm_fcst_commit_mst t
where t.material_no in
      (select km.material_no from sp_key_materials km where km.status = 1 and km.org_id = 'KT')
  and t.status in (select dimension1
                   from cfg_parameter
                   where param_name = 'KEY_MATERIAL_RISK_COMMITMENT_SRM_STATUS_FILTER_&_TRANSFORM'
                     and attr1 = 'Y') ;


/**/

select * from srm_fcst_commit_mst order by creation_date desc;
select * from sp_key_material_risk_commitment ;

select * from risk  ;



select *
from cfg_parameter where param_name = 'KEY_MATERIAL_RISK_COMMITMENT_DEFAULT_VALUE_CONFIG_1' and attr2= 'Y';

select distinct big_version from srm_fcst_commit_mst t order by big_version desc ;