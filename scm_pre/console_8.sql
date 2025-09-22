/*新增列表的数据获取*/
WITH data1 AS (SELECT d.factory_no, d.purchase_group, a.purchase_group_desc, 'SAP工厂主数据' AS source
               FROM sap_purchase_group_mst a
                        JOIN (SELECT DISTINCT c.factory_no, c.purchase_group
                              FROM sap_factory_material_mst c) d
                             ON a.purchase_group = d.purchase_group
               WHERE EXISTS (SELECT 1
                             FROM cfg_parameter cfg
                             WHERE param_name = 'RISK_STOCKING_SAP_FACTORY_MST'
                               AND d.factory_no = cfg.param_value)),
     data2 AS (SELECT DISTINCT dimension1 AS factory_no,
                               dimension2 AS purchase_group,
                               dimension3 AS purchase_group_desc,
                               'CFG配置'  AS source
               FROM cfg_parameter cfg
               WHERE param_name = 'PURCHASE_GROUP_CUSTOMIZE'
                 AND attr1 = 'Y'
                 AND NOT EXISTS (SELECT 1
                                 FROM data1
                                 WHERE cfg.dimension1 = data1.factory_no
                                   AND cfg.dimension2 = data1.purchase_group)
               )
SELECT * FROM data1
UNION
SELECT * FROM data2
         order by factory_no ,purchase_group ;



select * from  sap_purchase_group_mst;
SELECT * FROM cfg_parameter cfg
                             WHERE param_name = 'RISK_STOCKING_SAP_FACTORY_MST'


delete  from  cfg_parameter WHERE param_name = 'RISK_STOCKING_SAP_FACTORY_MST'


select  * from cfg_parameter where param_name in ('RSO_ORDER_FACTORY_VALUE_SET','RSO_ORDER_BG_VALUE_SET','RSO_STATUS','RSO_NEW_ORDER_PROCESS_TEMPLATE',
                                                 'RSO_CHANGE_ORDER_PROCESS_TEMPLATE','RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION',
                                                'RSO_ORDER_MCACCOUNT_PROCESS_NODES','RSO_ORDER_PDACCOUNT_PROCESS_NODES') order by param_name;
