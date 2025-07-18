Select 

CASE WHEN T3."BankName" = 'EIB' THEN 'TR'

WHEN T3."BankName" ='EBI' THEN 'TR'

ELSE 'TT' END AS "PayMode",


T3."BankName" as "Beneficiary Bank Name",
T1."AcctName" as "Beneficiary Name",



(Select A."PymAmount" FROM "PWZ4" A WHERE A."IdEntry" = T4."IdEntry" and A."CardCode" =T4."CardCode") as "PayAmount",
/*
Case When  T4."ObjType" <>19 then
SUM(T4."InvPayAmnt") 
Else SUM(-T4."InvPayAmnt") END 
AS "PayAmount",*/
T4."PymCurr" as "Pay Currency",
T0."DflIBAN" as "Beneficiary account number / IBAN No",
--T0."Address"||T0."Block"||T0."City"||

(Select  "Name" from OCST where "Code" = T0."State1" and "Country" = T0."Country" )||T0."Country" as "Beneficiary Address",
(Select STRING_AGG("E_MailL",'; ') from OCPR where "CardCode"=T4."CardCode") as "Bene Email Id",
"WizardName" as "Payment Details for Beneficiary",-- changed as per Financial Department requirement

--STRING_AGG (T4."IsrRef",';' ) as "Payment Details for Beneficiary",
(Select "Name" from OCRY where "Code"=T0."Country") as "Payable Country",
---T0."DflSwift" as "BIC Code for Bene Bank",-- changed as per Financial Department  requirement
T3."SwiftNum" as "BIC Code for Bene Bank",
'' as "Route Code",
'' as "Sort Code",
'' as "BIC / SWIFT Intermediary Bank 1" ,
'2' as "Charge type",

CASE WHEN T3."BankName" IN ('EIB','EBI') then ' '


Else

'GDI'

End

as "Transaction Type",

CASE WHEN T3."BankName" IN ('EIB','EBI') then ' '
ELSE

'/REF/' 

END as "Payment Type",



STRING_AGG("NumAtCard",'; ')  as "Payment Details Link (for Invoice File)",
'' as "Transaction reference",
'' as "Account Debit Date",
(Select "Name" from OCRY where "Code"=T0."Country") as "Beneficiary country"
--,(Select  "Name" from OCST where "Code" = T0."State1" and "Country" = T0."Country" ) as "Beneficiary State"
 	 
FROM PWZ3 T4
LEFT OUTER JOIN "OCRD" T0 ON T0."CardCode" = T4."CardCode" 
LEFT OUTER JOIN "OPWZ" T2 ON T2."IdNumber" = T4."IdEntry" 
LEFT OUTER JOIN "OCRB" T1 ON T1."CardCode" = T0."CardCode" AND T1."BankCode" = T0."BankCode" AND T1."Account" = T0."DflAccount" 
LEFT JOIN ODSC T3 on T3."BankCode"=T1."BankCode" and T3."CountryCod" = T1."Country"
WHERE ("PymMeth" = 'Bank Transfer' 
	OR "PymMeth" = 'BT' 
	OR "PymMeth" = 'Outgoing BT' 
	OR "PymMeth" = 'Outgoing Cheque') 
AND T2."Status" = 'E' 
and T4."Checked"='Y'
AND T2."WizardName" = '[%0]'
AND T4."ObjType" <>19
--AND T4."CardCode" ='GCV0001'

GROUP BY T3."BankName",T1."AcctName",
T4."PymCurr",T0."DflIBAN",T4."ObjType",T4."IdEntry",T2."WizardName",
--,T4."PayAmount",

T0."Address",T0."Block",T0."City",T0."State1",T0."Country" ,
T4."CardCode",T0."DflSwift",T2."IdNumber",T1."UsrNumber2",T3."U_S_PFrgnName",T3."SwiftNum" ;    -------------------T1."UsrNumber1"