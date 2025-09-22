select bom_factory,bom_life_cycle,pt_plan_version
from sp_turn_prodt_result where pt_plan_version = (select max(pt_plan_version) from sp_turn_prodt_result)
and ifnull(bom_life_cycle,'')<>'' or ifnull(bom_factory,'')<>''  ;


select bom_factory,bom_life_cycle
from sp_turn_prodt_result where pt_plan_version = '2025-07-28'
and ifnull(bom_life_cycle,'')<>'' or ifnull(bom_factory,'')<>''  ;


select original_zcode, in_out_zcode,bom_factory,bom_life_cycle from sp_zcode_optional_config_relation where original_zcode <> in_out_zcode


