ALTER PROCEDURE SBO_SP_TransactionNotification
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
PRICE DOUBLE;
Cnt2 int;
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
and IFNULL (T1."Country",'') ='UAE' and "CardType"='S'
AND LENGTH (T1."IBAN") <> '23' 
and T0."CardType" ='S';
 if :Cnt1 > 0 then 
  error := 114;
  error_message := 'Please check IBAN No. properly. IBAN LENGTH should be 23' ;
 end if;							
end if;

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
-------------------------------
-----Email Validation  must not contain spaces-------------

Cnt1 := 0;							
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN							

    SELECT COUNT(*) 
    INTO Cnt1 
    FROM OCRD T0 
    WHERE T0."CardCode" = :list_of_cols_val_tab_del 
      AND T0."E_Mail" NOT LIKE '%_@__%.__%'; -- Check for Email Format

    IF Cnt1 > 0 THEN							
        error := 20250624;							
        error_message := 'Wrong Email Address : Please enter valid email ID. - Email Format';							
    END IF;							

END IF;
------------------------------------
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

--------------------------------------


-----Email Address Validation -------------

Cnt1 := 0;							
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN							

    SELECT COUNT(*) 
    INTO Cnt1 
    FROM OCRD T0 
    WHERE T0."CardCode" = :list_of_cols_val_tab_del 
      AND T0."E_Mail" NOT LIKE '%_@__%.__%'; -- Email Addres format validation

    IF Cnt1 > 0 THEN							
        error := 20250624;							
        error_message := 'Invalid Email Address - Please enter a valid email ID.';							
    END IF;							

END IF;
---------------------------------------------------------------------------------------------------------------------------
/*
Cnt1:=0;                                             
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then                               
Select Count(*) into Cnt1 from "OPOR" T
where (IFNULL(T."U_MainContr",'')='' or T."U_MainContr" is null) and  T."DocEntry"= :list_of_cols_val_tab_del    ;
if :Cnt1>0 then                                      
error := (-5);                                       
error_message := 'Invalid Contract Type';                                    
end if;                                        
end if;
//Disabled by Ashfaaqh
*/
-------------------------------------------------------------------------------------------------------------------------------
Cnt1:=0;                                             
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then                               
Select Count(*) into Cnt1 from "OPOR" T
where (IFNULL(T."U_TYPE",'')='' or T."U_TYPE" is null) and  T."DocEntry"= :list_of_cols_val_tab_del    ;
if :Cnt1>0 then                                      
error := (-4);                                       
error_message := 'Enter Type Field';                                    
end if;                                        
end if;
----------------------------------------------------------------------------------------------------------------------------
Cnt1:=0;                                             
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then                               
Select Count(*) into Cnt1 from "OPOR" T
where (IFNULL(T."U_CATEGORY",'')='' or T."U_CATEGORY" is null) and  T."DocEntry"= :list_of_cols_val_tab_del    ;
if :Cnt1>0 then                                      
error := (-3);                                       
error_message := 'Invalid Category Type';                                   
end if;                                        
end if;
------------------------------------------------------------------------------------------------------------------------------------
Cnt1:=0;                                             
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then                               
Select Count(*) into Cnt1 from "OPOR" T
where (IFNULL(T."U_SQTYPE",'')='' or T."U_SQTYPE" is null) and  T."DocEntry"= :list_of_cols_val_tab_del    ;
if :Cnt1>0 then                                      
/*error := (-1);                                       
error_message := 'Invalid Department Field'; */                                   
end if;                                        
end if;
-------------------------------------------------------------------------------------------------------------------------------------
Cnt1:=0;                                             
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then                               
Select Count(*) into Cnt1 from "OPOR" T
where (IFNULL(T."U_Division",'')='' or T."U_Division" is null) and  T."DocEntry"= :list_of_cols_val_tab_del    ;
if :Cnt1>0 then                                      
error := (-2);                                       
error_message := 'Invalid Division  Field';                                    
end if;                                        
end if;
------------------------------------------------------------------------------------------------------------------------------------------
Cnt1:=0;                                             
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then                               
Select Count(*) into Cnt1 from "OPDN" T
where (IFNULL(T."U_DEPARTMENTT",'')='' or T."U_DEPARTMENTT" is null) and  T."DocEntry"= :list_of_cols_val_tab_del    ;
if :Cnt1>0 then                                      
error := (-2);                                       
error_message := 'Invalid Department  Field';                                    
end if;                                        
end if;





----------------------------BP Project should No Empty-----------------------------------------------
/*Cnt1:=0;							
   if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then	

Select Count(*) into Cnt1 from OPCH T0 Where T0."DocEntry" = :list_of_cols_val_tab_del and 
      T0."Project" IS NULL OR T0."Project" = '' ;

if :Cnt1>0 then							
            error := 18;							
            error_message := 'BP Project can not be blank in A/P Invoice';							
      end if;							
 end if;*/
/*-------------------------Diffrent Items not allowed in Linked LPO with Blanket Aggrement--------------

Cnt1:=0;							
   if :object_type = '22' and (:transaction_type ='A'  OR :transaction_type ='U') then	
 Select Count(*) into Cnt1 from OPOR T0 
      Where T0."DocEntry" =:list_of_cols_val_tab_del and (Select Count(T."AgrNo") from POR1 T where T."DocEntry"=T0."DocEntry"
      and IFNULL(T."AgrNo",0)<>0)>0 and (Select Count(T."AgrNo") from POR1 T where T."DocEntry"=T0."DocEntry"
      and IFNULL(T."AgrNo",0)<>0)<>(Select Count(T."VisOrder") from POR1 T where T."DocEntry"=T0."DocEntry");							
      if :Cnt1>0 then							
            error := 22;							
            error_message := 'Diffrent Items not allowed in Linked LPO with Blanket Aggrement';							
      end if;							
 end if;*/
 /*
------------------------Enter Bank account details----------------------------------------------------
Cnt1:=0;							
   if :object_type='2' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OCRD T0 Where T0."CardCode" = :list_of_cols_val_tab_del and 
      IFNULL(T0."DflAccount",'')='' AND "CardType"='S';						
 							
      if :Cnt1>0 then							
            error := 2;							
            error_message := 'PLease enter Bank account details';							
      end if;							
 end if;
 /*
 ------------------------Enter SQ ref no----------------------------------------------------
Cnt1:=0;							
   if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OPRQ T0 Where T0."DocEntry" = :list_of_cols_val_tab_del and 
      IFNULL(T0."U_Docref",'')='' ;						
 							
      if :Cnt1>0 then							
            error := 445;							
            error_message := 'PLease enter SQ Ref no';							
      end if;							
 end if;
---------------------------------------------------------------------------------------------------------
 Cnt1:=0;							
   if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from ODRF T0 Where T0."DocEntry" = :list_of_cols_val_tab_del and 
      IFNULL(T0."U_Docref",'')=''   and T0."ObjType"='1470000113';						
 							
      if :Cnt1>0 then							
            error := 4458;							
            error_message := 'PLease enter SQ Ref no';							
      end if;							
 end if;
 */
  */
 
------------------------Enter Bank details and IBAN number
Cnt1:=0;							
   if :object_type='2' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OCRD T0 Where T0."CardCode" = :list_of_cols_val_tab_del and 
      IFNULL(T0."DflIBAN",'')='' AND "CardType"='S';						
 							
      if :Cnt1>0 then							
            error := 2;							
            error_message := 'PLease enter Bank details and IBAN number';							
      end if;							
 end if;
  
----------------------Enter Supplier name in User Defined Field-------------------------------------------
Cnt1:=0;							
   if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OPDN T0 Where T0."DocEntry" = :list_of_cols_val_tab_del and  T0."CardCode" = 'V0604' and 
      IFNULL(T0."U_Supplier",'')='' ;						
 							
      if :Cnt1>0 then							
            error := 20;							
            error_message := 'Please enter supplier field when using vendor "V0604" in UDF for your cash purchase. Supplier:';							
      end if;							
 end if;
---------------------Enter Invoice no in User Defined Field-----------------------------------------
Cnt1:=0;							
   if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OPDN T0 Where T0."DocEntry" = :list_of_cols_val_tab_del and  T0."CardCode" = 'V0604' and 
      IFNULL(T0."U_Invoice_no",'')='' ;						
 							
      if :Cnt1>0 then							
            error := 20;							
            error_message := 'Please Enter Invoice no in User Defined Field';							
      end if;							
 end if;
-------------------------Please Enter T/R Expire Date----------------------------------------------
Cnt1:=0;							
   if :object_type='2' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OCRD T0 Where T0."CardCode" = :list_of_cols_val_tab_del and 
      IFNULL(T0."U_TrdLicExp",'')='' AND "CardType"='S';						
 							
      if :Cnt1>0 then							
            error := 2;							
            error_message := 'Please Enter T/R Expire Date';							
      end if;							
 end if;
-----------------------TRN No. cannot be blank-----------------------------------------------------
Cnt1:=0;							
   if :object_type='2' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OCRD a inner join CRD1 b on a."CardCode"=b."CardCode" where
      (a."LicTradNum" is null or a."LicTradNum"='') and b."Country" in('UAE','AE') and 
      (b."AdresType"='S' or b."AdresType"='B') and a."CardCode"=:list_of_cols_val_tab_del  AND "CardType"='S';					
 							
      if :Cnt1>0 then							
            error := 2003;							
            error_message := 'TRN No. cannot be blank';							
      end if;							
 end if;
----------------------------------TRN No. is missing for the Business Partner - INV---------------
Cnt1:=0;							
   if :object_type='13' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OINV t1 left join INV12 t2 on T1."DocEntry"=T2."DocEntry" where
      (t1."LicTradNum" is null or t1."LicTradNum"='') and t1."DocEntry" =:list_of_cols_val_tab_del;					
 							
      if :Cnt1>0 then							
            error := 2003;							
            error_message := 'TRN No. is missing for the Business Partner';							
      end if;
    end if;
-------------------------TRN No. is missing for the Business Partner - RIN-------------------------
Cnt1:=0;							
   if :object_type='14' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from ORIN t1 left join RIN12 t2 on T1."DocEntry"=T2."DocEntry" where
      (t1."LicTradNum" is null or t1."LicTradNum"='') and t1."DocEntry" =:list_of_cols_val_tab_del;					
 							
      if :Cnt1>0 then							
            error := 2003;							
            error_message := 'TRN No. is missing for the Business Partner';							
      end if;							
 end if;
-------------------------TRN No. is missing for the Business Partner-PCH--------------------------
Cnt1:=0;							
   if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from OPCH t1 left join PCH12 t2 on T1."DocEntry"=T2."DocEntry" where
      (t1."LicTradNum" is null or t1."LicTradNum"='') and t1."DocEntry" =:list_of_cols_val_tab_del;					
 							
      if :Cnt1>0 then							
            error := 2003;							
            error_message := 'TRN No. is missing for the Business Partner';							
      end if;							
 end if;
-------------------TRN No. is missing for the Business Partner-RPC-------------------------------
Cnt1:=0;							
   if :object_type='19' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from ORPC t1 left join RPC12 t2 on T1."DocEntry"=T2."DocEntry" where
      (t1."LicTradNum" is null or t1."LicTradNum"='') and t1."DocEntry" =:list_of_cols_val_tab_del;					
 							
      if :Cnt1>0 then							
            error := 2003;							
            error_message := 'TRN No. is missing for the Business Partner';							
      end if;							
 end if;
--------------------TRN No. is missing for the Business Partner - DPO--------------------------
Cnt1:=0;							
   if :object_type='204' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from ODPO t1 left join DPO12 t2 on T1."DocEntry"=T2."DocEntry" where
      (t1."LicTradNum" is null or t1."LicTradNum"='') and t1."DocEntry" =:list_of_cols_val_tab_del;					
 							
      if :Cnt1>0 then							
            error := 2003;							
            error_message := 'TRN No. is missing for the Business Partner';							
      end if;							
 end if;
---------------------------TRN No. is missing for the Business Partner-------------------------
Cnt1:=0;							
   if :object_type='203' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from ODPI t1 left join DPI12 t2 on T1."DocEntry"=T2."DocEntry" where
      (t1."LicTradNum" is null or t1."LicTradNum"='') and t1."DocEntry" =:list_of_cols_val_tab_del;					
 							
      if :Cnt1>0 then							
            error := 2003;							
            error_message := 'TRN No. is missing for the Business Partner';							
      end if;							
 end if;
----------------------------Only Non Contractual item can be selected-------------------------------------
Cnt1:=0;							
   if :object_type IN('112', '1470000113') and (:transaction_type ='A'  OR :transaction_type ='U') then	
   
   if :object_type ='112' then
   	
      Select Count(*) into Cnt1 from ODRF T0 
      INNER JOIN DRF1 T1 on T0."DocEntry"=T1."DocEntry"
      LEFT OUTER JOIN OITM T2 on T1."ItemCode"=T2."ItemCode" 
      Where T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_ContType"='2' and T2."U_ConItem" <>'Non Contractual'
      and T0."ObjType"='1470000113';					
 Else
      Select Count(*) into Cnt1 from OPRQ T0 
      INNER JOIN PRQ1 T1 on T0."DocEntry"=T1."DocEntry"
      LEFT OUTER JOIN OITM T2 on T1."ItemCode"=T2."ItemCode" 
      Where T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_ContType"='2' and T2."U_ConItem" <>'Non Contractual';
 END IF;    						
      if :Cnt1>0 then							
            error := 1470000113;							
            error_message := 'Only Non Contractual item can be selected';							
      end if;							
 end if;
----------------------------------Only Contractual item can be selected--------------------------------------------
Cnt1:=0;							
   if :object_type IN('112', '1470000113') and (:transaction_type ='A'  OR :transaction_type ='U') then	
   
   if :object_type ='112' then
      Select Count(*) into Cnt1 from ODRF T0 
      INNER JOIN DRF1 T1 on T0."DocEntry"=T1."DocEntry"
      Where T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_ContType"='1' and T1."ItemCode" Not In (Select "ItemCode" from 
      OAT1 where "LineStatus"='O') and T0."ObjType"='1470000113';					
 Else
      Select Count(*) into Cnt1 from OPRQ T0 
      INNER JOIN PRQ1 T1 on T0."DocEntry"=T1."DocEntry"
      Where T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_ContType"='1' and T1."ItemCode" Not In (Select "ItemCode" from 
      OAT1 where "LineStatus"='O');
 END IF;    						
      if :Cnt1>0 then							
            error := 1470000113;							
            error_message := 'Only Contractual item can be selected';							
      end if;							
 end if;
---------------------------------Only Non Contractual item can be selected-PO--------------------------
Cnt1:=0;							
   if :object_type IN('112', '22') and (:transaction_type ='A'  OR :transaction_type ='U') then	
   
   if :object_type ='112' then
   	
      Select Count(*) into Cnt1 from ODRF T0 
      INNER JOIN DRF1 T1 on T0."DocEntry"=T1."DocEntry"
      LEFT OUTER JOIN OITM T2 on T1."ItemCode"=T2."ItemCode" 
      Where T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_ContType"='2' and T2."U_ConItem" <>'Non Contractual'
      and T0."ObjType"='22';					
 Else
      Select Count(*) into Cnt1 from OPOR T0 
      INNER JOIN POR1 T1 on T0."DocEntry"=T1."DocEntry"
      LEFT OUTER JOIN OITM T2 on T1."ItemCode"=T2."ItemCode" 
      Where T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_ContType"='2' and T2."U_ConItem" <>'Non Contractual';
 END IF;    						
      if :Cnt1>0 then							
            error := 22;							
            error_message := 'Only Non Contractual item can be selected';							
      end if;							
 end if;
-----------------------Only Contractual item can be selected-PO---------------------------------------
Cnt1:=0;							
   if :object_type IN('112', '22') and (:transaction_type ='A'  OR :transaction_type ='U') then	
   
   if :object_type ='112' then
      Select Count(*) into Cnt1 from ODRF T0 
      INNER JOIN DRF1 T1 on T0."DocEntry"=T1."DocEntry"
      Where T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_ContType"='1' and T1."ItemCode" Not In (Select "ItemCode" from 
      OAT1 where "LineStatus"='O') and T0."ObjType"='22';					
 Else
      Select Count(*) into Cnt1 from OPOR T0 
      INNER JOIN POR1 T1 on T0."DocEntry"=T1."DocEntry"
      Where T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_ContType"='1' and T1."ItemCode" Not In (Select "ItemCode" from 
      OAT1 where "LineStatus"='O');
 END IF;    						
      if :Cnt1>0 then							
            error := 22;							
            error_message := 'Only Contractual item can be selected';							
      end if;							
 end if;
 -----------------------------------You can not create GRPO without LPO--------------------------------------
Cnt1:=0;
							
   if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PDN1 T0 Inner Join OPDN T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"<>'22' and T1."CANCELED"='N' and T1."CardCode"<>'V0604' and T1."CardCode"<>'V0739' and 
           T1."CardCode"<>'V0740'   and T1."CardCode"<>'V1026' and T1."CardCode"<>'V0630'
           and T1."CardCode"<>'V0856' and T1."CardCode"<>'V0855' and T1."CardCode"<>'V0854' and T1."CardCode"<>'V0853' and T1."CardCode"<>'V0852' and T1."CardCode"<>'V0898' and T1."CardCode"<>'V0851' and T1."CardCode"<>'V1025';							
 							
      if :Cnt1>0 then	
	    error := -202;							
            error_message := 'You can not create GRPO without LPO';							
      end if;							
 end if;
/*
 -----------------You can not create LPO without PR---------------------------------------
Cnt1:=0;
							
   if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from POR1 T0 Inner Join OPOR T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"<>'1470000113' and T1."CANCELED"='N';							
 							
      if :Cnt1>0 then	
	    error := -203;							
            error_message := 'You can not create LPO without PR';							
      end if;							
 end if;
  */
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

--------------------------------

     -----------------There is already another LPO Under approval with same PR---------------------------------------
Cnt1:=0;
							
   if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
    /*  Select Count(*) into Cnt1 from POR1 T0 Inner Join OPOR T1 On T0."DocEntry"=T1."DocEntry" 
            WHERE T1."CANCELED"='N' GROUP BY T0."BaseType" HAVING COUNT(*)>1;							
 							*/
 		  /*Select Count(*) into Cnt1 from DRF1 T0 Inner Join ODRF T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."CANCELED"='N' and T1."ObjType"='22' GROUP BY T0."BaseDocNum" HAVING COUNT(*)>1;							
 			
 			*/
 			
 	SELECT Count(*)into Cnt1 FROM ODRF T0 
 		WHERE T0."ObjType" = '22' 
 		and T0."DocType" = 'I'
		and T0."CardCode" = (Select T3."CardCode"  from ODRF T3 Where T3."DocEntry" =:list_of_cols_val_tab_del and T3."ObjType" = '22')
		and T0."DocTotal" = (Select T2."DocTotal"  from ODRF T2 Where T2."DocEntry" =:list_of_cols_val_tab_del and T2."ObjType" = '22')
 		and T0."WddStatus" IN ('W', 'Y')and T0."DocDate" > '1.1.2025';
     
      if :Cnt1>1 then	
	    error := -20390;							
            error_message := 'There is already another LPO Under approval with same PR';							
      end if;							
 end if;
 

----------------------------------------------------------------------------------------------------------------

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


 
 --------------------Employee Project is mandatory-------------------

Cnt1 :=0;

IF :object_type = '171' AND (:transaction_type = 'A' or :transaction_type = 'U') THEN
Select count(*) into Cnt1 FROM OHEM T0
WHERE IFNULL(T0."U_CCODE",'')=''  AND T0."empID" =:list_of_cols_val_tab_del;
if :Cnt1 >0 then
error := 4000;
error_message :='Please Select Project to proceed further' ;
end if;
end if;
 
 
  --------------------Employee Costcenter is mandatory-------------------

/*Cnt1 :=0;

IF :object_type = '171' AND (:transaction_type = 'A' or :transaction_type = 'U') THEN
Select count(*) into Cnt1 FROM OHEM T0
WHERE IFNULL(T0."CostCenter",'')=''  AND T0."empID" =:list_of_cols_val_tab_del;
if :Cnt1 >0 then
error := 4001;
error_message :='Please Select Costcenter to proceed further' ;
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
------------------------------------------------------------------------------------------------------------------------/
/*
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')=''  and T1."ObjType"='23';    
--(Select IFNULL(SUM("U_QTY"),0) FROM "@TNX_ASN1" Where "U_PUOREF"=T1."U_PUOREF" and "U_ITCODE"=T1."U_ITCODE")
--->(Select SUM(B."Quantity") FROM "OPOR" A INNER JOIN "POR1" B ON A."DocEntry"=B."DocEntry" Where A."DocNum"=TO_INT(T1."U_PUOREF") 
--and B."ItemCode"=T1."U_ITCODE");                                
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Contract'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')=''  and T1."ObjType"='1470000113';    
--(Select IFNULL(SUM("U_QTY"),0) FROM "@TNX_ASN1" Where "U_PUOREF"=T1."U_PUOREF" and "U_ITCODE"=T1."U_ITCODE")
--->(Select SUM(B."Quantity") FROM "OPOR" A INNER JOIN "POR1" B ON A."DocEntry"=B."DocEntry" Where A."DocNum"=TO_INT(T1."U_PUOREF") 
--and B."ItemCode"=T1."U_ITCODE");                                
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Purchase Request  Cannot be added with out Contract'  ;
end if;                        
end if; 
--------------------------------------------------------------------------------------
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from PRQ1 T0  INNER JOIN OPRQ T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')='' ;--- and T1."ObjType"='1470000113';    
--(Select IFNULL(SUM("U_QTY"),0) FROM "@TNX_ASN1" Where "U_PUOREF"=T1."U_PUOREF" and "U_ITCODE"=T1."U_ITCODE")
--->(Select SUM(B."Quantity") FROM "OPOR" A INNER JOIN "POR1" B ON A."DocEntry"=B."DocEntry" Where A."DocNum"=TO_INT(T1."U_PUOREF") 
--and B."ItemCode"=T1."U_ITCODE");                                
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Purchase Request Cannot be added with out Contract'  ;
end if;                        
end if;

 

---------------------------------------------------------------------------------------------
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from QUT1 T0  INNER JOIN OQUT T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')=''  and T1."ObjType"='23';    
--(Select IFNULL(SUM("U_QTY"),0) FROM "@TNX_ASN1" Where "U_PUOREF"=T1."U_PUOREF" and "U_ITCODE"=T1."U_ITCODE")
--->(Select SUM(B."Quantity") FROM "OPOR" A INNER JOIN "POR1" B ON A."DocEntry"=B."DocEntry" Where A."DocNum"=TO_INT(T1."U_PUOREF") 
--and B."ItemCode"=T1."U_ITCODE");                                
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Contract'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from PRQ1 T0  INNER JOIN OPRQ T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')='' ;--- and T1."ObjType"='1470000113';    
--(Select IFNULL(SUM("U_QTY"),0) FROM "@TNX_ASN1" Where "U_PUOREF"=T1."U_PUOREF" and "U_ITCODE"=T1."U_ITCODE")
--->(Select SUM(B."Quantity") FROM "OPOR" A INNER JOIN "POR1" B ON A."DocEntry"=B."DocEntry" Where A."DocNum"=TO_INT(T1."U_PUOREF") 
--and B."ItemCode"=T1."U_ITCODE");                                
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Purchase Request Cannot be added with out Contract'  ;
end if;                        
end if;

 

---------------------------------------------------------------------------------------------
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')=''  and T1."ObjType"='23';    
--(Select IFNULL(SUM("U_QTY"),0) FROM "@TNX_ASN1" Where "U_PUOREF"=T1."U_PUOREF" and "U_ITCODE"=T1."U_ITCODE")
--->(Select SUM(B."Quantity") FROM "OPOR" A INNER JOIN "POR1" B ON A."DocEntry"=B."DocEntry" Where A."DocNum"=TO_INT(T1."U_PUOREF") 
--and B."ItemCode"=T1."U_ITCODE");                                
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Contract'  ;
end if;                        
end if; 
*/
------------------------------------------------------------------------------------------------------------------------
---///

if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from PRQ1 T0  INNER JOIN OPRQ T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."Project",'')='' ;--- and T1."ObjType"='1470000113';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Purchase Request Cannot be added with out Project'  ;
end if;                        
end if;

 -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---///

if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from PDN1 T0  INNER JOIN OPDN T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."Project",'')='' ;--- and T1."ObjType"='1470000113';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'GRN  Cannot be added with out Project'  ;
end if;                        
end if;

 -----------------------------------------------------------
-------------------------------Contract mandatory in SQ DRAFT--------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

   Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
   WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
  and  ifnull(T0."Project",'')=''  and  T1."ObjType"='1470000113'; 
 								
 	if :Cnt1 > 0 then
      error := 1230;
       error_message := 'Purchase Request Cannot be added with out project'  ;
       end if;						
    end if; 



---------------------------------------------------------------------------------------------
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from QUT1 T0  INNER JOIN OQUT T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."Project",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Project'  ;
end if;                        
end if; 
------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from PDN1 T0  INNER JOIN OPDN T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."Project",'')=''  and T1."ObjType"='20';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'GRN Cannot be added with out Project'  ;
end if;                        
end if; 
------------------------------------------------------------------------------------------------------------------

-------------------------------Contract mandatory in SQ DRAFT--------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

   Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
   WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
   and  ifnull(T0."Project",'')=''  and T1."ObjType"='23';	
 								
 	if :Cnt1 > 0 then
      error := 1230;
       error_message := 'Sales Quotation Cannot be added with out Project'  ;
       end if;						
    end if; 
-----------------------------------Contract mandatory in PR DRAFT-----------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-------------------------------Contract mandatory in SQ DRAFT--------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

   Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
   WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
   and  ifnull(T0."OcrCode",'')=''  and T1."ObjType"='23';	
 								
 	if :Cnt1 > 0 then
      error := 1230;
       error_message := 'Sales Quotation Cannot be added with out Contract'  ;
       end if;						
    end if; 
-----------------------------------Contract mandatory in PR DRAFT-----------------------------------------------

if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')=''  and T1."ObjType"='1470000113';	
 	if :Cnt1 > 0 then
		error := 1235;
		error_message := 'Purchase Request  Cannot be added with out Contract'  ;
	end if;						
end if; 
----------------------------------------Contract mandatory in PR----------------------------------------------
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from PRQ1 T0  INNER JOIN OPRQ T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')='' ;--- and T1."ObjType"='1470000113';	
 if :Cnt1 > 0 then
	error := 1233;
	error_message := 'Purchase Request Cannot be added with out Contract'  ;
end if;						
end if; 

------------------------------------------Contract mandatory in SQ ---------------------------------------------------
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from QUT1 T0  INNER JOIN OQUT T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."OcrCode",'')=''  and T1."ObjType"='23';	
  	if :Cnt1 > 0 then
		error := 1232;
		error_message := 'Sales Quotation Cannot be added with out Contract'  ;
   end if;						
end if; 
----\\\\\
   -----------------------------------You can not create AP INVOICE without GRPO--------------------------------------

Cnt1:=0;
							
   if :object_type='18' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
      Select Count(*) into Cnt1 from PCH1 T0 Inner Join 
      OPCH T1 On T0."DocEntry"=T1."DocEntry" INNER JOIN OCRD T2 On 
      T2."CardCode"=T1."CardCode"
           where T1."DocEntry"= :list_of_cols_val_tab_del  and T0."BaseType"<>'20' 
           and T1."CANCELED"='N' and T2."GroupCode"<>'107' and T1."DocType"='I';							
 							
      if :Cnt1>0 then	
	    error := -210;							
            error_message := 'You can not create AP INVOICE without GRPO';							
      end if;							
 end if;
 
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------MANOHAR ADDED 
-----------------------------------------------Price diffrence SQ to SO SERVICE--------------------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='17' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from ORDR T0 inner join RDR1 T1 on T0."DocEntry"= T1."DocEntry" 
  INNER JOIN QUT1 T2   on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType"
  INNER JOIN OQUT T4 on  T4."DocEntry"= T2."DocEntry"
  Where  T0."DocEntry"= :list_of_cols_val_tab_del 
  --and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) 
 AND T1."LineTotal" > T2."LineTotal" 
  AND T0."CANCELED"='N' AND T0."DocType"='S' ;
  
 --Cnt1=1;
	if :Cnt1 > 0 then
		error := 12305;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from ORDR T0 inner join RDR1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN QUT1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T1."BaseType"= T2."ObjType"
		INNER JOIN OQUT T4 on  T4."DocEntry"= T2."DocEntry" 
	    Where T0."DocEntry"= :list_of_cols_val_tab_del 
	    --and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) 
AND T1."LineTotal" > T2."LineTotal" 
        AND T0."CANCELED"='N' AND T0."DocType"='S' ;
	 
	      error_message :='Entred Total in Line No '|| :Line ||' is Greater than Sales Quotation Price';                            
	end if;						
end if; 

-------------------------------------------------Price diffrence SQ to SO in DRAFT SERVICE-----------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType"
   INNER JOIN OQUT T4  on  T4."DocEntry"= T2."DocEntry"
 Where  T0."DocEntry"= :list_of_cols_val_tab_del 
 AND T1."LineTotal" > T2."LineTotal" 
 ---and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )  
 and T1."ObjType"='17' AND T0."DocType"='S' ;
	if :Cnt1 > 0 then
		error := 12307;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN QUT1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T1."BaseType"= T2."ObjType"
		INNER JOIN OQUT T4 on  T4."DocEntry"= T2."DocEntry" 
	    Where T0."DocEntry"= :list_of_cols_val_tab_del
	    --and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )
AND T1."LineTotal" > T2."LineTotal" 
	       and T1."ObjType"='17' AND T0."DocType"='S';
	 
	      error_message :='Entred Price in Line No '|| :Line ||' is Greater than Sales Quotation Price';                            
	end if;						
end if; 
---------------------------------------------QUANTITY diffrence SQ to SO SERVICE---------------------------------------------------------------------------
Cnt1:=0;           
if :object_type='17' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ORDR T0 inner join RDR1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"  and T1."BaseType"= T2."ObjType"
	 INNER JOIN 	OQUT T4 on  T4."DocEntry"= T2."DocEntry"  Where 
	T0."DocEntry"= :list_of_cols_val_tab_del and T1."U_Quantity" > T2."U_Quantity" AND T0."DocType"='S' ;
 
   if :Cnt1 > 0 then
	 error := 12306;
	 Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from ORDR T0 inner join RDR1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."BaseType" INNER JOIN OQUT T4 on  
		T4."DocEntry"= T2."DocEntry" AND T0."DocType"=T4."DocType" and T4."BaseType"= T2."BaseType" Where T0."DocEntry"= :list_of_cols_val_tab_del
		and	T1."U_Quantity" > T2."U_Quantity" AND T0."DocType"='S';

      error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Sales Quotation quantity';                            
end if;						
end if; 
------------------------------------------------QUANTITY diffrence SQ to SO Draft SERVICE-------------------------------------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"  and T1."BaseType"= T2."ObjType" INNER JOIN OQUT T4
  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del and T1."U_Quantity" > T2."U_Quantity"  and T1."ObjType"='17' AND T0."DocType"='S' ;
	if :Cnt1 > 0 then
		error := 12303;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN QUT1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType"
		INNER JOIN OQUT T4 on  T4."DocEntry"= T2."DocEntry" 
	    Where T0."DocEntry"= :list_of_cols_val_tab_del and   T1."U_Quantity" > T2."U_Quantity" and T1."ObjType"='17' AND T0."DocType"='S';
	 
	      error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Sales Quotation Price';                            
	end if;						
end if; 
-------------------------------------------------------QUANTITY diffrence SQ to SO Item Wise DRAFT-------------------------------------------------------------------
Cnt1:=0; 

          
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType"
	INNER JOIN OQUT T4 
	on  T4."DocEntry"= T2."DocEntry" Where T0."DocEntry"= :list_of_cols_val_tab_del
	and T1."Quantity" > T2."Quantity" AND T0."DocType"='I'   and T1."ObjType"='17' ;

	if :Cnt1 > 0 then
		error := 123072;
		Line:=0;  
		Select TOP 1 (T1."VisOrder"+1) into Line   from ODRF T0 inner join DRF1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OQUT T4 on 
		T4."DocEntry"= T2."DocEntry" Where T0."DocEntry"= :list_of_cols_val_tab_del 
		and	T1."Quantity" > T2."Quantity" AND T0."DocType"='I'  and T1."ObjType"='17' ;
		
	    error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Sales Quotation quantity';    
	                            
    end if;						
end if; 
----------------------------------------------------Price diffrence SQ to SO Item Wise ---------------------------------------------------------------------------------------
  
if :object_type='17' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ORDR T0 inner join RDR1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"  and T1."BaseType"= T2."ObjType" INNER JOIN OQUT T4 
	on  T4."DocEntry"= T2."DocEntry" Where T0."DocEntry"= :list_of_cols_val_tab_del
	 and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )  AND T0."DocType"='I' ;

	if :Cnt1 > 0 then
		error := 12301;
		Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from ORDR T0 inner join RDR1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OQUT T4 on 
		T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del 
		 and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) AND T0."DocType"='I' ;
		
	    error_message :='Entred total in Line No '|| :Line ||' is Greater than Sales Quotation quantity';    
	                            
    end if;						
end if; 
---------------------------------------------------------Price diffrence SQ to SO Item Wise DRAFT----------------------------------------------------------------------------------------
Cnt1:=0; 

          
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OQUT T4 
	on  T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del
    and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) AND T0."DocType"='I'   and T1."ObjType"='17' ;

	if :Cnt1 > 0 then
		error := 12308;
		Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from ODRF T0 inner join DRF1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN QUT1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OQUT T4 on 
		T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del 
		 and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) AND T0."DocType"='I'  and T1."ObjType"='17' ;
		
	    error_message :='Entred Total in Line No '|| :Line ||' is Greater than Sales Quotation quantity';    
	                            
    end if;						
end if; 
----------------------------------------------------- PR TO PO---------------------------------------------------------------------------------------------------
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------------------Price diffrence PR  to PO SERVICE--------------------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from OPOR T0 inner join POR1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4
  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del 
  --and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )
AND T1."LineTotal" > T2."LineTotal" 
    AND T0."DocType"='S' ;
	if :Cnt1 > 0 then
		error := 13305;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from OPOR T0 inner join POR1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN PRQ1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T1."BaseType"= T2."ObjType"
		INNER JOIN OPRQ T4 on  T4."DocEntry"= T2."DocEntry"
	    Where T0."DocEntry"= :list_of_cols_val_tab_del 
	     --and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) 
AND T1."LineTotal" > T2."LineTotal" 
	       AND T0."DocType"='S' ;
	 
	      error_message :='Entred Total in Line No '|| :Line ||' is Greater than Purchase Request Price';                            
	end if;						
end if; 
-------------------------------------------------Price diffrence PR to PO in DRAFT SERVICE-----------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4
  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del 
 AND T1."LineTotal" > T2."LineTotal" 
---  and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) 
 and T1."ObjType"='22' AND T0."DocType"='S' ;
	if :Cnt1 > 0 then
		error := 13307;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN PRQ1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T1."BaseType"= T2."ObjType"
		INNER JOIN OPRQ T4 on  T4."DocEntry"= T2."DocEntry"
	    Where T0."DocEntry"= :list_of_cols_val_tab_del 
	    -- and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) 
AND T1."LineTotal" > T2."LineTotal"   and T1."ObjType"='22' AND T0."DocType"='S';
	 
	      error_message :='Entred Price in Line No '|| :Line ||' is Greater than Purchase Request Price';                            
	end if;						
end if; 
---------------------------------------------QUANTITY diffrence PR to PO SERVICE---------------------------------------------------------------------------
Cnt1:=0;           
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from OPOR T0 inner join POR1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN 
	OPRQ T4 on  T4."DocEntry"= T2."DocEntry"  Where 
	T0."DocEntry"= :list_of_cols_val_tab_del and T1."U_Quantity" > T2."U_Quantity" AND T0."DocType"='S' ;
 
   if :Cnt1 > 0 then
	 error := 13306;
	 Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from OPOR T0 inner join POR1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4 on  
		T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del
		and	T1."U_Quantity" > T2."U_Quantity" AND T0."DocType"='S';

      error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Purchase Request quantity';                            
end if;						
end if; 
------------------------------------------------QUANTITY diffrence PR to PO Draft SERVICE-------------------------------------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4
  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del and T1."U_Quantity" > T2."U_Quantity"  and T1."ObjType"='22' AND T0."DocType"='S' ;
	if :Cnt1 > 0 then
		error := 13303;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN PRQ1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T1."BaseType"= T2."ObjType"
		INNER JOIN OPRQ T4 on  T4."DocEntry"= T2."DocEntry"
	    Where T0."DocEntry"= :list_of_cols_val_tab_del and   T1."U_Quantity" > T2."U_Quantity" and T1."ObjType"='22' AND T0."DocType"='S';
	 
	      error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Purchase Request Price';                            
	end if;						
end if; 
-------------------------------------------------------QUANTITY diffrence PR to PO Item Wise DRAFT-------------------------------------------------------------------
Cnt1:=0; 

          
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4 
	on  T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del
	and T1."Quantity" > T2."Quantity" AND T0."DocType"='I'   and T1."ObjType"='22' ;

	if :Cnt1 > 0 then
		error := 133072;
		Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from ODRF T0 inner join DRF1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4 on 
		T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del 
		and	T1."Quantity" > T2."Quantity" AND T0."DocType"='I'  and T1."ObjType"='22' ;
		
	    error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Purchase Request quantity';    
	                            
    end if;						
end if; 
----------------------------------------------------Price diffrence SQ to SO Item Wise ---------------------------------------------------------------------------------------
  
if :object_type='17' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from OPOR T0 inner join POR1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4 
	on  T4."DocEntry"= T2."DocEntry" Where T0."DocEntry"= :list_of_cols_val_tab_del
	 and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )    AND T0."DocType"='I' ;

	if :Cnt1 > 0 then
		error := 13301;
		Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from OPOR T0 inner join POR1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4 on 
		T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del 
		 and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )  AND T0."DocType"='I' ;
		
	    error_message :='Entred total in Line No '|| :Line ||' is Greater than Purchase Request quantity';    
	                            
    end if;						
end if; 
---------------------------------------------------------Price diffrence PR to PO Item Wise DRAFT----------------------------------------------------------------------------------------
Cnt1:=0; 

          
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4 
	on  T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del
	 and ( T1."LineTotal" > T2."LineTotal"  ) AND T0."DocType"='I'   and T1."ObjType"='22' ;

	if :Cnt1 > 0 then
		error := 13608;
		Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from ODRF T0 inner join DRF1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN PRQ1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPRQ T4 on 
		T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del 
		 and ( T1."LineTotal" > T2."LineTotal"  )   AND T0."DocType"='I'  and T1."ObjType"='22' ;
		
	    error_message :='Entred Total in Line No '|| :Line ||' is Greater than Purchase Request quantity';    
	                            
    end if;						
end if; 
--------------------------------------------------------------------------------------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------- PO TO GRPO---------------------------------------------------------------------------------------------------
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------------------Price diffrence PO  to GRPO SERVICE--------------------------------------------------------------------------------------
/*Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4
  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del 
 --and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) 
 and  T1."LineTotal" > T2."LineTotal"
  AND T0."DocType"='S' ;
-----Cnt1=1;
	if :Cnt1 > 0 then
		error := 13305;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN POR1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T1."BaseType"= T2."ObjType"
		INNER JOIN OPOR T4 on  T4."DocEntry"= T2."DocEntry"
	    Where T0."DocEntry"= :list_of_cols_val_tab_del 
	   -- and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )
	    and  T1."LineTotal" > T2."LineTotal"
	     AND T0."DocType"='S' ;
	 
	      error_message :='Entred Total in Line No '|| :Line ||' is Greater than Purchase Order Price';                            
	end if;						



 SELECT  "LINE TOTAL" into Line FROM 
 (Select IFNULL(T1."LineTotal",0) "LINE TOTAL",IFNULL(T2."LineTotal",0) AS "PO" ,
 IFNULL((SELECT "GRPO_AMOUNT"(T1."BaseEntry",T1."BaseLine") FROM DUMMY),0)"GRPO AMOUNT"
  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry"
  INNER JOIN POR1 T2   on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType"
   INNER JOIN OPOR T4  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del   AND T0."CANCELED"='N' ) 
 WHERE ("LINE TOTAL"+"GRPO AMOUNT") > "PO";
 
 Cnt1:=1; 

       if :Cnt1 > 0 then
		error := 13305;
    SELECT   TOP 1 ("LineNum"+1)  FROM 
 (Select IFNULL(T1."LineTotal",0) "LINE TOTAL",IFNULL(T2."LineTotal",0) AS "PO" ,T1."LineNum",
 IFNULL((SELECT "GRPO_AMOUNT"(T1."BaseEntry",T1."BaseLine") FROM DUMMY),0)"GRPO AMOUNT"
  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry"
  INNER JOIN POR1 T2   on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType"
   INNER JOIN OPOR T4  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del   AND T0."CANCELED"='N' );
 
  error_message :='Entred Total in Line No '|| :Line ||' is Greater than Purchase Order Price';    
                        
	end if;	
	---
end if; */


/*--------------------------------------------------Price diffrence  PO  to GRPO  Item Wise ---------------------------------------------------------------------------------------
  
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4 
	on  T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del
	 and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )   AND T0."DocType"='I' ;

	if :Cnt1 > 0 then
		error := 13301;
		Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from OPDN T0 inner join PDN1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4 on 
		T4."DocEntry"= T2."DocEntry" Where T0."DocEntry"= :list_of_cols_val_tab_del 
	 and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  ) AND T0."DocType"='I' ;
		
	    error_message :='Entred total in Line No '|| :Line ||' is Greater than Purchase Order quantity';    
	                            
    end if;						
end if; 
---------------------------------------------------------Price diffrence  PO  to GRPO  Item Wise DRAFT----------------------------------------------------------------------------------------
Cnt1:=0; 

          
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4 
	on  T4."DocEntry"= T2."DocEntry" Where T0."DocEntry"= :list_of_cols_val_tab_del
 and (T1."Quantity" > T2."Quantity"   ) AND T0."DocType"='I'   and T1."ObjType"='20' ;

	if :Cnt1 > 0 then
		error := 1308;
		Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from ODRF T0 inner join DRF1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4 on 
		T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del 
	 and (T1."Quantity" > T2."Quantity"  )  AND T0."DocType"='I'  and T1."ObjType"='20' ;
		
	    error_message :='Entred Total in Line No '|| :Line ||' is Greater than Purchase Order quantity';    
	                            
    end if;						
end if; 
---------//-----------------------------------------------------//-----------------------------------------------------


-----------------------------------------------Price diffrence PO  to GRPO SERVICE--------------------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 	
	
 select ifnull(( select  COUNT ( DISTINCT T0."DocNum")    from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry"
  inner JOIN POR1 T2   on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" 
  and T1."BaseType"= T2."ObjType"
   INNER JOIN OPOR T4  on  T4."DocEntry"= T2."DocEntry" 
 Where  T4."DocEntry"=(SELECT TOP 1(T2."DocEntry") from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry"
  INNER JOIN POR1 T2   on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"
  WHERE T0."DocEntry"= :list_of_cols_val_tab_del  )
 AND T0."CANCELED"='N' ),0) into PRICE   from dummy ;
	
if PRICE =1 then

 Select Count(*) into Cnt1  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T0."BaseType"= T2."BaseType" INNER JOIN OPOR T4
  on  T4."DocEntry"= T2."DocEntry" AND T0."DocType"=T4."DocType" and T4."BaseType"= T2."BaseType"
 Where  T0."DocEntry"= :list_of_cols_val_tab_del and T1."LineTotal" > T2."LineTotal"  AND T0."DocType"='S' ;
	--Cnt1 =1;
	if :Cnt1 > 0 then
		error := 1330995;
		 
		Select TOP 1 (T1."VisOrder"+1) into Line  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN POR1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T0."BaseType"= T2."BaseType"
		INNER JOIN OPOR T4 on  T4."DocEntry"= T2."DocEntry" AND T0."DocType"=T4."DocType" and T4."BaseType"= T2."BaseType"
	    Where T0."DocEntry"= :list_of_cols_val_tab_del and  T1."LineTotal" > T2."LineTotal"  AND T0."DocType"='S' ;
	 
	      error_message :='Entred Total in Line No '|| :Line ||' is Greater than Purchase Order Price';                            
	end if;		
else					
	( SELECT   Count(*) into Cnt1    FROM 
 (Select IFNULL(T1."LineTotal",0) "LINE TOTAL",IFNULL(T2."LineTotal",0) AS "PO" ,
 IFNULL((SELECT "GRPO_AMOUNT"(T1."BaseEntry",T1."BaseLine",:list_of_cols_val_tab_del ) FROM DUMMY),0)"GRPO AMOUNT"
  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry"
  INNER JOIN POR1 T2   on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType"
   INNER JOIN OPOR T4  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del   AND T0."CANCELED"='N' ) 
 WHERE  (ifnull("LINE TOTAL",0)+ifnull("GRPO AMOUNT",0))>ifnull("PO",0) );
 --Cnt1 =1;
       if :Cnt1 > 0 then
       	error := 1330885;
SELECT   TOP 1 ("LineNum"+1) into Line  
--TOP 1(ifnull("LINE TOTAL",0)+ifnull("GRPO AMOUNT",0)) into Line
FROM 
 (Select IFNULL(T1."LineTotal",0) "LINE TOTAL",IFNULL(T2."LineTotal",0) AS "PO" ,T1."LineNum",
 IFNULL((SELECT "GRPO_AMOUNT"(T1."BaseEntry",T1."BaseLine",:list_of_cols_val_tab_del ) FROM DUMMY),0)"GRPO AMOUNT"
  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry"
  INNER JOIN POR1 T2   on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType"
   INNER JOIN OPOR T4  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del   AND T0."CANCELED"='N' )
 WHERE   (ifnull("LINE TOTAL",0)+ifnull("GRPO AMOUNT",0)>ifnull("PO",0));
  
  error_message :='Entred Total in Line No '|| :Line  ||' is Greater than Purchase Order Price';                        
	end if;		


 
end if; 
end if; 

-------------------------------------------------Price diffrence  PO  to GRPO  in DRAFT SERVICE-----------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4
  on  T4."DocEntry"= T2."DocEntry"
 Where  T0."DocEntry"= :list_of_cols_val_tab_del  and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )  and T1."ObjType"='20' AND T0."DocType"='S' ;
	if :Cnt1 > 0 then
		error := 13307;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN POR1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T1."BaseType"= T2."ObjType"
		INNER JOIN OPOR T4 on  T4."DocEntry"= T2."DocEntry" 
	    Where T0."DocEntry"= :list_of_cols_val_tab_del and (T1."LineTotal" >  T2."OpenSum" or  T1."LineTotal" > T2."LineTotal"  )  and T1."ObjType"='20' AND T0."DocType"='S';
	 
	      error_message :='Entred Price in Line No '|| :Line ||' is Greater than Purchase Order Price';                            
	end if;						
end if;
---------------------------------------------QUANTITY diffrence  PO  to GRPO  SERVICE---------------------------------------------------------------------------
Cnt1:=0;           
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN 
	OPOR T4 on  T4."DocEntry"= T2."DocEntry"  Where 
	T0."DocEntry"= :list_of_cols_val_tab_del and T1."U_Quantity" > T2."U_Quantity" AND T0."DocType"='S' ;
 
   if :Cnt1 > 0 then
	 error := 13306;
	 Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4 on  
		T4."DocEntry"= T2."DocEntry" Where T0."DocEntry"= :list_of_cols_val_tab_del
		and	T1."U_Quantity" > T2."U_Quantity" AND T0."DocType"='S';

      error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Purchase Order quantity';                            
end if;						
end if; 
------------------------------------------------QUANTITY diffrence  PO  to GRPO  Draft SERVICE-------------------------------------------------------------------------------------------------------
Cnt1:=0; 
PRICE:=0;
  Line:=0;         
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

  Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
  on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4
  on  T4."DocEntry"= T2."DocEntry" 
 Where  T0."DocEntry"= :list_of_cols_val_tab_del and T1."U_Quantity" > T2."U_Quantity"  and T1."ObjType"='20' AND T0."DocType"='S' ;
	if :Cnt1 > 0 then
		error := 13303;
		 
		Select TOP 1 (T1."LineNum"+1) into Line  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN POR1 T2 	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry"and T1."BaseType"= T2."ObjType"
		INNER JOIN OPOR T4 on  T4."DocEntry"= T2."DocEntry" 
	    Where T0."DocEntry"= :list_of_cols_val_tab_del and   T1."U_Quantity" > T2."U_Quantity" and T1."ObjType"='20' AND T0."DocType"='S';
	 
	      error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Purchase Order Price';                            
	end if;						
end if; 
-------------------------------------------------------QUANTITY diffrence  PO  to GRPO  Item Wise DRAFT-------------------------------------------------------------------
Cnt1:=0; 

          
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4 
	on  T4."DocEntry"= T2."DocEntry"Where T0."DocEntry"= :list_of_cols_val_tab_del
	and T1."Quantity" > T2."Quantity" AND T0."DocType"='I'   and T1."ObjType"='20' ;

	if :Cnt1 > 0 then
		error := 133072;
		Line:=0;  
		Select TOP 1 (T1."LineNum"+1) into Line   from ODRF T0 inner join DRF1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."ObjType" INNER JOIN OPOR T4 on 
		T4."DocEntry"= T2."DocEntry"  Where T0."DocEntry"= :list_of_cols_val_tab_del 
		and	T1."Quantity" > T2."Quantity" AND T0."DocType"='I'  and T1."ObjType"='20' ;
		
	    error_message :='Entred Quantity in Line No '|| :Line ||' is Greater than Purchase Order quantity';    
	                            
    end if;						
end if;  */
-------------------------------------------SO to PR Draft----------------------------------------------------------------------------------------------------------

Cnt1:=0;
Cnt2:=0;				
IF :object_type='112' and ( :transaction_type ='A'  OR :transaction_type ='U') THEN
 
	DECLARE GRP NVARCHAR(100):='';
	DECLARE SUBGRP NVARCHAR(100):='';
	DECLARE refnum NVARCHAR(100):='';
	DECLARE DocDate DATE;
	DECLARE FDate DATE;
	DECLARE TDate DATE;
	DECLARE Budget NVARCHAR(10):='';
	DECLARE PostingAmt DOUBLE;
	DECLARE PostedAmt DOUBLE;
	DECLARE testm DOUBLE;
	DECLARE tests DOUBLE;
	DECLARE BudgetAmt DOUBLE;
	DECLARE PosYear INTEGER;
	DECLARE CostEnabled NVARCHAR(100):='';
	DECLARE BudgetFlag INTEGER:=0;
	DECLARE PostedPRAmount DOUBLE;
	DECLARE DraftPRAmount DOUBLE;
	
	DECLARE CURSOR c_items FOR SELECT SUM(T1."LineTotal") AS "LineTotal","U_Group","U_SUBGRP","RefDocNum","U_FRMSQ"
	FROM ODRF T0 INNER JOIN DRF1 T1 ON T0."DocEntry" = T1."DocEntry" INNER JOIN DRF21 K ON K."DocEntry" = T1."DocEntry"  
	WHERE T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_FRMSQ"='Y' AND "RefObjType"='17' AND T0."ObjType"='1470000113'
	group by "U_Group","U_SUBGRP","RefDocNum","U_FRMSQ", T1."LineNum" order by T1."LineNum" DESC;
	
	   FOR cur_row as c_items DO			
		  
	      GRP := cur_row."U_Group";
		  SUBGRP := cur_row."U_SUBGRP";
		  refnum := cur_row."RefDocNum";
		  PostingAmt := cur_row."LineTotal";
		  CostEnabled := cur_row."U_FRMSQ";
		 
	       SELECT  IFNULL(( Select IFNULL(SUM("LineTotal"),0) from PRQ1 T0  INNER JOIN OPRQ T1 ON T0."DocEntry" = T1."DocEntry" INNER JOIN 
		   PRQ21 K  ON K."DocEntry" = T1."DocEntry" WHERE T0."U_SUBGRP"=:SUBGRP  and T0."U_Group"=:GRP and K."RefDocNum"=:refnum  and 
		    T1."U_FRMSQ"='Y'  AND "RefObjType"='17'   ),0)INTO PostedPRAmount FROM DUMMY;
		   
		 
		 
		   SELECT  IFNULL((Select  IFNULL(SUM("LineTotal"),0) from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" INNER JOIN DRF21 K
		   ON K."DocEntry" = T1."DocEntry" inner JOIN OWDD A ON T1."DocEntry"=A."DraftEntry" WHERE T0."U_SUBGRP"=:SUBGRP and T0."U_Group"=:GRP
		   and  K."RefDocNum"=:refnum  and T1."U_FRMSQ"='Y' AND "RefObjType"='17'  AND  A."Status"<>'N' and T1."DocStatus"<>'C' AND A."ObjType"='1470000113'),0)
		    INTO DraftPRAmount  FROM DUMMY;
		 
		 -------BudgetAmt
		
		   SELECT IFNULL((Select SUM("LineTotal")  from ORDR T0 inner join RDR1 T1 on T0."DocEntry"= T1."DocEntry"	WHERE T0."DocNum"=:refnum 
		   AND T1."U_SUBGRP"=:SUBGRP and T1."U_Group"=:GRP),0) into BudgetAmt FROM DUMMY;
		   
		    PostingAmt := :DraftPRAmount + :PostedPRAmount;
			
				  IF :PostingAmt  >:BudgetAmt AND :BudgetFlag =0  THEN
						  BudgetFlag :=1;
						  BudgetFlag :=1;
	 					  SUBGRP=:cur_row."U_SUBGRP";
				          GRP=:cur_row."U_Group";
						  PostedAmt=:PostingAmt ;
						  BREAK ;
					 
	             END IF;
       
	   END FOR;
	

      IF :BudgetFlag = 1 THEN	
	        error := 1987;							
		  	error_message := 'Posting Amount '|| :PostedAmt ||' is greater than '|| :BudgetAmt ||', Amount in Draft PR '|| :DraftPRAmount ||'  AND Already added to PR '|| :PostedPRAmount ||' in group '|| :GRP ||' and  Subgroup  '|| :SUBGRP ||' ';				
	 END IF;
END IF;

------------------------------------SO to PR ---------------------------------------------------------------------------------------------------------------
Cnt1:=0;
Cnt2:=0;				
IF :object_type='1470000113' and ( :transaction_type ='A'  OR :transaction_type ='U') THEN
 
	DECLARE GRP NVARCHAR(100):='';
	DECLARE SUBGRP NVARCHAR(100):='';
	DECLARE refnum NVARCHAR(100):='';
	DECLARE DocDate DATE;
	DECLARE FDate DATE;
	DECLARE TDate DATE;
	DECLARE Budget NVARCHAR(10):='';
	DECLARE PostingAmt DOUBLE;
	DECLARE PostedAmt DOUBLE;
	DECLARE testm DOUBLE;
	DECLARE tests DOUBLE;
	DECLARE BudgetAmt DOUBLE;
	DECLARE PosYear INTEGER;
	DECLARE CostEnabled NVARCHAR(100):='';
	DECLARE BudgetFlag INTEGER:=0;
	DECLARE PostedPRAmount DOUBLE;
	DECLARE DraftPRAmount DOUBLE;
	
	DECLARE CURSOR c_items FOR SELECT SUM(T1."LineTotal") AS "LineTotal","U_Group","U_SUBGRP","RefDocNum","U_FRMSQ"
	FROM OPRQ T0 INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry" INNER JOIN PRQ21 K ON K."DocEntry" = T1."DocEntry"  
	WHERE T0."DocEntry" =:list_of_cols_val_tab_del and T0."U_FRMSQ"='Y' AND "RefObjType"='17' AND T0."ObjType"='1470000113'
	group by "U_Group","U_SUBGRP","RefDocNum","U_FRMSQ", T1."LineNum" order by T1."LineNum" DESC;
	

	FOR cur_row as c_items DO			
		  
		 GRP := cur_row."U_Group";
		 SUBGRP := cur_row."U_SUBGRP";
		 refnum := cur_row."RefDocNum";
		 PostingAmt := cur_row."LineTotal";
		 CostEnabled := cur_row."U_FRMSQ";
		  
   ---PostedAmt 
   SELECT  IFNULL(( Select IFNULL(SUM("LineTotal"),0) from PRQ1 T0  INNER JOIN OPRQ T1 ON T0."DocEntry" = T1."DocEntry" INNER JOIN 
   PRQ21 K  ON K."DocEntry" = T1."DocEntry" WHERE T0."U_SUBGRP"=:SUBGRP  and T0."U_Group"=:GRP and K."RefDocNum"=:refnum  and 
    T1."U_FRMSQ"='Y'  AND "RefObjType"='17'   ),0)INTO PostedPRAmount FROM DUMMY;
		   
		 
		 
	SELECT  IFNULL((Select  IFNULL(SUM("LineTotal"),0) from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" INNER JOIN DRF21 K
	ON K."DocEntry" = T1."DocEntry" inner JOIN OWDD A ON T1."DocEntry"=A."DraftEntry" WHERE T0."U_SUBGRP"=:SUBGRP and T0."U_Group"=:GRP
	and  K."RefDocNum"=:refnum  and T1."U_FRMSQ"='Y' AND "RefObjType"='17'  AND  A."Status"<>'N' and T1."DocStatus"<>'C' AND A."ObjType"='1470000113'),0)
	INTO DraftPRAmount  FROM DUMMY;
		 
	
	 SELECT IFNULL((SELECT IFNULL(SUM(T1."LineTotal"),0)FROM OPRQ T0 INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry" 
	 INNER JOIN PRQ21 K ON K."DocEntry" = T1."DocEntry" WHERE T0."DocEntry" =:list_of_cols_val_tab_del  AND T0."ObjType"='1470000113'
	 AND T1."U_SUBGRP"=:SUBGRP and T1."U_Group"=:GRP	and K."RefDocNum"=:refnum),0) INTO PostingAmt FROM DUMMY;
			
			
			
 ----BudgetAmt
	 SELECT IFNULL((Select SUM("LineTotal")  from ORDR T0 inner join RDR1 T1 on T0."DocEntry"= T1."DocEntry"	WHERE T0."DocNum"=:refnum 
	 AND T1."U_SUBGRP"=:SUBGRP and T1."U_Group"=:GRP),0) into BudgetAmt FROM DUMMY;
		   
		  PostingAmt := :DraftPRAmount + :PostedPRAmount;
		
			IF :PostingAmt  >:BudgetAmt AND :BudgetFlag =0  THEN
				  BudgetFlag :=1;
				  SUBGRP=:cur_row."U_SUBGRP";
			      GRP=:cur_row."U_Group";
				  PostedAmt=:PostingAmt ;
				  BREAK ;
	       END IF;
	         	
	         	 SUBGRP='';
			      GRP='';
	END FOR;
	
 
		IF :BudgetFlag = 1 THEN	
		   error := 1654;							
		   error_message := 'Posting Amount '|| :PostedAmt ||' is greater than '|| :BudgetAmt ||', Amount in Draft PR '|| :DraftPRAmount ||'  AND Already added to PR '|| :PostedPRAmount ||' in group '|| :GRP ||' and  Subgroup  '|| :SUBGRP ||' ';				
		END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 
	select (Case when( Select T1."U_FRMSQ"  from OPRQ T1  WHERE  T1."DocEntry" =:list_of_cols_val_tab_del )='Y' Then
    (case when (Select count(*)  from PRQ1 T0  INNER JOIN OPRQ T1 ON T0."DocEntry" = T1."DocEntry" inner JOIN PRQ21 K  ON K."DocEntry" = T1."DocEntry"
	WHERE T1."DocEntry" =:list_of_cols_val_tab_del  and T1."U_FRMSQ"='Y' AND "RefObjType"='17')>0 then 0   else     1 end) else 2 end)
	 into Cnt1  from dummy ;  						
 	---Cnt1 = 1 ;
 	if :Cnt1 = 1 then
error := 1233;
error_message := 'Please select the Related Sales Order Docnum in the Related document'  ;
end if;						
end if; 
---------------------------------------------------------------------------------------------
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
 
	select (Case when( Select T1."U_FRMSQ"  from ODRF T1  WHERE  T1."DocEntry" =:list_of_cols_val_tab_del  AND T1."ObjType"='1470000113')='Y' Then
    (case when (Select count(*)  from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" inner JOIN DRF21 K  ON K."DocEntry" = T1."DocEntry"
	WHERE  T1."DocEntry" =:list_of_cols_val_tab_del and T1."U_FRMSQ"='Y' AND "RefObjType"='17'  AND T0."ObjType"='1470000113')>0 then 0   else     1 end)
	 else 2 end) into Cnt1  from dummy ;  						
 ---Cnt1 = 1 ;
 	if :Cnt1 = 1 then
error := 1230;
error_message := 'Please select the Related Sales Order Docnum in the Related document'  ;
end if;						
end if; 
---------------------------------------------------------------------------------------------------------------------------------
Cnt1:=0; 

if :object_type='17' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ORDR T0 inner join RDR1 T1 on T0."DocEntry"= T1."DocEntry" where 
	ifnull(T1."BaseEntry",0)=0 	and T0."DocEntry"= :list_of_cols_val_tab_del; 
	
 	  if :Cnt1 = 1 then
         error := 16809;
         error_message := 'Sales Order cannot be added with out sales quotation'  ;
      end if;						
end if; 
------------------------------------------------------------------------------------------------------------------------
Cnt1:=0; 

if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" where 
	ifnull(T1."BaseEntry",0)=0 	and T0."DocEntry"= :list_of_cols_val_tab_del and T1."ObjType"='17' ;
	
     if :Cnt1 = 1 then
         error := 16097;
         error_message := 'Sales Order cannot be added with out sales quotation'  ;
      end if;						
end if;
-----------------------------------------------------------------------------------------------------------
Cnt1:=0; 

         
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry" where 
	ifnull(T1."BaseEntry",0)=0 	and T0."DocEntry"= :list_of_cols_val_tab_del   and T1."ObjType"='22' ;
 
     if :Cnt1 = 1 then
         error := 1087;
         error_message := 'Purchase Order cannot be added with out Purchase Request'  ;
      end if;	
      					
end if; 
------------------------------------------------------------------------------------------------------

Cnt1:=0;           
if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from OPOR T0 inner join POR1 T1 on T0."DocEntry"= T1."DocEntry"  where 
	ifnull(T1."BaseEntry",0)=0 	and T0."DocEntry"= :list_of_cols_val_tab_del; 
	 if :Cnt1 = 1 then
         error := 1088;
         error_message := 'Purchase Order cannot be added with out Purchase Request';
      end if;	
end if;      
-----------------------------------------------------------------------------------------------------------------------

Cnt1:=0; 

          
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

	DECLARE GRUP NVARCHAR(100):='';
select  count(*)INTO Cnt1 from OPRQ T0 inner join PRQ1 T1 on T0."DocEntry"= T1."DocEntry"
INNER JOIN PRQ21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
WHERE  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
and T0."DocEntry"= :list_of_cols_val_tab_del; 
--Cnt1 = 1;
 if :Cnt1 >0 then
         error := 107;
         select  top 1 "U_SUBGRP" INTO GRUP from OPRQ T0 inner join PRQ1 T1 on T0."DocEntry"= T1."DocEntry"
        INNER JOIN PRQ21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
        WHERE  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
        and T0."DocEntry"= :list_of_cols_val_tab_del; 
         error_message := 'Sub Group  Not Present in Sales Order '||:GRUP||' ';
      end if;	
end if;  
------------------------------------------------------------------------------------------------------------------------
Cnt1:=0; 

 if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
          

	DECLARE GRUP NVARCHAR(100):='';
select  count(*)INTO Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
INNER JOIN DRF21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
WHERE  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
and T0."DocEntry"= :list_of_cols_val_tab_del and T1."ObjType"='1470000113' ; 
--Cnt1 = 1;
 if :Cnt1 >0 then
         error := 107;
         select  top 1 "U_SUBGRP" INTO GRUP from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
        INNER JOIN DRF21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
        WHERE  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
        and T0."DocEntry"= :list_of_cols_val_tab_del AND T1."ObjType"='1470000113' ; 
         error_message := 'Sub Group  Not Present in Sales Order '||:GRUP||' ';
      end if;	
end if;  
------------------------------------------------------------------------------------------------------------------------
Cnt1:=0; 

          
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

	DECLARE GRUP NVARCHAR(100):='';
select  count(*)INTO Cnt1 from OPRQ T0 inner join PRQ1 T1 on T0."DocEntry"= T1."DocEntry"
INNER JOIN PRQ21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
and T0."DocEntry"= :list_of_cols_val_tab_del; 
--Cnt1 = 1;
 if :Cnt1 >0 then
         error := 107;
         select  top 1 "U_Group" INTO GRUP from OPRQ T0 inner join PRQ1 T1 on T0."DocEntry"= T1."DocEntry"
        INNER JOIN PRQ21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
        WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
        and T0."DocEntry"= :list_of_cols_val_tab_del; 
         error_message := 'Group  Not Present in Sales Order '||:GRUP||' ';
      end if;	
end if;       
---------------------------------------------------------------------------------------------------------------------------
  Cnt1:=0; 

 if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 
          

	DECLARE GRUP NVARCHAR(100):='';
select  count(*)INTO Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
INNER JOIN DRF21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
and T0."DocEntry"= :list_of_cols_val_tab_del and T1."ObjType"='1470000113' ; 
--Cnt1 = 1;
 if :Cnt1 >0 then
         error := 107;
         select  top 1 "U_Group" INTO GRUP from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
        INNER JOIN DRF21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
        WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
        and T0."DocEntry"= :list_of_cols_val_tab_del AND T1."ObjType"='1470000113' ; 
         error_message := 'Group  Not Present in Sales Order '||:GRUP||' ';
      end if;	
end if;  
------------------------------------------------------------------------------------------------------------ 
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

	DECLARE GRUP NVARCHAR(100):='';
	DECLARE sGRUP NVARCHAR(100):='';
		select  count(*)INTO Cnt1 from OPRQ T0 inner join PRQ1 T1 on T0."DocEntry"= T1."DocEntry"
		INNER JOIN PRQ21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
		WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
		and T0."DocEntry"= :list_of_cols_val_tab_del and  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
		      ; 
      --Cnt1 = 1;
 if :Cnt1 >0 then
         error := 107;
         select  top 1 "U_Group" INTO GRUP from OPRQ T0 inner join PRQ1 T1 on T0."DocEntry"= T1."DocEntry"
        INNER JOIN PRQ21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
        WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
        and T0."DocEntry"= :list_of_cols_val_tab_del and  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
      ; 
       select  top 1 "U_SUBGRP" INTO sGRUP from OPRQ T0 inner join PRQ1 T1 on T0."DocEntry"= T1."DocEntry"
        INNER JOIN PRQ21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
        WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
        and T0."DocEntry"= :list_of_cols_val_tab_del and  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
      ; 
         error_message := 'Group  Not Present in Sales Order '||:GRUP||' and '||:sGRUP||' ';
      end if;	
end if;       
----------------------------------------------------------------------------------------------------------------------
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

DECLARE GRUP NVARCHAR(100):='';
DECLARE sGRUP NVARCHAR(100):='';
	select  count(*)INTO Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
	INNER JOIN DRF21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
	WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
	and T0."DocEntry"= :list_of_cols_val_tab_del and  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
    and T1."ObjType"='1470000113' ;  
      --Cnt1 = 1;
 if :Cnt1 >0 then
         error := 107;
      select  top 1 "U_Group" INTO GRUP from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
      INNER JOIN DRF21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
      WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
      and T0."DocEntry"= :list_of_cols_val_tab_del and  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
      and T1."ObjType"='1470000113' ;  
      
      select  top 1 "U_SUBGRP" INTO sGRUP from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
      INNER JOIN DRF21 M ON T0."DocEntry" = M."DocEntry"  and T0."U_FRMSQ"='Y' AND "RefObjType"='17' --and "RefDocNum"='700025' 
      WHERE  T1."U_Group" not  in (select "U_Group" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
      and T0."DocEntry"= :list_of_cols_val_tab_del and  T1."U_SUBGRP" not  in (select "U_SUBGRP" from ORDR G inner join RDR1 H on G."DocEntry"= H."DocEntry"	WHERE G."DocNum"=M."RefDocNum")
      and T1."ObjType"='1470000113' ;  
      
         error_message := 'Group  Not Present in Sales Order '||:GRUP||' and '||:sGRUP||' ';
      end if;	
end if;       
-------------------------------01/11/2023-------------------------------------------------------------------------------------------
----------------------------------------Type mandatory in PR----------------------------------------------
Cnt1:=0; 
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from OPRQ T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_TYPE",'')='' ;
							
 	if :Cnt1 > 0 then
error := 1933;
error_message := 'Purchase Request Cannot be added with out Type.'  ;
end if;						
end if; 
----------------------------------
----------------------------------------Type mandatory in GRPO----------------------------------------------
Cnt1:=0; 
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from OPDN T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_TYPE",'')='' ;
							
 	if :Cnt1 > 0 then
error := 1933;
error_message := 'GRN Request Cannot be added with out Type.'  ;
end if;						
end if; 
----------------------------------
-------------------------------Contract mandatory in SQ DRAFT--------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

   Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
   WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
  and   ifnull(T1."U_TYPE",'')=''   and  T1."ObjType"='1470000113'; 
 								
 	if :Cnt1 > 0 then
      error := 1230;
       error_message := 'Purchase Request Cannot be added with out Type.'  ;
       end if;						
    end if; 


------------------------------------------------------------------------------------------------------------------
/*---------------------------------------Category mandatory in PR----------------------------------------------
Cnt1:=0; 
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 
DECLARE TYPES NVARCHAR(100):='';

 Select ("U_TYPE") into TYPES from OPRQ T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del ;

   IF TYPES='AMC' THEN
   
    Select Count(*) into Cnt1 from OPRQ T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
    and  IFNULL("U_CATEGORY",'')='';
    if :Cnt1 > 0 then
error := 19377;
error_message := 'Please add a Category  to the Purchase Request  for the AMC Type.'  ;
end if;		
   end if;
   
 				
end if; */
---------------------------------------------------------------------------------------------------
-------------------------------------Category mandatory in PR----------------------------------------------
Cnt1:=0; 
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 
DECLARE TYPES NVARCHAR(100):='';
Select Count(*) into Cnt1 from OPRQ T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  IFNULL("U_CATEGORY",'')='';
    if :Cnt1 > 0 then
error := 19377;
error_message := 'Please add a Category  to the Purchase Request.'  ;
end if;		
  
   
 				
end if; 
-------------------------------------'Employee Master Data  cannot be added with out Project-----------------------------------------------------------------
-------------------------------------Category mandatory in GRPO----------------------------------------------
Cnt1:=0; 
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 
DECLARE TYPES NVARCHAR(100):='';
Select Count(*) into Cnt1 from OPDN T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  IFNULL("U_CATEGORY",'')='';
    if :Cnt1 > 0 then
error := 19377;
error_message := 'Please add a Category  to the GRN.'  ;
end if;		
  
   
 				
end if; 
-------------------------------------'Employee Master Data  cannot be added with out Project-----------------------------------------------------------------

Cnt1:=0; 
if :object_type='171' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from OHEM T0  WHERE T0."empID"= :list_of_cols_val_tab_del 
    and  IFNULL("U_PROJECT",'')='';
    
  if :Cnt1 > 0 then
     error := 193007;
     error_message := 'Employee Master Data  cannot be added with out Project'  ;
  end if;		
end if;
   
------------------------------------------------------------------------------------------------------\\
------------------------------------ Valid Active Project------------------------------------------------------------------
Cnt1:=0; 
if :object_type='171' and (:transaction_type ='A'  OR :transaction_type ='U') then 

DECLARE PROJECT NVARCHAR(100):='';

Select IFNULL("U_PROJECT",'') into PROJECT from OHEM T0  WHERE T0."empID"= :list_of_cols_val_tab_del ;
 
 if :PROJECT <>'' then
  SELECT COUNT(T0."PrjCode")INTO Cnt1 FROM OPRJ T0 WHERE T0."Active" ='Y' AND T0."PrjCode"=:PROJECT;
  
    if :Cnt1 = 0 then
     error := 190307;
     error_message := 'Please Select a Valid Active Project ..'  ;
    end if;		
  end if;
end if;
      
------------------------------------------------------------------------------------------------------
----------------------------------------------Purchase Request Cannot be added with out Department--------------------------------------------------------
Cnt1:=0; 
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from OPRQ T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_DEPARTMENTT",'')='' ;
							
 	if :Cnt1 > 0 then
error := 1933;
error_message := 'Purchase Request Cannot be added with out Department.'  ;
end if;						
end if; 
------------------------------------------------------------------------------------------------------
----------------------------------------------Purchase Request Cannot be added with out Division--------------------------------------------------------
Cnt1:=0; 
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from OPRQ T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Division",'')='' ;
							
 	if :Cnt1 > 0 then
error := 1933;
error_message := 'Purchase Request Cannot be added with out Division.'  ;
end if;						
end if; 
------------------------------------------------------------------------------------------------------
----------------------------------------------Purchase Request Cannot be added with out Division--------------------------------------------------------
Cnt1:=0; 
if :object_type='1470000113' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from OPRQ T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Contract",'')='' ;
							
 	if :Cnt1 > 0 then
error := 1933;
error_message := 'Purchase Request Cannot be added with out Contract.'  ;
end if;						
end if; 
------------------------------------------------------------------------------------------------------

---------------------------------------------- GRN Cannot be added with out Division--------------------------------------------------------
Cnt1:=0; 
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from OPDN T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Division",'')='' ;
							
 	if :Cnt1 > 0 then
error := 1933;
error_message := 'GRN Cannot be added with out Division.'  ;
end if;						
end if; 
------------------------------------------------------------------------------------------------------
---------------------------------------------- GRN Cannot be added with out Division--------------------------------------------------------
Cnt1:=0; 
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 

 Select Count(*) into Cnt1 from OPDN T0  WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Contract",'')='' ;
							
 	if :Cnt1 > 0 then
error := 1933;
error_message := 'GRN Cannot be added with out Contract.'  ;
end if;						
end if; 
------------------------------------------------------------------------------------------------------

----------------------------------------------------Total diffrence PO  to GRPO  Item Wise ---------------------------------------------------------------------------------------
  
if :object_type='20' and (:transaction_type ='A'  OR :transaction_type ='U') then 
	
	Select Count(*) into Cnt1  from OPDN T0 inner join PDN1 T1 on T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
	on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."BaseType" INNER JOIN OPOR T4 
	on  T4."DocEntry"= T2."DocEntry" AND T0."DocType"=T4."DocType" and T4."BaseType"= T2."BaseType" Where T0."DocEntry"= :list_of_cols_val_tab_del
	and  T1."LineTotal" > T2."LineTotal"   AND T0."DocType"='I' ;

	if :Cnt1 > 0 then
		error := 13301;
		Line:=0;  
		Select TOP 1 (T1."VisOrder"+1) into Line   from OPDN T0 inner join PDN1 T1 on	T0."DocEntry"= T1."DocEntry" INNER JOIN POR1 T2 
		on T1."BaseLine"=T2."LineNum" and T1."BaseEntry"= T2."DocEntry" and T1."BaseType"= T2."BaseType" INNER JOIN OPOR T4 on 
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

------------------------------------------------------------
---------------------------------------------------------------------------------------------

/*
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  T0."U_CMNT" IS null  ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Sales Quotation Subject'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  T0."U_CMNT" IS null   and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Sales Quotation Subject'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from  OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and IFNULL(T0."CntctCode",0) =0 and T0."CANCELED"='N' ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out  Contact Person'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and   IFNULL(T0."CntctCode",0) =0 and T0."CANCELED"='N' and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Contact Person'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

/*-------------------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then

SELECT count(T2."trgtPath" ||'\'|| T2."FileName"||'.'|| T2."FileExt")  into Cnt1 
 FROM "OQUT" T0 INNER JOIN "OATC" T1 ON T0."AtcEntry"=T1."AbsEntry" 
INNER JOIN "ATC1" T2 ON T2."AbsEntry"=T1."AbsEntry" 
where T0."DocEntry"=:list_of_cols_val_tab_del;

IF Cnt1 =0 THEN
error := 12658300;
error_message := ' Atleast 1 is Attachment Mandatory'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------
Cnt1:=0;
Line:=0;  
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then

SELECT count(*)  into Line FROM "ODRF" T0 where T0."DocEntry"=:list_of_cols_val_tab_del and T0."ObjType"='23';  
if Line>1 then
SELECT count(T2."trgtPath" ||'\'|| T2."FileName"||'.'|| T2."FileExt")  into Cnt1 
 FROM "ODRF" T0 INNER JOIN "OATC" T1 ON T0."AtcEntry"=T1."AbsEntry" 
INNER JOIN "ATC1" T2 ON T2."AbsEntry"=T1."AbsEntry" 
where T0."DocEntry"=:list_of_cols_val_tab_del and T0."ObjType"='23';  
IF Cnt1 =0 THEN
error := 128300;
error_message := ' Atleast 1 is Attachment Mandatory'  ;
end if;  
end if;                        
end if; 

---------------------------------------------------------------------------------------------

Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Location",'')=''  ;    
     if :Cnt1 > 0 then
error := 123070;
error_message := 'Sales Quotation Cannot be added with out Location'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Location",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 126300;
error_message := 'Sales Quotation Cannot be added with out Location'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_WORKORDER",'')=''  ;    
     if :Cnt1 > 0 then
error := 1230900;
error_message := 'Sales Quotation Cannot be added with out Work Order Number'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0  inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_WORKORDER",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 123080;
error_message := 'Sales Quotation Cannot be added with out Work Order Number'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  T0."U_WRNTY" IS Null  ;    
     if :Cnt1 > 0 then
error := 12365400;
error_message := 'Sales Quotation Cannot be added with out Delivery'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  T0."U_WRNTY" IS Null   and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 1236500;
error_message := 'Sales Quotation Cannot be added with out Delivery'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."GroupNum",0)=0  ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Payment Terms'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."GroupNum",0)= 0  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Payment Terms'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_SQTYPE",'')<>''  ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Department'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
/*Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_SQTYPE",0)=0  and T0."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out  Department'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Division",'')='' ;    
     if :Cnt1 > 0 then
error := 123110;
error_message := 'Sales Quotation Cannot be added with out Division'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Division",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 123110;
error_message := 'Sales Quotation Cannot be added with out Division'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------
*/
/*---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND LENGTH (T0."U_CMNT") > 200   ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'The subject of the sales quotation should not exceed 200 characters.'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND LENGTH (T0."U_CMNT") > 200  and T0."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'The subject of the sales quotation should not exceed 200 characters.'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND LENGTH (T0."U_WRNTY") > 200   ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'The Delivery  of the sales quotation should not exceed 200 characters.'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND LENGTH (T0."U_WRNTY") > 200  and T0."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'The Delivery  of the sales quotation should not exceed 200 characters.'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

*/
--Down payment without PO-----
Cnt1:=0;
if :object_type='204' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODPO T0 inner join DPO1 T1 on T0."DocEntry"=T1."DocEntry"
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND T1."BaseType"<>'22';    
     if :Cnt1 > 0 then
error := 12311;
error_message := 'PO Should be mandatory for Downpaymnet'  ;
end if;                        
end if; 

--------------------------------------------------------------------------------------
/*
Cnt1:=0;
if :object_type ='2' and (:transaction_type ='A'  OR :transaction_type ='U') then 
SELECT COUNT (*) into Cnt1  FROM OCRD T0  INNER JOIN OCPR T1 ON T0."CardCode" = T1."CardCode"
Where T0."CardCode" = :list_of_cols_val_tab_del AND
 "CardType"='S' AND( CONTAINS("E_MailL", '[ &'',":;!+=\/()<>]') 
  OR CONTAINS("E_MailL", '[@.-_].*')  -- Valid but cannot be starting character
  OR CONTAINS("E_MailL", '.*[@.-_]$')  -- Valid but cannot be ending character
  OR "E_MailL" NOT LIKE '%@%.%'  -- Must contain at least one @ and one .
  OR "E_MailL" LIKE '%..%'  -- Cannot have two periods in a row
  OR "E_MailL" LIKE '%@%@%'  -- Cannot have two @ anywhere
  OR "E_MailL" LIKE '%.@%' OR "E_MailL" LIKE '%@.%' -- Can't have @ and . next to each other
  OR "E_MailL" LIKE '%.cm' OR "E_MailL" LIKE '%.co' -- Unlikely. Probably typos 
 OR "E_MailL" LIKE '%.or' OR "E_MailL" LIKE '%.ne'); -- Missing last letter

 if :Cnt1 >0 then 
  error := 114;
  error_message := 'Please Enter Proper Email Id' ;
 end if;							
end if;
-------------------------------------------------------------------------------------------------------------
--DECLARE Cnt1 INTEGER := 0;
/*IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN 
    SELECT COUNT(*) INTO Cnt1 
    FROM OCRD T0  
    INNER JOIN OCPR T1 ON T0."CardCode" = T1."CardCode"
    WHERE T0."CardCode" = :list_of_cols_val_tab_del 
    AND T0."CardType" = 'S' 
    AND (
        REGEXP_LIKE(T1."E_MailL", '[ &''":;!+=\\\/()<>]') 
        OR REGEXP_LIKE(T1."E_MailL", '^[.@-_]')
        OR REGEXP_LIKE(T1."E_MailL", '[@._-]$')
        OR NOT REGEXP_LIKE(T1."E_MailL", '@.+\..+')
        OR REGEXP_LIKE(T1."E_MailL", '\.\.')
        OR REGEXP_LIKE(T1."E_MailL", '@.*@')
        OR REGEXP_LIKE(T1."E_MailL", '@\.|\.@')
        OR T1."E_MailL" LIKE '%.cm' 
        OR T1."E_MailL" LIKE '%.co' 
        OR T1."E_MailL" LIKE '%.or' 
        OR T1."E_MailL" LIKE '%.ne'
    );
    IF :Cnt1 > 0 THEN 
        error := 114;
        error_message := 'Please Enter Proper Email Id';
    END IF;
END IF;


---------------------------------------------------------------------------------------------------
IF object_type = '2' AND (transaction_type = 'A' OR transaction_type = 'U') THEN 
    SELECT COUNT(*) INTO Cnt1 
    FROM OCRD T0  
    INNER JOIN OCPR T1 ON T0."CardCode" = T1."CardCode"
    WHERE T0."CardCode" = list_of_cols_val_tab_del 
    AND T0."CardType" = 'S' 
    AND (
        -- Invalid characters in the email
        T1."E_MailL" LIKE '%[ &''":;!+=\\\/()<>]%' OR

        -- Invalid starting characters
        T1."E_MailL" LIKE '%.%' OR
        T1."E_MailL" LIKE '%@%' OR
        T1."E_MailL" LIKE '%-%' OR
        T1."E_MailL" LIKE '%_%' OR

        -- Invalid ending characters
        T1."E_MailL" LIKE '%.%' OR
        T1."E_MailL" LIKE '%@%' OR
        T1."E_MailL" LIKE '%-%' OR
        T1."E_MailL" LIKE '%_%' OR

        -- Must contain at least one @ and one .
        T1."E_MailL" NOT LIKE '%@%.%' OR

        -- Cannot have two periods in a row
        T1."E_MailL" LIKE '%.%' OR

        -- Cannot have two @ symbols
        T1."E_MailL" LIKE '%@%@%' OR

        -- Can't have @ and . next to each other
        T1."E_MailL" LIKE '%@.%' OR
        T1."E_MailL" LIKE '%.@%' OR

        -- Check for common typo domains
        T1."E_MailL" LIKE '%.cm' OR
        T1."E_MailL" LIKE '%.co' OR
        T1."E_MailL" LIKE '%.or' OR
        T1."E_MailL" LIKE '%.ne'
    );
    
    IF Cnt1 > 0 THEN 
        error := 114;
        error_message := 'Please Enter Proper Email Id';
    END IF;
END IF;*/
-------------------------------------------------------------------------------------------
--DECLARE @Cnt1 INT;
--SET @
Cnt1 = 0;

IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    SELECT COUNT(*)
    INTO Cnt1
    FROM OCRD T0
    INNER JOIN OCPR T1 ON T0."CardCode" = T1."CardCode"
    WHERE T0."CardCode" = :list_of_cols_val_tab_del
      AND T0."CardType" = 'S' 
      and ifnull("E_MailL",'')<>''
      AND (
           -- Basic validation: Check for invalid characters and patterns
          "E_MailL" LIKE '%[&'',":;!+=\/()<>]%' 
          ESCAPE 2  -- Invalid characters
           OR "E_MailL" LIKE '[@.-_]%@%'  -- Must contain one @ and cannot start with special characters
           OR "E_MailL" LIKE '%@%[.-_]%'  -- Must contain one @ and cannot end with special characters
           OR "E_MailL" NOT LIKE '%@%.%'  -- Must contain at least one @ and one .
           OR "E_MailL" LIKE '%..%'  -- Cannot have two periods in a row
           OR "E_MailL" LIKE '%@%@%'  -- Cannot have two @ symbols
           OR "E_MailL" LIKE '%@.%'  -- Cannot have @ followed directly by .
           OR "E_MailL" LIKE '%.@%'  -- Cannot have . followed directly by @
           OR "E_MailL" LIKE '%[.][cm|co|or|ne]'  -- Unlikely domains
          );

    IF Cnt1 > 0 THEN
        error := 114;
        error_message := 'Please Enter Proper Email Id';
    END IF;
END IF;

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then

 

Select Count(*) into Cnt1 from  OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and IFNULL(T0."CntctCode",0) =0 and T0."CANCELED"='N' ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out  Contact Person'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and   IFNULL(T0."CntctCode",0) =0 and T0."CANCELED"='N' and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Contact Person'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
/* Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then

SELECT count(T2."trgtPath" ||'\'|| T2."FileName"||'.'|| T2."FileExt")  into Cnt1 
 FROM "OQUT" T0 INNER JOIN "OATC" T1 ON T0."AtcEntry"=T1."AbsEntry" 
INNER JOIN "ATC1" T2 ON T2."AbsEntry"=T1."AbsEntry" 
where T0."DocEntry"=:list_of_cols_val_tab_del;

IF Cnt1 =0 THEN
error := 12658300;
error_message := ' Atleast 1 is Attachment Mandatory'  ;
end if;                        
end if; */

Cnt1:=0;

if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then

SELECT count(*)  into Cnt1 
 FROM "OQUT" T0 
where T0."DocEntry"=:list_of_cols_val_tab_del  and T0."AtcEntry" is null;  
IF :Cnt1 >0 THEN
error := 1283001;
error_message := ' Atleast 1 is Attachment Mandatory'  ;
end if;  
end if;   
---------------------------------------------------------------------------------------------------------------------------
/* Cnt1:=0;
Line:=0;  
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then

SELECT count(*)  into Line FROM "ODRF" T0 where T0."DocEntry"=:list_of_cols_val_tab_del and T0."ObjType"='23';  
if Line>1 then
SELECT count(T2."trgtPath" ||'\'|| T2."FileName"||'.'|| T2."FileExt")  into Cnt1 
 FROM "ODRF" T0 INNER JOIN "OATC" T1 ON T0."AtcEntry"=T1."AbsEntry" 
INNER JOIN "ATC1" T2 ON T2."AbsEntry"=T1."AbsEntry" 
where T0."DocEntry"=:list_of_cols_val_tab_del and T0."ObjType"='23';  
IF Cnt1 =0 THEN
error := 128300;
error_message := ' Atleast 1 is Attachment Mandatory'  ;
end if;  
end if;                        
end if; */

Cnt1:=0;

if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then

SELECT count(*)  into Cnt1 
 FROM "ODRF" T0 
where T0."DocEntry"=:list_of_cols_val_tab_del and T0."ObjType"='23' and T0."AtcEntry" is null;  
IF :Cnt1 >0 THEN
error := 128300;
error_message := ' Atleast 1 is Attachment Mandatory'  ;
end if;  
end if;                        


---------------------------------------------------------------------------------------------

Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Location",'')=''  ;    
     if :Cnt1 > 0 then
error := 123070;
error_message := 'Sales Quotation Cannot be added with out Location'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Location",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 126300;
error_message := 'Sales Quotation Cannot be added with out Location'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_WORKORDER",'')=''  ;    
     if :Cnt1 > 0 then
error := 1230900;
error_message := 'Sales Quotation Cannot be added with out Work Order Number'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0  inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_WORKORDER",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 123080;
error_message := 'Sales Quotation Cannot be added with out Work Order Number'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  T0."U_WRNTY" IS Null  ;    
     if :Cnt1 > 0 then
error := 12365400;
error_message := 'Sales Quotation Cannot be added with out Delivery'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  T0."U_WRNTY" IS Null   and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 1236500;
error_message := 'Sales Quotation Cannot be added with out Delivery'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."GroupNum",0)=0  ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Payment Terms'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."GroupNum",0)= 0  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Payment Terms'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_SQTYPE",'')=''  ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out Department'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_SQTYPE",'')=''  and T0."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Sales Quotation Cannot be added with out  Department'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Division",'')='' ;    
     if :Cnt1 > 0 then
error := 123110;
error_message := 'Sales Quotation Cannot be added with out Division'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 inner join DRF1 T1 on T0."DocEntry"= T1."DocEntry"
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Division",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 123110;
error_message := 'Sales Quotation Cannot be added with out Division'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND LENGTH (T0."U_CMNT") > 200   ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'The subject of the sales quotation should not exceed 200 characters.'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND LENGTH (T0."U_CMNT") > 200  and T0."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'The subject of the sales quotation should not exceed 200 characters.'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then
 

Select Count(*) into Cnt1 from OQUT T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND LENGTH (T0."U_WRNTY") > 200   ;    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'The Delivery  of the sales quotation should not exceed 200 characters.'  ;
end if;                        
end if; 
----------------------------------------------------------------------------------------------------------------
Cnt1:=0;
if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then 

Select Count(*) into Cnt1 from ODRF T0 WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
AND LENGTH (T0."U_WRNTY") > 200  and T0."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'The Delivery  of the sales quotation should not exceed 200 characters.'  ;
end if;                        
end if; 
---------------------------------------------------------------------------------------------------------------------------
if :object_type='23' and (:transaction_type ='A'  OR :transaction_type ='U') then

Select Count(*) into Cnt1 from QUT1 T0  INNER JOIN OQUT T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Group",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Group selection is mandatory'  ;
end if;                        
end if; 

if :object_type='112' and (:transaction_type ='A'  OR :transaction_type ='U') then

Select Count(*) into Cnt1 from DRF1 T0  INNER JOIN ODRF T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocEntry"= :list_of_cols_val_tab_del 
and  ifnull(T0."U_Group",'')=''  and T1."ObjType"='23';    
     if :Cnt1 > 0 then
error := 12300;
error_message := 'Group selection is mandatory'  ;
end if;                        
end if;

-- Select the return values
select :error, :error_message FROM dummy;


end;