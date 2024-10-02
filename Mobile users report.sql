SELECT T0."USER_CODE", T0."U_NAME", T0."E_Mail", T0."PortNum", 

Case when  T0."MobileUser" = 'Y' then 'MOBILE USER'
when T0."MobileUser" = 'N' then 'NO'
Else 'NA' end as "Mobile",

Case when  T0."Locked" = 'Y' then 'LOCKED'
when T0."Locked" = 'N' then 'ACTIVE'
Else 'NA' end as "Locked",
T0."Department", T0."Branch" 

FROM OUSR T0