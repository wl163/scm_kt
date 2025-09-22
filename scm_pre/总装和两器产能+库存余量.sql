-- 总装产能
WITH cap_plan AS (SELECT physical_addr,
                         scm_line_body,
                         whole_in_out,
                         shipment_mode,
                         product_type,
                         priority,
                         hour_capacity
                  FROM (SELECT physical_addr,
                               base,
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
                  WHERE rn = 1)
SELECT cp.physical_addr,
       cp.scm_line_body,
       cp.whole_in_out,
       cp.shipment_mode,
       cp.product_type,
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
         cp.whole_in_out,
         cp.shipment_mode,
         cp.product_type,
         cp.priority,
         oc.period_date;

select distinct base,physical_addr from sop_final_assembly_line_capacity_plan t;
select base,physical_addr,t.* from sop_final_assembly_line_capacity_plan t;
select * from cfg_parameter where param_name = 'BASE_PLANT_RELATIONSHIP' ;

#     "两器产能TIDB表":
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



-- 库存数量  采用方案二；方案一关联不到数据
select a.site_id,sum(qty)
from sap_inventory_mst a
where exists(select 1
             from sop_two_devices_capacity_base b
             where a.material_no = b.material_code)
group by site_id ;

-- 库存数量 方案一，关联配置表，取出两器对应物料组<attr1>,再物料组关联sap 工厂物料主数据表的<material_plan_user>,对应<material_no>
/*select a.site_id, sum(qty)
from sap_inventory_mst a
join
     (select distinct a.material_no
      from sap_factory_material_mst a
               join (select *
                     from cfg_parameter
                     where param_name = 'SAP_ATP_ITEM_MATERIAL_GROUP'
                       and dimension1 = 'EVAPORATOR_AND_CONDENSER') b
                    on a.material_plan_user = attr1) c
on a.material_no = c.material_no
group by site_id;*/


-- 库存余量
select site_id,material_no,qty from sap_inventory_mst;

/*模具产能*/
    -- '模具平均日产能维护'表
SELECT * FROM sop_mould_average_capacity_daily;

with mould_data as (select a.base,
                           a.mould,
                           a.mould_level_one,
                           b.outlook_date,
                           date_format(b.outlook_date, '%Y%m')                                                                                   as month,
                           (a.number_of_kits * a.avg_mould_day_capacity)                                                                         as qty,
                           row_number() over (partition by a.base,a.mould,b.outlook_date order by (a.number_of_kits * a.avg_mould_day_capacity)) as rn
                    from sop_mould_average_capacity_daily a
                             /*关联模具产能日历维护*/
                             LEFT JOIN sop_mould_capacity_calendar b
                                       on a.base = b.base
                                              and a.mould_level_one = b.mould_level_one
                    WHERE CURDATE() BETWEEN effective_date AND ineffective_date
                      and b.is_working = 'Y')
select base, mould, month, sum(qty)
from mould_data
where rn = 1
group by base, mould, month
order by base, mould, month ;




-- "供应商承诺和风险承诺":
select site_code,
       date_format(period_date, '%Y-%m') as month,
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
order by material_code, supplier_code, site_code, period_date, qty_type;


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



select b.physical_addr,
       b.base,
       date_format(a.whenloaded, '%Y%m') as month,
       sum(a.dmdpegqty)
from sp_tmp_mds_material_pegging a
         left join sop_two_devices_capacity_info_header b
                   on a.unitespec = concat(b.material_type, '_', b.unite_spec, '_', b.base)
where capacity not in (100000000, 1000000000, 0)
  and restype = '两器产能'
group by physical_addr, month
order by physical_addr, month;


/*实际消耗的模具产能*/
SELECT supplyloc,                                -- 产能地点
       date_format(whenloaded, '%Y%m') as month, -- 产能时间
       dmdpegqty                                 -- 产能数量
FROM sp_tmp_mds_material_pegging T
where capacity not in (100000000, 1000000000, 0)
  and restype = '模具产能'
group by supplyloc, month
order by supplyloc, month;



SELECT unitespec,regexp_substr(unitespec, '[^_]+', 1, 1),resname, T.* FROM sp_tmp_mds_material_pegging T;
SELECT distinct physical_addr,unite_spec, base,concat(unite_spec,'_',base) FROM sop_two_devices_capacity_info_header T;

SELECT distinct  base FROM sop_two_devices_capacity_info_header T;



select distinct capacity
from sp_tmp_mds_material_pegging;

select REGEXP_SUBSTR('FACTORYCAPACITY_WH-XW1_WHJY', '[^_]+', 1, 2) ;
/*SELECT
SEQNUM,
SUPPLYSEQNUM ,
SUPPLYLOC, --产能地点
RESTYPE, --产能类型
RES, --资源
WHENLOADED,-- 产能时间
DMDPEGQTY --产能数量
FROM TMP_MDS_MATERIAL_PEGGING
WHERE CAPACITY NOT IN (99999999,999999999,0) AND  RESTYPE = '模具产能' AND seqNUM = '1678914'
*/
