select rso_no, version_no, status_code, valid_date
from sop_rso_order_header
where (rso_no, version_no) in (select rso_no, max(version_no) as version_no
                               from sop_rso_order_header
                               group by rso_no)
  and status_code in (select param_value from cfg_parameter WHERE param_name = 'RSO_STATUS' and attr1 = 'Y')
  and date_format(valid_date, '%Y-%m-%d') >= curdate();


-- 符合 失效SAP成功的单据 写法1
select rso_no, version_no, status_code, invalid_date
from sop_rso_order_header
where (rso_no, version_no) in (select rso_no, max(version_no) as version_no
                               from sop_rso_order_header
                               group by rso_no)
  and status_code in (select param_value from cfg_parameter WHERE param_name = 'RSO_STATUS' and attr2 = 'Y')
  and date_format(invalid_date, '%Y-%m-%d') <= curdate();