
--menglei
--2018/07/13 查询当前系统时间的退房申请
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryCheckoutdatas', 'select * from 
(select m.contract_id contractId,m.member_id memberId,m.branch_id branchId,m.room_id roomId,m.record_time recordTime,m.checkout_time checkoutTime from( select t.*,row_number() over(partition by t.branch_id, t.room_id, t.checkout_time order by t.record_time desc) rn from tb_p_checkout t
where t.dispose = ''1''
and t.status = ''2''
and t.post = ''*''
and to_char(t.checkout_time,''yyyy/MM/dd'') = to_char(sysdate,''yyyy/MM/dd'')
) m
where rn = 1)n left join tb_c_staff s on n.branchid = s.branch_id
and s.post = ''0007''
and s.status <> ''0''
', 'dsOracle', '退房发短信定时任务');

