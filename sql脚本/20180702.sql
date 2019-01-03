
insert into tp_c_sqlinfo (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('eRepairQuery', 'select t.repairapply_id repairapplyId,
       k.log_id logId,
       t.branch_id branchid,
       t.room_id roomid,
       t.equipment,
       t.serial_no serialno,
       t.warning_id warningid,
       transTitlesTwo(k.problem_tag,''TP_C_SYSPARAM'',''content'',''param_desc'',''param_type'',''tag'') problemTag,
       k.describe describe,
       k.repair_person maintperson,
       t.contract_id contractId,
       t.application_date applicationdate,
       t.mobile,
       t.remark,
       t.status status,
       to_char(t.record_time, ''yyyy/MM/dd'') recordTime,
       to_char(k.acrepair_time, ''yyyy/MM/dd'') acrepairTime
  from tb_p_repairApply t, tl_e_maintenancelog k
 where t.repairapply_id = k.repairapply_id(+)
   and  nvl(t.serial_no, '' '') like ''%'' || :ESERIALNO || ''%''
   and t.equipment like ''%'' || :EEQIPMENT || ''%''
   and t.equipment  not in(''1'',''3'',''5'',''2'',''4'',''6'')
   and k.repair_person like ''%'' ||:EMAINTPERSON || ''%''
   and t.status like ''%'' || :ERSTATUS || ''%''
   order by t.record_time desc
   ', 'dsOracle', '设备查询维修记录ems');
