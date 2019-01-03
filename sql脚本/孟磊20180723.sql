
--menglei
--2018/07/23; CRM价格规则加载开放所有规则选择
UPDATE TP_C_SQLINFO s
set s.sql_info = 'select t.* from TB_P_PRICERULES t
where t.rules_period <> ''1'' 
and t.rules_id <> ''0'' order by t.rules_id desc '
where s.sql_name = 'queryprApart';
commit;

