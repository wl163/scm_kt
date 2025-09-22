--     "转产结果SIM表数据": """
    SELECT
    FCST.ATTR4 AS ORDER_ID ,
    CASE
                 WHEN header.brand_group = '自有品牌' AND header.country_code = 'CN' AND header.is_special = 'Y'
                     THEN '内销特种'
                 WHEN header.brand_group = 'ODM' AND header.country_code = 'CN'
                     THEN '内销特种'
                 WHEN header.brand_group = '自有品牌' AND header.country_code = 'CN' AND header.is_special = 'N'
                     THEN '内销品牌'
                 WHEN header.brand_group = 'ODM' AND header.bu_code = '04'
                     THEN '外销ODM'
                 ELSE IMSM.bg_code END                                 AS                            BG,
       SF.NEEDDATE,
       TO_CHAR(SF.NEEDDATE, 'YYYY-MM') MONTH,
       TURN_PRODT_QTY       AS                           QTY,
       header.RELATION_ID,
       header.PROTO_CODE_TYPE,
       WHOLE_IN_OUT,
       IN_OUT_ZCODE,
       WHOLE_CODE,
       PT_PLAN_VERSION,
       DEMAND_TYPE,
              header.IS_SPECIAL,
       header.COUNTRY_CODE,
       header.BRAND_GROUP,
       header.IS_BULK,
       header.REQUIRE_GOODS_MODE
FROM IN_MDS_TURN_PRODT_RESULT header
         LEFT JOIN IN_MDS_SCM_MARKET_ORG IMSM
                   ON IMSM.COUNTRY_CODE = header.COUNTRY_CODE
                       AND BRAND_NAME = BRAND_GROUP
        INNER JOIN MID_MDS_FCSTORDER FCST
            ON header.ID = FCST.ORGNUM AND FCST.DMD_TYPE IN ('FCST','PO')
       INNER JOIN SCPOMGR_MDS1_KT.SIM_FCSTORDER SF ON FCST.SEQNUM = SF.SEQNUM
WHERE PROTO_CODE_TYPE != '套机' OR  WHOLE_IN_OUT NOT IN ( '内机' ,'外机') ;


SELECT MAX(PT_PLAN_VERSION) FROM IN_MDS_TURN_PRODT_RESULT;


