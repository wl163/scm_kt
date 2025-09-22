select distinct biz_line1 from sop_data_funnel_detail ;

select distinct biz_line1,biz_line2,biz_line3,biz_line4 from sop_data_funnel_detail  where biz_line1='OBG';

-- biz_line1=OBG，则查询所有BG的数据以及OBG总计。
-- biz_line1=外销ODM，则查询所有外销ODM的数据。
-- biz_line1=内销品牌，则查询内销品牌的数据。
-- biz_line1=内销特种，则查询内销特种的数据。

-- biz_line1=OBG，biz_line2选择BG，根据所选择BG查询对应的数据；biz_line3和biz_line4，选择什么则查询什么数据。
-- biz_line1=外销ODM，biz_line2=ALL,则查询所有外销ODM的数据；biz_line3和biz_line4，选择什么则查询什么数据。
-- biz_line1=内销品牌，biz_line2=ALL或者biz_line3=ALL或者biz_line4=ALL,则查询所有内销品牌的数据。
-- biz_line1=内销特种，biz_line2=ALL或者biz_line3=ALL或者biz_line4=ALL,则查询所有内销特种的数据。


select distinct  biz_line1,biz_line2,biz_line3,biz_line4 from sop_data_funnel_detail ;
select distinct  biz_line1,biz_line2,biz_line4 from sop_data_funnel_detail ;

 select * from sop_data_funnel_detail;


