/****************** RTF版本分析 ****************** /

/*版本号 取值校验*/
with v_no as (
    select distinct concat(version_no,'终版') as version_no,creation_date  from sop_rtf_detail_upload where rtf_version_no like '%SYSTEM%'
    union
    select distinct concat(version_no,'初版') as version_no,creation_date from sop_first_version_rtf_detail
)
select version_no,creation_date from v_no order by creation_date desc ;


/*销售组织取值*/
SELECT bu_name,bg_name,rbc_name,region_name,country_name_cn FROM scm_market_org;


/*要货模式取值*/
select require_goods_mode_code from dp_require_goods_mode ;

/*制造工厂和需求工厂的取值*/
select factory_no,factory_desc from sp_factory_config ;

select distinct version_no from sp_order_header_weekly_snapshot;
select * from sp_order_item_weekly_snapshot;


select  version_no,order_no,order_line_no from sop_first_version_rtf_detail order by version_no desc;

select  version_no,order_no,order_line_no from sp_order_header_weekly_snapshot order by version_no desc;
select  version_no,order_no,order_line_no ,promise_date,closed_qty from sp_order_item_weekly_snapshot
                                                      where order_no='OZLZ2402E6' and version_no='202505281836'
                                                      order by version_no desc;



select distinct rtf_version_no from sop_rtf_detail_upload order by rtf_version_no desc;

select iws.order_no, iws.order_line_no, iws.promise_date, iws.closed_qty
from sp_order_header_weekly_snapshot hws
         join (select distinct ORGNUM from SOP_HIS_MID_MDS_FCSTORDER where dmd_type = 'ODF') mf
              on hws.order_no = mf.orgnum
         join sp_order_item_weekly_snapshot iws
              on hws.order_no = iws.order_no
where hws.version_no = '202505281836' ;







select *
from sp_order_header_weekly_snapshot hws
where exists(select 1 from SOP_HIS_MID_MDS_FCSTORDER mf where hws.order_no = mf.orgnum and dmd_type = 'ODF') ;





select * from version_master order by creation_date desc ;
select distinct substr(version_no,1,8) from sop_rtf_detail_upload where version_no is not null order by version_no desc ;

select YEARWEEK('20250914');

select  (left(version_no,8)) from sp_order_header_weekly_snapshot group by version_no;

select  yearweek(left(version_no,8)) from sp_order_header_weekly_snapshot group by version_no;
select  * from sp_order_header_weekly_snapshot order by creation_date desc ;


select version_no from sp_order_header_weekly_snapshot group by version_no;




/*******************************************************************************************/
select * from sp_turn_prodt_result_for_rtf order by creation_date desc ;
select * from sp_order_header_for_rtf order by creation_date desc ;
select * from sp_order_item_for_rtf order by creation_date desc ;
select * from sop_first_version_rtf_detail order by creation_date desc ;
select * from sop_first_version_rtf_detail_wide order by creation_date desc ;
select * from sop_week_commitment_plan_detail_report order by creation_date desc ;
select * from sop_week_commitment_plan_detail_report_wide order by creation_date desc ;

select * from sp_turn_prodt_result where pt_plan_version='2025-09-15发布版';
select distinct pt_plan_version from sp_turn_prodt_result order by pt_plan_version desc ;
select * from sp_turn_prodt_result_for_rtf ;
select * from sop_his_mid_mds_fcstorder ;

-- 终版主计划 导入权限配置
select * from cfg_parameter where param_name ='IMPORT_PUBILSH_PERMISSION' and attr1 like  '%ex_liujin.wei%';

-- 开关配置是否可以导入初版主计划历史版本数据
select * from cfg_parameter where param_name = 'SWITCH_RTF_HISTORY_IMPORT' ;

select * from sop_rtf_detail_import order by creation_date desc;
select distinct version_no from sop_rtf_detail_upload order by last_update_date desc;
select distinct version_no from sop_rtf_detail_upload where version_no='20250932KTOP01';

select * from sop_first_version_rtf_detail order by creation_date desc ;

# update sop_rtf_detail_upload set version_no='20250925KTOP01' where version_no='20250132KTOP01';

select count(1) from sop_first_version_rtf_detail_wide where version_no='20250916KTOP01';

select * from version_master order by creation_date desc limit 4;

/*1、[sp_turn_prodt_result]取最大发布版本到[sp_turn_prodt_result_for_rtf];
2、清洗[sp_turn_prodt_result_for_rtf].<relation_id>不在[sop_his_mid_mds_fcstorder].<orgnum>记录；*/
select t.relation_id,t.abnormal_type_code, t.* from sp_turn_prodt_result t where pt_plan_version = (select pt_plan_version
                                                              from sp_turn_prodt_result
                                                              where pt_plan_version like '%发布版'
                                                              order by pt_plan_version desc
                                                              limit 1) and  ifnull(abnormal_type_code,'') =''
                                       and exists(select 1
                                                  from sop_his_mid_mds_fcstorder mmf
                                                  where t.relation_id = mmf.orgnum) ;

select * from sop_his_mid_mds_fcstorder order by creation_date desc ;

select * from sp_order_item_weekly_esp_snapshot ;

/*3、[sp_order_header_weekly_esp_snapshot]写入[sp_order_header_for_rtf]
	并清洗[sp_order_header_for_rtf].<order_no>不在[SOP_HIS_MID_MDS_FCSTORDER].<ORGNUM>中且DMD_TYPE='ODF'的记录*/
select *
from sp_order_header_for_rtf t
where exists(select 1 from SOP_HIS_MID_MDS_FCSTORDER mmf where DMD_TYPE = 'ODF' and t.order_no = mmf.ORGNUM) ;



select distinct version_no from sop_first_version_rtf_detail order by creation_date desc ;
select * from sop_rtf_detail_upload order by creation_date desc ;


select * from sop_first_version_rtf_detail where version_no = '20250924KTOP01' ;
select * from sop_first_version_rtf_detail where version_no = '20250917KTOP01' ;


select  * from version_master order by last_update_date desc limit 3 ;

select factory_no,factory_desc from sp_factory_config ;
select distinct bulk_require_goods_mode from sop_first_version_rtf_detail where version_no = '20250925KTOP01'
union
select distinct bulk_require_goods_mode from sop_rtf_detail_upload where version_no = '20250925KTOP01' ;


SELECT  yearweek(left('20250925KPOP01',8))  ;
SELECT  yearweek(left(version_no,8)) FROM sp_order_header_weekly_snapshot ORDER BY last_update_date DESC limit 1;
SELECT DISTINCT version_no FROM sp_order_item_weekly_snapshot ORDER BY last_update_date DESC ;

SELECT creation_date,t.* FROM sp_order_item_weekly_snapshot t where version_no = '202504301642' ;


SELECT * FROM sp_order_header_weekly_snapshot ORDER BY creation_date DESC ;





