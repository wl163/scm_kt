-- 《齐套结构》取数逻辑
SELECT DISTINCT whole_code , IFNULL(in_out_scode ,'') as in_out_scode ,whole_in_out
from sp_zcode_optional_config_relation t
where IFNULL(whole_code,'') != '' and whole_in_out in ('内机','外机') and org_id ='KT';

-- 分区配置 bu_code in Dimension1
SELECT * FROM cfg_parameter t WHERE belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='ADJUST_RANGE'
SELECT DISTINCT Dimension1 FROM cfg_parameter t WHERE belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='ADJUST_RANGE' and param_value ='内销';
SELECT DISTINCT bu_code FROM sp_turn_prodt_result t WHERE t.pt_plan_version ='2024-12-09'

-- 分区取值校验
SELECT DISTINCT param_value FROM cfg_parameter t WHERE belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='ADJUST_RANGE';
SELECT * FROM cfg_parameter t WHERE belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='ADJUST_RANGE';


-- <转产-后处理-海外工厂转产国内需求散件要货模式配置>
SELECT *  FROM cfg_parameter WHERE belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='OVERSEA_FACTORY_TURN_PRODUCT_BULK';


-- 转产发布-异常类型
SELECT `desc` FROM cfg_parameter WHERE belong_domain='KTSCM_TURN_PROUCT' AND PARAM_NAME='PUBLISH_ABNORMAL_TYPE';
SELECT param_value FROM cfg_parameter WHERE belong_domain='KTSCM_TURN_PROUCT' AND PARAM_NAME='PUBLISH_ABNORMAL_TYPE' and attr1 ='Y';
SELECT * FROM cfg_parameter WHERE belong_domain='KTSCM_TURN_PROUCT' AND PARAM_NAME='PUBLISH_ABNORMAL_TYPE';


-- 路径维度配置
SELECT `desc` FROM cfg_parameter WHERE belong_domain='ALL' AND PARAM_NAME='KTSCM_SUPPLY_TYPE';
SELECT * FROM cfg_parameter WHERE belong_domain='ALL' AND PARAM_NAME='KTSCM_SUPPLY_TYPE';

-- 国家+品牌大类+是否特种+是否散件+散件要货模式+要货客户+要货模式+要货指定工厂+原型机编码+要货需求时间
-- DELETE from sp_turn_prodt_result WHERE pt_plan_version ='2024-12-09'
SELECT t.abnormal_type_code ,t.* from sp_turn_prodt_result t WHERE t.pt_plan_version ='2024-12-09' and t.bu_code ='02' -- 01 03 内销
order by proto_code ,level_no,whole_in_out

SELECT t.* from sp_turn_prodt_result t where id in ('993594','90330','90329')

-- 993594 90330 90329
-- 齐套需求数据
select t.abnormal_type_code ,t.proto_code ,t.*
from sp_turn_prodt_result t
where pt_plan_version ='2024-12-09'
and (
	country_code ,brand_group ,is_special ,is_bulk,
	bulk_require_mode ,require_goods_cust ,require_goods_mode ,require_appoint_factory ,proto_code ,require_goods_demand_time
	)
in
(SELECT country_code ,brand_group ,is_special ,is_bulk,
	bulk_require_mode ,require_goods_cust ,require_goods_mode ,require_appoint_factory ,proto_code ,require_goods_demand_time
	from sp_turn_prodt_result t
	WHERE t.pt_plan_version ='2024-12-09' and t.bu_code ='02' -- 01 03 内销
	and t.proto_code_type ='套机' and whole_in_out <> '整机'
	group by country_code ,brand_group ,is_special ,is_bulk,
	bulk_require_mode ,require_goods_cust ,require_goods_mode ,require_appoint_factory ,proto_code ,require_goods_demand_time)
order by proto_code ,level_no,whole_in_out

-- Z1C20101700015 Z1C20103700017
select * from sp_turn_prodt_kits_structure t where t.pt_plan_version ='2024-12-09' and whole_code ='S12010101429';
select * from sp_turn_prodt_kits_structure t where t.pt_plan_version ='2024-12-16' and whole_code ='Z1C20101700015'
select distinct pt_plan_version from sp_turn_prodt_kits_structure


/************************************************** 发布校验 **************************************************/
SELECT * FROM cfg_parameter t WHERE belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='ADJUST_RANGE'

SELECT t.abnormal_type_code ,t.* from sp_turn_prodt_result t WHERE t.pt_plan_version ='2024-12-09' and t.bu_code ='02' -- 01 03 内销
order by proto_code ,demand_type ,level_no,whole_in_out
-- update sp_turn_prodt_result t set t.country_code ='CN' where t.pt_plan_version ='2024-12-09' and t.bu_code='01'
-- update sp_turn_prodt_result t set t.bu_code ='03' where t.pt_plan_version ='2024-12-09' and t.bu_code='01'

-- update sp_turn_prodt_result t set t.abnormal_type_code = null where t.pt_plan_version ='2024-12-09' and t.abnormal_type_code ='123'

SELECT d.id,d.pt_plan_version ,bu_code ,relation_id ,proto_code ,level_no ,proto_code_type ,whole_code ,in_out_scode ,
in_out_zcode ,turn_prodt_factory ,finished_factory ,turn_prodt_factory_etd_time
FROM sp_turn_prodt_result d
join (
	select Dimension1,Dimension2,param_value from cfg_parameter
	where belong_domain='KTSCM_TURN_PROUCT' and PARAM_NAME='PUBLISH_CYCLE_LIMIT_IS') cfg
on d.demand_type = cfg.Dimension1 and d.bu_code=cfg.Dimension2
and d.turn_prodt_factory_etd_time < DATE_ADD('2024-12-09', INTERVAL param_value DAY)
where  d.pt_plan_version ='2024-12-09'
and IFNULL(in_out_zcode,'') <>''  and IFNULL(turn_prodt_factory ,'') <>''  and IFNULL(finished_factory,'') <>''

-- 套机  内外机需求工厂制造工厂不相等的 Z1C20101700015
select * from sp_turn_prodt_result t where t.pt_plan_version='2024-12-09' and t.bu_code ='01' and t.proto_code ='Z1C20101700015'
and IFNULL(in_out_zcode,'') <>''  and IFNULL(turn_prodt_factory ,'') <>''  and IFNULL(finished_factory,'') <>''
-- Z码为空的 S12010303296：Z1U20103000994、Z1U20103000995
SELECT t.abnormal_type_code,t.proto_code ,in_out_zcode ,t.* from sp_turn_prodt_result t
where t.pt_plan_version ='2024-12-09' and t.bu_code='01' AND t.proto_code ='Z1C20101700827'

-- FCST周期不足的  S12010101429


SELECT `desc` FROM cfg_parameter WHERE belong_domain='KTSCM_TURN_PROUCT' AND PARAM_NAME='PUBLISH_ABNORMAL_TYPE';
SELECT `desc` FROM cfg_parameter WHERE belong_domain='ALL' AND PARAM_NAME='KTSCM_SUPPLY_TYPE';
--
-- DELETE from sp_turn_prodt_result_abnormal_publish_detail t where t.pt_plan_version ='2024-12-09'
-- DELETE from sp_turn_prodt_result t where t.pt_plan_version ='2024-12-09发布版'
-- DELETE from sp_turn_prodt_result t where t.pt_plan_version ='2024-12-09'
SELECT * from sp_turn_prodt_result t where t.pt_plan_version ='2024-12-09发布版' order by bu_code ,proto_code ,level_no ,whole_in_out
select * from sp_turn_prodt_result_abnormal_publish_detail t where t.pt_plan_version ='2024-12-09'

-- UPDATE sp_turn_prodt_result set abnormal_type_code =null where pt_plan_version ='2024-12-09'

SELECT t.abnormal_type_code ,t.proto_code ,t.turn_prodt_factory_etd_time ,t.*  from sp_turn_prodt_result t where t.pt_plan_version ='2024-12-09' order by bu_code ,proto_code ,level_no ,whole_in_out

SELECT t.abnormal_type_code ,t.proto_code ,t.turn_prodt_factory_etd_time ,t.*
from sp_turn_prodt_result t WHERE t.pt_plan_version ='2024-12-09' and t.bu_code ='02' -- 01 03 内销
order by proto_code ,demand_type ,level_no,whole_in_out


SELECT t.abnormal_type_code ,t.* from sp_turn_prodt_result t where  t.pt_plan_version ='2024-12-16' and t.abnormal_type_code  in
 (SELECT param_value FROM cfg_parameter WHERE belong_domain='KTSCM_TURN_PROUCT' AND PARAM_NAME='PUBLISH_ABNORMAL_TYPE' and attr1 ='Y')

SELECT * FROM cfg_parameter WHERE belong_domain='KTSCM_TURN_PROUCT' AND PARAM_NAME='PUBLISH_ABNORMAL_TYPE'

