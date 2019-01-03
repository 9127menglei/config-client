
--menglei
--2018/07/23; CRM价格规则加载开放所有规则选择
UPDATE TP_C_SQLINFO s
set s.sql_info = 'select t.* from TB_P_PRICERULES t
where t.rules_period <> ''1'' 
and t.rules_id <> ''0'' order by t.rules_id desc '
where s.sql_name = 'queryprApart';
commit;


--menglei
--2018/07/25 民宿房态统计查询所有的民宿统计信息
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryCurrentHouseNew', 'select r9.*,
       round((r9.yrzf / r9.zg) * 100, 2) || ''%'' rzrate,
       round(((r9.yrzf + r9.ydf) / r9.zg) * 100, 2) || ''%'' czrate,
       (r9.zg - r9.tsf - r9.zf - r9.wxf - r9.yrzf - r9.ydf) ksf
  from (select *
          from (select count(h7.house_id) zg
                  from tb_p_house h7
                 where h7.status <> ''0''
                  ) r8,
               (select count(h1.house_id) kf
                  from tb_p_house h1
                 where h1.status = ''1''
                  ) r1,
               (select count(h3.house_id) yrzf
                  from tb_p_house h3
                 where h3.status = ''3''
                  ) r3,
               (select count(h4.house_id) tsf
                  from tb_p_house h4
                 where h4.status = ''T''
                  ) r4,
               (select count(h5.house_id) zf
                  from tb_p_house h5
                 where h5.status = ''Z''
                  ) r5,
               (select count(h6.house_id) wxf
                  from tb_p_house h6
                 where  h6.status = ''W''
                 ) r6,
               (select nvl(count(h2.house_id), ''0'') ydf
                  from tb_p_house h2
                 where  h2.status = ''2''
                 ) r7) r9', 'dsOracle', '当日房态新');
commit;


--menglei
--2018/07/27
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('getvalidhaltplaning', 'select h.log_id      logid,
       h.branch_id   branchid,
       h.room_id     roomid,
       h.halt_type   halttype,
       h.halt_reason haltreason,
       h.start_time  starttime,
       h.end_time    endtime,
       h.status      status,
       h.record_time recordtime,
       h.record_user recorduser,
       h.remark      remark
  from tb_p_haltplan h
 where h.status = ''3'' {
   and h.room_id = ? } {
   and h.branch_id = ? }', 'dsOracle', '查询正在执行的停售房计划');

--2018/07/27

-- Create table
create table TL_P_CHECKOUT
(
  checkout_id   VARCHAR2(19) not null,
  branch_id     VARCHAR2(6) not null,
  check_id      VARCHAR2(17) not null,
  checkout_date DATE default sysdate not null,
  record_user   VARCHAR2(8) not null,
  record_time   DATE default sysdate not null,
  remark        VARCHAR2(100),
  type          VARCHAR2(1) not null
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
comment on table TL_P_CHECKOUT
  is '退房日志表';
-- Add comments to the columns 
comment on column TL_P_CHECKOUT.checkout_id
  is '退房日志号格式:YYMMDD+门店编号+5位序列';
comment on column TL_P_CHECKOUT.branch_id
  is '门店编号';
comment on column TL_P_CHECKOUT.check_id
  is '放单号';
comment on column TL_P_CHECKOUT.checkout_date
  is '退房日期';
comment on column TL_P_CHECKOUT.record_user
  is '操作人';
comment on column TL_P_CHECKOUT.record_time
  is '更新时间';
comment on column TL_P_CHECKOUT.remark
  is '备注';
comment on column TL_P_CHECKOUT.type
  is '操作类型:1-预定入住,2-退房';
-- Create/Recreate primary, unique and foreign key constraints 
alter table TL_P_CHECKOUT
  add constraint PRIMARYKEY_TL_P_CHECKOUT primary key (CHECKOUT_ID)
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
  
  
  --新建退房日志序列
  -- Create sequence 
create sequence SEQ_CHECKOUTLOG_ID
minvalue 10001
maxvalue 99999
start with 10021
increment by 1
cache 10
cycle;







