
SELECT a.demand_type, a.month, a.businessline, sum(a.turn_prodt_qty)
FROM (SELECT CASE
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'Y'
                     then '内销特种'
                 WHEN c.brand_group = 'ODM' and c.country_code = 'CN'
                     then '内销特种'
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'N'
                     then '内销品牌'
                 WHEN c.brand_group = 'ODM' and c.bu_code = '04'
                     then '外销ODM'
                 ELSE d.bg_code END                             as businessline,
             DATE_FORMAT(res.turn_prodt_factory_etd_time, '%Y%m') as month,
             c.*
      FROM sp_turn_prodt_result c
               JOIN scm_market_org d
                    ON c.brand_group = d.brand_name AND c.country_code = d.country_code
               left join (SELECT relation_id,
                                 MAX(turn_prodt_factory_etd_time) AS turn_prodt_factory_etd_time
                          FROM sp_turn_prodt_result
                          WHERE turn_prodt_factory_etd_time IS NOT NULL
                          GROUP BY relation_id) res
                   on c.relation_id = res.relation_id
      WHERE c.pt_plan_version = '2025-05-19发布版'
        and c.abnormal_type_code <> 'B-4'
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))
        and c.demand_type = 1) a
group by a.demand_type, a.month, a.businessline
order by a.demand_type, a.month, a.businessline;

select * from mdm_item_master_parts_mst where material_group in
('M010203','KT99999','9201401','9501702','M010201','MO10101');


select * from sp_turn_prodt_put t where demand_type=1 and demand_qty=1000 and date_format(require_goods_demand_time,'%Y%m')='202506'
order by require_goods_demand_time;


select t.abnormal_type_code, t.* from sp_turn_prodt_result t where t.pt_plan_version='2025-05-19' and t.demand_type = 1 and proto_code='S12020105015'
and date_format(require_goods_demand_time,'%Y%m')='202506'
order by relation_id,level_no,whole_in_out;



-- select t.abnormal_type_code, t.* from sp_turn_prodt_result t where t.pt_plan_version='2025-05-19初版' and t.demand_type = 1
-- and date_format(require_goods_demand_time,'%Y%m')='202506'
-- and country_code='CN'
-- order by relation_id,level_no,whole_in_out;

SELECT a.month,
       a.businessline,
       a.country_code,
       a.require_goods_mode,
       a.is_bulk,
       a.require_appoint_factory,
       case
           when a.proto_code_type = '套机' then sum(a.turn_prodt_qty)
           when a.proto_code_type <> '套机' then sum(TRUNCATE(
                   a.turn_prodt_qty / if(ifnull(a.in_out_zcode_qty, '') = '', 1, a.in_out_zcode_qty), 0))
           end as turn_prodt_qty
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
      FROM sp_turn_prodt_result c
               JOIN scm_market_org d
                    ON c.brand_group = d.brand_name AND c.country_code = d.country_code
      WHERE c.pt_plan_version = '2025-05-19初版'
        AND ifnull(C.abnormal_type_code, '') = ''
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))
        and c.demand_type = 1) a
group by a.month, a.businessline, a.country_code, a.require_goods_mode,
         a.is_bulk, a.require_appoint_factory
order by a.month, a.businessline, a.country_code, a.require_goods_mode,
         a.is_bulk, a.require_appoint_factory;

select t.* from sp_turn_prodt_result t where pt_plan_version = '2025-05-19发布版' and demand_type=2;

SELECT a.demand_type,
       a.month,
       a.businessline,
       case
           when a.proto_code_type = '套机' then sum(a.turn_prodt_qty)
           when a.proto_code_type <> '套机' then floor(sum(
                   a.turn_prodt_qty /(ifnull(a.in_out_zcode_qty, 1) * ifnull(a.in_out_scode_qty,1))))
           end as turn_prodt_qty
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
      FROM sp_turn_prodt_result c
               JOIN scm_market_org d
                    ON c.brand_group = d.brand_name AND c.country_code = d.country_code
      WHERE c.pt_plan_version = '2025-05-19发布版'
        and c.abnormal_type_code <> 'B-4'
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))
        and c.demand_type = 1) a
group by a.demand_type, DATE_FORMAT(a.require_goods_demand_time, '%Y%m'), a.businessline
order by a.demand_type, DATE_FORMAT(a.require_goods_demand_time, '%Y%m'), a.businessline

SELECT DATE_FORMAT(a.require_goods_demand_time, '%Y%m'),
       a.businessline,
       a.country_code,
       a.require_goods_mode,
       a.is_bulk,
       a.require_appoint_factory,

       case
           when a.proto_code_type = '套机' then sum(a.turn_prodt_qty)
           when a.proto_code_type <> '套机' then floor(sum(
                   a.turn_prodt_qty / (ifnull(a.in_out_zcode_qty, 1) * ifnull(a.in_out_scode_qty, 1))))
           end as turn_prodt_qty
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
      WHERE c.pt_plan_version = '2025-05-12'
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))) a
group by DATE_FORMAT(a.require_goods_demand_time, '%Y%m'), a.businessline, a.country_code, a.require_goods_mode,
         a.is_bulk, a.require_appoint_factory
order by DATE_FORMAT(a.require_goods_demand_time, '%Y%m'), a.businessline, a.country_code, a.require_goods_mode,
         a.is_bulk, a.require_appoint_factory



select * from sp_turn_prodt_result t where t.abnormal_type_code='A-6'