-- "供应商承诺和风险承诺": """

select material_code,
       supplier_code,
       site_code,
       date_format(period_date, '%Y-%m') as month,
       period_date,
       qty,
       case
           when qty_type = 1 then '供应商承诺'
           when qty_type = 2 then '风险承诺'
           else '其他'
        end                           as qty_type
from sp_key_material_risk_commitment_data
where version_id = (select max(version_id) from sp_key_material_risk_commitment_data)
  and qty_type in ('1', '2')
  and qty > 0
order by material_code, supplier_code, site_code, period_date, qty_type






