select * from IN_MDS_INVENTORY t where  t.MATERIAL_NO ='92014-000006'  and SITE_ID='5500' ;
--                                  group by MATERIAL_NO,SITE_ID
select * from RPT_MDS_MATERIAL_GAP_DETAIL_ATTRIBUTE;
select * from RPT_MDS_MATERIAL_GAP_DETAIL where VERSION='20250519_W_V240010' and ITEM='92014-000006' and FACTORY_SAP='5500';
SELECT * FROM IN_MDS_CFG_PARAMETER WHERE belong_domain='ALL' and param_name='MATERIAL_GAP_REPORT_SETTING' and param_value='Y';

select SUPPLYSEQNUM, t.*
from MID_MDS_MRP t
         left join MID_MDS_INVENTORY b
                   on t.SUPPLYSEQNUM = b.SEQNUM
where SUPPLYITEM = '92014-000006'
  AND t.SUPPLYLOC <> t.PARENTLOC
  AND t.SUPPLYTYPE = 7;


select * from MID_MDS_INVENTORY ;
SELECT
                                    MRP.SUPPLYITEM,
                                    MRP.FACTORY_ATP,
                                    SUM(CASE WHEN MRP.FACTORY_ATP = MRP1.SUPPLYLOC THEN SUPPLYPEGQTY ELSE 0 END) AS QTY2,
                                    SUM(CASE WHEN MRP.FACTORY_ATP = MRP1.PARENTLOC THEN SUPPLYPEGQTY ELSE 0 END) AS QTY3
                                FROM FinalCommonAtpData MRP
                                         LEFT JOIN MID_MDS_MRP MRP1
                                                   ON MRP.SUPPLYITEM = MRP1.SUPPLYITEM
                                                       AND MRP1.SUPPLYLOC <> MRP1.PARENTLOC
                                                       AND MRP1.SUPPLYTYPE = 7
                                         LEFT JOIN MID_MDS_INVENTORY MID_INV
                                                   ON MID_INV.SEQNUM = MRP1.SUPPLYSEQNUM
                                WHERE MID_INV.SUPPLY_TYPE = 'INV'
                                GROUP BY MRP.SUPPLYITEM, MRP.FACTORY_ATP


