SELECT T0."UserCode", T0."UserID", 

Case when  T0."Action"  = 'L' then 'Locked'
when T0."Action" = 'O' then 'Logoff'
when T0."Action" = 'F' then 'Failed Login'
when T0."Action" = 'I' then 'Logon Succeeded'
when T0."Action" = 'P' then 'Password Changed'
when T0."Action" = 'U' then 'Unlocked'
when T0."Action" = 'C' then 'Created'

Else 'NA' end as "Performed Action", 
T0."Action" as "Action Code", 


T0."ActionBy", T0."ClientIP", T0."Date", T0."Time", T0."ClientName", T0."ProcessID", 
T0."SessionID", T0."ReasonID", T0."ReasonDesc", T0."WinSessnID", T0."WinUsrName", T0."ProcName", 
T0."AliveDurtn", T0."LogoutTime",
 T0."Source" FROM USR5 T0 ORDER BY T0."Date"