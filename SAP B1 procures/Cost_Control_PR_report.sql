/* select T."DocNum" from "OPOR" T INNER JOIN POR1 T1 ON T1."DocEntry"=T."DocEntry" WHERE  T."DocDate" ='[%1]' and  T."DocDueDate" ='[%2]'  */

select distinct  PO."DocEntry",
PO."DocNum" AS "PO DOC NO",
 (CASE When PO."DocType"='I' then 'Item' When PO."DocType"='S' Then 'Service' 
	end ) as "PO Type",
	 PO."NumAtCard" AS "Quotation Ref No.",
---------------P1."OpenQty",
to_date(PO."DocDate") AS "PO DATE",
YEAR(PO."DocDate" ) AS "Year", 
month(PO."DocDate" ) as "Month",
PO."CardCode" AS "Code" ,
PO."CardName" as "Name",
(case when PO."DocStatus"='O' then 'Open'
When PO."DocStatus"='C' AND PO."CANCELED"='N' then 'Closed' 
When PO."DocStatus"='C' AND PO."CANCELED"='Y' then 'Cancelled'
end )
AS "PO STATUS",
PO."DocTotal" AS "PO TOTAL",
 PO."Comments" AS "PO Remarks",
PO."U_SalesQuoteRef" as "Sales Quote Reference",
PO."U_DEPARTMENTT",
PO."U_Division" as "Projects/Contracts",
(SELECT div."PrjName" FROM OPRJ div WHERE div."PrjCode" =  PO."U_Division") as "Project/Contract Name",
PO."U_Contract" as "Div/Dist",
(SELECT cc."PrcName" FROM OPRC cc WHERE cc."PrcCode" = PO."U_Contract") as "Div/Dist Name",
PO."U_CATEGORY",
PO."U_TYPE",

/*
 PO."U_Division" as "Division", (SELECT div."PrjName" FROM OPRJ div WHERE div."PrjCode" =PO."U_Division") as "Division Name",
PO."U_DEPARTMENTT" AS "Department", PO."U_CATEGORY" as "Category", PO."U_TYPE" as "Type",
-----(select "Contract"(PO."DocEntry" ) from DUMMY) "Contract",
------(select "Project"(PO."DocEntry" ) from DUMMY)as "Project",
(SELECT  STRING_AGG("OcrCode",',') FROM (select DISTINCT "OcrCode" from POR1 K WHERE K."DocEntry"= PO."DocEntry" AND "OcrCode"<>''  GROUP BY "OcrCode" ))as "Contract",
(SELECT prj."PrjName" FROM OPRJ prj WHERE prj."PrjCode" = (SELECT  STRING_AGG("OcrCode",',') FROM (select DISTINCT "OcrCode" from POR1 K WHERE K."DocEntry"= PO."DocEntry" AND "OcrCode"<>''  GROUP BY "OcrCode" ))) as "Contract Name",

(SELECT  STRING_AGG("Project",',') FROM (select DISTINCT "Project" from POR1 K WHERE K."DocEntry"= PO."DocEntry" AND "Project"<>''  GROUP BY "Project" ))as "Project",
(SELECT divv."PrjName" FROM OPRJ divv WHERE divv."PrjCode" =(SELECT  STRING_AGG("Project",',') FROM (select DISTINCT "Project" from POR1 K WHERE K."DocEntry"= PO."DocEntry" AND "Project"<>''  GROUP BY "Project" ))) as "Project Name",
*/

----(select distinct "Project" from POR1 WHERE "DocEntry"= PO."DocEntry" and "LineNum"=0 )as "Project",
-----(select distinct "OcrCode" from POR1 WHERE "DocEntry"= PO."DocEntry" and "LineNum"=0 )as "Contract",
/*
(CASE When PO."DocType"='I' 	Then 
(case when P1."OpenQty"=0 and P1."LineStatus"='C' Then 'Delivery Completed'
 when P1."OpenQty"<>0 and P1."LineStatus"='O' Then 
 'Delivery Not Completed/Partial Delivery Completed' end)
  When PO."DocType"='S' Then (case when P1."OpenSum"=0 and P1."LineStatus"='C' Then 'Delivery Completed'
   when P1."OpenSum"<>0 and P1."LineStatus"='O' Then 'Delivery Not Completed/Partial Delivery Completed' 
		end) 
	end ) AS "Delivery Status",*/
	
 M."PymntGroup" AS "Payment Terms Code" ,
(SELECT COUNT("DocEntry") from (SELECT DISTINCT (G."DocEntry") "DocEntry" FROM OPDN G INNER JOIN PDN1 G1 ON G."DocEntry"= G1."DocEntry" and  G1."BaseType"=PO."ObjType"  WHERE G1."BaseEntry"= (PO."DocEntry"))) as "No of GRN s",
G."DocEntry",
G."DocNum" AS "GRN DOC NO",
to_date(G."DocDate") AS "GRN DATE",
YEAR(G."DocDate" ) AS "Year", 
month(G."DocDate" ) as "Month",
---G."DocStatus" 
(case when G."DocStatus"='O' then 'Open'
When G."DocStatus"='C' AND G."CANCELED"='N' then 'Closed' 
When G."DocStatus"='C' AND G."CANCELED"='Y' then 'Cancelled'
end )
AS "GRN STATUS",
G."DocTotal" AS "GRN TOTAL",
 G."Comments" AS "GRN Remarks",
 (SELECT Count(DISTINCT "DocNum") FROM OPCH IV INNER JOIN PCH1 IV1 ON IV."DocEntry"= IV1."DocEntry"	and   IV1."BaseType"= G1."ObjType"WHERE IV1."BaseEntry" In 
 (G."DocEntry"))  "No of INVOICES",

IV."DocEntry",IV."BaseType",
IV."DocNum" AS "INV DOC NO",
to_date(IV."DocDate") AS "INV DATE",
YEAR(IV."DocDate" ) AS "Year", 
month(IV."DocDate" ) as "Month",
(case when IV."DocStatus"='O' then 'Open'
When IV."DocStatus"='C' AND IV."CANCELED"='N' then 'Closed' 
When IV."DocStatus"='C' AND IV."CANCELED"='Y' then 'Cancelled'
end )
---IV."DocStatus" 
AS "INV STATUS",
IV."DocTotal" AS "INV TOTAL",
IV."Comments" AS "INV Remarks"

 from
OPOR PO INNER JOIN POR1 P1 ON PO."DocEntry"=P1."DocEntry"
left JOIN PDN1 G1 ON G1."BaseEntry"=P1."DocEntry" and  G1."BaseType"=PO."ObjType" 
LEFT JOIN OPDN G ON G."DocEntry"= G1."DocEntry"
LEFT JOIN PCH1 IV1 ON IV1."BaseEntry"= G1."DocEntry"  and IV1."BaseType"= G1."ObjType"
LEFT JOIN OPCH IV ON IV."DocEntry"= IV1."DocEntry"
left join OCRD K ON PO."CardCode"=K."CardCode" 
---left join OCPR H ON H."CardCode"=K."CardCode" 
LEFT JOIN OCTG M ON PO."GroupNum" = M."GroupNum" 
WHERE G."DocDate" between '[%1]' and '[%2]' 
order by  PO."DocEntry",G."DocEntry",IV."DocEntry";