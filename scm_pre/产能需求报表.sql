-- 需求ODF
with t2 as (select cfg.attr1                                                                 as factory,
                   spc.product_categ                                                         as mode,
                   case substring(a.item_code, 3, 1)
                       when 'U' then 'CBU'
                       when 'S' then 'SKD'
                       when 'C' then 'CKD'
                       END                                                                   AS ship_mode,
                   a.whole_in_out,
                   date_format(ifnull(a.adjust_promise_date, a.first_promise_date), '%Y-%m') as demand_date,
                   a.qty
            from sp_order_item_weekly_esp_snapshot a
                     inner join sp_order_header_weekly_esp_snapshot b
                                on a.order_no = b.order_no
                     left join (select *
                                from cfg_parameter
                                where belong_domain = 'KTSCM_TURN_PROUCT'
                                  and Param_name = 'DMD_FACTORY_BASE_PLANT_RELATION') cfg
                               on a.turn_prodt_factory = cfg.Dimension1 and b.is_bulk = cfg.Dimension2
                     left join mdm_item_master_mst mimm
                               on a.item_code = mimm.bom_code
                     left join sp_product_categ spc
                               on mimm.product_small_categ_name = spc.product_small_categ_name
            where a.whole_in_out in ('外机', '内机')
              and date_format(ifnull(a.adjust_promise_date, a.first_promise_date), '%Y%m') >=
                  DATE_FORMAT(NOW(), '%Y%m')
              and date_format(ifnull(a.adjust_promise_date, a.first_promise_date), '%Y%m') <=
                  DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 4 MONTH), '%Y%m')

            union all

            select cfg.attr1                                           as factory,
                   spc.product_categ                                   as mode,
                   CASE
                       WHEN a.is_bulk2 = 'N' THEN 'CBU'
                       ELSE
                           CASE
                               WHEN a.proto_code_type = '单内' THEN
                                   CASE
                                       WHEN a.bulk_require_mode LIKE '%内半散%' THEN 'SKD'
                                       WHEN a.bulk_require_mode LIKE '%内全散%' THEN 'CKD'
                                       WHEN a.bulk_require_mode = '半散（单）' THEN 'SKD'
                                       WHEN a.bulk_require_mode = '全散（单）' THEN 'CKD'
                                       END
                               WHEN a.proto_code_type = '单外' THEN
                                   CASE
                                       WHEN a.bulk_require_mode LIKE '%外半散%' THEN 'SKD'
                                       WHEN a.bulk_require_mode LIKE '%外全散%' THEN 'CKD'
                                       WHEN a.bulk_require_mode = '半散（单）' THEN 'SKD'
                                       WHEN a.bulk_require_mode = '全散（单）' THEN 'CKD'
                                       END
                               END
                       END                                             AS ship_mode,
                   a.whole_in_out,
                   date_format(a.turn_prodt_factory_etd_time, '%Y-%m') as demand_date,
                   a.turn_prodt_qty                                    as qty
            from (SELECT *
                  FROM sp_turn_prodt_result
                  where pt_plan_version = '2025-05-12'
                    and not (proto_code_type='套机' and whole_in_out='整机')
                    and date_format(turn_prodt_factory_etd_time, '%Y%m') >= DATE_FORMAT(NOW(), '%Y%m')
                    and date_format(turn_prodt_factory_etd_time, '%Y%m') <=
                        DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 4 MONTH), '%Y%m')) a
                     left join
                 (select Dimension1, Dimension2, attr1
                  from CFG_PARAMETER
                  where belong_domain = 'KTSCM_TURN_PROUCT'
                    and Param_name = 'DMD_FACTORY_BASE_PLANT_RELATION') cfg
                 on a.turn_prodt_factory = cfg.Dimension1
                     and a.is_bulk2 = cfg.Dimension2
                     left join mdm_item_master_mst mimm on a.in_out_zcode = mimm.bom_code
                     left join mdm_item_master_mst mimm2 on a.in_out_scode = mimm2.bom_code
                     left join sp_product_categ spc
                               on ifnull(mimm.product_small_categ_name, mimm2.product_small_categ_name) =
                                  spc.product_small_categ_name)
select factory, mode, ship_mode, whole_in_out, demand_date, sum(t2.qty)
from t2
group by factory, mode, ship_mode, whole_in_out, demand_date
order by factory, mode, ship_mode, whole_in_out, demand_date;



