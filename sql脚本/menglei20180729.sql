
--menglei
--2018/07/29 
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

