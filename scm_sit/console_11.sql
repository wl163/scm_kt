-- ODF承诺&排产
select tphm.pr_no,
       tpim.parent_po_line_no,
       tpim.po_line_no,
       tpim.cust_bom_code,
       psr.open_qty,
       tpim.request_delivery_date,
       sih.order_no,
       IFNULL(IFNULL(sih.adjust_promise_date, sih.first_promise_date), sih.promise_date) as promise_date,
       sih.open_qty                                                                      as '订单OPEN数量',
       wo.prodt_order_end_date                                                           as '排产时间',
       wo.qty,
       wo.prodt_inv_qty,
       wo.open_qty                                                                       as '排产数量'
from tof_pr_header_mst tphm
         left join tof_pr_item_mst tpim on tphm.pr_no = tpim.pr_no and level = 2
         left join pr_so_relationship psr on psr.pr_no = tphm.pr_no and psr.pr_line_no = tpim.po_line_no
         left join sp_order_header soh on tphm.pr_no = soh.po_no and tpim.parent_po_line_no = soh.po_line_no
         left join sp_order_item sih on soh.order_no = sih.order_no and tpim.po_line_no = sih.po_line_no
         left join sap_prodt_work_order_mst wo on wo.order_no = sih.order_no and wo.order_item_no = sih.order_line_no
where psr.open_qty > 0
  and tphm.enabled_offset = 'Y'
order by request_delivery_date desc ;


select * from sap_prodt_work_order_mst where order_no='TGZZ250005';
select * from sp_order_item where order_no='TGZZ250005';



SELECT * FROM dp_single_model_require_plan_report T  ;



select tf.cust_bom_code as sku,
       tf.promise_date  as bg_demand_time,
       sum(open_qty)    as qty
from (select tphm.pr_no,
             tpim.parent_po_line_no,
             tpim.po_line_no,
             tpim.cust_bom_code,
             psr.open_qty,
             tpim.request_delivery_date,
             sih.order_no,
             IFNULL(IFNULL(sih.adjust_promise_date, sih.first_promise_date), sih.promise_date) as promise_date,
             sih.open_qty                                                                      as '订单OPEN数量',
             wo.prodt_order_end_date                                                           as '排产时间',
             wo.qty,
             wo.prodt_inv_qty,
             wo.open_qty                                                                       as '排产数量'
      from tof_pr_header_mst tphm
               left join tof_pr_item_mst tpim on
          tphm.pr_no = tpim.pr_no
              and level = 2
               left join pr_so_relationship psr on
          psr.pr_no = tphm.pr_no
              and psr.pr_line_no = tpim.po_line_no
               left join sp_order_header soh on
          tphm.pr_no = soh.po_no
              and tpim.parent_po_line_no = soh.po_line_no
               left join sp_order_item sih on
          soh.order_no = sih.order_no
              and tpim.po_line_no = sih.po_line_no
               left join sap_prodt_work_order_mst wo on
          wo.order_no = sih.order_no
              and wo.order_item_no = sih.order_line_no
      where psr.open_qty > 0
        and tphm.enabled_offset = 'Y') tf
group by tf.cust_bom_code,
         tf.promise_date order by bg_demand_time desc ;