Select *, DAYS_BETWEEN(X."PR Approved Date" ,X."PO Created Date" ) as "No of Days" from (SELECT DISTINCT T0."DocNum" as "PR NO." ,T0."DocDate" as "PR Date", 

(SELECT
  max( t2."UpdateDate")
FROM OWDD t1 
LEFT JOIN WDD1 t2 ON t1."WddCode"=t2."WddCode" where t1."DocEntry"=T0."DocEntry" and t1."ObjType"=1470000113) as "PR Approved Date",

( select DISTINCT A."U_NAME" from OUSR A  

  INNER JOIN OPRQ B  ON B."UserSign"=A."USERID" and B."DocEntry"=T0."DocEntry") as "Created By"

 ,T5."SeriesName" || '-'|| T4."DocNum" as "PO Num", T4."DocDate" as "PO Date",T4."CreateDate" as "PO Created Date",

( select DISTINCT A."U_NAME" from OUSR A  

  INNER JOIN OPOR B  ON B."UserSign"=A."USERID" and B."DocEntry"=T4."DocEntry") as "PO Created By"

 FROM OPRQ T0
INNER JOIN PRQ1 T2 on T0."DocEntry"=T2."DocEntry"
LEFT JOIN POR1 T3 on T3."BaseEntry"=T2."DocEntry"
LEFT JOIN OPOR T4 on T4."DocEntry"=T3."DocEntry"
LEFT JOIN NNM1 T5 on T4."Series"=T5."Series"
ORDER BY T0."DocDate" DESC)X