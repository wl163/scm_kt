select distinct material_no,purchase_group from sap_factory_material_mst where factory_no='5540' and ifnull(purchase_group,'')<>''
and material_no='10104-100007';

select distinct purchase_group from sap_factory_material_mst where material_no='0109000100053';
select * from sop_rso_order_header where rso_no= 'RSO20250709006';


select distinct factory_no from sop_purchase_group_config;

select * from sop_rso_order_approve_detail where parent_id = (
    select id from sop_rso_order_header where rso_no='RSO20250709005' and sop_rso_order_header.version_no=1
    );

select * from sop_rso_order_header where rso_no='RSO20250703007' and version_no=1;

select * from sop_rso_order_item_detail where parent_id in (
    select id from sop_rso_order_header where rso_no in ('RSO20250703001')  -- DRAFT
    );

select * from sop_rso_order_header where rso_no in ('RSO20250703001') ; -- DRAFT
-- 工厂配置
select * from cfg_parameter WHERE param_name='RSO_ORDER_FACTORY_VALUE_SET' ;
-- 内外销配置
select * from cfg_parameter WHERE param_name='RSO_ORDER_BG_VALUE_SET';
-- 审批状态
select * from cfg_parameter WHERE param_name='RSO_STATUS';
-- OA创建模板
select * from cfg_parameter WHERE param_name='RSO_NEW_ORDER_PROCESS_TEMPLATE' and dimension1='内销';
-- OA变更模板
select * from cfg_parameter WHERE param_name='RSO_CHANGE_ORDER_PROCESS_TEMPLATE' and dimension1='内销';
-- 流程模板节点定义
select  * from cfg_parameter where param_name='RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION'
                               and param_value = (
    select distinct param_value from cfg_parameter WHERE param_name='RSO_NEW_ORDER_PROCESS_TEMPLATE' and dimension1='外销'
    );

-- 物控人员节点配置
select  * from cfg_parameter where param_name='RSO_ORDER_MCACCOUNT_PROCESS_NODES' and dimension1='19780d30e266f78c695ffef4abeb8d39' ;
select * from cfg_parameter where param_name in ('RSO_ORDER_FACTORY_VALUE_SET','RSO_ORDER_BG_VALUE_SET','RSO_STATUS','RSO_NEW_ORDER_PROCESS_TEMPLATE',
                                                 'RSO_CHANGE_ORDER_PROCESS_TEMPLATE','RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION',
                                                'RSO_ORDER_MCACCOUNT_PROCESS_NODES','RSO_ORDER_PDACCOUNT_PROCESS_NODES','RISK_STOCKING_SAP_FACTORY_MST')
                            order by param_name,param_value,dimension1


# update cfg_parameter set attr2=attr1 where param_name='RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION'
-- 物控人员节点配置



and dimension1='19780d30e266f78c695ffef4abeb8d39' ;
-- 采购开发人员节点配置
select * from cfg_parameter where param_name='RSO_ORDER_PDACCOUNT_PROCESS_NODES' and dimension1='19780d30e266f78c695ffef4abeb8d39';

select  distinct param_value from cfg_parameter where param_name='RSO_ORDER_MCACCOUNT_PROCESS_NODES' and dimension1='A001'
union
select distinct param_value from cfg_parameter where param_name='RSO_ORDER_PDACCOUNT_PROCESS_NODES' and dimension1='A001';

select  * from cfg_parameter where param_name='RSO_ORDER_MCACCOUNT_PROCESS_NODES';
select * from cfg_parameter where param_name='RSO_ORDER_PDACCOUNT_PROCESS_NODES' ;

-- DRAFT SUBMIT_OA_SUCC  SUBMIT_OA_FAIL  OA_REJECT OA_END SUBMIT_SAP_SUCC  SUBMIT_SAP_FAIL  TIME_FAILURE_SAP_SUCC  TIME_FAILURE_SAP_FAIL
select * from sop_rso_order_header where rso_no='RSO20250703001' ; -- SUBMIT_SAP_SUCC
UPDATE sop_rso_order_header SET status_code='OA_END' WHERE rso_no='RSO20250704002' and version_no='0';

select distinct param_value from cfg_parameter WHERE param_name='FACTORY_NO' ;
-- DATE_FORMAT(CURDATE(), '%Y-%m-01')
select DATE_FORMAT(CURDATE(), '%Y-%m-01');
SELECT DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY) AS monday_of_week;

select distinct material_no,purchase_group from sap_factory_material_mst t where t.factory_no='5540' and purchase_group='393' ;
select distinct material_desc_short from sap_factory_material_mst t where t.material_no='010900027_A';

select * from sop_purchase_group_config where factory_no='5540' and purchase_group='393';

select distinct pmc_uid from sop_rso_order_item_detail;
SELECT DISTINCT t1.material_no
FROM sap_factory_material_mst t1
WHERE t1.factory_no = '5500'
AND  EXISTS (
    SELECT 1
    FROM sap_factory_material_mst t2
    WHERE t2.factory_no = '5540'
    AND t2.material_no = t1.material_no
);

SELECT *
FROM cfg_parameter cfg
WHERE param_name = 'PURCHASE_GROUP_CUSTOMIZE' AND attr1 = 'Y';

-- 符合 提交SAP成功的单据
select rso_no, version_no, status_code, valid_date
from sop_rso_order_header
where (rso_no, version_no) in (select rso_no, max(version_no) as version_no
                               from sop_rso_order_header
                               group by rso_no)
  and status_code in (select param_value from cfg_parameter WHERE param_name = 'RSO_STATUS' and attr1 = 'Y')
  and date_format(valid_date, '%Y-%m-%d') >= curdate();

select * from cfg_parameter WHERE param_name = 'RSO_STATUS';
select * from sop_rso_order_header where rso_no= 'RSO20250708010';

-- 符合 失效SAP成功的单据 写法1
select rso_no, version_no, status_code, invalid_date
from sop_rso_order_header
where (rso_no, version_no) in (select rso_no, max(version_no) as version_no
                               from sop_rso_order_header
                               group by rso_no)
  and status_code in (select param_value from cfg_parameter WHERE param_name = 'RSO_STATUS' and attr2 = 'Y')
  and date_format(invalid_date, '%Y-%m-%d') <= curdate();


-- 符合 失效SAP成功的单据 写法2
WITH latest_rso AS (
    SELECT
        rso_no,
        version_no,
        status_code,
        invalid_date,
        -- 使用窗口函数获取每个rso_no的最新版本
        ROW_NUMBER() OVER (PARTITION BY rso_no ORDER BY version_no DESC) AS rn
    FROM sop_rso_order_header
),
valid_status AS (
    -- 获取有效的状态值列表
    SELECT DISTINCT param_value
    FROM cfg_parameter
    WHERE param_name = 'RSO_STATUS'
      AND attr2 = 'Y'
)
SELECT
    r.rso_no,
    r.version_no,
    r.status_code,
    r.invalid_date
FROM latest_rso r
JOIN valid_status s ON r.status_code = s.param_value
WHERE r.rn = 1                  -- 只取最新版本
  AND r.invalid_date <= CURRENT_DATE  -- 失效时间小于于等于当前日期
ORDER BY r.rso_no;


UPDATE sop_rso_order_header SET status_code='DRAFT' WHERE rso_no='RSO20250624008';
select * from sop_rso_order_header t where rso_no='RSO20250624002';


select * from SOP_HIS_MID_MDS_FCSTORDER;
select* from oms_piso_header_in where pi_no='PIOBG250623033' ;


select * from mdm_item_clean_cfg  ;



select * from sp_turn_prodt_result t where t.pt_plan_version='2025-06-30' and demand_qty='1500' and country_code='CN' AND DATE_FORMAT(require_goods_demand_time,'%Y%m')


select  concat((DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY)),'初版');


select * from scm_market_org;
select * from cfg_parameter WHERE belong_domain = 'KTSCM_TURN_PROUCT';

select bulk_require_goods_mode,t.* from dp_require_plan_output_data t;
select distinct bulk_require_goods_mode from dp_require_plan_output_data





--  采购组信息维护
select * from dp_require_plan_output;
select * from sp_product_categ;

select * from mdm_item_master_mst;
select * from mdm_sku_mst;

select * from sap_factory_material_mst  where factory_no='5500' and material_no='G0301-110348T';
SELECT * FROM sop_purchase_group_config T WHERE T.purchase_group='A01' AND factory_no='5540';
select *  from cfg_parameter cfg WHERE param_name = 'PURCHASE_GROUP_CUSTOMIZE' ;
/*新增列表的数据获取*/
WITH data1 AS (SELECT d.factory_no, d.purchase_group, a.purchase_group_desc, 'SAP工厂主数据' AS source
               FROM sap_purchase_group_mst a
                        JOIN (SELECT DISTINCT c.factory_no, c.purchase_group
                              FROM sap_factory_material_mst c) d
                             ON a.purchase_group = d.purchase_group
               WHERE EXISTS (SELECT 1
                             FROM cfg_parameter cfg
                             WHERE param_name = 'RISK_STOCKING_SAP_FACTORY_MST'
                               AND d.factory_no = cfg.param_value)),
     data2 AS (SELECT DISTINCT dimension1 AS factory_no,
                               dimension2 AS purchase_group,
                               dimension3 AS purchase_group_desc,
                               'CFG配置'  AS source
               FROM cfg_parameter cfg
               WHERE param_name = 'PURCHASE_GROUP_CUSTOMIZE'
                 AND attr1 = 'Y'
                 AND NOT EXISTS (SELECT 1
                                 FROM data1
                                 WHERE cfg.dimension1 = data1.factory_no
                                   AND cfg.dimension2 = data1.purchase_group)
               )
SELECT * FROM data1
UNION
SELECT * FROM data2
         order by factory_no ,purchase_group ;

select * from cfg_parameter where param_name = 'RISK_STOCKING_SAP_FACTORY_MST';
