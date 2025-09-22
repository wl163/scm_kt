select cdc_inv_total,rdc1_inv_total,rdc2_inv_total,cur_rdc1_inv_total,cur_rdc2_inv_total,cur_cdc_inv_total,actual_inv_qty,available_inv_qty,
       t.*
       from dp_require_plan_base t
       where cur_rdc1_inv_total is not null;




-- cal_mode
select * from dp_require_plan_param;
select * from kt_plan_time_master;




select inner_po_qty,T.* from dp_require_plan_base_factory T  where inner_po_qty != 0;

SELECT * FROM dp_require_plan_base_factory_plan_bom;
select * from cfg_parameter where param_name ='SECOND_ASSIGN_EMAIL';

INSERT INTO cfg_parameter
(belong_domain, param_name, dimension1, dimension2, dimension3, param_value, data_type, `desc`,
 attr1, attr2, attr3, attr4, attr5, attr6, dynamic_flag, display_flag, created_by, creation_date, last_updated_by,
 last_update_date, created_account, last_updated_account, org_id, delete_flag)
VALUES ('KTSCM_TURN_PROUCT', 'SECOND_ASSIGN_EMAIL', 'TO', 'TO', 'CC',
        'kt_xiajing2@tcl.com;kt_liulufang@tcl.com;zuyin.zhuo@tcl.com;xinyi5.xu@tcl.com',
        'STRING',
        '二次转产后发送邮件的配置 用; 进行分割，dimension1 -> attr1 ,dimension2 -> attr2 ,配置发送人（TO），和抄送人（CC）',
        'kaibin3.zhang@tcl.com;xiaoyu2.lan@tcl.com;yuying.lei@tcl.com',
        'hongmei.lin@tcl.com;wenya1.huang@tcl.com;aiwen2.chen@tcl.com;zhixin.lai@tcl.com',
        '', null, null, null, null, null, 1, now(), 1, now(), 'admin', 'admin', 'KT', 0);


select sku,
       demand_date,
       qty
from sop_rtf_detail_upload t
where t.rtf_version_no = (SELECT MAX(rtf_version_no)
                          FROM sop_rtf_detail_upload
                          WHERE org_id = 'KT'
                            AND is_parent = 'Y'
                            AND INSTR(rtf_version_no, 'SYSTEM') > 1)
  and t.org_id = 'KT'
  AND t.is_parent = 'N';


select bom_factory,bom_life_cycle
from sp_turn_prodt_result where pt_plan_version = (select max(pt_plan_version) from sp_turn_prodt_result)
and ifnull(bom_life_cycle,'')<>'' or ifnull(bom_factory,'')<>''  ;


select bom_factory,bom_life_cycle
from sp_turn_prodt_result where pt_plan_version = '2025-07-28'
and ifnull(bom_life_cycle,'')<>'' or ifnull(bom_factory,'')<>''  ;
