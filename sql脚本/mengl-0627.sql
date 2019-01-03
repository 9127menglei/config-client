--menglei
--2018/06/27 更改datasource表来源状态和名称
update TB_C_DATARESOURCE s
set s.name = '去哪儿'
where s.member_id = '2';
commit;
update TB_C_DATARESOURCE s
set s.name = '小程序'
where s.member_id = '4';
commit;
update TB_C_DATARESOURCE s
set s.status = '0'
where s.member_id = '5' or s.member_id = '8';
commit;
