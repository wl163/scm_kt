# 周 英俊

with his as (
select
	t.plan_version,
	t.require_addr,
	t.require_goods_mode,
	t.require_goods_cust_code,
	t.customer_model,
	t.bulk_require_goods_mode,
	t.appointed_factory,
	t.final_require_plan_factory_qty,
	t.final_require_net_qty,
	t.inner_po_qty,
	t.brand_group,
	t.is_special,
	tm.std_part_week,
	tm.cal_month
from
	dp_require_plan_base_factory_archive_data t
left join (
	select
		distinct t.std_part_week,
		CONVERT (t.pw_start_date,
		date) as date,
		CONVERT (t.pw_end_date,
		date) as dateEnd,
		cal_month
	from
		kt_plan_time_master t
	where
		t.std_part_week in ( '2524' , '2525' ,'2527B' ) ) tm on
	t.bg_demand_time >= tm.date
	and t.bg_demand_time <= tm.dateEnd
WHERE
	( (t.plan_version = '202525'
		and tm.std_part_week = '2524')
	or (t.plan_version = '202526'
		and tm.std_part_week = '2525')
	or (t.plan_version = '202527'
		and tm.std_part_week = '2527B') ) )
select
	ifnull(tf.region_name, "") as regionName,
	ifnull(tf.require_addr, "") as requireAddr,
	ifnull(tf.country_name_cn, "") as countryNameCn,
	ifnull(tf.require_goods_mode, "") as requireGoodsMode,
	ifnull(tf.require_goods_cust_code, "") as requireGoodsCustCode,
	ifnull(tf.customer_model, "") as customerModel,
	ifnull(tf.bulk_require_goods_mode, "") as bulkRequireGoodsMode,
	ifnull(tf.appointed_factory, "") as appointedFactory,
	ifnull(tf.plan_version, "") as versionId,
	ifnull(tf.brand_group, "") as brandGroup,
	ifnull(tf.is_special, "") as isSpecial ,
	sum(case tf.cal_month when '202504' then tf.final_require_plan_factory_qty else 0 end) as "202504-要货计划" ,
	sum(case tf.cal_month when '202505' then tf.final_require_plan_factory_qty else 0 end) as "202505-要货计划" ,
	sum(case tf.cal_month when '202506' then tf.final_require_plan_factory_qty else 0 end) as "202506-要货计划" ,
	sum(case tf.cal_month when '202507' then tf.final_require_plan_factory_qty else 0 end) as "202507-要货计划" ,
	sum(case tf.cal_month when '202508' then tf.final_require_plan_factory_qty else 0 end) as "202508-要货计划" ,
	sum(case tf.std_part_week when '2514B' then tf.final_require_plan_factory_qty else 0 end) as "2514B-要货计划" ,
	sum(case tf.std_part_week when '2515' then tf.final_require_plan_factory_qty else 0 end) as "2515-要货计划" ,
	sum(case tf.std_part_week when '2516' then tf.final_require_plan_factory_qty else 0 end) as "2516-要货计划" ,
	sum(case tf.std_part_week when '2517' then tf.final_require_plan_factory_qty else 0 end) as "2517-要货计划" ,
	sum(case tf.std_part_week when '2518A' then tf.final_require_plan_factory_qty else 0 end) as "2518A-要货计划" ,
	sum(case tf.std_part_week when '2518B' then tf.final_require_plan_factory_qty else 0 end) as "2518B-要货计划" ,
	sum(case tf.std_part_week when '2519' then tf.final_require_plan_factory_qty else 0 end) as "2519-要货计划" ,
	sum(case tf.std_part_week when '2520' then tf.final_require_plan_factory_qty else 0 end) as "2520-要货计划" ,
	sum(case tf.std_part_week when '2521' then tf.final_require_plan_factory_qty else 0 end) as "2521-要货计划" ,
	sum(case tf.std_part_week when '2522A' then tf.final_require_plan_factory_qty else 0 end) as "2522A-要货计划" ,
	sum(case tf.std_part_week when '2522B' then tf.final_require_plan_factory_qty else 0 end) as "2522B-要货计划" ,
	sum(case tf.std_part_week when '2523' then tf.final_require_plan_factory_qty else 0 end) as "2523-要货计划" ,
	sum(case tf.std_part_week when '2524' then tf.final_require_plan_factory_qty else 0 end) as "2524-要货计划" ,
	sum(case tf.std_part_week when '2525' then tf.final_require_plan_factory_qty else 0 end) as "2525-要货计划" ,
	sum(case tf.std_part_week when '2526' then tf.final_require_plan_factory_qty else 0 end) as "2526-要货计划" ,
	sum(case tf.std_part_week when '2527A' then tf.final_require_plan_factory_qty else 0 end) as "2527A-要货计划" ,
	sum(case tf.std_part_week when '2527B' then tf.final_require_plan_factory_qty else 0 end) as "2527B-要货计划" ,
	sum(case tf.std_part_week when '2528' then tf.final_require_plan_factory_qty else 0 end) as "2528-要货计划" ,
	sum(case tf.std_part_week when '2529' then tf.final_require_plan_factory_qty else 0 end) as "2529-要货计划" ,
	sum(case tf.std_part_week when '2530' then tf.final_require_plan_factory_qty else 0 end) as "2530-要货计划" ,
	sum(case tf.std_part_week when '2531A' then tf.final_require_plan_factory_qty else 0 end) as "2531A-要货计划" ,
	sum(case tf.std_part_week when '2531B' then tf.final_require_plan_factory_qty else 0 end) as "2531B-要货计划" ,
	sum(case tf.std_part_week when '2532' then tf.final_require_plan_factory_qty else 0 end) as "2532-要货计划" ,
	sum(case tf.std_part_week when '2533' then tf.final_require_plan_factory_qty else 0 end) as "2533-要货计划" ,
	sum(case tf.std_part_week when '2534' then tf.final_require_plan_factory_qty else 0 end) as "2534-要货计划" ,
	sum(case tf.std_part_week when '2535' then tf.final_require_plan_factory_qty else 0 end) as "2535-要货计划" ,
	sum(case tf.cal_month when '202504' then tf.final_require_net_qty else 0 end) as "202504-净预测" ,
	sum(case tf.cal_month when '202505' then tf.final_require_net_qty else 0 end) as "202505-净预测" ,
	sum(case tf.cal_month when '202506' then tf.final_require_net_qty else 0 end) as "202506-净预测" ,
	sum(case tf.cal_month when '202507' then tf.final_require_net_qty else 0 end) as "202507-净预测" ,
	sum(case tf.cal_month when '202508' then tf.final_require_net_qty else 0 end) as "202508-净预测" ,
	sum(case tf.std_part_week when '2514B' then tf.final_require_net_qty else 0 end) as "2514B-净预测" ,
	sum(case tf.std_part_week when '2515' then tf.final_require_net_qty else 0 end) as "2515-净预测" ,
	sum(case tf.std_part_week when '2516' then tf.final_require_net_qty else 0 end) as "2516-净预测" ,
	sum(case tf.std_part_week when '2517' then tf.final_require_net_qty else 0 end) as "2517-净预测" ,
	sum(case tf.std_part_week when '2518A' then tf.final_require_net_qty else 0 end) as "2518A-净预测" ,
	sum(case tf.std_part_week when '2518B' then tf.final_require_net_qty else 0 end) as "2518B-净预测" ,
	sum(case tf.std_part_week when '2519' then tf.final_require_net_qty else 0 end) as "2519-净预测" ,
	sum(case tf.std_part_week when '2520' then tf.final_require_net_qty else 0 end) as "2520-净预测" ,
	sum(case tf.std_part_week when '2521' then tf.final_require_net_qty else 0 end) as "2521-净预测" ,
	sum(case tf.std_part_week when '2522A' then tf.final_require_net_qty else 0 end) as "2522A-净预测" ,
	sum(case tf.std_part_week when '2522B' then tf.final_require_net_qty else 0 end) as "2522B-净预测" ,
	sum(case tf.std_part_week when '2523' then tf.final_require_net_qty else 0 end) as "2523-净预测" ,
	sum(case tf.std_part_week when '2524' then tf.final_require_net_qty else 0 end) as "2524-净预测" ,
	sum(case tf.std_part_week when '2525' then tf.final_require_net_qty else 0 end) as "2525-净预测" ,
	sum(case tf.std_part_week when '2526' then tf.final_require_net_qty else 0 end) as "2526-净预测" ,
	sum(case tf.std_part_week when '2527A' then tf.final_require_net_qty else 0 end) as "2527A-净预测" ,
	sum(case tf.std_part_week when '2527B' then tf.final_require_net_qty else 0 end) as "2527B-净预测" ,
	sum(case tf.std_part_week when '2528' then tf.final_require_net_qty else 0 end) as "2528-净预测" ,
	sum(case tf.std_part_week when '2529' then tf.final_require_net_qty else 0 end) as "2529-净预测" ,
	sum(case tf.std_part_week when '2530' then tf.final_require_net_qty else 0 end) as "2530-净预测" ,
	sum(case tf.std_part_week when '2531A' then tf.final_require_net_qty else 0 end) as "2531A-净预测" ,
	sum(case tf.std_part_week when '2531B' then tf.final_require_net_qty else 0 end) as "2531B-净预测" ,
	sum(case tf.std_part_week when '2532' then tf.final_require_net_qty else 0 end) as "2532-净预测" ,
	sum(case tf.std_part_week when '2533' then tf.final_require_net_qty else 0 end) as "2533-净预测" ,
	sum(case tf.std_part_week when '2534' then tf.final_require_net_qty else 0 end) as "2534-净预测" ,
	sum(case tf.std_part_week when '2535' then tf.final_require_net_qty else 0 end) as "2535-净预测" ,
	sum(case tf.cal_month when '202504' then tf.inner_po_qty else 0 end) as "202504-订单" ,
	sum(case tf.cal_month when '202505' then tf.inner_po_qty else 0 end) as "202505-订单" ,
	sum(case tf.cal_month when '202506' then tf.inner_po_qty else 0 end) as "202506-订单" ,
	sum(case tf.cal_month when '202507' then tf.inner_po_qty else 0 end) as "202507-订单" ,
	sum(case tf.cal_month when '202508' then tf.inner_po_qty else 0 end) as "202508-订单" ,
	sum(case tf.std_part_week when '2514B' then tf.inner_po_qty else 0 end) as "2514B-订单" ,
	sum(case tf.std_part_week when '2515' then tf.inner_po_qty else 0 end) as "2515-订单" ,
	sum(case tf.std_part_week when '2516' then tf.inner_po_qty else 0 end) as "2516-订单" ,
	sum(case tf.std_part_week when '2517' then tf.inner_po_qty else 0 end) as "2517-订单" ,
	sum(case tf.std_part_week when '2518A' then tf.inner_po_qty else 0 end) as "2518A-订单" ,
	sum(case tf.std_part_week when '2518B' then tf.inner_po_qty else 0 end) as "2518B-订单" ,
	sum(case tf.std_part_week when '2519' then tf.inner_po_qty else 0 end) as "2519-订单" ,
	sum(case tf.std_part_week when '2520' then tf.inner_po_qty else 0 end) as "2520-订单" ,
	sum(case tf.std_part_week when '2521' then tf.inner_po_qty else 0 end) as "2521-订单" ,
	sum(case tf.std_part_week when '2522A' then tf.inner_po_qty else 0 end) as "2522A-订单" ,
	sum(case tf.std_part_week when '2522B' then tf.inner_po_qty else 0 end) as "2522B-订单" ,
	sum(case tf.std_part_week when '2523' then tf.inner_po_qty else 0 end) as "2523-订单" ,
	sum(case tf.std_part_week when '2524' then tf.inner_po_qty else 0 end) as "2524-订单" ,
	sum(case tf.std_part_week when '2525' then tf.inner_po_qty else 0 end) as "2525-订单" ,
	sum(case tf.std_part_week when '2526' then tf.inner_po_qty else 0 end) as "2526-订单" ,
	sum(case tf.std_part_week when '2527A' then tf.inner_po_qty else 0 end) as "2527A-订单" ,
	sum(case tf.std_part_week when '2527B' then tf.inner_po_qty else 0 end) as "2527B-订单" ,
	sum(case tf.std_part_week when '2528' then tf.inner_po_qty else 0 end) as "2528-订单" ,
	sum(case tf.std_part_week when '2529' then tf.inner_po_qty else 0 end) as "2529-订单" ,
	sum(case tf.std_part_week when '2530' then tf.inner_po_qty else 0 end) as "2530-订单" ,
	sum(case tf.std_part_week when '2531A' then tf.inner_po_qty else 0 end) as "2531A-订单" ,
	sum(case tf.std_part_week when '2531B' then tf.inner_po_qty else 0 end) as "2531B-订单" ,
	sum(case tf.std_part_week when '2532' then tf.inner_po_qty else 0 end) as "2532-订单" ,
	sum(case tf.std_part_week when '2533' then tf.inner_po_qty else 0 end) as "2533-订单" ,
	sum(case tf.std_part_week when '2534' then tf.inner_po_qty else 0 end) as "2534-订单" ,
	sum(case tf.std_part_week when '2535' then tf.inner_po_qty else 0 end) as "2535-订单"
from
	(
	select
		tt.plan_version,
		tt.require_addr,
		tt.require_goods_mode,
		tt.require_goods_cust_code,
		tt.customer_model,
		tt.bulk_require_goods_mode,
		tt.appointed_factory,
		tt.final_require_plan_factory_qty,
		tt.final_require_net_qty,
		tt.inner_po_qty,
		tt.std_part_week,
		tt.cal_month,
		tmo.region_name,
		tmo.region_code,
		tmo.country_name_cn,
		tt.brand_group,
		tt.is_special
	from
		( (
		select
			'202525' as 'plan_version',
			his.require_addr,
			his.require_goods_mode,
			his.require_goods_cust_code,
			his.customer_model,
			his.bulk_require_goods_mode,
			his.appointed_factory,
			his.final_require_plan_factory_qty,
			his.final_require_net_qty,
			his.inner_po_qty,
			his.brand_group,
			his.is_special,
			his.std_part_week,
			his.cal_month
		from
			his
		where
			his.plan_version < '202525'
	union
		select
			'202526' as 'plan_version',
			his.require_addr,
			his.require_goods_mode,
			his.require_goods_cust_code,
			his.customer_model,
			his.bulk_require_goods_mode,
			his.appointed_factory,
			his.final_require_plan_factory_qty,
			his.final_require_net_qty,
			his.inner_po_qty,
			his.brand_group,
			his.is_special,
			his.std_part_week,
			his.cal_month
		from
			his
		where
			his.plan_version < '202526'
	union
		select
			'202527' as 'plan_version',
			his.require_addr,
			his.require_goods_mode,
			his.require_goods_cust_code,
			his.customer_model,
			his.bulk_require_goods_mode,
			his.appointed_factory,
			his.final_require_plan_factory_qty,
			his.final_require_net_qty,
			his.inner_po_qty,
			his.brand_group,
			his.is_special,
			his.std_part_week,
			his.cal_month
		from
			his
		where
			his.plan_version < '202527' )
union
	select
		t.plan_version,
		t.require_addr,
		t.require_goods_mode,
		t.require_goods_cust_code,
		t.customer_model,
		t.bulk_require_goods_mode,
		t.appointed_factory,
		t.final_require_plan_factory_qty,
		t.final_require_net_qty,
		t.inner_po_qty,
		t.brand_group,
		t.is_special,
		tm.std_part_week,
		tm.cal_month
	from
		dp_require_plan_base_factory_archive_data t
	left join (
		select
			distinct t.std_part_week,
			CONVERT (t.pw_start_date,
			date) as date,
			CONVERT (t.pw_end_date,
			date) as dateEnd,
			cal_month
		from
			kt_plan_time_master t
		where
			t.std_part_week > '2524') tm on
		t.bg_demand_time >= tm.date
		and t.bg_demand_time <= tm.dateEnd
	WHERE
		( (t.plan_version = '202525'
			and tm.std_part_week > '2524' )
		or (t.plan_version = '202526'
			and tm.std_part_week > '2525' )
		or (t.plan_version = '202527'
			and tm.std_part_week > '2527B' ) ) ) tt
	left join (
		select
			distinct region_name,
			region_code,
			country_code,
			country_name_cn,
			brand_name as brand_group
		from
			scm_market_org) tmo on
		tmo.country_code = tt.require_addr
		and tmo.brand_group = tt.brand_group ) tf
WHERE
	tf.plan_version in ( '202525' , '202526' , '202527' )
	and tf.brand_group in ( 'ODM' , '自有品牌' )
	and tf.is_special in ( 'N' , 'Y' )
	and tf.require_addr in ( 'DR' , 'BR' , 'PL' , 'BD' , 'TT' , 'ML' , 'PA' , 'SD' , 'VE' , 'FR' , 'TW' , 'SR' , 'EE' , 'VN' , 'GM' , 'UZ' , 'CV' , 'MF' , 'CI' , 'TZ' , 'SC' , 'HR' , 'NE' , 'CG' , 'AL' , 'PT' , 'EU' , 'BA' , 'GU' , 'HN' , 'ES' , 'KZ' , 'MR' , 'KG' , 'GD' , 'ET' , 'MY' , 'PE' , 'GB' , 'YT' , 'AR' , 'UG' , 'OM' , 'AM' , 'CD' , 'KW' , 'AW' , 'GP' , 'CR' , 'DK' , 'NC' , 'TR' , 'NACN' , 'FJ' , 'IR' , 'ZA' , 'US' , 'QA' , 'UY' , 'MU' , 'EUCN' , 'KH' , 'KI' , 'UK' , 'TJ' , 'MD' , 'ZM' , 'MA' , 'MW' , 'BN' , 'VG' , 'DJ' , 'CY' , 'ME' , 'SE' , 'JO' , 'SY' , 'SS' , 'CN' , 'NA' , 'TN' , 'MM' , 'PG' , 'EC' , 'RS' , 'PF' , 'XY' , 'TC' , 'CO' , 'ID' , 'GQ' , 'CL' , 'KM' , 'HK' , 'KP' , 'MN' , 'CA' , 'GN' , 'GR' , 'DO' , 'PR' , 'YU' , 'AN' , 'IN' , 'BS' , 'YE' , 'CM' , 'MEACN' , 'SO' , 'TD' , 'MX' , 'EG' , 'GY' , 'JM' , 'MG' , 'CU' , 'MT' , 'LV' , 'JP' , 'BY' , 'ZW' , 'NG' , 'UA' , 'IS' , 'MQ' , 'RU' , 'GW' , 'NI' , 'IQ' , 'TG' , 'DB' , 'GH' , 'PY' , 'DZ' , 'FI' , 'RE' , 'KV' , 'NL' , 'AU' , 'AE' , 'PH' , 'RO' , 'AT' , 'BB' , 'NZ' , 'SI' , 'SG' , 'KE' , 'CW' , 'TP' , 'SA' , 'CZ' , 'MV' , 'CF' , 'DM' , 'AG' , 'AO' , 'TM' , 'AS' , 'LB' , 'VU' , 'LACN' , 'LR' , 'BG' , 'BZ' , 'SB' , 'MZ' , 'LC' , 'AF' , 'PS' , 'LS' , 'GF' , 'TH' , 'IT' , 'SV' , 'BT' , 'BJ' , 'APCN' , 'LY' , 'BW' , 'LK' , 'LA' , 'KR' , 'NP' , 'GA' , 'HU' , 'BO' , 'HT' , 'AZ' , 'ER' , 'DE' , 'PK' , 'IL' , 'MH' , 'VC' , 'BH' , 'MK' , 'GT' , 'GE' , 'LT' , 'BF' , 'SN' )
	and tf.customer_model in ('Z2U20101009800')
group by
	tf.region_name,
	tf.require_addr,
	tf.country_name_cn,
	tf.require_goods_mode,
	tf.require_goods_cust_code,
	tf.customer_model,
	tf.bulk_require_goods_mode,
	tf.appointed_factory,
	tf.plan_version
order by
	tf.region_name,
	tf.require_addr,
	tf.country_name_cn,
	tf.require_goods_mode,
	tf.require_goods_cust_code,
	tf.customer_model,
	tf.bulk_require_goods_mode,
	tf.appointed_factory,
	tf.plan_version