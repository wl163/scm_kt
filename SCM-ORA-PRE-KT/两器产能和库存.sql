--  "总装产能":
select t.*,
       case
           when rescapture_2 <> 'COMMON' then
               case
                   when rescapture_1 = 'FACTORYCAPACITY' then IMFALCP.PHYSICAL_ADDR
                   when rescapture_1 = 'EVANCONCAPACITY' then IMTDCIH.PHYSICAL_ADDR
                   else supplyloc end
           else rescapture_2 end as base
from (
         select SUPPLYLOC,
                RES,
                regexp_substr(RES, '[^_]+', 1, 1) as rescapture_1,
                regexp_substr(RES, '[^_]+', 1, 2) as rescapture_2,
                regexp_substr(RES, '[^_]+', 1, 3) as rescapture_3,
                WHENLOADED,
                to_char(WHENLOADED, 'YYYYMM')     as month,
                CAPACITYAVAILDATE,
                CAPACITYPEGQTY,
                SIMULATION_NAME
         from SCPOMGR_MDS1_KT.SIM_RESLOADINDDMDLINK SR
         where sr.SIMULATION_NAME = 'MDS_KT'
     ) t
         left join IN_MDS_FINAL_ASSEMBLY_LINE_CAPACITY_PLAN IMFALCP
                   on t.SUPPLYLOC = IMFALCP.BASE and t.rescapture_2 = IMFALCP.SCM_LINE_BODY
         left join IN_MDS_TWO_DEVICES_CAPACITY_INFO_HEADER IMTDCIH ON IMTDCIH.BASE = SUPPLYLOC
where rescapture_2 <> 'COMMON'
  and not exists(
        select 1
        from SCPOMGR_MDS1_KT.calpattern calp
                 inner join SCPOMGR_MDS1_KT.calattribute calattr
                            on calp.cal = calattr.cal and calp.patternseqnum = calattr.patternseqnum
        where calp.cal like '%MDS_KT%'
          and calattr.value = 999999999
          and calp.CAL = t.RES
          and t.CAPACITYAVAILDATE between STARTDATE and ENDDATE
    ) ;

select * from IN_MDS_FINAL_ASSEMBLY_LINE_CAPACITY_PLAN;
select * from IN_MDS_TWO_DEVICES_CAPACITY_INFO_HEADER;
select * from SCPOMGR_MDS1_KT.calattribute;
--     "两器产能":
select stdcih.base,
       case when base = 'ZSJY' and physical_addr = '散件厂' then 'KIT' else 'CBU' end as shipment_type,
       physical_addr,
       material_type,
       unite_spec,
       to_char(outlook_date, 'YYYY-MM-DD')                                         as period_date,
       to_char(outlook_date, 'YYYY-MM')                                            as month,
       stdcii.outlook_date_qty                                                     as capacity_qty
from IN_MDS_TWO_DEVICES_CAPACITY_INFO_HEADER stdcih
         join IN_MDS_TWO_DEVICES_CAPACITY_INFO_ITEM stdcii on stdcih.id = stdcii.header_id
where outlook_date >= trunc(SYSDATE)
  and outlook_date <= last_day(add_months(sysdate, 3))
order by physical_addr, shipment_type, material_type, unite_spec, period_date;

--     "两器库存":
    SELECT INV.MATERIAL_NO,CFG.ATTR2 AS BASE,inv.STORAGE, INV.SALES_ORDER_ID,INV.SALES_ORDER_LINE_NO,QTY
      FROM IN_MDS_INVENTORY INV
               INNER JOIN MID_MDS_ITEM ITEM
                          ON INV.MATERIAL_NO = ITEM.ITEM
               LEFT JOIN SDBMGR_KT.IN_MDS_CFG_PARAMETER CFG
                         ON CFG.BELONG_DOMAIN = 'ALL'
                             AND CFG.PARAM_NAME = 'SAP_ATP_LOC_MAPPING'
                             AND CFG.ATTR1 = 'Y'
                             AND CFG.DIMENSION1 = INV.SITE_ID
      WHERE ITEM.ATP_MATL_GROUP = '两器';