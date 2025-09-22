-- 配置数据
# select * FROM cfg_parameter WHERE belong_domain = 'KTSCM_DATA_FUNNEL';
-- 数据漏斗版本表
# select * from sop_data_funnel_version order by last_update_date desc;
-- 数据漏斗明细标
# select * from sop_data_funnel_detail order by creation_date desc;

-- 转产计划发布版 净FCST-正常，查看各业务线下的外销整机分体/窗机 的净FCST数量
/*SELECT a.demand_type,
       a.month,
       a.businessline,
       a.bine2,
       SUM(case
               when a.proto_code_type = '套机' then a.turn_prodt_qty
               when a.proto_code_type <> '套机' then floor(a.turn_prodt_qty /
                                                           (ifnull(a.in_out_zcode_qty, 1) * ifnull(a.in_out_scode_qty, 1)))
               else 0 end) as turn_prodt_qty
FROM (SELECT demand_type,
             proto_code_type,
             turn_prodt_qty,
             in_out_scode_qty,
             in_out_zcode_qty,
             CASE
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'Y' then '内销特种'
                 WHEN c.brand_group = 'ODM' and c.country_code = 'CN' then '内销特种'
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'N' then '内销品牌'
                 WHEN c.brand_group = 'ODM' and c.bu_code = '04' then '外销ODM'
                 ELSE d.bg_code END                           as businessline,
             case
                 when spc.product_categ = '窗机' then '外销整机窗机'
                 else '外销整机分体' end                      as bine2,
             DATE_FORMAT(c.require_goods_demand_time, '%Y%m') as month
      FROM sp_turn_prodt_result c
               JOIN scm_market_org d
                    ON c.brand_group = d.brand_name AND c.country_code = d.country_code
               left join (select distinct bom_code, type_code from mdm_item_master_mst) mimm
                    on c.proto_code = mimm.bom_code
               left join sp_product_categ spc
                    on mimm.type_code = spc.product_categ_code
      WHERE c.pt_plan_version = concat((DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY)), '发布版')
        and c.abnormal_type_code <> 'B-4'
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))
        and c.demand_type = 1
        AND is_bulk <> 'Y') a where a.businessline not in ('内销品牌','内销特种')
group by a.demand_type, a.month, a.businessline, bine2
order by a.demand_type, a.month, a.businessline, bine2;
*/

-- 转产计划发布版 净FCST-正常，查看OBG下的国家 的净FCST数量
/*SELECT a.demand_type,
       a.month,
       a.businessline,
       country_code,
       country_name_cn,
       SUM(case
               when a.proto_code_type = '套机' then a.turn_prodt_qty
               when a.proto_code_type <> '套机' then floor(a.turn_prodt_qty /
                                                           (ifnull(a.in_out_zcode_qty, 1) * ifnull(a.in_out_scode_qty, 1)))
               else 0 end) as turn_prodt_qty
FROM (SELECT demand_type,
             proto_code_type,
             turn_prodt_qty,
             in_out_scode_qty,
             in_out_zcode_qty,
             d.country_code,
             d.country_name_cn,
             CASE
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'Y' then '内销特种'
                 WHEN c.brand_group = 'ODM' and c.country_code = 'CN' then '内销特种'
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'N' then '内销品牌'
                 WHEN c.brand_group = 'ODM' and c.bu_code = '04' then '外销ODM'
                 ELSE d.bg_code END                           as businessline,
             DATE_FORMAT(c.require_goods_demand_time, '%Y%m') as month
      FROM sp_turn_prodt_result c
               JOIN scm_market_org d
                    ON c.brand_group = d.brand_name AND c.country_code = d.country_code
      WHERE c.pt_plan_version = concat((DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY)), '发布版')
        and c.abnormal_type_code <> 'B-4'
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))
        and c.demand_type = 1) a where a.businessline <> '外销ODM'
group by a.demand_type, a.month, a.businessline,country_code
order by a.demand_type, a.month, a.businessline,country_code;*/

-- 转产计划发布版 净FCST-正常，查看外销ODM下的分公司 的净FCST数量
/*SELECT a.demand_type,
       a.month,
       a.businessline,
       rbc_code,
       rbc_name,
       SUM(case
               when a.proto_code_type = '套机' then a.turn_prodt_qty
               when a.proto_code_type <> '套机' then floor(a.turn_prodt_qty /
                                                           (ifnull(a.in_out_zcode_qty, 1) * ifnull(a.in_out_scode_qty, 1)))
               else 0 end) as turn_prodt_qty
FROM (SELECT demand_type,
             proto_code_type,
             turn_prodt_qty,
             in_out_scode_qty,
             in_out_zcode_qty,
             d.rbc_code,
             d.rbc_name,
             CASE
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'Y' then '内销特种'
                 WHEN c.brand_group = 'ODM' and c.country_code = 'CN' then '内销特种'
                 WHEN c.brand_group = '自有品牌' and c.country_code = 'CN' and c.is_special = 'N' then '内销品牌'
                 WHEN c.brand_group = 'ODM' and c.bu_code = '04' then '外销ODM'
                 ELSE d.bg_code END                           as businessline,
             DATE_FORMAT(c.require_goods_demand_time, '%Y%m') as month
      FROM sp_turn_prodt_result c
               JOIN scm_market_org d
                    ON c.brand_group = d.brand_name AND c.country_code = d.country_code
      WHERE c.pt_plan_version = concat((DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY)), '发布版')
        and c.abnormal_type_code <> 'B-4'
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))
        and c.demand_type = 1) a where a.businessline='外销ODM'
group by a.demand_type, a.month, a.businessline,rbc_code
order by a.demand_type, a.month, a.businessline,rbc_code;*/

# select DISTINCT bg_name,rbc_name from scm_market_org where bu_name='ODM外销';
-- **************************************************************************************************************





SELECT a.demand_type,
       a.month,
       a.businessline,
       a.rbc_code,
       a.rbc_name,
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
                d.rbc_code,
                d.rbc_name,
             DATE_FORMAT(c.require_goods_demand_time, '%Y%m') as month,
             c.*
      FROM sp_turn_prodt_result_abnormal_publish_detail c
               JOIN scm_market_org d
                    ON c.brand_group = d.brand_name AND c.country_code = d.country_code
      WHERE c.pt_plan_version =(DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY))
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))

      ) a
group by a.demand_type, DATE_FORMAT(a.require_goods_demand_time, '%Y%m'), a.businessline,rbc_code
order by a.demand_type, DATE_FORMAT(a.require_goods_demand_time, '%Y%m'), a.businessline ,rbc_code;






select DISTINCT pt_plan_version from sp_turn_prodt_result_abnormal_publish_detail;
-- 2025-04-14

select * from sp_turn_prodt_result_abnormal_publish_detail where pt_plan_version='2025-07-21';
select * from sp_turn_prodt_result_abnormal_publish_detail where pt_plan_version='2025-02-17';


update sp_turn_prodt_result_abnormal_publish_detail set pt_plan_version = '2025-07-21',require_goods_demand_time='2025-07-24 00:00:00' where pt_plan_version='2025-02-17';




select max(pt_plan_version) from sp_turn_prodt_result;


select * from sp_factory_config ;

# sp_order_offset_day_remaining_open_fnl
# sp_rtf_daily_snapshot
# sp_order_header_daily_offset_effflag
# sp_order_offset_day_result


select distinct in_out_sale,biz_line1,biz_line2,biz_line3,biz_line4
from sop_data_funnel_detail
where version_id = '745607963822841856' and in_out_sale='外销' ;

select * from sop_data_funnel_detail where version_id = '745607963822841856' ;
select * from sop_data_funnel_version order by version_week desc;




SELECT a.demand_type,
       a.month,
       a.businessline,
       cat.product_categ,
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
      WHERE c.pt_plan_version = (DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY))
        and ((c.proto_code_type in ('套机') and c.whole_in_out = '整机') or c.proto_code_type not in ('套机'))) a
left join mdm_item_master_mst mst on a.proto_code = mst.bom_code
left join sp_product_categ cat on mst.type_code = cat.product_categ_code
group by a.demand_type, a.month, a.businessline
order by a.demand_type, a.month, a.businessline



select * from cfg_parameter where param_name = 'DATA_FUNNEL_FACTORY' ;