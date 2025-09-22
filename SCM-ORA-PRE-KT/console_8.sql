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
            and t.CAPACITYAVAILDATE between STARTDATE and ENDDATE);



SELECT
        SITE_ID,                --工厂
        SUM(OPEN_QTY) --未清洗QTY数据     (IN表 OPEN_QTY)
FROM
(
        SELECT SITE_ID, SUM(QTY) AS OPEN_QTY FROM IN_MDS_INVENTORY imi
        LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY SITE_ID
        UNION
        SELECT SITE_CODE,SUM(NET_TRANSIT_QTY) AS OPEN_QTY FROM    IN_MDS_DELIVERY_NOTE
        LEFT JOIN MID_MDS_ITEM ON MATERIAL_CODE = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY SITE_CODE
        UNION
        SELECT FACTORY_NO,SUM(UNCLEAR_QTY) AS OPEN_QTY FROM    IN_MDS_SUPPLY_STO
        LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY FACTORY_NO
        UNION
        SELECT FACTORY_NO,SUM(uninstock_qty) AS OPEN_QTY FROM    IN_MDS_PROD
     LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机' GROUP BY FACTORY_NO
)
GROUP BY SITE_ID;


