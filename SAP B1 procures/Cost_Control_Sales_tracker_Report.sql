/* select T."DocNum" from "OPOR" T INNER JOIN POR1 T1 ON T1."DocEntry"=T."DocEntry" WHERE  T."DocDate" ='[%1]' and  T."DocDueDate" ='[%2]'  */

/*
select P."CardCode", P."CardName", P."NumAtCard", P."DocNum", P."U_SQTYPE", P."U_Division", 
(     SELECT T0."PrjName" FROM OPRJ T0 WHERE T0."PrjCode"=P."U_Division") AS "Division Name",
    P."DocEntry" as "SQ Draft DocEntry",P."DocNum" as "SQ Draft DocNum",
 (select "U_NAME" FROM OUSR WHERE "USERID"=  T0."UserSign") as "Originator"
,
 T17."SlpName",
     P."DocDate" as "SQ Date",
P."CardName" as "SQ Cus",
P."DocTotal" as "SQ DocTotal",
     	 T0."CurrStep" as "Current stage Code",
	 Case when T0."Status"='N' then 'Rejected'
when T0."Status"='W' then 'Pending'
when T0."Status"='Y' then 'Approved'
Else ''END as "Approval Doc Status",	

T27."DocNum"  AS "Sales Quotation Document Number ",
T27."DocTotal" as "SQ DocTotal",
O."DocNum" as "Sales Order Doc Num",O."DocDate",O."DocTotal" as "SO DocTotal"
,T4."DocEntry" as "Invoice Doc Entry"
,T4."DocNum" as "Invoice Doc Num",T4."DocTotal" as "INV DocTotal"
	
from
 ODRF P LEFT JOIN 
 OWDD T0 ON P."DocEntry"=T0."DraftEntry"  AND P."ObjType"= T0."ObjType"
left outer JOIN OSLP T17 ON P."SlpCode" = T17."SlpCode"
left outer JOIN OQUT T27 ON T0."DocEntry"= T27."DocEntry" 
LEFT JOIN QUT1 R1 ON R1 ."DocEntry"= T27."DocEntry" 
LEFT JOIN RDR1 O1 ON  R1."LineNum" = O1."BaseLine" and R1."DocEntry" =O1."BaseEntry"
LEFT JOIN ORDR O ON  O1."DocEntry"= O."DocEntry" 
LEFT JOIN INV1 T2   on T2."BaseLine"=O1."LineNum" and T2."BaseEntry"= O1."DocEntry" and T2."BaseType"= O1."ObjType"
   LEFT JOIN OINV T4  on  T4."DocEntry"= T2."DocEntry" 



where T0."DraftEntry"<>'0'and P."ObjType"='23'
AND P."DocDate" Between '[%1]' and '[%2]'
 ------and  DAYS_BETWEEN(P."DocDate",CURRENT_DATE)<=180
--- and T0."ProcesStat" ='W'  and T1."Status"='W' 
GROUP BY 
P."DocNum" , 
T0."WtmCode" ,
T27."DocNum",
T0."CurrStep",
T0."DocEntry",
P."CardName",
T17."SlpName",
T0."DocDate",
T0."Status",
T0."Remarks",
T0."UserSign",P."DocTotal",T27."DocTotal" ,
T0."CreateDate",T4."DocEntry",T4."DocNum" ,O."DocTotal",T4."DocTotal",
T0."IsDraft",

P."CardCode", P."CardName", P."NumAtCard", P."DocNum", P."U_SQTYPE", P."U_Division",O."DocEntry" ,O."DocNum" ,
P."DocEntry",
    P."DocDate",O."DocDate"

ORDER BY P."DocNum"

*/

Select Distinct 
T0."NumAtCard" as "Quote No", 
to_date(T0."DocDate") AS "SQ DATE",
YEAR(T0."DocDate" ) AS "Year", 
month(T0."DocDate" ) as "Month",
T8."SlpName" as "Requester" ,
T0."CardCode" As "Client Code", 
T0."CardName" as "Client Name", 

T0."U_WORKORDER" as "Work Order NO", 
T0."DocNum" as "Quotation No",
TO_VARCHAR(T0."U_CMNT") as "Sales Quotation Subject", 
T0."DocDate" as "Quotatoon Date",

---T0."Status",
(case when T0."DocStatus"='O' then 'Open'
When T0."DocStatus"='C' AND T0."CANCELED"='N' then 'Closed' 
When T0."DocStatus"='C' AND T0."CANCELED"='Y' then 'Cancelled'
end )
AS "SQ STATUS",
--T0."U_SQTYPE", T0."U_Division",
T0."U_DEPARTMENTT",
T0."U_Division" as "Projects/Contracts",
(SELECT div."PrjName" FROM OPRJ div WHERE div."PrjCode" =  T0."U_Division") as "Project/Contract Name",
--T0."U_Contract" as "Div/Dist",
--(SELECT cc."PrcName" FROM OPRC cc WHERE cc."PrcCode" = T0."U_Contract") as "Div/Dist Name",
T0."U_CATEGORY",
T0."U_TYPE",
T0."DocTotal" as "SQ Total",
T0."VatSum", ( T0."DocTotal"- T0."VatSum") as " SQ Amount without VAT",
T3."DocNum" as "Sales Order No",
T3."DocDate" as "Order Date",
T3."DocTotal" as "Order Total",
T5."DocNum" as "Delivery No",
T5."DocDate" as "Delivery Date",
T5."DocTotal" as "Delivery Total",

T7."DocNum" as "Invoice No",
T7."DocDate" as "Invoice Date",
YEAR(T7."DocDate" ) AS "Invoice Year", 
month(T7."DocDate" ) as "Invoice Month",

T7."DocTotal" as "Invoice Total",
T7."VatSum", ( T7."DocTotal"- T7."VatSum") as " INV Amount without VAT"
from OQUT T0
Left join QUT1 T1 on T0."DocEntry" = T1."DocEntry"
--------------------Quotation - Order--------------------------------------
Left join RDR1 T2 on T2."BaseEntry" = T1."DocEntry" and T2."BaseType" = T1."ObjType" 
                  and ( T2."BaseLine" = T1."LineNum"
                  or T2."ItemCode" = T1."ItemCode" ) 
Left Join ORDR T3 on T2."DocEntry" = T3."DocEntry" 

--------------------Order - Delivery--------------------------------------
Left join DLN1 T4 on T4."BaseEntry" = T2."DocEntry" and T4."BaseType" = T2."ObjType"
                  and ( T4."BaseLine" = T2."LineNum"
                  Or T4."ItemCode" = T2."ItemCode" ) 
Left Join ODLN T5 on T4."DocEntry" = T5."DocEntry"
--------------------Delivery - Invoice--------------------------------------
Left join INV1 T6 on T6."BaseEntry" = T4."DocEntry" and T6."BaseType" = T4."ObjType"
                  and (T6."BaseLine" = T4."LineNum"
                  Or T6."ItemCode" = T4."ItemCode") 
Left Join OINV T7 on T6."DocEntry" = T7."DocEntry"
--------------------------------------------------------------------------
Left join OSLP T8 ON T1."SlpCode" = T8."SlpCode"

Where T7."CANCELED" = 'N' and T0."DocDate">=[%1] and T0."DocDate"<=[%2]
order by T0."DocDate"