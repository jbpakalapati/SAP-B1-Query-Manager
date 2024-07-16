


SELECT T0."DocNum", 
Case when  T0."DocStatus" = 'C' then 'CLOSED'
when T0."DocStatus" = 'O' then 'OPEN'
Else 'NO' end as "Doc Status",

T0."DocDate", 

T0."CardCode", T0."CardName", T1."ItemCode", T1."Dscription", T1."Quantity", T1."Price" as "Unit Price", T1."TotalSumSy", 

T0."U_CATEGORY",  T0."U_Contract", T0."U_DEPARTMENTT", T0."U_Division", T0."U_Location", T0."U_Docref", 
T0."SlpCode" as "Buyer", 
(select T3."SlpName" from OSLP T3 where T0."SlpCode" = T3."SlpCode") as "Buyer Name"


FROM "HPFM"."OPOR"  T0 INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry" ORDER BY T1."DocDate"