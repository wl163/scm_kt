SELECT
            map.brand_group,
            map.is_special,
            map.is_bulk,
            map.customer_model,
            map.require_addr,
            map.require_goods_mode,
            map.require_goods_cust_code,
            DATE(IF(pp.cal_mode='W', wt.w_start_date, pwt.pw_start_date)) AS bg_demand_time
            FROM (
                SELECT
                brand_group,
                is_special,
                is_bulk,
                customer_model,
                require_addr,
                require_goods_mode,
                require_goods_cust_code
                FROM dp_require_plan_demand_map
                GROUP BY
                brand_group,
                is_special,
                is_bulk,
                customer_model,
                require_addr,
                require_goods_mode,
                require_goods_cust_code
                UNION
                SELECT
                brand_group,
                is_special,
                is_bulk,
                customer_model,
                require_addr,
                require_goods_mode,
                require_goods_cust_code
                FROM dp_require_plan_supply_map
                GROUP BY
                brand_group,
                is_special,
                is_bulk,
                customer_model,
                require_addr,
                require_goods_mode,
                require_goods_cust_code
            ) AS map
            LEFT JOIN dp_require_plan_param AS pp ON map.brand_group=pp.brand_group
                            AND map.is_special=pp.is_special
                            AND map.customer_model=pp.customer_model
                            AND map.require_addr=pp.require_addr
                            AND map.require_goods_mode=pp.require_goods_mode
                            AND map.require_goods_cust_code=pp.require_goods_cust_code
            LEFT JOIN (SELECT DISTINCT w_start_date,w_end_date FROM kt_plan_time_master) AS wt ON pp.cal_mode='W'
                                                                                    AND DATE(wt.w_start_date) >= pp.plan_start_time
                                                                                    AND pp.plan_end_time >= DATE(wt.w_end_date)
            LEFT JOIN kt_plan_time_master AS pwt ON pp.cal_mode='PW'
                                            AND DATE(pwt.pw_start_date) >= pp.plan_start_time
                                            AND pp.plan_end_time >= DATE(pwt.pw_end_date)
            WHERE IF(pp.cal_mode='W', wt.w_start_date, pwt.pw_start_date) IS NOT NULL;


delete
from dp_require_plan_base pb
where exists(select 1
             from dp_require_plan_param pp
             where pb.customer_model = pp.customer_model
               and pb.require_addr = pp.require_addr
               and pb.require_goods_mode = pp.require_goods_mode
               and pb.require_goods_cust_code = pp.require_goods_cust_code
               and pb.brand_group = pp.brand_group
               and pb.is_special = pp.is_special
               and pb.is_bulk = pp.is_bulk
               and pb.bg_demand_time < pp.plan_start_time);



select * from v_rtf_detail_pre;
select * from dp_require_plan_base_archive;
select plan_version from  dp_require_plan_base where ifnull(plan_version,'')<>''  order by plan_version desc  ;

# SELECT  w_start_date,w_end_date,pw_start_date,pw_end_date, t.* FROM kt_plan_time_master t where cal_year='2025'


/*-- 新建的备份表*/
select * from dp_require_plan_base_archive_data;
select * from dp_require_plan_base_factory_archive_data;
select * from dp_require_plan_base_plan_bom_archive_data;
select * from dp_require_plan_base_factory_plan_bom_archive_data;




