SELECT DISTINCT
	PR."DocNum" AS "PR Doc Number",
	PR."DocDate",
             PR."DocTotal",

	PO."DocNum" AS "PO Doc Number",
	PO."DocDate", PO."DocTotal",
	PO."CardCode" AS "Vendor Code",
	PO."CardName" as "Vendor Name",
    PO."Comments" as "Remarks",
    PO."U_SalesQuoteRef",
PO."U_DEPARTMENTT",
PO."U_Division" as "Projects/Contracts",
(SELECT div."PrjName" FROM OPRJ div WHERE div."PrjCode" =  PO."U_Division") as "Project/Contract Name",
PO."U_Contract" as "Div/Dist",
(SELECT cc."PrcName" FROM OPRC cc WHERE cc."PrcCode" = PO."U_Contract") as "Div/Dist Name",
PO."U_CATEGORY",
PO."U_TYPE",
	S."SlpName" AS "Buyer",
	G."DocNum" AS "GR Doc Number",
             G."DocTotal",
	G."DocDate" AS "GR Posting Date",
	G."DocDueDate" AS "GR DueDate",
	YEAR(G."DocDate") AS "GR Year",
	G."NumAtCard" AS "Delivery Note Reference",
    G."Comments" as "Remarks",
	OU."U_NAME" AS "GR Created By",
	OU."USER_CODE",
	IV."BaseType",
	IV."DocNum" AS "Inv Doc Number",
	IV."DocDate" AS "Inv Date",
	IV."NumAtCard" AS "Inv Ref No.",
    IV."Comments" as "Remarks"

 FROM OPRQ PR
LEFT JOIN PRQ1 PR1 on PR."DocEntry"=PR1."DocEntry"
LEFT JOIN POR1 P1 on P1."BaseEntry"=PR1."DocEntry"
AND P1."BaseType" = PR."ObjType"
AND P1."BaseLine" = PR1."LineNum"
LEFT JOIN OPOR PO on PO."DocEntry"=P1."DocEntry"
LEFT JOIN PDN1 G1 ON G1."BaseEntry" = P1."DocEntry"
AND G1."BaseType" = PO."ObjType"
AND G1."BaseLine" = P1."LineNum"
LEFT JOIN OPDN G ON G."DocEntry" = G1."DocEntry"
LEFT JOIN PCH1 IV1 ON IV1."BaseEntry" = G1."DocEntry"
AND IV1."BaseType" = G1."ObjType"
AND IV1."BaseLine" = G1."LineNum"
LEFT JOIN OPCH IV ON IV."DocEntry" = IV1."DocEntry"
LEFT JOIN OWHS W ON P1."WhsCode" = W."WhsCode"
LEFT JOIN OSLP S ON PO."SlpCode" = S."SlpCode"
LEFT JOIN OUSR OU ON G."UserSign" = OU."USERID"
WHERE 
PR."U_Division"  =[%2] 


---And PR."DocStatus" Not In ('N') And PO."DocStatus" Not In ('N') And G."DocStatus" Not In ('N')
ORDER BY PR."DocNum", G."DocNum", IV."DocNum"