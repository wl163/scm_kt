-- 配置数据
select  * from cfg_parameter where belong_domain='ALL' and PARAM_NAME='MST_IS_OEM_C' and attr1 = 'Y' ;

select  * from cfg_parameter where belong_domain='ALL' and PARAM_NAME='MST_IS_OEM_O' and attr1 = 'Y' ;

-- 内销
with mst as (SELECT bom_code, REPLACE(bom_code, '_A', '') AS bom_code2, bom_factory
             FROM mdm_item_master_mst a
             WHERE is_oem IN (select param_value
                              from cfg_parameter
                              where belong_domain = 'ALL'
                                and PARAM_NAME = 'MST_IS_OEM_C'
                                and attr1 = 'Y'
                              )
#                AND RIGHT(bom_code, 2) = '_A'
             )
select mst.bom_code, mst.bom_code2, mst.bom_factory, b.bom_code, b.bom_factory,b.is_oem
from mst
         left join mdm_item_master_in b on mst.bom_code2 = b.bom_code
where b.bom_code='Z1U20102000516' ;


-- 外销
with mst as (select a.bom_code, a.proto_code, a.bom_factory,a.is_oem,a.product_type
             from mdm_item_master_mst a
             where a.is_oem in (select param_value
                                from cfg_parameter
                                where belong_domain = 'ALL'
                                  and PARAM_NAME = 'MST_IS_OEM_O'
                                  and attr1 = 'Y')
               AND a.product_type <> '原型机')
select mst.is_oem, mst.bom_code, mst.proto_code, mst.product_type, mst.bom_factory, b.bom_code,b.product_type ,b.bom_factory
from mst
         left join mdm_item_master_in b on mst.proto_code = b.bom_code
where mst.bom_code = 'Z4U20103037179'
order by mst.bom_code ;



-- 5500,5520,5540,5550,5660,5570
select is_oem,bom_code,bom_factory,product_type from mdm_item_master_in where bom_code in
                                                                 ('Z2U20102007180','Z2U20103007093');


select is_oem,bom_code,bom_factory from mdm_item_master_in where is_oem = 'OEM内销' ;


select * from scm_item_bom_factoy_initial where bom_code = 'Z4U20103037179' ;
select bom_factory,proto_code, product_type,is_oem,t.* from mdm_item_master_mst t where bom_code = 'Z1U20103000825' ;


select bom_factory, product_type,t.* from mdm_item_master_mst t where bom_code = 'Z1U20103000825' ;


select bom_factory from sp_zcode_optional_config_relation where in_out_zcode='Z1U20103000621'



select *
                              from cfg_parameter
                              where belong_domain = 'ALL'
                                and PARAM_NAME = 'MST_IS_OEM_O'
                                and attr1 = 'Y'



select
b.physical_addr,
base,
date_format(whenloaded, '%Y%m') as month,
sum(dmdpegqty) -- 实际耗用产能
from (select *
      from sp_tmp_mds_material_pegging
      where version = (select distinct VERSION from sp_tmp_mds_material_pegging t ORDER BY VERSION DESC LIMIT 1)) as a
         left join sop_final_assembly_line_capacity_plan b
                   on regexp_substr(a.res, '[^_]+', 1, 2) = b.scm_line_body
where capacity not in (100000000, 1000000000, 0)
  and restype = '总装产能'
group by physical_addr, month;


/*实际消耗的两器产能*/
select b.physical_addr,
       base,
       date_format(whenloaded, '%Y%m') as month,
       sum(dmdpegqty)
from (select *
      from sp_tmp_mds_material_pegging
      where version = (select distinct VERSION from sp_tmp_mds_material_pegging t ORDER BY VERSION DESC LIMIT 1)) a
         left join sop_two_devices_capacity_info_header b
                   on a.unitespec = concat(b.material_type, '_', b.unite_spec, '_', b.base)
where capacity not in (100000000, 1000000000, 0)
  and restype = '两器产能'
group by physical_addr, month
order by physical_addr, month;


select atp_plan_start_date from atp_plan_start_date_r4_data_funnel

