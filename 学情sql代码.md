# **1、查所有正价课学员的学情数据-郭凯**
select aaa.nickname as `学员昵称`,

aaa.mobile as  `手机号`,

aaa.unionid as `unionid`,

aaa.`支付时间` ,

aaa.item_name as `购买课程`,

aaa.course_Id as `课程id`,

aaa.amount `支付金额`,

aaa.seller_name `所属销售`,

bbb.chapter_name as `学习章节`,

bbb.content_Id as `内容id`,

bbb.`内容类型`,

bbb.study_time as `学习时长`,

bbb.playback_time as `回放时长`

from

(select distinct vo.course_Id, vo.nickname,vo.mobile,vo.unionid,

from_unixtime(vo.pay_time) as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

where vo.amount>2000 and vo.status=2 and vo.unionid is not null

and from_unixtime(vo.pay_time)>'2020-09-01 00:00:00' and from_unixtime(vo.pay_time) is not null) aaa

right join

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.study_time,

iii.unionid,

mm.playback_time,

case mm.content_type when 1 then '直播'

when 4 then '作业' when 6 then '资料' end as `内容类型`,

tt.chapter_name

from ods_lps_kkb_cloud_edu.content_study_progress mm

left join

(select distinct ss.uid,uu.unionid

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

where mm.content_type in ('1','4','6')) bbb

on aaa.unionid=bbb.unionid and aaa.new_course_id=bbb.course_id

where aaa.`支付时间` is not null

# 2、查询课程学员到课率、完课率-孙志岗(常用)
select

bbb.content_title as `内容名称`,

aaa.`报名人数`,

bbb.`到课学员总数`,

bbb.`完课学员总数`,

bbb.`到课学员总数`/aaa.`报名人数` as `到课率`,

bbb.`完课学员总数`/aaa.`报名人数` as `完课率`

from

(select vc.new_course_Id,count(vo.out_order_id) as `报名人数`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc on vo.course_id=vc.course_Id

where vo.status=2 and vo.course_id=1849

group by vc.new_course_Id) aaa

left join

(select

c.course_Id,

c.content_title,

count(csp.student_uid) as `到课学员总数`,

sum(case when  csp.study_time>'2400' then 1 else 0 end ) as `完课学员总数`

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_lps_kkb_cloud_edu.content c on c.content_id=csp.content_id

left join ods_lps_kkb_cloud_passport.user u on u.uid=csp.student_uid

where c.course_Id='212337'

group by c.content_title,c.course_id

) bbb on aaa.new_course_Id=bbb.course_Id

# 3、查询课程学员评分&评价-程申林
select ce.course_id,ce.chapter_id,cc.chapter_name as `章节名称`,ce.score as `学员评分`,ce.content as `学员评价`

from ods_lps_kkb_cloud_tss.course_evaluate ce

left join ods_lps_kkb_cloud_edu.chapter cc on cc.chapter_id=ce.chapter_Id

where ce.course_id in

('211826',

'212061',

'211447',

'211452')

order by ce.course_id,ce.chapter_id

# 4、查询平台直播的平均观看时长-景奇
select

aaa.oper_id,

bbb.`时长`,

aaa.`人数`

from

(select oper_id, count(distinct(user_Id)) as `人数`

from ods_lps_kkb_live.class_user

where oper_id='oper-840577696268288'

group by oper_id) aaa

left join

(select oper_Id, sum(online) as `时长`

from ods_lps_kkb_live.class_user

where oper_id='oper-840577696268288'

group by oper_Id) bbb

on aaa.oper_id=bbb.oper_Id


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

# 6、查询课程学员创建订单与支付时间差
select ss.name  学科,

FROM_UNIXTIME(vo.pay_time)支付时间,FROM_UNIXTIME(vo.create_time)创建时间,

round((UNIX_TIMESTAMP(FROM_UNIXTIME(vo.pay_time)) - UNIX_TIMESTAMP(FROM_UNIXTIME(vo.create_time)))/60,2) as 分钟差,

round((UNIX_TIMESTAMP(FROM_UNIXTIME(vo.pay_time)) - UNIX_TIMESTAMP(FROM_UNIXTIME(vo.create_time))),2) as 秒差

from vip_order vo

left join vip_channel vc on vo.channel_code=vc.code

left join vip_course vco on vco.id=vo.course_Id

left join `kkb-cloud-account`.sys_subject ss on ss.id=vco.subject_id

where

vo.status=2

and vo.course_id=76

and vo.amount='0.99'

# 7、复购学员学习进度情况-史伟
**#part1**

select

customer_id,

mobile,

nickname,

class_id,

course_id,

pay_time,

amount,

item_name,

seller_name

from dwd.vipcourse_order_f

where seller_name in ('冯宝坤',

'王平',

'尹晓宇',

'刘玲玲',

'赵林明',

'杨官雍',

'金原平',

'李宁',

'高燕',

'霍玲玲',

'孙英俊',

'张艳芬',

'赵静',

'卓莉',

'占佳佳',

'赵德苹',

'张俊博',

'柏默含',

'张海阳',

'刘俊月',

'李欣',

'姜冉',

'周颖',

'耿月',

'张莞青',

'孙方宇',

'李聪敏',

'靳立信',

'杨秀娟',

'李雅琪')

and status=2

and to_data(pay_time)

between '2020-10-01' and '2020-10-31'

**#part2**

select aaa.*,bbb.*

from

(select vo.customer_id,vo.mobile,vo.nickname,vo.course_Id,vo.pay_time,vo.item_name,vo.seller_name,vc.subject_name,vc.bussiness_name,

vcc.formal,

vcc.talent_service,

vcc.scholarship,

vcc.excellent,

vcc.training_camp

from  dwd.vipcourse_order_f vo

left join  dim.dim_order_course vc on vo.course_id=vc.id

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vcc on vcc.id=vo.course_Id

where to_date(vo.pay_time) <'2020-10-01' and vo.status=2 and vo.amount>800 ) aaa

left join

(select ff.customer_id,ff.course_id,ff.progress,ff.fineshed_at,vc.course_id as `kechengid`,vc.new_course_name

from dwd.edu_study_course_progress_f  ff

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on ff.course_Id=vc.new_course_Id) bbb on bbb.`kechengid`=aaa.course_id

and bbb.customer_id=aaa.customer_id

where aaa.customer_id in ()

8、小课体验课学情-胡玉娇

select  distinct aaa.nickname as `学员昵称`,

aaa.mobile as  `手机号`,

aaa.unionid as `unionid`,

aaa.`支付时间` ,

aaa.item_name as `购买课程`,

aaa.course_Id as `课程id`,

aaa.amount `支付金额`,

aaa.seller_name `所属销售`,

bbb.chapter_name as `学习章节`,

bbb.content_Id as `内容id`,

bbb.`内容类型`,

bbb.study_time as `学习时长`,

bbb.playback_time as `回放时长`

from

(select distinct vo.course_Id, vo.nickname,vo.mobile,vo.unionid,

from_unixtime(vo.pay_time) as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

where vo.course_id=1936 and vo.status=2 ) aaa

left  join

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.study_time,

iii.unionid,

iii.mobile,

mm.playback_time,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业' when 5 then '测验'  when 6 then '资料'

when 9 then '互动剧本' end as `内容类型`,

tt.chapter_name

from (  select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='212457' )mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

where mm.content_type in ('1','3','4','5','6','9')) bbb

on aaa.mobile=bbb.mobile and aaa.new_course_id=bbb.course_id



# 8、DAG数据分析体验课学情-胡玉娇(常用)
select  distinct aaa.nickname as `学员昵称`,

aaa.mobile as  `手机号`,

aaa.unionid as `unionid`,

aaa.`支付时间` ,

aaa.item_name as `购买课程`,

aaa.course_Id as `课程id`,

aaa.amount `支付金额`,

aaa.seller_name `所属销售`,

bbb.chapter_name as `学习章节`,

bbb.content_Id as `内容id`,

bbb.`内容类型`,

bbb.study_time as `学习时长`,

bbb.playback_time as `回放时长`

from

(select distinct vo.course_Id, vo.nickname,vo.mobile,vo.unionid,

from_unixtime(vo.pay_time) as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id

where vo.course_id=1936 and vo.status=2 ) aaa

left  join

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.study_time,

iii.unionid,

iii.mobile,

mm.playback_time,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业' when 5 then '测验'  when 6 then '资料'

when 9 then '互动剧本' end as `内容类型`,

tt.chapter_name

from (  select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='212457' )mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

where mm.content_type in ('1','3','4','5','6','9')) bbb

on aaa.mobile=bbb.mobile and aaa.new_course_id=bbb.course_id

# 9、小间谍-李娟
select aaa.group_md5_id 群id,aaa.wxid 学员id,aaa.chat_time 发言时间,aaa.content 发言内容, bbb.members,bbb.group_name

from

(select group_md5_id,chat_time,wxid,content

from chat_detail

where

group_md5_id in ('Chat_0ad634c87574478a6d6c9019858855f6')

) aaa

left join

(select group_name,owner_id,members,group_md5_id

from group_history

where members!=''

and group_md5_id in ('Chat_0ad634c87574478a6d6c9019858855f6')

)bbb on aaa.group_md5_id=bbb.group_md5_id

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

# 12、注册时间5月后学科订单数-姜渭川
SELECT bbb.name,count(bbb.order_no)

from

(SELECT aaa.order_no,c.createdat,aaa.name

from

(SELECT vo.order_no,vo.amount,ss.name

from dwd.vipcourse_order_f vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vc

on vo.course_id=vc.id

left join ods_oldmos_kkb_cloud_account.sys_subject ss

on vc.subject_id=ss.id

WHERE vo.status=2) aaa

left join

ods_mos_cc_deal_deal.deal de

on aaa.order_no=de.orderno

left join ods_mos_cc_deal.customer ca

on de.customerid=c.id

WHERE c.createdat BETWEEN '2020-05-01 00:00:00' and '2020-11-19 23:59:59'

) bbb

GROUP BY bbb.name


# 13、5月后各价格区间数量-姜渭川
```sql
    SELECT 
    case when 0<=aaa.money and aaa.money<1000 then '0-1000' 
    when 1000<=aaa.money and aaa.money<3000 then '1000-3000'
    when 3000<=aaa.money and aaa.money<6000 then '3000-6000'
    when 6000<=aaa.money and aaa.money<9000 then '6000-9000'
    when 9000<=aaa.money and aaa.money<15000 then '9000-15000'
    when 15000<=aaa.money then '15000以上'
    end `价格区间`,
    count(aaa.user_id) as `学员人数`
  
    from
   
   (select user_id,sum(amount) as `money`
   from ods_oldmos_kkb_cloud_vipcourse.vip_order 
   where status=2 
   and from_unixtime(pay_time) >'2020-05-01 00:00:00'
   group by user_id ) aaa
   
   group by 
    case when 0<=aaa.money and aaa.money<1000 then '0-1000' 
    when 1000<=aaa.money and aaa.money<3000 then '1000-3000'
    when 3000<=aaa.money and aaa.money<6000 then '3000-6000'
    when 6000<=aaa.money and aaa.money<9000 then '6000-9000'
    when 9000<=aaa.money and aaa.money<15000 then '9000-15000'
    when 15000<=aaa.money then '15000以上'
    end
```
# 14、各业务线平均到课&作业&资料率-迟慧
select distinct

aaa.mobile,

aaa.bussiness_name,

bbb.course_Id,

bbb.content_Id,

bbb.content_type

from

(select vo.mobile,vc.bussiness_name,vcc.new_course_Id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vc on vo.course_Id=vc.id

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vcc on vcc.course_Id=vo.course_Id

where vo.status=2 and  FROM_UNIXTIME(vo.pay_time)>'2020-08-23 00:00:00'

and vc.bussiness_name is not null and vo.mobile is not null

order by bussiness_name) aaa

left join

(select u.mobile,cc.content_type,cc.course_Id,cc.content_id

from ods_lps_kkb_cloud_edu.content_study_progress cc

left join ods_lps_kkb_cloud_passport.user u on u.uid=cc.student_uid

where cc.content_type in ('4') and u.mobile is not null and cc.created_at>'2020-08-23 00:00:00')bbb on aaa.mobile=bbb.mobile and aaa.new_course_id=bbb.course_Id

where bbb.content_type is not null


# 15、各学科评分平均-迟慧
select

aaa.mobile as  `手机号`,

aaa.unionid as `unionid`,

aaa.bussiness_name as `业务线`,

aaa.course_Id as `课程id`,

bbb.score as `评分`

from

(select distinct vo.course_Id, vo.mobile,vo.unionid,vc.new_course_id,vcc.bussiness_name

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc on vo.course_Id=vc.course_Id

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vcc on vcc.id=vo.course_Id

where vo.amount>2000 and vo.status=2 and vo.unionid is not null

and from_unixtime(vo.pay_time)>'2020-08-23 00:00:00' and from_unixtime(vo.pay_time) is not null) aaa

left join

(select ce.uid,ce.score,ce.course_id,uu.unionid

from ods_lps_kkb_cloud_tss.course_evaluate ce

left join

(select distinct uid,unionid from   ods_lps_kkb_cloud_passport.user_wechat_map)

uu on ce.uid=uu.uid) bbb

on bbb.course_Id=aaa.new_course_id and bbb.unionid=aaa.unionid

# 16、交叉学科购买情况-姜渭川
select

pay_subject_name as `学科`,

pay_course_name as `课程`,

count(*)

from temp.user_portrait_pro1

where pay_subject_name in ('Python小课 , 数据中课',

'Python小课 , 数据大课',

'Python小课 , PM',

'PM , 数据大课',

'Python小课 , Web',

'Java , Web',

'数据大课 , PM',

'Python小课 , Java',

'Python小课 , AI',

'Python小课 , 新职课C++')

group by pay_subject_name,pay_course_name

order by pay_subject_name,pay_course_name


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

# 19、查询官网公开课/体验课的创建订单数、下单数、到课数、平均时长-梁紫媛
**（适用于查询单门课，多课存在多对多问题）**

select

aaa.`课程名称`,

aaa.course_id,

-- aaa.new_course_id,

aaa.`课程类型`,

aaa.price as `课程售价`,

sum(bbb.amount) as `成交金额`,

count(aaa.mobile) as `创建订单手机号`,

count(bbb.mobile) as `下单手机号`

,count(ddd.mobile) as `到课手机号`

,sum(ddd.study_time) as `到课总时长`

from

(select distinct vo.item_name as `课程名称`,vo.course_id,vcc.new_course_id,

case when vo.course_type=0 then '正价课'

when vo.course_type=1 then '体验课'

when vo.course_type=2 then '公开课'

when vo.course_type=3 then '新公开课'

else '未知' end `课程类型`,

vo.price ,vo.mobile

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vc on vo.channel_code=vc.code

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vcc on vcc.course_Id=vo.course_id

where vc.source_type=1 and vo.order_create_time>'2020-10-01 00:00:00'

and vcc.new_course_Id in ()

) aaa

left join

(select distinct vo.item_name as `课程名称`,vo.mobile,vo.amount,vcc.new_course_id,vo.course_Id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vc on vo.channel_code=vc.code

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vcc on vcc.course_Id=vo.course_id

where vc.source_type=1 and vo.status=2  and vo.order_pay_time>'2020-10-01 00:00:00'

and vcc.new_course_Id in ()

) bbb on aaa.mobile=bbb.mobile and aaa.course_id=bbb.course_Id

left join

(select distinct uuu.mobile,ccc.course_id,ccc.study_time

from ods_lps_kkb_cloud_edu.content_study_progress ccc

left join ods_lps_kkb_cloud_passport.user uuu

on uuu.uid=ccc.student_uid

where  ccc.course_Id in ()

) ddd

on ddd.mobile=aaa.mobile and ddd.course_Id=bbb.new_course_id

where aaa.`课程类型` in ('公开课','新公开课','体验课')

group by

aaa.`课程名称`,

-- aaa.new_course_id,

aaa.`课程类型`,

aaa.price,

aaa.course_id

# 20、各学科职业目的占比情况
SELECT c.`学习目的`,count(1)

FROM

(

SELECT b.title,a.*

,CASE

WHEN a.answer like '%提升%' or a.answer like '%提高%' or a.answer like '%求职%' or a.answer like '%工作%' THEN '能力提升'

WHEN a.answer like '%兼职%' or a.answer like '%外快%' THEN '兼职'

WHEN a.answer like '%转行%' THEN '转行'

WHEN a.answer like '%兴趣%' or a.answer like '%爱好%' or a.answer like '%学术%' or a.answer like '%研究%' or a.answer like '%知识%'  THEN '个人兴趣'

ELSE '其他'

END as `学习目的`

FROM

(

SELECT *

FROM ods_lps_kkb_tes_form.fo_form_submit_content

WHERE form_id IN (133,157,218,314,152,45,137,211,213,349,214,132,210,129,128,209,176,319,296,353,297,290,289,375,299,265,374,377,318,370,376,351,352,264,448,345,292,291,468,295,344,450,346,489,262,263,507,451,488,388,391)

) a

JOIN (

SELECT *

FROM ods_lps_kkb_tes_form.fo_form_content

WHERE id IN (1064,1241,1718,3445,1218,377,1087,1660,1681,4140,1693,1055,1639,1044,1038,1630,1401,3547,3009,4248,3036,2812,2768,4660,3072,2352,4633,4714,3528,4554,4687,4194,4221,2328,6005,4076,2887,2854,6351,2982,4049,6059,4103,6608,2282,2305,6832,6086,6581,4930,4967)

) b on a.form_content_id = b.id

) c

GROUP BY c.`学习目的`


# 21、低价正价课2175学情数据-赵中源
--003期 213088

select

fff.`购买课程` as `课程名称`,

--fff.`课程id` as `课程id`,

fff.`期` as `期数`,

case when fff.`学习章节` = "职业认知篇" then "第1章"

when fff.`学习章节` = "价值创造篇" then "第2章"

when fff.`学习章节` = "领导关系篇" then "第3章"

when fff.`学习章节` = "升职加薪篇" then "第4章"

when fff.`学习章节` = "直播答疑" then "直播答疑"

when fff.`学习章节` = "开营仪式" then "开营仪式"

end as `学习章节`,

fff.`内容类型` as `内容类型`,

fff.`内容名称` as `内容名称`,

eee.`订单数` as `上课人数`,

--fff.`到页人数` as `到页人数`,

fff.`到课人数` as `到课人数`,

fff.`完课人数` as `完课人数`,

case when fff.`内容类型` = "作业" then 0 else round(fff.`平均学习时长`/60,2) end as `平均学习时长(分)`,

fff.`提交作业人数` as `提交作业人数`

from

(select

ccc.`购买课程`,

ccc.`课程id`,

-- ccc.`班次id`,

ccc.`期`,

ccc.`学习章节`,ccc.`内容名称`,ccc.`内容id`,

ccc.`内容类型`,

count(ccc.`内容id`) as `到页人数`,

sum(case when ccc.`学习时长`>='300' then 1 else 0 end) as `到课人数`,

sum(case when ccc.`学习时长`>='1200' then 1 else 0 end ) as `完课人数`,

sum(ccc.`学习时长`)/count(ccc.`内容id`) as `平均学习时长`,

count(ccc.uid) as `提交作业人数`

from

(select distinct aaa.nickname as `学员昵称`,

bbb.student_uid,

aaa.mobile as  `手机号`,

aaa.unionid as `unionid`,

aaa.`支付时间` ,

aaa.item_name as `购买课程`,

aaa.item_sku_name as `期`,

aaa.course_Id as `课程id`,

aaa.class_id as `班次id`,

aaa.amount `支付金额`,

aaa.seller_name `所属销售`,

bbb.chapter_name as `学习章节`,

bbb.content_Id as `内容id`,

bbb.content_title as `内容名称`,

bbb.`内容类型`,

bbb.study_time as `学习时长`,

bbb.playback_time as `回放时长`,

sh.uid

from

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.study_time,

iii.unionid,

iii.mobile,

mm.playback_time,

ee.content_title,

case mm.content_type when 16 then '直播'  when 3 then '点播'

when 4 then '作业' when 5 then '测验'  when 6 then '资料'

when 9 then '互动剧本' end as `内容类型`,

tt.chapter_name

from (  select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='213088' and content_type in ('16','3','4'))mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_lps_kkb_cloud_edu.content ee on ee.content_id=mm.content_Id

where mm.content_type in ('16','3','4','5','6','9')) bbb

left join

(select distinct vo.course_Id, vo.nickname,vo.mobile,vo.unionid,class_Id,item_sku_name,

from_unixtime(vo.pay_time) as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id

where vo.course_id = '2175' and vo.status = '2' and vo.class_id = '3771') aaa

on aaa.mobile=bbb.mobile

and aaa.new_course_id=bbb.course_id

left join ods_lps_kkb_cloud_edu.student_homework sh

on sh.uid = bbb.student_uid

--and sh.course_id = aaa.new_course_id

and sh.content_id = bbb.content_id

where aaa.mobile is not null) ccc

group by

ccc.`购买课程`,

ccc.`课程id`,

-- ccc.`班次id`,

ccc.`期`,

ccc.`学习章节`,

ccc.`内容名称`,

ccc.`内容id`,

ccc.`内容类型`

) fff

left join

(select course_id,count(out_order_id) as `订单数`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where course_id = '2175' and status = '2' and class_id = '3771'

group by course_Id) eee  on eee.course_id=fff.`课程id`


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

# 24、模块课在线学习时间分布情况-景琦
select to_date(lb.created_at) as `日期`,

case hour(lb.created_at) when 0 then '0-1点学习'

when 1 then '1-2点学习'

when 2 then '2-3点学习'

when 3 then '3-4点学习'

when 4 then '4-5点学习'

when 5 then '5-6点学习'

when 6 then '6-7点学习'

when 7 then '7-8点学习'

when 8 then '8-9点学习'

when 9 then '9-10点学习'

when 10 then '10-11点学习'

when 11 then '11-12点学习'

when 12 then '12-13点学习'

when 13 then '13-14点学习'

when 14 then '14-15点学习'

when 15 then '15-16点学习'

when 16 then '16-17点学习'

when 17 then '17-18点学习'

when 18 then '18-19点学习'

when 19 then '19-20点学习'

when 20 then '20-21点学习'

when 21 then '21-22点学习'

when 22 then '22-23点学习'

when 23 then '23-24点学习'

end as `学习时间段`,

count(distinct lb.customer_id) as `学习人数`

from dwd.fct_user_portrait_learning_behavior lb

where lb.course_id = '212747'

group by to_date(lb.created_at),hour(lb.created_at)

order by `日期` desc, `学习时间段` asc

# 25、模块课PV、UV统计-景琦
select lb.course_id as `课程id`,

to_date(lb.created_at) as `时间`,

count(lb.customer_id) as `PV`,

count(distinct lb.customer_id) as `UV`

from dwd.fct_user_portrait_learning_behavior lb

where lb.course_id in (

'212747',

'212804',

'212800',

'212831',

'212927')

group by lb.course_id,to_date(lb.created_at)

order by `时间` asc

# 26、低价正价课2175学情数据-赵中源(核对)
select distinct b.uid,b.mobile,b.course_id,b.class_id,b.new_course_id,

csp.content_id,csp.content_type,csp.progress

from

(select distinct a.uid,a.mobile,a.course_id,a.class_id,vc.new_course_id

from

(select distinct u.uid,u.mobile,vo.course_id,vo.class_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_lps_kkb_cloud_passport.user u

on vo.mobile = u.mobile

where vo.course_id = '2175' and vo.class_id = '3612' and vo.status = '2') a

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

on a.course_id = vc.course_id and a.class_id = vc.id) b

left join ods_lps_kkb_cloud_edu.content_study_progress csp

on b.new_course_id = csp.course_id and b.uid = csp.student_uid

where csp.content_id is not null

# 27、模块课到课、完课情况统计(需求3)-景琦
--212747

select csp.content_id,csp.content_type,c.content_title,

count(csp.content_id) as `到课人数`,b.`购课人数` as `购课人数`,

round(count(csp.content_id)/b.`购课人数`, 4) as `到课率`

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_lps_kkb_cloud_edu.content c

on c.content_id = csp.content_id

left join

(select count(*) as `购课人数` from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.course_id = 2126 and vo.class_id = 3482) b

where csp.course_id = '212747'

and csp.content_id in ('284467','284478','285254','285689','285256','285260')

group by csp.content_id,csp.content_type,c.content_title,b.`购课人数`

order by `到课人数` desc,csp.content_id

--212800

select csp.content_id,csp.content_type,c.content_title,

count(csp.content_id) as `到课人数`,b.`购课人数` as `购课人数`,

round(count(csp.content_id)/b.`购课人数`, 4) as `到课率`

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_lps_kkb_cloud_edu.content c

on c.content_id = csp.content_id

left join

(select count(*) as `购课人数` from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.course_id = 2145 and vo.class_id = 3545) b

where csp.course_id = '212800'

and csp.content_id in ('288055','288469','288153','288251','288590','288617')

group by csp.content_id,csp.content_type,c.content_title,b.`购课人数`

order by `到课人数` desc,csp.content_id

--212927

select csp.content_id,csp.content_type,c.content_title,

count(csp.content_id) as `到课人数`,b.`购课人数` as `购课人数`,

round(count(csp.content_id)/b.`购课人数`, 4) as `到课率`

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_lps_kkb_cloud_edu.content c

on c.content_id = csp.content_id

left join

(select count(*) as `购课人数` from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.course_id = 2219 and vo.class_id = 3668) b

where csp.course_id = '212927'

group by csp.content_id,csp.content_type,c.content_title,b.`购课人数`

order by csp.content_id

# 28、官网公开课
select

aaa.course_id,

aaa.channel_code,

aaa.seller_name,

aaa.uv,

aaa.source_type,

aaa.name,

aaa.`直播结束时间`,

count(bbb.out_order_id),

count(ccc.out_order_id)


from

(

select

distinct

vo.course_id,

vo.channel_code,

vo.out_order_id,

vo.seller_name,

vch.uv,

vch.source_type,

vch.name,

from_unixtime(ll.real_end_time) as `直播结束时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vch

on vo.channel_code = vch.code

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

on vo.course_id = vc.course_id

left join ods_lps_kkb_cloud_edu.live_lesson ll

on ll.course_id = vc.new_course_id

where vo.course_id in ('2263','2244','2248','2235','2232','2196','2236','2222','2221','2179',

'2177','2171','2159','2158','2135','2127','2125','2122','2073','2071','2067','2061','2013',

'2012','2033','2011','2027','2008','1974','1973','1968','1960','1948','1939','1883','1915',

'1878','1870','1864','1841','1842','1859','1843','1838')

and from_unixtime(ll.real_end_time) >= "2020-10-01 00:00:00") aaa

left join

(select out_order_id, mobile,user_Id,from_unixtime(pay_time) as `支付时间`,channel_code

from ods_oldmos_kkb_cloud_vipcourse.vip_order where status=2

and  course_id in ('2263','2244','2248','2235','2232','2196','2236','2222','2221','2179',

'2177','2171','2159','2158','2135','2127','2125','2122','2073','2071','2067','2061','2013',

'2012','2033','2011','2027','2008','1974','1973','1968','1960','1948','1939','1883','1915',

'1878','1870','1864','1841','1842','1859','1843','1838'))bbb

on aaa.channel_code=bbb.channel_code

left join

(select out_order_id, mobile,user_Id

from ods_oldmos_kkb_cloud_vipcourse.vip_order where status=2 and amount>2000 and from_unixtime(pay_time)>'2020-10-01 00:00:00') ccc

on ccc.mobile=bbb.mobile



group by

aaa.course_id,

aaa.channel_code,

aaa.seller_name,

aaa.uv,

aaa.source_type,

aaa.name,

aaa.`直播结束时间`


# 29、奖学金班打卡月报（AI)-周颖
select

mm.course_id,

tt.chapter_name as `章节名称`,

case mm.content_type when 16 then '直播'  when 3 then '点播'

when 4 then '作业' when 5 then '测验'  when 6 then '资料'

when 9 then '互动剧本' end as `内容类型`,

ten.`内容名称`,

mm.content_id,

mm.student_uid,

ss.nickname as `昵称`,

ddd.`直播开始时间`,

ddd.`回放总时长`,

mm.study_time as `直播观看时长`,

mm.playback_time as `回放观看时长`,

hhh.`提交作业时间`,

ooo.`作业得分`

from (select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='211517' and content_type in ('16','4') )mm

left join

(select distinct  uid,content_id,course_id,to_date(from_unixtime(homework_time)) as `提交作业时间`

from ods_lps_kkb_cloud_edu.student_homework ) hhh

on hhh.content_id=mm.content_id and hhh.uid=mm.student_uid

left join

(select distinct content_id,content_title as `内容名称` from ods_lps_kkb_cloud_edu.content) ten

on ten.content_id=mm.content_id

left join

(select distinct sh.uid,shc.score as `作业得分`,shc.content_id

from ods_lps_kkb_cloud_edu.student_homework_correct shc

left join ods_lps_kkb_cloud_edu.student_homework sh on shc.student_homework_id=sh.id) ooo

on ooo.content_Id=mm.content_id and ooo.uid=mm.student_uid

left join

(select distinct uid,nickname

from  ods_lps_kkb_cloud_passport.`user`) ss

on ss.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt

on tt.chapter_id=mm.chapter_id

left join

(select ll.course_Id,ll.content_id,ll.`直播开始时间`,vl.`回放总时长`

from

(select distinct course_id, content_id,to_date(from_unixtime(real_start_time)) as `直播开始时间` from ods_lps_kkb_cloud_edu.live_lesson) ll

left join

(select content_id,sum(duration) as `回放总时长` from  ods_lps_kkb_cloud_edu.video_lesson group by content_id ) vl

on ll.content_id=vl.content_id

where ll.course_id='211517' and ll.`直播开始时间`!='1970-01-01') ddd

on ddd.content_Id=mm.content_id

order by mm.student_uid,mm.content_id












# 30、体验课带来的成单-中间件
select aaa.channel_code,

count(distinct(aaa.mobile)) as `体验课订单`,

sum(case when  aaa.`公开课支付`<bbb.`正价课支付` then 1 else 0 end) as `正价课订单`

from

(select channel_code,mobile,FROM_UNIXTIME(pay_time) as `公开课支付`

from

vip_order

where status=2

and channel_code in ())aaa

left join

(select mobile,FROM_UNIXTIME(pay_time) as `正价课支付` from vip_order where status=2 and amount>1200) bbb

on aaa.mobile=bbb.mobile

group by aaa.channel_code

# 31、架构匹配-中间件
SELECT distinct sca.mos_uid,su.name 销售姓名,GROUP_CONCAT(DISTINCT(CONCAT_WS('-',sds.name,sd.name)))部门名称

from

`kkb-cloud-account`.sys_corgi_adapter sca

left join `kkb-corgi-upms`.sys_user_dept sud

on sca.learn_uid=sud.user_id

left join `kkb-corgi-upms`.sys_user su

on sca.learn_uid=su.uid

left join `kkb-corgi-upms`.sys_dept sd

on sud.dept_id=sd.dept_id

left join `kkb-corgi-upms`.sys_dept sds

on sd.parent_id=sds.dept_id

where sud.status=1

and sd.status=1

and sds.status=1

group by mos_uid

order by sca.mos_uid


# 32、模块课日报（需求7）-景琦
select distinct ppp.*

from

(

select

ddd.*,

case when ddd.`支付时间`> ttt.`正价支付时间`then '是' else '否' end as `是否购买过大课`,

case when ddd.`支付时间`> ooo.`入库时间` then '否' else '是' end as `是否新学员`

from

(

select  distinct aaa.nickname as `学员昵称`,

aaa.unionid as `unionid`,

aaa.user_id,

aaa.mobile as `手机号`,

aaa.`支付时间` ,

aaa.item_name as `购买课程`,

aaa.course_Id as `课程id`,

aaa.amount `支付金额`,

aaa.seller_name `所属销售`,

bbb.chapter_name as `学习章节`,

bbb.group_name as `小节名`,

bbb.content_Id as `内容id`,

bbb.`内容类型`,

bbb.study_time as `学习时长`

from

(select distinct vo.course_Id, vo.nickname,vo.mobile,vo.unionid,user_Id,

from_unixtime(vo.pay_time) as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id

where vo.course_id=2126 and vo.status=2 ) aaa

left  join

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.study_time,

iii.unionid,

iii.mobile,

mm.playback_time,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业' when 5 then '测验'  when 6 then '资料'

when 9 then '互动剧本' when 18 then '探索练习' end as `内容类型`,

tt.chapter_name,

gg.group_name

from (  select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='212747' )mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_lps_kkb_cloud_edu.group gg on gg.group_id=mm.group_id

where mm.content_type in ('1','3','4','5','6','9','18')) bbb

on aaa.mobile=bbb.mobile and aaa.new_course_id=bbb.course_id

)ddd

left join

(select distinct mobile ,from_unixtime(pay_time) as `正价支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and amount>5000) ttt

on ddd.`手机号`=ttt.mobile

left join

(select distinct phone,createdat as `入库时间`

from ods_mos_cc_deal.customer) ooo

on ddd.`手机号`=ooo.phone

)ppp


# 33、公开课转化数据（空手机号补充）-顾长领
select

ooo.user_id as `用户id`,

ooo.nickname as `昵称`,

case when bbb.mobile=ooo.`手机号` then '是' else '否' end as `是否到课`,

ccc.item_name as `课程价格`,

ccc.amount as `支付金额`,

ccc.`正价支付时间`

from

(select

aaa.user_id,

aaa.nickname,

aaa.new_course_id,

case when aaa.mobile is null then ggg.mobile else aaa.mobile end as `手机号`

from

(select vo.mobile,vo.user_id,vo.nickname,vc.new_course_id,vo.unionid

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id

where vo.course_id=2012 and vo.status=2) aaa

left join

(select distinct aa.unionid,uu.mobile

from ods_lps_kkb_cloud_passport.user_wechat_map aa

left join ods_lps_kkb_cloud_passport.user uu

on uu.uid=aa.uid

) ggg

on ggg.unionid=aaa.unionid

) ooo

left join

(select

mm.course_Id,

ss.mobile

from

(select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='212593' )mm

left join

(select distinct uid,mobile from ods_lps_kkb_cloud_passport.user) ss

on ss.uid=mm.student_uid

) bbb

on ooo.new_course_Id=bbb.course_Id and ooo.`手机号`=bbb.mobile

left join

(select distinct  vo.mobile,vo.item_name,from_unixtime(vo.pay_time) as `正价支付时间`,vo.amount

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vr on vr.id=vo.course_id

left join ods_oldmos_kkb_cloud_account.sys_subject sv on sv.id=vr.subject_id

where vo.status=2 and sv.name='Web' and vo.amount>2000 and from_unixtime(vo.pay_time) between '2020-11-11 20:00:00' and  '2020-11-12 23:59:59') ccc

on ccc.mobile=ooo.`手机号`


# 34、老公开课裂变数据-丁芳
select

aaa.id,

aaa.`公开课名称`,

aaa.`公开课时间`,

aaa.`报名数`,

aaa.`到课数`,

bbb.`拉新人数`,

ccc.`新人到课数`

from

(#到课

select

oc.id,

oc.name 公开课名称,

FROM_UNIXTIME(oc.`schedule`) 公开课时间,

oc.signup_count 报名数,

sum(case when occ.`live_duration`>0 then 1 else 0 end) 到课数

from open_course oc

left join open_course_student occ on oc.id=occ.open_course_id

where oc.signup_count >0

group by

oc.name ,

oc.id,

FROM_UNIXTIME(oc.`schedule`),

oc.signup_count) aaa

left join

(#拉新

select

oc.id,

oc.name 公开课名称,

FROM_UNIXTIME(oc.`schedule`) 公开课时间,

oc.signup_count 报名数,

count(occ.social_id) as `拉新人数`

from open_course oc

left join open_course_student occ on oc.id=occ.open_course_id

where oc.signup_count >0

and occ.parent_social_id is not null

group by

oc.name ,

oc.id,

FROM_UNIXTIME(oc.`schedule`),

oc.signup_count)bbb on aaa.id=bbb.id

left join

(#新人到课

select

oc.id,

oc.name 公开课名称,

FROM_UNIXTIME(oc.`schedule`) 公开课时间,

oc.signup_count 报名数,

sum(case when occ.`live_duration`>0 then 1 else 0 end) 新人到课数

from open_course oc

left join open_course_student occ on oc.id=occ.open_course_id

where oc.signup_count >0

and occ.parent_social_id is not null

group by

oc.name ,

oc.id,

FROM_UNIXTIME(oc.`schedule`),

oc.signup_count)ccc on aaa.id=ccc.id



# 35、DTG学科直播数据-欧老师
select

concat("learn.kaikeba.com/video/",aaaa.content_id) as `lps直播回放链接`,

aaaa.course_id as `new_course_id`,

case

when aaaa.course_id = "212735" then "数据挖掘工程师实战004期"

when aaaa.course_id = "212911" then "企业级任务型对话机器人【2，3】"

when aaaa.course_id = "213060" then "基础能力强化课程"

when aaaa.course_id = "213061" then "核心能力提升课程"

when aaaa.course_id = "213182" then "遮挡状态下的活体人脸身份识别【4,5,6】"

when aaaa.course_id = "213183" then "企业级任务型对话机器人【4,5,6】"

when aaaa.course_id = "213184" then "资金流入流出预测【4,5,6】"

else aaaa.new_course_name  end as `lps课程`,

aaaa.chapter_name as `章`,

bbbb.group_name as `节`,

aaaa.content_id as `content_id`,

--aaaa.content_type,

eeee.name  as `讲师`,

--aaaa.teacher_uid,

aaaa.`权限学员数` as `权限学员数`,

aaaa.`直播应开始时间` as `直播应开始时间`,

aaaa.`直播应结束时间` as `直播应结束时间`,

aaaa.`课程应上时长(分)` as `课程应上时长(分)`,

aaaa.`直播实际开始时间` as `直播实际开始时间`,

aaaa.`直播实际结束时间` as `直播实际结束时间`,

aaaa.`实际上课时长(分)` as `实际上课时长(分)`,

cccc.`在线峰值人数` as `在线峰值人数`,

bbbb.`直播完课人数` as `直播完课人数`,

--bbbb.`回放完课人数` as `回放完课人数`,

concat(round(bbbb.`直播完课人数`/aaaa.`权限学员数`*100,2),"%") as `直播完课率`,

concat(round(bbbb.`回放完课人数`/aaaa.`权限学员数`*100,2),"%") as `回放完课率`

from

(select

a.course_id,a.new_course_name,a.chapter_name,a.content_id,a.content_type,

b.`权限学员数`,

c.`直播应开始时间`,c.`直播应结束时间`,c.`直播实际开始时间`,c.`直播实际结束时间`,

c.`实际上课时长(分)`,c.`课程应上时长(分)`,c.teacher_uid

--d.`在线人数峰值`

from(select distinct vc.new_course_name,co.course_id,

ch.chapter_name,co.content_id,co.content_title,co.content_type

from ods_lps_kkb_cloud_edu.content co

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

on vc.new_course_id = co.course_id

left join ods_lps_kkb_cloud_edu.chapter ch

on co.chapter_id = ch.chapter_id

where co.course_id in (

'213182','213061','212911','212684','213183','213060','212796','212388','212793',

'213184','212651','212735','212728','212586','212934','212856','212928','212933',

'212559','212738','212766','212768','212813','212814')

and co.content_type in ('1','7','16')

)a

left join

(select cs.course_id,count(cs.student_uid) as `权限学员数` from

ods_lps_kkb_cloud_edu.course_student cs

group by cs.course_id

)b

on a.course_id = b.course_id

left join(

select ll.course_id,ll.content_id,ll.teacher_uid,

ll.`直播应开始时间`,ll.`直播应结束时间`,ll.`直播实际开始时间`,ll.`直播实际结束时间`,

ll.`实际上课时长(分)`,vl.`课程应上时长(分)`

from

(select

distinct course_id, content_id,teacher_uid,

from_unixtime(start_time) as `直播应开始时间`,

from_unixtime(end_time) as `直播应结束时间`,

from_unixtime(real_start_time) as `直播实际开始时间` ,

from_unixtime(real_end_time) as `直播实际结束时间` ,

round((unix_timestamp(from_unixtime(real_end_time))-unix_timestamp(from_unixtime(real_start_time)))/60,2) as `实际上课时长(分)`

from ods_lps_kkb_cloud_edu.live_lesson) ll

left join

(select content_id,round(sum(duration)/60,2) as `课程应上时长(分)`

from  ods_lps_kkb_cloud_edu.video_lesson group by content_id ) vl

on ll.content_id=vl.content_id

where date(ll.`直播实际开始时间`) != "1970-01-01"

)c

on a.content_id = c.content_id

)aaaa

left join

(select aaa.group_name,aaa.content_id,

--aaa.content_type,

sum(aaa.`直播是否完课`) as `直播完课人数`,

sum(aaa.`回放是否完课`) as `回放完课人数`

from

(select

l.group_name,l.content_id,l.content_type,l.student_uid,

l.`直播学习时长` as `直播观看时长`,l.playback_time as `回放观看时长`,p.`课程应上时长`,

--l.study_time/p.`课程应上时长` as `直播观看进度`,

--l.playback_time/p.`课程应上时长` as `回放观看进度`,

case when l.`直播学习时长`/p.`课程应上时长`>=0.6 then 1 else 0 end as `直播是否完课`,

case when l.playback_time/p.`课程应上时长`>=0.6 then 1 else 0 end as `回放是否完课`

from

(select csp.content_id,g.group_name,csp.student_uid,

csp.study_time - csp.playback_time as `直播学习时长`,

csp.playback_time,csp.content_type

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_lps_kkb_cloud_edu.`group` g

on csp.section_id = g.section_id

where csp.course_id in (

'213182','213061','212911','212684','213183','213060','212796','212388','212793',

'213184','212651','212735','212728','212586','212934','212856','212928','212933',

'212559','212738','212766','212768','212813','212814')

and csp.content_type in ('1','7','16')) l

left join

(select content_id,sum(duration) as `课程应上时长`

from  ods_lps_kkb_cloud_edu.video_lesson group by content_id) p

on l.content_id = p.content_id)aaa

group by aaa.group_name,aaa.content_id

--,aaa.content_type)

)bbbb

on aaaa.content_id = bbbb.content_id

left join

(select cp.class_id,max(cp.count) as `在线峰值人数`

from ods_lps_kkb_live.class_point cp

group by cp.class_id

)cccc

on aaaa.content_id = cccc.class_id

left join

(select u.uid,u.mobile,ocsf.name

from ods_lps_kkb_cloud_passport.user u

left join dwd.org_corgi_staff_f ocsf

on u.mobile = ocsf.mobile

) eeee

on aaaa.teacher_uid = eeee.uid


# 36、DTG学科直播数据核对-欧老师
--live_lesson

select *,from_unixtime(ll.end_time),from_unixtime(ll.real_end_time),from_unixtime(ll.real_start_time),

from_unixtime(ll.start_time),ll.callback_info

from

ods_lps_kkb_cloud_edu.live_lesson ll

where ll.content_id in (

'291664','292295','293636','294055','296342','297320','291667','294054','290130',

'294079','288668','293843','292068','296008','296907','295985','297108','296633',

'297554','293810','296417','297340','292625','293799','296936','297371','297455',

'287968','288732','289636','290259','291279','292069','286661','297191','294598',

'297643','294660','297143','296960','297520','292330','293754','292597','294064',

'296945','297091','293746','296521','297558','297650')

and date(from_unixtime(ll.real_start_time)) != "1970-01-01"

--抽查学员学习记录

select csp.content_id,csp.content_type,csp.student_uid,

case when csp.content_type = '7' then 0 else csp.study_time end as `直播学习时长`,

csp.playback_time,vl.duration

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_lps_kkb_cloud_edu.video_lesson vl

on csp.content_id = vl.content_id

where csp.content_id = '296008'


# 37、Q4季度官网的营收、新leads量-科长
select

a.mobile,a.`支付时间`,month(a.`支付时间`) as `月份`,a.status,a.amount,a.`课程类型`,a.source_type,

b.`首次支付时间`

from

(select

vo.mobile,from_unixtime(vo.pay_time) as `支付时间`,vo.status,vo.amount,

case vo.course_type when 1 then "体验课" when 3 then "公开课" end as `课程类型`,

vch.source_type

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vch

on vo.channel_id = vch.id

where date(from_unixtime(vo.pay_time)) between "2020-10-01" and "2020-12-31"

and vo.status = '2'

and vch.source_type = '1'

and (vo.course_type = '1' or vo.course_type = '3')

and vo.mobile is not null

)a

left join

(select vo.mobile,min(from_unixtime(vo.pay_time)) as `首次支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.status = '2'

group by vo.mobile

)b

on a.mobile = b.mobile

where a.`支付时间` = b.`首次支付时间`

----------------------------------------------------------

select

vo.mobile,round(vo.amount,2),

from_unixtime(vo.pay_time) as `支付时间`,

month(date(from_unixtime(vo.pay_time))) as `月份`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vch

on vo.channel_id = vch.id

where vo.status = '2'

and date(from_unixtime(vo.pay_time)) between "2020-10-01" and "2020-12-31"

and vch.source_type = '1'

# 38、课程学员开权限&总学分&多单续费行为判断
#开权限-学分

select vvv.course_Id,vvv.`开权限人数`, uuu.`总学分`,

uuu.`总学分`/vvv.`开权限人数` as `完课率`

from

(

select fff.course_Id,

-- fff.student_uid,

-- fff.`总学分`,

-- ddd.`已更新数量`,

sum(fff.`总学分`/ddd.`已更新数量`) as `总学分`

from

(select eee.course_id,eee.student_uid,sum(eee.`学分`) as `总学分`

from

(select bbb.course_id,bbb.content_id,bbb.student_uid,

case when (bbb.study_time-bbb.playback_time)/aaa.`直播总时长`>'0.6' then 1 else 0 end as `学分`

from

(select course_Id,content_id,student_uid,study_time,playback_time

from ods_lps_kkb_cloud_edu.content_study_progress

where course_id in ('213182',

'213061',

'212911',

'212684',

'213183',

'213060',

'212796',

'212388',

'212793',

'213184',

'212651',

'212735',

'212728',

'212586',

'212934',

'212856',

'212928',

'212933',

'212559',

'212738',

'212766',

'212768',

'212813',

'212814'

)and content_type in ('1','16')) bbb

left join

(

select course_id,content_id,sum(duration) as `直播总时长`

from ods_lps_kkb_cloud_edu.video_lesson

where course_id in ('213182',

'213061',

'212911',

'212684',

'213183',

'213060',

'212796',

'212388',

'212793',

'213184',

'212651',

'212735',

'212728',

'212586',

'212934',

'212856',

'212928',

'212933',

'212559',

'212738',

'212766',

'212768',

'212813',

'212814'

)

group by course_id,content_id

) aaa

on bbb.course_Id=aaa.course_id and bbb.content_id=aaa.content_id

) eee

group by eee.course_id,eee.student_uid

)fff

left join

(select ll.course_id,count(*) as `已更新数量`

from ods_lps_kkb_cloud_edu.live_lesson ll

left join ods_lps_kkb_cloud_edu.content c

on ll.content_id=c.content_id

where  ll.course_id in ('213182',

'213061',

'212911',

'212684',

'213183',

'213060',

'212796',

'212388',

'212793',

'213184',

'212651',

'212735',

'212728',

'212586',

'212934',

'212856',

'212928',

'212933',

'212559',

'212738',

'212766',

'212768',

'212813',

'212814')

and ll.status in ('1','2','3') and c.content_title is not null

group by ll.course_id)

ddd

on fff.course_Id=ddd.course_id

group by fff.course_Id

) uuu

right join

(-- #开权限

select course_Id,count(*) as `开权限人数`

from ods_lps_kkb_cloud_edu.course_student

where course_id in  ('213182',

'213061',

'212911',

'212684',

'213183',

'213060',

'212796',

'212388',

'212793',

'213184',

'212651',

'212735',

'212728',

'212586',

'212934',

'212856',

'212928',

'212933',

'212559',

'212738',

'212766',

'212768',

'212813',

'212814')

group by course_Id) vvv

on uuu.course_Id=vvv.course_Id

#判断多单-续费，多单的学习时间长短

select *

from ods_lps_kkb_cloud_edu.content_study_progress

where student_uid in () and course_id in()

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



# 41、官网活动老学员转化-夏季
select

a.unionid,a.`体验课订单编号`,a.`学员昵称`,a.`体验课名称`,a.course_id,a.uid,a.channel_code,

a.mobile,a.`课程类型`,a.`体验课支付时间`,b.`首次支付时间`,

case when a.`体验课支付时间` = b.`首次支付时间` then "新"

else "老" end as `用户类型`,

case when a.new_course_id is not null then a.new_course_id

else 0 end as `new_course_id`,

case when a.study_time is not null then a.study_time

else 0 end as `study_time`,

c.`历史最大学习时长`,

d.out_order_id as `正价课订单编号`,

d.item_name as `正价课名称`,

from_unixtime(d.pay_time) as `正价课支付时间`,

d.amount as `正价课支付金额`

from

(select

vo.unionid,vo.out_order_id as `体验课订单编号`,vo.nickname as `学员昵称`,

vo.item_name as `体验课名称`,vo.course_id,uwm.uid,vo.channel_code,vo.mobile,

case when vo.course_type=0 then '正价课'

when vo.course_type=1 then '体验课'

when vo.course_type=2 then '公开课'

when vo.course_type=3 then '新公开课' end as `课程类型`,

FROM_UNIXTIME(vo.pay_time) as `体验课支付时间`,

vo.pay_time,

m.new_course_id,m.content_id,m.study_time

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join

ods_lps_kkb_cloud_passport.user_wechat_map uwm

on vo.unionid = uwm.unionid

left join (

select vc.new_course_id,vc.course_id,csp.content_id,csp.student_uid,csp.study_time

from ods_oldmos_kkb_cloud_vipcourse.vip_class vc

left join ods_lps_kkb_cloud_edu.content_study_progress csp

on vc.new_course_id = csp.course_id

)m

on vo.course_id = m.course_id and uwm.uid = m.student_uid

WHERE vo.status=2 and (vo.unionid is not null)

and vo.channel_code in (

'iilsg34uqf','9iz2a7rgbr','u06qbr46sl','myn7x931fl',

'igaxmr3bc6','0un3mx5e6w','jalkcyy81i','8s42ym9cio',

'7ara5bnz7b','e38uwyhi8v','9fvirpww6x','52xpqn3m93',

'efzse5nhah','7pfufnwpxi','4qarfyrtex','yi7gxp1dle',

'vj2s2u451y','mm77dpn15h')

)a

left join

(select

vo.mobile,min(FROM_UNIXTIME(vo.pay_time)) as `首次支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.status = '2'

group by vo.mobile) b

on a.mobile = b.mobile

left join

(select

a.student_uid,max(a.`学习时长`) as `历史最大学习时长`

from

(

select s.student_uid,s.course_id,sum(s.study_time) as `学习时长`

from

(select csp.student_uid,csp.course_id,csp.study_time,vco.type

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

on csp.course_id  = vc.new_course_id

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vco

on vc.course_id = vco.id

where vco.type = 1)s

group by s.student_uid,s.course_id

)a

group by a.student_uid

)c

on a.uid = c.student_uid

left join ods_oldmos_kkb_cloud_vipcourse.vip_order d

on (a.mobile = d.mobile)

where a.`体验课支付时间` != b.`首次支付时间`

and (a.pay_time < d.pay_time)

and (d.status = '2')

and (d.amount >= 1000)




# 42、官网新leads明细数据
select

--a.mobile,

a.`支付时间`,month(a.`支付时间`) as `月份`,a.status,a.amount,a.`课程类型`,

a.`课程名称`,a.`学科`,a.source_type,

b.`首次支付时间`,

case when a.`支付时间` = b.`首次支付时间` then "是"

else "否" end as `是否具有价值`

from

(select

vo.mobile,from_unixtime(vo.pay_time) as `支付时间`,vo.status,vo.amount,

case vo.course_type when 1 then "体验课" when 3 then "公开课" end as `课程类型`,

vo.item_name as `课程名称`,ss.name as `学科`,

vch.source_type

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vch

on vo.channel_id = vch.id

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vco

on vo.course_id = vco.id

left join

ods_oldmos_kkb_cloud_account.sys_subject ss

on vco.subject_id = ss.id

where date(from_unixtime(vo.pay_time)) between "2020-06-01" and "2020-12-31"

and vo.status = '2'

and vch.source_type = '1'

and (vo.course_type = '1' or vo.course_type = '3')

and vo.mobile is not null

)a

left join

(select vo.mobile,min(from_unixtime(vo.pay_time)) as `首次支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.status = '2'

group by vo.mobile

)b

on a.mobile = b.mobile



# 43、历史成单学员手机号-谢世康
select distinct ss.name,vo.mobile

from ods_oldmos_kkb_cloud_account.sys_subject ss

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vco

on ss.id = vco.subject_id

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on vco.id = vo.course_id

where vo.status in ('2','4') and ss.id in ('1','33','35')

and (vo.mobile is not null)

and (vo.mobile != '')

and (from_unixtime(vo.pay_time) between "2019-12-01 00:00:00" and "2020-12-31 23:59:59")


# 44、财务nps数据
# --内容评分

select a.`内容评价`,count(a.id) as `人数`

from

(select cf.id,cf.content_score,

case

when cf.content_score between 1 and 3 then "非常差"

when cf.content_score between 4 and 5 then "差"

when cf.content_score between 6 and 8 then "好"

when cf.content_score between 9 and 10 then "非常好"

end as `内容评价`

from ods_lps_kkb_cloud_edu.course_feedback cf

)a

where a.`内容评价` is not null

group by a.`内容评价`


--服务评分

select a.`服务评价`,count(a.id) as `人数`

from

(select cf.id,cf.serve_score,

case

when cf.serve_score between 1 and 3 then "非常差"

when cf.serve_score between 4 and 5 then "差"

when cf.serve_score between 6 and 8 then "好"

when cf.serve_score between 9 and 10 then "非常好"

end as `服务评价`

from ods_lps_kkb_cloud_edu.course_feedback cf

)a

where a.`服务评价` is not null

group by a.`服务评价`


--讲师评价

select a.`讲师评价`,count(a.id) as `人数`

from

(select cf.id,cf.teach_score,

case

when cf.teach_score between 1 and 3 then "非常差"

when cf.teach_score between 4 and 5 then "差"

when cf.teach_score between 6 and 8 then "好"

when cf.teach_score between 9 and 10 then "非常好"

end as `讲师评价`

from ods_lps_kkb_cloud_edu.course_feedback cf

)a

where a.`讲师评价` is not null

group by a.`讲师评价`


--讲师评价tss

select a.`讲师评价`,count(a.id) as `人数`

from

(select ce.id,ce.score,

case

when ce.score between 1 and 3 then "非常差"

when ce.score between 4 and 5 then "差"

when ce.score between 6 and 8 then "好"

when ce.score between 9 and 10 then "非常好"

end as `讲师评价`

from ods_lps_kkb_cloud_tss.course_evaluate ce

)a

where a.`讲师评价` is not null

group by a.`讲师评价`



# 45、微软长线班学员明细数据-孙方宇
select

distinct

vo.mobile,vo.nickname,u.uid,

csp.course_id,csp.chapter_id,ch.chapter_name as `章`,

csp.section_id,g.group_name as `节`,

csp.content_id,c.content_title as `内容`,

case csp.content_type

when '1' then "直播"

when '16' then "直播"

when '3' then "点播"

when '7' then "回放"

when '4' then "作业"

end as `类型`,

case csp.content_type

when '1' then round((csp.study_time-csp.playback_time)/60,2)

when '16' then round((csp.study_time-csp.playback_time)/60,2)

when '3' then round(csp.study_time/60,2)

when '7' then round(csp.playback_time/60,2)

else 0

end as `观看时长/分`,

case csp.content_type

when '1' then round(csp.playback_time/60,2)

when '16' then round(csp.playback_time/60,2)

else 0

end as `回放时长/分`,a.`作业得分`

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_lps_kkb_cloud_edu.chapter ch

on csp.chapter_id = ch.chapter_id

left join ods_lps_kkb_cloud_edu.content c

on csp.content_id = c.content_id

left join ods_lps_kkb_cloud_edu.group g

on csp.section_id = g.section_id

left join ods_lps_kkb_cloud_passport.user u

on csp.student_uid = u.uid

left join ods_oldmos_kkb_cloud_vipcourse.vip_order vo

on u.mobile = vo.mobile

left join

(select distinct sh.uid,shc.score as `作业得分`,shc.content_id

from ods_lps_kkb_cloud_edu.student_homework_correct shc

left join ods_lps_kkb_cloud_edu.student_homework sh on shc.student_homework_id=sh.id)  a

on csp.content_id=a.content_id and a.uid=u.uid

where csp.course_id in ('210766','210765','210764','210780','210878','210943')

and csp.content_type in ('1','3','4','7','16')

and vo.mobile is not null

and csp.content_id is not null

order by csp.course_id,vo.mobile,vo.nickname,csp.content_id


# 46、微软长线班学员聚合数据-孙方宇
select

d.course_Id,d.student_uid,d.`直播学习总时长`,d.`总学分`,d.`已更新数量`,

a.`作业设置总数`,b.`提交作业总数`,

d.`到课率`,d.`完课率`,b.`提交作业总数`/a.`作业设置总数` as `作业完成率`

from

(select

fff.course_Id,

fff.student_uid,

fff.`总学分`,

ddd.`已更新数量`,

fff.`直播学习总时长`,

sum(fff.`总到课`/ddd.`已更新数量`) as `到课率`,

sum(fff.`总学分`/ddd.`已更新数量`) as `完课率`

from

(select eee.course_id,eee.student_uid,sum(eee.`直播学习时长`) as `直播学习总时长`,

sum(eee.`学分`) as `总学分`,sum(eee.`到课`) as `总到课`

from

(select bbb.course_id,bbb.content_id,bbb.student_uid,bbb.`直播学习时长`,

case

when bbb.study_time > '600' then 1 else 0 end as `学分`,

case when bbb.study_time-bbb.playback_time > '600' then 1 else 0 end as `到课`

from

(select course_Id,content_id,student_uid,study_time,playback_time,

study_time-playback_time as `直播学习时长`,content_type

from ods_lps_kkb_cloud_edu.content_study_progress

where course_id in ('210766','210765','210764','210780','210878','210943')

and content_type in ('1','7','16')) bbb

) eee

group by eee.course_id,eee.student_uid

)fff

left join

(select ll.course_id,count(*) as `已更新数量`

from ods_lps_kkb_cloud_edu.live_lesson ll

left join ods_lps_kkb_cloud_edu.content c

on ll.content_id=c.content_id

where  ll.course_id in ('210766','210765','210764','210780','210878','210943')

and ll.status in ('1','2','3') and c.content_title is not null

group by ll.course_id)

ddd

on fff.course_Id=ddd.course_id

group by fff.course_Id,fff.student_uid,fff.`总学分`,ddd.`已更新数量`,fff.`直播学习总时长`

)d

left join

(select csp.student_uid,csp.course_id,csp.content_type,count(csp.content_id) as `提交作业总数`

from ods_lps_kkb_cloud_edu.content_study_progress csp

where csp.content_type = '4' and csp.course_id in ('210766','210765','210764','210780','210878','210943')

group by csp.student_uid,csp.course_id,csp.content_type

)b

on b.course_id = d.course_Id and b.student_uid = d.student_uid

left join

(select

c.course_id,count(c.content_id) as `作业设置总数`

from ods_lps_kkb_cloud_edu.content c

where c.course_id in ('210766','210765','210764','210780','210878','210943')

and c.content_type = '4'

group by c.course_id

)a

on a.course_id = d.course_id

# 47、单纯求一个lps学员的学习情况-沈才武
select

mm.student_uid as `uid`,

iii.nickname as `昵称`,

mm.course_id as `course_id`,

tt.chapter_name as `章`,

gg.group_name as `节`,

nn.content_title as `内容`,

mm.content_id as `内容id`,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业' when 5 then '测验'  when 6 then '资料'

when 9 then '互动剧本'  when 16 then 'hk直播' when 7 then '回放' end as `内容类型`,

mm.created_at as `开始看内容时间`,

mm.study_time-mm.playback_time as `直播观看时间s(作业忽略此项)`,

mm.playback_time as `回放观看时间s(作业忽略此项)`

from

( select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='212844'  and content_type in ('1','3','4','5','6','9','16','7') )mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile,ss.nickname

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_Lps_kkb_cloud_edu.group gg on gg.section_id=mm.section_id

left join ods_lps_kkb_cloud_edu.content nn on nn.content_id=mm.content_id

# 48、米堆学堂直播课学情-王晓慧
（备注：直播课学员学情-首单销售归属-正价转化）

select

aaa.*,

ppp.*,

ooo.*

from


(-- #购买直播的人，转化正价情况

select eee.`直播课名`,eee.`直播课昵称`,eee.`直播课手机号`,eee.user_id,eee.`直播课支付时间`,

qqq.`正价课程名称`,qqq.`成单人`,qqq.`正价支付时间`,qqq.`金额`


from

(

-- eee为买直播课的人

select mobile `直播课手机号`,nickname as `直播课昵称`, user_id, item_name as `直播课名`, from_unixtime(pay_time) as `直播课支付时间`

from  ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and course_id ='2487') eee

left join

-- 分             割               线

(

-- qqq为买正价课的人

select item_name as `正价课程名称`, seller_name as `成单人`, amount as `金额`,

from_unixtime(pay_time) as `正价支付时间`,mobile as `正价课手机号`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and course_id in

('100052',

'100054',

'100057',

'100059',

'100060',

'2371',

'2102',

'2103',

'2104') and mobile is not null) qqq on eee.`直播课手机号`=qqq.`正价课手机号`) aaa



left join

-- 分             割               线

(

-- ppp为学情

select

aaa.student_uid,

ccc.mobile as `上课手机号`,

ccc.unionid,

aaa.`看直播时间`,

aaa.`看回放时间`,

aaa.`开始看内容时间`

from

(select

student_uid,

study_time-playback_time as `看直播时间`

,playback_time as `看回放时间`

,created_at as `开始看内容时间`

from ods_lps_kkb_cloud_edu.content_study_progress

where course_id ='213618') aaa

left join

(select distinct uuu.mobile,uuu.uid,www.unionid

from ods_lps_kkb_cloud_passport.`user` uuu

left join ods_lps_kkb_cloud_passport.user_wechat_map www

on uuu.uid=www.uid) ccc

on aaa.student_uid=ccc.uid

)ppp

on aaa.`直播课手机号`=ppp.`上课手机号`




-- 分             割               线


left join

(select iii.mobile,yyy.`销售`

from

(select mobile, min(from_unixtime(pay_time)) as `最早支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and course_id in ('2040','2178','2364') and mobile is not null

group by mobile) iii

left join

(select mobile,qr_code_seller_name as `销售`,from_unixtime(pay_time) as `支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and course_id in ('2040','2178','2364') and mobile is not null) yyy

on iii.mobile=yyy.mobile and iii.`最早支付时间`=yyy.`支付时间`) ooo

on aaa.`直播课手机号` =ooo.mobile


# 49、打卡功能sql-打卡点得分
-- 学员打卡点得分情况

select

kk.course_id,

kk.course_name as `课程名称`,

cc.name as `打卡计划`,

bb.id as `打卡点id`,

bb.name as `打卡点名称`,

bb.total_credit as `打卡点设置学分`,

aa.user_id,

aa.course_credit as `打卡点已得学分`

from ods_xiaoke_lms_checkin_server.checkin_point_result aa

left join ods_xiaoke_lms_checkin_server.checkin_point bb on aa.checkin_point_id=bb.id

left join ods_xiaoke_lms_checkin_server.checkin_plan cc on cc.id=bb.checkin_plan_id

left join ods_xiaoke_lms_checkin_server.checkin_plan_course kk on kk.checkin_plan_id=cc.id

# 50、打卡功能sql-打卡任务得分
-- 学员打卡任务得分情况

select

ee.course_name as `课程名称`,

ee.course_Id,

dd.name as `打卡计划名称`,

dd.id as `打卡计划id`,

cc.name as `打卡点名称`,

cc.id as `打卡点id`,

aa.checkin_task_id as `打卡任务id`,

bb.course_content_id as `内容id`,

bb.total_credit as `打卡任务设置学分`,

case when bb.type=0 and bb.subtype=0  then '直播'

when bb.type=0 and bb.subtype=1  then '直播或回放'

when bb.type=0 and bb.subtype=2  then '直播加回放'

when  bb.type=1 then '录播'

when  bb.type=2 then '作业'

when  bb.type=3 then '测验' end as `任务类型`,

aa.user_id,

aa.course_credit as `打卡任务已得学分`

from ods_xiaoke_lms_checkin_server.checkin_task_result aa

left join ods_xiaoke_lms_checkin_server.checkin_task bb on aa.checkin_task_id=bb.id

left join ods_xiaoke_lms_checkin_server.checkin_point cc on cc.id=bb.checkin_point_id

left join ods_xiaoke_lms_checkin_server.checkin_plan dd on dd.id=cc.checkin_plan_id

left join ods_xiaoke_lms_checkin_server.checkin_plan_course ee on ee.checkin_plan_id=dd.id

# 51、用体验课投放放的米堆学情0125
select

aaa.*,

ppp.*,

vvv.`激活手机号`

from

(select mobile `直播课手机号`,nickname as `直播课昵称`, user_id, item_name as `直播课名`, from_unixtime(pay_time) as `直播课支付时间`

,qr_code_seller_name as `归属销售`,qr_code_seller_id as `归属销售id`

from  ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and course_id ='2518') aaa


left join

(

select rrr.mobile as `激活手机号`,ggg.course_Id

from  ods_lps_kkb_cloud_edu.course_student ggg

left join

(select distinct uuu.mobile,uuu.uid,www.unionid

from ods_lps_kkb_cloud_passport.`user` uuu

left join ods_lps_kkb_cloud_passport.user_wechat_map www

on uuu.uid=www.uid) rrr

on ggg.student_uid=rrr.uid

where ggg.course_id='213684'

) vvv

on vvv.`激活手机号`=aaa.`直播课手机号`


left join

-- 分             割               线

(

-- ppp为学情

select

aaa.student_uid,

ccc.mobile as `上课手机号`,

ccc.unionid,

aaa.`看直播时间`,

aaa.`看回放时间`

from

(select

student_uid,

study_time-playback_time as `看直播时间`

,playback_time as `看回放时间`

from ods_lps_kkb_cloud_edu.content_study_progress

where course_id ='213684') aaa

left join

(select distinct uuu.mobile,uuu.uid,www.unionid

from ods_lps_kkb_cloud_passport.`user` uuu

left join ods_lps_kkb_cloud_passport.user_wechat_map www

on uuu.uid=www.uid) ccc

on aaa.student_uid=ccc.uid

)ppp

on aaa.`直播课手机号`=ppp.`上课手机号`


# 52、用体验课洗老量的米堆学情0125
select

aaa.`昵称`,aaa.user_id,

ooo.`所属销售`,ooo.`所属销售id`,ooo.`所属销售订单id`,

aaa.`课程名称`,aaa.`支付时间`,

case when aaa.user_id=hhh.student_uid then '是' else '否' end as `是否激活`,

ppp.`内容名称`,ppp.`看直播时间`,ppp.`看回放时间`,ppp.`开始看内容时间`

from

(-- eee为买体验课的人

select mobile `手机号`,nickname as `昵称`, user_id, item_name as `课程名称`, from_unixtime(pay_time) as `支付时间`

from  ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and course_id ='2518') aaa

left join

(select student_uid

from ods_lps_kkb_cloud_edu.course_student

where course_id='213684') hhh on hhh.student_uid=aaa.user_id

left join

-- 分             割               线

(

-- ppp为学情

select

aaa.student_uid,

aaa.content_id,

xcv.content_title as `内容名称`,

ccc.mobile as `上课手机号`,

aaa.`看直播时间`,

aaa.`看回放时间`,

aaa.`开始看内容时间`

from

(select

student_uid,

content_id,

study_time-playback_time as `看直播时间`

,playback_time as `看回放时间`

,created_at as `开始看内容时间`

from ods_lps_kkb_cloud_edu.content_study_progress

where course_id ='213684'

order by content_id

) aaa

left join ods_lps_kkb_cloud_edu.content xcv on xcv.content_Id=aaa.content_id

left join

(select distinct uuu.mobile,uuu.uid,www.unionid

from ods_lps_kkb_cloud_passport.`user` uuu

left join ods_lps_kkb_cloud_passport.user_wechat_map www

on uuu.uid=www.uid) ccc

on aaa.student_uid=ccc.uid

)ppp

on aaa.`手机号`=ppp.`上课手机号`


-- 分             割               线


left join

(select iii.mobile,yyy.`所属销售`,yyy.`所属销售订单id`,yyy.`所属销售id`

from

(select mobile, min(from_unixtime(pay_time)) as `最早支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and course_id in ('2040','2178','2364') and mobile is not null

group by mobile) iii

left join

(select mobile,qr_code_seller_name as `所属销售`,qr_code_seller_id as `所属销售id`,out_order_id as `所属销售订单id`,from_unixtime(pay_time) as `支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where status=2 and course_id in ('2040','2178','2364') and mobile is not null) yyy

on iii.mobile=yyy.mobile and iii.`最早支付时间`=yyy.`支付时间`) ooo

on aaa.`手机号` =ooo.mobile

order by aaa.user_id,ppp.`内容名称`

# 53、学员地域占比-秦星晨
select

aaa.`省份`,

aaa.`学科`,

aaa.`学员数`,

bbb.`学员总数`,

aaa.`学员数`/bbb.`学员总数` as `占比`

from

(select  case when aa.province is not null then aa.province else aa.fromprovince end as `省份`,

ss.name as `学科`, count(aa.id) as `学员数`

from  ods_mos_cc_deal.customer  aa

left join ods_mos_cc_deal_deal.deal bb on aa.id=bb.customerid

left join ods_oldmos_kkb_cloud_vipcourse.vip_course  cc on cc.name=bb.comments

left join ods_oldmos_kkb_cloud_account.sys_subject ss on ss.id=cc.subject_id

where aa.fromprovince is not null and ss.name is not null

group by case when aa.province is not null then aa.province else aa.fromprovince end ,ss.name)  aaa

left join

(select

case when aa.province is not null then aa.province else aa.fromprovince end as `省份`,

count(aa.id) as `学员总数`

from  ods_mos_cc_deal.customer  aa

left join ods_mos_cc_deal_deal.deal bb on aa.id=bb.customerid

left join ods_oldmos_kkb_cloud_vipcourse.vip_course  cc on cc.name=bb.comments

left join ods_oldmos_kkb_cloud_account.sys_subject ss on ss.id=cc.subject_id

where aa.fromprovince is not null and ss.name is not null

group by  case when aa.province is not null then aa.province else aa.fromprovince end) bbb

on

aaa.`省份`=bbb.`省份`


# 54、公开课裂变海报分享情况—韦露雪
select distinct

fff.item_name as `课程名称`,

ddd.nickname as `微信用户昵称`,

aaa.level as `用户等级`,

bbb.`裂变人数` as `裂变人数`,

ccc.`是否到课` as `是否到课` ,

eee.nickname as `直接上级昵称`,

fff.name as `订单渠道名称`,

fff.seller_name as `订单所属销售`

from

(select order_id, uid,parent_uid,level

from ods.ods_kkb_cloud_vipcourse__vip_course_fission_ha

where course_id=2510 and pt=2021012810) aaa



left join



(select  parent_uid, count(uid) as `裂变人数`

from ods.ods_kkb_cloud_vipcourse__vip_course_fission_ha

where course_id=2510  and parent_uid is not null and pt=2021012810

group by  parent_uid) bbb



on aaa.uid=bbb.parent_uid

left join

(select student_uid,

case when student_uid is not null

then "是"

else null

end as `是否到课`

from ods_lps_kkb_cloud_edu.content_study_progress

where course_id=212137) ccc

on aaa.uid=ccc.student_uid

left join

(select uid,nickname

from ods_lps_kkb_cloud_passport.`user`) ddd

on aaa.uid=ddd.uid

left join

(select uid,nickname

from ods_lps_kkb_cloud_passport.`user`) eee

on aaa.parent_uid=eee.uid

left join

(select ord.id,ord.channel_code,ord.seller_name,ord.item_name,cha.name

from ods_oldmos_kkb_cloud_vipcourse.vip_order ord

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel cha

on ord.channel_code=cha.code

where ord.course_id = 2510) fff

on aaa.order_id=fff.id

order by bbb.`裂变人数` desc;


# 55、企业服务学员需求-张秀丽
select

mm.student_uid,

ss.nickname as `昵称`,

mm.course_id,

tt.chapter_name as `章`,

gg.group_name as `节`,

nn.content_title as `内容`,

case mm.content_type when 10 then '练习'  when 3 then '点播'

when 9 then '互动剧本' when 18 then '未知类型' end as `内容类型`,

mm.content_type,

mm.study_time-mm.playback_time as `看直播时长`,

mm.playback_time as `看回放时长`,

mm.created_at as `开始看内容时间`

from (select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='212192' )mm

left join

(select distinct uid,nickname

from  ods_lps_kkb_cloud_passport.user)ss

on ss.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_lps_kkb_cloud_edu.group gg on gg.section_id=mm.section_id

left join ods_lps_kkb_cloud_edu.content nn on nn.content_Id=mm.content_Id

where mm.content_type in ('10','3','9','18')

# 56、官网漏斗之总漏斗
select aaa.`日期`,aaa.`今日活跃用户数`,bbb.`今日公开课详情页`,ddd.`今日公开课详情页已登陆`,ccc.`今日体验课详情页`,eee.`今日体验课详情页已登陆`

from

(select pt as `日期`,count(distinct visituserid)  as `今日活跃用户数`

from

dwd.flw_fct_gio_full_log_di

where action_type = 'view'

group by pt

order by pt desc) aaa

left join

(select pt as `日期`,count(distinct visituserid)  as `今日公开课详情页`

from

dwd.flw_fct_gio_full_log_di

where action_type = 'view'

and url like '%[www.kaikeba.com/open/item%](http://www.kaikeba.com/open/item%?fileGuid=dw9HYtXtKWD9Dgwp)'

group by pt

order by pt desc)bbb

on aaa.`日期`=bbb.`日期`

left join

(select pt as `日期`,count(distinct visituserid)  as `今日体验课详情页`

from

dwd.flw_fct_gio_full_log_di

where action_type = 'view'

and url like '%[www.kaikeba.com/experience/detail%](http://www.kaikeba.com/experience/detail%?fileGuid=dw9HYtXtKWD9Dgwp)'

group by pt

order by pt desc)ccc

on aaa.`日期`=ccc.`日期`

left join

(select pt as `日期`,count(distinct visituserid)  as `今日公开课详情页已登陆`

from

dwd.flw_fct_gio_full_log_di

where action_type = 'view'

and url like '%[www.kaikeba.com/open/item%](http://www.kaikeba.com/open/item%?fileGuid=dw9HYtXtKWD9Dgwp)' and  loginuserId !=''

group by pt

order by pt desc) ddd

on bbb.`日期`=ddd.`日期`

left join

(select pt as `日期`,count(distinct visituserid)  as `今日体验课详情页已登陆`

from

dwd.flw_fct_gio_full_log_di

where action_type = 'view'

and url like '%[www.kaikeba.com/experience/detail%](http://www.kaikeba.com/experience/detail%?fileGuid=dw9HYtXtKWD9Dgwp)' and  loginuserId !=''

group by pt

order by pt desc) eee

on ccc.`日期`=eee.`日期`

# 57、官网漏斗之体验课
-- #体验课转化

select ooo.`日期`,count(ooo.`今日体验课已登陆userid`) as `今日体验课登陆数`

, count(`今日创建订单user_id`) as `今日创建订单数`

,

count(`今日支付订单user_id`) as `今日支付订单数`

,

count(`今日新leads`) as `今日新leads数`

from

(

select mm.`日期`,mm.`今日体验课已登陆userid`,nn.user_id as `今日创建订单user_id`,

ll.user_id as `今日支付订单user_id`,kk.mobile as `今日新leads`

from

(select distinct pt as `日期`,loginuserId as `今日体验课已登陆userid`

from

dwd.flw_fct_gio_full_log_di

where action_type = 'view'

and url like '%[www.kaikeba.com/experience/detail%](http://www.kaikeba.com/experience/detail%?fileGuid=dw9HYtXtKWD9Dgwp)'  and  loginuserId !='' )mm

left join

(select distinct  vo.user_id,

date_format(from_unixtime(vo.create_time) ,'yyyyMMdd') as `订单创建时间`

from

ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vc

on vo.channel_code=vc.code

where vc.source_type=1 and vo.course_type=3 ) nn

on mm.`今日体验课已登陆userid` =nn.user_id  and nn. `订单创建时间`=mm.`日期`

left join

(

select distinct  vo.user_id, vo.mobile,

from_unixtime(vo.pay_time)  as `订单支付时间到s`,

date_format(from_unixtime(vo.pay_time) ,'yyyyMMdd') as `订单支付时间`

from

ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vc

on vo.channel_code=vc.code

where vc.source_type=1 and vo.course_type=3  and vo.status=2

) ll

on nn.user_id =ll.user_id  and nn.`订单创建时间`=ll.`订单支付时间`

left join

(

select vo.mobile,

min(from_unixtime(vo.pay_time)) as `最早日期到s`,

date_format(min(from_unixtime(vo.pay_time)),'yyyyMMdd') as `最早日期`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.status =2

group by vo.mobile

)kk

on kk.mobile=ll.mobile and  kk.`最早日期到s`=ll.`订单支付时间到s`

) ooo

group by ooo.`日期`

# 57、官网漏斗之公开课
-- #公开课转化

select ooo.`日期`,count(ooo.`今日公开课已登陆userid`) as `今日公开课登陆数`

, count(`今日创建订单user_id`) as `今日创建订单数`

,

count(`今日支付订单user_id`) as `今日支付订单数`

,

count(`今日新leads`) as `今日新leads数`

from

(

select mm.`日期`,mm.`今日公开课已登陆userid`,nn.user_id as `今日创建订单user_id`,

ll.user_id as `今日支付订单user_id`,kk.mobile as `今日新leads`

from

(select distinct pt as `日期`,loginuserId as `今日公开课已登陆userid`

from

dwd.flw_fct_gio_full_log_di

where action_type = 'view'

and url like  '%www.kaikeba.com/open/item%'  and  loginuserId !='' )mm

left join

(select distinct  vo.user_id, vo.out_order_Id,

date_format(from_unixtime(vo.create_time) ,'yyyyMMdd') as `订单创建时间`

from

ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vc

on vo.channel_code=vc.code

where vc.source_type=1 and vo.course_type=3 ) nn

on mm.`今日公开课已登陆userid` =nn.user_id  and nn. `订单创建时间`=mm.`日期`

left join

(

select distinct  vo.user_id, vo.mobile,vo.out_order_id,

from_unixtime(vo.pay_time)  as `订单支付时间到s`,

date_format(from_unixtime(vo.pay_time) ,'yyyyMMdd') as `订单支付时间`

from

ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vc

on vo.channel_code=vc.code

where vc.source_type=1 and vo.course_type=3  and vo.status=2

) ll

on nn.user_id =ll.user_id  and nn.`订单创建时间`=ll.`订单支付时间` and nn.out_order_id=ll.out_order_Id

left join

(

select vo.mobile,

min(from_unixtime(vo.pay_time)) as `最早日期到s`,

date_format(min(from_unixtime(vo.pay_time)),'yyyyMMdd') as `最早日期`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.status =2

group by vo.mobile

)kk

on kk.mobile=ll.mobile and  kk.`最早日期到s`=ll.`订单支付时间到s`

) ooo

group by ooo.`日期`




# 58、公开课裂变到课数据对比-刘航
select distinct

ccc.course_id as `课程ID`,

ccc.name as `渠道`,

ccc.code as code,

ccc.pv as pv,

ccc.uv as uv,

-- ddd.channel_code as channel_code,

eee.bao as `报名数`,

ddd.`code对应的到课人数` as `到课数`,

fff.sn as `销售`

from

(

select course_id,name,code,sum(pv) as pv,sum(uv) as uv

from ods_oldmos_kkb_cloud_vipcourse.vip_channel

where course_id in (

'2577',

。。。。。。。kmos商品id。。。。。。)

and name not like "测试"

group by course_id,name,code

) ccc



left join

(

select

aaa.channel_code,

count(distinct(bbb.student_uid)) as `code对应的到课人数`

from

(select vo.channel_code,vo.user_Id,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

on vc.course_Id=vo.course_Id

where vo.status=2

) aaa



left join



(select distinct student_uid,course_id

from ods_lps_kkb_cloud_edu.content_study_progress) bbb

on bbb.student_uid=aaa.user_id

and bbb.course_id=aaa.new_course_Id

group by aaa.channel_code

) ddd



on ccc.code=ddd.channel_code

left join



(

select channel_code,count(channel_code) bao

from ods_oldmos_kkb_cloud_vipcourse.vip_order

group by channel_code

)eee



on ccc.code=eee.channel_code

left join



(

select channel_code,seller_name sn

from ods_oldmos_kkb_cloud_vipcourse.vip_order

) fff

on ccc.code=fff.channel_code


# 59、给班主任BI核对直播到课人数-智慧
select cs.student_uid,mm.uid,cc.student_uid

from ods_lps_kkb_cloud_edu.course_student cs

left join ods_lps_kkb_cloud_edu.manager mm on cs.student_uid=mm.uid

left join ods_lps_kkb_cloud_edu.content_study_progress cc on cc.student_uid=cs.student_uid

where  cc.content_id='252671' and cs.course_id='211698' and mm.uid is null

# 60、NPS班主任汇总
#班班nps，更换id，更换评分类型即可

select uuu.`班班`,uuu.mobile,sum(uuu.`nps总数`),sum(uuu.`1-3`) as `1-3`,sum(uuu.`4-5`) as `4-5`,sum(uuu.`6-8`) as `6-8`,sum(uuu.`9-10`) as `9-10`


from



(

select  ee.course_Id,dd.realname as `班班`,dd.mobile,

ee.`nps总数`,ee.`1-3`,ee.`4-5`,ee.`6-8`,ee.`9-10`

from

(select  course_id

,count(uid) as `nps总数`

-- ,count(case when serve_score = 0  then uid else null end) as `0`

,count(case when teach_score in (1,2,3) then uid else null end) as `1-3`

,count(case when teach_score in (4,5) then uid else null end) as `4-5`

,count(case when teach_score in (6,7,8) then uid else null end) as `6-8`

,count(case when teach_score in (9,10) then uid else null end) as `9-10`

from

(

select

cf.uid            -- 学员id

,cf.course_id     -- 新学习中心id

,cf.content_score -- 课程内容评分

,cf.teach_score   -- 课程讲师评分

,cf.serve_score   -- 课程服务评分  就当成班班评分

,cf.remark        -- 反馈内容



from ods_lps_kkb_cloud_edu.course_feedback cf

-- left join ods_lps_kkb_cloud_edu.course_class_teacher cct on cf.course_id = cct.course_id -- 课程对应的班班id

-- left join ods_lps_kkb_cloud_passport.user u on ll.teacher_uid = u.uid  -- 班班id 对应的 班班手机号

-- left join dwd.org_corgi_staff_f ocsf on u.mobile = ocsf.mobile    -- 班班手机号 对应的班班姓名&架构

-- where created_at = 本月

-- where cf.course_id in   -- 提供的本月开班的课程lpsid

-- (



-- )

)a

group by course_id

) ee


left join

(select bb.course_id,cc.realname,cc.mobile

from

(select course_id ,uid from ods_lps_kkb_cloud_edu.course_class_teacher) bb

left join

(select uid,mobile,realname  from ods_lps_kkb_cloud_edu.manager )cc

on bb.uid=cc.uid) dd

on dd.course_id=ee.course_id) uuu

group by uuu.`班班`,uuu.mobile





# 61、NPS讲师汇总
#讲师nps汇总 换id即可

select

aa2.mobile

,aa2.realname as `讲师姓名`

,count(aa1.uid) `上月nps总数`

-- ,count(aa1.score)

,count(case when aa1.score in (1,2,3) then aa1.uid end) as `1-3分 非常差`

,count(case when aa1.score in (4,5) then aa1.uid end) as `4-5分 差`

,count(case when aa1.score in (6,7,8) then aa1.uid end) as `6-8分 好`

,count(case when aa1.score in (9,10) then aa1.uid end) as `9-10分 非常好`

from

(

select

ce.uid  ,ce.score  ,ce.section_id  ,ll.teacher_uid  -- ,ce.created_at

from

(

select

uid   ,section_id   ,score  ,created_at     -- uid 学员ID

from ods_lps_kkb_cloud_tss.course_evaluate

where course_id in ('213182','213061','212911','212684','213183','213060','212796','212388','212793','213184','212651','212735',

'212728','212586','212934','212856','212928','212933','212559','212738','212766','212768','212813','212814')   -- 手动提供本月开班的课程

) ce

left join

(

select distinct

section_id  ,teacher_uid   -- 讲师ID

from ods_lps_kkb_cloud_edu.live_lesson

) ll on ce.section_id = ll.section_id

) aa1

left join

(



select uid, mobile,realname from ods_lps_kkb_cloud_edu.manager



) aa2 on aa1.teacher_uid=aa2.uid

group by aa2.mobile ,aa2.realname




# 62、NPS讲师明细
#讲师nps明细 换id即可

select

-- aa2.name ,aa2.mobile     ,aa1.uid  ,aa1.score  ,aa1.section_id  ,aa1.created_at  ,aa1.course_id   ,aa3.nickname  ,aa4.group_name  ,aa5.new_course_name  ,aa1.content

aa2.realname as `讲师姓名`

,aa2.mobile

,aa5.new_course_name as `LPS课程`

,aa6.chapter_name as `章`

,aa4.group_name as `节`

,aa1.content as `评价内容`

,aa1.created_at as `评价时间`

,aa1.score as `评分`

,aa3.nickname as `用户昵称`

from

(

select

ce.uid  ,ce.score  ,ce.chapter_id ,ce.section_id  ,ll.teacher_uid  ,ce.created_at  ,ce.course_id  ,ce.content

from

(

select

uid   ,chapter_id ,section_id   ,score  ,created_at   ,course_id  ,content-- uid 学员ID

from ods_lps_kkb_cloud_tss.course_evaluate

where course_id in ('213182','213061','212911','212684','213183','213060','212796','212388','212793','213184','212651','212735',

'212728','212586','212934','212856','212928','212933','212559','212738','212766','212768','212813','212814')   -- 手动提供本月开班的课程

) ce

left join

(

select distinct

section_id  ,teacher_uid   -- 讲师ID

from ods_lps_kkb_cloud_edu.live_lesson

) ll on ce.section_id = ll.section_id

) aa1

left join

(

select uid, mobile,realname from ods_lps_kkb_cloud_edu.manager

) aa2 on aa1.teacher_uid=aa2.uid

left join

(

select distinct

uid ,nickname

from ods_lps_kkb_cloud_passport.user

) aa3 on aa3.uid=aa1.uid

left join

(

select distinct

section_id ,group_name

from ods_lps_kkb_cloud_edu.`group`

) aa4 on aa1.section_id=aa4.section_id

left join

(

select distinct

new_course_id ,new_course_name

from ods_oldmos_kkb_cloud_vipcourse.vip_class

) aa5 on aa1.course_id=aa5.new_course_id

left join

(

select distinct

chapter_id ,chapter_name

from ods_lps_kkb_cloud_edu.chapter

) aa6 on aa1.chapter_id=aa6.chapter_id




# 63、直播
-- #直播更新完毕版本，只需要加id即可

select

concat("learn.kaikeba.com/video/",aaaa.content_id) as `lps直播回放链接`,

aaaa.course_id as `new_course_id`,

ffff.course_name as `lps课程`,

aaaa.chapter_name as `章`,

bbbb.group_name as `节`,

aaaa.content_id as `content_id`,

--aaaa.content_type,

eeee.realname  as `讲师`,

--aaaa.teacher_uid,

aaaa.`权限学员数` as `权限学员数`,

aaaa.`直播应开始时间` as `直播应开始时间`,

aaaa.`直播应结束时间` as `直播应结束时间`,

aaaa.`课程应上时长(分)` as `课程应上时长(分)`,

aaaa.`直播实际开始时间` as `直播实际开始时间`,

aaaa.`直播实际结束时间` as `直播实际结束时间`,

aaaa.`实际上课时长(分)` as `实际上课时长(分)`,

cccc.`在线峰值人数` as `在线峰值人数`,

bbbb.`直播完课人数` as `直播完课人数`,

--bbbb.`回放完课人数` as `回放完课人数`,

bbbb.`直播未完课人数` as `直播未完课人数`,

concat(round(bbbb.`直播完课人数`/aaaa.`权限学员数`*100,2),"%") as `直播完课率`,

concat(round(bbbb.`回放完课人数`/aaaa.`权限学员数`*100,2),"%") as `回放完课率`

from

(select

a.course_id,a.new_course_name,a.chapter_name,a.content_id,a.content_type,

b.`权限学员数`,

c.`直播应开始时间`,c.`直播应结束时间`,c.`直播实际开始时间`,c.`直播实际结束时间`,

c.`实际上课时长(分)`,c.`课程应上时长(分)`,c.teacher_uid

--d.`在线人数峰值`

from(select distinct vc.new_course_name,co.course_id,

ch.chapter_name,co.content_id,co.content_title,co.content_type

from ods_lps_kkb_cloud_edu.content co

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc

on vc.new_course_id = co.course_id

left join ods_lps_kkb_cloud_edu.chapter ch

on co.chapter_id = ch.chapter_id

where co.course_id in (

)

and co.content_type in ('1','7','16')

)a

left join

(select cs.course_id,count(cs.student_uid) as `权限学员数` from

ods_lps_kkb_cloud_edu.course_student cs

group by cs.course_id

)b

on a.course_id = b.course_id

left join

(

select ll.course_id,ll.content_id,ll.teacher_uid,

ll.`直播应开始时间`,ll.`直播应结束时间`,ll.`直播实际开始时间`,ll.`直播实际结束时间`,

ll.`实际上课时长(分)`,ll.`课程应上时长(分)`

from

(select

distinct course_id, content_id,teacher_uid,

from_unixtime(start_time) as `直播应开始时间`,

from_unixtime(end_time) as `直播应结束时间`,

from_unixtime(real_start_time) as `直播实际开始时间` ,

from_unixtime(real_end_time) as `直播实际结束时间` ,

round((unix_timestamp(from_unixtime(real_end_time))-unix_timestamp(from_unixtime(real_start_time)))/60,2) as `实际上课时长(分)`,

round((unix_timestamp(from_unixtime(end_time))-unix_timestamp(from_unixtime(start_time)))/60,2) as `课程应上时长(分)`

from ods_lps_kkb_cloud_edu.live_lesson) ll

where date(ll.`直播实际开始时间`) != "1970-01-01"

)c

on a.content_id = c.content_id

)aaaa

left join

(select aaa.group_name,aaa.content_id,

--aaa.content_type,

sum(aaa.`直播是否未完课`) as `直播未完课人数`,

sum(aaa.`直播是否完课`) as `直播完课人数`,

sum(aaa.`回放是否完课`) as `回放完课人数`

from

(select

l.group_name,l.content_id,l.content_type,l.student_uid,

l.`直播学习时长` as `直播观看时长`,l.playback_time as `回放观看时长`,p.`课程应上时长`,

--l.study_time/p.`课程应上时长` as `直播观看进度`,

--l.playback_time/p.`课程应上时长` as `回放观看进度`,

case when l.`直播学习时长`/p.`课程应上时长`<=0.4 then 1 else 0 end as `直播是否未完课`,

case when l.`直播学习时长`/p.`课程应上时长`>=0.6 then 1 else 0 end as `直播是否完课`,

case when l.playback_time/p.`课程应上时长`>=0.6 then 1 else 0 end as `回放是否完课`

from

(select csp.content_id,g.group_name,csp.student_uid,

csp.study_time - csp.playback_time as `直播学习时长`,

csp.playback_time,csp.content_type

from ods_lps_kkb_cloud_edu.content_study_progress csp

left join ods_lps_kkb_cloud_edu.`group` g

on csp.section_id = g.section_id

where csp.course_id in (

'213182','213061','212911','212684','213183','213060','212796','212388','212793',

'213184','212651','212735','212728','212586','212934','212856','212928','212933',

'212559','212738','212766','212768','212813','212814')

and csp.content_type in ('1','7','16')) l

left join

(select content_id,sum(duration) as `课程应上时长`

from  ods_lps_kkb_cloud_edu.video_lesson group by content_id) p

on l.content_id = p.content_id)aaa

group by aaa.group_name,aaa.content_id

--,aaa.content_type)

)bbbb

on aaaa.content_id = bbbb.content_id

left join

(select cp.class_id,max(cp.count) as `在线峰值人数`

from ods_lps_kkb_live.class_point cp

group by cp.class_id

)cccc

on aaaa.content_id = cccc.class_id

left join

(select uid,realname from ods_lps_kkb_cloud_edu.manager

) eeee

on aaaa.teacher_uid = eeee.uid


left join

(select course_name,course_Id from ods_lps_kkb_cloud_edu.course ) ffff

on ffff.course_id=aaaa.course_id


64、春节裂变活动数据-岳文佩

select

vo.order_no as `订单号`,

vo.unionid,

vo.user_Id,

-- iii.id as `customer_id`,

uuu.mobile as `手机号`,

vo.item_name as `课程名称`,

vo.channel_code,

vo.course_Id ,

vo.nickname as `昵称`,

vo.pay_time `支付时间`,

vo.seller_name as `链接创建人`,

vo.`分发渠道链接`,

vo.`上级unionid`,

ov.order_no as `上级订单号`,

ov.user_Id as `上级user_id`,

ooo.mobile as `上级手机号`,

-- ppp.id as `上级customerid`,

ov.item_name as `上级购买课程`,

ov.channel_code as `上级channel_code`,

ov.course_id as `上级course_id`,

ov.nickname as `上级昵称`,

ov.pay_time as `上级支付时间`,

ov.seller_name as `上级channel_code创建人`

from

(

select order_no,unionid,user_Id,item_name,channel_code,course_id,nickname,pay_time,seller_name,

get_json_object(passback_params,'$.fissionChannel') as `分发渠道链接`,

get_json_object(passback_params,'$.source_unionid') as `上级unionid`

from dwd.vipcourse_order_hf

where channel_code='z0rvipcgm0'

and status=2 and pt='2021020912'

-- and unionid in (select distinct unionid from ods.ods_cc_deal_openweixin__pay_marketing_plan_fans_da

-- where payMarketingPlanId ='7c42ddb4-089f-41a1-b643-4b2831bdb6f1')

) vo

left join (select distinct uid,mobile from ods_lps_kkb_cloud_passport.user ) uuu

on uuu.uid=vo.user_id

left join (select distinct id,phone from ods_mos_cc_deal.customer where appid='5d6526d7-3c9f-460b-b6cf-ba75397ce1ac') iii

on iii.phone=uuu.mobile

left join

(select *

from dwd.vipcourse_order_hf

where channel_code='z0rvipcgm0'

and status=2 and pt='2021020912' ) ov

on ov.unionid=vo.`上级unionid`

left join (select distinct uid,mobile from ods_lps_kkb_cloud_passport.user ) ooo

on ooo.uid=ov.user_id

left join  (select distinct id,phone from ods_mos_cc_deal.customer where appid='5d6526d7-3c9f-460b-b6cf-ba75397ce1ac') ppp

on ppp.phone=ooo.mobile

where vo.`上级unionid` is not null



65、

select ttt.course_id, sum(ttt.`直播完课`) as `直播完`,sum(ttt.`回放完课`) as `回放完` ,sum(ttt.`整体完课`) as `整体完`

from

(

select

pp.course_Id,

re.student_uid,pp.content_id,pp.study_time-pp.playback_time as `直播观看时长`,pp.playback_time as `回放观看时长`,dur.`直播时长`,

case when  pp.study_time/dur.`直播时长`>=0.60 then 1 else 0 end as `整体完课`,

case when (pp.study_time-pp.playback_time)/dur.`直播时长`>=0.60 then 1 else 0 end as `直播完课`,

case when pp.playback_time/dur.`直播时长`>=0.60 then 1 else 0 end as `回放完课`


from


(select distinct cs.student_uid

from

(select * from ods_lps_kkb_cloud_edu.course_student where course_id='210291') cs

left join ods_lps_kkb_cloud_edu.manager mm on cs.student_uid=mm.uid

where mm.uid is null) re


left join

(select * from  ods_lps_kkb_cloud_edu.content_study_progress where content_type in ('1','7','16') and course_id='210291')  pp

on pp.student_uid=re.student_uid


left join

(select distinct pp.content_id,

ll.end_time-ll.start_time as `直播时长`from

ods_lps_kkb_cloud_edu.content_study_progress pp

left join ods_lps_kkb_cloud_edu.live_lesson ll on ll.content_Id=pp.content_id

where pp.content_type in ('1','7','16')) dur

on dur.content_id=pp.content_id

) ttt

group by ttt.course_Id

# 64、官网漏斗数据上BI用

select

opena.`公开课日期`,

opena.`公开课列表页访问用户数`,

opena.`公开课详情页访问用户数`,

pera.`体验课日期`,

pera.`体验课列表页访问用户数`,

pera.`体验课详情页访问用户数`,

ordr.`课程类型`,

ordr.`创建日期`,

ordr.`创建订单数`,

ordr.`支付订单数`,

ordr.`支付订单中新leads数`

from

(

select

cre.`课程类型`,

-- to_date(cre.`创建时间`) as `创建订单日期（天）`,

date_format(cre.`创建时间`,'yyyyMMdd') as `创建日期`,

count(cre.`订单号`) as `创建订单数`,

count(pay.`订单号`) as `支付订单数`,

count( distinct(new.mobile)) as `支付订单中新leads数`

from

(

-- 创建

select  distinct

a.`mobile`,a.out_order_id as `订单号`,a.`创建时间`,a.`课程类型`

from

(select

vo.mobile `mobile`,vch.name `name`,from_unixtime(vo.create_time) as `创建时间`,vo.out_order_Id,vo.status,vo.amount,

case vo.course_type

when 0 then "正价课"

when 1 then "体验课"

when 2 then "公开课"

when 3 then "新公开课" end as `课程类型`,

vch.source_type,vo.item_name `课程名称`,vo.out_order_id `订单编号`



from

( select distinct *

from ods.ods_kkb_cloud_vipcourse__vip_order_ha

where substr(pt,1,8)=date_format(CURRENT_DATE,'yyyyMMdd')

and (date(from_unixtime(create_time)) between '2021-02-01' and '2021-02-28')

-- and status = 2

) vo

left join

( select * from

ods.ods_kkb_cloud_vipcourse__vip_channel_ha

where substr(pt,1,8)=date_format(CURRENT_DATE,'yyyyMMdd')

) vch

on vo.channel_code = vch.code

where (vch.source_type = '1'

or vch.name like '%SEO%'

or vch.name like '%产品壹佰%')



or (vo.passback_params LIKE '%:"gw%' OR

vo.passback_params LIKE '%:"old%' OR

vo.passback_params LIKE '%:"teacher%'

and vo.course_id in (

'2579',

'2604',

'2620',

'2617'))

and not isnull(vo.mobile)

)a

) cre

left join

(

-- 支付

select distinct

a.`mobile`,a.out_order_id as `订单号`,a.`支付时间`,a.`课程类型`

from

(select

vo.mobile `mobile`,vch.name `name`,from_unixtime(vo.pay_time) as `支付时间`,vo.out_order_Id,vo.status,vo.amount,

case vo.course_type

when 0 then "正价课"

when 1 then "体验课"

when 2 then "公开课"

when 3 then "新公开课" end as `课程类型`,

vch.source_type,vo.item_name `课程名称`,vo.out_order_id `订单编号`



from

( select *

from ods.ods_kkb_cloud_vipcourse__vip_order_ha

where substr(pt,1,8)=date_format(CURRENT_DATE,'yyyyMMdd')

and (date(from_unixtime(pay_time)) between '2021-02-01' and '2021-02-28')

and status = 2



) vo

left join

( select * from

ods.ods_kkb_cloud_vipcourse__vip_channel_ha

where substr(pt,1,8)=date_format(CURRENT_DATE,'yyyyMMdd')

) vch

on vo.channel_code = vch.code

where (vch.source_type = '1'

or vch.name like '%SEO%'

or vch.name like '%产品壹佰%')



or (vo.passback_params LIKE '%:"gw%' OR

vo.passback_params LIKE '%:"old%' OR

vo.passback_params LIKE '%:"teacher%'

and vo.course_id in (

'2579',

'2604',

'2620',

'2617'))

and not isnull(vo.mobile)

)a

)pay

on pay.mobile=cre.mobile and pay.`订单号`=cre.`订单号`

left join

(-- 新leads

select

a.`mobile`,a.out_order_Id as `订单号`,a.`课程类型`

from

(select

vo.mobile `mobile`,vch.name `name`,from_unixtime(vo.pay_time) as `支付时间`,vo.status,vo.amount,vo.out_order_id,

case vo.course_type

when 0 then "正价课"

when 1 then "体验课"

when 2 then "公开课"

when 3 then "新公开课" end as `课程类型`,

vch.source_type,vo.item_name `课程名称`,vo.out_order_id `订单编号`



from

( select *

from ods.ods_kkb_cloud_vipcourse__vip_order_ha

where substr(pt,1,8)=date_format(CURRENT_DATE,'yyyyMMdd')

and (date(from_unixtime(pay_time)) between '2021-02-01' and '2021-02-28')

and status = 2

) vo

left join

( select * from

ods.ods_kkb_cloud_vipcourse__vip_channel_ha

where substr(pt,1,8)=date_format(CURRENT_DATE,'yyyyMMdd')

) vch

on vo.channel_code = vch.code

where (vch.source_type = '1'

or vch.name like '%SEO%'

or vch.name like '%产品壹佰%')

or (vo.passback_params LIKE '%:"gw%' OR

vo.passback_params LIKE '%:"old%' OR

vo.passback_params LIKE '%:"teacher%'

and vo.course_id in (

'2579',

'2604',

'2620',

'2617'))

and not isnull(vo.mobile)

)a

left join

(select vo.mobile,min(from_unixtime(vo.pay_time)) as `首次支付时间`

from

( select *

from ods.ods_kkb_cloud_vipcourse__vip_order_ha

where substr(pt,1,8)=date_format(CURRENT_DATE,'yyyyMMdd')

and status = '2'

and not isnull(mobile)

) vo

group by vo.mobile

)b

on a.mobile = b.mobile and a.`支付时间`=b.`首次支付时间`

where b.`首次支付时间` is not null

)new

on new.mobile=pay.mobile and new.`订单号`=pay.`订单号`

group by

cre.`课程类型`,date_format(cre.`创建时间`,'yyyyMMdd')

) ordr

right join

(

-- 公开课访问

select open.pt as `公开课日期`,open.`公开课列表页访问用户数`,opend.`公开课详情页访问用户数`

from

(SELECT pt, count(visituserid) as `公开课列表页访问用户数`

from dwd.flw_fct_gio_page_log_di

where title1='开课吧' and title2='公开课'

group by pt) open

left join

(SELECT pt, count(visituserid) as `公开课详情页访问用户数`

from dwd.flw_fct_gio_page_log_di

where  url like '%www.kaikeba.com/open/item%'

group by pt)opend

on open.pt=opend.pt

) opena

on opena.`公开课日期`=ordr.`创建日期`

right join

(

-- 体验课访问

select per.pt as `体验课日期`,per.`体验课列表页访问用户数`,perd.`体验课详情页访问用户数`

from

(SELECT pt, count(visituserid) as `体验课列表页访问用户数`

from dwd.flw_fct_gio_page_log_di

where title1='开课吧' and title2='体验课'

group by pt) per

left join

(SELECT pt, count(visituserid) as `体验课详情页访问用户数`

from dwd.flw_fct_gio_page_log_di

where  url like '%www.kaikeba.com/experience/detail%'

group by pt) perd

on per.pt=perd.pt

) pera

on pera.`体验课日期`=ordr.`创建日期`


# 65、薪动分销数据-BI用
select

vo.order_no as `订单号`,

vo.unionid,

vo.user_Id,

uuu.mobile as `手机号`,

iii.`客户的id`,

vo.item_name as `课程名称`,

vo.channel_code,

vc.name as `渠道名称`,

vo.course_Id ,

vo.nickname as `昵称`,

vo.pay_time `支付时间`,

vo.seller_name as `链接创建人`,

vo.`分发渠道链接`,

vo.`上级unionid`,

ov.nickname as `上级昵称`,

ov.uid as `上级user_id`,

ppp.`上级客户的id`,

ov.mobile as `上级手机号`

from

(select distinct unionid from ods.ods_cc_deal_openweixin__pay_marketing_plan_fans_da

where payMarketingPlanId ='7c42ddb4-089f-41a1-b643-4b2831bdb6f1') rrr

left join

(

select distinct order_no,unionid,user_Id,item_name,channel_code,course_id,nickname,pay_time,seller_name,

get_json_object(passback_params,'$.fissionChannel') as `分发渠道链接`,

get_json_object(passback_params,'$.source_unionid') as `上级unionid`

from dwd.vipcourse_order_hf

where channel_code='z0rvipcgm0'

and status=2 and substr(pt,1,8)=date_format(CURRENT_DATE,'yyyyMMdd')

) vo

on vo.unionid=rrr.unionid

left join

(select * from ods_oldmos_kkb_cloud_vipcourse.vip_channel) vc

on vc.code=vo.channel_code

left join (select distinct uid,mobile from ods_lps_kkb_cloud_passport.user ) uuu

on uuu.uid=vo.user_id

left join (

select aa.phone,max(`客户id`) as `客户的id`

from

(select phone,case when status=1 then id when status=2 then mergedCustomerId end as `客户id`

from ods_mos_cc_deal.customer

where appid='5d6526d7-3c9f-460b-b6cf-ba75397ce1ac') aa

group by phone

) iii

on iii.phone=uuu.mobile

left join

(select distinct uwm.unionid,uwm.uid,uu.nickname,uu.mobile

from ods_lps_kkb_cloud_passport.user_wechat_map uwm

left join ods_lps_kkb_cloud_passport.user uu

on uwm.uid=uu.uid) ov

on ov.unionid=vo.`上级unionid`

left join  (select aa.phone,max(`客户id`) as `上级客户的id`

from

(select phone,case when status=1 then id when status=2 then mergedCustomerId end as `客户id`

from ods_mos_cc_deal.customer

where appid='5d6526d7-3c9f-460b-b6cf-ba75397ce1ac') aa

group by phone

) ppp

on ppp.phone=ov.mobile

where vo.`上级unionid` is not null and rrr.unionid is not null

# 66、春节直播复盘
select

case when aa.`观看时长`<3 then '观看时长3h以内的用户数'

when aa.`观看时长`>=3 and aa.`观看时长`<6  then '观看时长3-6h的用户数'

when aa.`观看时长`>=6 and aa.`观看时长`<9  then '观看时长6-9h的用户数'

when aa.`观看时长`>=9 and aa.`观看时长`<24  then '观看时长9-24h的用户数'

when aa.`观看时长`>=24 then '观看时长24以上的用户数' end as `观看时长分布`,

count(distinct(aa.student_uid)) as `人数`

from

(

select

student_uid,

study_time/3600 as `观看时长`

from content_study_progress

where content_id='316712'

and student_uid in ()

)aa

group by case when aa.`观看时长`<3 then '观看时长3h以内的用户数'

when aa.`观看时长`>=3 and aa.`观看时长`<6  then '观看时长3-6h的用户数'

when aa.`观看时长`>=6 and aa.`观看时长`<9  then '观看时长6-9h的用户数'

when aa.`观看时长`>=9 and aa.`观看时长`<24  then '观看时长9-24h的用户数'

when aa.`观看时长`>=24 then '观看时长24以上的用户数' end



# 67、助教作业批改情况-BI用
select

oo.`学院名称`,

oo.`教务学科`,

oo.`课程名称`,

oo.course_id,

oo.`开班时间`,

oo.`结班时间`,

pp.`班级人数`,

oo.`作业名称`,

gg.content_id,

rr.`提交作业人数`,

pp.`班级人数`-rr.`提交作业人数` as `未提交作业人数`,

gg.`助教姓名`,

gg.`助教id`,

gg.`批改状态（结果值）`,

gg.`个数`,

ff. `批改总数量（过程值）`,

hh.`驳回总数量（过程值）`,

ii.`助教批改当前content作业的平均分`,

tt.`当前content作业总分`,

tt.`当前content作业总分`/pp.`班级人数` as `当前content作业全班平均分`

from

(

select

concat(ee.content_id,ee.`助教id`) as `id合并`,

ee.content_id,

ee.`助教姓名`,

ee.`助教id`,

ee.`批改状态（结果值）`,

count(ee.content_id) as `个数`

from

(select distinct

bb.content_id,bb.id as `homework_id`,cc.uid as `助教id`,dd.realname as `助教姓名`,

case when bb.correct_status=0 then '未批改' when bb.correct_status=1 then '已批改'

when bb.correct_status=2 then '驳回' end as `批改状态（结果值）`

from student_homework bb

left join student_homework_correct cc on cc.student_homework_id=bb.id and bb.content_id=cc.content_id

left join

(SELECT DISTINCT

sh.uid,zj.realname

FROM student_homework_correct_records sh

LEFT JOIN (SELECT uid,realname

FROM manager

UNION ALL

SELECT assistant_id as uid,assistant_name as realname

FROM content_assistants) zj

ON sh.uid = zj.uid

GROUP BY sh.uid) dd on  dd.uid=cc.uid

where

bb.assistant_id=0

) ee

group by

ee.`批改状态（结果值）`,

ee.content_id,

ee.`助教姓名`,

ee.`助教id`

)gg

left join

(select concat(content_Id,uid) as `id合并`,count(*) as `批改总数量（过程值）`

from student_homework_correct_records where type=2

group by concat(content_Id,uid)

) ff

on ff.`id合并`=gg.`id合并`

left join

(select concat(content_Id,uid) as `id合并`,count(*) as `驳回总数量（过程值）`

from student_homework_correct_records where type=4

group by concat(content_Id,uid)

) hh

on hh.`id合并`=gg.`id合并`

left join

(select

CONCAT(content_id,uid) as `合并id`,sum(score)/count(*) as `助教批改当前content作业的平均分`

from student_homework_correct

group by  CONCAT(content_id,uid))ii

on ii.`合并id`=gg.`id合并`

left join

(

select qq.content_Id,qq.content_title as `作业名称`,ww.course_name as `课程名称`,ss.school_name as `学院名称`,qq.course_id

,ww.real_start_date as `开班时间`,ww.real_end_date as `结班时间`,

case when ww.education_id='1' then '数据分析学科'

when ww.education_id='2' then 'Java百万架构学科'

when ww.education_id='3' then  'AI学科'

when ww.education_id='4'  then 'Web学科'

when ww.education_id='5'  then	'大数据开发学科'

when ww.education_id='6' 	then '新职课Java学科'

when ww.education_id='7' then '新职课数据科学学科'

when ww.education_id='8' then	'新职课C++学科'

when ww.education_id='9' then	'产品经理学科'

when ww.education_id='10'  then '新职课Web学科'

when ww.education_id='11'  then	'职场软技能学科'

when ww.education_id='12'	then '数据赋能学科'

when ww.education_id='13' then	'新职课产品运营学科'

when ww.education_id='14'	 then'Java进阶课学科'

end as `教务学科`

from content qq

left join course ww

on qq.course_id=ww.course_Id

left join school ss

on ss.school_id=ww.school_id

) oo

on oo.content_id=gg.content_id

left join

(

select cs.course_id,

sum(case when mm.uid is null then 1 else 0 end ) as `班级人数`

from course_student cs

left join manager mm on cs.student_uid = mm.uid

group by cs.course_id

)pp

on pp.course_id=oo.course_id

left join

(select content_id,count(distinct(uid)) as `提交作业人数`

from student_homework_record

group by content_id) rr

on rr.content_id=gg.content_id

left join

(select

content_id,sum(score) as `当前content作业总分`

from student_homework_correct

group by  content_id ) tt

on tt.content_id=gg.content_id

where oo.`结班时间`>'2021-01-31'


# 68、助教对提交作业的响应-BI用
select

dd.`合并id`,

sum(case when dd.`响应时间分布`='12小时内响应' then dd.`响应次数` ELSE NULL END) `12小时内响应次数`,

sum(case when dd.`响应时间分布`='12-24小时内响应' then dd.`响应次数` ELSE NULL END) `12-24小时内响应次数`,

sum(case when dd.`响应时间分布`='24-48小时内响应' then dd.`响应次数` ELSE NULL END) `24-48小时内响应次数`,

sum(case when dd.`响应时间分布`= '48小时以上响应' then dd.`响应次数` ELSE NULL END) `48小时以上响应次数`

from

(

select

concat(aa.content_id,bb.uid) `合并id`,

case when round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) <12.0 then '12小时内响应'

when round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) >=12.0 and

round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) <24.0 then '12-24小时内响应'

when round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) >=24.0 and

round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) <48.0 then '24-48小时内响应'

when round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) >=48.0 then '48小时以上响应' end as `响应时间分布`,

count(concat(aa.content_id,bb.uid)) as `响应次数`

from student_homework_record aa

left join

(

select student_homework_record_id,uid,student_homework_id,content_id,min(created_at) as created_ate

from student_homework_correct_records

where type in ('2','4')

group by student_homework_record_id,uid,student_homework_id,content_id

) bb

on aa.id=bb.student_homework_record_id

left join student_homework cc on cc.id=aa.homework_id

where  cc.assistant_id=0

group by case when round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) <12.0 then '12小时内响应'

when round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) >=12.0 and

round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) <24.0 then '12-24小时内响应'

when round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) >=24.0 and

round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) <48.0 then '24-48小时内响应'

when round((unix_timestamp(bb.created_ate)-unix_timestamp(aa.created_at))/3600,1) >=48.0 then '48小时以上响应' end

,concat(aa.content_id,bb.uid)

)dd

group by dd.`合并id`

# 69、米堆正价学习情况
select

mm.student_uid as `uid`,

iii.nickname as `昵称`,

mm.course_id as `course_id`,

tt.chapter_name as `章`,

gg.group_name as `节`,

nn.content_title as `内容`,

mm.content_id as `内容id`,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业' when 5 then '测验'  when 6 then '资料'

when 9 then '互动剧本'  when 16 then 'hk直播' when 7 then '回放' end as `内容类型`,

round(vl.`视频时长`/60,2) as `视频时长`,

mm.created_at as `开始学习时间`,

mm.updated_at as `最近一次学习时间`,

round(mm.study_time/60,2)  as `学习时长（min）`


from

( select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id in ('213341','213342','213343','213535')  and content_type in ('1','3','4','5','6','9','16','7') )mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile,ss.nickname

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_Lps_kkb_cloud_edu.group gg on gg.section_id=mm.section_id

left join ods_lps_kkb_cloud_edu.content nn on nn.content_id=mm.content_id

left join

(select sum(duration) as `视频时长`,content_id

from ods_lps_kkb_cloud_edu.video_lesson

where video_vendor=1

group by content_id

) vl

on vl.content_id=mm.content_id

order by course_id

# 70、ESU测评
select info.*,ans.*

from

(

select ii.exam_paper_id as `试卷id`,ii.paper_name as `试卷名称`,cc.title as `场次名称`,rr.exam_question_id as `问题id`,

bb.question_id,

bb.title as `问题名称`,bb.type as `问题类型`

from

(

select exam_paper_id,paper_name from  oj_exam_paper

where paper_name

in ('宁德时代AI基础能力测评221_2')

)ii

left join oj_exam cc on cc.exam_paper_id=ii.exam_paper_id

left join oj_exam_question rr on rr.exam_paper_id=cc.exam_paper_id

left join oj_question bb on bb.question_id=rr.question_challenge_id

-- where cc.title='宁德时代AI能力基础测评_补充'

) info

inner join

(select tt.student_id,yy.name as `学员姓名`,yy.phone as `学员手机号`,tt.question_id as `问题id`,tt.answer as `回答`,tt.score as `分数`

from oj_student_question tt

left join oj_student yy on tt.student_id=yy.student_id) ans

on info.question_id=ans.`问题id`

# 71、财务需求课时数据-郭萌
select distinct aa.course_Id,aa.course_name as `lps课程名称`,

aa.education_id,

-- aa.`预计开班时间`,

-- aa.`预计结班时间`,

aa.`实际开班日期`,aa.`实际结班日期`,bb.`实际课时`

from

(

select course_Id,course_name,

-- case when type='1' then '体系课'

-- when when type='2' then '公开课'

-- when type='3' then '微课'

-- when type='4' then '小课'

-- when type='5' then '就业课'

-- when type='6' then '真北课程'

-- when type='7' then '线下课'

-- when type='8' then '普通公开课'

-- when type='9' then '体验课'

-- when type='10' then 'TBL课(任务制教学)'

-- end as `课程类型`,

-- to_date(from_unixtime(start_date)) as `预计开班时间`,

-- end_date as `预计结班时间`,

real_start_date as `实际开班日期`,

real_end_date as `实际结班日期`,

education_id

-- ,course_name

from ods_lps_kkb_cloud_edu.course

where

type=1

-- and real_start_date>'2019-01-01' and real_end_date<'2021-03-01'

-- and real_start_date is not null and  real_end_date is not null

) aa

left join

(select course_Id,

round(sum(round((unix_timestamp(from_unixtime(real_end_time))-unix_timestamp(from_unixtime(real_start_time)))/3600,2)),2) as `实际课时`

from ods_lps_kkb_cloud_edu.live_lesson

where disabled='0' and real_end_time is not null and real_start_time is not null

group by course_Id

) bb on aa.course_id=bb.course_id


-- left join

-- (select distinct new_course_id,name,course_id from ods_oldmos_kkb_cloud_vipcourse.vip_class ) cc

-- on cc.new_course_id=aa.course_id

order by bb.`实际课时` desc







# 72、官网转化数据-徐文燕
select

a.`课程名称`,

a.course_id,

case a.course_type

when 0 then "正价课"

when 1 then "体验课"

when 2 then "公开课"

when 3 then "新公开课" end as `课程类型`,

a.channel_code,

a.mobile,

a.user_id,

a.`昵称`,

a.headimgurl as `头像`,

a.seller_name as `成单人`,

a.`支付时间`,

a.`成交金额`,

b.`首次支付时间`,

case when b.`首次支付时间`=a.`支付时间`  then '新用户'

when b.`首次支付时间`<a.`支付时间` then '老用户'

else '未知' end as `新老用户`,

c.`正价课支付时间`,

c.`正价课支付金额`,

c.`正价课名称`

from


(select

vo.headimgurl,

vo.mobile,

vo.user_id,

from_unixtime(vo.pay_time) as `支付时间`,

vo.channel_code,

vo.course_type,

vo.seller_name,

vo.nickname as `昵称`,

vo.course_id,

vo.amount as `成交金额`,

vo.item_name as `课程名称`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vch

on vo.channel_code = vch.code

where

date(from_unixtime(vo.pay_time)) >= "2020-12-18"

and vch.name='官网_默认渠道'

and vo.mobile is not null and vo.seller_name in ('开课吧',

'肖坤',

'夏艳丽',

'肖涵木',

'于晓彤',

'董火峰',

'粱紫媛')

)a


left join

(select vo.mobile,min(from_unixtime(vo.pay_time)) as `首次支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.status = '2'

group by vo.mobile

)b

on a.mobile = b.mobile

-- where a.`支付时间` = b.`首次支付时间`

left join

(select vo.mobile,from_unixtime(vo.pay_time) as `正价课支付时间`,vo.amount as `正价课支付金额`,vo.item_name as `正价课名称`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.status = '2' and vo.amount>1000

)c

on c.mobile=a.mobile

order by a.user_id,a.channel_code


# 73、财务需求课时数据by月-郭萌
select distinct

aa.school_id,

aa.course_Id,

bb.`直播开始时间月份`,

-- aa.course_name as `lps课程名称`,

-- aa.education_id,

-- aa.`实际开班日期`,

-- aa.`实际结班日期`,

bb.`实际课时`


from

(

select course_Id,course_name,school_id,

real_start_date as `实际开班日期`,

real_end_date as `实际结班日期`,

education_id

from ods_lps_kkb_cloud_edu.course

where

type=1) aa

left join

(select course_Id,substr(FROM_UNIXTIME(real_start_time),1,7) as `直播开始时间月份`,

round(sum(round((unix_timestamp(from_unixtime(real_end_time))-unix_timestamp(from_unixtime(real_start_time)))/3600,2)),2) as `实际课时`

from ods_lps_kkb_cloud_edu.live_lesson

where disabled='0'

and real_end_time is not null and real_start_time is not null

and real_start_time!='0' and real_end_time!='0'

group by course_Id,substr( FROM_UNIXTIME(real_start_time),1,7)

) bb on aa.course_id=bb.course_id

order by bb.`实际课时` desc

# # 74、学员使用时长-陈国军
select cc.school_id,round(sum(cc.`学习总时长`),2)as `时长累计`

from

(

select distinct

aa.school_id,

aa.course_Id,

bb.`学习总时长`

from


(select round(sum(study_time-playback_time)/3600,2) as `学习总时长`,course_id

from ods_lps_kkb_cloud_edu.content_study_progress

where content_type in ('1','16') and created_at between '2021-01-01 00:00:00' and '2021-01-31 23:59:59'

group by course_id

) bb

left join

(

select course_Id,school_id

from ods_lps_kkb_cloud_edu.course

) aa

on aa.course_id=bb.course_id

order by bb.`学习总时长` desc

) cc

group by cc.school_id


# 75、正价续购数据-郭萌
select

vvv.`支付月份`,vvv.`课程分类`,

count(vvv.out_order_id) as `月签约人数`,sum(vvv.amount) as `月流水`,

round(sum(vvv.amount)/count(vvv.out_order_id),2) as `客单价`

from

(

select distinct aa.customer_id,aa.`课程分类`,aa.`支付月份`,aa.pay_time,aa.amount,aa.channel_code,aa.out_order_id

from

(select

customer_id,

case when  subject_name='数据中课' then '赋能课'

when  subject_name='Python小课'  then '赋能课'

--  when  subject_name='DBG付费社群' then '赋能课'

when  subject_name='小课畅学卡' then '赋能课'

when  subject_name='职业素质' then '赋能课'

when  subject_name='传统行业' then '赋能课'

when item_name like '%米堆%' or item_name like '%财务%' then '拓展课'

else '岗位课'

end as `课程分类`,

channel_code,

amount,

-- item_name,

-- subject_name,

pay_time,

out_order_id,

substr(pay_time,1,7) as `支付月份`

from dwd.vipcourse_order_hf

where pt='2021030512' and amount>1000 and status=2  and  to_date(pay_time) between '2021-02-01' and  '2021-02-28') aa

left join

(

select

customer_id,

subject_name as `学科`,

item_name as `课程名称`,

amount,

substr(pay_time,1,7) as `支付月份`

from dwd.vipcourse_order_hf

where pt='2021030512' and amount>1000 and status=2  and  to_date(pay_time) between '2019-04-01' and  '2021-01-31') bb

on aa.customer_id=bb.customer_id

where bb.customer_id is not null and aa.customer_id!='' and aa.customer_id is not null

) vvv

group by vvv.`支付月份`,vvv.`课程分类`

# 76、官网公开课订单直播开始时间-刘航
select

aa.`学科`,aa.`课程名称`,aa.`渠道码`

-- cc.`直播状态`,cc.`直播预计开始时间`,

-- cc.`实际直播开始时间`,aa.`支付日期`,aa.`订单数`

from

(select subject_name as `学科`,item_name as `课程名称`,channel_code as `渠道码`,course_Id,

substr(pay_time,1,7) as `支付日期`,

count(out_order_id) as `订单数`

from dwd.vipcourse_order_hf

where pt='2021031210'

and status='2' and course_type='3'

group by subject_name,item_name,channel_code,course_id,substr(pay_time,1,7) ) aa

right join

(select distinct code,name

from ods_oldmos_kkb_cloud_vipcourse.vip_channel

where name='官网_默认渠道') bb

on aa.`渠道码`=bb.code

left join

(

select distinct vo.new_course_id,vo.course_id,

case when ll.status=0 then '未开始'

when ll.status=1 then '直播中'

when ll.status=2 then '直播结束'

when ll.status=3 then '生成回放'

when ll.status=4 then '回放异常'

when ll.status=5 then '备课中' end as `直播状态`,

from_unixtime(ll.real_start_time) as `实际直播开始时间`,

from_unixtime(ll.start_time) as `直播预计开始时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_class vo

left join ods_lps_kkb_cloud_edu.live_lesson ll on vo.new_course_Id=ll.course_Id

where ll.disabled='0') cc

on cc.course_id=aa.course_Id

# 77、首单是官网的手机号在后续转化
select a.*,b.*

from

(

--官网首单

select vo.mobile,min(from_unixtime(vo.pay_time)) as `首次支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_channel vc on vo.channel_code=vc.code

where vo.status = '2' and vc.source_type='1' and vo.course_type='1' and vo.mobile is not null

group by vo.mobile

) a

left join

(

--首单

select vo.mobile,min(from_unixtime(vo.pay_time)) as `首次支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

where vo.status = '2' and vo.mobile is not null

group by vo.mobile

) b

on a.mobile=b.mobile and  a.`首次支付时间`=b.`首次支付时间`

where b.mobile is not null

**#转化金额**

select

substr(from_unixtime(pay_time),1,7) as `支付月份`,

count(out_order_Id) as `正价订单数`,

sum(amount) as `正价总金额`

from vip_order

where status=2 and amount>1000  and mobile in ()

group by substr(from_unixtime(pay_time),1,7)

# 78、软技能学院开年加薪训练营-赵美红
select  distinct aaa.nickname as `学员昵称`,

-- aaa.mobile as  `手机号`,

-- aaa.unionid as `unionid`,

aaa.`订单号`,

aaa.`支付时间` ,

aaa.item_name as `购买课程`,

aaa.course_Id as `课程id`,

aaa.amount `支付金额`,

aaa.seller_name `所属销售`,

bbb.chapter_name as `章`,

bbb.group_name as `节`,

bbb.content_title as `内容`,

bbb.content_Id as `内容id`,

bbb.`内容类型`,

round(bbb.study_time/60,2) as `学习时长(min)`

-- bbb.playback_time as `回放时长`

from

(select distinct vo.course_Id, vo.nickname,vo.mobile,vo.unionid,vo.out_order_Id as `订单号`,

from_unixtime(vo.pay_time) as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id

where vo.course_id=2640 and vo.status=2 ) aaa

left  join

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.study_time,

iii.unionid,

iii.mobile,

mm.playback_time,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业'  when 16 then 'hk直播' end as `内容类型`,

tt.chapter_name,

gg.group_name ,

nn.content_title

from (  select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='213981' )mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_lps_kkb_cloud_edu.group  gg on gg.section_id=mm.section_id

left join ods_lps_kkb_cloud_edu.content nn on nn.content_Id=mm.content_Id

where mm.content_type in ('1','3','4','16')) bbb

on aaa.mobile=bbb.mobile and aaa.new_course_id=bbb.course_id


# 79、普通班学习时长-岳文佩
select

aaa.mobile,aaa.name,bbb.`学习时长`

from


(

select distinct ss.name,vo.mobile

from

(select distinct mobile,course_Id from  ods_oldmos_kkb_cloud_vipcourse.vip_order

where course_type='0' and amount>1000 and status=2 and mobile is not null ) vo

left join

(select distinct id,subject_Id from

ods_oldmos_kkb_cloud_vipcourse.vip_course

where

talent_service='1'

or scholarship='1'

or excellent='1'

or training_camp='1'

or schoolboy_class='1'

)vc  on vo.course_id=vc.id

left join ods_oldmos_kkb_cloud_account.sys_subject  ss on ss.id=vc.subject_Id

) aaa


left join

(

select oo.student_uid,dd.mobile,oo.`学习时长`

from

(select student_uid,sum(study_time) as `学习时长`

from ods_lps_kkb_cloud_edu.content_study_progress

where created_at>'2020-12-16 00:00:00'

group by student_uid) oo

left join

(select distinct uid,mobile from

ods_lps_kkb_cloud_passport.user) dd on oo.student_uid=dd.uid

) bbb

on aaa.mobile =bbb.mobile

order by bbb.`学习时长` desc

# 80、点播到课率、时长、平均时长-BI用
select aaa.*,bbb.`章`,bbb.`节`,bbb.`点播`,concat(round(ccc.`到课人数`/aaa.`班级人数`*100,2),"%") as `到课率`,

bbb.`点播时长(min)`,ccc.`平均观看时长(min)`

from

(

select

school_name as `学院`,

education_name as `教务学科`,

lps_course_name as `lps课程`,

lps_course_id,

real_start_date as `开班日期`,

real_end_date as `结班日期`,

course_stu_cnt as `班级人数`

from dws.edu_fct_kpi_class_teacher_course_a

where course_type='1' and school_name not like '%测试%' and lps_course_name not like '%测试%'

) aaa

left join

(

select co.course_id,ch.chapter_name as `章`,gr.group_name as `节`,ot.content_id,ot.content_title as `点播`,round(max(vl.duration)/60,2) as `点播时长(min)`

from ods_lps_kkb_cloud_edu.course co

left join ods_lps_kkb_cloud_edu.chapter ch on co.course_Id=ch.course_Id

left join ods_lps_kkb_cloud_edu.group gr on gr.chapter_id=ch.chapter_id

left join ods_lps_kkb_cloud_edu.content ot on ot.section_id=gr.section_id

left join ods_lps_kkb_cloud_edu.video_lesson vl on vl.content_id=ot.content_id

where co.type='1' and ot.content_type='3' and vl.video_vendor='4'

group by co.course_id,ch.chapter_name,gr.group_name,ot.content_title,ot.content_id

)bbb

on aaa.lps_course_id=bbb.course_id

left join

(

select cs.content_Id,count(cs.student_uid) as `到课人数`,round((sum(cs.study_time)/count(cs.student_uid))/60,2) as `平均观看时长(min)`

from ods_lps_kkb_cloud_edu.content_study_progress cs

left join ods_Lps_kkb_cloud_edu.manager ma on cs.student_uid=ma.uid

where cs.content_type=3 and ma.uid is null

group by cs.content_Id

)ccc

on ccc.content_id=bbb.content_Id

81、

select

ee.item_name as `课程名称`,

ee.course_Id,

ee.`报名数`,

uu.`章`,

uu.`节`,

uu.`内容`,

uu.`到课数`,

concat(round(uu.`到课数`/ ee.`报名数`*100,2),"%") as `到课率`,

uu.`完课数`,

concat(round(uu.`完课数`/ ee.`报名数`*100,2),"%") as `完课率`,

uu.`回放数`,

concat(round(uu.`回放数`/ ee.`报名数`*100,2),"%") as `回放率`,

uu.`到课数+回放数`,

concat(round(uu.`到课数+回放数`/ee.`报名数`*100,2),"%") as `到课数+回放数率`,

uu.`交作业数`,

concat(round(uu.`交作业数`/ee.`报名数`*100,2),"%") as `交作业率`


from



(select item_name,course_id, count(mobile) as `报名数`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where course_id=2761 and status=2

group by course_id,item_name)ee


left join


(

select

dd.`章`,

dd.`节`,

dd.`内容`,

dd.course_Id,

count(case when dd.`内容类型`='hk直播' and  dd.`学习时长(min)`>0 then 'dd.`手机号`' else null end) as `到课数`,

count(case when dd.`内容类型`='hk直播' and  dd.`学习时长(min)`>60 then 'dd.`手机号`' else null end) as `完课数`,

count(case when dd.`内容类型`='回放' then 'dd.`手机号`' else null end ) as `回放数`,

count(case when dd.`内容类型`='hk直播' and  dd.`学习时长(min)`>0 then 'dd.`手机号`' else null end)

+count(case when dd.`内容类型`='回放' then 'dd.`手机号`' else null end )  as `到课数+回放数`,

count(case when dd.`内容类型`='作业' then 'dd.`手机号`' else null end ) as `交作业数`

from

(

select

distinct

aaa.mobile as  `手机号`,

aaa.course_id,

bbb.chapter_name as `章`,

bbb.group_name as `节`,

bbb.content_title as `内容`,

-- bbb.content_Id as `内容id`,

bbb.`内容类型`,

round(bbb.study_time/60,2) as `学习时长(min)`,

round(bbb.playback_time/60,2) as `回放时长(min)`

from

(select distinct vo.course_Id, vo.nickname,vo.mobile,vo.unionid,vo.out_order_Id as `订单号`,

from_unixtime(vo.pay_time) as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id

where vo.course_id=2761 and vo.status=2 ) aaa

left  join

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.study_time,

iii.unionid,

iii.mobile,

mm.playback_time,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业' when 7 then '回放' when 16 then 'hk直播' end as `内容类型`,

tt.chapter_name,

gg.group_name ,

nn.content_title

from (  select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='214246' )mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_lps_kkb_cloud_edu.group  gg on gg.section_id=mm.section_id

left join ods_lps_kkb_cloud_edu.content nn on nn.content_Id=mm.content_Id

where mm.content_type in ('1','3','4','16','7')) bbb

on aaa.mobile=bbb.mobile and aaa.new_course_id=bbb.course_id

)dd

group by

dd.`章`,

dd.`节`,

dd.`内容`,

dd.course_Id) uu

on uu.course_Id=ee.course_id

# 81、雅思体验课直播见转化情况-田潇潇
-- 直播内是每周二19:30到每周五22:00



select distinct

ww.`phone`,

ww.`体验课支付时间`,

rr.`最早到课时间`,

case when rr.`最早到课时间` is null then '否' else '是' end as `是否到课`,

case when qq.`正价支付时间`>= rr.`最早到课时间` and rr.`最早到课时间` is not null  then '是' else '否' end as  `是否有效正价`,

qq.`正价支付时间`,qq.`正价金额`


from

(select  dwd.udf_decrypt(mobile) as `phone`,from_unixtime(pay_time) as `体验课支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where course_id=2713  and class_id=4893 and status=2) ww

left join

(select  dwd.udf_decrypt(mobile) as `phone`,amount as `正价金额`,from_unixtime(pay_time) as `正价支付时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where

course_id in ('2778','2802') and

status=2) qq

on ww.`phone`=qq.`phone`

left join

(select min(hh.created_at) as `最早到课时间`,uu.mobile

from ods_lps_kkb_cloud_edu.content_study_progress hh

left join ods_lps_kkb_cloud_passport.`user` uu on uu.uid=hh.student_uid

where hh.course_id='214246'  and  hh.content_type in ('7','16')

group by uu.mobile) rr

on rr.mobile=ww.`phone`




# 82、雅思体验课各种X课率-田萧萧
--003期

select

ee.item_name as `课程名称`,

ee.course_Id,

uu.`期`,

ee.`报名数`,

uu.`章`,

uu.`节`,

uu.`内容`,

uu.`到课数`,

concat(round(uu.`到课数`/ ee.`报名数`*100,2),"%") as `到课率`,

uu.`完课数`,

concat(round(uu.`完课数`/ ee.`报名数`*100,2),"%") as `完课率`,

uu.`回放数`,

concat(round(uu.`回放数`/ ee.`报名数`*100,2),"%") as `回放率`,

uu.`到课数+回放数`,

concat(round(uu.`到课数+回放数`/ee.`报名数`*100,2),"%") as `到课数+回放数率`,

uu.`交作业数`,

concat(round(uu.`交作业数`/ee.`报名数`*100,2),"%") as `交作业率`


from



(select item_name,course_id,class_id,count(mobile) as `报名数`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where course_id ='2713' and class_Id='5190' and status=2

group by course_id,item_name,class_id)ee

left join

(

--uu开始

select

dd.`章`,

dd.`节`,

dd.`内容`,

dd.course_Id,

dd.class_Id,

dd.`期`,

count(case when dd.`内容类型`='hk直播' and  (dd.`学习时长(min)`-dd.`回放时长(min)`)>0 then 'dd.`手机号`' else null end) as `到课数`,

count(case when dd.`内容类型`='hk直播' and  (dd.`学习时长(min)`-dd.`回放时长(min)`)>60 then 'dd.`手机号`' else null end) as `完课数`,

count(case when dd.`内容类型`='回放' then 'dd.`手机号`' else null end ) as `回放数`,

count(case when dd.`内容类型`='hk直播' and  (dd.`学习时长(min)`-dd.`回放时长(min)`)>0 then 'dd.`手机号`' else null end)

+count(case when dd.`内容类型`='回放' then 'dd.`手机号`' else null end )  as `到课数+回放数`,

count(case when dd.`内容类型`='作业' then 'dd.`手机号`' else null end ) as `交作业数`

from

(--dd开始

select

distinct

aaa.`手机号`,

aaa.course_id,

aaa.class_Id,

aaa.`期`,

bbb.chapter_name as `章`,

bbb.group_name as `节`,

bbb.content_title as `内容`,

-- bbb.content_Id as `内容id`,

bbb.`内容类型`,

round(bbb.study_time/60,2) as `学习时长(min)`,

round(bbb.playback_time/60,2) as `回放时长(min)`

from

(select distinct vo.course_Id,vo.class_Id, vo.nickname,dwd.udf_decrypt(vo.mobile) as `手机号`,vo.unionid,vo.out_order_Id as `订单号`,

vc.name as `期`,

from_unixtime(vo.pay_time) as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from ods_oldmos_kkb_cloud_vipcourse.vip_order vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id and vo.class_id=vc.id

where vo.course_id ='2713' and vo.class_id='5190' and vo.status=2 ) aaa

left  join

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.study_time,

iii.unionid,

iii.mobile,

mm.playback_time,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业' when 7 then '回放' when 16 then 'hk直播' end as `内容类型`,

tt.chapter_name,

gg.group_name ,

nn.content_title

from (  select * from ods_lps_kkb_cloud_edu.content_study_progress where course_id='214564')mm

left join

(select distinct ss.uid,uu.unionid,ss.mobile

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_lps_kkb_cloud_edu.group  gg on gg.section_id=mm.section_id

left join ods_lps_kkb_cloud_edu.content nn on nn.content_Id=mm.content_Id

where mm.content_type in ('1','3','4','16','7')

) bbb

on aaa.`手机号`=bbb.mobile and aaa.new_course_id=bbb.course_id

--dd结束

)dd

group by

dd.`章`,

dd.`节`,

dd.`内容`,

dd.course_Id,

dd.class_Id,

dd.`期`

--uu结束

) uu

on uu.course_Id=ee.course_id and uu.class_id=ee.class_id




# 83、岗位课对应的newcourse_Id
select distinct

case aa.subject_name when '数据大课' then '岗位课'

when'UXD'then '岗位课'

when'PM'then '岗位课'

when'短视频直播运营'then '岗位课'

when'运营'then '岗位课'

when'JAVA'then '岗位课'

when 'Java' then '岗位课'

when 'Web' then '岗位课'

when'web'then '岗位课'

when 'WEB' then '岗位课'

when'AI'then '岗位课'

when'新职课'then '岗位课'

when '新职课web'then '岗位课'

when '新职课java'then '岗位课'

when '新职课python'then '岗位课'

when '新职课C++'then '岗位课'

when '新职课云实习'then '岗位课'

when'全品类'then '岗位课'

when '大数据开发'then '岗位课'

when 'Python全栈'then '岗位课'

when '数据挖掘'then '岗位课'

when '云实习'then '岗位课'

when  'DBG付费社群'then '岗位课'

when  'DTG付费社群'then '岗位课'

when  '数据中课' then '赋能课'

when  'Python小课' then '赋能课'

when  '小课畅学卡' then '赋能课'

when  '职业素质' then '赋能课'

when  '传统行业' then '赋能课'

when '财商'then '拓展课'

when 'WBO财商' then '拓展课' end as `课程类型`,

aa.subject_name,bb.new_course_Id

from

(select distinct concat(course_Id,class_id) as `合并id`,subject_name

from

dwd.vipcourse_order_f

where amount>1000 and status=2 and course_type=0 ) aa

left join

(select distinct concat(course_id,id) as `合并id`,new_course_Id

from

ods_oldmos_kkb_cloud_vipcourse.vip_class) bb

on aa.`合并id`=bb.`合并id`

# 84、求每月到课人数
SELECT substr(p.updated_at,1,7),

count(distinct(p.student_uid))

FROM (select * from  ods_lps_kkb_cloud_edu.content_study_progress

where course_Id in ('bb.new_course_id',

'NULL',

'210069',

'210070',

'210116',

'210117',

'210169',

'210201',

'210205',

'210210',

'210211',

'210266',

'210368',

'210375',

'210376',

'210377',

'210386',

'210389',

'210417',

'210442',

'210447',

'210455',

'210456',

'210458',

'210685',

'210686',

'210690',

'210691',

'210692',

'210693',

'210694',

'210695',

'210701',

'210703',

'210713',

'210764',

'210765',

'210766',

'210780',

'210935',

'210995',

'210996',

'210997',

'210998',

'211014',

'211015',

'211138',

'211139',

'211140',

'211141',

'211142',

'211143',

'211329',

'211330',

'211349',

'211350',

'211351',

'211352',

'211353',

'211354',

'211392',

'211509',

'211515',

'211517',

'211591',

'211592',

'211650',

'211651',

'211652',

'211653',

'211654',

'211655',

'211656',

'211869',

'211870',

'211871',

'211872',

'211892',

'211893',

'212145',

'212388',

'212509',

'212669',

'212670',

'212671',

'212672',

'212673',

'212674',

'212685',

'212793',

'212796',

'212872',

'213288',

'213289',

'213290',

'213291',

'213328',

'213329',

'213330',

'213331',

'213433',

'214203',

'214204',

'214205',

'214206',

'214647',

'213364',

'214648',

'213464',

'213709',

'213710',

'213711',

'214572',

'NULL',

'210138',

'210145',

'210153',

'210172',

'210182',

'210193',

'210231',

'210267',

'210293',

'210294',

'210366',

'210402',

'210670',

'210688',

'210851',

'210976',

'210977',

'211043',

'211101',

'211249',

'211271',

'211327',

'211487',

'211553',

'211580',

'211849',

'211851',

'212101',

'212140',

'212309',

'212368',

'212511',

'212559',

'212586',

'212934',

'213054',

'213070',

'213132',

'213361',

'213395',

'213458',

'213517',

'213989',

'214235',

'214490',

'214631',

'NULL',

'210073',

'210126',

'210185',

'210229',

'210287',

'210306',

'210314',

'210370',

'210678',

'210682',

'210683',

'210733',

'210955',

'210978',

'211023',

'211126',

'211127',

'211447',

'211451',

'211452',

'211825',

'211826',

'211828',

'212041',

'212202',

'212206',

'212410',

'212420',

'212554',

'212738',

'212766',

'212768',

'212813',

'212814',

'212886',

'213118',

'213174',

'213333',

'213334',

'213335',

'213418',

'213883',

'213898',

'213899',

'213900',

'214569',

'214607',

'214608',

'214767',

'211517',

'212650',

'212684',

'NULL',

'210080',

'210082',

'210124',

'210125',

'210136',

'210218',

'210261',

'210309',

'210310',

'210344',

'210379',

'210906',

'211318',

'211617',

'NULL',

'210143',

'210144',

'210151',

'210179',

'210180',

'210291',

'210295',

'210322',

'210364',

'210408',

'210466',

'210648',

'210669',

'210913',

'210945',

'211100',

'211145',

'211218',

'211302',

'211477',

'211581',

'211694',

'211855',

'212072',

'212103',

'212132',

'212327',

'212328',

'212591',

'212592',

'212928',

'212933',

'213372',

'213373',

'213930',

'213936',

'214176',

'214366',

'NULL',

'210071',

'210161',

'210276',

'210380',

'210621',

'210968',

'211006',

'211197',

'211485',

'211837',

'212310',

'212562',

'212651',

'212856',

'213034',

'NULL',

'210043',

'210072',

'210130',

'210141',

'210160',

'210369',

'210532',

'210620',

'210969',

'210975',

'211007',

'211210',

'211446',

'211736',

'212058',

'212181',

'212467',

'212728',

'212752',

'213187',

'213384',

'213400',

'213607',

'213617',

'213762',

'213974',

'214317',

'214544',

'213471',

'214539',

'211752',

'211831',

'213706',

'214393',

'210753',

'211315',

'212433',

'212585',

'213704',

'214065',

'214398',

'210752',

'212454',

'212590',

'210734',

'212456',

'213702',

'214057',

'212844',

'213471',

'213588',

'213673',

'214167',

'214455',

'214497',

'214591',

'211326',

'211920',

'212345',

'212421',

'212795'

)

) p

JOIN (

SELECT a.uid

FROM dwd.mkt_er_order_a b

JOIN dwd.pub_user_customer_f a ON a.customer_id=b.customer_id

WHERE

b.status=2

AND b.amount>1000

AND b.subject_name IN (

'UXD','PM','短视频直播运营','JAVA','Java','Web','web','WEB','AI','新职课','新职课web','新职课java','新职课python','新职课C++',

'新职课云实习','全品类','大数据开发','Python全栈','数据挖掘','云实习','DBG付费社群','DTG付费社群')

) o on o.uid=p.student_uid

group by substr(p.updated_at,1,7)


# 85、季度上课数据-郭萌
SELECT

case when

substr(p.updated_at,1,7)='2019-01' then '2019季度1'

when substr(p.updated_at,1,7)='2019-02' then  '2019季度1'

when substr(p.updated_at,1,7)='2019-03' then  '2019季度1'

when substr(p.updated_at,1,7)='2019-04' then '2019季度2'

when substr(p.updated_at,1,7)='2019-05' then  '2019季度2'

when substr(p.updated_at,1,7)='2019-06' then  '2019季度2'


when substr(p.updated_at,1,7)='2019-07' then '2019季度3'

when substr(p.updated_at,1,7)='2019-08' then  '2019季度3'

when substr(p.updated_at,1,7)='2019-09' then  '2019季度3'


when substr(p.updated_at,1,7)='2019-10' then '2019季度4'

when substr(p.updated_at,1,7)='2019-11' then  '2019季度4'

when substr(p.updated_at,1,7)='2019-12' then  '2019季度4'


when substr(p.updated_at,1,7)='2020-01' then '2020季度1'

when substr(p.updated_at,1,7)='2020-02' then '2020季度1'

when substr(p.updated_at,1,7)='2020-03' then '2020季度1'


when substr(p.updated_at,1,7)='2020-04' then '2020季度2'

when substr(p.updated_at,1,7)='2020-05' then '2020季度2'

when substr(p.updated_at,1,7)='2020-06' then '2020季度2'

when substr(p.updated_at,1,7)='2020-07' then '2020季度3'

when substr(p.updated_at,1,7)='2020-08' then '2020季度3'

when substr(p.updated_at,1,7)='2020-09' then '2020季度3'


when substr(p.updated_at,1,7)='2020-10' then '2020季度4'

when substr(p.updated_at,1,7)='2020-11' then '2020季度4'

when substr(p.updated_at,1,7)='2020-12' then '2020季度4'


when substr(p.updated_at,1,7)='2021-01' then '2021季度1'

when substr(p.updated_at,1,7)='2021-02' then '2021季度1'

when substr(p.updated_at,1,7)='2021-03' then '2021季度1'

end as `季度`,

-- substr(p.updated_at,1,7),

count(distinct(p.student_uid))

FROM (select * from  ods_lps_kkb_cloud_edu.content_study_progress

where course_Id in ('212712',

'212733',

'213341',

'213830',

'214485'

)

) p

JOIN (

SELECT a.uid

FROM dwd.mkt_er_ord_a b

JOIN dwd.pub_user_customer_f a ON a.customer_id=b.customer_id

WHERE

b.status=2

AND b.amount>1000

AND b.subject_name IN ('财商','WBO财商')

) o on o.uid=p.student_uid

group by

case when

substr(p.updated_at,1,7)='2019-01' then '2019季度1'

when substr(p.updated_at,1,7)='2019-02' then  '2019季度1'

when substr(p.updated_at,1,7)='2019-03' then  '2019季度1'

when substr(p.updated_at,1,7)='2019-04' then '2019季度2'

when substr(p.updated_at,1,7)='2019-05' then  '2019季度2'

when substr(p.updated_at,1,7)='2019-06' then  '2019季度2'


when substr(p.updated_at,1,7)='2019-07' then '2019季度3'

when substr(p.updated_at,1,7)='2019-08' then  '2019季度3'

when substr(p.updated_at,1,7)='2019-09' then  '2019季度3'


when substr(p.updated_at,1,7)='2019-10' then '2019季度4'

when substr(p.updated_at,1,7)='2019-11' then  '2019季度4'

when substr(p.updated_at,1,7)='2019-12' then  '2019季度4'


when substr(p.updated_at,1,7)='2020-01' then '2020季度1'

when substr(p.updated_at,1,7)='2020-02' then '2020季度1'

when substr(p.updated_at,1,7)='2020-03' then '2020季度1'


when substr(p.updated_at,1,7)='2020-04' then '2020季度2'

when substr(p.updated_at,1,7)='2020-05' then '2020季度2'

when substr(p.updated_at,1,7)='2020-06' then '2020季度2'

when substr(p.updated_at,1,7)='2020-07' then '2020季度3'

when substr(p.updated_at,1,7)='2020-08' then '2020季度3'

when substr(p.updated_at,1,7)='2020-09' then '2020季度3'


when substr(p.updated_at,1,7)='2020-10' then '2020季度4'

when substr(p.updated_at,1,7)='2020-11' then '2020季度4'

when substr(p.updated_at,1,7)='2020-12' then '2020季度4'


when substr(p.updated_at,1,7)='2021-01' then '2021季度1'

when substr(p.updated_at,1,7)='2021-02' then '2021季度1'

when substr(p.updated_at,1,7)='2021-03' then '2021季度1'

end

# 86、声音变现课需求-于笛
select

ppp.`购买课程`,

-- ppp.`内容`,

count(ppp.`订单号`) as `报名数实际`,

count(ppp.`手机号`) as `报名数`,

count(ppp.`是否激活`) as `激活数`,

concat(round(count(ppp.`是否激活`) /count(ppp.`手机号`)*100,2),"%") as `激活率(激活数/报名数)）`,

count(ppp.`是否到课`)as `到课数`,

concat(round(count(ppp.`是否到课`)/count(ppp.`是否激活`)*100,2),"%") as `到课率(到课数/激活数)`,

count(ppp.`是否完课`) as `完课数`,

concat(round(count(ppp.`是否完课`) /count(ppp.`是否到课`)*100,2),"%") as `完课率(完课数/到课数)`,

round(sum(ppp.`到课时长(min)`)/count(ppp.`是否到课`),2) as `平均观看时间长(min)(总时长/到课数)`,

count(ppp.`是否转化`) as `转化数`

from

(

select  distinct aaa.nickname as `学员昵称`,

aaa.`手机号`,

aaa.`订单号`,

-- kkk.`激活手机号`,

case when kkk.`激活手机号`=aaa.`手机号` then '是' else null end as `是否激活`,

-- aaa.`订单号`,

-- aaa.`支付时间` ,

aaa.item_name as `购买课程`,

-- aaa.course_Id as `课程id`,

-- aaa.amount `支付金额`,

-- aaa.seller_name `所属销售`,

-- bbb.chapter_name as `章`,

-- bbb.group_name as `节`,

bbb.content_title as `内容`,

-- bbb.content_Id as `内容id`,

-- bbb.`内容类型`,

round((bbb.study_time-bbb.playback_time)/60,2) as `到课时长(min)`,

case when aaa.`支付时间` <=rrr.`转化时间` and  bbb.created_at <rrr.`转化时间`   then '是' else null end `是否转化`,

case when round((bbb.study_time-bbb.playback_time)/60,2) >0 then '是' else null end as `是否到课`,

case when round((bbb.study_time-bbb.playback_time)/60,2) >=60 then '是' else null end as `是否完课`

-- round((bbb.study_time-bbb.playback_time)/60,2) as `直播观看时长`

from

(select distinct vo.course_Id,vo.nickname,dwd.udf_decrypt(vo.mobile) as `手机号`,vo.unionid,vo.out_order_Id as `订单号`,

vo.pay_time as `支付时间`,vo.item_name,vo.amount,

vo.seller_name,vc.new_course_id

from (select * from  dwd.mkt_er_order_ha where pt='2021032909') vo

left join ods_oldmos_kkb_cloud_vipcourse.vip_class vc  on vo.course_Id=vc.course_Id

where vo.course_id=2879 and vo.status=2 ) aaa

left  join

(

select distinct vv.course_Id,dwd.udf_decrypt(uu.mobile) as `激活手机号`

from ods_lps_kkb_cloud_edu.course_student vv

left join ods_lps_kkb_cloud_passport.`user` uu  on vv.student_uid=uu.uid

where vv.course_id='214700'

)kkk

on kkk.`激活手机号`=aaa.`手机号`


left join

(select

mm.course_id,

mm.content_id,

mm.student_uid,

mm.created_at,

mm.study_time,

iii.unionid,

iii.`手机号`,

mm.playback_time,

case mm.content_type when 1 then '直播'  when 3 then '点播'

when 4 then '作业'  when 16 then 'hk直播' end as `内容类型`,

tt.chapter_name,

gg.group_name ,

nn.content_title

from (  select * from ods.ods_kkb_cloud_edu__content_study_progress_ha

where course_id='214700' and pt='2021032909')mm

left join

(select distinct ss.uid,uu.unionid,dwd.udf_decrypt(ss.mobile) as `手机号`

from  ods_lps_kkb_cloud_passport.user ss

left join ods_lps_kkb_cloud_passport.user_wechat_map uu on uu.uid=ss.uid

where uu.unionid!='') iii on iii.uid=mm.student_uid

left join ods_lps_kkb_cloud_edu.chapter tt on tt.chapter_id=mm.chapter_id

left join ods_lps_kkb_cloud_edu.group  gg on gg.section_id=mm.section_id

left join ods_lps_kkb_cloud_edu.content nn on nn.content_Id=mm.content_Id

where mm.content_type in ('16')) bbb

on aaa.`手机号`=bbb.`手机号` and aaa.new_course_id=bbb.course_id


left join

(select

dwd.udf_decrypt(mobile) as `转化手机号`,

from_unixtime(pay_time)as `转化时间`

from ods_oldmos_kkb_cloud_vipcourse.vip_order

where course_id=2891 and status=2) rrr

on rrr.`转化手机号`=aaa.`手机号`

) ppp

group by ppp.`购买课程`

# 87、小课正价上课人数2019Q4补充-郭萌
select

count(distinct(aaa.customer_Id)) as `人数`,

case

when substr(aaa.created_at,1,7) ='2019-08' then '2019Q3'

when substr(aaa.created_at,1,7) ='2019-09' then '2019Q3'

when substr(aaa.created_at,1,7) ='2019-10' then '2019Q4'

when substr(aaa.created_at,1,7) ='2019-11' then '2019Q4'

when substr(aaa.created_at,1,7) ='2019-12' then '2019Q4'


when substr(aaa.created_at,1,7) ='2020-01' then '2020Q1'

when substr(aaa.created_at,1,7) ='2020-02' then '2020Q1'

when substr(aaa.created_at,1,7) ='2020-03' then '2020Q1'

when substr(aaa.created_at,1,7) ='2020-04' then '2020Q2'

when substr(aaa.created_at,1,7) ='2020-05' then '2020Q2'

when substr(aaa.created_at,1,7) ='2020-06' then '2020Q2'

when substr(aaa.created_at,1,7) ='2020-07' then '2020Q3'

when substr(aaa.created_at,1,7) ='2020-08' then '2020Q3'

when substr(aaa.created_at,1,7) ='2020-09' then '2020Q3'


when substr(aaa.created_at,1,7) ='2020-10' then '2020Q4'

when substr(aaa.created_at,1,7) ='2020-11' then '2020Q4'

when substr(aaa.created_at,1,7) ='2020-12' then '2020Q4'

when substr(aaa.created_at,1,7) ='2021-01' then '2021Q1'

when substr(aaa.created_at,1,7) ='2021-02' then '2021Q1'

when substr(aaa.created_at,1,7) ='2021-03' then '2021Q1'

end as `季度`

-- substr(aaa.created_at,1,7) as `月份`



from


(select user_id

from dwd.mkt_er_order_a

where subject_name='Python小课'

and status=2 and amount>1000) bbb



left join

(select created_at,customer_id from

dwd.fct_study_task_learn_f

where  course_id in ('0d47585b-985b-4db9-b2fb-3feea3c4a530',

'04c0de61-a183-41b3-9646-fb2ebf61c4fe',

'52c2d06b-abc1-4776-a353-53c892e2b0b0',

'c93e2f64-dd72-454f-9694-cd5c97f3edeb',

'9efcc70f-b3d3-4753-a486-5aa9e6d94175',

'1e282939-2340-4b6f-ba7e-d13250aa126a',

'9a69b524-f849-46ed-bcaa-35f89bfa6b58',

'a43561de-a132-4603-8a63-8e7256294223',

'9d8c283e-10fc-4494-9611-97488afa3e17') and status='30') aaa

on aaa.customer_id=bbb.user_id

-- where bbb.user_id is not null

group by

case

when substr(aaa.created_at,1,7) ='2019-08' then '2019Q3'

when substr(aaa.created_at,1,7) ='2019-09' then '2019Q3'

when substr(aaa.created_at,1,7) ='2019-10' then '2019Q4'

when substr(aaa.created_at,1,7) ='2019-11' then '2019Q4'

when substr(aaa.created_at,1,7) ='2019-12' then '2019Q4'


when substr(aaa.created_at,1,7) ='2020-01' then '2020Q1'

when substr(aaa.created_at,1,7) ='2020-02' then '2020Q1'

when substr(aaa.created_at,1,7) ='2020-03' then '2020Q1'

when substr(aaa.created_at,1,7) ='2020-04' then '2020Q2'

when substr(aaa.created_at,1,7) ='2020-05' then '2020Q2'

when substr(aaa.created_at,1,7) ='2020-06' then '2020Q2'

when substr(aaa.created_at,1,7) ='2020-07' then '2020Q3'

when substr(aaa.created_at,1,7) ='2020-08' then '2020Q3'

when substr(aaa.created_at,1,7) ='2020-09' then '2020Q3'


when substr(aaa.created_at,1,7) ='2020-10' then '2020Q4'

when substr(aaa.created_at,1,7) ='2020-11' then '2020Q4'

when substr(aaa.created_at,1,7) ='2020-12' then '2020Q4'

when substr(aaa.created_at,1,7) ='2021-01' then '2021Q1'

when substr(aaa.created_at,1,7) ='2021-02' then '2021Q1'

when substr(aaa.created_at,1,7) ='2021-03' then '2021Q1'

end

# 88、盗版课程追踪-刘志超
select aa.`年度`,dd.`学院`,cc.`学科`,aa.`课程名称`,aa.course_Id,aa.`课程类型`,aa.`章数`,aa.`节数`,bb.`视频类型`,bb.`视频数`

from

(select

course_Id,

school_id,

course_name as `课程名称`,

chapter_count as `章数`,

section_count as `节数`,

substr(created_at,1,4) as `年度`,

case when type=1 then '体系课'

when type=2 then '公开课'

when type=3 then '微课'

when type=4 then '小课'

when type=5 then '就业课'

when type=6 then '真北课程'

when type=7 then '线下课'

when type=8 then '普通公开课'

when type=9 then '体验课'

when type=10 then 'TBL课(任务制教学)' end as `课程类型`

from ods_lps_kkb_cloud_edu.course ) aa

left join

(select distinct school_id,school_name as `学院`

from ods_lps_kkb_cloud_edu.school)dd

on dd.school_id=aa.school_id

left join

(select course_id,

case when content_type=1 then '直播'

when content_type=2 then '直播'

when content_type=16 then '直播'

when content_type=3 then '点播'

when content_type=7 then '直播'

end as `视频类型`,

count(content_Id) as `视频数`

from ods_lps_kkb_cloud_edu.content

where content_type in ('3','1','2','7','16')

group by course_id,case when content_type=1 then '直播'

when content_type=2 then '直播'

when content_type=16 then '直播'

when content_type=3 then '点播'

when content_type=7 then '直播'

end

) bb

on aa.course_id=bb.course_id

left join

(select  vc.new_course_Id,max(ss.name) as `学科`

from ods_oldmos_kkb_cloud_vipcourse.vip_class  vc

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vo on vo.id=vc.course_id

left join ods_oldmos_kkb_cloud_account.sys_subject ss on ss.id=vo.subject_id

-- left join dwd.mkt_er_order_a me

-- on me.course_id=vc.course_id

group by vc.new_course_Id

) cc

on cc.new_course_Id=aa.course_id

where dd.`学院` not like '%测试%' and aa.`课程名称` not like '%测试%'

-------------------------我是分割线------------------------------------

select aa.`年度`,dd.`学院`,cc.`学科`,aa.`课程名称`,aa.course_Id,aa.`课程类型`,aa.`章数`,aa.`节数`,bb.`视频数`

from

(select

course_Id,

school_id,

course_name as `课程名称`,

chapter_count as `章数`,

section_count as `节数`,

substr(created_at,1,4) as `年度`,

case when type=1 then '体系课'

when type=2 then '公开课'

when type=3 then '微课'

when type=4 then '小课'

when type=5 then '就业课'

when type=6 then '真北课程'

when type=7 then '线下课'

when type=8 then '普通公开课'

when type=9 then '体验课'

when type=10 then 'TBL课(任务制教学)' end as `课程类型`

from ods_lps_kkb_cloud_edu.course ) aa

left join

(select distinct school_id,school_name as `学院`

from ods_lps_kkb_cloud_edu.school)dd

on dd.school_id=aa.school_id

left join

(select course_id,count(content_Id) as `视频数`

from ods_lps_kkb_cloud_edu.content

where content_type in ('3','1','2','7','16')

group by course_id) bb

on aa.course_id=bb.course_id

left join

(select  vc.new_course_Id,max(ss.name) as `学科`

from ods_oldmos_kkb_cloud_vipcourse.vip_class  vc

left join ods_oldmos_kkb_cloud_vipcourse.vip_course vo on vo.id=vc.course_id

left join ods_oldmos_kkb_cloud_account.sys_subject ss on ss.id=vo.subject_id

-- left join dwd.mkt_er_order_a me

-- on me.course_id=vc.course_id

group by vc.new_course_Id

) cc

on cc.new_course_Id=aa.course_id

where dd.`学院` not like '%测试%' and aa.`课程名称` not like '%测试%'

# 89、项目数据完退续支持-雪玲
select

cc.course_id,

cc.course_name as `课程名称`,

se.education_name as `教务学科`,

dd.finish_live_course_rate as `直播完课率`,

dd.finish_playback_course_rate as `回放完课率`,

course_stu_cnt as `班级人数`,

ii.`已更新进度/直播数`

from ods_lps_kkb_cloud_edu.course cc

left join ods_oldmos_kkb_cloud_account.sys_education se

on cc.education_id=se.id

left join

(

select ww.course_id,ww.`直播数`/qq.`更新数` as `已更新进度/直播数`

from

(select course_id,count(*) as `更新数`

from ods_lps_kkb_cloud_edu.live_lesson

where disabled='0'

group by course_id) qq

left join

(select course_id,count(*) as `直播数`

from ods_lps_kkb_cloud_edu.content

where content_type in ('1','7','16')

group by course_id) ww

on ww.course_id=qq.course_id

) ii

on ii.course_id=cc.course_id

left join

(select distinct

finish_live_course_rate,finish_playback_course_rate,course_stu_cnt,lps_course_id

from

dws.edu_fct_kpi_class_teacher_course_a) dd

on dd.lps_course_Id=cc.course_id

where cc.course_id in ()


