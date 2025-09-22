select bom_code,whole_in_out,product_type,proto_code,bom_factory from mdm_item_master_in where product_type <> '原型机' and bom_code='Z4U20203001781';


# 关联逻辑示意：
select a.bom_code,a.bom_factory,a.product_type,b.proto_code,b.product_type as in_type from mdm_item_master_in a inner join (
        select proto_code,product_type from mdm_item_master_in where product_type <> '原型机'
) b on a.bom_code = b.proto_code;

-- 更新历史数据
update mdm_item_master_mst as a
    join (select proto_code, bom_factory
          from mdm_item_master_mst where product_type <> '原型机') as b
    on a.bom_code = b.proto_code
set a.bom_factory = b.bom_factory
where a.bom_factory <> b.bom_factory;



/*update mdm_item_master_mst as mst
    join (select a.bom_code, a.bom_factory
          from mdm_item_master_in a
                   join (select proto_code
                         from mdm_item_master_in
                         where product_type <> '原型机') b
                        on a.bom_code = b.proto_code) mi
    on mi.bom_code = mst.proto_code
set mst.bom_factory = mi.bom_factory
where mst.bom_factory <> mi.bom_factory;
*/

select * from mdm_item_master_mst where product_type <> '原型机';






select bom_factory from mdm_item_master_mst where proto_code='Z4U20203000930';

/*select bom_code, a.proto_code, bom_factory, product_type
from mdm_item_master_in a
         join (select distinct proto_code
               from mdm_item_master_mst
               where product_type <> '原型机' and ifnull(proto_code, '') <> '') b
             on a.bom_code = b.proto_code ;
*/

select bom_factory from mdm_item_master_in where bom_code in ('Z2U20103004774','Z2U20103004793');
select bom_code,proto_code,product_type,bom_factory from mdm_item_master_in t where t.proto_code in ('Z4U39901000078','Z1U39901000004')
and bom_code in ('Z4U39901000078','Z1U39901000004')
