WITH demand_capcity_model as (
#   转产结果
  SELECT
      cfg1.attr1 as factory,
      spc.product_categ as model,
      CASE
        WHEN tpr.is_bulk2 = 'N' THEN 'CBU'
        ELSE
          CASE
            WHEN tpr.proto_code_type = '单内' THEN
              CASE
                WHEN tpr.bulk_require_mode LIKE '%内半散%' THEN 'SKD'
                WHEN tpr.bulk_require_mode LIKE '%内全散%' THEN 'CKD'
                WHEN tpr.bulk_require_mode = '半散（单）' THEN 'SKD'
                WHEN tpr.bulk_require_mode = '全散（单）' THEN 'CKD'
              END
            WHEN tpr.proto_code_type = '单外' THEN
              CASE
                WHEN tpr.bulk_require_mode LIKE '%外半散%' THEN 'SKD'
                WHEN tpr.bulk_require_mode LIKE '%外全散%' THEN 'CKD'
                WHEN tpr.bulk_require_mode = '半散（单）' THEN 'SKD'
                WHEN tpr.bulk_require_mode = '全散（单）' THEN 'CKD'
              END
          END
      END AS shipment_mode,
      tpr.whole_in_out,
      DATE_FORMAT(tpr.turn_prodt_factory_etd_time, '%Y-%m') AS `year_month`,
      tpr.turn_prodt_qty as qty
  FROM sp_turn_prodt_result tpr
  LEFT JOIN cfg_parameter cfg1
    ON cfg1.belong_domain = 'KTSCM_TURN_PROUCT'
   AND cfg1.PARAM_NAME = 'DMD_FACTORY_BASE_PLANT_RELATION'
   AND tpr.turn_prodt_factory = cfg1.dimension1
   AND tpr.is_bulk2 = cfg1.dimension2
  LEFT JOIN mdm_item_master_mst item_m
     ON tpr.in_out_zcode = item_m.bom_code
  LEFT JOIN mdm_item_master_mst item_m2
     ON tpr.in_out_scode = item_m2.bom_code
  LEFT JOIN sp_product_categ spc
     ON IFNULL(item_m.product_small_categ_name, item_m2.product_small_categ_name) = spc.product_small_categ_name
  WHERE NOT (tpr.proto_code_type = '套机' AND tpr.whole_in_out = '整机')
#     AND tpr.pt_plan_version = '2024-10-21'
    AND DATE_FORMAT(tpr.turn_prodt_factory_etd_time, '%Y%m') BETWEEN DATE_FORMAT(NOW(), '%Y%m')
        AND DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 4 MONTH), '%Y%m')

  UNION ALL
#     ODF
  SELECT
    cfg1.attr1 as factory,
    spc.product_categ as model,
    CASE SUBSTR(oi.item_code, 3, 1)
      WHEN 'U' THEN 'CBU'
      WHEN 'S' THEN 'SKD'
      WHEN 'C' THEN 'CKD'
    END AS shipment_mode,
    oi.whole_in_out,
    DATE_FORMAT(IFNULL(oi.adjust_promise_date, oi.first_promise_date), '%Y-%m') as `year_month`,
    oi.qty as qty
  FROM sp_order_header_weekly_esp_snapshot oh
  INNER JOIN sp_order_item_weekly_esp_snapshot oi
    ON oh.order_no = oi.order_no
  LEFT JOIN cfg_parameter cfg1
    ON cfg1.belong_domain  = 'KTSCM_TURN_PROUCT'
   AND cfg1.param_name = 'DMD_FACTORY_BASE_PLANT_RELATION'
   AND oi.turn_prodt_factory = cfg1.dimension1
   AND oh.is_bulk = cfg1.dimension2
  LEFT JOIN mdm_item_master_mst item
    ON oi.item_code = item.bom_code
  LEFT JOIN sp_product_categ spc
    ON item.product_small_categ_name = spc.product_small_categ_name
  WHERE oi.whole_in_out IN ('内机', '外机')
    -- N ~ N+4
    AND DATE_FORMAT(IFNULL(oi.adjust_promise_date, oi.first_promise_date), '%Y-%m') BETWEEN
        DATE_FORMAT(CURRENT_DATE(), '%Y-%m') AND DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL 4 MONTH), '%Y-%m')

),
-- 需求产能数据
demand_capcity_data as (
  SELECT
    tpr.factory,
    tpr.model,
    tpr.shipment_mode,
    tpr.whole_in_out,
    tpr.`year_month`,
    SUM(tpr.qty) as total
FROM demand_capcity_model tpr
GROUP BY tpr.factory, tpr.model, tpr.shipment_mode, tpr.whole_in_out, tpr.`year_month`
ORDER BY tpr.factory, tpr.model, tpr.shipment_mode, tpr.whole_in_out, tpr.`year_month`
),
-- 设计产能机型
design_capcity_model as (
  SELECT
      cfg1.attr1 as factory,
      plan.product_type AS model,
      plan.shipment_mode,
      plan.whole_in_out,
      DATE_FORMAT(upi.outlook_date, '%Y-%m') as `year_month`,
      upi.final_capacity as qty
  FROM sop_final_assembly_capacity_ramp_up_plan plan
  INNER JOIN sop_final_assembly_capacity_ramp_up_plan_item upi
    ON plan.id = upi.header_id
  LEFT JOIN cfg_parameter cfg1
    ON cfg1.belong_domain = 'KTSCM_TURN_PROUCT'
   AND cfg1.PARAM_NAME = 'DMD_FACTORY_BASE_PLANT_RELATION'
   AND plan.base = cfg1.param_value
   AND plan.physical_addr = cfg1.attr2
  WHERE DATE_FORMAT(upi.outlook_date, '%Y%m') BETWEEN DATE_FORMAT(NOW(), '%Y%m')
              AND DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 4 MONTH), '%Y%m')
),
-- 设计产能数据
design_capcity_data as (
  SELECT
      plan.factory,
      plan.model,
      plan.shipment_mode,
      plan.whole_in_out,
      plan.`year_month`,
      SUM(plan.qty) as total
  FROM design_capcity_model plan
  GROUP BY plan.factory, plan.model, plan.whole_in_out, plan.shipment_mode, plan.`year_month`
  ORDER BY plan.factory, plan.model, plan.whole_in_out, plan.shipment_mode, plan.`year_month`
),
all_data as (
  select
      t1.factory,
      t1.model,
      t1.shipment_mode,
      t1.whole_in_out,
      t1.`year_month`,
      IFNULL(t1.total, 0)  as demand_qty,
      IFNULL(t2.total, 0)  as design_qty,
      IFNULL(t2.total, 0)  - IFNULL(t1.total, 0)  as remain_qty
  FROM demand_capcity_data t1
  LEFT JOIN design_capcity_data t2
    on t1.factory = t2.factory
   and t1.model = t2.model
  and t1.shipment_mode = t2.shipment_mode
  and t1.whole_in_out = t2.whole_in_out
   and t1.`year_month` = t2.`year_month`
  UNION ALL
  select
      t2.factory,
      t2.model,
      t2.shipment_mode,
      t2.whole_in_out,
      t2.`year_month`,
      IFNULL(t1.total, 0)  as demand_qty,
      IFNULL(t2.total, 0)  as design_qty,
      IFNULL(t2.total, 0)  - IFNULL(t1.total, 0)  as remain_qty
  FROM demand_capcity_data t1
  RIGHT JOIN design_capcity_data t2
    on t1.factory = t2.factory
   and t1.model = t2.model
   and t1.shipment_mode = t2.shipment_mode
   and t1.whole_in_out = t2.whole_in_out
   and t1.`year_month` = t2.`year_month`
),
group_data as (
  select
      factory,
      model,
      shipment_mode,
      whole_in_out,
      `year_month`,
      demand_qty,
      design_qty,
      remain_qty,
      ROW_NUMBER() OVER(PARTITION BY factory, model, shipment_mode, whole_in_out, `year_month`) as rn
  from all_data
)
select
    factory,
    model,
    shipment_mode,
    whole_in_out,
    `year_month`,
    demand_qty,
    design_qty,
    remain_qty
from group_data
where rn  = 1
order by factory, model, shipment_mode, whole_in_out, `year_month`