select distinct pt_plan_version from sp_turn_prodt_result order by pt_plan_version desc;


select * from cfg_parameter where belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='PUBLISH_ABNORMAL_TYPE';
select * from cfg_parameter where param_name ='SECOND_ASSIGN_EMAIL';


select abnormal_type_code,bom_factory,t.* from sp_turn_prodt_result t
                                          where pt_plan_version ='2025-07-21'
                                            and demand_type= 2
                                            and abnormal_type_code like '%B-9%'
#                                           and ifnull(bom_factory,'') = ''
order by relation_id;

select abnormal_type_code,bom_factory,t.*
from sp_turn_prodt_result t where pt_plan_version ='2025-07-21'  AND relation_id in ('3805430','3805432','3805512');


select abnormal_type_code,bom_factory,t.*
from sp_turn_prodt_result t where pt_plan_version ='2025-07-21'  AND
                            in_out_zcode in ('Z4S20102080082', 'Z4S20102080083','Z4S20102080181');




;

select bom_factory,t.* from sp_zcode_optional_config_relation t where in_out_zcode in ('Z4S20102080082', 'Z4S20102080083','Z4S20102080181')