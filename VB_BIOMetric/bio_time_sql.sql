select 
emp_code, 
convert(Date, punch_time) 'Date',
min(convert(time(0),punch_time)) 'IN',
max(convert(time(0), punch_time)) 'OUT'
FROM iclock_transaction 
where CONVERT(DATE, punch_time) between '1/1/2025' and '2/30/2025' 
and emp_code in ('603672')
group By convert (date,punch_time), emp_code
order by emp_code, convert(date,punch_time)
























select
id,emp_code, 
punch_time,
convert(Date, punch_time) 'Date'
FROM iclock_transaction where CONVERT(DATE, punch_time) between '4/1/2025' and '4/30/2025' 
and emp_code in ('603672')










select
id,emp_code, 
punch_time,
convert(Date, punch_time) 'Date'
FROM iclock_transaction where CONVERT(DATE, punch_time) between '6/1/2025' and '6/28/2025' 
and emp_code in ('603672')






Select emp_code, CONVERT(DATE, punch_time) 'Date',  min(convert(time(0), punch_time)) 'IN', max(convert(time(0), punch_time)) 'OUT' FROM [iclock_transaction] where CONVERT(DATE, punch_time) between '6/1/2025' and '6/28/2025' GROUP BY CONVERT(DATE, punch_time) ,emp_code Order by emp_code

Where CONVERT(Date, punch_time) Between '"6/1/2025' and '6/18/2025' GROUP BY CONVERT(DATE, punch_time) ,emp_code Order by emp_code,Convert(Date, punch_time) 



select distinct local_net_address, local_tcp_port from sys.dm_exec_connections where local_net_address is not null










































update iclock_transaction set punch_time = '2025-05-13 16:53:14.000' where id = 2382410







SELECT *  FROM "TADAWI"."@SBO_BIOMETRIC"  T0




UPDATE "@SBO_BIOMETRIC" set "U_StartDate" = '25.06.01' where "Code" = '1'


update "DUBAILIMITEDINV"."@SBO_BIOMETRIC"  T0 SET T0."U_StartDate" = '2025.07.01' where T0."Code" = '1'