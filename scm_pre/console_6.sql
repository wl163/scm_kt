with aa as (select *
            from (select DATE_FORMAT(t.demand_date, '%y%m')         as month,
                         (case
                              when t.brand_group = 'ODM'
                                  and t.bg_code != 'CBG' then '外销ODM'
                              when t.bg_code = 'CBG'
                                  and t.is_special != 'Y'
                                  and t.brand_group != 'ODM' then '内销品牌'
                              when t.bg_code = 'CBG'
                                  and (t.is_special = 'Y'
                                      or t.brand_group = 'ODM') then '内销特种'
                              else t.bg_code
                             end)                                   as 'biz_line',
                         t.bg_code                                  as 'BG/分公司',
                         t.region_code                              as '业务单元',
                         t.country_code                             as '国家',
                         t.brand_group                              as '品牌大类',
                         t.is_special                               as '是否特种',
                         t.is_bulk                                  as '是否散件',
                         t.bulk_require_goods_mode                  as '散件要货模式',
                         t.cust_code                                as '客户',
                         t.inner_po_no                              as '内部PO号',
                         t.inner_po_item_no                         as '内部PO行号',
                         t.inner_po_item_no_detail                  as '内部PO明细行号',
                         CONCAT(inner_po_no, '_', inner_po_item_no) as 'po行',
                         t.so_no                                    as 'SO号',
                         t.so_line_no                               as 'SO行号',
                         t.require_goods_mode                       as '要货模式',
                         t.whole_material_no                        as '整机行物料编码',
                         t.whole_proto_code                         as '整机行原型机编码',
                         t.demand_date                              as '需求时间',
                         t.demand_qty                               as '需求数量',
                         t.order_source,
                         t.so_major_categories,
                         if(t.order_source = '01' and t.so_major_categories = '2', t.demand_qty,
                            t.offset_qty)                           as 'OPEN数量'
                  from sp_order_offset_week_po_organized t
                  where t.version_no = (select po_version
                                        from sp_weekly_offset_version_relation
                                        where version_no =
                                              (select version_no
                                               from sp_order_offset_week_result
                                               group by version_no
                                               order by version_no desc
                                               limit 1))) ss ),
     bb as (SELECT SUM(dd.net_demand_qty),
                   CONCAT(cc.po_no, '_', cc.po_line_no) AS ODFpo行,
                   demand_date
            FROM (SELECT po_no,
                         po_line_no,
                         order_no
                  FROM sp_order_header_weekly_snapshot
                  WHERE version_no = (SELECT MAX(version_no) FROM sp_order_header_weekly_snapshot)) cc
                     JOIN
                 (SELECT doc_no,
                         net_demand_qty,
                         demand_date
                  FROM sp_order_offset_week_process_2
                  WHERE demand_type = 'ODF'
                    AND version_no = (SELECT MAX(version_no) FROM sp_order_offset_week_process_2)) dd
                 ON cc.order_no = dd.doc_no
            GROUP BY CONCAT(cc.po_no, '_', cc.po_line_no)),
     all_date as (select * from aa left join bb on aa.po行 = bb.ODFpo行
                  union all
                  select * from aa right join bb on aa.po行 = bb.ODFpo行),
    group_date as (
        select month,biz_line,`BG/分公司`,业务单元,国家,品牌大类,是否特种,
            是否散件,散件要货模式,客户,内部PO号,内部PO行号,内部PO明细行号,po行,SO号,SO行号,要货模式,整机行物料编码,整机行原型机编码,需求时间,ODFpo行,
               row_number() over (partition by month,biz_line,`BG/分公司`,业务单元,国家,品牌大类,是否特种,
            是否散件,散件要货模式,客户,内部PO号,内部PO行号,内部PO明细行号,po行,SO号,SO行号,要货模式,整机行物料编码,整机行原型机编码,需求时间,ODFpo行) as rn
        from all_date
    )
select *
from group_date where rn=1



