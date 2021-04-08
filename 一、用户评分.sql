一、用户评分
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






