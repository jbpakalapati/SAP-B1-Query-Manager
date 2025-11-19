SELECT  /*T0."Code", T0."Name", T0."U_EmpName", */

X1."empID", X1."ExtEmpNo",   ifnull (X1."firstName",' ') || ' '|| ifnull(X1."middleName",' ')|| ' '|| ifnull (X1."lastName",' ' ) as "Employee Name", 

X1."startDate",

/*X1."CostCenter", X1."U_Gratuity", X1."U_GSDate", X1."U_Cat",

CASE 
WHEN X1."U_EType"= '1' Then 'Staff' 
WHEN X1."U_EType" = '2' Then 'Labour' 
else X1."U_EType" 
end as "Employee Type",


CASE 
WHEN X1."U_PayMode"= '1' Then 'WPS' 
WHEN X1."U_PayMode"= '2' Then 'WPS Cash' 
WHEN X1."U_PayMode"= '3' Then 'Bank Transfer' 
WHEN X1."U_PayMode"= '4' Then 'Cash' 
WHEN X1."U_PayMode"= '4' Then 'WPS Exchange' 
else X1."U_PayMode" 
end as "PayMode",*/
CASE 
WHEN X1."Active"= 'Y' Then 'Active' 
WHEN X1."Active"= 'N' Then 'Inactive' 
else X1."Active"
end as "Status",
 X1."jobTitle",
(SELECT A0."Name" FROM OUDP A0 WHERE A0."Code" = X1."dept") AS "Department",
(SELECT A1."BPLName" FROM OBPL  A1 WHERE A1."BPLId" = X1."BPLId") AS "Branch",
(SELECT B1."firstName" FROM OHEM B1 WHERE  X1."manager" = B1."empID") AS "Manager",
(SELECT XA."Name" FROM OCRY XA WHERE  XA."Code" = X1."citizenshp") AS "Citizen",
X1. "govID" as "CPR No", X1."passportNo",
X1."startDate" AS "Joining Date",

(YEARS_BETWEEN (X1."startDate" , NOW())) AS "Experience in Years" ,


(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E001')  as "Basic",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E002')  as "Other Allowances",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E003')  as "Special Allowance",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E004')  as "Staff Accommodation Allowances",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E005')  as "Fixed Over time",
/*(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E006')  as "Special Allowance - Basic pay",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E007')  as "Driving Allowance",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E008')  as "Temproray Allowance",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E009')  as "Telephone Allowance",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E010')  as "Extra Duty Allowance",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E011')  as "Basic Allowance - C",
(SELECT T1."U_Amount" FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  AND T1."U_Code" ='E012')  as "Overtime",*/

(SELECT SUM (T1."U_Amount") FROM "@SBO_PREMPSALDET0" T1 WHERE T1."Code" = T0."Code"  

AND T1."U_Code" NOT IN ('E001','E002','E003','E004','E005','E006','E007','E008','E009','E010','E011','E012'))  as "Other Earnings",

(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D001')  as "Advance Salary",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D002')  as "Gosi Contribution",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D003')  as "LMRA",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D004')  as "Late / Early Deduction",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D005')  as "Fines / Penalties",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D006')  as "Insurance Premium Deduction",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D007')  as "Telephone Deduction",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D008')  as "Loan Deduction",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D009')  as "Rent Deduction",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D010')  as "Fixed Advance",
(SELECT T2."U_Amount" FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  AND T2."U_Code" ='D011')  as "Allowance Deduction-C",
(SELECT SUM (T2."U_Amount") FROM "@SBO_PREMPSALDET1" T2 WHERE T2."Code" = T0."Code"  
AND T2."U_Code" NOT IN ('D001','D002','D003','D004','D005','D006','D007','D008','D009','D010','D011'))  as "Other Deductions"
,T0."U_NetPay" as "Gross Salary"
FROM "@SBO_PREMPSALMSTR"  T0 right JOIN OHEM X1 ON T0."Code" = X1."empID"
where X1."Active" ='Y'
 order by X1."empID"