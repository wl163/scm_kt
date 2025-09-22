select
		'ODF' as demandType,
        CASE
        WHEN sph.brand_type = 'ODM' AND sph.country_code != 'CN' THEN '外销ODM'
        WHEN sph.brand_type = 'ODM' AND sph.country_code = 'CN' THEN '内销特种'
        when sph.brand_type = '自有品牌' and sph.is_special = 'Y' and  sph.country_code = 'CN' then '内销特种'
        when sph.brand_type = '自有品牌' and sph.is_special = 'N' and  sph.country_code = 'CN' then  'CBG'
        when sph.brand_type = '自有品牌' and sph.country_code !=  'CN'  then  sph.bg_code
        END AS businessLine,
        smo.rbc_name,
        smo.region_name,
        smo.country_name_cn,
        sph.is_special,
        sph.is_bulk,
        sph.bulk_require_goods_type as bulk_require_goods_mode,
        sph.require_goods_mode,
        '' AS requireGoodsFacotry,
      	sph.proto_type_code as prototype_code,
      	'' as proto_code_type,
      	sph.bom_code as bom_no,
        szocr.bom_factory,
        szocr.bom_life_cycle,
        szocr.bom_status,
        pc.product_categ,
        sph.qty,
        sph.closed_qty,
		sph.open_qty,
    	mimm.whole_in_out,
     	'' as sku,
        szocr.whole_code,
        sph.box_body,
     	'' AS manufactureFactory,
        sfc.factory_desc AS demandFactory,
      	ifnull(adjust_promise_date,ifnull(first_promise_date,promise_date)) as demandDate,
		sph.version_no
from
	sp_order_header_weekly_snapshot sph
	left join scm_market_org smo on sph.country_code = smo.country_code and sph.brand_type = smo.brand_name
	left join sp_factory_config sfc on sfc.factory_no = sph.demand_factory
	left join sp_zcode_optional_config_relation szocr on sph.bom_code =  szocr.in_out_zcode
	left join mdm_item_master_mst mimm on mimm.bom_code = sph.proto_type_code
	left join mdm_sku_mst msm on msm.code = sph.proto_type_code
	LEFT JOIN (
            select distinct bom_code, product_small_categ_name
            from mdm_item_master_mst
        ) item ON sph.bom_code = item.bom_code
    LEFT JOIN (
            SELECT distinct product_small_categ_name, product_categ
            FROM sp_product_categ
        ) pc ON item.product_small_categ_name = pc.product_small_categ_name
/*where 1=1
	and sph.order_no in (
	SELECT
		orgnum
	FROM
		his_mid_mds_fcstorder
	WHERE
		dmd_type = 'ODF'
		AND orgnum IS NOT NULL
        )*/
-- 	and STR_TO_DATE(SUBSTRING(spheader.version_no, 1, 8), '%Y%m%d') >
-- 	#{pwStartDate})
-- 	and STR_TO_DATE(SUBSTRING(spheader.version_no, 1, 8), '%Y%m%d') <
-- 	#{pwEndDate}
union all
    select
    'ODF' as demandType,
        CASE
        WHEN sph.brand_type = 'ODM' AND sph.country_code != 'CN' THEN '外销ODM'
        WHEN sph.brand_type = 'ODM' AND sph.country_code = 'CN' THEN '内销特种'
        when sph.brand_type = '自有品牌' and sph.is_special = 'Y' and  sph.country_code = 'CN' then '内销特种'
        when sph.brand_type = '自有品牌' and sph.is_special = 'N' and  sph.country_code = 'CN' then  'CBG'
        when sph.brand_type = '自有品牌' and sph.country_code !=  'CN'  then  sph.bg_code
        END AS businessLine,
        smo.rbc_name,
        smo.region_name,
        smo.country_name_cn,
        sph.is_special,
        sph.is_bulk,
        sph.bulk_require_goods_type as bulk_require_goods_mode,
        sph.require_goods_mode,
        '' AS requireGoodsFacotry,
      	spi.proto_type_code as prototype_code,
      	'' as proto_code_type,
      	spi.item_code as bom_no,
        szocr.bom_factory,
        szocr.bom_life_cycle,
        szocr.bom_status,
        pc.product_categ,
        spi.qty,
        spi.closed_qty,
		spi.open_qty,
    	mimm.whole_in_out,
     	'' as sku,
        szocr.whole_code,
        sph.box_body,
     	sfc2.factory_desc AS manufactureFactory,
        sfc.factory_desc AS demandFactory,
      	ifnull(spi.adjust_promise_date,ifnull(spi.first_promise_date,spi.promise_date)) as demandDate,
		spi.version_no
from
	sp_order_item_weekly_snapshot spi
	left join sp_order_header_weekly_snapshot sph on spi.order_no = sph.order_no
	left join scm_market_org smo on sph.country_code = smo.country_code and sph.brand_type = smo.brand_name
	left join sp_factory_config sfc on sfc.factory_no = sph.demand_factory
	left join sp_factory_config sfc2 on sfc2.factory_no = spi.turn_prodt_factory
	left join sp_zcode_optional_config_relation szocr on spi.item_code =  szocr.in_out_zcode
	left join mdm_item_master_mst mimm on mimm.bom_code = spi.proto_type_code
	left join mdm_sku_mst msm on msm.code = spi.proto_type_code
	LEFT JOIN (
            select distinct bom_code, product_small_categ_name
            from mdm_item_master_mst
        ) item ON spi.item_code = item.bom_code
    LEFT JOIN (
            SELECT distinct product_small_categ_name, product_categ
            FROM sp_product_categ
        ) pc ON item.product_small_categ_name = pc.product_small_categ_name
/*where
	spi.order_no in (
	SELECT
		orgnum
	FROM
		his_mid_mds_fcstorder
	WHERE
		dmd_type = 'ODF'
		AND orgnum IS NOT NULL
        )
	and STR_TO_DATE(SUBSTRING(spitem.version_no, 1, 8), '%Y%m%d') >
	#{pwStartDate})
	and STR_TO_DATE(SUBSTRING(spitem.version_no, 1, 8), '%Y%m%d') <
	#{pwEndDate};*/