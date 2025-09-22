select bu_name,bg_name,rbc_name,region_name,t.* from scm_market_org t;

select t.* from scm_market_org t where t.brand_name='ODM' and country_code='AN';

select distinct bu_code from scm_market_org t
                        where (bg_code,brand_name) in (select distinct bg_code, brand_type from sp_order_header t where t.order_no='AZLS24002S');

select bu_name,bg_name,rbc_name,region_name,t.* from scm_market_org t where t.bu_code='04' AND country_code='AAC' ;

select * from sop_first_version_rtf_detail where version_no ='20250521KTOP01' and demand_code  ='FCST0000266'  and data_type=1;

select distinct bg_code, brand_type from sp_order_header t where t.order_no='AZLS24002S';

select * from sp_turn_prodt_result t where t.pt_plan_version='2025-05-12';
select * from sp_turn_prodt_process_detail t where t.pt_plan_version='2025-05-12';

select * from sop_week_commitment_plan_detail_report t where t.version_no='20250521KTOP01' and  ifnull(schedseqnum,'')<> ''
group by demand_type having count(schedseqnum)>1;
select original_parent_id,t.* from sop_week_commitment_plan_detail_report t where t.version_no='20250521KTOP01' and schedseqnum='64569';-- 105097
select t.demand_code,parent_id,t.original_parent_id,t.whole_in_out,t.data_type,qty,t.lt_qty,t.schedseqnum,t.*
from sop_week_commitment_plan_detail_report t where t.version_no='20250522KTOP01' and original_parent_id='562578' order by commit_group,data_type;

select t.demand_code,parent_id,t.original_parent_id,t.whole_in_out,t.data_type,qty,t.lt_qty,
       t.*
from sop_week_commitment_plan_detail_report_wide t where t.version_no='20250522KTOP01' and parent_id='FCST0000005'
and data_type in (1,3);

select a.parent_id,a.original_parent_id,a.original_demand_code,a.demand_code,c.scheddate,c.schedqty
from sop_week_commitment_plan_detail_report a
         left join sop_his_mid_mds_fcstorder b
                   on a.original_parent_id = b.orgnum
         left join sop_his_mid_mds_fcstorderstatus c on b.seqnum = c.seqnum
where a.version_no = '20250522KTOP01'
    and a.parent_id='AZLS25000N'
  and a.data_type = 3
  and a.is_parent = 'Y';


select t.demand_code,parent_id,t.original_parent_id,t.whole_in_out,t.data_type,qty,t.lt_qty,t.schedseqnum,t.*
from sop_week_commitment_plan_detail_report t where t.version_no='20250522KTOP01' and parent_id='UNEFODF0000002'
order by original_parent_id;


select a.schedseqnum
from sop_week_commitment_plan_detail_report a
where version_no = '20250522KTOP01'
  and exists(select 1
             from engine_mid_mds_mrp b
             where a.schedseqnum = b.schedseqnum
               and b.supplyitem != 'DMY-ITEM'
               and b.supplytype = '12')
  and a.parent_id = 'FCST0000005';



select * from sop_first_version_rtf_detail_wide where  lt_qty>0;
select  schedseqnum,t.* from engine_mid_mds_mrp t where schedseqnum='111374'
and supplyitem != 'DMY-ITEM'
and supplytype = '12';

select * from sop_his_mid_mds_fcstorder;
select  * from sop_his_mid_mds_fcstorderstatus where schedseqnum='111374';

select distinct original_parent_id from sop_week_commitment_plan_detail_report t where t.version_no='20250521KTOP01' and lt_qty>0 and  data_type=3;
select original_parent_id,t.* from sop_week_commitment_plan_detail_report t where t.version_no='20250521KTOP01' and schedseqnum='105097';
select * from sop_week_commitment_plan_detail_report t where t.version_no='20250521KTOP01' and original_parent_id='563608';


SELECT * FROM   sop_his_mid_mds_fcstorderstatus T  WHERE IFNULL(seqnum,'')<>'';

SELECT DATE_ADD('2025-05-19', INTERVAL 28 DAY);

select  * from sp_turn_prodt_put t where t.proto_code='S12020100469' and demand_qty>0

select * from sop_his_mid_mds_fcstorderstatus a
where exists(
          select 1 from engine_mid_mds_mrp b
          where a.SCHEDSEQNUM = b.SCHEDSEQNUM
          and b.SUPPLYITEM <> 'DMD-ITEM'
          and b.SUPPLYTYPE='12'
);
/*select SCHEDSEQNUM,SUPPLYITEM, SUPPLYTYPE from engine_mid_mds_mrp;
select * from cfg_parameter where param_name ='IMPORT_PUBILSH_PERMISSION';
select  schedseqnum from sop_his_mid_mds_fcstorderstatus ;*/

select demand_code,parent_id, original_parent_id,
       whole_in_out,data_type,qty,lt_qty,t.schedseqnum
from sop_week_commitment_plan_detail_report t
where t.version_no = '20250523KTOP01'
  and parent_id = 'AZLS25000N'
  and data_type in (1, 3);




select *
from sop_week_commitment_plan_detail_report a
where a.data_type = 1
  and exists(select 1
             from engine_mid_mds_mrp b
             where a.schedseqnum = b.schedseqnum
               and b.supplyitem != 'DMY-ITEM'
               and b.supplytype = '12');


select purchase_group,purchase_group_desc,t.* from sp_key_material_risk_commitment t where ifnull(purchase_group_desc,'')<>'';

-- SAP采购组配置信息
select distinct purchase_group_desc from sap_purchase_group_mst;

select * from sap_factory_material_mst a
left join sap_purchase_group_mst b
on a.purchase_group = b.purchase_group;

select * from sp_key_material_risk_commitment ;

# 关键物料表
select * from sp_key_materials;
# 工厂物料主数据mst
select *
from sap_factory_material_mst;

SELECT * FROM MDM_ITEM_MASTER_PARTS_MST;
select * from sop_his_mid_mds_fcstorder;
select b.purchase_group from sp_key_materials a
         left join sap_factory_material_mst b on a.material_no = b.material_no

select c.purchase_group_desc
from sp_key_materials a
         left join sap_factory_material_mst b
                   on a.material_no = b.material_no
         left join sap_purchase_group_mst c
                   on b.purchase_group = c.purchase_group
where ifnull(c.purchase_group_desc,'')<>'';


select distinct b.purchase_group
from sp_key_materials a
         left join sap_factory_material_mst b
                   on a.material_no = b.material_no
where ifnull(b.purchase_group,'')<>'';


select distinct b.purchase_group_desc
from sp_key_materials a
         left join sap_purchase_group_mst b
                   on a.purchase_group = b.purchase_group
where ifnull(b.purchase_group_desc,'')<>'';
 select *  from cfg_parameter where param_name = 'SAP_ATP_ITEM_MATERIAL_GROUP' and display_flag = '1';

select b.purchase_group from sop_his_mid_mds_fcstorder a
left join sap_factory_material_mst b
on a.item = b.material_no;

select distinct c.purchase_group_desc
from sop_his_mid_mds_fcstorder a
         left join sap_factory_material_mst b
                   on a.item = b.material_no
         left join sap_purchase_group_mst c
                   on b.purchase_group = c.purchase_group
where ifnull(c.purchase_group_desc,'')<>''
union
select distinct c.purchase_group_desc
from sop_his_mid_odf_fcstorder a
         left join sap_factory_material_mst b
                   on a.item = b.material_no
         left join sap_purchase_group_mst c
                   on b.purchase_group = c.purchase_group
where ifnull(c.purchase_group_desc,'')<>'';

select distinct purchase_group_desc from sap_purchase_group_mst

                                    where  purchase_group='451';

select *
from sop_week_commitment_plan_detail_report a
where a.data_type = 1
  and exists(select 1
             from engine_mid_mds_mrp b
             where a.schedseqnum = b.schedseqnum
               and b.supplyitem != 'DMY-ITEM'
               and b.supplytype = '12');



SELECT DISTINCT b.purchase_group_desc FROM SP_MDS_MATERIAL_GAP_DETAIL_RPT a
                            LEFT JOIN sap_purchase_group_mst b ON a.PURCH_GROUP=b.PURCH_GROUP  WHERE  IFNULL (b.purchase_group_desc,'')<>'';

SELECT DISTINCT purchase_group_desc FROM sap_purchase_group_mst WHERE IFNULL(purchase_group_desc,'')<>'';
select *from sap_purchase_group_mst ;



SELECT DISTINCT t3.purchase_group      AS code,
                t4.purchase_group_desc AS meaning
FROM sop_his_mid_mds_fcstorder   t
         INNER JOIN (SELECT material_no,
                            material_desc_short,
                            purchase_group
                     FROM (SELECT ROW_NUMBER() OVER (PARTITION BY material_no
                         ORDER BY
                             material_desc_short) AS rn,
                                  material_no,
                                  material_desc_short,
                                  purchase_group
                           FROM sap_factory_material_mst) tt
                     WHERE tt.rn = 1) t3 ON
    t.item = t3.material_no
         INNER JOIN sap_purchase_group_mst t4 ON
    t3.purchase_group = t4.purchase_group
WHERE  t.org_id = 'KT'
  AND t3.purchase_group IS NOT NULL
  AND t4.purchase_group_desc IS NOT NULL;


select *
from sp_turn_prodt_result t
where t.pt_plan_version = '2025-05-12'
  and ((t.proto_code_type = '套机' and t.level_no = 2)
    or (t.proto_code_type <> '套机'))
  and ifnull(t.finished_factory_etd_time, '') = '' ;



select * from sp_order_item_for_rtf t where t.order_no='AZLZ240038';
select * from sp_order_header_for_rtf t where t.order_no='AZLZ240038';

select * from sop_his_mid_mds_fcstorder;

select distinct b.purchase_group, purchase_group_desc
from sop_his_mid_mds_fcstorder a
          join sap_factory_material_mst b
                   on a.item = b.material_no
          join sap_purchase_group_mst c
                   on b.purchase_group = c.purchase_group
where ifnull(c.purchase_group_desc,'') <>'';


select distinct  b.purchase_group,c.purchase_group_desc from sp_key_materials a
          join sap_factory_material_mst b on a.material_no = b.material_no
          join sap_purchase_group_mst c on b.purchase_group = c.purchase_group
where ifnull(c.purchase_group_desc,'') <>'';


select *from sap_purchase_group_mst;

select distinct purchase_group_desc from sap_purchase_group_mst;


select *from sop_week_commitment_plan_detail_report t
        where t.version_no='20250528KTOP01' and data_type=1 and qty>0;

select * from sop_week_commitment_plan_detail_report_wide t
        where t.version_no='20250528KTOP01' and data_type=1 and qty>0;

select  * from sp_key_materials t where material_no = '92014-000647';


SELECT DISTINCT b.purchase_group_desc FROM SP_MDS_MATERIAL_GAP_DETAIL_RPT a
                            LEFT JOIN sap_purchase_group_mst b ON a.PURCH_GROUP=b.PURCH_GROUP  WHERE  IFNULL (b.purchase_group_desc,'')<>'';

select * from sap_purchase_group_mst t where t.purchase_group='466';
select distinct purchase_group_desc from sap_purchase_group_mst where IFNULL (purchase_group_desc,'')<>'';

select * from dp_require_plan_output t where t.plan_version = (select max(plan_version) from dp_require_plan_output);
select * from dp_require_plan_output t where t.customer_model in ('S12110400008', 'S12110400006') and final_require_plan_qty >0;
select * from sp_order_offset_week_result_turn_prodt t where t.proto_type_code in ('S12110400008', 'S12110400006') and net_demand_qty>0;
select * from sp_turn_prodt_put t where t.proto_code in ('S12110400008', 'S12110400006') and demand_qty >0;
select * from sp_turn_prodt_cycle_deficiency_detail t  where t.pt_plan_version='2025-05-26' and t.proto_code in ('S12110400008', 'S12110400006');
select * from sp_turn_prodt_result t where t.pt_plan_version='2025-05-26' and t.proto_code in ('S12110400008', 'S12110400006');


select * from sop_his_mid_mds_fcstorder a;

select * from sp_turn_prodt_result t where t.pt_plan_version='2025-05-26' and t.proto_code_type ='套机' order by relation_id,level_no,whole_in_out;


select * from sp_turn_prodt_result t where t.pt_plan_version='2025-05-26' and t.proto_code_type ='套机'  and level_no=1;


select * from cfg_parameter where param_name ='IMPORT_PUBILSH_PERMISSION' and id='693417843443687425';

select count(1) from sop_first_version_rtf_detail where version_no='20250529KTOP01' ;

select count(1) from sop_first_version_rtf_detail_wide where version_no='20250529KTOP01' ;

select * from scm_market_org where region_code = 'SOUTHEAST ASIA' ;


select a.material_no,b.purchase_group from sp_key_materials a
join sap_factory_material_mst b
on a.material_no  = b.material_no
where ifnull(purchase_group,'')<>'';


select distinct c.purchase_group_desc
from sp_key_materials a
        join sap_factory_material_mst b on a.material_no  = b.material_no
        join sap_purchase_group_mst c
                   on b.purchase_group = c.purchase_group
where ifnull(c.purchase_group_desc,'')<>''
and ifnull(c.purchase_group,'')<>'' ;



select distinct sap_factory_material_mst.factory_no from sap_factory_material_mst;



select distinct b.purchase_group_desc
from sap_factory_material_mst a
         left join sap_purchase_group_mst b on a.purchase_group = b.purchase_group
where ifnull(b.purchase_group, '') <> ''
  and ifnull(b.purchase_group_desc, '') <> '';


SELECT DISTINCT purchase_group value,
purchase_group_desc AS label
FROM
sap_purchase_group_mst
WHERE 1 = 1
ORDER BY purchase_group DESC;

select * from sop_week_commitment_plan_detail_report where version_no='20250529KTOP01' and data_type=1;


select sum(qty) from sop_week_commitment_plan_detail_report where version_no='20250529KTOP01' and data_type=3 and demand_type='FCST'
union all
select sum(qty)+sum(lt_qty) from sop_week_commitment_plan_detail_report where version_no='20250529KTOP01' and data_type=1 and demand_type='FCST';


SELECT
    (SELECT COALESCE(SUM(qty), 0)
     FROM sop_week_commitment_plan_detail_report
     WHERE version_no='20250529KTOP01' AND data_type=3 AND demand_type='FCST')
    -
    (SELECT COALESCE(SUM(qty) + SUM(lt_qty), 0)
     FROM sop_week_commitment_plan_detail_report
     WHERE version_no='20250529KTOP01' AND data_type=1 AND demand_type='FCST')
AS difference;


select 7097713 - 7097541 ;
select * from plm_bom_item;

select *
from sop_week_commitment_plan_detail_report_wide;

select distinct product_type from mdm_item_master_mst ;
SHOW INDEX FROM plm_s_z_relation;

select *
from cfg_parameter where belong_domain='ALL'AND PARAM_NAME='KTSCM_REQUIRE_MODE';

select distinct product_categ from sp_product_categ ;

select t.outlook_date,t.* from sop_final_assembly_capacity_ramp_up_plan_item t ;


select * from cfg_parameter where belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='PUBLISH_ABNORMAL_TYPE' order by param_value;

SELECT * FROM srm_inventory_mst where item_code = '92014-000018';

