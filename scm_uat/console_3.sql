SELECT `rpsd`.`whole_s_code`                 AS `whole_code`,
       `inv`.`product_sku_code`              AS `single_code`,
       `inv`.`product_sku_code`              AS `product_sku_code`,
       `rpsd`.`internal_or_external_machine` AS `whole_in_out`,
       `inv`.`logic_whse_type_name`          AS `logic_whse_type_name`,
       `inv`.`logic_whse_func_type_name`     AS `logic_whse_func_type_name`,
       `inv`.`logic_whse_name`               AS `logic_whse_name`,
       `inv`.`logic_whse_code`               AS `logic_whse_code`,
       `inv`.`sales_org_name`                AS `sales_org_name`,
       `inv`.`sales_org_code`                AS `sales_org_code`,
       (CASE
            WHEN `inv`.`logic_whse_type_name` = _UTF8MB4'CDC' AND
                 `inv`.`logic_whse_name` NOT LIKE _UTF8MB4'%KY-3W菜鸟仓%' AND
                 `inv`.`logic_whse_name` NOT LIKE _UTF8MB4'%京东%' THEN IFNULL(`inv`.`plan_inv_crm`, 0)
            ELSE 0 END)                      AS `cdc_inv_total`,
       (CASE
            WHEN `inv`.`logic_whse_type_name` = _UTF8MB4'RDC' AND
                 `inv`.`logic_whse_name` NOT LIKE _UTF8MB4'%KY-3W菜鸟仓%' AND
                 `inv`.`logic_whse_name` NOT LIKE _UTF8MB4'%京东%' THEN IFNULL(`inv`.`plan_inv_crm`, 0)
            ELSE 0 END)                      AS `rdc_inv_total`,
       (CASE
            WHEN `inv`.`logic_whse_name` LIKE _UTF8MB4'%KY-3W菜鸟仓%' OR `inv`.`logic_whse_name` LIKE _UTF8MB4'%京东%'
                THEN IFNULL(`inv`.`plan_inv_crm`, 0)
            ELSE 0 END)                      AS `plat_inv_total`,
       `inv`.`plan_inv_crm`                  AS `plan_inv_crm`,
       `inv`.`product_model_name`            AS `product_model_name`,
       `inv`.`data_date`                     AS `inv_last_update_time`,
       1                                     AS `created_by`,
       NOW()                                 AS `creation_date`,
       1                                     AS `last_updated_by`,
       NOW()                                 AS `last_update_date`,
       _UTF8MB4'admin'                       AS `created_account`,
       _UTF8MB4'admin'                       AS `last_updated_account`,
       _UTF8MB4'KT'                          AS `org_id`,
       0                                     AS `delete_flag`
FROM (SELECT `tmp`.`whole_s_code`                             AS `whole_s_code`,
             IF(`bkr`.`whole_machine_code` IS NOT NULL, 1, 0) AS `flag`,
             IF(`bkr`.`whole_machine_code` IS NOT NULL, `bkr`.`single_machine_code`,
                NULL)                                         AS `single_machine_code`,
             IF(`bkr`.`whole_machine_code` IS NOT NULL, `bkr`.`internal_or_external_machine`,
                NULL)                                         AS `internal_or_external_machine`
      FROM (SELECT `lg`.`whole_s_code` AS `whole_s_code`
            FROM `scm_uat_kt_plan`.`dp_require_plan_simulation_dom_data_large` AS `lg`
            WHERE NOT EXISTS (SELECT 1 AS `1`
                              FROM `scm_uat_kt_plan`.`scm_kt_bulk_kits_relationship` AS `rt`
                              WHERE `lg`.`whole_s_code` = `rt`.`single_machine_code`
                                AND IFNULL(`rt`.`whole_machine_code`, _UTF8MB4'') != _UTF8MB4'')
            GROUP BY `lg`.`whole_s_code`) AS `tmp`
               LEFT JOIN `scm_uat_kt_plan`.`scm_kt_bulk_kits_relationship` AS `bkr`
                         ON (`tmp`.`whole_s_code` = `bkr`.`whole_machine_code` AND
                             `bkr`.`internal_or_external_machine` = _UTF8MB4'内机')) AS `rpsd`
         LEFT JOIN `scm_uat_kt_plan`.`v_dw_cbg_warehouse_inv` AS `inv`
                   ON IF(`rpsd`.`flag` = 1, `rpsd`.`single_machine_code`, `rpsd`.`whole_s_code`) =
                      `inv`.`product_sku_code` AND
                      `inv`.`product_line_name` IN (_UTF8MB4'TCL_空调产品线', _UTF8MB4'乐华_空调产品线') AND
                      `inv`.`logic_whse_func_type_name` = _UTF8MB4'好机仓' AND
                      `inv`.`company_code` != _UTF8MB4'5570' AND `inv`.`plan_inv_crm` != 0
WHERE `inv`.`product_sku_code` IS NOT NULL
  AND `inv`.`plan_inv_crm` != 0;

