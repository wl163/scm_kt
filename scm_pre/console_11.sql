select tf.BG,
       tf.国家,
       tf.demand_type               需求类型,
       tf.brand_group               品牌大类,
       tf.is_special                是否特种,
       tf.require_goods_mode        要货模式,
       tf.customer_model            机型,
       (
           CASE
               when tf.demand_type = 'PUB_DEMAND' AND tf.BG not in ('LABG', 'APBG', 'NABG', 'MEABG', 'EUBG') AND
                    tf.brand_group = '自有品牌' then '毛预测'
               when tf.demand_type = 'PUB_DEMAND' AND tf.brand_group = 'ODM' then '毛预测'
               when tf.demand_type = 'PUB_DEMAND' AND tf.BG in ('LABG', 'APBG', 'NABG', 'MEABG', 'EUBG') AND
                    tf.brand_group = '自有品牌' then '净预测'
               when tf.demand_type = 'NOTDUE_ORD' then 'OPEN 订单'
               when tf.demand_type = 'DUE_ORD' then '欠产-超期订单'
               else '未知类型'
               END
           )                        需求类型,
       tf.bg_demand_time            需求时间,
       tf.qty                       数量,
       date(tf.last_update_date) as 发布日期
from (
-- 内销品牌
         select '内销品牌'     as             BG,
                t.require_addr as             国家,
                t.demand_type,
                t.brand_group,
                t.is_special,
                t.require_goods_mode,
                t.customer_model,
                t.bg_demand_time,
                t.last_update_date,
                sum(t.final_require_plan_qty) qty
         from dp_require_plan_output t
         WHERE t.brand_group = '自有品牌'
           and t.require_addr = 'CN'
           and t.require_goods_mode = 'DOM'
           and t.is_special = 'N'
           and t.final_require_plan_qty != 0
         group by t.require_addr,
                  t.demand_type,
                  t.brand_group,
                  t.is_special,
                  t.require_goods_mode,
                  t.customer_model,
                  t.bg_demand_time,
                  t.last_update_date
         UNION
-- 内销特种
         select '内销特种'     as             BG,
                t.require_addr as             国家,
                t.demand_type,
                t.brand_group,
                t.is_special,
                t.require_goods_mode,
                t.customer_model,
                t.bg_demand_time,
                t.last_update_date,
                sum(t.final_require_plan_qty) qty
         from dp_require_plan_output t
         WHERE (t.require_addr = 'CN'
             and t.require_goods_mode = 'FOB'
             and t.is_special = 'Y'
             and t.brand_group = '自有品牌')
            or (t.require_addr = 'CN'
             and t.require_goods_mode = 'FOB'
             and t.is_special = 'N'
             and t.brand_group = 'ODM')
             and t.final_require_plan_qty != 0
         group by t.require_addr,
                  t.demand_type,
                  t.brand_group,
                  t.is_special,
                  t.require_goods_mode,
                  t.customer_model,
                  t.bg_demand_time,
                  t.last_update_date
         UNION
-- 外销odm
         select '外销ODM'       as            BG,
                tmo.region_name as            国家,
                t.demand_type,
                t.brand_group,
                t.is_special,
                t.require_goods_mode,
                t.customer_model,
                t.bg_demand_time,
                t.last_update_date,
                sum(t.final_require_plan_qty) qty
         from dp_require_plan_output t
                  left join (select distinct country_code,
                                             region_name
                             from scm_market_org
                             where brand_name = 'ODM') tmo
                            on
                                tmo.country_code = t.require_addr
         WHERE t.brand_group = 'ODM'
           and t.require_addr != 'CN'
           and t.require_goods_mode = 'FOB'
           and t.is_special = 'N'
           and t.final_require_plan_qty != 0
         group by tmo.region_name,
                  t.demand_type,
                  t.brand_group,
                  t.is_special,
                  t.require_goods_mode,
                  t.customer_model,
                  t.bg_demand_time,
                  t.last_update_date
         UNION
-- 外销品牌          
         select tmo.bg_code    as             BG,
                t.require_addr as             国家,
                t.demand_type,
                t.brand_group,
                t.is_special,
                t.require_goods_mode,
                t.customer_model,
                t.bg_demand_time,
                t.last_update_date,
                sum(t.final_require_plan_qty) qty
         from dp_require_plan_output t
                  left join (select distinct country_code,
                                             bg_code
                             from scm_market_org
                             where brand_name = '自有品牌') tmo
                            on
                                tmo.country_code = t.require_addr
         WHERE t.brand_group = '自有品牌'
           and t.require_goods_mode in ('DOM', 'FOB')
           and t.is_special = 'N'
           and t.require_addr != 'CN'
           and t.final_require_plan_qty != 0
         group by t.require_addr,
                  t.demand_type,
                  t.brand_group,
                  t.is_special,
                  t.require_goods_mode,
                  t.customer_model,
                  t.bg_demand_time,
                  t.last_update_date) tf
order by tf.BG,
         tf.国家,
         tf.demand_type,
         tf.brand_group,
         tf.is_special,
         tf.require_goods_mode,
         tf.customer_model,
         tf.bg_demand_time,
         tf.last_update_date ;



select * from scm_market_org where country_code = 'St.Martin'