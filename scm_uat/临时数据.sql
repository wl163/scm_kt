select distinct demand_type from sop_rtf_detail_upload rdp ;

-- 202507151847
select version_no from sp_order_header_weekly_snapshot order by creation_date desc limit 1 ;


select iws.version_no, iws.order_no, iws.order_line_no, iws.promise_date, iws.closed_qty
from (select *
      from sp_order_header_weekly_snapshot
      where
          version_no = (select version_no from sp_order_header_weekly_snapshot order by creation_date desc limit 1)) hws
         join (select distinct ORGNUM from SOP_HIS_MID_MDS_FCSTORDER where dmd_type = 'ODF') mf
              on hws.order_no = mf.orgnum
         join (select *
               from sp_order_item_weekly_snapshot
               where version_no =
                     (select version_no from sp_order_item_weekly_snapshot order by creation_date desc limit 1)) iws
              on hws.order_no = iws.order_no
where yearweek(left(hws.version_no, 8)) = yearweek((select left(version_no, 8) from sop_rtf_detail_upload order by creation_date limit 1)) ;



select * from sp_order_header_weekly_esp_snapshot ;



/*取值逻辑*/
with rtf_data as (
select demand_type,
       case
           when t.brand_group = 'ODM' and t.country_code <> 'CN' then '外销ODM'
           when t.brand_group = 'ODM' and t.country_code = 'CN' then '内销特种'
           when t.brand_group = '自有品牌' and t.is_special = 'Y' and t.country_code = 'CN' then '内销特种'
           when t.brand_group = '自有品牌' and t.is_special = 'N' and t.country_code = 'CN' then 'CBG'
           when t.brand_group = '自有品牌' and t.country_code <> 'CN' then t.bg_code
           else '' end  as line,
       org.rbc_name     as rbc_name,
       org.region_name  as region_name,
       t.country_code   as country_code,
       t.is_special,
       t.is_bulk,
       t.bulk_require_goods_mode,
       t.require_goods_mode,
       cf.factory_desc,
       t.prototype_code,
       t.proto_code_type,
       t.bom_no,
       szocr.bom_factory,
       szocr.bom_life_cycle,
       szocr.bom_status,
       spc.product_categ,
       t.whole_in_out,
       szocr2.whole_code,
       t.box_body,
       cf2.factory_desc as finsh_factory,
       cf2.factory_desc as demand_factory

from sop_rtf_detail_upload t
         left join scm_market_org org on t.bu_code = org.bu_code and t.country_code = org.country_code
         left join sp_factory_config cf on t.require_goods_facotry = cf.factory_no
         left join sp_zcode_optional_config_relation szocr on t.bom_no = szocr.in_out_zcode
         left join mdm_item_master_mst mst on t.bom_no = mst.bom_code
         left join sp_product_categ spc on mst.product_small_categ_name = spc.product_small_categ_name
         left join sp_zcode_optional_config_relation szocr2
                   on t.bom_no = szocr2.in_out_zcode and ifnull(szocr.whole_code, '') <> ''
         left join sp_factory_config cf2 on t.manufacture_factory = cf2.factory_no
         left join
             (select *
              from sp_order_header_weekly_snapshot
              where version_no = (select version_no
                                  from sp_order_header_weekly_snapshot
                                  order by creation_date desc
                                  limit 1)) hws
                    on yearweek(left(t.version_no, 8)) = yearweek(left(hws.version_no, 8))

         join (select distinct ORGNUM from SOP_HIS_MID_MDS_FCSTORDER where dmd_type = 'ODF') mf
              on hws.order_no = mf.orgnum
         join (select *
               from sp_order_item_weekly_snapshot
               where version_no =
                     (select version_no from sp_order_item_weekly_snapshot order by creation_date desc limit 1)) iws
              on hws.order_no = iws.order_no )
select * from rtf_data group by

;


select yearweek(left(version_no,8)) from sop_rtf_detail_upload order by  version_no desc;

select * from sp_order_item_weekly_snapshot ;

select * from sop_rtf_detail_upload order by  version_no desc;

select adjust_promise_date ,first_promise_date ,promise_date,closed_qty from sp_order_item_weekly_snapshot
