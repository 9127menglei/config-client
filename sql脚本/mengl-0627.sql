--menglei
--2018/06/27 ����datasource����Դ״̬������
update TB_C_DATARESOURCE s
set s.name = 'ȥ�Ķ�'
where s.member_id = '2';
commit;
update TB_C_DATARESOURCE s
set s.name = 'С����'
where s.member_id = '4';
commit;
update TB_C_DATARESOURCE s
set s.status = '0'
where s.member_id = '5' or s.member_id = '8';
commit;
