--menglei
--2018/08/01 晚 查询维修保洁雇佣人员
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryFrequenters', 'select  t.user_name label,t.user_id value
  from TB_C_FREQUENTER t
 where t.status = ''1''  and(
 { t.user_id = ?}
 {or t.user_name like ''%'' || ? || ''%''} 
 {or t.city in (select c.admini_code from tb_p_city c where c.admini_name like ''%'' || ? || ''%'' and c.rank = ''1'') }
 {or t.district in (select c.admini_code from tb_p_city c where c.admini_name like ''%'' || ? || ''%'' and c.rank = ''2'') })', 'dsOracle', '查询雇佣人员');
 
 
 
 --2018/08/02
 --民宿查询预到订单添加status='1'
UPDATE TP_C_SQLINFO s
set s.sql_info = 'select * from tb_p_order o
where  to_char(o.arrival_time,''yyyy/MM/dd'') = to_char(sysdate,''yyyy/MM/dd'')
and  o.branch_id=?
and o.status = ''1'''
where s.sql_name = 'queryarrivalorder';
commit;


--2018/08/02
--操作日志修改时间显示bug
UPDATE TP_C_SQLINFO s
set s.sql_info = 'select t.log_id LOGID,(select s.param_name from Tp_c_Sysparam s where s.param_type = ''OPER_TYPE'' and s.content = t.oper_type) OPERTYPE, t.oper_module OPERMODULE, t.content CONTENT, decode(t.record_user,''admin'',''admin'',(select f.staff_name from Tb_c_Staff f where f.staff_id = t.record_user)) RECORDUSER, to_char(t.record_time,''yyyy-MM-dd hh24:mi:ss'') RECORDTIME, t.oper_ip OPERIP, nvl(t.remark, '' '') REMARK from Tl_p_Operatelog t left join Tb_c_Staff tb on t.record_user = tb.staff_id  where t.oper_type != ''6''{and t.branch_id = ? } {and t.oper_type = ? } {and tb.staff_name like ''%'' || ? || ''%''} {and to_date(to_char(t.record_time,''yyyy/MM/dd''),''yyyy/MM/dd'') >= to_date(?,''yyyy/MM/dd'')} {and to_date(to_char(t.record_time,''yyyy/MM/dd''),''yyyy/MM/dd'') <= to_date(?,''yyyy/MM/dd'')} order by t.record_time desc
' where s.sql_name = 'operateLog';
commit;
--2018/08/02
--操作日志修改时间显示bug
UPDATE TP_C_SQLINFO s
set s.sql_info = 'select t.branch_id,
       t.log_id LOGID,
       (select s.param_name
          from Tp_c_Sysparam s
         where s.param_type = ''OPER_TYPE''
           and s.content = t.oper_type) OPERTYPE,
       t.oper_module OPERMODULE,
       t.content CONTENT,
       decode(t.record_user,''admin'',''admin'',(select f.staff_name from Tb_c_Staff f where f.staff_id = t.record_user)) RECORDUSER,
       to_char(t.record_time, ''yyyy-MM-dd hh24:mi:ss'') RECORDTIME,
       t.oper_ip OPERIP,
       nvl(t.remark, '' '') REMARK
  from Tl_p_Operatelog t left join Tb_c_Staff tb
    on t.record_user = tb.staff_id
   where t.branch_id in (select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} || ''%'') {and t.oper_type = ? } {and
 tb.staff_name like ''%'' || ? || ''%'' } {and
 to_date(to_char(t.record_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') >=
       to_date(?, ''yyyy/MM/dd'') } {and
 to_date(to_char(t.record_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') <=
       to_date(?, ''yyyy/MM/dd'') }
 order by t.record_time desc'
where s.sql_name = 'operateLogforHouse';
commit;

--2018/08/02
--更新公寓合同卡房间sql
UPDATE TP_C_SQLINFO s
set s.sql_info='select r.room_id roomid,
       r.room_type roomtype,
       r.branch_id,
       (select t.room_name
          from TP_P_ROOMTYPE t
         where t.room_type = r.room_type
           and t.branch_id = ?) roomname2
  from tb_p_room r
 where r.theme = 2
   and (r.status = ''3'' or r.status = ''1'' or r.status = ''2'' or
       r.status = ''W'')
   and r.branch_id = ?
   and r.room_id not in
       (select t.room_id 
          from tb_p_contrart t
         where t.branch_id = ?
           and (t.status = ''4''
           or ?  = to_char(t.start_time, ''yyyy/mm/dd'')) )'
where s.sql_name = 'queryreversedroomid';
commit;

--2018/08/03
--新建标签管理序列

create sequence SEQ_NEWTIPS_ID
minvalue 18
maxvalue 99
start with 18
increment by 1
cache 10
cycle;

--2018/08/03
--CRM新增查询sql,查询入住须知标签
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryTips', 'select s.order_no orderno,s.content from tp_c_sysparam  s where s.param_type = ''TIPS'' and status = ''1''', 'dsOracle', '查询入住须知标签crm');


