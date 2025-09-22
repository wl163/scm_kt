CREATE TABLE `scm_item_bom_factoy_initial` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `bom_code` varchar(64) NOT NULL COMMENT 'BOM编码',
  `bom_factory` varchar(64) NOT NULL COMMENT 'BOM工厂',
  `created_by` bigint(20) DEFAULT NULL COMMENT '创建人',
  `creation_date` datetime DEFAULT NULL COMMENT '创建时间',
  `last_updated_by` bigint(20) DEFAULT NULL COMMENT '修改人ID(架构字段)',
  `last_update_date` datetime DEFAULT NULL COMMENT '最近更新日期',
  `created_account` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人OA账号(架构)',
  `last_updated_account` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '修改人OA账号(架构)',
  `org_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '组织ID',
  `delete_flag` tinyint(4) DEFAULT NULL COMMENT '删除标识(架构)',
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB COMMENT='物料主数据BOM工厂初始化';


-- 用初始化数据更新mst表BOM工厂
update mdm_item_master_mst im
left join scm_item_bom_factoy_initial fi
on im.bom_code = fi.bom_code 
set im.bom_factory = fi.bom_factory 
where
fi.bom_code is not null;



-- 内销
update mdm_item_master_mst imo
left join mdm_item_master_mst imp
on TRIM(TRAILING '_A' FROM imo.bom_code) = imp.bom_code
set imo.bom_factory = imp.bom_factory 
where
imo.bom_code like '%\_A'
and
exists(select 1 from cfg_parameter where belong_domain='ALL' and PARAM_NAME='MST_IS_OEM_C' and attr1='Y' and imo.is_oem = PARAM_VALUE)
and
imp.bom_code is not null
and
IFNULL(imo.bom_factory,'') != IFNULL(imp.bom_factory,'');

-- 外销
update mdm_item_master_mst imo
left join mdm_item_master_mst imp
on imo.proto_code = imp.bom_code
set imo.bom_factory = imp.bom_factory 
where
imo.product_type <> '原型机'
and
exists(select 1 from cfg_parameter where belong_domain='ALL' and PARAM_NAME='MST_IS_OEM_O' and attr1='Y' and imo.is_oem = PARAM_VALUE)
and
imp.bom_code is not null;


