# select distinct customer_model
# from dp_require_plan_base_factory_archive_data;
#
# select distinct bulk_require_goods_mode
# from dp_require_plan_base_factory_archive_data;

# select bom_factory,t.* from mdm_item_master_mst t order by last_update_date;
select data.business_line,
       data.brand_group,
       data.is_special,
       data.region_name,
       data.country,
       data.require_goods_mode,
       data.require_goods_cust_code,
       data.month,
       data.customer_model,
       data.bulk_require_goods_mode,
       data.appointed_factory,
       data.plan_version,
       sum(data.final_require_plan_factory_qty) as final_require_plan_factory_qty ,
       sum(data.final_require_net_qty) as final_require_net_qty,
       sum(data.inner_po_qty) as inner_po_qty

from (select case
                 when brand_group = '自有品牌' and is_special = 'N' and require_addr = 'CN' then '内销品牌'
                 when (brand_group = '自有品牌' and is_special = 'Y' and require_addr = 'CN') or
                      (brand_group = 'ODM' and is_special = 'N' and require_addr = 'CN') THEN '内销特种&ODM'
                 WHEN brand_group = 'ODM' and require_addr <> 'N' THEN '外销ODM'
                 WHEN brand_group = '自有品牌' and require_addr <> 'N' THEN smo.bg_code
                 ELSE '' END                         AS business_line,
             fad.brand_group,
             fad.is_special,
             smo.region_name,
             smo.country_name_cn                     as country,
             fad.require_goods_mode,
             fad.require_goods_cust_code,
#        fad.bg_demand_time,
             date_format(fad.bg_demand_time, '%Y%m') as month,
             fad.customer_model,
             fad.bulk_require_goods_mode,
             fad.appointed_factory,
             fad.plan_version,
             fad.final_require_plan_factory_qty,
             fad.final_require_net_qty,
             fad.inner_po_qty
      from dp_require_plan_base_factory_archive_data fad
               left join scm_market_org smo
                         on fad.require_addr = smo.country_code and fad.brand_group = smo.brand_name) data
group by business_line, brand_group, is_special, region_name, country, require_goods_mode, require_goods_cust_code,
         month, customer_model, bulk_require_goods_mode,
         appointed_factory, plan_version
order by customer_model,month, plan_version;

#
# select * from dp_require_plan_base_factory_archive_data t where brand_group='ODM' AND require_addr='AE' AND customer_model IN ('Z2U20101009800','Z2U20101009800')
# and final_require_plan_factory_qty<> 0