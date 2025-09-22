-- bom状态
select * from cfg_parameter where param_name='BOM_STATUS_DEFINE' ;
select param_value,`desc` from cfg_parameter where param_name='BOM_STATUS_DEFINE';


-- BOM状态取值逻辑 Z4S20102080260
select distinct bom_status from plm_bom_header where root_bom_no = 'Z4S20202080016';


select bom_status,bom_factory from sp_zcode_optional_config_relation where in_out_zcode='Z4S20202080016';

select * from mdm_item_master_mst where bom_code = 'Z4S20102080260' ; -- 批产(产品) ;
select * from sp_zcode_optional_config_relation where in_out_zcode='Z4S20202080016';
select * from sp_zcode_optional_config_relation order by creation_date desc;

select * from plm_s_z_relation where component_material_no  = 'Z4S20102080260';


select * from sp_zcode_optional_config_relation where in_out_zcode='Z4S20202080016';
select* from sp_turn_prodt_kits_structure order by creation_date desc;
select * from plm_bom_header;

-- 查询条件“BOM工厂”取值校验
select distinct bom_factory from sp_zcode_optional_config_relation where ifnull(bom_factory,'')<>'';

select * from sp_turn_prodt_effective_demand_config WHERE bom_status='01' and bom_life_cycle='批产(产品)';

SELECT demand_type,
       business_line,
       relation_id,
       proto_code,
       doc_no,
       doc_line_no,
       level_no,
       bom_life_cycle,
       bom_status,
       bom_factory,
       finished_factory,
       turn_prodt_factory,
       abnormal_type_code,
       in_out_zcode
FROM sp_turn_prodt_result t
where pt_plan_version = '2025-08-04' and demand_type = 1
  and proto_code_type != '套机'
  and proto_code = 'Z2U20301000790'
order by relation_id, level_no, doc_line_no
limit 3;

select * FROM sp_turn_prodt_result t
where pt_plan_version = '2025-08-04' order by creation_date desc ;

-- Z2S20103080130_ST Z2S20102080136_ST
select * from sp_zcode_optional_config_relation where in_out_zcode in ('Z2S20103080130_ST','Z2S20102080136_ST') ;


select in_out_zcode
from sp_zcode_optional_config_relation
where in_out_zcode in (SELECT in_out_zcode
                       FROM sp_turn_prodt_result t
                       where pt_plan_version = '2025-08-04'
                         and demand_type = 2
                         and proto_code_type != '套机');



select *
FROM sp_turn_prodt_result t
where pt_plan_version = '2025-08-04'
  and demand_type = 2
  and proto_code_type = '套机'
    and proto_code = 'Z2U20101008098'
order by relation_id, level_no, doc_line_no;



select param_value, `desc`
from cfg_parameter
where param_name = 'BOM_STATUS_DEFINE'
  and param_value in (select bom_status
                      from plm_bom_header
                      where root_bom_no = 'Z4U20102081922') ;


select * from cfg_parameter where param_name ='SECOND_ASSIGN_EMAIL';

-- BOM生命周期
select distinct bom_life_cycle from mdm_item_master_mst;

-- 有效需求配置
select * from sp_turn_prodt_effective_demand_config WHERE bom_life_cycle='批产(产品)' AND bom_status='07';


--
select * from cfg_parameter where param_name = 'PUBLISH_ABNORMAL_TYPE' ;



select distinct basic_unit from mdm_item_master_mst