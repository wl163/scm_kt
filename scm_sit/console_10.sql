-- 待产PO
select *
from (SELECT oowr.bu_area                                                  as region_code,
             oowr.brand_group,
             oowr.is_special,
             oowr.inner_po_no,
             oowr.inner_po_item_no,
             oowr.inner_po_item_no_detail,
             oowr.whole_proto_code                                         AS whole_code,
             oowr.country                                                  AS require_addr,
             IF((oowr.country = 'CN' AND oowr.brand_group = '自有品牌' AND oowr.is_special = 'Y')
                    OR (oowr.country = 'CN' AND oowr.brand_group = 'ODM'), oowr.customer,
                'DUM_CUST')                                                AS require_goods_cust_code,
             oowr.require_goods_mode,
             oowr.country                                                  AS supply_demand_handshake_addr,
             IF(IFNULL(oowr.demand_date, '') = '', NULL,
                CAST(oowr.demand_date AS DATE))                            AS eta_demand_date,
             IF(IFNULL(oowr.demand_date, '') = '', NULL,
                CAST(oowr.demand_date AS DATE))                            AS etd_demand_date,
             CAST(oowr.demand_qty AS DECIMAL(12, 3))                       AS demand_qty,
             CAST(IF(ps.promise_time_flag = '1', oowr.flip_instock_qty,
                     oowr.delivered_qty) AS DECIMAL(12, 3))                AS delivery_qty,
             CAST(IF(ps.promise_time_flag = '1', oowr.no_flip_instock_qty,
                     oowr.undeliver_qty) AS DECIMAL(12, 3))                AS open_qty,
             oowr.is_bulk,
             oowr.bulk_require_goods_mode,
             (
                 case
                     WHEN IFNULL(oowr.demand_date, '') = '' then NULL
                     WHEN DATE_FORMAT(CURDATE(), '%Y-%m-01') > CAST(oowr.demand_date AS DATE) THEN 1
                     WHEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) > CAST(oowr.demand_date AS DATE)
                         and CAST(oowr.demand_date AS DATE) >= DATE_FORMAT(CURDATE(), '%Y-%m-01') THEN 2
                     ELSE 0
                     END
                 )                                                         as inner_po_overdue_flag,
             NOW()                                                         as snap_time,
             'WEEK'                                                        AS snap_param_one,
             'THU'                                                         AS snap_param_two,
             ''                                                            AS bulk_scene,
             oowr.demand_factory                                           AS mfg_factory,
             1                                                             AS created_by,
             NOW()                                                         AS creation_date,
             1                                                             AS last_updated_by,
             NOW()                                                         AS last_update_date,
             'admin'                                                       AS created_account,
             'admin'                                                       AS last_updated_account,
             'KT'                                                          AS org_id,
             0                                                             AS delete_flag,
             oowr.id,
             (CASE
                  WHEN oowr.order_source = '01' AND oowr.so_major_categories = '2' THEN 'YN01'
                  WHEN oowr.order_source = '99' AND oowr.so_major_categories = '2' AND oowr.country = 'ID' THEN 'YN02'
                  ELSE '' END
                 )                                                         AS appointed_factory,
             oowr.order_source,
             oowr.so_major_categories,
             row_number() over (partition by oowr.id order by ps.priority) as row_num
      FROM sp_inner_po_weekly_snapshot as oowr
               left join (
/*参数总表匹配*/
          SELECT ps.brand_group,
                 ps.is_special,
                 ps.require_goods_mode,
                 ps.is_work_plan_bom_flag,
                 ps.snap_param_one,
                 ps.snap_param_two,
                 ps.promise_time_flag,
                 (
/*匹配模式，1加上要货地点，0 去掉要货地点*/
                     CASE
                         WHEN ps.require_addr != 'NOT CN' THEN 1
                         WHEN ps.bg_code = 'ALL' THEN 0
                         ELSE 1 END
                     )     AS match_flag,
                 (
/*优先级：多种情况都匹配到的，取优先及最高的一条*/
                     CASE
                         WHEN ps.require_addr != 'NOT CN' THEN 1
                         WHEN ps.bg_code = 'ALL' THEN 3
                         ELSE 2 END
                     )     AS priority,
                 IFNULL(
                         CASE
                             WHEN ps.require_addr != 'NOT CN' THEN ps.require_addr
                             WHEN ps.bg_code = 'ALL' THEN ''
                             ELSE org.country_code END
                     , '') AS require_addr,
                 ps.cal_mode,
                 ps.inner_po_type,
                 ps.overdue_demand_co_flag
          FROM dp_require_plan_summary AS ps
                   LEFT JOIN scm_market_org AS org
                             ON org.org_id = 'KT' AND ps.bg_code = org.bg_code AND ps.brand_group = org.brand_name
          WHERE ps.org_id = 'KT') as ps
                         on oowr.brand_group = ps.brand_group and
                            oowr.is_special = ps.is_special and
                            oowr.require_goods_mode = ps.require_goods_mode and
                            if(ps.match_flag = 1, oowr.country = ps.require_addr, oowr.country != 'CN')
                             and ps.brand_group is not null
      WHERE oowr.`level` = '2'
        AND oowr.enabled_offset = 'Y'
        and oowr.version_no =
            (select MAX(version_no) from sp_inner_po_weekly_snapshot WHERE version_no REGEXP '^[0-9]{14}$')
        and oowr.enabled_offset = 'Y'
        AND CAST(IF(ps.promise_time_flag = '1', oowr.no_flip_instock_qty, oowr.undeliver_qty) AS DECIMAL(12, 3)) > 0
        and oowr.brand_group = '自有品牌'
        and oowr.is_special = 'N'
        and oowr.country = 'CN') t
where t.row_num = 1;