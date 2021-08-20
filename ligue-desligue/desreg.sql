set num 20
set verify off
set heading off;
clear computes;
clear breaks;
set pagesize 0;
set linesize 200;
set feedback off;


select c.CLIENT_ID||';'||
c.PHONE||';'||
c.LEGACY_CLIENT_ID||';'||
u.NASPORT||';'||
u.NASIP_ADDRESS||';'||
u.IP_ADDRESS||';'||
u. CPE_IP_ADDRESS||';'||
c. PLAN_NAME||';'||
c.BLOCKING_STATE 
from psa.client c inner join psa.userline u 
on c.CLIENT_ID=u.CLIENT_ID 
where c.PHONE='&1' and c.DELETED_DATE_UTC is null  order by c.BLOCKING_STATE;
exit;
