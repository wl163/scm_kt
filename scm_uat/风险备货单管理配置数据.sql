select * from cfg_parameter where param_name in ('RSO_ORDER_FACTORY_VALUE_SET','RSO_ORDER_BG_VALUE_SET','RSO_STATUS','RSO_NEW_ORDER_PROCESS_TEMPLATE',
                                                 'RSO_CHANGE_ORDER_PROCESS_TEMPLATE','RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION',
                                                'RSO_ORDER_MCACCOUNT_PROCESS_NODES','RSO_ORDER_PDACCOUNT_PROCESS_NODES','RISK_STOCKING_SAP_FACTORY_MST')
                            order by param_name,param_value,dimension1
