

/*Convert Amount to text
*/

If {Command.DocCur}= {OADM.MainCurncy}
and propercase(ToWords (tonumber(mid(Cstr({Command.DocTotal}),Instr(Cstr({Command.DocTotal}),".",1)+1,len(Cstr({Command.DocTotal})))),0))<>"Zero" then
    {Command.CurrName}&" "& propercase(towords(tonumber(mid(Cstr({Command.DocTotal}),1,Instr(Cstr({Command.DocTotal}),".",1)-1)),0)) + " and " + 
    propercase(ToWords (tonumber(mid(Cstr({Command.DocTotal}),Instr(Cstr({Command.DocTotal}),".",1)+1,len(Cstr({Command.DocTotal})))),0)) &" "&{Command.F100Name}

Else If {Command.DocCur}={OADM.MainCurncy} and propercase(ToWords (tonumber(mid(Cstr({Command.DocTotal}),
Instr(Cstr({Command.DocTotal}),".",1)+1,len(Cstr({Command.DocTotal})))),0))="Zero" then
    {Command.CurrName}&" "& propercase(towords(tonumber(mid(Cstr({Command.DocTotal}),1,Instr(Cstr({Command.DocTotal}),".",1)-1)),0)) 

Else If {Command.DocCur}<>{OADM.MainCurncy} and propercase(ToWords (tonumber(mid(Cstr({Command.DocTotalFC}),
Instr(Cstr({Command.DocTotalFC}),".",1)+1,len(Cstr({Command.DocTotalFC})))),0))="Zero" then
    {Command.CurrName}&" "& propercase(towords(tonumber(mid(Cstr({Command.DocTotalFC}),1,Instr(Cstr({Command.DocTotalFC}),".",1)-1)),0)) 

Else If {Command.DocCur}<>{OADM.MainCurncy} and propercase(ToWords (tonumber(mid(Cstr({Command.DocTotalFC}),
Instr(Cstr({Command.DocTotalFC}),".",1)+1,len(Cstr({Command.DocTotalFC})))),0))<>"Zero" then
    {Command.CurrName}&" "& propercase(towords(tonumber(mid(Cstr({Command.DocTotalFC}),1,
Instr(Cstr({Command.DocTotalFC}),".",1)-1)),0)) + " and " + 
propercase(ToWords (tonumber(mid(Cstr({Command.DocTotalFC}),Instr(Cstr({Command.DocTotalFC}),".",1)+1,len(Cstr({Command.DocTotalFC})))),0)) &" "&{Command.F100Name}



--Simple Line

'AED ' + ProperCase( ToWords({@TotalInvoiceAmount}, 0))+ ' only.'

---------------------------------------
--Added this Line to get Fills also.

" AED "+ propercase(towords(tonumber(mid(Cstr({@TotalInvoiceAmount}),1,
Instr(Cstr({@TotalInvoiceAmount}),".",1)-1)),0))+ " and " + 
propercase(ToWords (tonumber(mid(Cstr({@TotalInvoiceAmount}),Instr(Cstr({@TotalInvoiceAmount}),".",1)+1,len(Cstr({@TotalInvoiceAmount})))),0))+ " Fills Only"

--Result : 18479.72
 AED Eighteen Thousand Four Hundred Seventy-Nine and Seventy-Two Fills Only

