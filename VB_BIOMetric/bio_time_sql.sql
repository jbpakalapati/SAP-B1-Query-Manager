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

SELECT *  FROM "HPFM"."@SBO_BIOMETRIC"  T0



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

--- Cancel Leave Application
Update "ALMADALLAH"."@SBO_PRLEVAPPMSTR"  T0 SET T0."U_AppStat" = 'N' WHERE T0."U_Appid" = 'LA004369'



UPDATE "TELETRONICS"."@SBO_ATTSUMMARYMSTR" T1 set T1."U_STATUS" = '' where T1."U_STATUS" = 'A'


--- LPO cancel of Old

Update OPOR T0 SET  T0."DocStatus" = 'C', T0."CANCELED" = 'Y'  WHERE T0."DocNum" = '100008'

--- Arun's requirement 

Update OPOR T0 SET  T0."DocStatus" = 'C', T0."CANCELED" = 'N'  WHERE T0."DocNum" IN ('400624','500338','500538','500660','400184','500246','500537','500344','400128','500542','400428','500247','500116','500293','300547','500602','400709','400604','500339','500152','500063','500334','500337','500210','500223','400294','500627','500566','500494','500193','500176','500211','500061','400200','400686','400138','500082','500172','400629','500310','500384','400717','500485','500497','500428','500506','500201','500288','500372','500079','500207','400088','500380','500255','500159','500595','500014','500039','500456','500002','400589','500571','500238','500594','500027','400671','500110','500074','500590','400080','500646','500097','500001','500262','400147','500264','500199','500202','500028','400494','500547','400507','500185','500031','500153','500121','500629','500261','400697','500533','500237','500589','500134','500618','500650','500644','500067','500600','500527','500630','500476','500558')

Update OPOR T0 SET  T0."DocStatus" = 'C', T0."CANCELED" = 'N'  WHERE T0."DocNum" IN ('600003','600016','600052','600200','600081','600149','600178','600237','600269','600268','600338','600334','600370','600408','600379','600438','600444','600581','600621','600631','600630','600625','600688','600766','600791','600806','600810','600819','600896','600906','600899','600940','600994','601043','601050','601108','601111','601137','601299','601318','601355','601402','601376','601401','601502','601503','601489','601536','601526','601534','601533','601562','601581','700013','700031','700039','700071','700099','700142','700141','700151','700192','700213','700284','700228','700241','700254','700273','700259','700296','700327','700351','700345','700340','700350','700458','700413','700417','700460','700436','700456','700493','700497','700499','700533','700531','700562','700564','700584','700676','700709','700819','700836','701033','701034','701026','701059','701083','701389','701435','701509','701584','701649','701648','701669','701778','701785','701919','702020','702034')

--- Leave Applications Report
SELECT T0."U_empcode",  T0."U_empname", T0."U_Appid" as "Application ID",T1."U_Code", T1."U_dscr", T1."U_LBal",T0."U_Appdate",T1."U_lfdate", T1."U_ltdate", T1."U_ladays", T0."U_AppStat" FROM "@SBO_PRLEVAPPMSTR"  T0 INNER JOIN "@SBO_PRLEVAPPDET0"  T1 ON T0."Code" = T1."Code" AND T0."U_Appdate" >= ADD_DAYS(CURRENT_DATE, -30) AND T0."U_Appdate" <= CURRENT_DATE Order by T0."U_Appdate"

-- Payroll Pre-process 

UPDATE "@SBO_PRCONTROL"  T0 SET T0."U_DatChk" = 2, T0."U_ChkBy" = '', T0."U_ChkDate" ='', T0."U_PrDate" = '', T0."U_PRProcs"=2, T0."U_LAccr" = 2, T0."U_LAAMTJV"=2
