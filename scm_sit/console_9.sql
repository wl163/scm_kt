 SELECT * FROM dp_require_plan_base_factory_plan_bom ;


-- 要货计划主参数分工厂表
 select * from dp_require_plan_param_factory;


select * from dp_require_plan_master;
 -- 销售机型+要货地点+要货模式+要货客户+品牌大类+是否特种+散件要货模式+整内外+指定工厂 组合，是主键


 select customer_model,
        require_addr,
        require_goods_mode,
        require_goods_cust_code,
        brand_group,
        is_special,
        bulk_require_goods_mode,
        whole_in_out,
        appointed_factory
 from dp_require_plan_base_factory_plan_bom drpbfpb ;


select * from dp_require_plan_simulation_obg_tcl_sales_data_factory ;

select count(1) from sop_first_version_rtf_detail;
select distinct plan_version from dp_single_model_require_plan_report ;


select count(1) from dp_single_model_require_plan_report order by creation_date desc;

select * from dp_require_plan_base ;
select * from dp_require_plan_base_archive ;

select * from dp_require_plan_base_factory;
select * from dp_require_plan_base_factory_archive ;

select  * from dp_require_plan_base_factory_plan_bom order by creation_date desc;
select  * from dp_require_plan_base_factory_plan_bom_archive ;

select * from dp_require_plan_publish where plan_version = '202531' ;
select distinct plan_version from dp_require_plan_publish order by plan_version desc ;
select * from dp_require_plan_output order by last_update_date desc ;
select * from dp_review_require_plan order by version_id desc;

 select ifnull(t1.in_out_scode, drpo.customer_model) as in_out_scode,
        in_out_scode_qty,
        drpo.customer_model,
        t1.whole_in_out,
        t2.product_platform_name,
        drpo.require_addr,
        drpo.require_goods_cust_code,
        drpo.require_goods_mode,
        drpo.bg_demand_time,
        drpo.is_bulk,
        drpo.bulk_require_goods_mode,
        drpo.prefer_manufacturer,
        drpo.final_require_plan_qty
 from dp_require_plan_output drpo
          left join sp_zcode_optional_config_relation t1 on drpo.customer_model = t1.whole_code and priority = 1
          left join mdm_sku_mst t2 on t2.code = t1.in_out_scode
 where drpo.brand_group = '自有品牌'
   and drpo.is_special = 'N'
   and drpo.require_addr = 'CN'
   and drpo.demand_type = 'PUB_DEMAND' ;



select * from dp_single_model_require_plan_report where week = '2530' AND actual_production <> 0;
#  select distinct whole_in_out from sp_zcode_optional_config_relation


 select ifnull(t1.in_out_scode, drpo.customer_model) as sku,
        drpo.customer_model,
        t1.whole_in_out,
        drpo.bg_demand_time,
        sum(drpo.final_require_plan_qty)             as qty
 from dp_require_plan_output drpo
          left join sp_zcode_optional_config_relation t1 on
     drpo.customer_model = t1.whole_code
         and priority = 1
          left join mdm_sku_mst t2 on
     t2.code = t1.in_out_scode
 where drpo.brand_group = '自有品牌'
   and drpo.is_special = 'N'
   and drpo.require_addr = 'CN'
   and drpo.demand_type = 'PUB_DEMAND'
 and drpo.customer_model='S12010105041'
 group by ifnull(t1.in_out_scode, drpo.customer_model),
          drpo.customer_model,
          t1.whole_in_out,
          drpo.bg_demand_time ;



select *  from dp_require_plan_output drpo
 where drpo.brand_group = '自有品牌'
   and drpo.is_special = 'N'
   and drpo.require_addr = 'CN'
   and drpo.demand_type = 'PUB_DEMAND'
 and drpo.customer_model='S12010105041' ;


select distinct b.product_model_name  from mdm_sku_mst a join mdm_product_model_mst  b on a.product_model = b.code
where a.product_model in (
    select distinct sku from dp_single_model_require_plan_report where week = '2530'
    ) ;

-- S12010105041 P3010196
select * from mdm_sku_mst ;

select * from dp_single_model_require_plan_report where week = '2530'  AND actual_production <>0;

select product_model_name from mdm_product_model_mst where code = 'S12010105041' ;
select product_small_categ_name,product_platform_name from mdm_sku_mst where product_model='S12010105041';


select * from sp_inner_po_weekly_snapshot;

 select tphm.pr_no,
        tpim.parent_po_line_no,
        tpim.po_line_no,
        tpim.cust_bom_code,
        psr.open_qty,
        tpim.request_delivery_date,
        sih.order_no,
        IFNULL(IFNULL(sih.adjust_promise_date, sih.first_promise_date), sih.promise_date) as promise_date,
        sih.open_qty                                                                      as '订单OPEN数量',
        wo.prodt_order_end_date                                                           as '排产时间',
        wo.qty,
        wo.prodt_inv_qty,
        wo.open_qty                                                                       as '排产数量'
 from tof_pr_header_mst tphm
          left join tof_pr_item_mst tpim on tphm.pr_no = tpim.pr_no and level = 2
          left join pr_so_relationship psr on psr.pr_no = tphm.pr_no and psr.pr_line_no = tpim.po_line_no
          left join sp_order_header soh on tphm.pr_no = soh.po_no and tpim.parent_po_line_no = soh.po_line_no
          left join sp_order_item sih on soh.order_no = sih.order_no and tpim.po_line_no = sih.po_line_no
          left join sap_prodt_work_order_mst wo on wo.order_no = sih.order_no and wo.order_item_no = sih.order_line_no
 where psr.open_qty > 0
   and tphm.enabled_offset = 'Y';