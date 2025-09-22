-- 要货计划基表
select * from dp_require_plan_base;


select max(plan_version) from dp_require_plan_base_archive;

-- 要货计划参数表总表
select * from dp_require_plan_summary;

-- 要货计划参数表
select begining_inv_date,inner_po_value_type,t.* from dp_require_plan_param t ;

-- 整机库存
select * from v_whole_machine_inv_pre ;
-- 内部PO周度冲减快照表
select * from sp_inner_po_weekly_snapshot;



select * from dp_cbg_demand_classify_header;
select * from dp_cbg_demand_classify_item;
select * from dp_cbg_demand_classify_version_relation;


select * from dp_po_so_open_cbu;



SELECT SUBSTRING_INDEX('Z1U20102000645_A', '_', 1) AS result;
-- 返回: Z1U20102000645


/*    cur_rdc1_inv_total                  int         null comment '当前库存(RDC1)',
    cur_rdc2_inv_total                  int         null comment '当前库存(RDC2)',
    cur_cdc_inv_total                   int         null comment '当前库存(CDC)',
    actual_inv_qty                      int         null comment '实际库存',
    available_inv_qty                   int         null comment '可用库存',*/
select cur_rdc1_inv_total, cur_rdc2_inv_total,cur_cdc_inv_total,actual_inv_qty,available_inv_qty,t.* from dp_require_plan_base t;

select actual_inv_qty, avaliable_stock_qty, t.*
from scm_uat_inbound.dw_cbg_warehouse_inv_mst t
where logic_whse_type_name = 'RDC' and
      `logic_whse_name` NOT LIKE _UTF8MB4'%KY-3W菜鸟仓%' AND
      `logic_whse_name` NOT LIKE _UTF8MB4'%京东%'
union all
select actual_inv_qty, avaliable_stock_qty, t.*
from scm_uat_inbound.dw_cbg_warehouse_inv_mst t
where logic_whse_type_name = 'CDC' and
      `logic_whse_name` NOT LIKE _UTF8MB4'%KY-3W菜鸟仓%' AND
      `logic_whse_name` NOT LIKE _UTF8MB4'%京东%'

                                            OR logic_whse_type_name='CDC';

select * from v_whole_machine_inv_pre ;


select distinct factory_no from sap_factory_material_mst where ifnull(factory_no,'')<>'';


select distinct factory_no from sp_factory_config where ifnull(factory_no,'')<>'';
select distinct bom_factory from sp_zcode_optional_config_relation where ifnull(bom_factory,'')<>''