select site_code,
       date_format(period_date, '%Y%m') as month,
       sum(qty),
       case
           when qty_type = 1 then '供应商承诺'
           when qty_type = 2 then '风险承诺'
           else '其他'
           end                          as qty_type
from sp_key_material_risk_commitment_data
where version_id = (select max(version_id) from sp_key_material_risk_commitment_data)
  and qty_type in ('1', '2')
  and qty > 0
group by site_code, month, qty_type
order by qty_type,month,site_code;



select * from sp_key_material_risk_commitment_data ;



select * from sop_r4_data_funnel_detail ;
select * from sop_r4_data_funnel_version;


select * from sop_r4_data_funnel_detail  where version_id =(
                select id from sop_r4_data_funnel_version order by version_week desc limit 1
) and date_type='SUPPLY_PROMISE' and date_format(data_date,'%Y%m')='202508'
order by data_date;



-- 配置表
select * from cfg_parameter where param_name = 'DATA_FUNNEL_FACTORY';

-- 计划开始日期
select * from atp_plan_start_date_r4_data_funnel ;

-- 其他供应
select * from compressor_inventory_r4_data_funnel ;


-- SAP库存
select a.site_id,
       date_format((select atp_plan_start_date from atp_plan_start_date_r4_data_funnel), '%Y%m') as date,
       sum(qty)
from sap_inventory_mst a
where exists(select 1
             from sop_two_devices_capacity_base b
             where a.material_no = b.material_code)
group by site_id, date;


-- 总装产能实际维护的产能
WITH cap_plan AS (SELECT physical_addr,
scm_line_body,
#                          whole_in_out,
#                          shipment_mode,
#                          product_type,
priority,
hour_capacity
  FROM (SELECT physical_addr,
   scm_line_body,
   whole_in_out,
   shipment_mode,
   product_type,
   priority,
   hour_capacity,
   ROW_NUMBER() OVER (
   PARTITION BY physical_addr, scm_line_body, whole_in_out, shipment_mode, product_type
   ORDER BY priority
   ) AS rn
FROM sop_final_assembly_line_capacity_plan) t
  WHERE rn = 1),
t1 as (SELECT cp.physical_addr,
   cp.scm_line_body,
#        cp.whole_in_out,
#        cp.shipment_mode,
#        cp.product_type,
   cp.priority,
   oc.period_date,
   cp.hour_capacity * oc.qty AS qty
FROM cap_plan cp
JOIN (SELECT line_body,
  factory_code,
  qty,
  period_date
   FROM sop_factory_output_cal
   WHERE module_code = 'SCM'
-- 日期180天
AND period_date BETWEEN curdate() AND DATE_ADD(curdate(), INTERVAL 179 DAY)) oc
  ON cp.scm_line_body = oc.line_body
ORDER BY cp.physical_addr,
cp.scm_line_body,
cp.priority,
oc.period_date)
select physical_addr, left(period_date, 6) as month, sum(qty)
from t1
group by physical_addr, month
order by physical_addr, month;



/*实际消耗的总装产能*/
select
#        supplyloc, -- 产能地点
#        restype,   -- 产能类型
#        res,
#        b.scm_line_body,
       b.physical_addr ,
       base,
       date_format(whenloaded, '%Y%m') as month,
       sum(dmdpegqty)  -- 实际耗用产能
from sp_tmp_mds_material_pegging a
         left join sop_final_assembly_line_capacity_plan b
                   on regexp_substr(a.res, '[^_]+', 1, 2) = b.scm_line_body
where capacity not in (100000000, 1000000000, 0)
  and restype = '总装产能'
group by physical_addr,month;



/* 两器产能TIDB表*/
with t1 as (select stdcih.base,
                   if(base = 'ZSJY' and physical_addr = '散件厂', 'KIT', 'CBU') as shipment_type,
                   physical_addr,
                   material_type,
                   unite_spec,
                   date_format(outlook_date, '%Y-%m')                           as month,
                   stdcii.outlook_date_qty                                      as capacity_qty
            from sop_two_devices_capacity_info_header stdcih
                     join sop_two_devices_capacity_info_item stdcii on stdcih.id = stdcii.header_id
            where outlook_date between curdate() and DATE_ADD(curdate(), INTERVAL 179 DAY)
              and material_type in ('CD', 'EP')
            order by physical_addr, shipment_type, material_type, unite_spec)
select physical_addr, month, sum(capacity_qty)
from t1
group by physical_addr, month
order by physical_addr, month;


/*实际消耗的两器产能*/
select b.physical_addr,
       base,
       date_format(whenloaded, '%Y%m') as month,
       sum(dmdpegqty)
from sp_tmp_mds_material_pegging a
         left join sop_two_devices_capacity_info_header b
                   on a.unitespec = concat(b.material_type, '_', b.unite_spec, '_', b.base)
where capacity not in (100000000, 1000000000, 0)
  and restype = '两器产能'
group by physical_addr, month
order by physical_addr, month;


select distinct abnormal_type_code from sp_turn_prodt_result t where t.pt_plan_version = '2025-08-18' ;

select distinct abnormal_type_code from sp_turn_prodt_process_detail where pt_plan_version='2025-08-18' and proto_code='Z4U20101020548' ;

select t.abnormal_type_code,t.* from sp_turn_prodt_result t where t.pt_plan_version = '2025-08-18'
                                                              and proto_code = 'S12010101486' order by relation_id LIMIT 3 ;


update sp_turn_prodt_result set abnormal_type_code = 'B-10' where pt_plan_version = '2025-08-18'
                                                              and proto_code = 'S12010101486' AND IFNULL(abnormal_type_code,'')<>''


select * from cfg_parameter where param_name='PUBLISH_ABNORMAL_TYPE';
SELECT TRIM(BOTH ';' FROM REPLACE(REPLACE('B-10;',CONCAT('B-10',';'),''), 'B-10', ''));
SELECT TRIM(BOTH ';' FROM REPLACE(REPLACE('B-10;Y',CONCAT('B-10',';'),''), 'B-10', ''));
SELECT TRIM(BOTH ';' FROM REPLACE(REPLACE('X;B-10;',CONCAT('B-10',';'),''), 'B-10', ''));
SELECT TRIM(BOTH ';' FROM REPLACE(REPLACE('X;B-10;Y',CONCAT('B-10',';'),''), 'B-10', ''));


select pw_start_date,pw_end_date,w_start_date,w_end_date ,T.* from kt_plan_time_master T ORDER by std_week desc;


select * from sop_data_funnel_detail ;
select * from sop_data_funnel_version;
