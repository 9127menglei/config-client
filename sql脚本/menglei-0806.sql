--menglei
--2018/08/06

--CRMGY��Ԣ��������״̬��ѯsql
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('rpstatusNew', 'select content content,param_name paramname,order_no orderno from tp_c_sysparam where param_type = ''ROOMSTATUS'' and status = ''1'' and content <> ''0''', 'dsOracle', '��ѯ����״̬');
commit;
--������Ԣ��̬˫���¼�ά��sql
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('loadRepairApplyT', 'select t.repairapply_id repairapplyId,
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
       decode(t.status, ''0'', ''��ȡ��'', ''1'', ''δ���'', ''2'',''�����'',''3'',''δ�޸�'',''���޸�'') status,
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
 where t.branch_id = ?
 and t.room_id = ?
 order by t.record_time desc', 'dsOracle', '��ѯ��Ԣά��');
 commit;
