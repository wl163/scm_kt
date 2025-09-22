WITH cte_relation AS (SELECT COALESCE(
                                     CASE
                                         WHEN item1.whole_in_out = '整机' OR sku_parent.whole_in_out = '整机'
                                             THEN pszr.parent_part_code END,
                                     NULL
                             )                          AS whole_code,
                             pszr.bom_no,
                             COALESCE(
                                     CASE
                                         WHEN pszr.bom_no LIKE 'S%' AND sku_bom.whole_in_out IN ('内机', '外机')
                                             THEN pszr.bom_no END,
                                     NULL
                             )                          AS in_out_scode,
                             pszr.p_qty,
                             pszr.component_material_no,
                             pszr.component_material_no as original_zcode,
                             pszr.whole_in_out,
                             pszr.type_code,
                             pszr.product_categ,
                             pszr.is_forecast,
                             pszr.m_qty
                      FROM (SELECT t.parent_part_code,
                                   t.bom_no,
                                   t.component_material_no,
                                   t.whole_in_out,
                                   t.p_qty,
                                   t.m_qty,
                                   pc.product_categ,
                                   COALESCE(pc.is_forecast, '') AS is_forecast,
                                   item2.type_code
                            FROM plm_s_z_relation t
                                     LEFT JOIN mdm_item_master_mst item2
                                               ON t.component_material_no = item2.bom_code
                                     LEFT JOIN sp_product_categ pc
                                               ON item2.type_code = pc.product_categ_code
                            WHERE t.delete_flag = 0
                              AND (
                                pc.is_forecast = 'Y'
                                    OR EXISTS (SELECT 1
                                               FROM sp_bom_white_list sbwl
                                               WHERE
                                                   IFNULL(sbwl.parent_part_code, '1') = IFNULL(t.parent_part_code, '1')
                                                 AND IFNULL(sbwl.bom_no, '1') = IFNULL(t.bom_no, '1')
                                                 AND IFNULL(sbwl.component_material_no, '1') =
                                                     IFNULL(t.component_material_no, '1'))
                                )) pszr
                               LEFT JOIN mdm_item_master_mst item1
                                         ON pszr.parent_part_code = item1.bom_code
                               LEFT JOIN mdm_sku_mst sku_parent
                                         ON pszr.parent_part_code = sku_parent.code
                               LEFT JOIN mdm_sku_mst sku_bom
                                         ON pszr.bom_no = sku_bom.code),
     cte_zcode_choose AS (select cr.*,
                              /*Z码逻辑变更：当S码或者整机码为S开头, 且组件编码 || _A存在于mdm_item_master_mst和plm_s_z_relation表中时, 取组件编码 || _A, 其他情况直接取组件编码*/
                                 CASE
                                     WHEN comonent_item.bom_code IS NOT NULL AND pszr.component_material_no IS NOT NULL
                                         THEN
                                         CONCAT(cr.component_material_no, '_A')
                                     ELSE
                                         cr.component_material_no
                                     END AS in_out_zcode
                          FROM cte_relation cr
                                   LEFT JOIN mdm_item_master_mst comonent_item
                                             ON (cr.whole_code like 'S%' or cr.in_out_scode like 'S%')
                                                 AND CONCAT(cr.component_material_no, '_A') = comonent_item.bom_code
                                   LEFT JOIN plm_s_z_relation pszr
                                             ON (cr.whole_code like 'S%' or cr.in_out_scode like 'S%')
                                                 AND
                                                CONCAT(cr.component_material_no, '_A') = pszr.component_material_no),
     cte_data AS (SELECT cr.type_code,
                         cr.product_categ,
                         cr.whole_code,
                         cr.in_out_scode,
                         cr.in_out_zcode,
                         cr.original_zcode,
                         cr.whole_in_out,
                         IF(cr.whole_code IS NOT NULL AND cr.in_out_scode IS NOT NULL, cr.p_qty,
                            NULL)                                                                        AS in_out_scode_qty,
                         IF(cr.whole_code IS NOT NULL AND cr.original_zcode IS NOT NULL, cr.m_qty,
                            NULL)                                                                        AS in_out_zcode_qty,
                         CASE
                             WHEN cr.original_zcode IS NOT NULL THEN
                                 zcode_item.product_type
                             WHEN cr.original_zcode IS NULL AND cr.in_out_scode IS NOT NULL THEN
                                 IFNULL(scode_item.product_type, scode_sku.product_type)
                             WHEN cr.original_zcode IS NULL AND cr.in_out_scode IS NULL THEN
                                 IFNULL(wcode_item.product_type, wcode_sku.product_type)
                             END                                                                         AS product_type,
                         IF(cr.original_zcode IS NOT NULL, zcode_item.bom_life_cycle, NULL)              AS bom_life_cycle,
                         IF(cr.original_zcode IS NOT NULL, zcode_item.bom_factory, NULL)                 AS bom_factory,
                         IF(cr.original_zcode IS NOT NULL, zcode_item.bom_last_update_date,
                            NULL)                                                                        AS bom_update_time,
                         CASE
                             WHEN cr.original_zcode IS NOT NULL THEN
                                 zcode_item.product_platform_name
                             WHEN cr.original_zcode IS NULL AND cr.in_out_scode IS NOT NULL THEN
                                 IFNULL(scode_item.product_platform_name, scode_sku.product_platform_name)
                             WHEN cr.original_zcode IS NULL AND cr.in_out_scode IS NULL THEN
                                 IFNULL(wcode_item.product_platform_name, wcode_sku.product_platform_name)
                             END                                                                         AS box_body,
                         CASE
                             WHEN cr.whole_code IS NOT NULL AND cr.in_out_scode IS NOT NULL
                                 AND COUNT(*) OVER (PARTITION BY cr.whole_code, cr.in_out_scode, cr.whole_in_out) > 1
                                 THEN '一对多'
                             ELSE '一对一'
                             END                                                                         AS selectable_relation,
                         CASE LEFT(cr.whole_code, 1)
                             WHEN 'S' THEN 'S码'
                             WHEN 'Z' THEN 'Z码'
                             ELSE '其他'
                             END                                                                         AS whole_code_type
                  FROM cte_zcode_choose cr
                           LEFT JOIN mdm_item_master_mst zcode_item ON original_zcode = zcode_item.bom_code
                           LEFT JOIN mdm_item_master_mst scode_item ON in_out_scode = scode_item.bom_code
                           LEFT JOIN mdm_item_master_mst wcode_item ON cr.whole_code = wcode_item.bom_code
                           LEFT JOIN mdm_sku_mst scode_sku ON cr.in_out_scode = scode_sku.code
                           LEFT JOIN mdm_sku_mst wcode_sku ON cr.whole_code = wcode_sku.code),
     cte_priority AS (SELECT *,
                             CASE
                                 WHEN cte_data.selectable_relation = '一对多' THEN
                                     CASE
                                         WHEN cte_data.bom_life_cycle IN ('首批(未评审)', '首批(产品)', '批产(产品)', '批产(订单)')
                                             THEN 'L1'
                                         WHEN cte_data.bom_life_cycle IN ('试制(产品)', '试产(产品)') THEN 'L2'
                                         WHEN cte_data.bom_life_cycle IN ('开发(产品)', '退市(产品)') THEN 'L999'
                                         ELSE 'L3'
                                         END
                                 END AS sort_level
                      FROM cte_data)
SELECT type_code,
       product_categ,
       whole_code_type,
       product_type,
       whole_in_out,
       whole_code,
       in_out_scode,
       in_out_zcode,
       original_zcode,
       box_body,
       in_out_scode_qty,
       in_out_zcode_qty,
       bom_update_time,
       CASE
           WHEN selectable_relation = '一对多' THEN
               CASE
                   WHEN sort_level = 'L999' THEN
                       0
                   WHEN sort_level IN ('L1', 'L2', 'L3') THEN
                       ROW_NUMBER() OVER (PARTITION BY whole_code, in_out_scode ORDER BY sort_level, bom_update_time DESC)
                   END
           ELSE 1
           END AS recommend_priority,
       CASE
           WHEN selectable_relation = '一对多' THEN
               CASE
                   WHEN sort_level = 'L999' THEN
                       0
                   WHEN sort_level IN ('L1', 'L2', 'L3') THEN
                       ROW_NUMBER() OVER (PARTITION BY whole_code, in_out_scode ORDER BY sort_level, bom_update_time DESC)
                   END
           ELSE 1
           END AS priority,
       selectable_relation,
       bom_life_cycle,
       bom_factory,
       '否'    AS remind_flag
FROM cte_priority  where whole_code like 'S%';


# select * from sp_zcode_optional_config_relation;
# select bom_factory from mdm_item_master_mst where bom_code='Z1U20103000890'