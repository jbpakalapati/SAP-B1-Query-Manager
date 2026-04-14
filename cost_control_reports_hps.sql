-- All Transctions GL COS ( Cost of Sales)

SELECT T0."RefDate",
YEAR(T0."RefDate" ) AS "Year", 
month(T0."RefDate" ) as "Month",
T0."TransId", T0."Number" as "Journal Document No", 
CASE WHEN T0."TransType" = '-2' THEN 'Opening Balance'WHEN T0."TransType" = '13' 
THEN 'AR Invoice'WHEN T0."TransType" = '14' THEN 'AR Credit Memo'WHEN T0."TransType" = '15' 
THEN 'Delivery'WHEN T0."TransType" = '16' THEN 'Return'WHEN T0."TransType" = '18' 
THEN 'AP Invoice'WHEN T0."TransType" = '19' THEN 'AP Credit Memo'WHEN T0."TransType" = '20' 
THEN 'Goods Receipt PO'WHEN T0."TransType" = '202' THEN 'Production Order'WHEN T0."TransType" = '21' 
THEN 'Goods Return'WHEN T0."TransType" = '24' THEN 'Incoming Payments'WHEN T0."TransType" = '30' 
THEN 'Journal Entry'WHEN T0."TransType" = '46' THEN 'Outgoing Payments'WHEN T0."TransType" = '58' 
THEN 'Stock Posting'WHEN T0."TransType" = '59' THEN 'Goods Receipt/Receipt from production'WHEN T0."TransType" = '60'
THEN 'Goods Issue/Issue from Production' WHEN T0."TransType" = '67' THEN 'InventoryTransfer'WHEN T0."TransType" = '69' 
THEN 'Landed Costs'WHEN T0."TransType" = '162' THEN 'Inventory Revaluation'WHEN T0."TransType" = '140000009' 
THEN 'Outgoing Excise Invoice'WHEN T0."TransType" = '140000010' THEN 'Incoming Excise Invoice' 
WHEN T0."TransType" = '204' THEN 'A/P Downpayment Invoice' WHEN T0."TransType" = '203' THEN 'A/R Downpayment Invoice' 
ELSE 'NULLVALUE' END AS "Transaction Type" ,T0."BaseRef" as "Document Num", T0."Ref1", T0."Ref2", T0."Memo", T1."Account",
case when T1."ShortName"=T2."AcctCode" then T2."AcctName" else (Select "CardName" from OCRD where "CardCode"
=T1."ShortName") end as 
"AcctName", 
T1."ShortName",  
T1."Project",
(SELECT div."PrjName" FROM OPRJ div WHERE div."PrjCode" = T1."Project") as "Project/Contract Name",
T1."ProfitCode",
(SELECT cc."PrcName" FROM OPRC cc WHERE cc."PrcCode" = T1."ProfitCode") as "Div/Dist Name",
T1."Debit", T1."Credit", T1."LineMemo" as "Line Remarks" ,case when T1."MthDate" is not null then 'Reconciled' else 'Un Reconciled' end as "Reconciled/Un Reconciled"

FROM 
OJDT T0  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" 
INNER JOIN OACT T2 ON T1."Account" = T2."AcctCode"
Where T0."RefDate" Between '[%2]' and '[%3]' and T1."Account" like '5010000%'

order by  T0."TransId",T0."RefDate"


