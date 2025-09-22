-- 内部PO取值类型=MO
UPDATE dp_require_plan_base_factory AS pbf
    LEFT JOIN (SELECT pp.customer_model,
                      pp.require_addr,
                      pp.require_goods_mode,
                      pp.require_goods_cust_code,
                      pp.brand_group,
                      pp.is_special,
                      map.is_bulk,
                      map.appointed_factory,
                      IF(pp.cal_mode = 'PW', DATE(pwt.pw_start_date), DATE(wt.w_start_date)) AS bg_demand_time,
                      SUM(osd.demand_qty)                                                    AS qty
               FROM (SELECT oc.whole_code,
                            oc.require_addr,
                            oc.require_goods_mode,
                            oc.brand_group,
                            oc.is_special,
                            oc.is_bulk,
                            IFNULL(oc.appointed_factory, '') AS appointed_factory,
                            oc.eta_demand_date,
                            oc.demand_qty,
                            IF((oc.require_addr = 'CN' AND oc.brand_group = '自有品牌' AND oc.is_special = 'Y')
                                   OR (oc.require_addr = 'CN' AND oc.brand_group = 'ODM'), oc.require_goods_cust_code,
                               'DUM_CUST')                   AS require_goods_cust_code
                     FROM dp_po_so_open_cbu oc
                     WHERE oc.org_id = 'KT'
                       AND oc.demand_qty != 0
                       AND EXISTS (SELECT 1
                                   FROM (
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
                                                               ON org.org_id = 'KT' AND ps.bg_code = org.bg_code AND
                                                                  ps.brand_group = org.brand_name
                                            WHERE ps.org_id = 'KT') AS ps
                                   WHERE oc.brand_group = ps.brand_group
                                     AND oc.is_special = ps.is_special
                                     AND oc.require_goods_mode = ps.require_goods_mode
                                     AND if(ps.match_flag = 1, oc.require_addr = ps.require_addr,
                                            oc.require_addr != 'CN')
                                     AND oc.snap_param_one = ps.snap_param_one
                                     AND oc.snap_param_two = ps.snap_param_two)) AS osd
                        /*连接 需求map*/
                        LEFT JOIN dp_require_plan_demand_map AS map ON map.demand_model = osd.whole_code
                   AND map.demand_cust_code = osd.require_goods_cust_code
                   AND map.demand_mode = osd.require_goods_mode
                   AND map.demand_addr = osd.require_addr
                   AND map.brand_group = osd.brand_group
                   AND map.is_special = osd.is_special
                   AND map.is_bulk = osd.is_bulk
                   AND map.appointed_factory = osd.appointed_factory
                   /*连接 参数表*/
                        LEFT JOIN dp_require_plan_param AS pp ON map.customer_model = pp.customer_model
                   AND map.require_addr = pp.require_addr
                   AND map.require_goods_mode = pp.require_goods_mode
                   AND map.require_goods_cust_code = pp.require_goods_cust_code
                   AND map.brand_group = pp.brand_group
                   AND map.is_special = pp.is_special
                   /*连接日历表*/
                        LEFT JOIN kt_plan_time_master AS pwt ON pp.cal_mode = 'PW'
                   AND osd.eta_demand_date >= DATE(pwt.pw_start_date)
                   AND DATE(pwt.pw_end_date) >= osd.eta_demand_date
                        LEFT JOIN (SELECT DISTINCT w_end_date, w_start_date FROM kt_plan_time_master) wt
                                  ON pp.cal_mode = 'W'
                                      AND osd.eta_demand_date >= DATE(wt.w_start_date)
                                      AND DATE(wt.w_end_date) >= osd.eta_demand_date
               WHERE map.customer_model IS NOT NULL
                 AND pp.inner_po_value_type = 'MO'
               GROUP BY pp.customer_model,
                        pp.require_addr,
                        pp.require_goods_mode,
                        pp.require_goods_cust_code,
                        pp.brand_group,
                        pp.is_special,
                        map.is_bulk,
                        map.appointed_factory,
                        IF(pp.cal_mode = 'PW', DATE(pwt.pw_start_date), DATE(wt.w_start_date))) AS tab ON
        tab.customer_model = pbf.customer_model
            AND tab.require_addr = pbf.require_addr
            AND tab.require_goods_mode = pbf.require_goods_mode
            AND tab.require_goods_cust_code = pbf.require_goods_cust_code
            AND tab.brand_group = pbf.brand_group
            AND tab.is_special = pbf.is_special
            AND tab.is_bulk = pbf.is_bulk
            AND tab.appointed_factory = pbf.appointed_factory
            AND tab.bg_demand_time = pbf.bg_demand_time
SET pbf.inner_po_qty=tab.qty
WHERE tab.customer_model IS NOT NULL;

--  内部PO取值类型=PISO的取值
UPDATE dp_require_plan_base_factory AS pbf
    LEFT JOIN (SELECT pp.customer_model,
                      pp.require_addr,
                      pp.require_goods_mode,
                      pp.require_goods_cust_code,
                      pp.brand_group,
                      pp.is_special,
                      map.is_bulk,
                      map.appointed_factory,
                      IF(pp.cal_mode = 'PW', DATE(pwt.pw_start_date), DATE(wt.w_start_date)) AS bg_demand_time,
                      SUM(osd.demand_qty)                                                    AS qty
               FROM (SELECT oc.whole_code,
                            oc.require_addr,
                            oc.require_goods_mode,
                            oc.brand_group,
                            oc.is_special,
                            oc.is_bulk,
                            IFNULL(oc.appointed_factory, '') AS appointed_factory,
                            oc.eta_demand_date,
                            oc.demand_qty,
                            IF(oc.require_addr != 'CN' AND oc.brand_group = '自有品牌', 'DUM_CUST',
                               oc.require_goods_cust_code)   AS require_goods_cust_code
                     FROM dp_pi1so2_open_cbu oc
                     WHERE oc.demand_qty != 0
                       AND oc.org_id = 'KT'
                       AND oc.snap_time = (SELECT MAX(snap_time) FROM dp_pi1so2_open_cbu WHERE org_id = 'KT')
                       AND EXISTS (SELECT 1
                                   FROM (
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
                                                               ON org.org_id = 'KT' AND ps.bg_code = org.bg_code AND
                                                                  ps.brand_group = org.brand_name
                                            WHERE ps.org_id = 'KT') AS ps
                                   WHERE oc.brand_group = ps.brand_group
                                     AND oc.is_special = ps.is_special
                                     AND oc.require_goods_mode = ps.require_goods_mode
                                     AND IF(ps.match_flag = 1, oc.require_addr = ps.require_addr,
                                            oc.require_addr != 'CN')
                                     AND oc.snap_param_one = ps.snap_param_one
                                     AND oc.snap_param_two = ps.snap_param_two)) AS osd
                        /*连接 需求map*/
                        LEFT JOIN dp_require_plan_demand_map AS map ON map.demand_model = osd.whole_code
                   AND map.demand_cust_code = osd.require_goods_cust_code
                   AND map.demand_mode = osd.require_goods_mode
                   AND map.demand_addr = osd.require_addr
                   AND map.brand_group = osd.brand_group
                   AND map.is_special = osd.is_special
                   AND map.is_bulk = osd.is_bulk
                   AND map.appointed_factory = osd.appointed_factory
                   /*连接 参数表*/
                        LEFT JOIN dp_require_plan_param AS pp ON map.customer_model = pp.customer_model
                   AND map.require_addr = pp.require_addr
                   AND map.require_goods_mode = pp.require_goods_mode
                   AND map.require_goods_cust_code = pp.require_goods_cust_code
                   AND map.brand_group = pp.brand_group
                   AND map.is_special = pp.is_special
                   /*连接日历表*/
                        LEFT JOIN kt_plan_time_master pwt ON pp.cal_mode = 'PW'
                   AND osd.eta_demand_date >= DATE(pwt.pw_start_date)
                   AND DATE(pwt.pw_end_date) >= osd.eta_demand_date
                        LEFT JOIN (SELECT DISTINCT w_end_date, w_start_date FROM kt_plan_time_master) wt
                                  ON pp.cal_mode = 'W'
                                      AND osd.eta_demand_date >= DATE(wt.w_start_date)
                                      AND DATE(wt.w_end_date) >= osd.eta_demand_date
               WHERE map.customer_model IS NOT NULL
                 AND pp.inner_po_value_type = 'PISO'
               GROUP BY pp.customer_model,
                        pp.require_addr,
                        pp.require_goods_mode,
                        pp.require_goods_cust_code,
                        pp.brand_group,
                        pp.is_special,
                        map.is_bulk,
                        map.appointed_factory,
                        IF(pp.cal_mode = 'PW', DATE(pwt.pw_start_date), DATE(wt.w_start_date))) AS tab ON
        tab.customer_model = pbf.customer_model
            AND tab.require_addr = pbf.require_addr
            AND tab.require_goods_mode = pbf.require_goods_mode
            AND tab.require_goods_cust_code = pbf.require_goods_cust_code
            AND tab.brand_group = pbf.brand_group
            AND tab.is_special = pbf.is_special
            AND tab.is_bulk = pbf.is_bulk
            AND tab.appointed_factory = pbf.appointed_factory
            AND tab.bg_demand_time = pbf.bg_demand_time
SET pbf.inner_po_qty=tab.qty
WHERE tab.customer_model IS NOT NULL