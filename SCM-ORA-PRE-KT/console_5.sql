SELECT INV.MATERIAL_NO,CFG.ATTR2 AS BASE,inv.STORAGE, INV.Sales_Order_Id,INV.Sales_Order_Line_No,QTY
      FROM IN_MDS_INVENTORY INV
               INNER JOIN IN_MDS_ITEM_MASTER ITEM
                          ON INV.MATERIAL_NO = ITEM.BOM_CODE
               LEFT JOIN SDBMGR_KT.IN_MDS_CFG_PARAMETER CFG
                         ON CFG.BELONG_DOMAIN = 'ALL'
                             AND CFG.PARAM_NAME = 'SAP_ATP_LOC_MAPPING'
                             AND CFG.ATTR1 = 'Y'
                             AND CFG.DIMENSION1 = INV.SITE_ID
      WHERE ITEM.WHOLE_IN_OUT IN ('内机', '外机')