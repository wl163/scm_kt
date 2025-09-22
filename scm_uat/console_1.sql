# v1/0/engine-inventory/pageList
select
        distinct
        t.require_addr,
        t.require_goods_mode,
        t.require_goods_cust_code,
        t.customer_model,
        tm.week,
        t.is_bulk as isBulk,
        t.is_special as isSpecial,
        t.brand_group as brandGroup,


        t.last_final_require_plan_qty as lastFinalRequirePlanQty,
        t.last_rtf_synergy_supply_promise_qty as lastRtfSynergySupplyPromiseQty,
        t.inner_po_overdue_co_qty as innerPoOverdueCoQty,
        t.open_inner_po_qty as openPoQty,
        t.initialt_require_ne_qty as netForecastQty,
        t.initial_require_plan_qty as initialRequirePlanQty,
        t.sales_forecast_qty as sellInQty

        from dp_require_plan_base t
        left join (select distinct t.std_part_week as week,t.pw_start_date, t.pw_end_date from kt_plan_time_master t) tm
        on tm.pw_start_date <=t.bg_demand_time and tm.pw_end_date >=t.bg_demand_time
        where t.require_addr ='CN'  and t.require_goods_mode='DOM' and t.is_special ='N' and t.brand_group='自有品牌' ;


select *  from kt_plan_time_master;
select plan_start_time,plan_end_time,cal_mode,t.* from dp_require_plan_param t;
select distinct cal_mode from dp_require_plan_param t;

