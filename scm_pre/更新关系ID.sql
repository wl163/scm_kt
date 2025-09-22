/*
给同一个组内{套机(整机、内、外组)}的所有记录赋值相同的关系id
*/
UPDATE sp_turn_prodt_result AS tpd
    LEFT JOIN (SELECT tpp.id,
                      tpp.country_code,
                      tpp.brand_group,
                      tpp.is_special,
                      tpp.is_bulk,
                      tpp.bulk_require_mode,
                      tpp.require_goods_cust,
                      tpp.require_goods_mode,
                      tpp.require_appoint_factory,
                      tpp.proto_code,
                      tpp.require_goods_demand_time,
                      ROW_NUMBER() over (PARTITION BY tpp.country_code,tpp.brand_group,tpp.is_special,tpp.is_bulk,tpp.bulk_require_mode,tpp.require_goods_cust,tpp.require_goods_mode,tpp.require_appoint_factory,tpp.proto_code,tpp.require_goods_demand_time
                          ORDER BY tpp.id) AS num
               FROM sp_turn_prodt_result AS tpp
               WHERE tpp.pt_plan_version = '2025-05-26'
                 and tpp.demand_type = '1'
                 AND tpp.proto_code_type = '套机'
                 AND tpp.whole_in_out = '整机'
                 AND tpp.org_id = 'KT') AS t ON t.num = 1
        AND tpd.country_code = t.country_code
        AND tpd.brand_group = t.brand_group
        AND tpd.is_special = t.is_special
        AND tpd.is_bulk = t.is_bulk
        AND tpd.bulk_require_mode = t.bulk_require_mode
        AND tpd.require_goods_cust = t.require_goods_cust
        AND tpd.require_goods_mode = t.require_goods_mode
        AND tpd.require_appoint_factory = t.require_appoint_factory
        AND tpd.proto_code = t.proto_code
        AND tpd.require_goods_demand_time = t.require_goods_demand_time
SET tpd.relation_id=t.id
WHERE tpd.pt_plan_version = '2024-11-25'
  and tpd.demand_type = '1'
  AND tpd.org_id = 'KT'
  AND t.id IS NOT NULL
;