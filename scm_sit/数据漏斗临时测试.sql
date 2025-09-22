select SUBSTR(REPLACE(PARAM_VALUE, '/'), 1, 6)
            from rp_cfg_parameter
            where param_name = 'ATP_PLAN_START_DATE';


select pt_plan_version as version,sum(turn_prodt_qty) from sp_turn_prodt_result group by version


-- bom_factory,bom_code
select distinct is_oem  from mdm_item_master_mst ;

select bom_code,bom_factory, is_oem,product_type_code ,product_type from mdm_item_master_mst where bom_code like '%\_A';