select
    t.inner_po_no,
    t.inner_po_item_no,
    t.inner_po_item_no_detail,
    t.brand_group
from sp_inner_po_weekly_snapshot t
left join dp_require_plan_summary drps on t.brand_group = drps.brand_group and t.is_special = drps.is_special
                                              and t.require_goods_mode = drps.require_goods_mode
where t.version_no = (select version_no from sp_inner_po_weekly_snapshot order by version_no desc limit 1)
and t.level = 1
and t.enabled_offset = 'Y' ;



SELECT distinct creation_date FROM dp_po_mid_cbu order by creation_date desc;
SELECT distinct creation_date FROM dp_po_mid_cbu order by creation_date desc limit 1,1;

SELECT distinct creation_date FROM dp_po_closed_cbu order by creation_date desc;



select actual_delivery_date,week_delivery_qty,is_monday_delivery,T.* from dp_po_closed_cbu T
                                                                     order by creation_date desc ;

# 要货计划参数总表
select * from dp_require_plan_summary ;
# 内部PO集成表
select * from dp_inner_po_integration ;
# 内部PO周度冲减快照表
select * from sp_inner_po_weekly_snapshot ;


# 内部PO周度冲减快照表
select * from sp_inner_po_weekly_snapshot where version_no = (
    select version_no from sp_inner_po_weekly_snapshot WHERE version_no REGEXP '^[0-9]' order by version_no desc limit 1
    )  and level=1 and enabled_offset='Y' and inner_po_no='MO241093210'
    order by inner_po_no,inner_po_item_no,inner_po_item_no_detail;

-- mid 表 上一版本
select * from dp_po_mid_cbu where creation_date = (
    '2025-08-11 00:00:31'
    )  and inner_po_no='MO241093210';
-- mid 表 当前版本
select * from dp_po_mid_cbu where creation_date = (
    SELECT creation_date FROM dp_po_mid_cbu ORDER BY  creation_date DESC LIMIT 1
    )  and inner_po_no='MO241093210';

-- close 表 上一个版本
select actual_delivery_date,week_delivery_qty,is_monday_delivery,T.* from dp_po_closed_cbu t where actual_delivery_date = (
    SELECT distinct actual_delivery_date FROM dp_po_closed_cbu order by creation_date desc limit 1,1
    )  and whole_code = 'Z2U20101009744' ;

-- close 表 当前版本
select actual_delivery_date,week_delivery_qty,is_monday_delivery,T.* from dp_po_closed_cbu t where actual_delivery_date = (
    SELECT distinct actual_delivery_date FROM dp_po_closed_cbu order by creation_date desc limit 1
    )  and whole_code = 'Z2U20101009744' ;

select distinct actual_delivery_date from dp_po_closed_cbu order by actual_delivery_date desc;


select * from dp_require_plan_demand_map;


select brand_group,whole_code,require_addr,require_goods_cust_code,is_special,is_bulk,bulk_require_mode,
       require_goods_mode,actual_delivery_date,
       (week_delivery_qty)
from dp_po_mid_cbu where creation_date = (
        SELECT creation_date FROM dp_po_mid_cbu ORDER BY creation_date DESC LIMIT 1 )
    and brand_group = 'ODM' and whole_code = 'Z2U20101009744' and require_addr='HK' and require_goods_cust_code='DUM_CUST'
    and is_special='N' and is_bulk='N' AND bulk_require_mode = '' AND require_goods_mode = 'FOB'
GROUP BY brand_group,whole_code,require_addr,require_goods_cust_code,is_special,is_bulk,bulk_require_mode,require_goods_mode,actual_delivery_date


select actual_delivery_date,week_delivery_qty,is_monday_delivery,T.* from dp_po_closed_cbu t where creation_date = (
    '2025-08-14 10:26:40'
    )  and whole_code = 'Z2U20102009455';


/*select * from dp_require_plan_summary ps inner join

(select * from sp_inner_po_weekly_snapshot where version_no = (
    select version_no from sp_inner_po_weekly_snapshot WHERE version_no REGEXP '^[0-9]'  order by version_no desc limit 1
    )  and proto_type_code = 'Z2U20102009455' )t  on ps.brand_group = t.brand_group and ps.is_special = t.is_special
                                                         and ps.require_goods_mode = t.require_goods_mode and ps.require_addr = t.country ;*/



select brand_group,
       is_special,
       require_goods_mode,
       ( case
            when ps.require_addr <> 'NOT CN' then ps.require_addr
            when ps.bg_code = 'ALL' then ''
            when ps.bg_code <> 'ALL' then org.country_code
            else '' end ) as require_addr
from dp_require_plan_summary ps
         left join scm_market_org org
                   on ps.org_id = 'KT' AND ps.bg_code = org.bg_code and ps.brand_group = org.brand_name;


select max(bg_demand_time) from dp_require_plan_base pb where pb.history_flag = 1;


select osd.brand_group,
       osd.whole_code,
       osd.require_goods_cust_code,
       osd.is_special,
       osd.require_addr,
       osd.require_goods_mode,
       osd.is_bulk,
       osd.actual_delivery_date,
       map.demand_cust_code,
       osd.week_delivery_qty
from dp_po_closed_cbu osd
         left join dp_require_plan_demand_map map
                   on map.brand_group = osd.brand_group
                        AND map.is_special=osd.is_special
                        AND map.is_bulk=osd.is_bulk
                        AND map.appointed_factory=''
                        AND map.demand_model=osd.whole_code
                        AND map.demand_cust_code=IF((osd.require_addr='CN' AND osd.brand_group='自有品牌' AND osd.is_special='Y')
                                                            OR (osd.require_addr='CN' AND osd.brand_group='ODM'),
                                                        osd.require_goods_cust_code,
                                                        'DUM_CUST')
                        AND map.demand_addr=osd.require_addr
                        AND map.demand_mode=osd.require_goods_mode ;


select distinct actual_delivery_date from dp_po_closed_cbu order by actual_delivery_date desc ;


select distinct creation_date from dp_po_closed_cbu order by creation_date desc ;

select actual_delivery_date,is_monday_delivery,creation_date from dp_po_closed_cbu
                                        where actual_delivery_date = (select max(actual_delivery_date) from dp_po_closed_cbu)
order by creation_date desc;


select actual_delivery_date,is_monday_delivery,creation_date from dp_po_closed_cbu
                                        where creation_date =
                                              (select distinct creation_date from dp_po_closed_cbu order by creation_date desc limit 1,1)
order by creation_date desc;





select etd_supply_flip_instock_time,t.* from v_rtf_detail_pre t where t.order_no = 'CWHZ25025C';


SELECT  oh.order_no,adjust_promise_date,first_promise_date,promise_date
from sop_rtf_detail_upload t left join sp_order_header oh on t.order_no = oh.order_no
where oh.order_no='CWHZ25025C';



select  * from scm_market_org ;


/*
 bu_code              varchar(60)  null comment 'BU编码',
    bu_name              varchar(225) null comment 'BU名称',
    bg_code              varchar(64)  null comment '营销中心编码（L1）',
    bg_name              varchar(64)  null comment '营销中心名称（L1）',
    brand_code           varchar(64)  null comment '品牌编码',
    brand_name           varchar(64)  null comment '品牌名称',
    rbc_code             varchar(64)  null comment '销售中心/大区编码（L2）',
    rbc_name             varchar(64)  null comment '销售中心/大区名称（L2）',
    region_code          varchar(64)  null comment '业务单元/战区编码（L3）',
    region_name          varchar(64)  null comment '业务单元/战区名称（L3）',
    country_code         varchar(64)  null comment '国家编码（L4）',
    country_name_cn      varchar(64)  null comment '国家中文名称（L4）',
    country_name_en      varchar(64)  null comment '国家英文名称（L4）',

*/



update sp_order_header set adjust_promise_date = '2025-03-23' where order_no='CWHZ25025C';



select bom_code,bom_factory,is_oem, t.* from mdm_item_master_mst t ;


select * from scm_market_org where country_name_cn='文莱';


SELECT bom_status,bom_life_cycle  from sp_turn_prodt_result ;
select bom_status,bom_life_cycle from sp_turn_prodt_effective_demand_config




select * from dp_require_plan_simulation_obg_dom_data_factory order by creation_date desc ;









