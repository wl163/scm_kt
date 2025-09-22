-- 要货计划工作表 版本表
select * from version_master  order by creation_date desc;

-- 要货计划工作表（外销TCL/日历模式PW）
select * from dp_require_plan_simulation_obg_tcl_data_factory order by last_update_date desc;

-- 要货计划工作表（外销/日历模式PW）
select * from dp_require_plan_simulation_obg_fob_data_large order by last_update_date desc;

-- 内销品牌
select * from dp_require_plan_simulation_dom_data_large ;
-- 内销特种
select * from dp_require_plan_simulation_special_type_data ;

-- 要货计划模拟（外销 OBG DOM）分工厂数据表
select * from dp_require_plan_simulation_obg_dom_data_factory order by creation_date desc;


select * from dp_single_model_require_plan_report ;



-- 要货计划工作表（外销/日历模式PW）
select * from dp_require_plan_simulation_obg_fob_data_large order by last_update_date desc;

select w1_initial_require_plan_qty,w2_initial_require_plan_qty,w3_initial_require_plan_qty,w4_initial_require_plan_qty,
       w5_initial_require_plan_qty,w6_initial_require_plan_qty,w7_initial_require_plan_qty,w8_initial_require_plan_qty,
       w9_initial_require_plan_qty,w10_initial_require_plan_qty,w11_initial_require_plan_qty,w22_initial_require_plan_qty,
       t.*
from dp_require_plan_simulation_obg_fob_data_large t
where version_id = (select max(version_id) from dp_require_plan_simulation_obg_fob_data_large)
  and sales_model = 'Z2U20101004087'
order by last_update_date desc;

select * from dp_require_plan_summary  ; -- TU

-- 内销品牌

select last_update_date,w1_initial_require_plan_qty,w2_initial_require_plan_qty,w3_initial_require_plan_qty,w4_initial_require_plan_qty,
       w5_initial_require_plan_qty,w6_initial_require_plan_qty,w7_initial_require_plan_qty,w8_initial_require_plan_qty,
       w9_initial_require_plan_qty,w10_initial_require_plan_qty,w11_initial_require_plan_qty,w22_initial_require_plan_qty,
       t.*
from dp_require_plan_simulation_dom_data_large t
where version_id = (select max(version_id) from dp_require_plan_simulation_dom_data_large)
and whole_s_code  in ('S12010100251' ,'S12010101087','S12010101158')
order by last_update_date desc;


select * from dp_require_plan_base  where customer_model ='S12010105058';


-- 内销特种
select *
from dp_require_plan_simulation_special_type_data t
where version_id = (select max(version_id) from dp_require_plan_simulation_special_type_data)
  and data_type='Initial Require Plan Qty'
  and  whole_s_code = 'S12010100251'
order by last_update_date desc,code ;