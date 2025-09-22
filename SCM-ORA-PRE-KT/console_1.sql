select * from RPT_MDS_MATERIAL_GAP_DETAIL;


select * from MID_MDS_MRP;

/*
SELECT DISTINCT b.purchase_group_desc FROM RPT_MDS_MATERIAL_GAP a
    LEFT JOIN sap_purchase_group_mst b ON a.PURCH_GROUP=b.PURCH_GROUP WHERE
              IFNULL (b.purchase_group_desc,'')<>'';
select * from RPT_MDS_MATERIAL_GAP_DETAIL;
*/

select * from IN_MDS_SRM_INVENTORY where vmi_type='Y';


select distinct PURCHASE_STRATEGY_CLASSIFY from IN_MDS_ITEM_MASTER_PARTS;

select * from IN_MDS_ITEM_MASTER_PARTS;


select * from MID_MDS_MRP a left join IN_MDS_ITEM_MASTER_PARTS b on
    a.SUPPLYITEM = b.PARTS_NO_ORIG ;



select * from MID_MDS_MRP a left join IN_MDS_ITEM_MASTER_PARTS b on
    a.SUPPLYITEM = b.PURCHASE_STRATEGY_CLASSIFY;

SELECT  * FROM IN_MDS_ITEM_MASTER_PARTS;

select PURCH_GROUP_DESC from RPT_MDS_MATERIAL_GAP a;

select c.PURCHASE_GROUP, c.PURCHASE_GROUP_DESC,a.*
from RPT_MDS_MATERIAL_GAP a
         left join IN_MDS_FACTORY_MATERIAL b on
    a.FACTORY_SAP = b.FACTORY_NO and a.ITEM = b.MATERIAL_NO
         left join in_mds_purchase_group_mst c
                   on b.PURCHASE_GROUP = c.PURCHASE_GROUP
where a.VERSION='20250528_W_V240042'
and COALESCE(c.PURCHASE_GROUP_DESC,'') <>''
and  COALESCE(c.PURCHASE_GROUP,'') <>'';


select a.ITEM,a.FACTORY_SAP,b.PURCHASE_GROUP,b.FACTORY_NO
from RPT_MDS_MATERIAL_GAP a
         inner join IN_MDS_FACTORY_MATERIAL b on
    a.FACTORY_SAP = b.FACTORY_NO and a.ITEM = b.MATERIAL_NO
where a.VERSION='20250528_W_V240042'
and a.ITEM='92014-000395';

select * from RPT_MDS_MATERIAL_GAP where FACTORY_SAP like '%5570%';
select * from RPT_MDS_MATERIAL_GAP where ITEM='92014-000395';
SELECT * FROM IN_MDS_FACTORY_MATERIAL where MATERIAL_NO='92014-000395' and FACTORY_NO in ('5500','5520');

SELECT distinct PURCHASE_GROUP FROM IN_MDS_FACTORY_MATERIAL;

select  PURCHASE_GROUP_DESC from in_mds_purchase_group_mst;

select INSTR('5500&5520&5570', '&')  from dual;
select  SUBSTR('5500&5520&5570', 1, INSTR('5500&5520', '&') - 1) AS part1 from dual ;
select * from in_mds_purchase_group_mst t where t.PURCHASE_GROUP='466';

select * from RPT_MDS_MATERIAL_GAP t where t.VERSION='20250528_W_V240042' and ITEM='92014-000395' and FACTORY_SAP = '5520';
select * from RPT_MDS_MATERIAL_GAP t where t.VERSION='20250528_W_V240042' and ITEM='92014-000395' and FACTORY_SAP = '5500';


WITH test_data AS (
  SELECT '5500&5520&5570' AS str FROM dual
)
SELECT
  LEVEL AS part_num,
  REGEXP_SUBSTR(str, '[^&]+', 1, LEVEL) AS part_value
FROM test_data
CONNECT BY LEVEL <= LENGTH(REGEXP_REPLACE(str, '[^&]', '')) + 1;

WITH T1 AS (SELECT MRP.SUPPLYITEM,
                   SUPPLYSEQNUM,
                   NVL(INV.PLANT, 'NA')                                                                      AS FACTORY_SAP,
                   CASE
                       WHEN TRIM(NVL(MRP.PARENTLOC, '')) IS NOT NULL THEN MRP.PARENTLOC
                       ELSE MRP.DMDLOC END                                                                   AS FACTORY_ATP,
                   SUPPLYAVAILDATE                                                                           AS REPORT_DATE
            FROM MID_MDS_MRP MRP
                     JOIN IN_MDS_KEY_ITEM_M ITEM ON ITEM.MATERIAL_NO_ORIG = MRP.SUPPLYITEM
                     LEFT JOIN MID_MDS_INVENTORY INV ON MRP.SUPPLYSEQNUM = INV.SEQNUM
            WHERE ITEM.STATUS = 1)


SELECT *FROM T1 WHERE LENGTH(FACTORY_SAP) > 4;


select * from RPT_MDS_MATERIAL_GAP_DETAIL;

with t as ( SELECT DECODE(MATERIAL_NO_ORIG, MATERIAL_NO, '相同', '不同') AS comparison_result
FROM IN_MDS_KEY_ITEM_M
 )
select *
from t where t.comparison_result = '不相同';


SELECT
  REGEXP_SUBSTR('5500&5520&5570', '[^&]+', 1, LEVEL) AS split_value
FROM dual
CONNECT BY LEVEL <= LENGTH(REGEXP_REPLACE('5500&5520&5570', '[^&]', '')) + 1;