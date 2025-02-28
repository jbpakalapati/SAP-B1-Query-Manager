CREATE PROCEDURE SBO_SP_TransactionNotification
(
	in object_type nvarchar(20), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255)
)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER 
AS
-- Return values
error  int;				-- Result (0 for no error)
error_message nvarchar (200); 		-- Error string to be displayed
Cnt1 int;
Line int;
begin

error := 0;
error_message := N'Ok';

--------------------------------------------------------------------------------------------------------------------------------

--------	ADD	YOUR	CODE	HERE

---------------------------IBAN Number LENGTH validation----------------

Cnt1:=0;
if :object_type ='2' and (:transaction_type ='A'  OR :transaction_type ='U') then 
SELECT COUNT (*) into Cnt1  FROM OCRD T0  INNER JOIN OCRB T1 ON T0."CardCode" = T1."CardCode"
Where T0."CardCode" = :list_of_cols_val_tab_del 
and IFNULL (T1."Country",'') ='UAE'
AND LENGTH (T1."IBAN") <> '23' 
and T0."CardType" ='S';
 if :Cnt1 > 0 then 
  error := 114;
  error_message := 'Please check IBAN No. properly. IBAN LENGTH should be 23' ;
 end if;							
end if;


 -----------------------------------------------------------

------------------------------------------------------------------------------IBAN DUPLICATE -------------------------------------------
Cnt1 := 0; 
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
-- Check for duplicate IBANs excluding the current business partner
SELECT COUNT("CardCode") INTO Cnt1 FROM OCRD WHERE "DflIBAN" = (SELECT "DflIBAN" FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del)   
 AND "CardCode" <> :list_of_cols_val_tab_del;    
  IF Cnt1 > 0 THEN       
   error := -30012;         
   error_message := 'Duplicate IBAN detected! IBAN must be unique across business partners.'; 
   END IF;
    END IF;
 
---------------------------------------------------------------------------------------------------------------------------
-----IBAN must not contain spaces-------------

Cnt1 := 0;							
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN							

    SELECT COUNT(*) 
    INTO Cnt1 
    FROM OCRD T0 
    WHERE T0."CardCode" = :list_of_cols_val_tab_del 
      AND T0."DflIBAN" LIKE '% %'; -- Check for spaces in IBAN

    IF Cnt1 > 0 THEN							
        error := 202502;							
        error_message := 'IBAN must not contain spaces.';							
    END IF;							

END IF;

-----IBAN must not contain  special characters-------------

Cnt1 := 0;							
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN							

    SELECT COUNT(*) 
    INTO Cnt1 
    FROM OCRD T0 
    WHERE T0."CardCode" = :list_of_cols_val_tab_del 
      AND (T0."DflIBAN" LIKE '%@%' 
      OR T0."DflIBAN" LIKE '%!%'
      OR T0."DflIBAN" LIKE '%#%'
      OR T0."DflIBAN" LIKE '%$%'
      OR T0."DflIBAN" LIKE '%^%'
      OR T0."DflIBAN" LIKE '%&%'
      OR T0."DflIBAN" LIKE '%*%'
      OR T0."DflIBAN" LIKE '%(%'
      OR T0."DflIBAN" LIKE '%)%'); -- Check for all common special characters

    IF Cnt1 > 0 THEN							
        error := 202501;							
        error_message := 'IBAN must not contain special characters.';							
    END IF;							

END IF;

---------------------------------------------------------------------------------------------------------------------------

Cnt1:=0;							
   if :object_type='2' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OCRD T0 Where T0."CardCode" = :list_of_cols_val_tab_del and 
      T0."U_TrdLicExp" IS NULL OR T0."U_TrdLicExp" = '' ;							
 							
      if :Cnt1>0 then							
            error := -114;							
            error_message := 'Please Enter T/R Expire Date';							
      end if;							
 end if;
-----------------You can not create GRPO without LPO---------------------------------------
Cnt1:=0;
							
   if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PDN1 T0 Inner Join OPDN T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"<>'22' and T1."CANCELED"='N' and T1."CardCode"<>'QGSV00106';							
 							
      if :Cnt1>0 then	
	    error := -202;							
            error_message := 'You can not create GRPO without LPO';							
      end if;							
 end if;
 -----------------You can not create LPO without PR---------------------------------------
/* Cnt1:=0;
							
   if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from POR1 T0 Inner Join OPOR T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"<>'1470000113' and T1."CANCELED"='N';							
 							
      if :Cnt1>0 then	
	    error := -203;							
            error_message := 'You can not create LPO without PR';							
      end if;							
 end if; */
 -----------------Contact person is mandatory------------------
Cnt1:=0;
							
   if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from POR1 T0 Inner Join OPOR T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and IFNULL(T1."CntctCode",0) =0 and T1."CANCELED"='N';							
 							
      if :Cnt1>0 then	
	    error := -204;							
            error_message := 'Contact Person is mandatory to add PO';							
      end if;							
 end if;
  -----------------Contact person is mandatory------------------
Cnt1:=0;
							
   if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from POR1 T0 Inner Join OPOR T1 On T0."DocEntry"=T1."DocEntry" 
      Left join OCPR T2 ON T2."CntctCode" = T1."CntctCode"
           where T1."DocEntry"= :list_of_cols_val_tab_del  and IFNULL(T2."E_MailL",'')='' and T1."CANCELED"='N';							
 							
      if :Cnt1>0 then	
	    error := -205;							
            error_message := 'Contact Person Email is empty. Please update email to contact person to add PO';							
      end if;							
 end if;
 -----------------Contact person is mandatory-----------
 Cnt1:=0;
							
   if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from DRF1 T0 Inner Join ODRF T1 On T0."DocEntry"=T1."DocEntry" 
      Left join OCPR T2 ON T2."CntctCode" = T1."CntctCode"
           where T1."DocEntry"= :list_of_cols_val_tab_del  and IFNULL(T2."E_MailL",'')='' and T1."CANCELED"='N' and T1."ObjType"='22';							
 							
      if :Cnt1>0 then	
	    error := -206;							
            error_message := 'Contact Person Email is empty. Please update email to contact person to add PO';							
      end if;							
 end if;
 --------------Start Date Is Mandatory---------
Cnt1 :=0;

IF :object_type = '171' AND (:transaction_type = 'A' or :transaction_type = 'U') THEN
Select count(*) into Cnt1 FROM OHEM T0
WHERE IFNULL(T0."startDate",'')=''  AND T0."empID" =:list_of_cols_val_tab_del;
if :Cnt1 >0 then
error := 3005;
error_message :='Please Enter Employee Date Of Hire' ;
end if;
end if;


------EMPLOYEE CONTRACT---------IS MANDATORY-------

Cnt1 :=0;

IF :object_type = '171' AND (:transaction_type = 'A' or :transaction_type = 'U') THEN
Select count(*) into Cnt1 FROM OHEM T0
WHERE IFNULL(T0."U_EmpType",'')=''  AND T0."empID" =:list_of_cols_val_tab_del;
if :Cnt1 >0 then
error := 3006;
error_message :='Please Select Employee Contract' ;
end if;
end if;

 ------Employee Category is mandatory -------

Cnt1 :=0;

IF :object_type = '171' AND (:transaction_type = 'A' or :transaction_type = 'U') THEN
Select count(*) into Cnt1 FROM OHEM T0
WHERE IFNULL(T0."U_Cat",'')=''  AND T0."empID" =:list_of_cols_val_tab_del;
if :Cnt1 >0 then
error := 3007;
error_message :='Please Select Employee Category White Collar Or Blue Collar' ;
end if;
end if;
 -------------Contact person is mandatory-------------
  Cnt1:=0;
							
   if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from DRF1 T0 Inner Join ODRF T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and IFNULL(T1."CntctCode",0) =0 and T1."CANCELED"='N' and T1."ObjType"='22';							
 							
      if :Cnt1>0 then	
	    error := -207;							
            error_message := 'Contact Person is mandatory to add PO';							
      end if;							
 end if; 
----------------------------------------------------Total diffrence PO  to GRPO  Item Wise ---------------------------------------------------------------------------------------
  
 if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T0."BaseType"= T2."BaseType" INNER JOIN OPOR T4 
	on  T4."DocEntry"= T2."DocEntry" AND T0."DocType"=T4."DocType" and T4."BaseType"= T2."BaseType" Where T0."DocEntry"= :list_of_cols_val_tab_del
	and  T1."LineTotal" > T2."LineTotal"   AND T0."DocType"='I' ;

	if :Cnt1 > 0 then
		error := 13301;
		Line:=0;  
		Select TOP 1 (T1."VisOrder"+1) into Line   from OPDN T0 inner join PDN1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T0."BaseType"= T2."BaseType" INNER JOIN OPOR T4 on 
		T4."DocEntry"= T2."DocEntry" AND T0."DocType"=T4."DocType" and T4."BaseType"= T2."BaseType" Where T0."DocEntry"= :list_of_cols_val_tab_del 
		and	 T1."LineTotal" > T2."LineTotal" AND T0."DocType"='I' ;
		
	    error_message :='Entred total in Line No '|| :Line ||' is Greater than Purchase Order Total';    
	                            
    end if;						
end if; 
---------Selected Leave Code ----------------------------
Cnt1=0;
IF :object_type = 'SBO_EMPSALUDO' AND (:transaction_type = 'A' or :transaction_type = 'U') THEN
	select Count(*)into Cnt1  from(
(Select distinct "Code",count("Code")as "ct"  From "@SBO_PREMPSALDET2" Where IFNULL("U_Pay",1)<>2 
and "Code"=:list_of_cols_val_tab_del
and "U_Code"  IN (SELECT T0."Code" FROM "@SBO_PRLEAVECODE"  T0 WHERE T0."U_Remarks" ='AL')  
 
group by "Code"order by "Code" asc) ) where "ct">1;

	
	if :Cnt1 > 0 then
		error := 1801;
		
		error_message := 'Please Select Different Leave code Because it is  added already with diffrent leave name ....' ;
	end if;
end if;

----------------------------A/P Invoice-------------------------------
/*
 Cnt1:=0;
							
   if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PCH1 T0 Inner Join OPCH T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"<>'20'

and T1."CANCELED"='N' and T1."DocType"='I';							
 							
      if :Cnt1>0 then	
	    error := -3024;							
            error_message := 'GRPO is mandatory to add AP Invoice';							
      end if;							
 end if;
 */
 -----
Cnt1:=0;
							
   if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PCH1 T0 Inner Join OPCH T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"='20'
           and T1."CardCode"<>(Select a."CardCode" from OPDN a inner join PDN1 b on a."DocEntry"=b."DocEntry"
           where b."DocEntry"=T0."BaseEntry" and b."LineNum"=T0."BaseLine" ) 

and T1."CANCELED"='N' and T1."DocType"='I';							
 							
      if :Cnt1>0 then	
	    error := -3025;							
            error_message := 'GRPO and AP Invoice Vendor should be same';							
      end if;							
 end if;
 -------
Cnt1:=0;
							
   if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PCH1 T0 Inner Join OPCH T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"='20' and T0."LineNum"=T0."BaseLine"
           and (T0."Quantity">T0."BaseOpnQty" or T0."Price"
           
           <>(Select b."Price" from  PDN1 b 
           where b."DocEntry"=T0."BaseEntry" and b."LineNum"=T0."LineNum"))

and T1."CANCELED"='N' and T1."DocType"='I';							
 							
      if :Cnt1>0 then	
	    error := -3026;							
            error_message := 'Quantity and Price should not exceed from GRPO';							
      end if;							
 end if;
 ----------------------------A/P Invoice-------------------------------------
-----------------------GRPO-----------------------------------
Cnt1:=0;
							
   if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PDN1 T0 Inner Join OPDN T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"<>'22'

and T1."CANCELED"='N' and T1."DocType"='I';							
 							
      if :Cnt1>0 then	
	    error := -3027;							
            error_message := 'PO is mandatory to add GRPO';							
      end if;							
 end if;
 -----
Cnt1:=0;
							
   if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PDN1 T0 Inner Join OPDN T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"='22'
           and T1."CardCode"<>(Select a."CardCode" from OPOR a inner join POR1 b on a."DocEntry"=b."DocEntry"
           where b."DocEntry"=T0."BaseEntry" and b."LineNum"=T0."BaseLine" ) 

and T1."CANCELED"='N' and T1."DocType"='I';							
 							
      if :Cnt1>0 then	
	    error := -3028;							
            error_message := 'PO and GRPO Vendor should be same';							
      end if;							
 end if;
 -------
Cnt1:=0;
							
   if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PDN1 T0 Inner Join OPDN T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"='22' and T0."LineNum"=T0."BaseLine"
           and (T0."Quantity">T0."BaseOpnQty" or T0."Price"
            <>(Select b."Price" from  POR1 b 
           where b."DocEntry"=T0."BaseEntry" and b."LineNum"=T0."LineNum"))

and T1."CANCELED"='N' and T1."DocType"='I';							
 							
      if :Cnt1>0 then	
	    error := -3026;							
            error_message := 'Quantity and Price should not exceed from PO';							
      end if;							
 end if;
 ------------------------GRPO----------------------------
------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------- 
--------------------------------Created by - Ajay / Purchase Order / 17022025 ---------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then

Select Count(*) into Cnt1 
from OPOR T1
 Left join POR1 T2 on T1."DocEntry" = T2."DocEntry"
 left join OPRQ T3 on T2."BaseEntry" = T3."DocEntry" and T2."BaseType" = T3."ObjType" 
WHERE T1."DocEntry"= :list_of_cols_val_tab_del and  
T1."DocDate" < T3."DocDate";
    
     if :Cnt1 > 0 then
error := 17022025;
error_message := 'DocDate is not allowed to be less than Base DocDate'  ;
end if;                        
end if;
---------------------------------------------------------------------------------------------------------------------------
--------------------------------Created by - Ajay / GRPO / 17022025 ---------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then

Select Count(*) into Cnt1 
from OPDN T1
 Left join PDN1 T2 on T1."DocEntry" = T2."DocEntry"
 left join OPOR T3 on T2."BaseEntry" = T3."DocEntry" and T2."BaseType" = T3."ObjType" 
WHERE T1."DocEntry"= :list_of_cols_val_tab_del and  
T1."DocDate" < T3."DocDate";
    
     if :Cnt1 > 0 then
error := 17022025;
error_message := 'DocDate is not allowed to be less than Base DocDate'  ;
end if;                        
end if;
---------------------------------------------------------------------------------------------------------------------------
--------------------------------Created by - Ajay / A/P Invoice / 17022025 ---------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then

Select Count(*) into Cnt1 
from OPCH T1
 Left join PCH1 T2 on T1."DocEntry" = T2."DocEntry"
 left join OPDN T3 on T2."BaseEntry" = T3."DocEntry" and T2."BaseType" = T3."ObjType" 
WHERE T1."DocEntry"= :list_of_cols_val_tab_del and  
T1."DocDate" < T3."DocDate";
    
     if :Cnt1 > 0 then
error := 17022025;
error_message := 'DocDate is not allowed to be less than Base DocDate'  ;
end if;                        
end if;
---------------------------------------------------------------------------------------------------------------------------
--------------------------------Created by - Ajay / A/P Invoice / 21022025 ---------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then

Select Count(*) into Cnt1 
from PCH1 T1
 WHERE T1."DocEntry"= :list_of_cols_val_tab_del and  
T1."BaseEntry" is NULL and T1."AgrNo" is NULL;

     if :Cnt1 > 0 then
error := 21022025;
error_message := 'Direct A/P Invoice Entry Prohibited'  ;
end if;                        
end if;
---------------------------------------------------------------------------------------------------------------------------
--------------------------------Created by - Ajay / A/P Invoice - Blanket Agreement / 27022025 ---------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then

Select Count(*) into Cnt1 
From OPCH T0
Left join PCH1 T1 On T0."DocEntry" = T1."DocEntry"
--------------------------------------------------
Left join(

Select 
T0."StartDate"
,T0."EndDate"
,T0."BpCode"
,T1."ItemCode"
,T1."PlanQty" 
,ifnull(T2."Quantity",0) as "Quantity"
,ifnull(T1."PlanQty",0)-Ifnull(T2."Quantity",0) as "OpenQty"
from OOAT T0
--------------------------------------------------
Left join OAT1 T1 On T0."AbsID" = T1."AgrNo"
--------------------------------------------------
Left join (
Select T0."CardCode",T1."ItemCode",Sum(T1."Quantity") "Quantity" from OPCH T0
Left Join PCH1 T1 on T0."DocEntry" = T1."DocEntry"

Left join (Select T0."StartDate",T0."EndDate",T0."BpCode",T1."ItemCode" from OOAT T0
Left join OAT1 T1 On T0."AbsID" = T1."AgrNo"
Where T0."Status" = 'A' ) T2 on T0."CardCode" = T2."BpCode" and T1."ItemCode" = T2."ItemCode"

Where T1."DocDate" between T2."StartDate" and T2."EndDate"
Group BY T0."CardCode",T1."ItemCode"
) T2 on T0."BpCode" = T2."CardCode" and T1."ItemCode" = T2."ItemCode"
--------------------------------------------------
Where T0."Status" = 'A' 

)T2 on T2."BpCode" = T0."CardCode" and T2."ItemCode" = T1."ItemCode"
--------------------------------------------------

Where T0."DocEntry" = :list_of_cols_val_tab_del
and T1."Quantity" > T2."OpenQty";
    
     if :Cnt1 > 0 then
error := 27022025;
error_message := 'A/P Invoice Quantity Exceeds Blanket Agreement Limit'  ;
end if;                        
end if;
---------------------------------------------------------------------------------------------------------------------------
-- Select the return values
select :error, :error_message FROM dummy;

end;