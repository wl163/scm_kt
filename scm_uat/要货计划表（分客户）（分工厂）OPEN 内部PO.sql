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
                                            WHERE ps.org_id = 'KT')
                                            AS ps
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
WHERE tab.customer_model IS NOT NULL;




-- /*参数总表匹配*/
(
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
    WHERE ps.org_id = 'KT');





/** ****************************** MO ******************************************/
UPDATE dp_require_plan_base_factory_plan_bom AS pbfpb
        LEFT JOIN (
            SELECT
            map.brand_group,
            map.is_special,
            map.appointed_factory,
            map.customer_model,
            map.require_addr,
            map.require_goods_mode,
            map.require_goods_cust_code,
            map.whole_in_out,
            map.bulk_require_goods_mode,
            DATE(IF(pppb.cal_mode='W', wt.w_start_date, pwt.pw_start_date)) AS bg_demand_time,
            SUM(po.open_qty) AS open_qty
            FROM (
                SELECT
                psoc.brand_group,
                psoc.is_special,
                IFNULL(psoc.appointed_factory, '') AS appointed_factory,
                psoc.whole_code AS demand_model,
                psoc.require_addr AS demand_addr,
                psoc.require_goods_mode AS demand_mode,
                (
                    CASE when (psoc.require_addr!='CN' AND psoc.brand_group='自有品牌')
                                OR (psoc.require_addr='CN' AND psoc.brand_group='自有品牌' AND psoc.is_special='N') THEN 'DUM_CUST'
                        ELSE IFNULL(psoc.require_goods_cust_code,'') END
                ) AS demand_cust_code,
                floor(psoc.open_qty) AS open_qty,
                psoc.eta_demand_date
                FROM dp_po_so_open_cbu AS psoc
                WHERE psoc.org_id='KT' AND psoc.open_qty!=0 AND psoc.inner_po_overdue_flag=0
                    AND IFNULL(psoc.brand_group, '')!=''
                    AND IFNULL(psoc.is_special, '')!=''
                    AND IFNULL(psoc.whole_code, '')!=''
                    AND IFNULL(psoc.require_addr, '')!=''
                    AND IFNULL(psoc.require_goods_mode, '')!=''
                    AND EXISTS (
                        SELECT 1
                        FROM (
            /*参数总表匹配*/
            SELECT
            ps.brand_group,
            ps.is_special,
            ps.require_goods_mode,
            (
                /*匹配模式，1加上要货地点，0 去掉要货地点*/
                CASE WHEN ps.require_addr!='NOT CN' THEN 1
                    WHEN ps.bg_code='ALL' THEN 0
                    ELSE 1 END
            ) AS match_flag,
            IFNULL(
                CASE WHEN ps.require_addr!='NOT CN' THEN ps.require_addr
                    WHEN ps.bg_code='ALL' THEN ''
                    ELSE org.country_code END
            , '') AS require_addr,
            ps.snap_param_one,
            ps.snap_param_two
            FROM dp_require_plan_summary AS ps
            LEFT JOIN scm_market_org AS org ON org.org_id='KT' AND ps.bg_code=org.bg_code AND ps.brand_group=org.brand_name
            WHERE ps.org_id='KT'
        )AS dps
                        WHERE psoc.brand_group=dps.brand_group
                            AND psoc.is_special=dps.is_special
                            AND psoc.require_goods_mode=dps.require_goods_mode
                            AND IF(dps.match_flag=1, psoc.require_addr=dps.require_addr, psoc.require_addr!='CN')
                            AND psoc.snap_param_one=dps.snap_param_one
                            AND psoc.snap_param_two=dps.snap_param_two
                    )
            ) AS po
            LEFT JOIN dp_require_plan_demand_map_plan_bom AS map ON map.org_id='KT'
                                                                AND po.brand_group=map.brand_group
                                                                AND po.is_special=map.is_special
                                                                AND po.appointed_factory=map.appointed_factory
                                                                AND po.demand_model=map.demand_model
                                                                AND po.demand_addr=map.demand_addr
                                                                AND po.demand_mode=map.demand_mode
                                                                AND po.demand_cust_code=map.demand_cust_code
            LEFT JOIN dp_require_plan_param_plan_bom AS pppb ON pppb.org_id='KT'
                                                        AND map.brand_group=pppb.brand_group
                                                        AND map.is_special=pppb.is_special
                                                        AND map.customer_model=pppb.customer_model
                                                        AND map.require_addr=pppb.require_addr
                                                        AND map.require_goods_mode=pppb.require_goods_mode
                                                        AND map.require_goods_cust_code=pppb.require_goods_cust_code
                                                        AND map.whole_in_out=pppb.whole_in_out
                                                        AND map.bulk_require_goods_mode=pppb.bulk_require_goods_mode
            LEFT JOIN (SELECT DISTINCT w_start_date,w_end_date FROM kt_plan_time_master) AS wt ON pppb.cal_mode='W'
                                                                                    AND po.eta_demand_date >= DATE(wt.w_start_date)
                                                                                    AND DATE(wt.w_end_date) >= po.eta_demand_date
            LEFT JOIN kt_plan_time_master AS pwt ON pppb.cal_mode='PW'
                                        AND po.eta_demand_date >= DATE(pwt.pw_start_date)
                                        AND DATE(pwt.pw_end_date) >= po.eta_demand_date
            WHERE map.brand_group IS NOT NULL AND pppb.brand_group IS NOT NULL
                AND pppb.overdue_demand_type='2' AND pppb.inner_po_value_type='MO'
                AND IF(pppb.cal_mode='W', wt.w_start_date, pwt.pw_start_date) IS NOT NULL
            GROUP BY
            map.brand_group,
            map.is_special,
            map.appointed_factory,
            map.customer_model,
            map.require_addr,
            map.require_goods_mode,
            map.require_goods_cust_code,
            map.whole_in_out,
            map.bulk_require_goods_mode,
            DATE(IF(pppb.cal_mode='W', wt.w_start_date, pwt.pw_start_date))
        ) AS td ON pbfpb.org_id='KT'
                AND pbfpb.brand_group=td.brand_group
                AND pbfpb.is_special=td.is_special
                AND pbfpb.appointed_factory=td.appointed_factory
                AND pbfpb.customer_model=td.customer_model
                AND pbfpb.require_addr=td.require_addr
                AND pbfpb.require_goods_mode=td.require_goods_mode
                AND pbfpb.require_goods_cust_code=td.require_goods_cust_code
                AND pbfpb.whole_in_out=td.whole_in_out
                AND pbfpb.bulk_require_goods_mode=td.bulk_require_goods_mode
                AND pbfpb.bg_demand_time=td.bg_demand_time
        SET
        pbfpb.open_inner_po_qty=td.open_qty
        WHERE td.brand_group IS NOT NULL;



/*    initial_require_net_qty             int                      null comment '初版净要货',
    final_require_net_qty               int                      null comment '终版净要货',
    final_require_net_qty          int                      null comment '上期终版净要货',
    last_rtf_synergy_supply_promise_qty int                      null comment '上期终版RTF',
    open_inner_po_qty                   int                      null comment 'OPEN 内部PO',
    inner_po_qty                        int                      null comment '内部PO数量',*/

SELECT initial_require_net_qty,
       final_require_net_qty,
       final_require_net_qty,
       last_rtf_synergy_supply_promise_qty,
       open_inner_po_qty,
       inner_po_qty,
       pp.net_require_init_flag,
       fpb.*
FROM dp_require_plan_base_factory_plan_bom fpb
         left join dp_require_plan_param_plan_bom pp
                   on fpb.brand_group = pp.brand_group
                       and fpb.is_special = pp.is_special
                       and fpb.customer_model = pp.customer_model
                       and fpb.require_addr = pp.require_addr
                       and fpb.require_goods_cust_code = pp.require_goods_cust_code
                       and fpb.require_goods_mode = pp.require_goods_mode
where pp.net_require_init_flag = 1 and pp.inner_po_value_type= 'PISO';


select inner_po_value_type from dp_require_plan_param_plan_bom where brand_group='自有品牌' and is_special='N' and customer_model='Z4U20101024343'
and require_addr='BR' and require_goods_cust_code='DUM_CUST' and require_goods_mode='DOM' ;

select final_require_net_qty_w_fnl from MID_M_NET_REQUIRE_PLAN;

select * from dp_require_plan_base_factory ;
select * from dp_require_plan_param_plan_bom;







-- 初版净要货取值
SELECT
        pbfpb.id,
        pbfpb.brand_group,
        pbfpb.is_special,
        pbfpb.appointed_factory,
        pbfpb.customer_model,
        pbfpb.require_addr,
        pbfpb.require_goods_mode,
        pbfpb.require_goods_cust_code,
        pbfpb.whole_in_out,
        pbfpb.bulk_require_goods_mode,
        pbfpb.bg_demand_time,
        IFNULL(pbpb.last_final_require_net_qty, 0) AS base_last_final_require_net_qty,
        IFNULL(pbfpb.last_final_require_net_qty, 0) AS last_final_require_net_qty,
        tab.qty
        FROM dp_require_plan_base_factory_plan_bom AS pbfpb
        LEFT JOIN dp_require_plan_base_plan_bom AS pbpb ON pbfpb.org_id='KT' AND pbpb.org_id='KT'
                                            AND pbfpb.brand_group=pbpb.brand_group
                                            AND pbfpb.is_special=pbpb.is_special
                                            AND pbfpb.customer_model=pbpb.customer_model
                                            AND pbfpb.require_addr=pbpb.require_addr
                                            AND pbfpb.require_goods_mode=pbpb.require_goods_mode
                                            AND pbfpb.require_goods_cust_code=pbpb.require_goods_cust_code
                                            AND pbfpb.whole_in_out=pbpb.whole_in_out
                                            AND pbfpb.bulk_require_goods_mode=pbpb.bulk_require_goods_mode
                                            AND pbfpb.bg_demand_time=pbpb.bg_demand_time
                                            AND pbfpb.history_flag=0
        LEFT JOIN (
            SELECT
            map.brand_group,
            map.is_special,
            map.customer_model,
            map.require_addr,
            map.require_goods_mode,
            map.require_goods_cust_code,
            map.whole_in_out,
            map.bulk_require_goods_mode,
            IF(pppb.cal_mode='PW',date(pwt.pw_start_date),date(wt.w_start_date)) as bg_demand_time,
            SUM(osd.final_require_net_qty_w_fnl) as qty
            FROM (
                SELECT
                nrp.brand_group,
                nrp.is_special,
                nrp.customer_model AS demand_model,
                nrp.require_addr AS demand_addr,
                nrp.require_goods_mode AS demand_mode,
                nrp.require_goods_cust_code AS demand_cust_code,
                nrp.bg_demand_time,
                nrp.final_require_net_qty_w_fnl
                FROM mid_m_net_require_plan AS nrp
                WHERE nrp.org_id='KT' AND nrp.final_require_net_qty_w_fnl!=0
                    AND nrp.bg_demand_time IS NOT NULL
            ) AS osd
            LEFT JOIN (
                SELECT
                t.*,
                ROW_NUMBER() OVER(PARTITION BY t.brand_group,
                                            t.is_special,
                                            t.demand_model,
                                            t.demand_addr,
                                            t.demand_mode,
                                            t.demand_cust_code
                              ORDER BY t.appointed_factory) AS num
                FROM dp_require_plan_demand_map_plan_bom AS t
            ) AS map ON map.org_id='KT' AND map.num=1
                    AND osd.brand_group=map.brand_group
                    AND osd.is_special=map.is_special
                    AND osd.demand_model=map.demand_model
                    AND osd.demand_addr=map.demand_addr
                    AND osd.demand_mode=map.demand_mode
                    AND osd.demand_cust_code=map.demand_cust_code
            /*连接 参数表*/
            LEFT JOIN dp_require_plan_param_plan_bom AS pppb ON pppb.org_id='KT'
                                            AND map.brand_group=pppb.brand_group
                                            AND map.is_special=pppb.is_special
                                            AND map.customer_model=pppb.customer_model
                                            AND map.require_addr=pppb.require_addr
                                            AND map.require_goods_mode=pppb.require_goods_mode
                                            AND map.require_goods_cust_code=pppb.require_goods_cust_code
                                            AND map.whole_in_out=pppb.whole_in_out
                                            AND map.bulk_require_goods_mode=pppb.bulk_require_goods_mode
            /*接日历表*/
            LEFT JOIN kt_plan_time_master pwt ON pppb.cal_mode='PW'
                                         AND osd.bg_demand_time>=date(pwt.pw_start_date)
                                         AND date(pwt.pw_end_date)>=osd.bg_demand_time
            LEFT JOIN (SELECT DISTINCT w_end_date,w_start_date FROM kt_plan_time_master) wt ON pppb.cal_mode='W'
                                                                                 AND osd.bg_demand_time>=date(wt.w_start_date)
                                                                                 AND date(wt.w_end_date)>=osd.bg_demand_time
            WHERE pppb.customer_model IS NOT NULL
                AND pppb.inner_po_value_type= 'PISO'
                AND pppb.net_require_init_flag='1'
            GROUP BY
            map.brand_group,
            map.is_special,
            map.customer_model,
            map.require_addr,
            map.require_goods_mode,
            map.require_goods_cust_code,
            map.whole_in_out,
            map.bulk_require_goods_mode,
            IF(pppb.cal_mode='PW',date(pwt.pw_start_date),date(wt.w_start_date))
        ) AS tab ON tab.brand_group=pbfpb.brand_group
                AND tab.is_special=pbfpb.is_special
                AND tab.customer_model=pbfpb.customer_model
                AND tab.require_addr=pbfpb.require_addr
                AND tab.require_goods_mode=pbfpb.require_goods_mode
                AND tab.require_goods_cust_code=pbfpb.require_goods_cust_code
                AND tab.whole_in_out=pbfpb.require_goods_cust_code
                AND tab.bulk_require_goods_mode=pbfpb.require_goods_cust_code
                AND tab.bg_demand_time=pbfpb.bg_demand_time
        WHERE pbpb.customer_model IS NOT NULL AND tab.customer_model IS NOT NULL


select upper('DATA_FUNNEL_branch_office');

select * from sop_first_version_rtf_detail;
select * from sop_rtf_detail_upload;





