1、米堆信息流投放账户对应每一条广告（hive）
select distinct
    ac.`代理商渠道`
    ,ac.`投放媒体`
    ,plan.`账户id`
    ,ac.`账户`
    ,ac.`业务线`
    ,ac.`产品线`
    ,plan.`广告组id`
    ,plan_name.`广告组名称`
    ,plan.`广告计划id`
    ,plan_name.`广告计划名称`
    ,plan.`广告创意创建时间`
    ,plan.`投放消耗金额`
    ,plan.`曝光量`
    ,plan.`广告点击数`
    -- ,from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') `创建时间`
    ,from_unixtime(unix_timestamp('2021032509','yyyyMMddHH'),'yyyy-MM-dd HH')  `创建时间`       
from
    (
    -- 投放计划相关
        select
            advertiser_id `账户id`
            -- ,business_name `业务线`
            -- ,subject_name `产品线`
            ,ad_plan_id `广告组id`
            ,ad_id `广告计划id`
            ,to_date(from_unixtime(UNIX_TIMESTAMP(busi_date,'yyyy-MM-dd'))) `广告创意创建时间`
            ,sum(cost)/100 `投放消耗金额`
            ,sum(show_num) `曝光量`
            ,sum(click) `广告点击数`
        from
            `ods`.ods_kkb_ad_support__ad_delivery_data_day_ha
        where
            -- business_id = 18 and advertiser_id is not null and course_id in(2364,2178,2567,2591) and
             pt='2021032509'
        GROUP BY advertiser_id,ad_plan_id,ad_id,to_date(from_unixtime(UNIX_TIMESTAMP(busi_date,'yyyy-MM-dd')))
    ) plan

left join

    (
        -- 广告组名称、广告计划名称
       select
            bb.ad_id ad_id
           ,bb.ad_plan_name `广告组名称`
           ,bb.ad_name `广告计划名称`
       from
           (
                select 
                     ad_id
                    ,ad_plan_name 
                    ,ad_name
                    ,busi_date 
                    ,row_number()over(partition by ad_id order by busi_date desc)   as  rank
                from 
                    `ods`.ods_kkb_ad_support__ad_delivery_data_day_ha 
                where 
                    -- business_id = 18 and  advertiser_id is not null and course_id in(2364,2178,2567,2591) and
                    pt='2021032509'
           ) bb
       where bb.rank=1
    ) plan_name
on plan.`广告计划id`=plan_name.ad_id

-- LEFT JOIN
inner JOIN
    (
    -- 账户、代理商渠道
        select
            -- media_code `投放媒体`
             agent_name `代理商渠道`
            -- ,case when agent_name
            ,case when `media_code`='wechat_moments' then '微信公众平台'
                when `media_code`='tencent' then '腾讯广点通'
                when `media_code`='toutiao' then '今日头条'
                when `media_code`='kuaishou' then '快手'
                when `media_code`='zhihu' then '知乎'
                when `media_code`='bilibili' then 'B站'
                when `media_code`='baidu_ocpc' then '微信朋友圈' end as `投放媒体`
            ,account_name `账户`
            ,account_id `账户id`
            ,business_line_name `业务线`
            ,subject_name `产品线`
        From
          `ods`.ods_kkb_ad_account__account_info_ha
        where business_line_id =18 and pt='2021032509'
    ) ac
on ac.`账户id` = plan.`账户id`