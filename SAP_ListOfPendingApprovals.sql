SELECT 
T0."WddCode", 
T0."WtmCode", 
T0."OwnerID", 
T0."DocDate", 
T0."CurrStep", 
T0."Status", 
T1."Name", 
T2."Name" as "Pending With ",
T0."Remarks" 
FROM OWDD T0  INNER JOIN OWTM T1 ON T0."WtmCode" = T1."WtmCode" 
INNER JOIN OWST T2 ON T0."CurrStep" = T2."WstCode" 
WHERE T0."Status" = 'W'