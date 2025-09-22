-- "供应商承诺和风险承诺": """

with tt as (
         select material_code,
         supplier_code,
         site_code,
         date_format(period_date, '%Y-%m') as month,
         period_date,
         qty,
         case when qty_type = 1 then '供应商承诺'
           when qty_type = 2 then '风险承诺'
           else '其他'
        end                           as qty_type
from sp_key_material_risk_commitment_data
where version_id = (select max(version_id) from sp_key_material_risk_commitment_data)
  and qty_type in ('1', '2')
  and qty > 0
order by material_code, supplier_code, site_code, period_date, qty_type
    )

select * from tt where tt.qty_type='供应商承诺'


-- "供应商承诺和风险承诺"
select site_code,
       date_format(period_date, '%Y%m') as month,
       qty,
       case
           when qty_type = 1 then '供应商承诺'
           when qty_type = 2 then '风险承诺'
           else '其他'
           end                          as qty_type
from sp_key_material_risk_commitment_data
where version_id = (select max(version_id) from sp_key_material_risk_commitment_data)
  and qty_type in ('1', '2')
  and qty > 0
order by site_code, month, qty_type;







SELECT
    SITE_ID,        --工厂
    SUM(OPEN_QTY) --未清洗QTY数据   (IN表 OPEN_QTY)
FROM
(
    SELECT SITE_ID, SUM(QTY) AS OPEN_QTY FROM  sap_inventory_mst
    LEFT JOIN ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY SITE_ID
    UNION
    SELECT SITE_CODE,SUM(NET_TRANSIT_QTY) AS OPEN_QTY FROM  srm_delivery_note_mst
    LEFT JOIN MID_MDS_ITEM ON MATERIAL_CODE = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY SITE_CODE
    UNION
    SELECT FACTORY_NO,SUM(UNCLEAR_QTY) AS OPEN_QTY FROM  sap_supply_sto_mst
    LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY FACTORY_NO
    UNION
    SELECT FACTORY_NO,SUM(uninstock_qty) AS OPEN_QTY FROM  sap_prod_mst
    LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY FACTORY_NO
)
GROUP BY SITE_ID;


 SELECT uninstock_qty AS OPEN_QTY FROM  sap_prod_mst ;



SELECT FACTORY_NO,UNCLEAR_QTY AS OPEN_QTY,date_format(delivery_date,'%Y%m') as delivery_date  FROM  sap_supply_sto_mst
LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY FACTORY_NO


select FACTORY_NO,uninstock_qty AS OPEN_QTY,demand_date from rp_sap_material_list_bom_info


select lower('CAP_USAGE')

select * from cfg_parameter where param_name = 'DATA_FUNNEL_FACTORY'



