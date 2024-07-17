SELECT 
--T0."empID" as "SAP Code", 

T0."ExtEmpNo" as "Employee ID", 
--'LBT' as "Transaction Type Code",
CASE WHEN T0."U_WPSBNK" = 'EIB' THEN 'BT'
WHEN T0."U_WPSBNK" = 'EBI' THEN 'BT'
ELSE 'LBT' END as "Transaction Type Code",
 
'3708435638001' as "Debit Account No.",
'' as "Beneficiary ID",
T0."bankAcount" as "BeneficiaryAccountNo.",
T0."firstName", 
T0."lastName",
'' as "BeneficiaryAddr. Line 1",
'' as "BeneficiaryAddr. Line 2",
'' as "BeneficiaryAddr. Line 3",
(select T3."BankName" from ODSC T3 where T3."BankCode" = T0."bankCode") as "Beneficiary Bank Name", 
'AE' as "Beneficiary Bank Country",
'' as "Beneficiary Bank Location",
'' as "Beneficiary Bank Address",
 
T0."U_WPSBNK" as "Beneficiary Bank Wsift Code", 
CURRENT_DATE as "Value Date",
'AED' as "Transaction Currency",
'' as "Transaction Amount",
'SHA' as "Charge Type",
'' as "Purpose Code",
'Salary01' as "Customer Reference No",
'Salary' as "Purpose Of Payment",
'' as "Intermediatory Bank Swift Code",
'' as "Routing Code",
'' as "Beneficiary Purpose Code",
'AE' as "Beneficiary Country",
'' as "Account Identifier"
FROM OHEM T0 

WHERE 


T0."Active" = 'Y'