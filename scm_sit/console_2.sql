update dp_require_plan_base as pb
        LEFT JOIN
        (

            /*获取内销哪些数据需要更新*/
            SELECT
            pb.id,
            inv.rdc1Qty,
            inv.rdc2Qty,
            inv.cdcQty
            FROM
            (
                /*汇总期初库存数据*/
                SELECT
                psm.brand_group,
                psm.is_special,
                psm.is_bulk,
                psm.customer_model,
                psm.require_addr,
                psm.require_goods_mode,
                psm.require_goods_cust_code,
                pp.plan_start_time,
                SUM(inv.rdc_inv_total) as rdc1Qty,
                sum(inv.plat_inv_total) as rdc2Qty,
                sum(inv.cdc_inv_total) as cdcQty
                /*期初库存日期的前一天*/
                FROM
                (
                select rdc_inv_total,plat_inv_total,cdc_inv_total,whole_code,logic_whse_code,inv_last_update_time,sales_org_code
                from v_whole_machine_inv_pre
                where whole_code is not null
                and logic_whse_code is not null
                ) as inv
                LEFT JOIN dp_require_plan_supply_map as psm
                on psm.supply_model=inv.whole_code
                    and psm.supply_addr=inv.logic_whse_code
            	    and psm.demand_addr=inv.sales_org_code
                    and psm.demand_mode='DOM'
                    and psm.brand_group = '自有品牌'
                    and psm.is_special = 'N'
                    and psm.is_bulk = 'N'
                    and psm.appointed_factory = ''
                LEFT JOIN dp_require_plan_param as pp
                on psm.customer_model=pp.customer_model
                    and psm.require_addr=pp.require_addr
                    and psm.require_goods_mode=pp.require_goods_mode
                    and psm.require_goods_cust_code=pp.require_goods_cust_code
                    and psm.brand_group = pp.brand_group
                    and psm.is_special = pp.is_special
                WHERE psm.id is not null
                    and inv.inv_last_update_time = DATE_SUB(pp.begining_inv_date, INTERVAL 1 DAY)
                GROUP BY
                psm.brand_group,
                psm.is_special,
                psm.is_bulk,
                psm.customer_model,
                psm.require_addr,
                psm.require_goods_mode,
                psm.require_goods_cust_code,
                pp.plan_start_time
            ) as inv
            LEFT JOIN dp_require_plan_base as pb
            on inv.customer_model=pb.customer_model
            and inv.require_addr=pb.require_addr
            and inv.require_goods_mode=pb.require_goods_mode
            and inv.require_goods_cust_code=pb.require_goods_cust_code
            and pb.bg_demand_time=inv.plan_start_time
            and inv.is_special = pb.is_special
            and inv.brand_group = pb.brand_group
            and inv.is_bulk = pb.is_bulk
            WHERE pb.customer_model is not null
        ) as t on t.id=pb.id
        set pb.rdc1_inv_total=t.rdc1Qty,
        pb.rdc2_inv_total=t.rdc2Qty,
        pb.cdc_inv_total = t.cdcQty,
        pb.last_update_date=NOW()
        WHERE t.id is not null
;


SELECT * FROM dp_require_plan_param_factory;
-- actual_inv_qty,available_inv_qty,
select T.*
from dp_require_plan_base T
where brand_group = 'ODM'
  and is_special = 'N'
  and customer_model = 'S12010101420'
  and require_addr = 'CN'
  and require_goods_mode = 'FOB'
  and require_goods_cust_code = 'ZT10015592';


SELECT * FROM dp_require_plan_summary;

SELECT *
FROM dp_require_plan_simulation_special_type_data
where version_id = (select max(version_id) from dp_require_plan_simulation_special_type_data)
  and whole_s_code = 'S12010101420' ;


select *
FROM dp_require_plan_simulation_special_type_data
where version_id = (select max(version_id) from dp_require_plan_simulation_special_type_data)
and require_goods_cust_code  in ('0001006030','0001025934','0001032206','0001032835','0001033279','0001037793','0001038329');


delete
FROM dp_require_plan_simulation_special_type_data
where version_id = (select max(version_id) from dp_require_plan_simulation_special_type_data)
and require_goods_cust_code  in ('ZT10017993');

select distinct require_goods_cust_code
FROM dp_require_plan_simulation_special_type_data
where version_id = (select max(version_id) from dp_require_plan_simulation_special_type_data);


select *
from dp_require_plan_simulation_obg_dom_data_factory t
where t.version_id = (select max(version_id) from dp_require_plan_simulation_obg_dom_data_factory)
  and t.sales_model = 'Z2U20101006685';


select *
from dp_require_plan_simulation_obg_fob_data_large t
where t.sales_model = 'Z2U20101006685'
and version_id = '1924767879719249114'
and rbc='ZA02';

select * from  dp_require_plan_base where ifnull(plan_version,'')<>''  order by plan_version desc  ;

select * from scm_sit_powerjob.workflow_lock;
delete
from dp_require_plan_simulation_obg_fob_data_large t
where version_id = '1924767879719249114' and sales_model in
                                             (
                                              'Z2U20102006005',
                                              'Z2U20103010213',
                                              'Z2U20301000383',
                                              'Z4U20101043436',
                                              'Z2U20101008172',
                                              'Z2U20101006888',
                                              'Z2U20103005977',
                                              'Z2U20103009142',
                                              'Z4U20101015266',
                                              'Z4U20101012985',
                                              'Z2U20101008521',
                                              'Z2U20101008506',
                                              'Z2U20101008008',
                                              'Z2U20103009115',
                                              'Z4U20102039160',
                                              'Z2U20101007948',
                                              'Z2U20101006685',
                                              'Z2U20102009435',
                                              'Z2U20302000938',
                                              'Z2U20302000622',
                                              'Z2U20607000278',
                                              'Z2U20101007868',
                                              'Z4U20102039520',
                                              'Z2U20101009936',
                                              'Z2U20103009163',
                                              'Z2U20607000198',
                                              'Z2U20101009138',
                                              'Z4U20101043717',
                                              'Z2U20607000141',
                                              'Z2U20302000620',
                                              'Z4U20101022804',
                                              'Z2U20103006083',
                                              'Z2U20101008513',
                                              'Z4U20101013054',
                                              'Z2U20101010789',
                                              'Z2U20102009397',
                                              'Z2U20101008114',
                                              'Z2U20101007173',
                                              'Z4U20102021193',
                                              'Z2U20101006636',
                                              'Z2U20101008505',
                                              'Z4U20101031686',
                                              'Z2U20102006538',
                                              'Z4U20101009031',
                                              'Z4U20101013055',
                                              'Z4U20101013046',
                                              'Z2U20103007701',
                                              'Z2U20102006128',
                                              'Z2U20102009395',
                                              'Z2U20607000142',
                                              'Z4U20102015749',
                                              'Z2U20101008152',
                                              'Z2U20101011569',
                                              'Z2U20607000241',
                                              'Z2U20607000263',
                                              'Z2U20301000367',
                                              'Z4U20101031685',
                                              'Z2U20101008146',
                                              'Z2U20102009447',
                                              'Z2U20101003931',
                                              'Z2U20101008143',
                                              'Z4U20101016678',
                                              'Z2U20101007174',
                                              'Z4U20101033321',
                                              'Z2U20302000599',
                                              'Z2U20302000934',
                                              'Z2U20102009430',
                                              'Z2U20101008519',
                                              'Z4U20103038780',
                                              'Z2U20102010577',
                                              'Z4U20101021683',
                                              'Z2U20101008091',
                                              'Z2U20101007173',
                                              'Z4U20101020588',
                                              'Z4U20101042775',
                                              'Z2U20101008321',
                                              'Z2U20101007174',
                                              'Z2U20101008520',
                                              'Z2U20101009171',
                                              'Z2U20101006687',
                                              'Z2U20102005764',
                                              'Z2U20607000257',
                                              'Z2U20607000266'
                                                 );


select * from scm_market_org where rbc_name='中东分公司';
select * from cfg_parameter where param_name = 'BASE_PLANT_RELATIONSHIP';


