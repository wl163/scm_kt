select tt.month                        as '月份',
       tt.biz_line                     as '业务线',
       ifnull(tnr.net_rtf_qty, 0)      as '输出-净RTF数量',
       ifnull(tnp.net_po_qty, 0)       as '输出-净PO数量',
       ifnull(too.odf_qty, 0)          as '输出-ODF数量'
from (select tc.month,
             tbl.biz_line
      from (select distinct t.month
            from (select distinct DATE_FORMAT(t.demand_date, '%Y-%m') as month
                  from sp_rtf_daily_snapshot t
                  where t.version_no = (select version_no
                                        from sp_rtf_daily_snapshot
                                        group by version_no
                                        order by version_no desc
                                        limit 1)
                    and t.is_parent = 'Y'
                    and t.data_type = '1'
                  union all
                  select distinct DATE_FORMAT(t.demand_date, '%Y-%m')
                  from sp_order_offset_day_remaining_open_fnl t
                           left join scm_market_org org
                                     on t.country_code = org.country_code
                                         and t.brand_group = org.brand_name
                  where t.is_parent = 'Y'
                    and t.data_type = '1'
                    and t.demand_source = 'ODF'
                  union all
                  select distinct DATE_FORMAT(ifnull(t.flip_promise_date,
                                                     ifnull(t.demand_factory_etd_time, t.last_demand_date)),
                                              '%Y-%m') as month
                  from sp_order_header_daily_offset_effflag t
                           left join scm_market_org org
                                     on t.require_goods_country = org.country_code
                                         and t.brand_type = org.brand_name
                  where t.eff_flag = '0'
                     or (
                      t.eff_flag != '0'
                          and
                      t.eff_prc_sw = '0'
                      )
                  union all
                  select distinct DATE_FORMAT(t.data_time, '%Y-%m') as month
                  from sp_order_offset_day_result t
                  where t.version_no = (select version_no
                                        from sp_order_offset_day_result
                                        group by version_no
                                        order by version_no desc
                                        limit 1)
                    and t.is_parent = 'Y'
                    and t.data_type = '1') t
            order by t.month) tc
               join scm_biz_line_analysis tbl
      order by tc.month,
               field(tbl.biz_line, 'CBG-非特种', 'CBG-特种&ODM', 'APBG', 'LABG', 'MEABG', 'EUBG', 'NABG', 'ODM-外销',
                     'N/A')) tt

         left join
     (
         -- 日度冲减输出净RTF
         select t.month,
                t.biz_line,
                sum(t.net_rtf_qty) as net_rtf_qty
         from (select DATE_FORMAT(t.data_time, '%Y-%m') as month,
                      (case
                           when t.brand_group = 'ODM'
                               and org.bg_code != 'CBG' then 'ODM-外销'
                           when org.bg_code = 'CBG'
                               and t.is_special != 'Y'
                               and t.brand_group != 'ODM' then 'CBG-非特种'
                           when org.bg_code = 'CBG'
                               and (t.is_special = 'Y'
                                   or t.brand_group = 'ODM') then 'CBG-特种&ODM'
                           when org.bg_code in ('APBG', 'EUBG', 'LABG', 'MEABG', 'NABG') then org.bg_code
                           else 'N/A'
                          end)                          as 'biz_line',
                      t.net_rtf_qty
               from sp_order_offset_day_result t
                        left join scm_market_org org
                                  on t.country_code = org.country_code
                                      and t.brand_group = org.brand_name
               where t.version_no = (select version_no
                                     from sp_order_offset_day_result
                                     group by version_no
                                     order by version_no desc
                                     limit 1)
                 and t.is_parent = 'Y'
                 and t.data_type = '1'
                 and t.demand_type = 'FCST') t
         group by t.month,
                  t.biz_line
         order by t.month,
                  field(t.biz_line, 'CBG-非特种', 'CBG-特种&ODM', 'APBG', 'LABG', 'MEABG', 'EUBG', 'NABG', 'ODM-外销',
                        'N/A')) tnr
     on tnr.month <=> tt.month and tnr.biz_line <=> tt.biz_line
         left join
     (
         -- 日度冲减输出净PO数量
         select t.month,
                t.biz_line,
                sum(t.net_order_qty) as net_po_qty
         from (select DATE_FORMAT(t.data_time, '%Y-%m') as month,
                      (case
                           when t.brand_group = 'ODM'
                               and org.bg_code != 'CBG' then 'ODM-外销'
                           when org.bg_code = 'CBG'
                               and t.is_special != 'Y'
                               and t.brand_group != 'ODM' then 'CBG-非特种'
                           when org.bg_code = 'CBG'
                               and (t.is_special = 'Y'
                                   or t.brand_group = 'ODM') then 'CBG-特种&ODM'
                           when org.bg_code in ('APBG', 'EUBG', 'LABG', 'MEABG', 'NABG') then org.bg_code
                           else 'N/A'
                          end)                          as 'biz_line',
                      t.net_order_qty
               from sp_order_offset_day_result t
                        left join scm_market_org org
                                  on t.country_code = org.country_code
                                      and t.brand_group = org.brand_name
               where t.version_no = (select version_no
                                     from sp_order_offset_day_result
                                     group by version_no
                                     order by version_no desc
                                     limit 1)
                 and t.is_parent = 'Y'
                 and t.data_type = '1'
                 and t.demand_type = 'ODF'
                 and t.order_status != 'EFFECTIVE') t
         group by t.month,
                  t.biz_line
         order by t.month,
                  field(t.biz_line, 'CBG-非特种', 'CBG-特种&ODM', 'APBG', 'LABG', 'MEABG', 'EUBG', 'NABG', 'ODM-外销',
                        'N/A')) tnp
     on tnp.month <=> tt.month and tnp.biz_line <=> tt.biz_line
         left join
     (
         -- 日度冲减输出ODF数量
         select t.month,
                t.biz_line,
                sum(t.net_order_qty) as odf_qty
         from (select DATE_FORMAT(t.data_time, '%Y-%m') as month,
                      (case
                           when t.brand_group = 'ODM'
                               and org.bg_code != 'CBG' then 'ODM-外销'
                           when org.bg_code = 'CBG'
                               and t.is_special != 'Y'
                               and t.brand_group != 'ODM' then 'CBG-非特种'
                           when org.bg_code = 'CBG'
                               and (t.is_special = 'Y'
                                   or t.brand_group = 'ODM') then 'CBG-特种&ODM'
                           when org.bg_code in ('APBG', 'EUBG', 'LABG', 'MEABG', 'NABG') then org.bg_code
                           else 'N/A'
                          end)                          as 'biz_line',
                      t.net_order_qty
               from sp_order_offset_day_result t
                        left join scm_market_org org
                                  on t.country_code = org.country_code
                                      and t.brand_group = org.brand_name
               where t.version_no = (select version_no
                                     from sp_order_offset_day_result
                                     group by version_no
                                     order by version_no desc
                                     limit 1)
                 and t.is_parent = 'Y'
                 and t.data_type = '1'
                 and t.demand_type = 'ODF'
                 and t.order_status = 'EFFECTIVE') t
         group by t.month,
                  t.biz_line
         order by t.month,
                  field(t.biz_line, 'CBG-非特种', 'CBG-特种&ODM', 'APBG', 'LABG', 'MEABG', 'EUBG', 'NABG', 'ODM-外销',
                        'N/A')) too
     on too.month <=> tt.month and too.biz_line <=> tt.biz_line;



SELECT UPPER('offset_day')

