


SELECT DISTINCT T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T0."DocStatus", T0."U_DEPARTMENTT",
T0."U_Division" as "Project/Contracts",
T0."U_Contract" as "Div/Dist",
T0."U_CATEGORY",
T0."U_TYPE",T0."DocType", T0."CANCELED", T0."DocTotal", T0."VatSum", T1."BaseRef", T2."DocNum" as "OP Number", T2."DocDate", T2."DocStatus", T2."DocType", T2."CANCELED", T2."DocTotal" FROM OPDN T0  INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN OPOR T2 ON INT(T2."DocNum") = INT(T1."BaseRef") --WHERE ---T0."DocDate" >=[%0]



SELECT
    DISTINCT
    T0."DocNum" AS "Document Number",
    T0."DocType" AS "Document Type",
    T0."DocStatus" AS "Document Status",
    T0."DocTotal" AS "Total",
    T2."RefDocNum" AS "Referenced Document Number",
    T4."DocNum" AS "Purchase Order



    SELECT
    DISTINCT
    T0."DocNum" AS "Document Number",
T0."U_DEPARTMENTT",
T0."U_Division" as "Project/Contracts",
T0."U_Contract" as "Div/Dist",
T0."U_CATEGORY",
T0."U_TYPE",
    T0."DocType" AS "Document Type",
    T0."DocStatus" AS "Document Statu