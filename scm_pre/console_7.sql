SELECT a.demand_type,
       a.month,
       a.businessline,
           SUM(case
               when a.proto_code_type = '套机' then a.turn_prodt_qty
               when a.proto_code_type <> '套机' then floor(a.turn_prodt_qty /
                                                           (ifnull(a.in_out_zcode_qty, 1) * ifnull(a.in_out_scode_qty, 1)))
               else 0 end) as turn_prodt_qty
FROM (SELECT CASE
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'Y'
                     then '内销特种'
                 WHEN c.brand_group = 'ODM' and c.country_code = 'CN'
                     then '内销特种'
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'N'
                     then '内销品牌'
                 WHEN c.brand_group = 'ODM' and c.bu_code = '04'
                     then '外销ODM'
                 ELSE d.bg_code END                           as businessline,
             DATE_FORMAT(c.require_goods_demand_time, '%Y%m') as month,
             c.*
      FROM sp_turn_prodt_cycle_deficiency_detail c
               JOIN scm_market_org d
                    ON c.brand_group = d.brand_name AND c.country_code = d.country_code
      WHERE c.pt_plan_version =(DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY))
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))) a
group by a.demand_type, DATE_FORMAT(a.require_goods_demand_time, '%Y%m'), a.businessline
order by a.demand_type, DATE_FORMAT(a.require_goods_demand_time, '%Y%m'), a.businessline