INSERT overwrite TABLE abcde partition(p_provincecode,p_date)
SELECT '2017-06-11' AS DAY,c.msisdn,c.province,c.city,c.tacid,c.terminal_model,c.terminal_vendor,
       b.appname,a.times,a.duration,1001 as p_provincecode,'2017-06-11' AS p_date
FROM 
( select imsi_3g,imsi_4g,msisdn,tacid,terminal_model,terminal_vendor,province,city
  from $USER_INFO$ where p_provincecode=10010
) c
JOIN (
  SELECT substring(msisdn,-11) AS msisdn,appid,
         SUM(times) AS times,SUM(duration) AS duration,(sum(uplink_flux)+sum(downlink_flux)) as Flux,
         AVG(kqi_snspublicrate) as KqiSnspublicrate,AVG(kqi_snspublicdelay) as KqiSnspublicdelay,
         AVG(kqi_snsrefreshrate) as KqiSnsrefreshrate,AVG(kqi_snsrefreshdelay) as kqiSnsrefreshdelay
  FROM $QOEKQI_DAY$
  WHERE p_provincecode=$QOEKQI_DAY.p_provincecode$ AND reportdate='2017-06-11' AND 
        rat=255 AND msisdn>''
  GROUP BY msisdn,appid
) a ON a.msisdn=c.msisdn 
LEFT JOIN $DIM_SERVICE$ b ON a.appid=b.appid


INSERT overwrite TABLE table2 partition(p_provincecode,p_date,p_citycode)
SELECT case when hour<10 then concat(a.date,' 0',a.hour,':00:00') else concat(a.date,' ',a.hour,':00:00') end as time,
'China' as country,b.province,b.city,b.district,b.enodebid,a.cellid,
'2016-10-09' as p_date,510000 as p_provincecode,b.citycode as citycode
FROM
    (
    SELECT date,hour,cellid,pci
    FROM  cellcoverinfo 
    where p_date='2016-10-09' and p_provincecode=510000
    ) as a
    left JOIN 
    (
      SELECT province,city,citycode,district,enodebid
      FROM geoprojinfo
    ) as b 
    ON a.enodebid = b.enodebid limit 10

INSERT INTO table table2 partition(p_provincecode,p_date,p_region)
select 
"2016-10-08"  as date ,
6 as hour ,
675235 as enodebid,
1000 as bplconfigcellnum,
99.5 as bplulpdcpavgthroughput,
"aa" as bplulthroughputstatus,
95.1 as bpldlpdcpavgthroughput,
"1234" as bpldlthroughputstatus,
1 as enbpagingcongestionnum ,
2 as enbpagingnum,
11.2 as cpuavgratio ,
"3344" as cpuusedstatus,
55.7 as cctransportulbandwidth ,
"43143" as cctransportulstatus,
11.3 as cctransportdlbandwidth,
"finised" cctransportdlstatus ,
510000 as p_provincecode ,
"2016-10-09" as p_date,
888852 as p_region
from
table1 limit 1;

没有数据
INSERT OVERWRITE TABLE table1 PARTITION(p_provincecode,p_date)
select  '02' as  servicetype,' 2016-04-10' as msgdate,510000 as p_provincecode,'2016-05-05' as p_date from table1 limit 1
union all
select  '02' as  servicetype,' 2016-04-08' as msgdate,510000 as p_provincecode,'2016-05-05' as p_date from table1 limit 1;


如果某表没有数据  可以这样
INSERT OVERWRITE TABLE table1 PARTITION(p_provincecode,p_date)
select  '15220203849' as  mdn,1 as mdnclass,0.99 as confidence,510000 as p_provincecode,'2016-05-05' as p_date 
from  (select count(1) from ict_function_localnetfraudnumber_day) as xxx limit 1
