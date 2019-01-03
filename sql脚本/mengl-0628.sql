--menglei
--2018/06/28 修正民宿占用提示sql,停售房取消卡结束时间
 UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select t.house_id houseid, decode(sign(sum(a.nums)),''-1'',''占用'',''0'',''占用'',''空'') numss from tb_p_house t 
left join( 
select s.house_id houseid, count(s.house_id) nums from tb_p_house s group by s.house_id
union all
select ord.branch_id houseid, -count(ord.branch_id) nums
from tb_p_order ord
where ord.theme = ''3'' and ord.status in(''1'',''3'') 
 and to_char(ord.arrival_time, ''yyyy/MM/dd'') <=  ? 
 and to_char(ord.leave_time, ''yyyy/MM/dd'') >  ?  
group by ord.branch_id
union all 
select hp.branch_id houseid, -count(hp.branch_id) nums
from  tb_p_haltplan hp
where hp.status in (''1'', ''3'')
 and to_char(hp.start_time, ''yyyy/MM/dd'') <=  ? 
group by hp.branch_id 
union all
select rp.branch_id houseid ,-count(rp.branch_id) nums
from  tb_p_repairapply rp
where rp.status in(''2'',''3'')
and to_char(rp.application_date, ''yyyy/MM/dd'')<=?
group by rp.branch_id
)a on t.house_id = a.houseid
where t.house_id = ?
group by t.house_id'
 where s.sql_name = 'houseForwardStatus';
 commit;
 
 --menglei
 --2018/06/28 民宿远期房态卡停售房取消卡结束时间
  UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select 
          (select count(ord.branch_id) YD from tb_p_order ord where ord.theme = ''3''and ord.status = ''1''
            and to_char(ord.arrival_time, ''yyyy/MM/dd'') <= ?
            and to_char(ord.leave_time, ''yyyy/MM/dd'') > ?
            and ord.branch_id = ?
          group by ord.branch_id) YD, 
        (select count(ord.branch_id) ZZ
           from tb_p_order ord
          where ord.theme = ''3''
            and ord.status = ''3''
            and to_char(ord.arrival_time, ''yyyy/MM/dd'') <= ?
            and to_char(ord.leave_time, ''yyyy/MM/dd'') > ?
            and ord.branch_id = ?
          group by ord.branch_id) ZZ,
        (select count(hp.branch_id) TS
           from tb_p_haltplan hp
          where hp.status in (''1'', ''3'')
            and to_char(hp.start_time, ''yyyy/MM/dd'') <= ?
            and hp.branch_id = ?
          group by hp.branch_id) TS,
        (select count(rp.branch_id) WX
           from tb_p_repairapply rp
          where rp.status in (''2'', ''3'')
            and to_char(rp.application_date, ''yyyy/MM/dd'') <= ?
            and rp.branch_id = ?
          group by rp.branch_id) WX
FROM dual'
 where s.sql_name = 'newhouseforward';
 commit;
 
 
 
