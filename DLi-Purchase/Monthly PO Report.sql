SELECT T0."DocDate" as "Date",T1."SeriesName" || '-'||T0."DocNum" as "LPO No.", T0."CardName" as "Vendor", CASE WHEN T0."DocCur"<>'AED' then T0."DocTotalFC" else T0."DocTotal" end as "LPO Amount", T0."U_Savings" as "Savings",'' as "Category" FROM OPOR T0
inner join NNM1 T1 ON T0."Series"=T1."Series"

WHERE (T0."DocDate" >=[%0] OR [%0]='')AND (T0."DocDate" <=[%1] OR [%1]='')
ORDER BY T0."DocDate"