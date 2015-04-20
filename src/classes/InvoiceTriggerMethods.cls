public without sharing class InvoiceTriggerMethods
 {
    //public Set<Id> invsUpdated = new Set<Id>();
    
    public class Test_Exception extends Exception{}
    //Populate Invoice Status field on booking event object, Opportunity Line Item object and Susbscription Line object

    // Case 6609
    // updateSubscription function is called from InvoiceTrigger
    // This function check invoice fields Copy_Invoice_Status__c == 'Paid' and Copy_Match_Type__c != 'Credited'
    // if both conditions are true it updates subscrption fields Invoice_Status__c, Status__c, Invoice_Date__c, Start_Date__c, End_Date__c
    // depending on subscription field Type__c == 'New' OR (Type__c == 'Renewal' AND Subscription_Value__c > 0)
    public static void updateSubscription(List<c2g__codaInvoice__c> invoiceList)
    {
        system.debug('Inside updateSubscription');
        system.debug('invoiceList - ' + invoiceList);
        List<Id> invIds = new List<Id>();
        for(c2g__codaInvoice__c inv : invoiceList)
        {
            invIds.add(inv.id);
        }
        if(invIds.size() > 0)
        {
            system.debug('invIds - ' + invIds);

            List<c2g__codaInvoice__c> invoices = [SELECT c2g__Transaction__r.c2g__DocumentOutstandingTotal__c, c2g__Transaction__r.c2g__MatchType__c, 
                                                    Copy_Invoice_Status__c, Copy_Match_Type__c, Computed_Invoice_Status__c 
                                                    FROM c2g__codaInvoice__c WHERE id in :invIds];
            system.debug('invoices - ' + invoices);
            invIds.clear();
            for(c2g__codaInvoice__c inv : invoices)
            {
                system.debug('inv.Copy_Invoice_Status__c - ' + inv.Copy_Invoice_Status__c);
                system.debug('inv.Copy_Match_Type__c - ' + inv.Copy_Match_Type__c);
                if(inv.Copy_Invoice_Status__c == 'Paid' && inv.Copy_Match_Type__c  != 'Credited')
                {
                    invIds.add(inv.id);
                }
            }

            Map<Id, Subscription__c> subscriptions = new Map<Id, Subscription__c>([SELECT Invoice_Status__c, Invoice_Date__c, Type__c, Start_Date__c, End_Date__c
                                            , Longest_Duration_Years__c, Status__c, Subscription_Value__c FROM Subscription__c 
                                            WHERE Renewal_Sales_Invoice__c in :invIds]);
            system.debug('subscriptions - ' + subscriptions);

            List<AggregateResult> listLongestDuration = [SELECT Subscription__r.id subId, max(Reminder_Days_Number__c) Longest_Reminder_Days__c
                                                    FROM Subscription_Line__c where Subscription__c = :subscriptions.keyset()
                                                    group by Subscription__r.id];
            system.debug('listDuration - ' + listLongestDuration);

            Map<Id, Decimal> mapLongestDuration = new Map<Id, Decimal>();

            for (AggregateResult ar : listLongestDuration) 
            {
                Decimal lrd = 0;
                if((Decimal)ar.get('Longest_Reminder_Days__c') != null)
                {
                    lrd = (Decimal)ar.get('Longest_Reminder_Days__c');
                }
                mapLongestDuration.put((ID)ar.get('subId'), lrd);
            }
            system.debug('mapDuration - ' + mapLongestDuration);
            
            for(Subscription__c sub : subscriptions.values())
            {
                sub.Invoice_Status__c = 'Paid';
                if(sub.Type__c == 'New')
                {
                    system.debug('Inside New');
                    sub.Status__c = 'Current';
                    sub.Invoice_Date__c = Date.today();
                    sub.Start_Date__c = Date.today();
                    sub.End_Date__c = sub.Start_Date__c.addYears((integer)sub.Longest_Duration_Years__c) - 1;
                }
                if(sub.Type__c == 'Renewal' && sub.Subscription_Value__c > 0)
                {
                    system.debug('Inside Renewal');
                    if(sub.Start_Date__c > Date.today())
                    {
                        system.debug('if st date gt today');
                        sub.Status__c = 'Pending - Paid';
                    }
                    else if(sub.Start_Date__c <= Date.today())
                    {
                        system.debug('if st date le today');
                        sub.Status__c = 'Current';
                    }

                    if(sub.Paying_By__c == 'Direct Debit')
                    {
                        system.debug('if Direct Debit');
                        sub.Invoice_Date__c = sub.Start_Date__c - 20;
                    }
                    else
                    {
                        system.debug('else Direct Debit');
                        system.debug('sub.Start_Date__c - ' + sub.Start_Date__c);
                        system.debug('sub.Longest_Reminder_Days__c - ' + mapLongestDuration.get(sub.id));
                        Integer Longest_Reminder_Days = (Integer)mapLongestDuration.get(sub.id);
                        system.debug('Longest_Reminder_Days - ' + Longest_Reminder_Days);
                        sub.Invoice_Date__c = sub.Start_Date__c.addDays(-1*Longest_Reminder_Days);
                    }
                }
            }
            update subscriptions.values();
            system.debug('after update subscriptions - ' + subscriptions);
        }
    }
    
    public static void updateInvoiceLineItemsNonFuture(Set<Id> invoiceIdSet) {

//      if (!invsUpdated.containsAll(invoiceIdSet)){
            Map<Id,c2g__codaInvoiceLineItem__c> invoiceLineItemMap = new Map<Id,c2g__codaInvoiceLineItem__c>([SELECT Id 
                FROM c2g__codaInvoiceLineItem__c
                WHERE c2g__Invoice__c IN:invoiceIdSet]);
            update invoiceLineItemMap.values();
            //invsUpdated.addAll(invoiceIdSet);
//      }
     }
          
    @future public static void updateInvoiceLineItems(Set<Id> invoiceIdSet) {

        Map<Id,c2g__codaInvoiceLineItem__c> invoiceLineItemMap = new Map<Id,c2g__codaInvoiceLineItem__c>([SELECT Id 
            FROM c2g__codaInvoiceLineItem__c
            WHERE c2g__Invoice__c IN:invoiceIdSet]);
            
        update invoiceLineItemMap.values();
    }
     
     public static void populateCustomerReference(List<c2g__codaInvoice__c> invoiceList)
     {
     
         for(c2g__codaInvoice__c invoice:invoiceList)
         {
             //throw new Test_Exception('Done'+invoice.Name);
             invoice.c2g__CustomerReference__c = invoice.Name;
         }
     
     } 
     /* 
      * CLEAR TO BE INVOICED OPPORTUNITY FLAG
      *
      * If the invoice has been posted then update the related opportunity to say its been invoiced and clear is credited if one2one invoice.
      */
     public static void clearToBeInvoicedOppFlag(Map<Id, c2g__codaInvoice__c> oldInvMap, Map<Id, c2g__codaInvoice__c> newInvMap){
        
        List<Id> oppIdsToUpd = new List<Id>();
        
        for (Id invId:newInvMap.keySet()){
            c2g__codaInvoice__c myOldInv = oldInvMap.get(invId);
            c2g__codaInvoice__c myNewInv = newInvMap.get(invId);
            
            if ((myOldInv.c2g__InvoiceStatus__c <> myNewInv.c2g__InvoiceStatus__c) && myNewInv.c2g__InvoiceStatus__c == 'Complete'){
                oppIdsToUpd.add(myNewInv.c2g__Opportunity__c);
                System.debug('Added invoice for updating: '+myNewInv.Name+'st-old:'+myOldInv.c2g__InvoiceStatus__c+' st-new:'+myNewInv.c2g__InvoiceStatus__c);
            }
        }
        
        if (oppIdsToUpd.size() > 0){
            List<Opportunity> oppsToUpd = new List<Opportunity>([SELECT 
                                                                    Id, 
                                                                    Finance_to_Invoice_Opp__c,
                                                                    Is_Credited__c,
                                                                    Using_one_to_one_invoicing__c
                                                                FROM
                                                                    Opportunity
                                                                WHERE
                                                                    Finance_to_Invoice_Opp__c = true AND
                                                                    Id IN:oppIdsToUpd]);
            if (oppsToUpd.size() > 0){
                for (Opportunity opp : oppsToUpd){
                    opp.Finance_to_Invoice_Opp__c = false;
                    if (opp.Is_Credited__c == true && opp.Using_one_to_one_invoicing__c == 'Yes'){
                        opp.Is_Credited__c = false;
                    }
                }
                System.debug('FJP objs being updated: '+oppsToUpd);
                update oppsToUpd;
            }
        }
     }
     
     /*
      * UPDATE LATEST INVOICE ON OPPORTUNITY
      *
      * Updates the latest invoice field on the opportunity
      */
     public static void updateLatestInvoice(List<c2g__codaInvoice__c> invList){
        
     }
     
     /*
      * UPDATE PROFORMA CREATED FLAG
      * 
      * Updates the Opportunity.Proforma Exists flag if an proforma invoice exists for the opporunity
      * Updates the Opportunity.Latest_Invoice field on the opportunity.
      */
     public static void updateOppFields(List<c2g__codaInvoice__c> invoiceList){
        
        // Get unique opportunities for each invoice
        Set<Id> oppIdList = new Set<Id>();
        List<Opportunity> oppsToBeUpd = new List<Opportunity>();
        
        System.debug('In updateOppFields');
        if (invoiceList.size() > 0){
            System.debug('Invoices in list');
            for (c2g__codaInvoice__c inv : invoiceList){
                if (inv.c2g__Opportunity__c !=null){
                    System.debug('Found opp to add to arr');
                    oppIdList.add(inv.c2g__Opportunity__c);
                }else{
                    System.debug('Cant find opp');
                }
            }
            // Get opp details
            List<Opportunity> oppList = new List<Opportunity>([SELECT
                    Id,
                    Proforma_exists__c
                FROM
                    Opportunity
                WHERE
                    Id IN :oppIdList
                ]);
            
            // Get all invoices for opportunities
            List<c2g__codaInvoice__c> invList = new List<c2g__codaInvoice__c>([SELECT
                            Id,
                            c2g__InvoiceStatus__c,
                            c2g__Opportunity__c
                        FROM
                            c2g__codaInvoice__c
                        WHERE
                            c2g__Opportunity__c IN :oppIdList
                ]);

            for (Opportunity opp : oppList){
                
                // Loop over each opp and find if it is in progress or not.
                Boolean inProgress = false;
                for (c2g__codaInvoice__c inv : invList){
                    System.debug('Looping invoices');
                    if (inv.c2g__Opportunity__c == opp.Id){
                        if (inv.c2g__InvoiceStatus__c == 'In Progress'){
                            inProgress = true;
                            System.debug('Found inProgress invoice');
                        }
                    }
                }
                if (inProgress){
                    // only add to update list if the field is different
                    if (opp.Proforma_exists__c == false){
                        System.debug('Proforma Not Found');
                        opp.Proforma_exists__c = true;
                        oppsToBeUpd.add(opp);
                    }
                }else{
                    // only add to update list if the field is different
                    if (opp.Proforma_exists__c == true){
                        System.debug('Proforma Found');
                        opp.Proforma_exists__c = false;
                        oppsToBeUpd.add(opp);
                    }
                }
            }
            
            // Identifiy if the status has changed and if so add it to the update list.             
            System.debug('Opps to update: '+oppsToBeUpd);
            update oppsToBeUpd;
        }
        
        
     }
     
     /*
      * UPDATE OPPORTUNITY LINE CREDITS
      *
      * When an invoice has "is fully credited" set on it update the opportunity line quantity credited values.
      */
     public static void updOppLineCredits(Map<Id,c2g__codaInvoice__c> oldInvs, Map<Id,c2g__codaInvoice__c> newInvs){
        
        List<Id> oppsToCredit = new List<Id>();
        Set<Id> invsToMarkAsCredited = new Set<Id>();

        system.debug('oldInvs - ' + oldInvs.keySet());
        system.debug('newInvs - ' + newInvs.keySet());

        for (Id invId:newInvs.keySet()){
        system.debug('oldInvs.get(invId).Is_Credited_In_Full__c - ' + oldInvs.get(invId).Is_Credited_In_Full__c);
        system.debug('newInvs.get(invId).Is_Credited_In_Full__c - ' + newInvs.get(invId).Is_Credited_In_Full__c);
        system.debug('newInvs.get(invId).c2g__Opportunity__c - ' + newInvs.get(invId).c2g__Opportunity__c);
        system.debug('newInvs.get(invId).Credited_Opp_Lines__c - ' + newInvs.get(invId).Credited_Opp_Lines__c);
        
            if (oldInvs.get(invId).Is_Credited_In_Full__c <> newInvs.get(invId).Is_Credited_In_Full__c && 
                newInvs.get(invId).Is_Credited_In_Full__c == True && 
                newInvs.get(invId).c2g__Opportunity__c != null && 
                newInvs.get(invId).Credited_Opp_Lines__c == False){
                    
                oppsToCredit.add(newInvs.get(invId).c2g__Opportunity__c);
                invsToMarkAsCredited.add(invId);
            }
        }
        
        
        if (oppsToCredit.size() > 0){
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>([SELECT
                                                                                        Id,
                                                                                        Quantity,
                                                                                        Quantity_Credited__c,
                                                                                        Opportunity.Using_one_to_one_invoicing__c
                                                                                    FROM
                                                                                        OpportunityLineItem
                                                                                    WHERE
                                                                                    OpportunityId IN :oppsToCredit]);
            Boolean updLines = false;
            for (OpportunityLineItem oppLine : oppLineItems){
                if (oppLine.Opportunity.Using_one_to_one_invoicing__c == 'Yes'){
                    System.debug('Using one 2 one');
                    Double QtyCredited = oppLine.Quantity_Credited__c;
                    if (oppLine.Quantity_Credited__c == null){
                        QtyCredited = 0;
                    }else{
                        QtyCredited = oppLine.Quantity_Credited__c;
                    }
                    oppLine.Quantity_Credited__c = QtyCredited + oppLine.Quantity;
                    updLines = true;
                }
            }
            if (updLines){
                System.debug('Upd lines'+oppLineItems);
                update oppLineItems;
            }
            List<c2g__codaInvoice__c> invsToUpd = new List<c2g__codaInvoice__c>([SELECT Id, Credited_Opp_Lines__c FROM c2g__codaInvoice__c WHERE Id IN:invsToMarkAsCredited]);
            for (c2g__codaInvoice__c inv : invsToUpd){
                inv.Credited_Opp_Lines__c = True;
            }
            update invsToUpd;
        }
     }
     
     public testmethod static void testInvoiceTriggerMethods()
     {
        // Case 1359 and  1254 -- Added due to Winter 11 FF release where the default company of the user is required to determine the appropriate data
        System.debug('User Details: '+UserInfo.getUserName());
        c2g__codaUserCompany__c userCompany = [Select id, c.c2g__User__r.Username, c.c2g__Company__c From  c2g__codaUserCompany__c c Where c.c2g__User__r.Username = :UserInfo.getUserName() and c.c2g__Company__r.name='British Safety Council'];
        
        system.debug('Before TestHelper.CreateSpecialEventBooking');
        Special_Event_Booking__c bookingEvt = TestHelper.CreateSpecialEventBooking();
        system.debug('After TestHelper.CreateSpecialEventBooking');

        OpportunityLineItem opl = TestHelper.OppLineItem;
        Subscription_Line__c subsline = TestHelper.subscriptionLineItem;
        
        system.debug('Subscription_Line__c subsline - ' + subsline);
                
        Id invoiceLineItemId = [Select c.c2g__Invoice__c from c2g__codaInvoiceLineItem__c c Where c.c2g__Invoice__r.c2g__OwnerCompany__c = :userCompany.c2g__Company__c and OPL_ID__c = :opl.Id limit 1].c2g__Invoice__c;
                                                                                                           
        Map<Id,c2g__codaInvoice__c> invoiceMap = new Map<Id,c2g__codaInvoice__c>([Select c.Name, c.Id, c.Copy_Invoice_Status__c, c.Copy_Match_Type__c From c2g__codaInvoice__c c Where c.Id = :invoiceLineItemId limit 1]);

        system.debug('invoiceMap - ' + invoiceMap.keySet());

        Test.startTest();         
        InvoiceTriggerMethods.updateInvoiceLineItems(invoiceMap.keySet());
        InvoiceTriggerMethods.populateCustomerReference(invoiceMap.values());
        //update invoiceMap.values();

        Map<Id,c2g__codaInvoice__c> oldMap = invoiceMap;
        Map<Id,c2g__codaInvoice__c> newMap = invoiceMap.deepClone();

        for(c2g__codaInvoice__c inv : newMap.values())
        {
            inv.Is_Credited_In_Full__c = true;
            inv.c2g__Opportunity__c = TestHelper.Opportunity.id;
            
        }
        InvoiceTriggerMethods.updOppLineCredits(oldMap, newMap);

        List<c2g__codaInvoice__c> listInv = newMap.values();
        for(c2g__codaInvoice__c inv : listInv)
        {
            inv.Copy_Invoice_Status__c = 'Paid';
            inv.Copy_Match_Type__c  = '';
        }
        
        update listInv;
        Subscription__c sub = TestHelper.subscription;        
        sub.Renewal_Sales_Invoice__c = listInv[0].id;
        update sub;

        InvoiceTriggerMethods.updateSubscription(listInv);

        Test.stopTest();       

     }
 }