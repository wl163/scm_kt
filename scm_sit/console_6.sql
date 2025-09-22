select count(1) from sp_zcode_optional_config_relation ;
-- original_zcode

select whole_code,whole_in_out,in_out_scode,in_out_zcode,original_zcode,in_out_zcode_qty,last_update_date
from sp_zcode_optional_config_relation where in_out_zcode like '%\_A'
                                         and ifnull(whole_code,'')= '' and whole_code_type='内销'
order by last_update_date desc ;


select whole_code, whole_in_out, in_out_scode, in_out_zcode, original_zcode, in_out_zcode_qty,product_type, bom_life_cycle ,last_update_date
from sp_zcode_optional_config_relation t
where in_out_zcode <> original_zcode ;



SELECT whole_code,in_out_scode,in_out_zcode,original_zcode FROM sp_zcode_optional_config_relation where original_zcode='Z4U20102053544';
select bom_code,bom_last_update_date from mdm_item_master_mst t where t.bom_code in (
    'Z4U20102053544'
    );

select * from mdm_item_master_mst ;

SELECT a.original_zcode,a.in_out_zcode,a.bom_factory,b.bom_factory
FROM sp_zcode_optional_config_relation a  join mdm_item_master_mst b
on a.original_zcode = b.bom_code
where a.bom_factory<> b.bom_factory ;

SELECT bom_factory ,creation_date,last_update_date ,t.* from sp_zcode_optional_config_relation t where original_zcode='Z4U20103083755';
select bom_factory from mdm_item_master_mst where bom_code = 'Z1U20203000438';
update mdm_item_master_mst set bom_factory='5540,5570,YN01' where id = '65297';

select  whole_code,in_out_scode,in_out_zcode,original_zcode ,bom_factory
        from sp_zcode_optional_config_relation where original_zcode <> in_out_zcode
                                                and original_zcode='Z1U20203000438'
                                                order by last_update_date desc;

-- id,whole_code,in_out_scode,in_out_zcode,original_zcode ,bom_factory
select id,whole_code,in_out_scode,in_out_zcode,original_zcode ,bom_factory
from sp_zcode_optional_config_relation
where whole_code = 'S12020100330' and in_out_scode='S12020300378' and original_zcode='Z1U20203000438';

select id,whole_code,in_out_scode,in_out_zcode,original_zcode ,bom_factory
from sp_zcode_optional_config_relation
where whole_code = 'S12020100330' and in_out_scode='S12020300378' and original_zcode='xxx';

select distinct bu_name,bg_name from scm_market_org where bu_name='ODM外销' order by bu_name,bg_name
-- Z1U20203000438

SELECT a.bom_factory ,a.creation_date,a.last_update_date ,b.bom_factory from sp_zcode_optional_config_relation a  left join mdm_item_master_mst b
on a.original_zcode = b.bom_code where b.bom_code='Z4U20103083755';


select * from sp_zcode_optional_config_relation order by last_update_date desc,creation_date desc;
select whole_code,in_out_scode,in_out_zcode,original_zcode ,priority,last_update_date from sp_zcode_optional_config_relation
                                                           order by whole_code,in_out_scode ,priority ,last_update_date desc;



select bom_factory from mdm_item_master_mst where bom_code = 'Z4U20103083755';

select *
from mdm_item_master_mst mst
         join (select distinct component_material_no from plm_s_z_relation) re on
    mst.bom_code = re.component_material_no
where mst.bom_code
          in (
              'Z1U20103000660_A',
              'Z1U20102001214_A',
              'Z1U39902000071_A',
              'Z1U39902000064_A',
              'Z1U20102001030_A',
              'Z1U30304000203_A',
              'Z1UC0304000010_A',
              'Z1U30104000780_A',
              'Z1U20103000463_A',
              'Z1U20102001085_A',
              'Z1U20102001139_A',
              'Z1U21104000001_A',
              'Z3U20103000355_A',
              'Z1U20904000027_A',
              'Z1U20102001018_A',
              'Z3U20103000183_A',
              'Z1U20904000023_A'
          );

select * from plm_s_z_relation where component_material_no = 'Z3U20102000403_A'