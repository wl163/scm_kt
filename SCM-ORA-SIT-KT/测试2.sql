--  其他供应（除承诺外的其他供应（库存，转储等） – Oracle

SELECT
    SITE_ID,        --工厂
    TDATE,
    SUM(OPEN_QTY) --未清洗QTY数据   (IN表 OPEN_QTY)
FROM
(

    SELECT SITE_ID,
           (select SUBSTR(REPLACE(PARAM_VALUE, '/'), 1, 6)
            from IN_MDS_CFG_PARAMETER
            where param_name = 'ATP_PLAN_START_DATE' and ROWNUM =1 ) AS TDATE,
           SUM(QTY)                                   AS OPEN_QTY
    FROM IN_MDS_INVENTORY imi LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机'
                                                                            GROUP BY SITE_ID
    UNION
    SELECT SITE_CODE,substr(replace(ESTIMATE_ARRIVAL_DATE,'-'),1,6)  AS TDATE, SUM(NET_TRANSIT_QTY) AS OPEN_QTY FROM  IN_MDS_DELIVERY_NOTE imdn
    LEFT JOIN MID_MDS_ITEM ON MATERIAL_CODE = ITEM WHERE ATP_MATL_GROUP = '压缩机'
                                                   GROUP BY SITE_CODE,substr(replace(ESTIMATE_ARRIVAL_DATE,'-'),1,6)
    UNION
    SELECT FACTORY_NO,substr(DELIVERY_DATE,1,6) as TDATE,SUM(UNCLEAR_QTY) AS OPEN_QTY FROM  IN_MDS_SUPPLY_STO
    LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机'
                                                 GROUP BY FACTORY_NO,substr(DELIVERY_DATE,1,6)
    UNION
    SELECT FACTORY_NO,TO_CHAR(PRODT_ORDER_END_DATE,'YYYYMM') AS TDATE,SUM(uninstock_qty) AS OPEN_QTY FROM  IN_MDS_PROD
    LEFT JOIN MID_MDS_ITEM ON MATERIAL_NO = ITEM WHERE ATP_MATL_GROUP = '压缩机'
                                                 GROUP BY FACTORY_NO ,TO_CHAR(PRODT_ORDER_END_DATE,'YYYYMM')
)
GROUP BY SITE_ID ,TDATE;



select * from SDBMGR_KT.MID_MDS_FCSTORDER WHERE TO_CHAR(CREATION_DATE,'YYYY-MM-DD') ='2025-09-19'
