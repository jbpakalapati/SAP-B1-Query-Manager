SELECT 

CASE WHEN T0."CardType"='S' then 'Vendor'
 WHEN T0."CardType"='C' then 'Customer' end as "Type"
,T0."CardCode",T0."CardName" ,'' as "Category",  T2."U_NAME" as "Created By",T0."CreateDate" as "Created Date",

CASE WHEN T0."validFor" ='Y' then 'Active'
when T0."validFor" ='N' then 'Not Active' end as "Status"

 FROM OCRD T0
inner join OUSR T2 ON T0."UserSign"=T2."USERID" WHERE T0."CardType" = [%1] ORDER BY T0."CardType"