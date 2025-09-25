

select *
from sp_order_offset_week_set order by creation_date desc;

select * from dp_inner_po_integration;
select * from sp_inner_po_weekly_snapshot;
select * from sp_order_offset_week_po_organized where version_no =
                                                      (select max(version_no) from sp_order_offset_week_po_organized );

select * from dp_require_plan_weekly_snapshot_orig;

select distinct snapshot_date from sp_inner_po_weekly_snapshot order by snapshot_date desc ;
select * from dp_require_plan_output ;

select * from dp_po_so_open_cbu;
select  * from sp_order_offset_set_weekly_snapshot order by version_no desc;

SELECT param_value AS value,
               `desc` AS label,
               attr1 AS extValueOne
        FROM cfg_parameter
        WHERE org_id = 'KT'
          AND param_name='IMPORT_PUBILSH_PERMISSION'
          AND dimension1= 'ex_liujin.wei'
        ORDER BY dimension1 ASC  ;

/*冲减PO快照范围筛选*/

select *
from sp_inner_po_weekly_snapshot pws
where pws.enabled_offset = 'Y'
  AND level = 1
  and undeliver_qty <> 0
  /*且需求时间>=当周*/
  and demand_date >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);


/*要货快照PO表范围筛选*/
select * from dp_po_so_open_cbu t
where t.delivery_qty <> 0
and etd_demand_date >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);




