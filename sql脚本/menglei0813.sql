--menglei
--2018/08/13
--����CRM��������ʱ�ķ���״̬ѡ�� 
UPDATE TP_C_SQLINFO s
set s.sql_info = 'select content content, param_name paramname, order_no orderno
  from tp_c_sysparam
 where param_type = ''ROOMSTATUS''
   and status = ''1''
   and content <> ''0''
   and content <> ''T''
   and content <> ''W'''
where s.sql_name = 'rpstatusNew';
commit;
