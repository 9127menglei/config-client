--menglei
--2018/07/18
--0点定时任务查询待入住远期订单刷room状态定时任务sql
insert into TP_C_SQLINFO (SQL_NAME, SQL_INFO, DB_TYPE, REMARK)
values ('refreshAprtRoom', 'select a.branch_id branchId, a.room_id roomId from TB_P_APTORDER a
where a.status in(''1'',''6'')', 'dsOracle', '公寓定时刷房态');

--Crm数据权限sql
 UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select ter.* from (select b.branch_id branchid,
       b.branch_name branchname,
       b.rank rank,
       b.branch_type branchtype,
       b.address address,
       b.phone phone,
       b.postcode postcode,
       b.contacts contacts,
       b.mobile mobile,
       b.record_user recorduser,
       b.record_time recordtime,
       b.city city,
       b.district district,
       b.street street,
       b.circle circle,
       b.status status,
       b.flag flag,
       nvl(b.remark, '' '') remark,
       l.latitude latitude,
       l.longitude longitude,
       b.special_label speciallabel,
       b.special_description specialdescription,
       b.order_no orderno,
       (select c.admini_name from TB_P_CITY c where c.admini_code = b.city) cityName,
       (select c.admini_name from TB_P_CITY c where c.admini_code = b.district)  districtName,
       (select c.admini_name from TB_P_CITY c where c.admini_code = b.street)  streetName,
       (select c.admini_name from TB_P_CITY c where c.admini_code = b.circle)  circleName
  from tb_c_branch b,TB_P_LOCATION l
 where b.status = ''1'' and l.status = ''1'' and b.branch_id = l.branch_id
   and b.branch_name like ''%'' || :PRICEBRANCHNAME || ''%''
   and b.mobile like ''%'' || :MOBILE || ''%''
   and b.status like ''%'' || :ZT || ''%''
  order by b.branch_id desc) ter where ter.cityName like ''%'' || :CITY || ''%''
  and ter.districtName like ''%'' || :DISTRICT || ''%''
  and (ter.streetName like ''%'' || :STREET || ''%'' or nvl(ter.streetName, '' '') like ''%'' || :STREET || ''%'')
  and (ter.circleName like ''%'' || :CIRCLE || ''%'' or nvl(ter.circleName, '' '') like ''%'' || :CIRCLE || ''%'')'
 where s.sql_name = 'branchmanageAll';
 commit;

 UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select c.data_id dataid,
       b.branch_name branchname,
       c.branch_id branchid,
       c.cash_box cashbox,
       c.cash_count cashcount,
       c.cash_status cashstatus,
       c.record_user recorduser,
       to_char(c.record_time, ''yyyy/mm/dd'') record_time,
       c.status status,
       nvl(c.remark,'' '') remark
  from tb_c_cashbox c,tb_c_branch b
  where  c.branch_id = b.branch_id(+)
      and c.status like ''%'' || :CBSTATUS || ''%'' 
      and b.branch_name like ''%'' || :PRICEBRANCHNAME || ''%'' 
      and b.status = ''1''
      order by c.data_id desc'
 where s.sql_name = 'cashdatanew';
 commit;
 
  UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select * from (select h.house_id branchid,
           h.housename,
       h.house_no houseno,
       h.house_type housetype,
      ( select c.admini_name  from tb_p_city c where h.city = c.admini_code(+)) city,
       (select c.admini_name  from tb_p_city c where h.district = c.admini_code(+)) district,
        (select c.admini_name  from tb_p_city c where h.street = c.admini_code(+)) street,
         (select c.admini_name  from tb_p_city c where h.circle= c.admini_code(+)) circle,
       h.init_price initprice,
      h.current_price currentprice,
      h.clean_price cleanprice,
      h.cashpledge cashpledge,
      h.dec_style decstyle,
      h.community_name communityname,
      h.address address,
      nvl(h.remark ,'' '') remark,
      h.floor floorr,
      h.position position,
      h.staff_id staffname,
      h.staff_id staffid,
      h.record_user recordUser,
      h.status status,
      to_char(h.record_time,''yyyy/MM/dd'') recordtime,
      h.special_label speciallabel,
      h.special_description specialdescription,
      h.order_no orderno
        from TB_P_HOUSE h) r1 where
        r1.housename like ''%'' || :PRICEBRANCHNAME || ''%''
        and r1.houseno like ''%'' || :HOUSENO || ''%''
        and r1.city like ''%'' || :CITY || ''%''
        and r1.district like ''%'' || :DISTRICT || ''%''
        and nvl(r1.street,'' '') like ''%'' || :STREET || ''%''
        and nvl(r1.circle, '' '') like ''%'' || :CIRCLE || ''%''
        and r1.status  like ''%'' || :HOUSESTATUS || ''%''
        and r1.status <> ''0''
        order by r1.branchid desc'
 where s.sql_name = 'housemanagecrm';
 commit;
 
  UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select r.branch_id branchid,
       b.branch_name branchname,
       r.room_id roomid,
       r.theme theme,
       r.room_type roomtype,
       r.area area,
       t.room_name roomname,
       r.floor floor,
       r.status status,
       s.param_name paramname,
       r.record_time recordtime,
       nvl(r.remark, '' '') remark
  from tb_p_room r, tb_c_branch b, tp_p_roomtype t, tp_c_sysparam s
 where r.branch_id = b.branch_id(+)
   and r.branch_id = t.branch_id(+)
   and r.room_type = t.room_type(+)
   and r.status = s.content(+)
   and s.param_type = ''ROOMSTATUS''
   and t.status <> ''0''
   and r.status != ''F''
   and b.branch_name like ''%'' || :PRICEBRANCHNAME || ''%''
   and r.theme like ''%'' || :ROOMTHEME || ''%''
   and t.room_name like ''%'' || :ROOMTYPE || ''%''
   and s.param_name like ''%'' || :RMSTATUS || ''%''
   and r.room_id like ''%'' || :RMID || ''%''
   and r.floor like ''%'' || :RMFLOOR || ''%''
 --  and r.branch_id like decode($BRANCHID, ''100001'', ''%'', $BRANCHID)
 order by r.record_time desc'
 where s.sql_name = 'pmsroomdata';
 commit;
 
  UPDATE TP_C_SQLINFO s
 set s.sql_info = 'select * from (select t.room_type ROOMTYPE,
       t.room_name ROOMNAME,
       decode(t.theme, 1, ''酒店'', 2, ''公寓'', 3, ''民宿'') THEME,
       t.room_bed ROOMBED,
       (select P.CONTENT
          from TP_C_SYSPARAM p
         where p.param_type = ''BEDDESC''
           AND P.STATUS = ''1''
           AND P.PARAM_DESC = t.bed_desc) BEDDESC,
       decode(t.broadband, 1, ''有线免费'', 2, ''免费'') BROADBAND,
       t.room_label ROOMLABEL,
       t.room_desc ROOMDESC,
       t.tips TIPS,
       (select P.CONTENT
          from TP_C_SYSPARAM p
         where p.param_type = ''ROOMPOSITION''
           AND P.STATUS = ''1''
           AND P.PARAM_DESC = t.Room_Position) ROOMPOSITION,
       t.status STATUS,
       to_char(t.record_time, ''yyyy/mm/dd'') RECORDTIME,
       t.record_user RECORDUSER,
       t.remark REMARK,
       t.branch_id BRANCHID,
       (select a.branch_name
          from (select b.branch_id, b.branch_name
                  from TB_C_BRANCH b
                union all
                select h.house_id, h.house_no from TB_P_HOUSE h) a
         where a.branch_id = t.branch_id) BRANCHNAME
  from TP_P_ROOMTYPE t
 where t.room_type like ''%'' || :ROOMTYPEAREA || ''%''
   and t.room_name like ''%'' || :ROOMNAMEAREA || ''%''
   and t.theme like ''%'' || :THEMEAREA || ''%''and t.status = ''1''
   ) op
   where op.branchname like ''%'' || :PRICEBRANCHNAME || ''%'''
 where s.sql_name = 'queryRoomTypeAll';
 commit;
