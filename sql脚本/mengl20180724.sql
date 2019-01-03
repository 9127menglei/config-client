
--menglei
--2018/07/25 民宿房态统计查询所有的民宿统计信息
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('queryCurrentHouseNew', 'select r9.*,
       round((r9.yrzf / r9.zg) * 100, 2) || ''%'' rzrate,
       round(((r9.yrzf + r9.ydf) / r9.zg) * 100, 2) || ''%'' czrate,
       (r9.zg - r9.tsf - r9.zf - r9.wxf - r9.yrzf - r9.ydf) ksf
  from (select *
          from (select count(h7.house_id) zg
                  from tb_p_house h7
                 where h7.status <> ''0''
                  ) r8,
               (select count(h1.house_id) kf
                  from tb_p_house h1
                 where h1.status = ''1''
                  ) r1,
               (select count(h3.house_id) yrzf
                  from tb_p_house h3
                 where h3.status = ''3''
                  ) r3,
               (select count(h4.house_id) tsf
                  from tb_p_house h4
                 where h4.status = ''T''
                  ) r4,
               (select count(h5.house_id) zf
                  from tb_p_house h5
                 where h5.status = ''Z''
                  ) r5,
               (select count(h6.house_id) wxf
                  from tb_p_house h6
                 where  h6.status = ''W''
                 ) r6,
               (select nvl(count(h2.house_id), ''0'') ydf
                  from tb_p_house h2
                 where  h2.status = ''2''
                 ) r7) r9', 'dsOracle', '当日房态新');
