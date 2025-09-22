update sp_supply_path
set box_body= replace(box_body, '_', '&')
where path_dimension_code = 'ST01'
  and box_body like '%#_%' ESCAPE '#';

update mdm_sku_mst
set product_platform_name = replace(product_platform_name, '_', '&')
where whole_in_out in ('整机', '内机')
  and ifnull(product_panel, '') != '';

update mdm_item_master_mst
set product_platform_name = replace(product_platform_name, '_', '&')
where is_oem in ('OEM内销', '自主品牌内销')
  and whole_in_out in ('内机')
  and ifnull(product_panel, '') != ''
  and product_platform_name is not null;

select * from mdm_sku_mst
where
    product_platform_name  like '%#_%' ESCAPE '#' limit 1000;