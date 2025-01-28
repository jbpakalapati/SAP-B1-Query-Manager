SELECT distinct 
h."NumAtCard" as "Quote No", 
--h."SlpCode",
I."SlpName" as "Requester" ,
 h."CardCode" As "Client Code", h."CardName" as "Client Name", h."DocTotal", h."U_WORKORDER" as "FSI NO", h."DocNum" as "Quotation No",h."DocDate" as "Quotatoon Date",
f."DocNum" as "Sales Order No",f."DocDate" as "Order Date",
d."DocNum" as "Delivery No",d."DocDate" as "Delivery Date",
a."DocNum" as "Invoice No",a."DocDate" as "Invoice Date"
 

from OINV a inner join INV1 b on a."DocEntry"=b."DocEntry"
left join DLN1 c on c."DocEntry"=b."BaseEntry" and c."LineNum"=b."BaseLine"
inner join ODLN d on c."DocEntry"=d."DocEntry"
left join RDR1 e on e."DocEntry"=c."BaseEntry" and e."LineNum"=c."BaseLine"
inner join ORDR f on e."DocEntry"=f."DocEntry"
left join QUT1 g on g."DocEntry"=e."BaseEntry" and g."LineNum"=e."BaseLine"
inner join OQUT h on g."DocEntry"=h."DocEntry"
INNER JOIN OSLP I ON h."SlpCode" = I."SlpCode"
where h."DocDate">=[%1] and h."DocDate"<=[%2] 
order by a."DocDate"