SELECT
	 T0."DocNum" as "LPO",
	T0."DocDate" as "Date",
             YEAR(T0."DocDate" ) AS "Year", 
             month(T0."DocDate" ) as "Month",
	 T0."CardName" as "Vendor Name",
	 (Case 	when T0."DocType" = 'I' then  M."ItemCode" 	Else M."Dscription"	End ) as "Item/Service",
	 (Case 	when T0."DocType" = 'I' then 'Item'	Else 'Service' 	End ) as "Item/Service",M."Price",
	 (Case 	when T0."DocType" = 'I' then  M."Quantity" 	Else M."U_Quantity"	End ) as "Quantity",	
	 (Case 	when T0."DocType" = 'I' then  M."LineTotal" Else M."LineTotal"	End ) as "LineTotal",	
	  (Case when T0."DocType" = 'I' then  J."BuyUnitMsr" Else M."U_UoM"	End ) as "Uom",
T0."U_Docref",
                 ----(Case when T0."DocType" = 'I' then  M."U_BaseRef" Else M."U_UoM"	End ) as "Sales Quote Ref",	 
	 T0."Comments" as "Remarks",

----M."U_BaseRef" as "Sales Quote Ref",
	T0."DocDueDate" as "Due Date",
	M."Project" as "Project",
M."OcrCode" as "Contract",
T0."U_SalesQuoteRef" as "Sales Quote Reference",
 T0."U_Division" as "Project", (SELECT div."PrjName" FROM OPRJ div WHERE div."PrjCode" =  T0."U_Division") as "Project Name",
T0."U_DEPARTMENTT" AS "Department", T0."U_CATEGORY" as "Category", T0."U_TYPE" as "Type",
-----(select "Contract"(PO."DocEntry" ) from DUMMY) "Contract",
------(select "Project"(PO."DocEntry" ) from DUMMY)as "Project",
(SELECT  STRING_AGG("OcrCode",',') FROM (select DISTINCT "OcrCode" from POR1 K WHERE K."DocEntry"= T0."DocEntry" AND "OcrCode"<>''  GROUP BY "OcrCode" ))as "Contract",
(SELECT prj."PrjName" FROM OPRJ prj WHERE prj."PrjCode" = T0."U_Contract") as "Contract Name",

(SELECT  STRING_AGG("Project",',') FROM (select DISTINCT "Project" from POR1 K WHERE K."DocEntry"= T0."DocEntry" AND "Project"<>''  GROUP BY "Project" ))as "Division",
(SELECT divv."PrjName" FROM OPRJ divv WHERE divv."PrjCode" =(SELECT  STRING_AGG("Project",',') FROM (select DISTINCT "Project" from POR1 K WHERE K."DocEntry"= T0."DocEntry" AND "Project"<>''  GROUP BY "Project" ))) as "Division Name",

	 T0."DocTotal" as "Document Total",
	 T0."U_CTX_CMNT" as "Comments",
T0."U_Docref" as "Document Reference",
	--T0."U_CTX_STTS" as "Status",
	Case 
	when T0."U_CTX_STTS" ='P' then 'Pending' 
	when T0."U_CTX_STTS" ='R' then 'Reject'

	Else 'Accept'
	End  as "Status",
	
	T1."PymntGroup"
	
FROM OPOR T0 inner join POR1 M  ON T0."DocEntry"=M."DocEntry"
LEFT JOIN OITM J ON J."ItemCode" = M."ItemCode"
LEFT JOIN OCTG T1 ON T0."GroupNum" = T1."GroupNum" -----WHERE T0."DocType" ='I'

---select "BuyUnitMsr" from OITM

order by T0."DocDate"
