-- <!--内部PO实际收货第一部分：周一之前的部分-->
        (
            SELECT
            pb.id,
            pb.customer_model,
            pb.require_addr,
            pb.require_goods_mode,
            pb.require_goods_cust_code,
            pb.brand_group,
            pb.is_special,
            pb.is_bulk,
            pb.bg_demand_time,
            tab.qty
            FROM dp_require_plan_base AS pb
            LEFT JOIN (
                SELECT
                pp.customer_model,
                pp.require_addr,
                pp.require_goods_mode,
                pp.require_goods_cust_code,
                pp.brand_group,
                pp.is_special,
                map.is_bulk,
                IF(pp.cal_mode='PW', DATE(pwt.pw_start_date), DATE(wt.w_start_date)) AS bg_demand_time,
                sum(osd.week_delivery_qty) AS qty
                FROM dp_po_closed_cbu AS osd
                /*连接 需求map*/
                LEFT JOIN dp_require_plan_demand_map AS map
                        ON map.brand_group=osd.brand_group
                        AND map.is_special=osd.is_special
                        AND map.is_bulk=osd.is_bulk
                        AND map.appointed_factory=''
                        AND map.demand_model=osd.whole_code
                        AND map.demand_cust_code=IF((osd.require_addr='CN' AND osd.brand_group='自有品牌' AND osd.is_special='Y')
                                                            OR (osd.require_addr='CN' AND osd.brand_group='ODM'),
                                                        osd.require_goods_cust_code,
                                                        'DUM_CUST')
                        AND map.demand_addr=osd.require_addr
                        AND map.demand_mode=osd.require_goods_mode
                /*连接 参数表*/
                LEFT JOIN dp_require_plan_param pp ON map.customer_model=pp.customer_model
                            AND map.require_addr=pp.require_addr
                            AND map.require_goods_mode=pp.require_goods_mode
                            AND map.require_goods_cust_code=pp.require_goods_cust_code
                            AND map.brand_group=pp.brand_group
                            AND map.is_special=pp.is_special
                /*连接日历表，将 实际交付日期 按照日历模式，转化为 所在周的周开始时间*/
                LEFT JOIN kt_plan_time_master AS pwt ON pp.cal_mode='PW'
                        AND DATE(osd.actual_delivery_date) >= DATE(pwt.pw_start_date)
                        AND DATE(pwt.pw_end_date) >= DATE(osd.actual_delivery_date)
                LEFT JOIN (SELECT DISTINCT w_end_date, w_start_date FROM kt_plan_time_master) AS wt ON pp.cal_mode='W'
                        AND DATE(osd.actual_delivery_date) >= DATE(wt.w_start_date)
                        AND DATE(wt.w_end_date) >= DATE(osd.actual_delivery_date)
                WHERE osd.week_delivery_qty != 0 AND osd.is_monday_delivery='N'
                    AND NOT (pp.brand_group='ODM' AND pp.require_addr != 'CN')
                    AND map.customer_model IS NOT NULL
                    AND pp.customer_model IS NOT NULL
                GROUP BY
                pp.customer_model,
                pp.require_addr,
                pp.require_goods_mode,
                pp.require_goods_cust_code,
                pp.brand_group,
                pp.is_special,
                map.is_bulk,
                IF(pp.cal_mode='PW', DATE(pwt.pw_start_date), DATE(wt.w_start_date))
            ) AS tab ON tab.customer_model=pb.customer_model
                    AND tab.require_addr=pb.require_addr
                    AND tab.require_goods_mode=pb.require_goods_mode
                    AND tab.require_goods_cust_code=pb.require_goods_cust_code
                    AND tab.brand_group=pb.brand_group
                    AND tab.is_special=pb.is_special
                    AND tab.is_bulk=pb.is_bulk
                    AND tab.bg_demand_time=pb.bg_demand_time
                    AND pb.history_flag=1
            WHERE tab.customer_model IS NOT NULL
        ) ;


    -- <!--内部PO实际收货第二部分：周一到周二变化的部分-->
        (
            SELECT
            pb.id,
            pb.customer_model,
            pb.require_addr,
            pb.require_goods_mode,
            pb.require_goods_cust_code,
            pb.brand_group,
            pb.is_special,
            pb.is_bulk,
            pb.bg_demand_time,
            tab.qty
            FROM dp_require_plan_base AS pb
            LEFT JOIN (
                SELECT
                id,
                ROW_NUMBER() OVER(PARTITION BY customer_model,
                                            require_addr,
                                            require_goods_mode,
                                            require_goods_cust_code,
                                            brand_group,
                                            is_special,
                                            is_bulk
                                            ORDER BY bg_demand_time DESC) AS num
                FROM dp_require_plan_base
                WHERE history_flag='1'
            ) AS mxhb ON mxhb.num=1 AND pb.id=mxhb.id
            LEFT JOIN (
                SELECT
                pp.customer_model,
                pp.require_addr,
                pp.require_goods_mode,
                pp.require_goods_cust_code,
                pp.brand_group,
                pp.is_special,
                map.is_bulk,
                sum(osd.week_delivery_qty) AS qty
                FROM dp_po_closed_cbu AS osd
                /*连接 需求map*/
                LEFT JOIN dp_require_plan_demand_map AS map ON map.brand_group=osd.brand_group
                        AND map.is_special=osd.is_special
                        AND map.is_bulk=osd.is_bulk
                        AND map.appointed_factory=''
                        AND map.demand_model=osd.whole_code
                        AND map.demand_cust_code=IF((osd.require_addr='CN' AND osd.brand_group='自有品牌' AND osd.is_special='Y')
                                                        OR (osd.require_addr='CN' AND osd.brand_group='ODM'),
                                                    osd.require_goods_cust_code,
                                                    'DUM_CUST')
                        AND map.demand_addr=osd.require_addr
                        AND map.demand_mode=osd.require_goods_mode
                /*连接 参数表*/
                LEFT JOIN dp_require_plan_param AS pp ON map.customer_model=pp.customer_model
                        AND map.require_addr=pp.require_addr
                        AND map.require_goods_mode=pp.require_goods_mode
                        AND map.require_goods_cust_code=pp.require_goods_cust_code
                        AND map.brand_group=pp.brand_group
                        AND map.is_special=pp.is_special
                WHERE osd.week_delivery_qty != 0 AND osd.is_monday_delivery='Y'
                    AND NOT(pp.brand_group='ODM' AND pp.require_addr != 'CN')
                    AND map.customer_model IS NOT NULL
                    AND pp.customer_model IS NOT NULL
                GROUP BY
                pp.customer_model,
                pp.require_addr,
                pp.require_goods_mode,
                pp.require_goods_cust_code,
                pp.brand_group,
                pp.is_special,
                map.is_bulk
            ) AS tab ON tab.customer_model=pb.customer_model
                AND tab.require_addr=pb.require_addr
                AND tab.require_goods_mode=pb.require_goods_mode
                AND tab.require_goods_cust_code=pb.require_goods_cust_code
                AND tab.brand_group=pb.brand_group
                AND tab.is_special=pb.is_special
                AND tab.is_bulk=pb.is_bulk
            WHERE mxhb.id IS NOT NULL AND tab.customer_model IS NOT NULL
        ) ;




        UPDATE dp_require_plan_base AS pb
        LEFT JOIN
        (
            SELECT
            t.id,
            SUM(t.qty) AS qty
            FROM (
                SELECT
                p1.id,
                p1.qty
                -- 第一段SQL
                FROM <include refid="innerPoActualReceiveQtyP1"/> AS p1
                UNION ALL
                SELECT
                p2.id,
                p2.qty
                -- 第二段SQL
                FROM <include refid="innerPoActualReceiveQtyP2"/> AS p2
            ) AS t
            GROUP BY
            t.id
        ) AS tab ON pb.id=tab.id
        SET
        pb.inner_po_actual_receive_qty=tab.qty
        WHERE tab.id IS NOT NULL



