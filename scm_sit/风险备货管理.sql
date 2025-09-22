select * from sop_rso_order_approve_detail where parent_id = (
    select id from sop_rso_order_header where rso_no='RSO20250903001' and version_no=0
    );

select * from sop_rso_order_header where rso_no='RSO20250709002' and version_no=1;

select * from sop_rso_order_item_detail where parent_id in (
    select id from sop_rso_order_header where rso_no in ('RSO20250903001') ORDER by version_no desc limit 1  -- DRAFT
    );

select * from sop_rso_order_header where rso_no in ('RSO20250903001') ; -- DRAFT
-- 工厂配置
select * from cfg_parameter WHERE param_name='RSO_ORDER_FACTORY_VALUE_SET' ;
-- 内外销配置
select * from cfg_parameter WHERE param_name='RSO_ORDER_BG_VALUE_SET';
-- 审批状态
select * from cfg_parameter WHERE param_name='RSO_STATUS' and param_value='OA_DISUSE';
-- OA创建模板 A001
select * from cfg_parameter WHERE param_name='RSO_NEW_ORDER_PROCESS_TEMPLATE' ;
-- OA变更模板 A002
select * from cfg_parameter WHERE param_name='RSO_CHANGE_ORDER_PROCESS_TEMPLATE' ;
-- 审批流程 流程模板节点定义 新建单据
select * from cfg_parameter where param_name='RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION' and param_value = (
    select distinct param_value from cfg_parameter WHERE param_name='RSO_NEW_ORDER_PROCESS_TEMPLATE'
    ) order by dimension1 ;

-- 流程模板节点定义 变更单据
select * from cfg_parameter where param_name='RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION' and param_value = (
    select distinct param_value from cfg_parameter WHERE param_name='RSO_CHANGE_ORDER_PROCESS_TEMPLATE'
    ) order by dimension1 ;



select  distinct dimension1 as  审批顺序, dimension2 as 审批节点名,dimension3 as 签批类型
from cfg_parameter
where param_name='RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION'
  and param_value='1936133f08a78b00a8de94e4cd6bf9d2' and attr5<>'';


select * from cfg_parameter where param_name='RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION' order by param_value ,dimension1 ;

 select  *  from cfg_parameter where param_name='RSO_ORDER_MCACCOUNT_PROCESS_NODES' and dimension1='1936133f08a78b00a8de94e4cd6bf9d2' ;

  select * from cfg_parameter WHERE param_name='RSO_CHANGE_ORDER_PROCESS_TEMPLATE';
select * from cfg_parameter where param_name in ('RSO_ORDER_FACTORY_VALUE_SET','RSO_ORDER_BG_VALUE_SET','RSO_STATUS','RSO_NEW_ORDER_PROCESS_TEMPLATE',
                                                 'RSO_CHANGE_ORDER_PROCESS_TEMPLATE','RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION');

# update cfg_parameter set attr2=attr1 where param_name='RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION'
-- 物控人员节点配置
select  * from cfg_parameter where param_name='RSO_ORDER_MCACCOUNT_PROCESS_NODES' and dimension1='19780d30e266f78c695ffef4abeb8d39' ;
-- 采购开发人员节点配置
select * from cfg_parameter where param_name='RSO_ORDER_PDACCOUNT_PROCESS_NODES' and dimension1='19780d30e266f78c695ffef4abeb8d39';

select  * from cfg_parameter where param_name in ('RSO_ORDER_MCACCOUNT_PROCESS_NODES','RSO_ORDER_PDACCOUNT_PROCESS_NODES');

select  distinct param_value from cfg_parameter where param_name='RSO_ORDER_MCACCOUNT_PROCESS_NODES' and dimension1='A001'
union
select distinct param_value from cfg_parameter where param_name='RSO_ORDER_PDACCOUNT_PROCESS_NODES' and dimension1='A001';

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
  and date_format(valid_date, '%Y-%m-%d') <= curdate();


-- SUBMIT_SAP_SUCC  TIME_FAILURE_SAP_FAIL

select * from cfg_parameter WHERE param_name = 'RSO_STATUS';
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
  AND r.invalid_date <= CURRENT_DATE  -- 失效时间大于等于当前日期
ORDER BY r.rso_no;

-- 配置数据
select * from cfg_parameter where param_name in ('RSO_ORDER_FACTORY_VALUE_SET','RSO_ORDER_BG_VALUE_SET','RSO_STATUS','RSO_NEW_ORDER_PROCESS_TEMPLATE',
                                                 'RSO_CHANGE_ORDER_PROCESS_TEMPLATE','RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION',
                                                'RSO_ORDER_MCACCOUNT_PROCESS_NODES','RSO_ORDER_PDACCOUNT_PROCESS_NODES','RISK_STOCKING_SAP_FACTORY_MST') order by param_name ;

select * from cfg_parameter where param_name = 'RISK_STOCKING_SAP_FACTORY_MST';
select length('jichu.chen@tcl.com;li5.zhong@tcl.com;rui7.wu@tcl.com;kt_rensj@tcl.com;feng14.deng@tcl.com') ;


select * from sap_purchase_group_mst  ;



    SELECT srh.id,
           srh.rso_no,
           srh.in_out_sale,
           srh.factory_no,
           sri.id AS item_id,
           sri.line_no,
           sri.material_no,
           sri.demand_num,
           sri.demand_date,
           sri.data_status
    FROM sop_rso_order_header srh
             LEFT JOIN (SELECT srh.rso_no, max(version_no) AS version_no
                        FROM sop_rso_order_header srh
                        GROUP BY srh.rso_no) mv
                       ON srh.rso_no = mv.rso_no AND srh.version_no = mv.version_no
             LEFT JOIN sop_rso_order_item_detail sri ON srh.id = sri.parent_id
    WHERE mv.rso_no IS NOT NULL
      AND srh.valid_date <= CURDATE()
      AND
        srh.status_code IN (SELECT DISTINCT param_value FROM cfg_parameter WHERE param_name = 'RSO_STATUS' AND attr1 = 'Y') ;


update sop_rso_order_header
set  valid_date='2025-09-12 00:00:00',invalid_date='2025-09-12 00:00:00'
where rso_no='RSO20250912001' ;


select * from sop_rso_order_header where rso_no = 'RSO20250912001' ;


select   * from RSO_CHANGE_ORDER_PROCESS_TEMPLATE