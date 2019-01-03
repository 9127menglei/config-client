
----menglei----
--2018/05/27
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('querySource', '
select d.member_id memberId,d.name sourcename
from tb_c_dataresource d
where d.status=''1''', 'dsOracle', '查来源');
commit;

insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryHouseListOrder', 'select h.house_id houseId,h.house_no houseNo,h.house_type houseType,h.housename houseName
 from tb_p_house h where h.status <> ''0''', 'dsOracle', '查询所有民宿');
 commit;
 
 insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('houseForwardStatus', 'select t.house_id houseid, decode(nvl(sum(a.nums), 0),''0'',''占用'',''空'') numss from tb_p_house t 
left join( 
select s.house_id houseid, count(s.house_id) nums from tb_p_house s group by s.house_id
union all
select ord.branch_id houseid, -count(ord.branch_id) nums
from tb_p_order ord
where ord.theme = ''3'' and ord.status in(''1'',''3'') 
 and to_char(ord.arrival_time, ''yyyy/MM/dd'') <=  ? 
 and to_char(ord.leave_time, ''yyyy/MM/dd'') >  ?  
group by ord.branch_id
union all 
select hp.branch_id houseid, -count(hp.branch_id) nums
from  tb_p_haltplan hp
where hp.status in (''1'', ''3'')
 and to_char(hp.end_time, ''yyyy/MM/dd'') >= ?  
 and to_char(hp.start_time, ''yyyy/MM/dd'') <=  ? 
group by hp.branch_id   
)a on t.house_id = a.houseid
where t.house_id = ?
group by t.house_id', 'dsOracle', '民宿预定远期房态');
commit;

 UPDATE TP_C_SQLINFO s
  set s.sql_info = 'select m.branchid,m.housetype,m.area,m.floor,m.baseprice,m.price,m.district,m.address,m.beds,m.housename,m.picurl,m.position,m.districtname,m.status
   from (select a.branchid, a.housetype,a.area,a.floor,a.baseprice,a.price,a.district,a.address,a.circle,a.beds,a.housename,b.picurl,c.content position,d.admini_name districtname,nvl(e.status, ''0'') status
  from (select h.house_id branchid,h.house_type housetype, h.area,h.floor,h.init_price baseprice,decode(h.current_price, null, h.init_price, h.current_price) price,
               h.district, h.address,h.position,h.circle,h.beds,h.housename from tb_p_house h
          left join (select j.*
                      from tb_c_branchkeywords j
                     where j.status = ''1'' {and j.keywords like ''%'' || ? || ''%'' }) z
            on h.house_id = z.branch_id
         where {(h.address like ''%'' || ? || ''%''
               or }{ h.housename like ''%'' || ? || ''%'')
           and } { h.city = ?
           and }(h.status = ''1'' or h.status = ''2'' or h.status = ''3'')) a
  left join (select p.pic_url picurl, bp.branch_id branchid
               from tb_p_branchpicture bp, tb_p_picture p
              where bp.pic_style = ''tt'' and bp.status = ''1'' and bp.pic_id = p.pic_id and p.pic_style = ''HP'' and p.status = ''1'') b
    on a.branchid = b.branchid
  left join (select sp.content, sp.param_desc paramdesc from tp_c_sysparam sp where sp.param_type = ''ROOMPOSITION'' and sp.status = ''1'') c
    on a.position = c.paramdesc left join (select ct.* from tb_p_city ct where ct.rank = ''2'') d on a.district = d.admini_code
  left join (select co.* from tb_p_collection co {where co.member_id = ? }) e on a.branchid = e.branch_id) m {where m.circle = ? }'
where s.sql_name = 'getHouseBycirclecode';
commit;

--民宿查脏房sql脚本
--2018/05/29 

insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryhousedirty', '
select house.house_id,house.housename,house.status from tb_p_house house, tb_c_houseaccount t where house.status = ''Z'' and house.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || ? || ''%'' and t.status = ''1''', 'dsOracle', '查民宿脏房');


--operateLogforHouse
----20180528
 UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.branch_id,

       t.log_id LOGID,
       (select s.param_name
          from Tp_c_Sysparam s
         where s.param_type = ''OPER_TYPE''
           and s.content = t.oper_type) OPERTYPE,
       t.oper_module OPERMODULE,
       t.content CONTENT,
       (select f.staff_name
          from Tb_c_Staff f
         where f.staff_id = t.record_user) RECORDUSER,
       to_char(t.record_time, ''yyyy-MM-dd hh:mm:ss'') RECORDTIME,
       t.oper_ip OPERIP,
       nvl(t.remark, '' '') REMARK
  from Tl_p_Operatelog t left join Tb_c_Staff tb
    on t.record_user = tb.staff_id
   where t.branch_id in (select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} || ''%'' and h.status <> ''0'' and t.status = ''1'') {and t.oper_type = ? } {and
 tb.staff_name like ''%'' || ? || ''%'' } {and
 to_date(to_char(t.record_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') >=
       to_date(?, ''yyyy/MM/dd'') } {and
 to_date(to_char(t.record_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') <=
       to_date(?, ''yyyy/MM/dd'') }

 order by t.record_time desc'
 where s.sql_name = 'operateLogforHouse';
 commit;
 
--opLogforHouseHistory
--2018/05/28
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.branch_id,

       t.log_id LOGID,
       (select s.param_name
          from Tp_c_Sysparam s
         where s.param_type = ''OPER_TYPE''
           and s.content = t.oper_type) OPERTYPE,
       t.oper_module OPERMODULE,
       t.content CONTENT,
       (select f.staff_name
          from Tb_c_Staff f
         where f.staff_id = t.record_user) RECORDUSER,
       to_char(t.record_time, ''yyyy-MM-dd hh:mm:ss'') RECORDTIME,
       t.oper_ip OPERIP,
       nvl(t.remark, '' '') REMARK
  from TL_P_OPERATELOG_PAST t left join Tb_c_Staff tb
    on t.record_user = tb.staff_id
   where t.branch_id in (select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} || ''%'' and h.status <> ''0'' and t.status = ''1'') {and t.oper_type = ? } {and
 tb.staff_name like ''%'' || ? || ''%'' } {and
 to_date(to_char(t.record_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') >=
       to_date(?, ''yyyy/MM/dd'') } {and
 to_date(to_char(t.record_time, ''yyyy/MM/dd''), ''yyyy/MM/dd'') <=
       to_date(?, ''yyyy/MM/dd'') }

 order by t.record_time desc'
 where s.sql_name = 'opLogforHouseHistory';
 commit;
 
--loadRepairApply
--2018/05/28
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.repairapply_id repairapplyId,
       t.branch_id branchId,
       t.contract_id contractId,
       t.room_id roomId,
       t.application_date applicationDate,
       nvl(transtitles(t.reserved_person,
                   ''tb_c_member'',
                   ''member_id'',
                   ''member_name''),transtitles(t.reserved_person,
                   ''tb_c_staff'',
                   ''staff_id'',
                   ''staff_name'')) reservedPerson,
       t.mobile,
       decode(t.status, ''0'', ''已取消'', ''1'', ''未审核'', ''2'',''已审核'',''3'',''未修复'',''已修复'') status,
       t.audit_description auditDescripition,
       t.record_time recordtime,
       t.record_user recorduser,
       t.remark,
       t.repair_time repairTime,
       (select s.param_name from tp_c_sysparam s where s.content= t.equipment and s.status=''1'' and s.param_type=''REPAIREQUIPMENTTYPE'') equipment,
       t.emergent,
       t.room_type roomtype,
       t.post,
       t.audit_remark auditRemark
  from tb_p_repairapply t
  left join tb_p_contrart f on 
  t.contract_id=f.contrart_id
  where t.branch_id in (select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} || ''%'' and h.status <> ''0'' and t.status = ''1'')
 {and t.room_id=?}
 order by t.record_time desc'
 where s.sql_name = 'loadRepairApply';
 commit;
 
--repairInHouse
--2018/05/28
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.repairapply_id repairapplyId,
       transtitles(t.branch_id,''tb_p_house'',''house_id'',''housename'') branchId,
       t.contract_id contractId,
       t.room_id roomId,
       t.application_date applicationDate,
       nvl(transtitles(t.reserved_person,
                   ''tb_c_member'',
                   ''member_id'',
                   ''member_name''),transtitles(t.reserved_person,
                   ''tb_c_staff'',
                   ''staff_id'',
                   ''staff_name'')) reservedPerson,
       t.mobile,
       decode(t.status, ''0'', ''已取消'', ''1'', ''未审核'', ''2'',''已审核'',''3'',''未修复'',''已修复'') status,
       t.audit_description auditDescripition,
       t.record_time recordtime,
       t.record_user recorduser,
       t.remark,
       t.repair_time repairTime,
       (select s.param_name from tp_c_sysparam s where s.content= t.equipment and s.status=''1'' and s.param_type=''REPAIREQUIPMENTTYPE'') equipment,
       t.emergent,
       t.room_type roomtype,
       t.post,
       t.audit_remark auditRemark
        from TB_P_REPAIRAPPLY t, TB_P_HOUSE d
where t.branch_id = d.house_id
  and d.house_id in (select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} || ''%'' and h.status <> ''0'' and t.status = ''1'')
 {and d.house_id = ?}'
 where s.sql_name = 'repairInHouse';
 commit;
 
-- fHouseonlyStaffid 查民宿,状态不为0
--2018/05/29
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} || ''%'' and h.status != ''0'' and t.status = ''1'''
 where s.sql_name = 'fHouseonlyStaffid';
 commit;
 
--queryRepairDetailH
--2018/05/29
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.repairapply_id repairapplyId,
       t.branch_id branchId,
       t.contract_id contractId,
       t.room_id roomId,
       t.application_date applicationDate,
       nvl(transtitles(t.reserved_person,
                   ''tb_c_member'',
                   ''member_id'',
                   ''member_name''),transtitles(t.reserved_person,
                   ''tb_c_staff'',
                   ''staff_id'',
                   ''staff_name'')) reservedPerson,
       t.mobile,
       decode(t.status, ''0'', ''已取消'', ''1'', ''未审核'', ''2'',''已审核'',''3'',''未修复'',''已修复'') status,
       t.audit_description auditDescripition,
       t.record_time recordtime,
       t.record_user recorduser,
       t.remark,
       t.repair_time repairTime,
       (select s.param_name from tp_c_sysparam s where s.content= t.equipment and s.status=''1'' and s.param_type=''REPAIREQUIPMENTTYPE'') equipment,
       t.emergent,
       t.room_type roomtype,
       t.audit_description auditdescription,
       t.audit_remark auditremark,
       t.post post,
     (select s.housename from tb_p_house s where s.house_id = t.branch_id) names
  from tb_p_repairapply t
 where {t.branch_id in (select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} ||''%'' and h.status <> ''0'' and t.status = ''1'' {and h.housename like ''%'' || ? || ''%''}) {and t.mobile like ''%'' || ? || ''%'' } {and
      to_char(t.application_date, ''yyyy/MM/dd'') >= ? } {and
      ? >= to_char(t.application_date, ''yyyy/MM/dd'') } {and
      t.equipment = ? } {and t.status = ? }'
 where s.sql_name = 'queryRepairDetailH';
 commit;
 
--HouseNameAndId
--2018/05/29
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select h.house_id houseid,h.house_no houseno,h.house_type housetype,h.housename from tb_p_house h where h.house_id in (select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} ||''%'' and t.status = ''1'') and h.status =''3'''
 where s.sql_name = 'HouseNameAndId';
 commit;
 
 --selecthouseandtrans 民宿双击报错脚本
 --2018/05/30晚
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select h.staff_id manager from tb_p_house h where h.house_id = ?'
 where s.sql_name = 'selecthouseandtrans';
 commit;
 
--newhouseforward
--2018/06/01晚 民宿远期房态
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('newhouseforward', 'select 
          (select count(ord.branch_id) YD from tb_p_order ord where ord.theme = ''3''and ord.status = ''1''
            and to_char(ord.arrival_time, ''yyyy/MM/dd'') <= ?
            and to_char(ord.leave_time, ''yyyy/MM/dd'') > ?
            and ord.branch_id = ?
          group by ord.branch_id) YD,
  
          
        (select count(ord.branch_id) ZZ
           from tb_p_order ord
          where ord.theme = ''3''
            and ord.status = ''3''
            and to_char(ord.arrival_time, ''yyyy/MM/dd'') <= ?
            and to_char(ord.leave_time, ''yyyy/MM/dd'') > ?
            and ord.branch_id = ?
          group by ord.branch_id) ZZ,
        (select count(hp.branch_id) TS
           from tb_p_haltplan hp
          where hp.status in (''1'', ''3'')
            and to_char(hp.end_time, ''yyyy/MM/dd'') > ?
            and to_char(hp.start_time, ''yyyy/MM/dd'') <= ?
            and hp.branch_id = ?
          group by hp.branch_id) TS,
        (select count(rp.branch_id) WX
           from tb_p_repairapply rp
          where rp.status in (''2'', ''3'')
            and to_char(rp.application_date, ''yyyy/MM/dd'') <= ?
            and rp.branch_id = ?
          group by rp.branch_id) WX
FROM dual', 'dsOracle', '民宿远期房态统计最新sql');


--201/8/06/04晚 门锁日志表删表及重新建表语句
--drop table
drop table TL_E_CONTROLLOG;

-- Create table
create table TL_E_CONTROLLOG
(
  log_id       VARCHAR2(18) not null,
  serial_no    VARCHAR2(20) not null,
  status       VARCHAR2(2) not null,
  record_time  DATE default sysdate,
  record_user  VARCHAR2(18) not null,
  remark       VARCHAR2(200),
  branch_id    VARCHAR2(6) not null,
  room_id      VARCHAR2(6),
  floor_id     VARCHAR2(6) not null,
  order_id     VARCHAR2(17) not null,
  oper_command VARCHAR2(2)
)
tablespace PMS_DAT
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 16K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table TL_E_CONTROLLOG
  is '设备操作日志表';
-- Add comments to the columns 
comment on column TL_E_CONTROLLOG.log_id
  is '序列表格yyyymmdd+10序列';
comment on column TL_E_CONTROLLOG.serial_no
  is '设备编号';
comment on column TL_E_CONTROLLOG.status
  is '状态,1-有效,2-无效';
comment on column TL_E_CONTROLLOG.record_time
  is '录入时间';
comment on column TL_E_CONTROLLOG.record_user
  is '录入人';
comment on column TL_E_CONTROLLOG.remark
  is '备注';
comment on column TL_E_CONTROLLOG.branch_id
  is '门店编号';
comment on column TL_E_CONTROLLOG.room_id
  is '房间号';
comment on column TL_E_CONTROLLOG.floor_id
  is '楼层';
comment on column TL_E_CONTROLLOG.order_id
  is '订单号';
comment on column TL_E_CONTROLLOG.oper_command
  is '操作类型:1-普通开门,2-远程开门,3- 断电,4-开电,5- 采集器重置,6-门锁重置,7-电重置';
-- Create/Recreate primary, unique and foreign key constraints 
alter table TL_E_CONTROLLOG
  add constraint PRIMARYKEY_TL_E_CONTROLLOG primary key (LOG_ID)
  using index 
  tablespace PMS_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

  
  
  
  
--2018/06/05 上午 新建短信促销表

-- Create table
create table TB_P_PROMOTION
(
  promotion_id VARCHAR2(12) not null,
  start_time   DATE not null,
  end_time     DATE not null,
  content_desc VARCHAR2(200) not null,
  record_time  DATE default sysdate not null,
  record_user  VARCHAR2(8),
  status       VARCHAR2(2) not null,
  remark       VARCHAR2(200)
)
tablespace PMS_DAT
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 16K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table TB_P_PROMOTION
  is '促销短信表';
-- Add comments to the columns 
comment on column TB_P_PROMOTION.promotion_id
  is '促销编号';
comment on column TB_P_PROMOTION.start_time
  is '开始时间';
comment on column TB_P_PROMOTION.end_time
  is '结束时间';
comment on column TB_P_PROMOTION.content_desc
  is '内容';
comment on column TB_P_PROMOTION.record_time
  is '操作时间';
comment on column TB_P_PROMOTION.record_user
  is '记录人';
comment on column TB_P_PROMOTION.status
  is '状态,0-删除,1-有效';
comment on column TB_P_PROMOTION.remark
  is '备注';
-- Create/Recreate primary, unique and foreign key constraints 
alter table TB_P_PROMOTION
  add constraint TB_P_PROMOTION_ID primary key (PROMOTION_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Create sequence 
create sequence SEQ_PROMOTION_ID
minvalue 1001
maxvalue 9999
start with 1001
increment by 1
cache 10
cycle;

--2018/06/06下午 审核按钮报错修改sql(民宿)

UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select r.reserved_person reservedperson,
         u.staff_name username,
         r.branch_id branchid,
         b.housename branchname,
         to_char(r.application_date, ''yyyy/MM/dd'') applicationdate,
         r.contract_id contractid,
         r.room_type roomtype,
         b.housename roomname,
         r.room_id roomid,
         to_char(r.repair_time, ''yyyy/MM/dd'') repairtime,
         r.equipment equipment,
         r.emergent emergent,
         s.param_name paramname,
         nvl(r.remark, '' '') remark
          from tb_p_repairapply r,tb_c_staff u, tb_p_house      b,tp_c_sysparam    s
         where r.reserved_person = u.staff_id(+)
           and r.branch_id = b.house_id(+)
           and r.equipment = s.content(+)
           and s.param_type = ''REPAIREQUIPMENTTYPE''
           {and r.repairapply_id = ?}'
 where s.sql_name = 'selectrepaircloud';
 commit;

--2018/06/07 下午 挂房账查询在住的民宿

UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select c.house_id houseid,
       c.status,
       c.house_no       roomid,
       c.housename      roomtypename,
       c.check_id       checkid,
       d.checkuser_name checkusername
  from (select a.house_no,
               a.house_type,
               a.house_id,
               b.check_id,
               a.status,
               a.housename
          from (select house.house_id,
                       house.house_type,
                       house.status,
                       house.house_no,
                       house.housename
                  from tb_p_house house,TB_C_HOUSEACCOUNT t
                 where house.staff_id = t.houseaccount_name
                       and  t.staff_id like ''%''|| ? ||''%''
                       and t.status = ''1''
                       and (house.status = ''3'' or house.status = ''W'')) a,
               (select che.check_id,
                       che.branch_id,
                       che.room_id,
                       che.room_type
                  from tb_p_check che
                 where che.status = ''1'') b
         where a.house_id = b.branch_id
         ) c
  left join (select cheuser.checkuser_name, cheuser.check_id
               from tb_c_checkuser cheuser
              where cheuser.status = ''1''
                and cheuser.checkuser_type = ''1''
                and cheuser.checkin_type = ''2'') d
    on c.check_id = d.check_id'
 where s.sql_name = 'querylivehouse';
 commit;



UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select r.reserved_person reservedperson,
         u.staff_name username,
         r.branch_id branchid,
         b.housename branchname,
         to_char(r.application_date, ''yyyy/MM/dd'') applicationdate,
         r.contract_id contractid,
         r.room_type roomtype,
         b.housename roomname,
         r.room_id roomid,
         to_char(r.repair_time, ''yyyy/MM/dd'') repairtime,
         r.equipment equipment,
         r.emergent emergent,
         s.param_name paramname,
         nvl(r.remark, '' '') remark
          from tb_p_repairapply r,tb_c_staff u, tb_p_house      b,tp_c_sysparam    s
         where r.reserved_person = u.staff_id(+)
           and r.branch_id = b.house_id(+)
           and r.equipment = s.content(+)
           and s.param_type = ''REPAIREQUIPMENTTYPE''
           {and r.repairapply_id = ?}'
 where s.sql_name = 'selectrepaircloud';
 commit;

--2018/06/07 下午 预定民宿卡其维修房不可以预定

UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.house_id houseid, decode(nvl(sum(a.nums), 0),''0'',''占用'',''空'') numss from tb_p_house t 
left join( 
select s.house_id houseid, count(s.house_id) nums from tb_p_house s group by s.house_id
union all
select ord.branch_id houseid, -count(ord.branch_id) nums
from tb_p_order ord
where ord.theme = ''3'' and ord.status in(''1'',''3'') 
 and to_char(ord.arrival_time, ''yyyy/MM/dd'') <=  ? 
 and to_char(ord.leave_time, ''yyyy/MM/dd'') >  ?  
group by ord.branch_id
union all 
select hp.branch_id houseid, -count(hp.branch_id) nums
from  tb_p_haltplan hp
where hp.status in (''1'', ''3'')
 and to_char(hp.end_time, ''yyyy/MM/dd'') >= ?  
 and to_char(hp.start_time, ''yyyy/MM/dd'') <=  ? 
group by hp.branch_id 
union all
select rp.branch_id houseid ,-count(rp.branch_id) nums
from  tb_p_repairapply rp
where rp.status in(''2'',''3'')
and to_char(rp.application_date, ''yyyy/MM/dd'')<=?
group by rp.branch_id
)a on t.house_id = a.houseid
where t.house_id = ?
group by t.house_id'
 where s.sql_name = 'houseForwardStatus';
 commit;
 
 --2018/06/08 下午审核记录sql修改
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
and r.status = ''1'' 
and r.branch_id like ''%H%''
and r.post like ''%'' || $POST || ''%''
) apd
where apd.staffname like ''%'' || :AUDITRECORDUSER || ''%''
and apd.branchname like ''%'' || :AUDITBRANCHID || ''%''
and apd.tableaudittype like ''%'' || :TABLEAUDITTYPE || ''%''
order by apd.recordtime desc'
 where s.sql_name = 'reportAuditAll';
 commit;
 
 
 --2018/06/14 上午 舆情管理评论可空
alter table TB_P_COMMENT modify service_comment null;
alter table TB_P_COMMENT modify facility_comment null;
alter table TB_P_COMMENT modify security_comment null;


--2018/06/14 下午 品宣xmlsql脚本 来自185
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('getProBrandComment', 'select ter.* from(select t.*,
transtitles(t.branch_id,''TB_P_HOUSE'',''HOUSE_ID'',''HOUSENAME'') HOUSENAME,
       decode(t.status, ''0'', ''失效'', ''1'', ''有效'') status1,
       m.member_name,
       to_char(t.record_time, ''yyyy-MM-dd HH:mm:ss'') recordTime,
       t.service_score serviceScore,
       t.service_comment serviceComment,
       t.facility_score facilityScore,
       t.facility_comment facilityComment,
       t.security_score securityScore,
       t.security_comment securityComment
  from  TB_P_COMMENT t
  left join TB_C_MEMBER m
    on t.member_id = m.member_id
   and m.status = ''1''
 where t.status = ''1'' and nvl(t.RELATIVE_COMMENT,'' '') = '' ''
 order by t.comment_id DESC) ter where ter.HOUSENAME like ''%''||:HOUSENAME||''%''', 'dsOracle', '获取品宣评论');
 commit;

--loadRepairApply
--2018/06/14
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.repairapply_id repairapplyId,
       t.branch_id branchId,
       t.contract_id contractId,
       t.room_id roomId,
       t.application_date applicationDate,
       nvl(transtitles(t.reserved_person,
                   ''tb_c_member'',
                   ''member_id'',
                   ''member_name''),transtitles(t.reserved_person,
                   ''tb_c_staff'',
                   ''staff_id'',
                   ''staff_name'')) reservedPerson,
       t.mobile,
       decode(t.status, ''0'', ''已取消'', ''1'', ''未审核'', ''2'',''已审核'',''3'',''未修复'',''已修复'') status,
       t.audit_description auditDescripition,
       t.record_time recordtime,
       t.record_user recorduser,
       t.remark,
       t.repair_time repairTime,
       (select s.param_name from tp_c_sysparam s where s.content= t.equipment and s.status=''1'' and s.param_type=''REPAIREQUIPMENTTYPE'') equipment,
       t.emergent,
       t.room_type roomtype,
       t.post,
       t.audit_remark auditRemark
  from tb_p_repairapply t
  left join tb_p_contrart f on 
  t.contract_id=f.contrart_id
  where t.contract_id=f.contrart_id
 {and t.branch_id = ?}
 and (f.status=''1'' or f.status=''4'')
 {and f.room_id=?}
 and sysdate between f.start_time and f.end_time
 order by t.record_time desc'
 where s.sql_name = 'loadRepairApply';
 commit;


--维修展示页面按照申请时间先后顺序orderby
--2018/06/19
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.repairapply_id repairapplyId,
       transtitles(t.branch_id,''tb_p_house'',''house_id'',''housename'') branchId,
       t.contract_id contractId,
       t.room_id roomId,
       t.application_date applicationDate,
       (case
         when (t.contract_id IS NULL) then
          transtitles(t.reserved_person,
                       ''tb_c_staff'',
                       ''staff_id'',
                       ''staff_name'')
          
         else
          transtitles(t.reserved_person,
                       ''tb_c_member'',
                       ''member_id'',
                       ''member_name'')
       end) reservedPerson,
       t.mobile,
       decode(t.status, ''0'', ''已取消'', ''1'', ''未审核'', ''2'',''已审核'',''3'',''未修复'',''已修复'') status,
       t.audit_description auditDescripition,
       t.record_time recordtime,
       t.record_user recorduser,
       t.remark,
       t.repair_time repairTime,
       (select s.param_name from tp_c_sysparam s where s.content= t.equipment and s.status=''1'' and s.param_type=''REPAIREQUIPMENTTYPE'') equipment,
       t.emergent,
       t.room_type roomtype,
       t.post,
       t.audit_remark auditRemark
        from TB_P_REPAIRAPPLY t, TB_P_HOUSE d
where t.branch_id = d.house_id
  and d.house_id in (select h.house_id from TB_P_HOUSE h, TB_C_HOUSEACCOUNT t  where h.staff_id = t.houseaccount_name and  t.staff_id like ''%'' || {?} || ''%'')
 {and d.house_id = ?} order by t.application_date'
 where s.sql_name = 'repairInHouse';
 commit;

















