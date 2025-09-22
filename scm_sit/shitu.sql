create definer = scm_sit_admin@`%` view dp_inner_po_integration as
SELECT DISTINCT `pnh`.`po_no`                                                        AS `inner_po_no`,
                `pnh`.`pi_no`                                                        AS `pi_no`,
                (CASE
                     WHEN `pnl`.`multi_delivery_flag` = 'Y'
                         THEN IFNULL(`opnld`.`parent_po_line_no`, `opnld`.`po_line_no`)
                     ELSE IFNULL(`pnl`.`parent_po_line_no`, `pnl`.`po_line_no`) END) AS `inner_po_item_no`,
                (CASE
                     WHEN `pnl`.`multi_delivery_flag` = 'Y' THEN `opnld`.`po_line_detail_no`
                     ELSE `pnl`.`po_line_no` END)                                    AS `inner_po_item_no_detail`,
                `spsr`.`so_no`                                                       AS `so_no`,
                `spsr`.`so_line_no`                                                  AS `so_line_no`,
                `pnl`.`level`                                                        AS `level`,
                `pnh`.`require_goods_mode`                                           AS `require_goods_mode`,
                IF(`pnl`.`level` = '1', `pnl`.`bom_code`,
                   `omslineToParent`.`bom_code`)                                     AS `whole_material_no`,
                `pnl`.`proto_type_code`                                              AS `whole_proto_code`,
                `pnl`.`bom_code`                                                     AS `item_material_no`,
                `pnl`.`bom_code`                                                     AS `item_material_no_detail`,
                IF(`pnl`.`level` = '1', `pnl`.`proto_type_code`,
                   `pnl`.`prototype_in_out`)                                         AS `item_proto_material`,
                `pnh`.`require_goods_country`                                        AS `country`,
                (CASE
                     WHEN `pnh`.`doc_type_id` = 20 OR (`pnh`.`doc_type_id` = 10 AND
                                                       (`pnh`.`brand_business_region2` IS NOT NULL AND
                                                        `pnh`.`brand_business_region2` != ''))
                         THEN `countryBgSmo`.`region_code`
                     ELSE `pnh`.`area` END)                                          AS `bu_area`,
                (CASE
                     WHEN `pnh`.`doc_type_id` = 20 OR (`pnh`.`doc_type_id` = 10 AND
                                                       (`pnh`.`brand_business_region2` IS NOT NULL AND
                                                        `pnh`.`brand_business_region2` != ''))
                         THEN `pnh`.`brand_business_region2`
                     ELSE `pnh`.`sale_office` END)                                   AS `bg_branch_company`,
                (CASE
                     WHEN `pnh`.`doc_type_id` = 20 OR (`pnh`.`doc_type_id` = 10 AND
                                                       (`pnh`.`brand_business_region2` IS NOT NULL AND
                                                        `pnh`.`brand_business_region2` != ''))
                         THEN '自有品牌'
                     ELSE 'ODM' END)                                                 AS `brand_group`,
                'N'                                                                  AS `is_special`,
                `pnl`.`is_bulk`                                                      AS `is_bulk`,
                `pnl`.`bulk_require_goods_type`                                      AS `bulk_require_goods_mode`,
                `pnh`.`brand`                                                        AS `brand`,
                IF((CASE
                        WHEN `pnh`.`doc_type_id` = 20 OR (`pnh`.`doc_type_id` = 10 AND
                                                          (`pnh`.`brand_business_region2` IS NOT NULL AND
                                                           `pnh`.`brand_business_region2` != ''))
                            THEN `pnh`.`brand_business_region2`
                        ELSE `pnh`.`sale_office` END) IN ('EUBG', 'NABG'), `pnh`.`arriver_cust_code`,
                   `pnh`.`sold_cust_code`)                                           AS `customer`,
                `pnh`.`virtual_cust_name`                                            AS `virtual_customer`,
                (CASE
                     WHEN `pnl`.`multi_delivery_flag` = 'Y' THEN STR_TO_DATE(
                             REPLACE(`opnld`.`request_delivery_date`, '-', ''), '%Y%m%d')
                     ELSE STR_TO_DATE(REPLACE(`pnl`.`request_delivery_date`, '-', ''),
                                      '%Y%m%d') END)                                 AS `demand_date`,
                (CASE
                     WHEN `pnl`.`multi_delivery_flag` = 'Y' THEN `opnld`.`qty`
                     ELSE `pnl`.`qty` END)                                           AS `demand_qty`,
                IF(IFNULL(`spsr`.`open_qty`, `pnl`.`qty`) < 10 AND
                   STR_TO_DATE(REPLACE(`pnl`.`request_delivery_date`, '-', ''), '%Y%m%d') <
                   DATE_SUB(NOW(), INTERVAL 3 MONTH), `pnl`.`qty`,
                   IFNULL(`spsr`.`closed_qty`, 0))                                   AS `flip_instock_qty`,
                IF(IFNULL(`spsr`.`open_qty`, `pnl`.`qty`) < 10 AND
                   STR_TO_DATE(REPLACE(`pnl`.`request_delivery_date`, '-', ''), '%Y%m%d') <
                   DATE_SUB(NOW(), INTERVAL 3 MONTH), 0,
                   IFNULL(`spsr`.`open_qty`, `pnl`.`qty`))                           AS `no_flip_instock_qty`,
                IFNULL(`spsr`.`shipped_qty`, 0)                                      AS `delivered_qty`,
                IFNULL(`spsr`.`unshipped_qty`, `pnl`.`qty`)                          AS `undeliver_qty`,
                `pnh`.`enabled_odf`                                                  AS `enabled_odf`,
                `pnh`.`enabled_offset`                                               AS `enabled_offset`,
                `pnh`.`is_weekly_offset`                                             AS `is_weekly_offset`,
                `pnl`.`demand_factory`                                               AS `demand_factory`,
                `pnl`.`model_category`                                               AS `model_category`,
                IF(`pnl`.`level` = '1', `pnl`.`proto_type_code`,
                   `pnl`.`prototype_in_out`)                                         AS `proto_type_code`,
                IF(`pnl`.`level` = '1', `pnl`.`proto_type_name`,
                   `pnl`.`prototype_in_out_name`)                                    AS `proto_type_name`,
                `pnh`.`order_source`                                                 AS `order_source`,
                `pnh`.`so_major_categories`                                          AS `so_major_categories`,
                `owro`.`is_excess`                                                   AS `is_excess`,
                `owro`.`excess_qty`                                                  AS `excess_qty`,
                `owro`.`is_excess_rhythm`                                            AS `is_excess_rhythm`,
                `owro`.`excess_rhythm_qty`                                           AS `excess_rhythm_qty`,
                `pnh`.`is_turn_prodt_date`                                           AS `is_turn_prodt_date`,
                `pnh`.`created_by`                                                   AS `created_by`,
                `pnh`.`creation_date`                                                AS `creation_date`,
                `pnh`.`last_updated_by`                                              AS `last_updated_by`,
                `pnh`.`last_update_date`                                             AS `last_update_date`,
                `pnh`.`created_account`                                              AS `created_account`,
                `pnh`.`last_updated_account`                                         AS `last_updated_account`,
                `pnh`.`org_id`                                                       AS `org_id`,
                `pnh`.`delete_flag`                                                  AS `delete_flag`,
                `pnl`.`multi_delivery_flag`                                          AS `multi_delivery_flag`
FROM (((((`scm_sit_kt_plan`.`oms_prodt_notice_header_mst` AS `pnh` LEFT JOIN `scm_sit_kt_plan`.`oms_prodt_notice_line_mst` AS `pnl`
          ON `pnh`.`po_no` = `pnl`.`po_no` AND `pnl`.`org_id` = 'KT') LEFT JOIN `scm_sit_kt_plan`.`oms_prodt_notice_line_mst` AS `omslineToParent`
         ON `pnl`.`po_no` = `omslineToParent`.`po_no` AND `pnl`.`parent_po_line_no` = `omslineToParent`.`po_line_no` AND
            `omslineToParent`.`org_id` =
            'KT') LEFT JOIN `scm_sit_kt_plan`.`oms_sap_prodt_so_relationship` AS `spsr`
        ON `spsr`.`po_no` = `pnh`.`po_no` AND `spsr`.`po_line_no` = `pnl`.`po_line_no` AND
           `spsr`.`org_id` = 'KT') LEFT JOIN `scm_sit_kt_plan`.`dp_po_offset_status` AS `owro`
       ON `pnl`.`po_no` = `owro`.`inner_po_no` AND `pnl`.`po_line_no` =
                                                   `owro`.`inner_po_item_no`) LEFT JOIN `scm_sit_kt_plan`.`oms_prodt_notice_line_detail` AS `opnld`
      ON `pnl`.`po_no` = `opnld`.`po_no` AND `pnl`.`po_line_no` = `opnld`.`po_line_no`)
         LEFT JOIN (SELECT DISTINCT `country_code` AS `country_code`,
                                    `bg_code`      AS `bg_code`,
                                    `region_code`  AS `region_code`
                    FROM `scm_sit_kt_plan`.`scm_market_org`
                    WHERE `org_id` = 'KT'
                    GROUP BY `country_code`, `bg_code`) AS `countryBgSmo`
                   ON `countryBgSmo`.`country_code` = `pnh`.`destination_country` AND
                      `pnh`.`brand_business_region2` = `countryBgSmo`.`bg_code`
WHERE `pnh`.`org_id` = 'KT'
UNION ALL
SELECT DISTINCT `tph`.`pr_no`                                                        AS `inner_po_no`,
                NULL                                                                 AS `pi_no`,
                (CASE
                     WHEN `tpi`.`multi_delivery_flag` = 'Y'
                         THEN IFNULL(`tpid`.`parent_po_line_no`, `tpid`.`po_line_no`)
                     ELSE IFNULL(`tpi`.`parent_po_line_no`, `tpi`.`po_line_no`) END) AS `inner_po_item_no`,
                (CASE
                     WHEN `tpi`.`multi_delivery_flag` = 'Y' THEN `tpid`.`po_line_detail_no`
                     ELSE `tpi`.`po_line_no` END)                                    AS `inner_po_item_no_detail`,
                `psr`.`so_no`                                                        AS `so_no`,
                `psr`.`so_line_no`                                                   AS `so_line_no`,
                `tpi`.`level`                                                        AS `level`,
                `tph`.`require_goods_mode`                                           AS `require_goods_mode`,
                IF(`tpi`.`level` = '1', `tpi`.`cust_bom_code`,
                   `toflineToParent`.`cust_bom_code`)                                AS `whole_material_no`,
                `sku`.`proto_code`                                                   AS `whole_proto_code`,
                `tpi`.`cust_bom_code`                                                AS `item_material_no`,
                `tpi`.`material_no`                                                  AS `item_material_no_detail`,
                IF(`tpi`.`level` = '1', `sku`.`proto_code`,
                   `sku_1`.`proto_code`)                                             AS `item_proto_material`,
                'CN'                                                                 AS `country`,
                'CN'                                                                 AS `bu_area`,
                'CBG'                                                                AS `bg_branch_company`,
                (CASE
                     WHEN `tph`.`order_sub_type_name` LIKE '%品牌%' OR
                          `tph`.`order_sub_type_name` LIKE '%特种%' THEN '自有品牌'
                     WHEN `tph`.`order_sub_type_name` LIKE '%ODM%' OR
                          `tph`.`order_sub_type_name` LIKE '%OEM%' THEN 'ODM'
                     ELSE '' END)                                                    AS `brand_group`,
                (CASE
                     WHEN `order_sub_type_name` LIKE '%特种%' THEN 'Y'
                     ELSE 'N' END)                                                   AS `is_special`,
                `tpi`.`is_bulk`                                                      AS `is_bulk`,
                `tpi`.`bulk_require_goods_type`                                      AS `bulk_require_goods_mode`,
                `sku`.`product_brand`                                                AS `brand`,
                `tph`.`sales_cust_code`                                              AS `customer`,
                NULL                                                                 AS `virtual_customer`,
                (CASE
                     WHEN `tpi`.`multi_delivery_flag` = 'Y' THEN STR_TO_DATE(
                             REPLACE(`tpid`.`request_delivery_date`, '-', ''), '%Y%m%d')
                     ELSE STR_TO_DATE(REPLACE(`tpi`.`request_delivery_date`, '-', ''),
                                      '%Y%m%d') END)                                 AS `demand_date`,
                (CASE
                     WHEN `tpi`.`multi_delivery_flag` = 'Y' THEN `tpid`.`qty`
                     ELSE `tpi`.`qty` END)                                           AS `demand_qty`,
                IF(`order_sub_type_name` NOT LIKE '%特种%' AND IFNULL(`psr`.`open_qty`, `tpi`.`qty`) < 10 AND
                   STR_TO_DATE(REPLACE(`tpi`.`request_delivery_date`, '-', ''), '%Y%m%d') <
                   DATE_SUB(NOW(), INTERVAL 3 MONTH), `tpi`.`qty`,
                   IFNULL(`psr`.`closed_qty`, 0))                                    AS `flip_instock_qty`,
                IF(`order_sub_type_name` NOT LIKE '%特种%' AND IFNULL(`psr`.`open_qty`, `tpi`.`qty`) < 10 AND
                   STR_TO_DATE(REPLACE(`tpi`.`request_delivery_date`, '-', ''), '%Y%m%d') <
                   DATE_SUB(NOW(), INTERVAL 3 MONTH), 0,
                   IFNULL(`psr`.`open_qty`, `tpi`.`qty`))                            AS `no_flip_instock_qty`,
                IFNULL(`psr`.`shipped_qty`, 0)                                       AS `delivered_qty`,
                IFNULL(`psr`.`unshipped_qty`, `tpi`.`qty`)                           AS `undeliver_qty`,
                `tph`.`enabled_odf`                                                  AS `enabled_odf`,
                `tph`.`enabled_offset`                                               AS `enabled_offset`,
                `tph`.`is_weekly_offset`                                             AS `is_weekly_offset`,
                `tpi`.`demand_factory`                                               AS `demand_factory`,
                'CBU'                                                                AS `model_category`,
                IF(`tpi`.`level` = '1', `sku`.`proto_code`,
                   `sku_1`.`proto_code`)                                             AS `proto_type_code`,
                NULL                                                                 AS `proto_type_name`,
                NULL                                                                 AS `order_source`,
                NULL                                                                 AS `so_major_categories`,
                `owro`.`is_excess`                                                   AS `is_excess`,
                `owro`.`excess_qty`                                                  AS `excess_qty`,
                `owro`.`is_excess_rhythm`                                            AS `is_excess_rhythm`,
                `owro`.`excess_rhythm_qty`                                           AS `excess_rhythm_qty`,
                `tph`.`is_turn_prodt_date`                                           AS `is_turn_prodt_date`,
                `tph`.`created_by`                                                   AS `created_by`,
                `tph`.`creation_date`                                                AS `creation_date`,
                `tph`.`last_updated_by`                                              AS `last_updated_by`,
                `tph`.`last_update_date`                                             AS `last_update_date`,
                `tph`.`created_account`                                              AS `created_account`,
                `tph`.`last_updated_account`                                         AS `last_updated_account`,
                `tph`.`org_id`                                                       AS `org_id`,
                `tph`.`delete_flag`                                                  AS `delete_flag`,
                `tpi`.`multi_delivery_flag`                                          AS `multi_delivery_flag`
FROM ((((((`scm_sit_kt_plan`.`tof_pr_header_mst` AS `tph` LEFT JOIN `scm_sit_kt_plan`.`tof_pr_item_mst` AS `tpi`
           ON `tph`.`pr_no` = `tpi`.`pr_no` AND `tpi`.`org_id` = 'KT') LEFT JOIN `scm_sit_kt_plan`.`tof_pr_item_mst` AS `toflineToParent`
          ON `tpi`.`pr_no` = `toflineToParent`.`pr_no` AND
             `tpi`.`parent_po_line_no` = `toflineToParent`.`po_line_no` AND
             `toflineToParent`.`org_id` = 'KT') LEFT JOIN `scm_sit_kt_plan`.`pr_so_relationship` AS `psr`
         ON `psr`.`pr_no` = `tph`.`pr_no` AND `psr`.`pr_line_no` = `tpi`.`po_line_no` AND
            `psr`.`org_id` = 'KT') LEFT JOIN `scm_sit_kt_plan`.`mdm_sku_mst` AS `sku`
        ON `sku`.`org_id` = 'KT' AND `sku`.`code` = `tpi`.`cust_bom_code`) LEFT JOIN `scm_sit_kt_plan`.`mdm_sku_mst` AS `sku_1`
       ON `sku_1`.`org_id` = 'KT' AND
          `sku_1`.`code` = `tpi`.`material_no`) LEFT JOIN `scm_sit_kt_plan`.`tof_pr_item_detail` AS `tpid`
      ON `tpi`.`pr_no` = `tpid`.`pr_no` AND `tpi`.`po_line_no` = `tpid`.`po_line_no`)
         LEFT JOIN `scm_sit_kt_plan`.`dp_po_offset_status` AS `owro`
                   ON `tpi`.`pr_no` = `owro`.`inner_po_no` AND `tpi`.`po_line_no` = `owro`.`inner_po_item_no`
WHERE `tph`.`org_id` = 'KT';

