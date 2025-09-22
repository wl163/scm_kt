-- 场景04
select *
from sp_turn_prodt_result t
WHERE t.pt_plan_version = '2025-05-19发布版'
  AND demand_type = 1
  AND t.proto_code_type NOT in ('套机')
  and turn_prodt_factory = '5520'
  and finished_factory = 'YN02'
  and country_code <> 'CN'
  AND T.brand_group = '自有品牌'
--       and require_goods_mode='DOM'
  AND is_bulk = 'N'
  AND is_special = 'N';


select * from cfg_parameter where param_name ='IMPORT_PUBILSH_PERMISSION'

SELECT
    proto_code,
    country_code,
    turn_prodt_factory,
    GROUP_CONCAT(finished_factory) AS finished_factories
FROM (
    SELECT DISTINCT
        proto_code,
        country_code,
        turn_prodt_factory,
        finished_factory
    FROM sp_turn_prodt_result t
    WHERE t.pt_plan_version = '2025-05-19发布版'
      AND demand_type = 1
      AND T.country_code <> 'CN'
      AND t.proto_code_type = '套机'
      AND t.whole_in_out <> '整机'
      AND turn_prodt_factory = '5500'
) t1
GROUP BY proto_code, country_code, turn_prodt_factory
HAVING COUNT(*) > 1;


