     -----------------You can not create Duplicate LPO with same PR---------------------------------------
Cnt1:=0;
							
   if :object_type='22' and (:transaction_type ='A'  OR :transaction_type ='U') then							
							
    /*  Select Count(*) into Cnt1 from POR1 T0 Inner Join OPOR T1 On T0."DocEntry"=T1."DocEntry" 
            WHERE T1."CANCELED"='N' GROUP BY T0."BaseType" HAVING COUNT(*)>1;							
 							*/
 		  /*Select Count(*) into Cnt1 from DRF1 T0 Inner Join ODRF T1 On T0."DocEntry"=T1."DocEntry" 
           where T1."CANCELED"='N' and T1."ObjType"='22' GROUP BY T0."BaseDocNum" HAVING COUNT(*)>1;							
 			
 			*/
 			
 	SELECT Count(*)into Cnt1 FROM ODRF T0 
 		WHERE  T0."ObjType" = '22' 
          and  T0."DocTotal" = (Select T2."DocTotal"  from ODRF T2 Where T2."DocEntry" =:list_of_cols_val_tab_del and T2."ObjType" = '22') 
          and T0."WddStatus" IN ('W', 'Y');
     
      if :Cnt1>0 then	
	    error := -20390;							
            error_message := 'You can not create Duplicate LPO with Same PR';							
      end if;							
 end if;
 