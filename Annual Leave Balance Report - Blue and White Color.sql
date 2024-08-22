SELECT T0."empID",T0."ExtEmpNo",  T0."firstName", T0."middleName", T0."lastName", 

Case When T0."U_Cat" ='C001' Then 'BlueCollar'

When T0."U_Cat" ='C002' Then 'WhiteCollar' 

Else 'NotUpdated' End As "Category",

(SELECT A."U_LeaBda" FROM "LAVCITYLAUNDRY"."@SBO_PREMPSALDET2"  A WHERE A."U_Code" ='L001' and IFNULL ( A."U_Pay" ,1) <> 2  and A."Code" = T0."empID") AS "BlueCollarBalance",
(SELECT A."U_LeaBda" FROM "LAVCITYLAUNDRY"."@SBO_PREMPSALDET2"  A WHERE A."U_Code" ='L013' and IFNULL ( A."U_Pay" ,1) <> 2  and A."Code" = T0."empID") AS "WhiteCollarBalance",

T0."U_Cat" FROM OHEM T0 WHERE T0."Active" ='Y'