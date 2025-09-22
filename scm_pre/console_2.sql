SELECT t.original_parent_id, t.*
FROM sop_week_commitment_plan_detail_report t
WHERE version_no = '20250509KTOP01'
  AND data_type in (1,3)
  AND parent_id = 'FCST0000001'
order by original_parent_id;


SELECT t.original_parent_id, t.*
FROM sop_week_commitment_plan_detail_report t
WHERE version_no = '20250509KTOP01'
  AND data_type in (1,3)
  AND original_parent_id = 'AZLZ2400CU'
order by original_parent_id;








-- SCHEDSEQNUM
select schedseqnum,t.*
from sop_his_mid_mds_fcstorderstatus t where seqnum='12626565';

select t.*
from sop_his_mid_mds_fcstorder t where orgnum='AZLS24002S';

select b.demand_date,b.order_no,b.original_parent_id, t.orgnum,t.* from sop_his_mid_mds_fcstorder t
           left join sop_his_mid_mds_fcstorderstatus a on t.SEQNUM = a.SEQNUM
            left join sop_week_commitment_plan_detail_report b on t.orgnum=b.order_no
where 1 = 1
  and b.data_type=3
  and b.order_no='AZLS24002S';

select * from sp_turn_prodt_result t WHERE t.pt_plan_version = '2025-05-05发布版';

select open_qty, adjust_promise_date, first_promise_date
from sp_order_item_for_rtf t
where t.order_no = 'AZLS24002S';

select *
from sop_his_mid_mds_fcstorderstatus a
where exists(select *
             from SCPOMGR_MDS1_KT.SIM_INDDMDLINK b
             where a.SCHEDSEQNUM = b.SCHEDSEQNUM
               and b.SUPPLYTYPE = '12');

SELECT sum(turn_prodt_qty)
FROM sp_turn_prodt_result
WHERE pt_plan_version = '2025-05-05初版'
  and abnormal_type_code is NULL
  and demand_type = 1
  and proto_code = 'S12020100360'
  and whole_in_out = '整机';


select sum(turn_prodt_qty)
from sp_turn_prodt_cycle_deficiency_detail t
where t.proto_code = 'S12020100360'
  and t.whole_in_out = '整机';



SELECT t.finished_transport_method, t.*
from sp_order_offset_week_result_turn_prodt t
WHERE t.proto_type_code = 'S12010105011'
  and demand_type = 2
  and doc_no = 'CWHZ25APU4'
  and version_no = (SELECT max(version_no)
                    from sp_order_offset_week_result_turn_prodt);

select * from sp_supply_path t where
                                   t.path_dimension_code = 'ST01'
                                and t.box_body like '%#&%' ESCAPE '#';

SELECT * FROM sp_turn_prodt_result



