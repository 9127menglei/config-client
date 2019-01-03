--menglei
--2018/06/25 审核维修记录取消后仍然存在sql修复


 UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select * from( select decode(a.apply_id, null, '' '', ''房价申请'') tableaudittype,a.apply_id operid,a.post paramcode1,a.branch_id branchid,transTitles(a.record_user,''TB_C_STAFF'',''STAFF_ID'',''STAFF_NAME'') recorduser,to_char(a.record_time, ''yyyy/MM/dd'') recordtime, a.audit_remark auditremark,a.remark remark,s.staff_name staffname,b.branch_name branchname from TB_P_PRICEAPPLY a, tb_c_staff s, tb_c_branch b
where a.record_user = s.staff_id(+)
and a.branch_id = b.branch_id(+)
and a.post like ''%'' || $POST || ''%''
and a.post is not null
union all
select decode(r.repairapply_id, null, '' '', ''维修申请'') tableaudittype,r.repairapply_id operid,r.post paramcode1,r.branch_id branchid, (case when (r.contract_id IS NULL) then
          transtitles(r.reserved_person,
                       ''tb_c_staff'',
                       ''staff_id'',
                       ''staff_name'')
         else
          transtitles(r.reserved_person,
                       ''tb_c_member'',
                       ''member_id'',
                       ''member_name'')
       end) recorduser,to_char(r.record_time, ''yyyy/MM/dd'') recordtime, r.audit_remark auditremark, r.remark remark,
(case
         when (r.contract_id IS NULL) then
          transtitles(r.reserved_person,
                       ''tb_c_staff'',
                       ''staff_id'',
                       ''staff_name'')
          
         else
          transtitles(r.reserved_person,
                       ''tb_c_member'',
                       ''member_id'',
                       ''member_name'')
       end) staffname,
b.housename branchname from TB_P_REPAIRAPPLY r, tb_p_house b
where r.branch_id = b.house_id(+)
and r.branch_id like ''%H%''
and r.post like ''%'' || $POST || ''%''
and r.status in (''1'',''2'')
) apd
where apd.staffname like ''%'' || :AUDITRECORDUSER || ''%''
and apd.branchname like ''%'' || :AUDITBRANCHID || ''%''
and apd.tableaudittype like ''%'' || :TABLEAUDITTYPE || ''%''
order by apd.recordtime desc'
 where s.sql_name = 'reportAuditAll';
 commit;
 
 --2018/06/25 民宿结账提醒 数据按照时间排序
 
 UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select c.order_id,
       c.branch_id,
       c.room_id,
       c.room_type,
       (select h.housename from Tb_p_House h where h.house_id = c.branch_id) room_name,
       m.member_name,
       c.status,
       decode(c.status,
               ''0'',
               ''取消'',
               ''1'',
               ''新订'',
               ''2'',
               ''未到'',
               ''3'',
               ''在住/转单'',
               ''4'',
               ''离店'',
               ''5'',
               ''删除'',
               ''6'',
               ''已退
未结'') statusname,
       m.mobile,
       c.room_price,
       c.remark,
       to_char(c.leave_time, ''yyyy/MM/dd'') checkout_time,
       autorefund,
       c.guarantee
  from Tb_p_Order c
  left join Tb_c_Member m
    on c.order_user = m.member_id
 where c.status = ''6''
 {and c.order_user in (select tm.member_id from Tb_c_Member tm where tm.member_name like ''%'' || ? || ''%'') }
 {and c.order_user like ''%'' || ? || ''%'' }
 {and m.member_name like ''%'' || ? || ''%'' }
 {and to_date(to_char(c.arrival_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') >= to_date(?, ''yyyy/MM/dd'')}
 {and to_date(to_char(c.leave_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') <= to_date(?, ''yyyy/MM/dd'')}
 {and c.source like ''%'' || ? || ''%'' }
 {and c.room_type like ''%'' || ? || ''%'' }
 {and m.mobile like ''%'' || ? || ''%'' }
 {and c.record_user in (select sta.staff_id from tb_c_staff sta where sta.staff_name like ''%'' || ? || ''%'') }
 and c.branch_id in
       (select h.house_id
  from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t
 where h.staff_id = t.houseaccount_name
   {and t.staff_id like ?}
   and t.status = ''1''
   and h.status <> ''0'') {and
 to_date(to_char(c.checkout_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') =
       to_date(?, ''yyyy/MM/dd'') }
       order by c.leave_time desc'
 where s.sql_name = 'HouseCheckOutOrder';
 commit;

 --2018/06/25 民宿保洁按照时间desc排序
 
 UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select c.*
  from (select (select h.house_id
                  from TB_P_HOUSE h
                 where t.branch_id = h.house_id) houseid,
               (select h.housename
                  from TB_P_HOUSE h
                 where t.branch_id = h.house_id) housename,
               to_char(t.clean_time, ''yyyy/MM/dd'') cleanTime,
               t.room_id roomId,
               (select m.member_name
                  from TB_C_MEMBER m
                 where t.reserved_person = m.member_id) reserveperson,
               t.mobile mobile,
               decode(t.status, ''1'', ''未处理'', ''2'', ''已处理'', ''0'', ''已撤销'') status,
               to_char(t.application_time, ''yyyy/MM/dd'') applicationTime,
               t.status statusCode,
               t.cleanapply_id cleanapplyid
          from TB_P_CLEANAPPLY t
         where {t.clean_time like ''%'' || to_date(?, ''yy/MM/dd'') || ''%'' and}
         {t.application_time like ''%'' || to_date(?, ''yy/MM/dd'') || ''%'' and}
         {t.status like ''%'' || ? || ''%'' and}
         1 = 1
           and t.branch_id in (select h.house_id
                                 from Tb_p_House h, TB_C_HOUSEACCOUNT hacc
                                where h.staff_id = hacc.houseaccount_name
                                 {and hacc.staff_id like  ''%'' ||? || ''%''} and hacc.status = ''1''
                                  and h.status != ''0'')) c {where(c.houseid like ''%'' || ? || ''?'' } {or c.housename like ''%'' || ? || ''%'') } order by c.cleantime desc'
 where s.sql_name = 'queryHouseCleanApply';
 commit;


--2018/06/25
--查预抵只修改当前时间相等的订单的民宿
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryarrivalorder', 'select * from tb_p_order o
where  to_char(o.arrival_time,''yyyy/MM/dd'') = to_char(sysdate,''yyyy/MM/dd'')
and  o.branch_id=?', 'dsOracle', '维修查询预抵订单');
 commit;

--2018/06/27 更改datasource表来源状态和名称
update TB_C_DATARESOURCE s
set s.name = '去哪儿'
where s.member_id = '2';
commit;
update TB_C_DATARESOURCE s
set s.name = '小程序'
where s.member_id = '4';
commit;
update TB_C_DATARESOURCE s
set s.status = '0'
where s.member_id = '5' or s.member_id = '8';
commit;









