select in_zcode,out_zcode,t.* from dp_sell_in_fcst_data t where ifnull(in_zcode,'')<>'' order by version_id desc;

select *
from oms_odm_sales_forecast_export_mst
where version_code =
      (select max(version_code) from oms_odm_sales_forecast_export_mst);



select physical_addr,scm_line_body,whole_in_out,shipment_mode,product_type,min(priority) as priority,hour_capacity
from sop_final_assembly_line_capacity_plan
where scm_line_body ='JJ-N2'
group by physical_addr,scm_line_body,whole_in_out,shipment_mode,product_type;



select line_body,qty,period_date
from sop_factory_output_cal where module_code='SCM';

select line_body, qty, period_date from sop_factory_output_cal where module_code = 'SCM' ;

with cap_plan as (select physical_addr,
                         scm_line_body,
                         whole_in_out,
                         shipment_mode,
                         product_type,
                         priority,
                         hour_capacity,
                         row_number() over (partition by physical_addr,scm_line_body,whole_in_out,shipment_mode,product_type
                             order by priority) as rn
                  from sop_final_assembly_line_capacity_plan)
select physical_addr,
       scm_line_body,
       whole_in_out,
       shipment_mode,
       product_type,
       priority,
       oc.period_date,
       cp.hour_capacity * oc.qty as qty
from cap_plan cp
         join (select line_body, qty, period_date from sop_factory_output_cal where module_code = 'SCM') oc
              on cp.scm_line_body = oc.line_body
where cp.rn = 1
order by physical_addr,
         scm_line_body,
         whole_in_out,
         shipment_mode,
         product_type,
         priority,
         oc.period_date;


