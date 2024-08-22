SELECT 
T0."UserCode", 
T0."Date", 
T0."ClientIP", 
T0."ClientName", 
T0."ProcessID", 
T0."WinUsrName", 
T0."WinSessnID" 
FROM USR5 T0 WHERE T0."Date" >=[%0] and T0."Date" <=[%1]


SELECT * FROM USR5 T0 WHERE T0."Date" >=[%0] and T0."Date" <=[%1]