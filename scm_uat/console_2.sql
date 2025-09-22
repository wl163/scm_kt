update dp_require_plan_base as pb
        LEFT JOIN
        (

            /*获取内销哪些数据需要更新*/
            SELECT
            pb.id,
            inv.rdc1Qty,
            inv.rdc2Qty,
            inv.cdcQty
            FROM
            (
                /*汇总期初库存数据*/
                SELECT
                psm.brand_group,
                psm.is_special,
                psm.is_bulk,
                psm.customer_model,
                psm.require_addr,
                psm.require_goods_mode,
                psm.require_goods_cust_code,
                pp.plan_start_time,
                SUM(inv.rdc_inv_total) as rdc1Qty,
                sum(inv.plat_inv_total) as rdc2Qty,
                sum(inv.cdc_inv_total) as cdcQty
                /*期初库存日期的前一天*/
                FROM
                (
                select rdc_inv_total,plat_inv_total,cdc_inv_total,whole_code,logic_whse_code,inv_last_update_time,sales_org_code from v_whole_machine_inv_pre
                where whole_code is not null
                and logic_whse_code is not null
                ) as inv
                LEFT JOIN dp_require_plan_supply_map as psm
                on psm.supply_model=inv.whole_code
                    and psm.supply_addr=inv.logic_whse_code
            	    and psm.demand_addr=inv.sales_org_code
                    and psm.demand_mode='DOM'
                    and psm.brand_group = '自有品牌'
                    and psm.is_special = 'N'
                    and psm.is_bulk = 'N'
                    and psm.appointed_factory = ''
                LEFT JOIN dp_require_plan_param as pp
                on psm.customer_model=pp.customer_model
                    and psm.require_addr=pp.require_addr
                    and psm.require_goods_mode=pp.require_goods_mode
                    and psm.require_goods_cust_code=pp.require_goods_cust_code
                    and psm.brand_group = pp.brand_group
                    and psm.is_special = pp.is_special
                WHERE psm.id is not null
                    and inv.inv_last_update_time = DATE_SUB(pp.begining_inv_date, INTERVAL 1 DAY)
                GROUP BY
                psm.brand_group,
                psm.is_special,
                psm.is_bulk,
                psm.customer_model,
                psm.require_addr,
                psm.require_goods_mode,
                psm.require_goods_cust_code,
                pp.plan_start_time
            ) as inv
            LEFT JOIN dp_require_plan_base as pb
            on inv.customer_model=pb.customer_model
            and inv.require_addr=pb.require_addr
            and inv.require_goods_mode=pb.require_goods_mode
            and inv.require_goods_cust_code=pb.require_goods_cust_code
            and pb.bg_demand_time=inv.plan_start_time
            and inv.is_special = pb.is_special
            and inv.brand_group = pb.brand_group
            and inv.is_bulk = pb.is_bulk
            WHERE pb.customer_model is not null
        ) as t on t.id=pb.id
        set pb.rdc1_inv_total=t.rdc1Qty,
        pb.rdc2_inv_total=t.rdc2Qty,
        pb.cdc_inv_total = t.cdcQty,
        pb.last_update_date=NOW()
        WHERE t.id is not null