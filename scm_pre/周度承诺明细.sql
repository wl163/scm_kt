select demand_code,parent_id, original_parent_id,
       whole_in_out,data_type,qty,lt_qty
from sop_week_commitment_plan_detail_report_wide t
where t.version_no = '20250523KTOP01'
  and parent_id = 'AZLZ2400D0'
  and data_type in (1, 3);

select demand_code,parent_id, original_parent_id,
       whole_in_out,data_type,qty,lt_qty,t.schedseqnum
from sop_week_commitment_plan_detail_report t
where t.version_no = '20250522KTOP01'
  and parent_id = 'FCST0000005'
  and data_type in (1, 3);


# 查看供应
select a.parent_id, a.original_parent_id, a.original_demand_code, a.demand_code, c.scheddate, c.schedqty
from sop_week_commitment_plan_detail_report a
         left join sop_his_mid_mds_fcstorder b
                   on a.original_parent_id = b.orgnum
         left join sop_his_mid_mds_fcstorderstatus c on b.seqnum = c.seqnum
where a.version_no = '20250523KTOP01'
  and a.parent_id = 'AZLS25000O'
  and a.data_type = 3
  and a.is_parent = 'Y';

# 是否为LT满足数量
select *
from sop_week_commitment_plan_detail_report a
where a.data_type = 1
  and a.parent_id='AZLZ24002Y'
  and exists(select 1
             from engine_mid_mds_mrp b
             where a.schedseqnum = b.schedseqnum
               and b.supplyitem != 'DMY-ITEM'
               and b.supplytype = '12');


# 查看ODF需求
select order_no                                        as order_no,
       ifnull(adjust_promise_date, first_promise_date) as demand_date,
       open_qty
from sp_order_header_for_rtf t
where t.order_no = 'OZSZ2401IK'
union all
select concat_ws('_', order_no, order_line_no)         as order_no,
       ifnull(adjust_promise_date, first_promise_date) as demand_date,
       open_qty
from sp_order_item_for_rtf t
where t.order_no = 'OZSZ2401IK';

# FCST需求
select *
from sp_turn_prodt_result_for_rtf
where relation_id = '';


# SELECT *FROM sop_his_mid_mds_fcstorder T WHERE T.orgnum='OZSZ2401IK'

select *
from sop_week_commitment_plan_detail_report_wide t
where t.version_no = '20250529KTOP01'
  and parent_id = 'OZSZ2401IK'
  and data_type in (3, 1)
order by demand_code;


select  DATE_ADD(now(), INTERVAL 26 WEEK) AS delivery_date;


SELECT
    (SELECT COALESCE(SUM(qty), 0)
     FROM sop_week_commitment_plan_detail_report
     WHERE version_no='20250529KTOP01' AND data_type=3 AND demand_type='FCST')
    -
    (SELECT COALESCE(SUM(qty) + SUM(lt_qty), 0)
     FROM sop_week_commitment_plan_detail_report
     WHERE version_no='20250529KTOP01' AND data_type=1 AND demand_type='FCST')
AS difference;


