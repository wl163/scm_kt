	-- 外销odm
	select
		'外销ODM' as BG,
		tmo.region_name as 国家,
		t.demand_type,
		t.brand_group,
		t.is_special,
		t.require_goods_mode,
		t.customer_model,
		t.bg_demand_time,
		t.last_update_date,
		sum(t.final_require_plan_qty) qty
	from
		dp_require_plan_output t
	left join (
		select
			distinct country_code ,
			region_name
		from
			scm_market_org
		where 	brand_name = 'ODM'
                     ) tmo
	on
		tmo.country_code = t.require_addr
	WHERE
		t.brand_group = 'ODM'
		and t.require_addr != 'CN'
		and t.require_goods_mode = 'FOB'
		and t.is_special = 'N'
		and t.final_require_plan_qty != 0
	group by
		tmo.region_name ,
		t.demand_type,
		t.brand_group,
		t.is_special,
		t.require_goods_mode,
		t.customer_model,
		t.bg_demand_time,
		t.last_update_date;



select * from sop_week_commitment_plan_detail_report;
select * from sop_week_commitment_plan_detail_report_wide ;
select *from sop_week_commitment_plan_detail_demand_ratio ;

select t.proto_type_code, t.whole_code,t.* from sp_order_offset_week_result  t