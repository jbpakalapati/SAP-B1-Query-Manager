CREATE FUNCTION "PercentageCalculation"(IN MAN DOUBLE,IN MAT DOUBLE,IN SUBCON DOUBLE)
	RETURNS TABLE (	
	ManPower DOUBLE,
    Material DOUBLE,
  	SubContract DOUBLE
		) 
	LANGUAGE SQLSCRIPT
	SQL SECURITY INVOKER AS
BEGIN
RETURN 

SELECT 
(select case WHEN  :MAN > 0 AND :MAN <= 5000  then 
(Select "U_ManPower" From "@ME_PERCENT" WHERE "Code"='DP(MP)<5000')
 When  :MAN >=5001  AND :MAN <= 25000  then 
(Select "U_ManPower" From "@ME_PERCENT" WHERE "Code"='DP(MP)<25000')
 When :MAN >= 25001   AND :MAN <= 50000  then 
(Select "U_ManPower" From "@ME_PERCENT" WHERE "Code"='DP(MP)<50000')
 When  :MAN > 50000  then 
(Select "U_ManPower" From "@ME_PERCENT" WHERE "Code"='DP(MP)>50000')
 When  :MAN = 0  then 0
ELSE 0
END AS "ManPower"
FROM DUMMY) AS "MANPOWER"

 
,(select 
case 
 When  :MAT > 0 AND :MAT <= 1000000  then 
(Select "U_Material" From "@ME_PERCENT" WHERE "Code"='DP(MT)<100000')
 When :MAT >=  1000001  AND :MAT <= 5000000  then 
(Select "U_Material" From "@ME_PERCENT" WHERE "Code"='DP(MT)<500000')
 When :MAT > 5000000  then 
(Select "U_Material" From "@ME_PERCENT" WHERE "Code"='DP(MT)>500000')
When  :MAT = 0  THEN 0
ELSE 0
END AS "Material"
FROM DUMMY)AS "MATERIAL"

,(select 
case WHEN  :SUBCON >0 AND :SUBCON <= 500000  then 
(Select "U_SubContract" From "@ME_PERCENT" WHERE "Code"='DP(SC)<500000')
 When  :SUBCON >= 500001 AND :SUBCON <= 1000000  then 
(Select "U_SubContract" From "@ME_PERCENT" WHERE "Code"='DP(SC)<1000000')
 When  :SUBCON >= 1000001  AND :SUBCON <= 5000000  then 
(Select "U_SubContract" From "@ME_PERCENT" WHERE "Code"='DP(SC)<5000000')
 When  :SUBCON > 5000000  then 
(Select "U_SubContract" From "@ME_PERCENT" WHERE "Code"='DP(SC)>5000000')
 When  :SUBCON =0  then 0
ELSE 0
END AS "SubContract"

FROM DUMMY) AS "SUBCONTRACT" FROM DUMMY
;
END;