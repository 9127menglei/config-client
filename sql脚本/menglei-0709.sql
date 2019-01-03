
--menglei
--2018/07/09
--�۸���������branchid�ֶ�
alter table TB_P_PRICERULES add (rules_branch_id varchar2(6));
comment on column TB_P_PRICERULES.rules_branch_id is '�ŵ���';

--�л���Ԣ�۸�����ѯ
insert into TP_C_SQLINFO
  (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values
  ('queryPriceRulesApart',
   'select t.rules_id rulesId, t.rules_name rulesName, 
t.rules_period rulesPeriod, t.rules_perioddetails rulesPerioddetails,t.rules_filters rulesFilters,
t.rules_desc rulesDesc from TB_P_PRICERULES t where t.rules_branch_id = ''$BRANCHID''',
   'dsOracle',
   '��ѯ���й�Ԣ�۸����');
commit;

--Ӫ�����ѯsql
insert into TP_C_SQLINFO
  (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values
  ('campaignShowInPageAt',
   'select c.data_id dataid, c.campaign_name campaignname, 
c.campaign_type campaigntype, c.campaign_desc campaigndesc, c.using_range usingrange, 
transTitles(c.using_person, ''TP_C_MEMBERRANK'', ''MEMBER_RANK'',''RANK_NAME'') usingperson,
transTitlesTwo(c.using_type,''TP_C_SYSPARAM'',''PARAM_NAME'',''PARAM_DESC'',''PARAM_TYPE'',''EVENT_TYPE'') usingtype,
to_char(c.start_time,''yyyy/MM/dd HH:mm'') starttime, to_char(c.end_time,''yyyy/MM/dd HH:mm'') endtime,c.campaign_cycle campaigncycle, 
c.business_id businessid, c.record_time recordtime, 
decode(c.record_user,''1'',''admin'',transTitles(c.record_user, ''TB_C_STAFF'', ''STAFF_ID'', ''STAFF_NAME'')) recorduser, 
c.priority priority, nvl(c.remark ,'' '') remark, c.status status from tb_c_campaigns c  
where c.business_id like ''%''||:BUSINESSTYPE||''%'' and c.priority like ''%''||:PRIORITY||''%'' 
and transTitles(c.using_person, ''TP_C_MEMBERRANK'',''MEMBER_RANK'', ''RANK_NAME'') like ''%''||:USINGPERSON||''%'' 
and c.using_range like ''%''||:USINGRANGE||''%'' and  c.using_type like ''%''||:USINGTYPE_CUSTOM_VALUE||''%'' 
and c.start_time >= to_date(:STARTDATE ,''yyyy/MM/dd'') and c.status like ''%''||:SUPPILERSTATUS||''%''  
and c.branch_id = ''$BRANCHID'' order by c.record_time desc',
   'dsOracle',
   '�ֵ�չʾӪ���');
commit; 

-- ���۹����ѯsql��Ԣ
insert into TP_C_SQLINFO
  (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values
  ('queryprApart',
   'select t.* from TB_P_PRICERULES t
 where t.rules_period <> ''1'' and t.rules_branch_id = ?
 and t.rules_id <> ''0'' order by t.rules_id desc ',
   'dsOracle',
   '��ѯ���۹���');
 commit; 
 
--��Ԣ��ѯ���۵�����
insert into TP_C_SQLINFO
  (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values
  ('queryPVolatiDetails',
   '  select transTitles(t.branch_id,''TB_C_BRANCH'',''BRANCH_ID'',''BRANCH_NAME'')  branchId,
   decode(t.rp_id,''MSJ'',''���м�'') rpId,
   t.room_price roomPrice,
   decode(t.priority,''3'','' '',to_char(t.start_time, ''yyyy-MM-dd HH24:mi:ss'')) startTime,
   decode(t.priority,''3'','' '',to_char(t.end_time, ''yyyy-MM-dd HH24:mi:ss'')) endTime,
   decode(t.priority,''1'',''���'',''2'',''������'',''3'',''��׼��'') priority,
   decode(t.rules_id,''0'',''�޹���'',transTitles(t.rules_id,''TB_P_PRICERULES'',''RULES_ID'',''RULES_NAME'')) rulesId,
   t.recordtime
from TB_P_PRICE_VOLATILITY t
where t.rp_id = ''MSJ''
and t.theme <> ''3''
and to_date(to_char(t.start_time, ''yyyy/MM/dd HH24:mi:ss''),''yyyy/MM/dd HH24:mi:ss'') <=  to_date(:ENDTIME, ''yyyy/MM/dd HH24:mi:ss'')
and to_date(to_char(t.end_time, ''yyyy/MM/dd HH24:mi:ss''),''yyyy/MM/dd HH24:mi:ss'') >= to_date(:STARTDATE, ''yyyy/MM/dd HH24:mi:ss'')
and t.branch_id = ''$BRANCHID''
order by t.recordtime desc
',
   'dsOracle',
   '�����������Ƽ���Чʱ���ѯ������Ϣ');
commit;
  
--2018/07/10
--�޸���Դ
UPDATE TB_C_DATARESOURCE s
  set s.name = '�ŵ�'
where s.member_id = '3';
commit;

UPDATE TB_C_DATARESOURCE s
  set s.name = '���ں�'
where s.member_id = '7';
commit;

--�޸�crm��ѯ��Դsql
UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select os.data_id dataId,
       os.member_id memberId,os.name,os.status,os.remark
	  from TB_C_DATARESOURCE os
	where os.name like ''%'' || :ORDERSOURCENAME || ''%''
	and os.status = ''1'''
 where s.sql_name = 'queryOrderSource';
 commit;
 

--2018/07/10
--��Ԣά�޲�Ԥ��sql
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryarrivalorderApt', 'select * from tb_p_aptorder o
where  o.status = ''1''
and  o.branch_id=?
and  o.room_id = ?', 'dsOracle', '��Ԣ�鶩��');
commit;










