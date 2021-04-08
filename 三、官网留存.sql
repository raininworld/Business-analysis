三、官网留存

# 5、官网用户次日、7日、30日留存率
--备注：7日留存是指在第7天，而非7天内

select

count(aaa.visituserid) as `当日`,

count(bbb.visituserid) as `次日`,

count(ccc.visituserid) as `7日`,

count(ddd.visituserid) as `14日`,

count(eee.visituserid) as `30日`,

round(count(bbb.visituserid)/count(aaa.visituserid),2) as `次日留存`,

round(count(ccc.visituserid)/count(aaa.visituserid),2) as `7日留存`,

round(count(ddd.visituserid)/count(aaa.visituserid),2) as `14日留存`,

round(count(eee.visituserid)/count(aaa.visituserid),2) as `30日留存`

from

(select

distinct visituserid

from

dwd.fct_log_visit

where dt='2020-09-01'

-- and  loginuserid='""""""'

) aaa

left join

(select distinct visituserid

from dwd.fct_log_visit

where dt = DATE_ADD('2020-09-01',1)

-- and  loginuserid='""""""'

) bbb

on aaa.visituserid=bbb.visituserid

left join

(select distinct visituserid

from dwd.fct_log_visit

where dt between  DATE_ADD('2020-09-01',1) and DATE_ADD('2020-09-01',7)

-- and  loginuserid='""""""'

) ccc

on aaa.visituserid=ccc.visituserid

left join

(select distinct visituserid

from dwd.fct_log_visit

where dt between  DATE_ADD('2020-09-01',1) and  DATE_ADD('2020-09-01',14)

-- and  loginuserid='""""""'

) ddd

on aaa.visituserid=ddd.visituserid

left join

(select distinct visituserid

from dwd.fct_log_visit

where dt between  DATE_ADD('2020-09-01',1) and DATE_ADD('2020-09-01',30)

-- and  loginuserid='""""""'

) eee

on  aaa.visituserid=eee.visituserid

-- select distinct visituserid,loginuserid,dt from dwd.fct_log_page

# 10、官网公开课非游客观看时长（常用）
SELECT cu.user_id,sum(cu.online)

from ods_lps_kkb_live.class_user cu

WHERE cu.group_id=273177

and cu.msg_type in ('login_out_auto','login_out')

and length(cu.user_id)>=8

GROUP BY cu.user_id

# 11、鹰眼官网注册用户-刘航
select * fromplat_user

where action=10


# 17、官网pvuv订单非同源-刘航
--非同源，pv，uv有问题

SELECT bb.*,cc.`课程类型`,cc.`创建订单数`,dd.`订单完成数`,dd.`总金额`

from

(SELECT substr(pu.create_at,1,10) `自然日`,count(pu.uid)

from ods_plat_kkb_plat_eagle_eye.plat_user pu

WHERE pu.action='10'

and  substr(pu.create_at,1,10)>='2020-11-01'

GROUP BY substr(pu.create_at,1,10)) bb

left join

(SELECT aa.`创建时间`,aa.`课程类型`,count(aa.no) `创建订单数`

from

(SELECT substr(from_unixtime(vc.create_time),1,10) `创建时间`,vo.no,vo.status `支付状态`,

vo.amount,

case when vo.course_type=0 then '正价课'

when vo.course_type=1 then '体验课'

when vo.course_type=2 then '公开课'

when vo.course_type=3 then '新公开课'

else '未知' end `课程类型`

from ods_oldmos_kkb_cloud_vipcourse.vip_channel vc

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vcc

on vc.course_id=vcc.id

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on vc.code=vo.channel_code

WHERE vc.source_type=1

and vo.amount<100

and substr(from_unixtime(vc.create_time),1,10)>='2020-11-01') aa

GROUP BY aa.`创建时间`,aa.`课程类型`) cc

on bb.`自然日`=cc.`创建时间`

left join

(SELECT aa.`创建时间`,aa.`课程类型`,count(aa.no) `订单完成数`,sum(aa.amount) `总金额`

from

(SELECT substr(from_unixtime(vc.create_time),1,10) `创建时间`,vo.no,vo.status `支付状态`,

vo.amount,

case when vo.course_type=0 then '正价课'

when vo.course_type=1 then '体验课'

when vo.course_type=2 then '公开课'

when vo.course_type=3 then '新公开课'

else '未知' end `课程类型`

from ods_oldmos_kkb_cloud_vipcourse.vip_channel vc

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vcc

on vc.course_id=vcc.id

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on vc.code=vo.channel_code

WHERE vc.source_type=1

and vo.status=2

and vo.amount<100

and substr(from_unixtime(vc.create_time),1,10)>='2020-11-01') aa

GROUP BY aa.`创建时间`,aa.`课程类型`) dd

on cc.`创建时间`=dd.`创建时间` and cc.`课程类型`=dd.`课程类型`;

# 18、同源/非同源官网来量情况-刘航
--非同源，pv，uv有问题

SELECT bb.*,cc.`课程类型`,cc.`创建订单数`,dd.`订单完成数`,dd.`总金额`

from

(SELECT substr(pu.create_at,1,10) `自然日`,count(pu.uid)

from ods_plat_kkb_plat_eagle_eye.plat_user pu

WHERE pu.action='10'

and  substr(pu.create_at,1,10)>='2020-11-01'

GROUP BY substr(pu.create_at,1,10)) bb

left join

(SELECT aa.`创建时间`,aa.`课程类型`,count(aa.no) `创建订单数`

from

(SELECT substr(from_unixtime(vc.create_time),1,10) `创建时间`,vo.no,vo.status `支付状态`,

vo.amount,

case when vo.course_type=0 then '正价课'

when vo.course_type=1 then '体验课'

when vo.course_type=2 then '公开课'

when vo.course_type=3 then '新公开课'

else '未知' end `课程类型`

from ods_oldmos_kkb_cloud_vipcourse.vip_channel vc

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vcc

on vc.course_id=vcc.id

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on vc.code=vo.channel_code

WHERE vc.source_type=1

and vo.amount<100

and substr(from_unixtime(vc.create_time),1,10)>='2020-11-01') aa

GROUP BY aa.`创建时间`,aa.`课程类型`) cc

on bb.`自然日`=cc.`创建时间`

left join

(SELECT aa.`创建时间`,aa.`课程类型`,count(aa.no) `订单完成数`,sum(aa.amount) `总金额`

from

(SELECT substr(from_unixtime(vc.create_time),1,10) `创建时间`,vo.no,vo.status `支付状态`,

vo.amount,

case when vo.course_type=0 then '正价课'

when vo.course_type=1 then '体验课'

when vo.course_type=2 then '公开课'

when vo.course_type=3 then '新公开课'

else '未知' end `课程类型`

from ods_oldmos_kkb_cloud_vipcourse.vip_channel vc

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vcc

on vc.course_id=vcc.id

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on vc.code=vo.channel_code

WHERE vc.source_type=1

and vo.status=2

and vo.amount<100

and substr(from_unixtime(vc.create_time),1,10)>='2020-11-01') aa

GROUP BY aa.`创建时间`,aa.`课程类型`) dd

on cc.`创建时间`=dd.`创建时间` and cc.`课程类型`=dd.`课程类型`;

--同源

select ee.*,cc.`课程类型`,cc.`创建订单数`,dd.`支付成功订单数`,dd.`支付成功总金额`

from

(select substr(pu.create_at,1,10) `时间`,count(substr(pu.create_at,1,10)) `注册用户数`

from ods_plat_kkb_plat_eagle_eye.plat_user pu

where action='10'

and substr(pu.create_at,1,10)>='2020-11-01'

group by substr(pu.create_at,1,10)) ee

left join

(select substr(aa.create_at,1,10) `时间`,aa.`课程类型`,count(aa.`课程类型`) `创建订单数`

from

(select pu.uid,pu.create_at,

case when pu.create_at<=from_unixtime(vo.pay_time) then vo.status end `支付状态`,

case when pu.create_at<=from_unixtime(vo.pay_time) then vo.amount end `支付金额`,

case when pu.create_at<=from_unixtime(vo.pay_time) and vo.course_type=0 then '正价课'

when pu.create_at<=from_unixtime(vo.pay_time) and vo.course_type=1 then '体验课'

when pu.create_at<=from_unixtime(vo.pay_time) and vo.course_type=2 then '公开课'

when pu.create_at<=from_unixtime(vo.pay_time) and vo.course_type=3 then '新公开课'

when pu.create_at<=from_unixtime(vo.pay_time) and isnull(vo.course_type) then '未成单'

else '未知课程类型' end `课程类型`

from ods_plat_kkb_plat_eagle_eye.plat_user pu

left join ods_lps_kkb_cloud_passport.user_wechat_map uwm

on pu.uid=uwm.uid

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on uwm.unionid=vo.unionid

where action='10'

and substr(pu.create_at,1,10)>='2020-11-01') aa

group by substr(aa.create_at,1,10),aa.`课程类型`) cc

on ee.`时间`=cc.`时间`

left join

(select substr(bb.create_at,1,10) `时间`,bb.`课程类型`,count(bb.`支付状态`) `支付成功订单数`,sum(bb.`支付金额`) `支付成功总金额`

from

(select pu.uid,pu.create_at,

case when pu.create_at<=from_unixtime(vo.pay_time) then vo.status end `支付状态`,

case when pu.create_at<=from_unixtime(vo.pay_time) then vo.amount end `支付金额`,

case when pu.create_at<=from_unixtime(vo.pay_time) and vo.course_type=0 then '正价课'

when pu.create_at<=from_unixtime(vo.pay_time) and vo.course_type=1 then '体验课'

when pu.create_at<=from_unixtime(vo.pay_time) and vo.course_type=2 then '公开课'

when pu.create_at<=from_unixtime(vo.pay_time) and vo.course_type=3 then '新公开课'

when pu.create_at<=from_unixtime(vo.pay_time) and isnull(vo.course_type) then '未成单'

else '未知课程类型' end `课程类型`

from ods_plat_kkb_plat_eagle_eye.plat_user pu

left join ods_lps_kkb_cloud_passport.user_wechat_map uwm

on pu.uid=uwm.uid

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on uwm.unionid=vo.unionid

where action='10'

and vo.status=2

and substr(pu.create_at,1,10)>='2020-11-01') bb

group by substr(bb.create_at,1,10),bb.`课程类型`) dd

on cc.`时间`=dd.`时间` and cc.`课程类型`=dd.`课程类型`

-- limit 10

;

--官网每日注册用户数

select substr(pu.create_at,1,10),count(uid)

from

ods_plat_kkb_plat_eagle_eye.plat_user pu

where action='10'

and substr(pu.create_at,1,10)>='2020-11-01'

group by substr(pu.create_at,1,10);

--三级url的访问情况

select * from dws.smy_ow_url_visit_day




# 22、官网不同url带来的注册用户数统计-夏季
select

case when channel_code='BJIfUpjmLA' then '官网Banner-PC'

when  channel_code='veJyLkUVae-' then '官网Banner-H5'

when  channel_code='YaOTsw5tRf' then 'POP-PC'

when  channel_code='OwB44DoVsq' then 'POP-H5'

when  channel_code='WsfGjGk12Q' then '开课吧App开屏'

when  channel_code='SrLeUWboP9' then 'social新媒体推文&微博推广'

when  channel_code='dGyV3Ar3vh' then '品专宣传入口'

when  channel_code='XyArfZAKGp' then '百度APP开屏'

when  channel_code='EWiJxxoKUb' then '品牌海报、钉钉开屏'

when  channel_code='AYgvFxdjFO' then '抖音'

end as `来源`,

to_date(create_at) as `日期`,count(id) `注册数`

from ods_plat_kkb_plat_eagle_eye.plat_user

where ref_url in

('https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=AYgvFxdjFO&pageCode=nuWQPV0EfR',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=XyArfZAKGp&pageCode=Ys5fRxGfkp',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=SrLeUWboP9&pageCode=0sKXmqes67',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=EWiJxxoKUb&pageCode=1gWsNm7SUM',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=BJIfUpjmLA&pageCode=WkcmauSj8m',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=YaOTsw5tRf&pageCode=nnk9Jws0Zy',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=veJyLkUVae&pageCode=yThiDjJsSg',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=OwB44DoVsq&pageCode=QHOJ5nHaqq',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=WsfGjGk12Q&pageCode=m4AixGcLiE',

'https://www.kaikeba.com/activity/kaikebajiaoyujie?channel=dGyV3Ar3vh&pageCode=adOORgKaJf')

group by case when channel_code='BJIfUpjmLA' then '官网Banner-PC'

when  channel_code='veJyLkUVae-' then '官网Banner-H5'

when  channel_code='YaOTsw5tRf' then 'POP-PC'

when  channel_code='OwB44DoVsq' then 'POP-H5'

when  channel_code='WsfGjGk12Q' then '开课吧App开屏'

when  channel_code='SrLeUWboP9' then 'social新媒体推文&微博推广'

when  channel_code='dGyV3Ar3vh' then '品专宣传入口'

when  channel_code='XyArfZAKGp' then '百度APP开屏'

when  channel_code='EWiJxxoKUb' then '品牌海报、钉钉开屏'

when  channel_code='AYgvFxdjFO' then '抖音'

end,to_date(create_at)

# 23、双十二官网售卖课程成单统计-夏季
#分组课程名字id

select

c.item_name as `课程名称`,to_date(from_unixtime(c.pay_time)) as `支付时间`,

count(*) as `成交总单量`,round(sum(c.amount),2) as `成交总金额(元)`

from ods_oldmos_kkb_cloud_vipcourse.vip_order c

right join

(select a.*

from

(select distinct vo.channel_code,vc.new_course_id,vo.course_id,vo.class_id

from ods_oldmos_kkb_cloud_vipcourse.vip_class vc

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on vo.course_id = vc.course_id and vo.class_id = vc.id

where vc.new_course_id in ('212859',

'212870',

'212916',

'212941',

'212834',

'212912',

'212943',

'212825')) a

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vch

on a.channel_code = vch.code

where vch.source_type = 1)b

on c.channel_code = b.channel_code

where

from_unixtime(c.pay_time) between '2020-12-01 00:00:00' and '2020-12-10 23:59:59'

and c.status = 2

group by c.item_name,to_date(from_unixtime(c.pay_time))

#分组channel_code

select

b.channel_code,

to_date(from_unixtime(c.pay_time)) as `支付时间`,

count(*) as `成交总单量`,

round(sum(c.amount),2) as `成交总金额(元)`

from ods_oldmos_kkb_cloud_vipcourse.vip_order c

left join

(select a.*

from

(select distinct vo.channel_code,vo.course_id,vo.class_id,vo.item_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

on vo.course_id = vc.course_id and vo.class_id = vc.id

where vc.new_course_id in

('212859',

'212870',

'212916',

'212941',

'212834',

'212912',

'212943',

'212825')) a

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vch

on a.channel_code = vch.code

where vch.source_type = 1)b

on c.channel_code = b.channel_code

where

from_unixtime(c.pay_time) between '2020-12-01 00:00:00' and '2020-12-14 23:59:59'

and c.status = 2

group by b.channel_code,to_date(from_unixtime(c.pay_time))

--明细

select d.mobile,d.`课程名称` as `课程名称`,d.`支付时间` as `支付时间`,d.amount as `支付金额`,

min(from_unixtime(e.pay_time)) as `首次购课时间`

from

(select

distinct c.mobile,c.item_name as `课程名称`,from_unixtime(c.pay_time) as `支付时间`,c.amount

from ods_oldmos_kkb_cloud_vipcourse.vip_order c

right join

(select a.*

from

(select distinct vo.channel_code,vc.new_course_id,vo.course_id,vo.class_id,vo.mobile,vo.amount

from ods_oldmos_kkb_cloud_vipcourse.vip_class vc

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on vo.course_id = vc.course_id and vo.class_id = vc.id

where vc.new_course_id in ('212859',

'212870',

'212916',

'212941',

'212834',

'212912',

'212943',

'212825')) a

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vch

on a.channel_code = vch.code

where vch.source_type = 1)b

on c.channel_code = b.channel_code

where

from_unixtime(c.pay_time) between '2020-12-01 00:00:00' and '2020-12-14 23:59:59'

and c.status = 2)d

left join ods_oldmos_kkb_cloud_vipcourse.vip_order e

on e.mobile = d.mobile

where e.status = 2

group by d.mobile,d.`课程名称`,d.`支付时间`,d.amount

8


# 39、官网留资价值-微信号里的手机号
select

month(jjj.`首次咨询时间`) as`月份`,

count(jjj.`手机号`) as `个数`

-- ,jjj.`首次咨询时间`

-- ,jjj.`新最早支付时间`

from

(

select fff.`手机号`,fff.`首次咨询时间`,

case when fff.`最早支付时间` is null  then '2022-01-01 00:00:00'

else fff.`最早支付时间` end as `新最早支付时间`

from

(select

ccc.`手机号`

,ccc.`首次咨询时间`

,bbb.`最早支付时间`

from

(select aaa.`手机号`,aaa.`首次咨询时间`

from

(select

case when mobile='' then weixin

when mobile!='' then '' end as `手机号`,

min(first_add_time) as `首次咨询时间`

from ods_kkb_plat_customer_support.customer_support

group by case when mobile='' then weixin

when mobile!='' then '' end) aaa

where aaa.`首次咨询时间` between '2020-06-01 00:00:00' and '2020-12-31 23:59:59'

and aaa.`手机号` is not null

and length(aaa.`手机号`)=11

-- and aaa.`手机号` like '1%'

)ccc

left join

(select mobile,min(FROM_UNIXTIME(pay_time)) as `最早支付时间`

from  ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where status in (2,4)

group by mobile) bbb

on ccc.`手机号`=bbb.mobile) fff

)jjj

where jjj.`首次咨询时间`<jjj.`新最早支付时间`

group by

month(jjj.`首次咨询时间`)

# 40、官网留资价值-纯手机号
select

ddd.`月份`,count(ddd.`手机号`)

from (select ccc.`手机号`,ccc.`首次咨询时间`,

case  when bbb.`最早支付时间` is null then "2022-01-01 00:00:00"

else bbb.`最早支付时间` end as `首次支付时间`,

ccc.`月份`,

case when ccc.`首次咨询时间` > `最早支付时间` then "否"

else  "是" end as `是否具有价值`

from

(select aaa.`手机号`,aaa.`首次咨询时间`,aaa.`月份`

from

(

select

mobile as `手机号`,

month(min(first_add_time)) as `月份`,

min(first_add_time) as `首次咨询时间`

from ods_kkb_plat_customer_support.customer_support

where mobile is not null and length(mobile)=11 and mobile like '1%'

group by mobile) aaa

where aaa.`首次咨询时间` between '2020-06-01 00:00:00' and '2020-12-31 23:59:59')ccc

left join

(select mobile,min(FROM_UNIXTIME(pay_time)) as `最早支付时间`

from  ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where status in (2,4)

group by mobile) bbb

on ccc.`手机号`=bbb.mobile) ddd

where ddd.`是否具有价值` = "是"

group by ddd.`月份`

order by ddd.`月份`



