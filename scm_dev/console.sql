/*
select * from sop_rso_order_approve_detail;
select * from sop_rso_order_header;
select * from sop_rso_order_item_detail;
*/

-- 工厂配置
select distinct param_value from cfg_parameter WHERE param_name='RSO_ORDER_FACTORY_VALUE_SET' ;
-- 内外销配置
select * from cfg_parameter WHERE param_name='RSO_ORDER_BG_VALUE_SET';
-- 审批状态
select * from cfg_parameter WHERE param_name='RSO_STATUS';
-- OA创建模板
select * from cfg_parameter WHERE param_name='RSO_NEW_ORDER_PROCESS_TEMPLATE' and dimension1='输入的内外销';
-- OA变更模板
select * from cfg_parameter WHERE param_name='RSO_CHANGE_ORDER_PROCESS_TEMPLATE' and dimension1='输入的内外销';
-- 流程模板节点定义
select  * from cfg_parameter where param_name='RSO_ORDER_PROCESS_TEMPLATE_NODES_DEFINITION' and param_value='OA流程模板ID';
-- 物控人员节点配置
select * from cfg_parameter where param_name='RSO_ORDER_MCACCOUNT_PROCESS_NODES' and dimension1='OA流程模板ID' ;
-- 采购开发人员节点配置
select * from cfg_parameter where param_name='RSO_ORDER_PDACCOUNT_PROCESS_NODES' and dimension1='OA流程模板ID';






