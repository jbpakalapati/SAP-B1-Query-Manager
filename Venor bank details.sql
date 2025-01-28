SELECT CASE WHEN T0."BankCode" = 'EIB' THEN 'TR'
WHEN T0."BankCode" ='EBI' THEN 'TR'
WHEN T0."BankCode" ='Emirates NBD Bank' THEN 'TR'
WHEN T0."BankCode" ='Emirates NBD Bank (PJSC)' THEN 'TR'
ELSE 'TT' END AS "PaymentType Code",

'C' AS "Mode of Operation",
T0."CardCode" as "Bene Id",
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
       REPLACE(REPLACE(REPLACE(REPLACE(T0."CardName",
        '&',''),'-',''),'/',''),'*',''),'.',''),
        ',',''),'!',''),'*',''),'(',''),')','') as "Beneficiary Name",
---T0."CardName" as "Beneficiary Name",
T0."DflIBAN" as "Beneficiary Account No",
'' as "Beneficiary Currency",
'Dubai' as "Beneficiary Addr. Line 1",
'UAE' as "Beneficiary Addr. Line 2",
'' as "Beneficiary Addr. Line 3",
'' as "Beneficiary Country",
T0."E_Mail" as "Beneficiary E-mail Id",
T0."Phone1" as "Beneficiary Phone No",
T0."DflSwift" as "Beneficiary Bank IFSC Code",
'' as "Beneficiary Account Type", T1."SwiftNum", T1."BankName",
---T0."DflSwift" as "Swift Address", 
---(SELECT T1."SwiftNum" from ODSC T1 Where T1."BankCode" =  T0."BankCode") as "Swift Address",
---T0."BankCode" as "Bank Name",
---(SELECT T2."BankName" from ODSC T2 Where T2."BankCode" =  T0."BankCode") as "Bank Name",
'' as "Branch Name",
'' as "Country Code",
'' as "City Namee",
'' as "Clearing Code Details" FROM OCRD T0 INNER JOIN ODSC T1 ON T0."DflBankKey" = T1."AbsEntry" WHERE T0."CardType" = [%1] and T0."frozenFor" = [%2] ORDER BY T0."CardCode"