global with sharing class FinancialTransactionPopulationMethods
{
    /*
Case 00001862 26/04/2011 : Junction object will update as much information on
Opportunity/ Opportunity Lines/ Event Booking and Subscriptions
*/
    
    public static void populateFinancialObjectFromCN(Map<id,c2g__codaCreditNote__c> cn)
    {
        Set<Id> invSet = new Set<Id>();
        for(c2g__codaCreditNote__c c:cn.Values())
        {
            if(c.c2g__CreditNoteStatus__c=='Complete')
                invSet.add(c.c2g__Invoice__c);
        }
        if(invSet.size()>0)
        {
            Map<Id,c2g__codaInvoice__c> inv = new Map<Id,c2g__codaInvoice__c>([Select Id From c2g__codaInvoice__c Where Id IN :invSet]);
            // populateFinancialObject(inv);
            if(inv.size()>0)
                FinancialTransactionPopulationMethods.populateFinancialJunctionObject(inv.KeySet());
        }
    }
    
    //@future
    public static void cashMatching(Set<Id> cshmch)
    {
        List<String> invList = new List<String>();
        List<c2g__codaCashMatchingHistory__c> invListDesc = [Select c2g__TransactionLineItem__r.c2g__LineDescription__c, c2g__TransactionLineItem__r.c2g__lineReference__c From c2g__codaCashMatchingHistory__c Where c2g__matchingreference__c IN :cshmch and (c2g__TransactionLineItem__r.c2g__LineDescription__c Like '%SIN%' or c2g__TransactionLineItem__r.c2g__lineReference__c Like '%SIN%')];
        if(invListDesc.size()>0)
            for(c2g__codaCashMatchingHistory__c inv: invListDesc)
        {
            // if(inv.c2g__TransactionLineItem__r.c2g__LineDescription__c.length()>0)
            if(inv.c2g__TransactionLineItem__r.c2g__LineDescription__c!=Null)
            {
                Integer pos = inv.c2g__TransactionLineItem__r.c2g__LineDescription__c.indexOf('SIN',0);
                System.debug('**pos:'+pos);
                if(pos<>-1)
                {
                    String invNum = inv.c2g__TransactionLineItem__r.c2g__LineDescription__c.substring(pos);
                    if(invNum<>Null)
                        invList.add(invNum);
                }
            }
            else
                // if(inv.c2g__TransactionLineItem__r.c2g__lineReference__c.length()>0)
                if(inv.c2g__TransactionLineItem__r.c2g__lineReference__c!=Null)
            {
                Integer pos = inv.c2g__TransactionLineItem__r.c2g__lineReference__c.indexOf('SIN',0);
                if(pos<>-1)
                    invList.add(inv.c2g__TransactionLineItem__r.c2g__lineReference__c);
            }
        }
        if(invList.size()>0)
        {
            Map<Id,c2g__codaInvoice__c> invId = new Map<Id, c2g__codaInvoice__c>([Select Id From c2g__codaInvoice__c Where name in :invList]);
            /*if(invId.Size()>0)
update invId.Values();*/
            if(invId.size()>0)
                populateFinancialJunctionObject(invId.KeySet());
            
        }  
    }
    
    /*@future    
public static void creditNoteMatch(Set<Id> tlId)
{
List<String> invList = new List<String>(); 
System.debug('****************ENTRY**********');
List<c2g__codaTransactionLineItem__c> tl = [Select c2g__MatchingStatus__c, c2g__LineDescription__c, c2g__transaction__c From c2g__codaTransactionLineItem__c Where id in :tlId];
Set<Id> transId = new Set<Id>();
for(c2g__codaTransactionLineItem__c t:tl)
{
transId.add(t.c2g__transaction__c);
}
Map<Id,c2g__codaTransaction__c> ctMap = new Map<Id,c2g__codaTransaction__c>([Select c2g__transactionType__c From c2g__codaTransaction__c Where id IN :transId]); 
for(c2g__codaTransactionLineItem__c ctl : tl)
{
//system.debug('***'+ctl.c2g__LineDescription__c+' ***document '+ctl.c2g__Transaction__r.c2g__documentNumber__c.substring(0,3));
if(ctl.c2g__MatchingStatus__c=='Matched'&&ctMap.get(ctl.c2g__Transaction__c).c2g__transactionType__c=='Credit Note') // ctl.c2g__Transaction__r.c2g__documentNumber__c.substring(0,3)=='SCR'
{
Integer pos = ctl.c2g__LineDescription__c.indexOf('SIN',0);
System.debug('**pos:'+pos);
if(pos<>-1)
{
String invNum = ctl.c2g__LineDescription__c.substring(pos);
if(invNum<>Null)
invList.add(invNum);
}
//if(ctl.c2g__Transaction__r.c2g__DocumentNumber__c!=Null&&ctl.c2g__Transaction__r.c2g__DocumentNumber__c.Substring(1,3)=='SIN')
//{
//  invList.add(ctl.c2g__Transaction__r.c2g__DocumentNumber__c);
//}

}
}
if(!invList.isEmpty())
{
System.debug('****************List is not empty**********');
Map<Id,c2g__codaInvoice__c> invId = new Map<Id, c2g__codaInvoice__c>([Select Id From c2g__codaInvoice__c Where name in :invList]);
if(invId.size()>0)
populateFinancialJunctionObject(invId.KeySet());
}
}*/
    
    
    public static void creditNoteMatch(List<c2g__codaTransactionLineItem__c> tl)
    {
        List<String> invList = new List<String>(); 
        System.debug('****************ENTRY**********');
        Set<Id> transId = new Set<Id>();
        for(c2g__codaTransactionLineItem__c t:tl)
        {
            if(t.c2g__LineDescription__c!=Null&&t.c2g__MatchingStatus__c=='Matched')
                transId.add(t.c2g__transaction__c);
        }
        Map<Id,c2g__codaTransaction__c> ctMap = new Map<Id,c2g__codaTransaction__c>([Select c2g__transactionType__c From c2g__codaTransaction__c Where id IN :transId]);
        if (ctMap.size()>0) 
            for(c2g__codaTransactionLineItem__c ctl : tl)
        {
            if(ctl.c2g__MatchingStatus__c=='Matched'&&ctl.c2g__LineDescription__c!=Null&&ctMap.get(ctl.c2g__Transaction__c).c2g__transactionType__c=='Credit Note') // ctl.c2g__Transaction__r.c2g__documentNumber__c.substring(0,3)=='SCR'
            {
                Integer pos = ctl.c2g__LineDescription__c.indexOf('SIN',0);
                System.debug('**pos:'+pos);
                if(pos<>-1)
                {
                    String invNum = ctl.c2g__LineDescription__c.substring(pos);
                    if(invNum<>Null)
                        invList.add(invNum);
                }        
            }
        }
        if(!invList.isEmpty())
        {
            System.debug('****************List is not empty**********');
            Map<Id,c2g__codaInvoice__c> invId = new Map<Id, c2g__codaInvoice__c>([Select Id From c2g__codaInvoice__c Where name in :invList]);
            if(invId.size()>0)
                populateFinancialJunctionObject(invId.KeySet());
        }
    }
    
    /*
* Runs the financial junction object code on an individual invoice
* 
*/
    webservice public static void populateFinancialJunctionObject(Id ffInvId)
    {
        Set<Id> ffInvIds = new Set<Id>();
        ffInvIds.add(ffInvId);
        populateFinancialJunctionObject(ffInvIds);
        
    }  
    //@future
    public static void populateFinancialJunctionObject(Set<Id> ffInvId)
    {
        try
        {
            List<Financial_Transactional_Line_Data__c> fld = [Select Id From Financial_Transactional_Line_Data__c Where Financial_Transactional_Header_Data__r.Sales_Invoice__c IN :ffInvId];
            if(fld.size()>0)
                delete fld;
            List<Financial_Transactional_Header_Data__c> flh = [Select Id From Financial_Transactional_Header_Data__c Where Sales_Invoice__c IN :ffInvId];
            if(flh.size()>0)
                delete flh;
        }
        catch(Exception d)
        {
            
        }
        
        List<c2g__codaInvoice__c> inv = [Select Id, c2g__transaction__c, c2g__PaymentStatus__c, c2g__InvoiceStatus__c, c2g__InvoiceDate__c, name, c2g__OutstandingValue__c   From c2g__codaInvoice__c Where Id IN :ffInvId and c2g__InvoiceStatus__c!='In Progress'];
        System.debug('############ Calling populateFinancialJunctionObject from FUTURE Call ##########'+inv);
        if(inv.size()>0)
            populateFinancialJunctionObject(inv);
    }
    
    /*
* Main method for creating the financial junction object records.
*
*/
    public static void populateFinancialJunctionObject(List<c2g__codaInvoice__c> ffInvoice)
    {
        // List<c2g__codaInvoice__c> ffInvoice = new List<c2g__codaInvoice__c>([Select c2g__PaymentStatus__c, c2g__InvoiceStatus__c, c2g__CustomerReference__c, c2g__transaction__c From c2g__codaInvoice__c]);
        // START: Get All credit notes for the invoices
        /*Map<Id,Id> allCreditNotes = new Map<Id,Id>();
for (c2g__codaCreditNote__c allCreditNote : [SELECT Id,
c2g__Invoice__r.Id
FROM 
c2g__codaCreditNote__c 
WHERE 
c2g__Invoice__c = :ffInvoice 
AND c2g__CreditNoteStatus__c = 'Complete'
AND c2g__Invoice__r.c2g__InvoiceStatus__c <>'In Progress']){
allCreditNotes.put(allCreditNote.c2g__Invoice__r.Id,allCreditNote.Id);
}*/
        // END: Get all credit notes for the invoices
        
        System.debug('*****************Retrieved all invoices***************');
        List<Financial_Transactional_Header_Data__c> fthd = [Select Id From Financial_Transactional_Header_Data__c Where Sales_Invoice__c IN :ffInvoice];
        if(fthd.size()==0)
        for (c2g__codaInvoice__c ffinv:ffInvoice)
        {
            if(ffinv.c2g__InvoiceStatus__c<>'In Progress')
            {
                //double paymentAmount;
                //double outstandingAmount;
                Date paymentDate;
                Financial_Transactional_Header_Data__c ft = new Financial_Transactional_Header_Data__c ();
                
                // Determine if there is a credit Note against the invoice
                c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
                try
                {
                    creditNote = [Select Id From c2g__codaCreditNote__c Where c2g__Invoice__c = :ffinv.Id and c2g__CreditNoteStatus__c = 'Complete' limit 1];
                    ft.Sales_Credit_Note__c =  creditNote.id;
                }
                catch(QueryException Q0)
                {
                    // There are no Credit Notes
                    creditNote = Null;
                }
                if(creditNote!=Null)
                {
                    c2g__codaTransaction__c creditTransact = new c2g__codaTransaction__c();
                    try
                    {
                        creditTransact = [Select c2g__DocumentTotal__c, c2g__DocumentOutstandingTotal__c, c2g__transactionType__c From c2g__codaTransaction__c Where c2g__documentreference__c = :ffinv.name and c2g__transactionType__c = 'Credit Note' Limit 1];
                    }
                    catch(QueryException cqe)
                    {    
                        creditTransact = Null;        
                    }
                    // Map<Id,c2g__codaTransactionLineItem__c> creditTL = new Map<Id,c2g__codaTransactionLineItem__c>([Select Id From c2g__codaTransactionLineItem__c Where c2g__transaction__c = :creditTransact.Id and c2g__MatchingStatus__c='Matched']);
                    Map<Id,c2g__codaTransactionLineItem__c> creditTL = new Map<Id,c2g__codaTransactionLineItem__c>([Select Id, c2g__MatchingStatus__c From c2g__codaTransactionLineItem__c Where c2g__transaction__c = :creditTransact.Id and c2g__MatchingStatus__c='Matched']);
                    for(c2g__codaTransactionLineItem__c a:creditTL.Values())
                    {
                        System.debug('***********************Credit Note Status:'+a.c2g__MatchingStatus__c);
                    }
                    // Determine if a Credit Match to the Invoice has taken place.
                    If(creditTL.size()>0)
                        try
                    {
                        System.debug('*************We have a credit Note**************** Now checking for a match:'+creditTL.KeySet());
                        c2g__codaCashMatchingHistory__c creditCashMatch = [Select c2g__MatchingDate__c From c2g__codaCashMatchingHistory__c Where c2g__TransactionLineItem__c IN :creditTL.KeySet() Limit 1];
                        // List<c2g__codaCashMatchingHistory__c> creditCashMatch = [Select c2g__MatchingDate__c From c2g__codaCashMatchingHistory__c Where c2g__TransactionLineItem__c IN :creditTL.KeySet()];
                        System.debug('***Match Date:'+creditCashMatch.c2g__MatchingDate__c);
                        if(creditCashMatch.c2g__MatchingDate__c!=Null)
                        {
                            ft.Sales_Credit_Note_Matched__c=True;
                        } 
                    }
                    catch(QueryException cmqe)
                    {
                    }
                }
                
                
                System.debug('*****************Retrieved credit note***************');
                try
                {
                    // List <c2g__codaTransaction__c> transact = new List <c2g__codaTransaction__c>();
                    c2g__codaTransaction__c transact = new c2g__codaTransaction__c();
                    // if(ffinv.c2g__transaction__c!=null&&ffinv.c2g__paymentStatus__c=='Paid'&&creditNote==Null)
                    if(ffinv.c2g__transaction__c!=null&&creditNote==Null)
                    {
                        
                        try
                        {
                            transact = [Select c2g__DocumentTotal__c, c2g__DocumentOutstandingTotal__c From c2g__codaTransaction__c Where id = :ffinv.c2g__transaction__c limit 1];
                            //transact = [Select c2g__DocumentTotal__c, c2g__DocumentOutstandingTotal__c, c2g__transactionType__c From c2g__codaTransaction__c Where c2g__documentreference__c = :ffinv.name and c2g__transactionType__c = 'Cash' Limit 1];
                            Map<Id,c2g__codaTransactionLineItem__c> transactionLine= new Map<Id,c2g__codaTransactionLineItem__c>();
                            if(ffinv.c2g__PaymentStatus__c=='Paid')
                            {
                                transactionLine= new Map<Id,c2g__codaTransactionLineItem__c>([Select Id From c2g__codaTransactionLineItem__c Where c2g__transaction__c = :ffinv.c2g__transaction__c and c2g__matchingStatus__c = 'Matched']);
                            }
                            else
                                if(ffinv.c2g__PaymentStatus__c=='Part Paid')
                            {
                                // Financial Force does not change the matching status for a Part Payment 
                                transactionLine= new Map<Id,c2g__codaTransactionLineItem__c>([Select Id From c2g__codaTransactionLineItem__c Where c2g__transaction__c = :ffinv.c2g__transaction__c and c2g__matchingStatus__c = 'Available']);
                            }
                            if(transactionLine.size()>0)
                                try
                            {
                                AggregateResult[] groupedResults  = [Select MAX(c2g__MatchingDate__c) matchDate From c2g__codaCashMatchingHistory__c Where c2g__TransactionLineItem__c IN :transactionLine.KeySet()];
                                Object maxDate = groupedResults[0].get('matchDate');
                                paymentDate = (date)maxDate;
                            }
                            catch(Exception m)
                            {
                                System.debug('************No Match');
                            }                
                            
                        }
                        catch(QueryException et)
                        {
                        }
                        
                        System.debug('After Paymentdate');
                    }
                    ft.Sales_Invoice__c=ffinv.id;
                    if(paymentDate==Null&&ffinv.c2g__PaymentStatus__c=='Paid')
                    {
                        ft.Payment_Status__c='UnPaid';
                    }
                    else
                    {
                        ft.Payment_Status__c=ffinv.c2g__PaymentStatus__c;
                    }
                    ft.Invoice_Status__c=ffinv.c2g__InvoiceStatus__c;
                    ft.Invoice_Reference__c=ffinv.name;
                    ft.Payment_Date__c=paymentDate;
                    ft.Invoice_Date__c = ffinv.c2g__InvoiceDate__c;
                    if(paymentDate<>NULL)
                    {
                        ft.Payment_Amount__c=transact.c2g__DocumentTotal__c-ffinv.c2g__OutstandingValue__c;
                    }
                    else
                    {
                        ft.Payment_Amount__c=0;
                    }
                    ft.Outstanding_Amount__c=transact.c2g__DocumentOutstandingTotal__c;
                    //                  ft.Sales_Credit_Note__c =  creditNote.id;                                                                                               
                    
                    insert ft;
                    System.debug('*****************Inserted Financial Header ***************');
                    List<c2g__codaInvoiceLineItem__c> invLines = new List<c2g__codaInvoiceLineItem__c>([Select   SL__c
                                                                                                                ,BEB__c
                                                                                                                ,OPL_Id__c
                                                                                                                ,c2g__Product__c
                                                                                                                ,c2g__Invoice__r.c2g__Account__r.Name
                                                                                                                ,BEB__r.Special_Event__r.EndDate__c
                                                                                                                ,BEB__r.Special_Event__r.StartDate__c
                                                                                                                ,c2g__Invoice__r.c2g__InvoiceDate__c
                                                                                                                ,c2g__Invoice__r.Name
                                                                                                                //,c2g__Invoice__r.c2g__Opportunity__r.Opportunity_Number__c 
                                                                                                                ,c2g__NetValue__c
                                                                                                                ,SL__r.Subscription__r.End_Date__c
                                                                                                                ,SL__r.Subscription__r.Product_Codes__c
                                                                                                                ,SL__r.Subscription__r.Name
                                                                                                                ,SL__r.Subscription__r.Start_Date__c
                                                                                                                ,SL__r.Subscription__r.Status__c
                                                                                                                ,SL__r.Subscription__r.Type__c
                                                                                                          From c2g__codaInvoiceLineItem__c
                                                                                                         Where c2g__Invoice__c = :ffinv.id]);
                    List<Financial_Transactional_Line_Data__c> fl = new List<Financial_Transactional_Line_Data__c> ();
                    
                    List<Id> oplIdList = new List<Id>();
                    
                    for (c2g__codaInvoiceLineItem__c invl: invLines)
                    {
                        Financial_Transactional_Line_Data__c fld = new Financial_Transactional_Line_Data__c();
                        
                        fld.Subscription_Line__c = invl.SL__c;
                        fld.Sales_Invoice_Line_Item__c = invl.id;
                        fld.Financial_Transactional_Header_Data__c = ft.id;
                        fld.BSC_Event_Booking__c = invl.BEB__c;
                        fld.OPL_ID__c = invl.OPL_ID__c;
                        fld.Product__c = invl.c2g__Product__c;
                        
                        fld.Account_Name_Holder__c = invl.c2g__Invoice__r.c2g__Account__r.Name;
                        fld.BSC_Event_End_Date_Holder__c = invl.BEB__r.Special_Event__r.EndDate__c;
                        fld.BSC_Event_Start_Date_Holder__c = invl.BEB__r.Special_Event__r.StartDate__c;
                        fld.Invoice_Date_Holder__c = invl.c2g__Invoice__r.c2g__InvoiceDate__c;
                        fld.Invoice_Number_Holder__c = invl.c2g__Invoice__r.Name;
                        //fld.Opportunity_Number_Holder__c = invl.c2g__Invoice__r.c2g__Opportunity__r.Opportunity_Number__c;

                        fld.Sales_invoice_Net_Line_amount_Holder__c = invl.c2g__NetValue__c;
                        fld.Subscription_End_Date_Holder__c = invl.SL__r.Subscription__r.End_Date__c;
                        fld.Subscription_Product_Codes_Holder__c = invl.SL__r.Subscription__r.Product_Codes__c;
                        fld.Subscription_Ref_Holder__c = invl.SL__r.Subscription__r.Name;
                        fld.Subscription_Start_Date_Holder__c = invl.SL__r.Subscription__r.Start_Date__c;
                        fld.Subscription_Status_Holder__c = invl.SL__r.Subscription__r.Status__c;
                        fld.Subscription_Type_Holder__c = invl.SL__r.Subscription__r.Type__c;
                              
                        fl.add(fld);
                        
                        id oplid = (id)fld.Opl_id__c;
                        oplIdList.add(oplid);
                    }
                    if (fl.size()>0)
                    {
                        insert fl;
                        System.debug('*****************Inserted Financial Line ***************');
                    }
                    // START: #OPT-633 fix
                    // Loop over OPL_ID field and cast to set of ID's
                    
                    // VS moved this to the loop above.
                    /*List<Id> oplIdList = new List<Id>();
                    for(Financial_Transactional_Line_Data__c fld:fl){
                        id oplid = (id)fld.Opl_id__c;
                        oplIdList.add(oplid);
                    }*/
                    
                    // Query all opl_id's to get into map to iterate later on
                    Map<Id, OpportunityLineItem> oplLineList = new Map<Id, OpportunityLineItem>();
                    
                    for (OpportunityLineItem opl : [Select Id, OpportunityId,Opportunity.Account.Name,Opportunity.Opportunity_Number__c,
                                                    Invoice_Date__c, 
                                                    Invoice_Paid_Date__c, 
                                                    Quantity_Credited__c, 
                                                    Quantity_Invoiced__c, 
                                                    Financial_Transactional_Line_Data__c 
                                                    From 
                                                    OpportunityLineItem 
                                                    Where 
                                                    id IN :oplIdList]){
                                                        oplLineList.put(opl.Id, opl);
                                                    }
                    // END: #OPT-633 fix

                    // Too many SOQL fix - Rahul Case 6605
                    Set<ID> sebIds = new Set<ID> ();
                    Set<ID> slIds = new Set<ID> ();
                    Set<ID> oppIds = new Set<ID> ();
                    
                    for(Financial_Transactional_Line_Data__c fld:fl)
                    {
                        sebIds.add(fld.BSC_Event_Booking__c);
                        slIds.add(fld.Subscription_Line__c);
                        oppIds.add(fld.Opportunity__c);
                    }
                    sebIds.remove(null);
                    system.debug('RSB List<ID> sebIds - ' + sebIds);
                    slIds.remove(null);
                    system.debug('RSB List<ID> slIds - ' + slIds);
                    oppIds.remove(null);
                    system.debug('RSB List<ID> oppIds - ' + oppIds);

                    Map<Id, Special_Event_Booking__c> mapSeb = new Map<Id, Special_Event_Booking__c> ([Select opl_id__c, Invoice_Status__c, Invoice_Date__c, Credited_Status__c From Special_Event_Booking__c Where Id = :sebIDs]);
                    system.debug('RSB Map<Id, Special_Event_Booking__c> mapSeb - ' + mapSeb);

                    Map<Id, Subscription_Line__c> mapSl = new Map<Id, Subscription_Line__c> ([Select opl_id__c, Invoice_Status__c, Invoice_Date__c, Credited_Status__c From Subscription_Line__c Where Id = :slIds]);
                    system.debug('RSB Map<Id, Subscription_Line__c> mapSl - ' + mapSl);

                    Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity> ([Select Invoice_Paid_Date__c, Is_Credited__c, Invoiced_Total__c From Opportunity Where Id=:oppIds]);
                    system.debug('RSB Map<Id, Opportunity> mapOpp - ' + mapOpp);
                    
                    // Too many SOQL fix - Rahul Case 6605
                    for(Financial_Transactional_Line_Data__c fld:fl)
                    {
                        If(fld.Opl_id__c!=null)
                        {
                            try
                            {
                                id oplid = (id)fld.Opl_id__c;        
                                
                                OpportunityLineItem opl = oplLineList.get(oplid);
                                fld.Opportunity__c = opl.OpportunityId;
                                fld.Opportunity_Account__c = opl.Opportunity.Account.Name;
                                fld.Opportunity_Number_Holder__c = opl.Opportunity.Opportunity_Number__c;
                                //fld.Product__c = opl.PricebookEntry.Product2Id;
                                opl.Financial_Transactional_Line_Data__c = fld.Id;
                                // Financial_Transactional_Header_Data__c ftHeader = [Select Invoice_Status__c, Invoice_Date__c, Payment_Date__c, Sales_Credit_Note__c From Financial_Transactional_Header_Data__c Where id=:fld.Financial_Transactional_Header_Data__c];
                                if(ft.Invoice_Date__c!=null)
                                {
                                    opl.Invoice_Date__c = ft.Invoice_Date__c;
                                }
                                if(ft.Payment_Date__c!=null)
                                {
                                    opl.Invoice_Paid_Date__c=ft.Payment_Date__c;
                                }
                                if(ft.Sales_Credit_Note__c!=null)
                                {
                                    opl.Quantity_Credited__c = opl.Quantity_Invoiced__c;
                                }
                                System.debug('*****************Updating Opportunity Lines ***************');
                                //update opl;
                                
                                try
                                {
                                    // Rahul Case 6605
                                    //Opportunity opport = [Select Invoice_Paid_Date__c, Is_Credited__c, Invoiced_Total__c From Opportunity Where Id=:fld.Opportunity__c Limit 1];
                                    Opportunity opport = mapOpp.get(fld.Opportunity__c);
                                    system.debug('RSB Opportunity opport - ' + opport);
                                    if(opport != null)
                                    {
                                        opport.Invoice_Paid_Date__c = ft.Payment_Date__c;
                                        if(ft.Sales_Credit_Note__c!=Null)
                                            opport.Is_Credited__c = True;
                                        //update opport;
                                    }
                                }
                                catch(QueryException q1)
                                {
                                }
                                
                                try
                                {
                                    // Rahul Case 6605
                                    //Special_Event_Booking__c seb = [Select opl_id__c, Invoice_Status__c, Invoice_Date__c, Credited_Status__c From Special_Event_Booking__c Where Id = :fld.BSC_Event_Booking__c];
                                    Special_Event_Booking__c seb = mapSeb.get(fld.BSC_Event_Booking__c);
                                    system.debug('RSB Special_Event_Booking__c seb - ' + seb);
                                    if(seb != null)
                                    {
                                        seb.Invoice_Status__c = ft.Invoice_Status__c;
                                        if(ft.Invoice_Date__c!=null&&ft.Invoice_Date__c!=seb.Invoice_Date__c)
                                        {
                                            seb.Invoice_Date__c = ft.Invoice_Date__c;
                                        }
                                        if(ft.Payment_Date__c!=null&&ft.Payment_Date__c!=seb.Invoice_Paid_Date__c)
                                        {
                                            seb.Invoice_Paid_Date__c=ft.Payment_Date__c;
                                        }
                                        if(seb.opl_id__c==null)
                                        {
                                            seb.opl_id__c=fld.OPL_ID__c;
                                        }
                                        if(ft.Sales_Credit_Note__c!=Null)
                                        {
                                            seb.Credited_Status__c=true;
                                        }

                                        //update seb;
                                    }
                                }
                                catch (QueryException Qseb)
                                {
                                    // Do nothing
                                }
                                
                                try
                                {
                                    // Rahul Case 6605
                                    //Subscription_Line__c sl = [Select opl_id__c, Invoice_Status__c, Invoice_Date__c, Credited_Status__c From Subscription_Line__c Where Id = :fld.Subscription_Line__c];
                                    Subscription_Line__c sl = mapSl.get(fld.Subscription_Line__c);
                                    system.debug('RSB Subscription_Line__c sl - ' + sl);
                                    if(sl != null)
                                    {
                                        sl.Invoice_Status__c = ft.Invoice_Status__c;
                                        if(ft.Invoice_Date__c!=null&&ft.Invoice_Date__c!=sl.Invoice_Date__c)
                                        {
                                            sl.Invoice_Date__c = ft.Invoice_Date__c;
                                        }
                                        if(ft.Payment_Date__c!=null&&ft.Payment_Date__c!=sl.Invoice_Paid_Date__c)
                                        {
                                            sl.Invoice_Paid_Date__c=ft.Payment_Date__c;
                                        }
                                        if(sl.opl_id__c==null)
                                        {
                                            sl.opl_id__c=fld.OPL_ID__c;
                                        }
                                        if(ft.Sales_Credit_Note__c!=Null)
                                        {
                                            sl.Credited_Status__c=true;
                                        }
                                        //update sl;
                                    }
                                }
                                catch (QueryException Qsub)
                                {
                                    // Do nothing
                                }
                                
                            }
                            catch(Exception e)
                            {
                                System.Debug('Error: '+ e );
                            }
                        } 
                    }
                    // Rahul Case 6605
                    update oplLineList.values();
                    update mapSeb.values();
                    update mapSl.values();
                    update mapOpp.values();
                    // Rahul Case 6605
                    
                    update fl;
                }
                catch (QueryException Q1)
                {
                    //Transaction missing
                }
            }
        }
    }

    // Testing all the methods above.
    public testmethod static void testFinancialTransaction()
    {
        // Rahul Case 6605 - Below query is changed to cover code in testing
        //List<c2g__codaInvoice__c>  inv = [Select Id, c2g__transaction__c, c2g__PaymentStatus__c, c2g__InvoiceStatus__c, c2g__InvoiceDate__c, name, c2g__OutstandingValue__c From c2g__codaInvoice__c where c2g__InvoiceStatus__c = 'Complete' and c2g__PaymentStatus__c = 'Paid' Limit 10];
        List<c2g__codaInvoice__c>  inv1 = [Select Id, c2g__transaction__c, c2g__PaymentStatus__c, c2g__InvoiceStatus__c, c2g__InvoiceDate__c, name, c2g__OutstandingValue__c From c2g__codaInvoice__c where c2g__InvoiceStatus__c = 'Complete' and c2g__PaymentStatus__c = 'Paid' and Id not in (Select Sales_Invoice__c From Financial_Transactional_Header_Data__c) Limit 1];
        FinancialTransactionPopulationMethods.populateFinancialJunctionObject(inv1);

        // Rahul Case 6605 - Below query is newly added to cover code in testing
        List<c2g__codaInvoice__c>  inv2 = [Select Id, c2g__transaction__c, c2g__PaymentStatus__c, c2g__InvoiceStatus__c, c2g__InvoiceDate__c, name, c2g__OutstandingValue__c From c2g__codaInvoice__c where c2g__InvoiceStatus__c = 'Complete' and c2g__PaymentStatus__c = 'Paid' and Id not in (Select Sales_Invoice__c From Financial_Transactional_Header_Data__c) and Id in (Select c2g__Invoice__c From c2g__codaCreditNote__c where c2g__CreditNoteStatus__c = 'Complete' and c2g__Invoice__c != null) Limit 1];
        FinancialTransactionPopulationMethods.populateFinancialJunctionObject(inv2);
    }

    public testmethod static void testFinancialTransactionCN()
    {
        MAP<Id,c2g__codaCreditNote__c> cre = new Map<Id,c2g__codaCreditNote__c>([Select c2g__creditNoteStatus__c, c2g__Invoice__c From c2g__codaCreditNote__c Where c2g__creditNoteStatus__c = 'Complete' Limit 2]);
        FinancialTransactionPopulationMethods.populateFinancialObjectFromCN(cre);
    }

    public testmethod static void testFinancialTransactionCM()
    {
        Account acc = new Account();
        acc.Name = 'The Company Inc Plc 3668923';
        acc.CurrencyIsoCode = 'GBP';
        acc.Active__c = True;
        acc.Principle_Address_ZIP_Postal_Code__c = 'SW20 999';
        acc.BillingPostalCode = 'SW20 999';
        insert acc;
        
        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        contact.LastName = 'Test';
        contact.FirstName = 'Account121';
        contact.Email = 'test@testaccount121.com';
        insert contact;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Qualifying';
        opp.CloseDate = System.today();
        opp.AccountId = acc.id;
        opp.Price_Approval_Given__c = true;
        insert opp;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = contact.id;
        oppContRole.OpportunityId = opp.id;
        oppContRole.IsPrimary = true;
        insert oppContRole;
        
        Product2 prod = new Product2();
        prod.Name = 'Test  Product';
        prod.ProductCode = 'TESTCODE1';
        prod.Duration__c='1 Year';
        prod.Subscription_Product__c = true;
        insert prod;
        
        //Pricebook2 stdPricebook = [Select Id From Pricebook2 Where IsStandard = true Limit 1];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 300;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.IsActive = true;
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 120;
        
        insert oli;
        
        Special_Event__c specialEvent1 = new Special_Event__c(
            Opportunity__c = opp.Id,
            Name = 'oppcont 1',
            Product__c = prod.Id,
            Type__c = 'In-Company Training',
            Status__c = 'Allocating',
            Stage__c = 'Provisional',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        insert specialEvent1;
        
        ///* CREATE BSC EVENT BOOKING
        Special_Event_Booking__c specialEventbooking2 = new Special_Event_Booking__c(
            Opportunity__c = opp.Id,
            Booking_Fee__c =  10000,
            Special_Event__c = specialEvent1.Id,
            Type__c = 'Public',
            OPL_ID__c = oli.Id,
            status__c = 'Provisional'
        );
        insert specialEventbooking2; 
        
        specialEvent1.status__c = 'Confirmed';
        update specialEvent1;
        
        specialEventbooking2.status__c = 'Confirmed';
        update specialEventbooking2;
        
        opp.StageName = 'Booking Received';
        update opp;
        
        Id inv = FinanceHelper.createInvoiceFromOpp(opp.Id, true);
        c2g__codaInvoice__c invoice = [SELECT 
                                       Id,
                                       Name
                                       FROM
                                       c2g__codaInvoice__c
                                       WHERE
                                       Id = :inv][0];        
        
        Set<Id> cshmchId = new Set<Id>(); 
        // Rahul Case 6605 - Below query is changed to cover code in testing
        //Map<Id,c2g__codaCashMatchingHistory__c> cshmch = new Map<Id,c2g__codaCashMatchingHistory__c>([Select c2g__MatchingReference__c, c2g__TransactionLineItem__r.c2g__LineDescription__c From c2g__codaCashMatchingHistory__c Where c2g__TransactionLineItem__r.c2g__LineDescription__c Like :invoice.Name Limit 1]);
        Map<Id,c2g__codaCashMatchingHistory__c> cshmch = new Map<Id,c2g__codaCashMatchingHistory__c>([Select c2g__MatchingReference__c, c2g__TransactionLineItem__r.c2g__LineDescription__c From c2g__codaCashMatchingHistory__c Limit 1]);
        system.debug('RSB Map<Id,c2g__codaCashMatchingHistory__c> cshmch - ' + cshmch);
        for(c2g__codaCashMatchingHistory__c csh:cshmch.Values())
            cshmchId.add(csh.c2g__MatchingReference__c);
        if(cshmchId.size()>0)
            FinancialTransactionPopulationMethods.cashMatching(cshmchId);
        
        List<c2g__codaCashMatchingHistory__c> cshmchLst = new List<c2g__codaCashMatchingHistory__c>([Select c2g__MatchingReference__c, c2g__TransactionLineItem__r.c2g__LineDescription__c From c2g__codaCashMatchingHistory__c Where c2g__TransactionLineItem__r.c2g__LineDescription__c Like :invoice.Name ORDER BY CreatedDate DESC Limit 1]);
        system.debug('RSB List<c2g__codaCashMatchingHistory__c> cshmchLst - ' + cshmchLst);
        update cshmchLst;
        system.debug('RSB After List<c2g__codaCashMatchingHistory__c> cshmchLst - ' + cshmchLst);

        // Rahul Case 6605 - Below query is changed to cover code in testing
        //List<c2g__codaTransactionLineItem__c> creditNote = [Select c2g__MatchingStatus__c, c2g__LineDescription__c, c2g__Transaction__r.c2g__transactionType__c From c2g__codaTransactionLineItem__c Where c2g__MatchingStatus__c = 'Matched' and c2g__Transaction__r.c2g__transactionType__c='Credit Note' and c2g__LineDescription__c Like :invoice.Name Limit 1];
        List<c2g__codaTransactionLineItem__c> creditNote = [Select c2g__MatchingStatus__c, c2g__LineDescription__c, c2g__Transaction__r.c2g__transactionType__c From c2g__codaTransactionLineItem__c Where c2g__MatchingStatus__c = 'Matched' and c2g__Transaction__r.c2g__transactionType__c='Credit Note' Limit 1];
        if(creditNote.size()>0){
            FinancialTransactionPopulationMethods.creditNoteMatch(creditNote);
        }
        
    }
/* Commented - of no use Rahul Case 6605
    public testmethod static void testFinancialTransactionMR()
    {
        List<c2g__codaMatchingReference__c> cshmchLst = new List<c2g__codaMatchingReference__c>([Select Id From c2g__codaMatchingReference__c  where ownerid = '00GD0000001GWrG' ORDER BY CreatedDate DESC Limit 1]);
        update cshmchLst;
    }
*/
}