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

      T0."DocTotal" as "Document Total",
T0."U_SalesQuoteRef",
T0."U_DEPARTMENTT",
T0."U_Division" as "Projects/Contracts",
(SELECT div."PrjName" FROM OPRJ div WHERE div."PrjCode" =  T0."U_Division") as "Project/Contract Name",
T0."U_Contract" as "Div/Dist",
(SELECT cc."PrcName" FROM OPRC cc WHERE cc."PrcCode" = T0."U_Contract") as "Div/Dist Name",
T0."U_CATEGORY",
T0."U_TYPE",
	 T0."U_CTX_CMNT" as "Comments",
---T0."U_Docref" as "Document Reference",
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
