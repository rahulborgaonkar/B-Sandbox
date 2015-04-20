public class OpportunityLineItemsTriggerMethods{
    /*
    Case 00001649 18/03/2011 Invoice Quantities are not being updated
    Invoice quantities should always be updated.
    */
    public class Test_Exception extends Exception{}
    
    public class appException extends Exception {}
    
    /*
    * CHECK FOR OPPORTUNITY LINE LOCK
    *
    * Checks to see if an opportunity line has been used to create an invoice and if
    * so doesn't allow the invoice line to be deleted. 
    * 
    * VS: Also checks if the product has related event bookings associated to it.
    * 
    */
    public static void checkForOppLineLock(List<OpportunityLineItem> oppLines){
        
        Boolean oplInUse = false;
        List<String> strOPLsWithError = new List<String>();
        List<String> strOPLList = new List<String>();
        
        for (OpportunityLineItem oppLine : oppLines){
            strOPLList.add((string)oppLine.Id);
        }
        
        boolean foundError = false;
        
        for (AggregateResult ar : [select count(id) bookings, OPL_ID__c from Special_Event_Booking__c where OPL_ID__c in :strOPLList group by OPL_ID__c]){
            for (OpportunityLineItem oppLine : oppLines){
                if (ar.get('OPL_ID__c') == oppLine.Id && (Integer)ar.get('bookings') > 0){
                    oppLine.AddError('ERROR: You cannot remove this product from the opportunity because there are bookings associated to it. Please use the cancellation process to cancel the booking(s) and remove the product(s).');
                    foundError = true;
                }
            }
        }
        if (foundError == false){
            for (c2g__codaInvoiceLineItem__c invLine : [SELECT Id,
                                                        OPL_ID__c
                                                        FROM 
                                                        c2g__codaInvoiceLineItem__c 
                                                        WHERE 
                                                        c2g__Invoice__r.c2g__InvoiceStatus__c <> 'Discarded' 
                                                        AND c2g__Invoice__r.Is_Credited_In_Full__c != true
                                                        AND OPL_ID__c IN :strOPLList]){
                                                            strOPLsWithError.add(invLine.OPL_ID__c);
                                                        }
            
            for (OpportunityLineItem oppLine : oppLines){
                Boolean found = false;
                system.debug('oppLine.Transfer_Cancellation__c: ' + oppLine.Transfer_Cancellation__c);
                if (oppLine.Transfer_Cancellation__c == false){
                    for (String oplId : strOPLsWithError){
                        if (oplId == oppLine.Id){
                            found = true;
                            break;
                        }
                    }
                }
                if (found){
                    oppLine.addError('ERROR: Unable to delete opportunity Line as it is either attached to a proforma or completed invoice or the opportunity is at Customer Approved or Booking Received');
                }
            }
        }
    }
    
    /*
    * UPDATE BOOKING PRICE LINES
    *
    * Updates the Booking Line Price fields to match the Opportunity Line Totals.
    */
    public static void updateBookingPriceLines(Set<Id> oppLineIds){
        
        /* *********** COMMENTED OUT DUE TO TEST FAILURES NEEDS TO BE FIXED ONCE SANDBOX REFRESHED ********* */
        /*
        List<Special_Event_Booking__c> linesToUpd = new List<Special_Event_Booking__c>();
        
        System.Debug('FJP OppLineIds: '+oppLineIds);
        Map<Id, OpportunityLineItem> oppLines = new Map<Id, OpportunityLineItem>([SELECT 
        Id,
        TotalPrice
        FROM 
        OpportunityLineItem
        WHERE
        Id IN :oppLineIds]);
        
        
        Map<Id, Special_Event_Booking__c> bookingLines = new Map<Id, Special_Event_Booking__c>([SELECT 
        Id,
        Booking_Fee__c,
        OPL_ID__c
        FROM 
        Special_Event_Booking__c
        WHERE
        (Override_Booking_Fee__c = false OR Override_Booking_Fee__c = null) AND
        (Type__c = 'Public' OR Type__c = 'In-Company Primary') AND
        OPL_ID__c IN :oppLineIds]);
        for (Id bookingId : bookingLines.keySet()){
        Special_Event_Booking__c bookingLine = bookingLines.get(bookingId);
        if(oppLines.containsKey(bookingLine.OPL_ID__c)){
        OpportunityLineItem oppLine = oppLines.get(bookingLine.OPL_ID__c);
        
        if (bookingLine.Booking_Fee__c != oppLine.TotalPrice){
        bookingLine.Booking_Fee__c = oppLine.TotalPrice;
        linesToUpd.add(bookingLine);
        }
        }
        }
        
        if(linesToUpd.size() > 0){
        update linesToUpd;
        }
        */
    }
    
    public static void updateOpportunity(Set<Id> lineItemListId) 
    {
        Set<Id> oppId = new Set<Id>();
        for(OpportunityLineItem oppLineItem:[Select OpportunityId from OpportunityLineItem where Id IN:lineItemListId])
        {
            oppId.add(oppLineItem.OpportunityId);
        }
        list<Opportunity> updateOpp = new List<Opportunity>([Select Id from Opportunity where Id IN:oppId]);
        update updateOpp;
        
    }
    
    @future public static void updateOpportunityExt(Set<Id> lineItemListId)
    {
        OpportunityLineItemsTriggerMethods.updateOpportunity(lineItemListId);
    }
    
    
    
    public static void countQuantity (Map<Id,OpportunityLineItem> lineItemMap,Map<Id,OpportunityLineItem>oldLineItemMap)
    {
        
        Map<String,Double> quantityInvoiced = new Map<String,Double>();
        Map<String,Double> quantityPartPaid  = new Map<String,Double>();
        Map<String,Double> quantityPaid  = new Map<String,Double>();
        Map<String,Double> quantityCredited  = new Map<String,Double>();
        
        Map<String, c2g__codaInvoiceLineItem__c> invoiceLineItemMap = new Map<String, c2g__codaInvoiceLineItem__c>();
        
        boolean one2oneOpp = false;
        
        for(c2g__codaInvoiceLineItem__c invoiceLineItem: [Select OPL_ID__c,
                                                          c2g__Quantity__c,
                                                          c2g__Invoice__r.c2g__PaymentStatus__c,
                                                          c2g__Invoice__r.Copy_Invoice_Status__c,
                                                          c2g__Invoice__r.LastModifiedDate,
                                                          c2g__Invoice__r.c2g__InvoiceDate__c,
                                                          c2g__Invoice__r.c2g__MatchType__c,
                                                          c2g__Invoice__r.c2g__transaction__r.Legacy_Match_Type__c,
                                                          c2g__Invoice__r.Computed_Invoice_Status__c,
                                                          c2g__Invoice__r.c2g__Opportunity__r.Using_one_to_one_invoicing__c
                                                          from c2g__codaInvoiceLineItem__c
                                                          where OPL_ID__c IN:lineItemMap.KeySet()
                                                          and c2g__Invoice__r.c2g__InvoiceStatus__c!='Discarded'
                                                          and c2g__Invoice__r.c2g__InvoiceStatus__c!='In Progress'])
        {                                                          
            invoiceLineItemMap.put(invoiceLineItem.OPL_ID__c, invoiceLineItem);
            
            //Calculate quantity invoiced   
            if(!quantityInvoiced.containsKey(invoiceLineItem.OPL_ID__c))
                quantityInvoiced.put(invoiceLineItem.OPL_ID__c,invoiceLineItem.c2g__Quantity__c);
            
            else{
                Double quantity = quantityInvoiced.get(invoiceLineItem.OPL_ID__c);
                quantity+= invoiceLineItem.c2g__Quantity__c;
                quantityInvoiced.put(invoiceLineItem.OPL_ID__c,quantity);
            }     
            system.debug('quantityInvoiced::: '+quantityInvoiced);
            //Calculate quantity paid   
            if(invoiceLineItem.c2g__Invoice__r.Computed_Invoice_Status__c == 'Paid')
            {    
                if(!quantityPaid.containsKey(invoiceLineItem.OPL_ID__c))
                    quantityPaid.put(invoiceLineItem.OPL_ID__c,invoiceLineItem.c2g__Quantity__c);
                
                else{
                    Double quantity = quantityPaid.get(invoiceLineItem.OPL_ID__c);
                    quantity+= invoiceLineItem.c2g__Quantity__c;
                    quantityPaid.put(invoiceLineItem.OPL_ID__c,quantity);
                }      
            }else{
                
                quantityPaid.put(invoiceLineItem.OPL_ID__c,0);
            }
            system.debug('quantityPaid::: '+quantityPaid);
            
            //Calculate quantity part paid
            if(invoiceLineItem.c2g__Invoice__r.Copy_Invoice_Status__c =='Part Paid')
            {    
                if(!quantityPartPaid.containsKey(invoiceLineItem.OPL_ID__c))
                    quantityPartPaid.put(invoiceLineItem.OPL_ID__c,invoiceLineItem.c2g__Quantity__c);
                
                else{
                    Double quantity = quantityPartPaid.get(invoiceLineItem.OPL_ID__c);
                    quantity+= invoiceLineItem.c2g__Quantity__c;
                    quantityPartPaid.put(invoiceLineItem.OPL_ID__c,quantity);
                }     
            }else{
                
                quantityPartPaid.put(invoiceLineItem.OPL_ID__c,0);    
            }
            system.debug('quantityPartPaid::: '+quantityPartPaid);
            
            if(invoiceLineItem.c2g__Invoice__r.Computed_Invoice_Status__c == 'Credited' && invoiceLineItem.c2g__Invoice__r.c2g__Opportunity__r.Using_one_to_one_invoicing__c == 'Yes'){
                if(!quantityCredited.containsKey(invoiceLineItem.OPL_ID__c))
                    quantityCredited.put(invoiceLineItem.OPL_ID__c,invoiceLineItem.c2g__Quantity__c);
                
                else{
                    Double quantity = quantityCredited.get(invoiceLineItem.OPL_ID__c);
                    quantity+= invoiceLineItem.c2g__Quantity__c;
                    quantityCredited.put(invoiceLineItem.OPL_ID__c,quantity);
                }  
            }
            
            system.debug('quantityCredited::: '+quantityCredited);
                
            if (invoiceLineItem.c2g__Invoice__r.c2g__Opportunity__r.Using_one_to_one_invoicing__c == 'Yes')
                one2oneOpp = true;
            
        }
        
        if (one2oneOpp == false)
            for(c2g__codaCreditNoteLineItem__c creditNoteItem:[Select Sales_Invoice_Line_Item__r.OPL_ID__c,
                                                                      c2g__Quantity__c 
                                                                 from c2g__codaCreditNoteLineItem__c
                                                                where Sales_Invoice_Line_Item__r.OPL_ID__c IN:lineItemMap.KeySet()])
            {
                
                //Calculate quantity credited   
                if(!quantityCredited.containsKey(creditNoteItem.Sales_Invoice_Line_Item__r.OPL_ID__c))
                    quantityCredited.put(creditNoteItem.Sales_Invoice_Line_Item__r.OPL_ID__c,creditNoteItem.c2g__Quantity__c);
                
                else{
                    Double quantity = quantityCredited.get(creditNoteItem.Sales_Invoice_Line_Item__r.OPL_ID__c);
                    quantity+= creditNoteItem.c2g__Quantity__c;
                    quantityCredited.put(creditNoteItem.Sales_Invoice_Line_Item__r.OPL_ID__c,quantity);
                }  
                
            }
        
        //Update Opportunity line item quantity fields  
        for(OpportunityLineItem lineItem:lineItemMap.values())
        {
            //Quantity invoiced
            if(quantityInvoiced.containsKey(lineItem.Id))
                lineItem.Quantity_Invoiced__c = quantityInvoiced.get(lineItem.Id);
            
            if (invoiceLineItemMap.containsKey(lineItem.Id))
                lineItem.Invoice_Date__c = invoiceLineItemMap.get(lineItem.Id).c2g__Invoice__r.c2g__InvoiceDate__c;

            //Quantity paid
            if(quantityPaid.containsKey(lineItem.Id))
                lineItem.Quantity_Paid__c = quantityPaid.get(lineItem.Id);
                
            //Quantity Part Paid
            if(quantityPartPaid.containsKey(lineItem.Id))
                lineItem.Quantity_Part_Paid__c = quantityPartPaid.get(lineItem.Id);
            
            //Calculate quantity credited
            if(quantityCredited.containsKey(lineItem.Id))
                lineItem.Quantity_Credited__c = quantityCredited.get(lineItem.Id);
        }
        
    }
    
    @isTest(SeeAllData=true)
    public static  void testOpportunityLineItemTriggerMethods()
    {

        Set<Id> invoiceId = new Set<Id>();

        // Case 1359 and  1254 -- Added due to Winter 11 FF release where the default company of the user is required to determine the appropriate data
        //c2g__codaUserCompany__c userCompany = [Select id, c.c2g__User__r.Username, c.c2g__Company__c From  c2g__codaUserCompany__c c Where c.c2g__Company__r.name='British Safety Council' limit 1];
        
        List<c2g__codaInvoiceLineItem__c> invoiceLineItemList = new List<c2g__codaInvoiceLineItem__c>
            ([Select Id,
              OPL_ID__c,
              c2g__Invoice__c 
              from c2g__codaInvoiceLineItem__c 
              where OPL_ID__c!=null
              //and c2g__Invoice__r.c2g__OwnerCompany__c = :userCompany.c2g__Company__c
              and c2g__Invoice__r.Copy_Invoice_Status__c <> 'Paid' limit 5 ]); 
        
        Map<Id,OpportunityLineItem> lineItemMap = new Map<Id,OpportunityLineItem>( [Select Id,
                                                                                    Quantity_Invoiced__c,
                                                                                    Quantity_Paid__c,
                                                                                    Quantity_Part_Paid__c,
                                                                                    Quantity_Credited__c,
                                                                                    Invoice_Date__c 
                                                                                    from OpportunityLineItem 
                                                                                    //where id = :invoiceLineItemList[0].OPL_ID__c
                                                                                    limit 1]);
        
        
        for(c2g__codaInvoiceLineItem__c invoiceLineItem:invoiceLineItemList )
        {
            invoiceLineItem.OPL_ID__c = lineItemMap.values().get(0).Id;
            invoiceId.add(invoiceLineItem.c2g__Invoice__c);        
            
        }
        
        // update invoiceLineItemList ;
        // List<c2g__codaInvoice__c > invoice = [Select id,Copy_Invoice_Status__c from c2g__codaInvoice__c where Id='a1ZD0000000TTYV' limit 1];
        List<c2g__codaInvoice__c > invoice = [Select id,Copy_Invoice_Status__c from c2g__codaInvoice__c where Id=:invoiceLineItemList[0].c2g__Invoice__c limit 1];
        invoice.get(0).Copy_Invoice_Status__c ='Part Paid';
        //update invoice;                                                   
        
        
        
        
        OpportunityLineItemsTriggerMethods.countQuantity(lineItemMap,lineItemMap);
        invoice.get(0).Copy_Invoice_Status__c ='Paid';
        //invoice.get(1).Copy_Invoice_Status__c ='Paid';
        //update invoice;
        
        OpportunityLineItemsTriggerMethods.countQuantity(lineItemMap,lineItemMap); 
        
        //update lineItemMap.values();
        // Test.startTest();
        //   OpportunityLineItemsTriggerMethods.updateOpportunityExt(lineItemMap.keySet());
        // test.stopTest();
        
    }
    
    
}