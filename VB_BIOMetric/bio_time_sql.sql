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




UPDATE "@SBO_BIOMETRIC" set "U_StartDate" = '2025.07.01' where "Code" = '1'


update "DUBAILIMITEDINV"."@SBO_BIOMETRIC"  T0 SET T0."U_StartDate" = '2025.07.01' where T0."Code" = '1'






--Crystal report 
--Suppress Code
-- for sigature to apprear & disapprear based on ther document approval. 
{Command.SIGN}='NO'


--Bulk update of Employee master

UPDATE OHEM T0 SET T0."manager" = '1288' Where T0."ExtEmpNo" IN ( '2025','2671','2733','2642','2698','2652','2691')


UPDATE OHEM T0 SET T0."U_CATGTYPE" = 'C002' WHERE T0."ExtEmpNo" IN ( '500171','500292','500285','500201','500305','500284','500303','500109','500115','500279','500221','500138','500181','500301','500136','500290','500273','500274','500304','500268','500263','500131','500254','500317','500293','500129','602902','602914','602140','602915','500320','600150','500340','500368','500369','500371','500372','500373','500370','500376','500377','500378','500381','500383','500384','500388','500389','500397','500400','500401','500405','500406','500407','500409','500410','500412','500416','500413','500411','500414','500408','500419','500420','500421','500423','500424','500425')


-- Employee Annual Leave White & blue Collar type change.

select * from "@SBO_PREMPSALDET2"  T0
--Inner join "@SBO_PREMPSALMSTR" T1 on T0."Code"=T1."Code"
where T0."Code"='4511'
and "U_Code"='L001'


UPDATE "@SBO_PREMPSALDET2" T0 set "U_Code"='L013',"U_dscr"='Annual Leave-White Collar' where T0."Code"='4511'

-- 
UPDATE OPRC T0 SET T0."Active" = 'N' WHERE T0."PrcCode" IN ('1 Nu Kit','ALI SULT','ALW CLN','ALW MAN','ALY CLN','ALY KIFA','ALY MAN','ALYKIFMP','BEL BIKE','BEL CIVI','BEL MAN','Bloom F','BLR MAN','Boom Car','BUTI MAN','Carwash','CLN CAMC','COMCLN','CW store','DAR AL A','DES DAC','DES MAN','DES MEP','DHA CL','DHA MAN','DIF CLN','DIFC HOS','DLI LRY','DLI MEP','DLI WAR','DLIHOSP','DLY CLN','DPO CLN','DPO DAC','DPO HOS','DPO K9C','DPO KNL','DPO LAS','DPO MAN','DPO MEP','DPP CL','DUB HOS','DUC CLN','DUST MAN','FITOUT','GDR CLN','GDR LAS','GDR MEP','HAYT MAN','HPPR-809','HPPR-836','HPPR-841','HPPR-850','HPPR-870','HPS AWSL','IDF MEP','IMM MEP','LAD CAMC','LAS OTH','LEB CLN','LEB MEP','MBR DATA','MBRS CLN','MBRS MEP','MBRS_SG','NED CLN','NED LAN','NED MAN','NED MEP','NED SSC','PPD HOS','PPD MEP','PPD MEP1','SAL QUO','Saloon','SHA COS','SIR CLN','SIR DAC','SIR HOS','SIR MEP','SME MEP','SME PRJ','SMTVLT','TDC CLN','TDW CLN','TDW MAN','TDW MEP','TLC CLN','TLT HOS','TLT MEP','TRU MAN','TSD CLN','TSD LAS','TSD MAN','TSD MEP','UXE MAN','WSL BIKE','WSL MAN')





SELECT T0."DocDate", YEAR(T0."DocDate" ) AS "Year", 
             month(T0."DocDate" ) as "Month",
T0."DocNum",  T1."ItemCode", T1."Dscription", T1."Quantity", T1."Price", T1."unitMsr", T1."LineTotal", 

----T1."OcrCode",  

---T1."OcrName", T1."Project", 
T0."U_DEPARTMENTT",
T1."Project" as "Projects/Contracts",
(SELECT div."PrjName" FROM OPRJ div WHERE div."PrjCode" =  T1."Project") as "Project/Contract Name",
T1."OcrCode" as "Div/Dist",
(SELECT cc."PrcName" FROM OPRC cc WHERE cc."PrcCode" = T1."OcrCode") as "Div/Dist Name",
T0."U_CATEGORY",
T0."U_TYPE",
T0."Comments", T1."U_BaseRef" FROM OIGE T0  INNER JOIN IGE1 T1 ON T0."DocEntry" = T1."DocEntry" 
---WHERE (T0."DocDate" >=[0] OR [0]='')AND (T0."DocDate" <=[1] OR [1]='') 
WHERE T1."OcrCode" = [%1]
ORDER BY T0."DocDate"




UPDATE OHEM T0 SET  T0."manager" = '1327' where T0."ExtEmpNo" in ('591','646','618','658','598','592','597','823','833','914','2219','2464','2510','2480','2138','790','2196','2211','2218','2237','2236','2245','2259','2271','2319','2408','2546','2406','2731')

