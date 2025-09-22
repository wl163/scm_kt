SELECT * FROM sop_mould_capacity WHERE base='JJJY' AND mould='F1' and outlook_date>= curdate() order by outlook_date


select * from sop_mould_average_capacity_daily;
SELECT * FROM sop_mould_capacity;



select base,mould_level_one ,T.* from sop_mould_capacity_calendar T where is_working='Y';


select * from sp_turn_prodt_put where demand_type= 2 and


select business_line,in_out_scode,require_goods_mode2
from sp_turn_prodt_result t where t.pt_plan_version='2025-07-21初版' and
abnormal_type_code is NOT NULL and ((proto_code_type in ('套机') and whole_in_out='整机') or proto_code_type not in ('套机'))
and demand_type=2
and business_line = '外销ODM' order by doc_no ;


# 邮件配置：
SELECT * from cfg_parameter where param_name = 'ZCODE_OPTIONAL_CONFIG_RELATION_EMAIL';

select whole_code,whole_in_out,in_out_scode,in_out_zcode,original_zcode ,last_update_date
from sp_zcode_optional_config_relation
order by last_update_date desc ,whole_code;

select * from sop_data_funnel_detail where biz_line1='OBG';

select * from sop_data_funnel_detail where biz_line2 is null or biz_line3 is null or biz_line4 is null ;
