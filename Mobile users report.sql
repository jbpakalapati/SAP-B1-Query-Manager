SELECT T0."USER_CODE", T0."U_NAME", T0."E_Mail", T0."PortNum", 

Case when  T0."MobileUser" = 'Y' then 'MOBILE USER'
when T0."MobileUser" = 'N' then 'NO'
Else 'NA' end as "Mobile",

Case when  T0."Locked" = 'Y' then 'LOCKED'
when T0."Locked" = 'N' then 'ACTIVE'
Else 'NA' end as "Locked",
(SELECT T2."Name" from OUBR T2 Where T2."Code" =  T0."Branch") as "Branch",
(SELECT T3."Name" from OUDP T3 Where T3."Code" =  T0."Department") as "Department"


FROM OUSR T0 ORDER BY T0."MobileUser" DESC