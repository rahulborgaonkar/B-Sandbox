public with sharing class InvoiceLineItemsTriggerMethods {
/*
	Changes: 
		24/03/2010
		* Case 00001735 - Discarded Invoices do not update the Opportunity Line
				While an invoice is still "In progress", the opportunity line will not be updated
				This resolves the issue when the invoice is discarded.

*/

    public class Test_Exception extends Exception{}
        
    public static  boolean isBookingEvent(String bookingId)
    {
        Schema.DescribeSObjectResult result = Special_Event_Booking__c.SObjectType.getDescribe();
        return(bookingId.trim().startsWith(result.getKeyPrefix()));
    }
    
    public static boolean isOpportunityLineItem(String oppLineItemId)
    {
        Schema.DescribeSObjectResult result = OpportunityLineItem.SObjectType.getDescribe();
        return(oppLineItemId.trim().startsWith(result.getKeyPrefix()));
    }
    
    public static  boolean isSubscriptionLine(String subsLineId)
    {
        Schema.DescribeSObjectResult result = Subscription_Line__c.SObjectType.getDescribe();
        return(subsLineId.trim().startsWith(result.getKeyPrefix()));
    }
    
    
    public static void updateOppLineItemSubsLineBookingEvent(List<c2g__codaInvoiceLineItem__c> invoiceLineItemList)
    {
        
        Set<Id> bookingId = new Set<Id>();
        Set<Id> subsLineId = new Set<Id>();
        Set<Id> oppLineItemId = new Set<Id>();
	// Case 00001735
        Set<id> invIds = new Set<id>();
          
        for (c2g__codaInvoiceLineItem__c invline : invoiceLineItemList)
        	invIds.add(invline.c2g__Invoice__c);
        
        //Map<id, c2g__codaInvoice__c> invMap = new Map<id, c2g__codaInvoice__c>([Select c2g__InvoiceStatus__c From c2g__codaInvoice__c where id = :invIds]);
        	
        //Invoice line items
         for(c2g__codaInvoiceLineItem__c invoiceLineItem:invoiceLineItemList)
          {
          	// invMap.get(invoiceLineItem.c2g__Invoice__c).c2g__InvoiceStatus__c)
          	//c2g__Invoice__c inv =[Select c2g__InvoiceStatus__c From c2g__codaInvoice__c Where id = :invoiceLineItem.c2g__Invoice__c ];
          	//if (c2g__Invoice__c.c2g__InvoiceStatus__c <> 'In Progress')
          	if (invoiceLineItem.Invoice_Status__c <> 'In Progress')
          	{
              if(invoiceLineItem.OPL_ID__c !=null)
                  oppLineItemId.add(invoiceLineItem.OPL_ID__c);
             
              if(invoiceLineItem.BEB__c !=null)
                  bookingId.add(invoiceLineItem.BEB__c);
                  
              if(invoiceLineItem.SL__c !=null)
                  subsLineId.add(invoiceLineItem.SL__c);
          	}    
          }
	  // End of Case 00001735
          
          if(!oppLineItemId.isEmpty())
          {    
            
            List<OpportunityLineItem> updateOppLineItem = new List<OpportunityLineItem>([Select Id from OpportunityLineItem where Id IN:oppLineItemId]);
            update updateOppLineItem; 
            
          }
          
          if(!bookingId.isEmpty())
          {    
            
            List<Special_Event_Booking__c> updateBooking = new List<Special_Event_Booking__c>([Select Id from Special_Event_Booking__c where Id IN:bookingId]);
            update updateBooking; 
            
          }
          
          if(!subsLineId.isEmpty())
          {    
            
            List<Subscription_Line__c> updateSubsLine = new List<Subscription_Line__c>([Select Id from Subscription_Line__c where Id IN:subsLineId]);
            update updateSubsLine; 
            
          }   
    }

    
    
    
    public static void populateFields(List<c2g__codaInvoiceLineItem__c> invoiceLineItemList)
    {
        Boolean checked = false;
        
        System.debug('FJP pre: '+invoiceLineItemList);
        
        for(c2g__codaInvoiceLineItem__c invoiceLineItem:invoiceLineItemList)
        {
             if(invoiceLineItem.c2g__LineDescription__c !=null && invoiceLineItem.c2g__LineDescription__c != '')
             {   
                //throw new Test_Exception(String.valueOf(invoiceLineItem.c2g__LineDescription__c.split(';')[3]));
                //checked = false;
                
                //Populate (text) lookup field to opportunity line item
                if(InvoiceLineItemsTriggerMethods.isOpportunityLineItem(invoiceLineItem.c2g__LineDescription__c.split(';')[0]))
                {
                    invoiceLineItem.OPL_ID__c = invoiceLineItem.c2g__LineDescription__c.split(';')[0];
                }
                
                //Populate lookup fied to booking event
                if(invoiceLineItem.c2g__LineDescription__c.split(';').size()== 2 || invoiceLineItem.c2g__LineDescription__c.split(';').size()>2 )
                {
                    
                    if(InvoiceLineItemsTriggerMethods.isBookingEvent(invoiceLineItem.c2g__LineDescription__c.split(';')[1]))
                    {   
                        invoiceLineItem.BEB__c = invoiceLineItem.c2g__LineDescription__c.split(';')[1];
                        //invoiceLineItem.c2g__LineDescription__c = '';
                        //checked =true;
                    }
                } 
                //Populate lookup fied to susbscription line 
                if(invoiceLineItem.c2g__LineDescription__c.split(';').size() == 2 || invoiceLineItem.c2g__LineDescription__c.split(';').size()>2)
                {
                    if(InvoiceLineItemsTriggerMethods.isSubscriptionLine(invoiceLineItem.c2g__LineDescription__c.split(';')[1]))
                    {   
                        invoiceLineItem.SL__c = invoiceLineItem.c2g__LineDescription__c.split(';')[1];
                        //invoiceLineItem.c2g__LineDescription__c = '';
                        checked =true;
                    }
                }
                
                if(invoiceLineItem.c2g__LineDescription__c.split(';').size()== 4)
                {
                    invoiceLineItem.c2g__LineDescription__c = invoiceLineItem.c2g__LineDescription__c.split(';')[2]+';'+invoiceLineItem.c2g__LineDescription__c.split(';')[3];
                }
                else{
                    invoiceLineItem.c2g__LineDescription__c = '';
                }
                
               
             }        
        }
        invoiceLineItemList = InvoiceLineItemsTriggerMethods.createLineDescs(invoiceLineItemList);
        
    }
    
    /*
     * CREATE LINE DESCRIPTIONS
     *
     * Creates line descriptions based on the type of product that is on the invoice line.
     *
     * SUBSCRIPTION LINE:
	 *	Format:
	 *	<Product Name>
	 *	Subscription End Date: <End date of subscription in DD-MM-YYYY format>
	 *	Product Code: <The product code of the product>
	 *	
	 *	Example:
	 *	1 Year Subscription Module - Tools - 1 to 5 Sites
	 *	Subscription End Date: 01-11-2012
	 *	Product Code 1SMT-1-5
	 *
     */
    public static List<c2g__codaInvoiceLineItem__c> createLineDescs(List<c2g__codaInvoiceLineItem__c> invoiceLineItemList){
    	
    	// Create a list of event bookings and subscription lines and based on the list create
    	// the correct invoice line description for each so that they can be used by the invoice lines
    	Map<Id,String> subLineList = new Map<Id,String>();
    	Map<Id,String> evtBookingList = new Map<Id,String>();
    	
    	for (c2g__codaInvoiceLineItem__c invLineItem : invoiceLineItemList){
    		    		
    		if (invLineItem.SL__c !=null){
    			subLineList.put(invLineItem.SL__c, '');
    		}
       		if (invLineItem.BEB__c !=null){
    			evtBookingList.put(invLineItem.BEB__c, '');
    		}
    	}
    	
    	// Generate Subscripiton Line description
    	if (subLineList.size() > 0){
	    	for(Subscription_Line__c subLine : [SELECT
	    								Id,
	    								Subscription__r.Start_date__c,
	    								Subscription__r.End_date__c,
	    								Subscription__r.Type__c,
	    								Subscription__r.Sub_Ref__c
	    							FROM
	    								Subscription_Line__c
	    							WHERE
	    								Id IN:subLineList.keySet()]){

	    		if (subLine.Subscription__r.Type__c == 'Renewal'){
	    			
	    			Datetime dtStart = subLine.Subscription__r.Start_date__c;
	    			string startDateFrmt = dtStart.format('dd MMM yyyy');
	    			
		    		Datetime dtEnd = subLine.Subscription__r.End_date__c;
	    			string endDateFrmt = dtEnd.format('dd MMM yyyy');
	    			
	    			subLineList.put(subLine.Id, '('+startDateFrmt+' - '+endDateFrmt+')\nSubscription Number: '+subLine.Subscription__r.Sub_Ref__c);
	    		}else{
	    			subLineList.put(subLine.Id, 'Subscription Number: '+subLine.Subscription__r.Sub_Ref__c);
	    		}
	    	}
    	}
    	
    	if (evtBookingList.size() > 0){
    		System.debug('FJP1 lines'+evtBookingList);
			for(Special_Event_Booking__c evtBookLine : [SELECT
	    								Id,
	    								Special_Event__r.Name,
	    								Special_Event__r.StartDate__c,
	    								Special_Event__r.EndDate__c
	    							FROM
	    								Special_Event_Booking__c
	    							WHERE
	    								Id IN:evtBookingList.keySet()]){

	    			Datetime dtStart = evtBookLine.Special_Event__r.StartDate__c;
	    			string startDateFrmt = dtStart.format('dd MMM yyyy');
	    			
	    			string endDateFrmt = '';
	    			if (evtBookLine.Special_Event__r.EndDate__c != null){
			    		Datetime dtEnd = evtBookLine.Special_Event__r.EndDate__c;
		    			endDateFrmt = dtEnd.format('dd MMM yyyy');
	    			}else{
	    				endDateFrmt = 'n/a';
	    			}
	    			evtBookingList.put(evtBookLine.Id, '('+startDateFrmt+' - '+endDateFrmt+')\nEvent Reference: '+evtBookLine.Special_Event__r.Name);

	    	}
    	}
    	
    	for (c2g__codaInvoiceLineItem__c invLine : invoiceLineItemList){

			if (invLine.SL__c != null){
				invLine.c2g__LineDescription__c = subLineList.get(invLine.SL__c);
			}
			if (invLine.BEB__c != null){
	    		invLine.c2g__LineDescription__c = evtBookingList.get(invLine.BEB__c);
			}
    	}
    	return invoiceLineItemList;
    }
    
    public testmethod static void testInvoiceLineItemTriggerMethods()
    {
        // OpportunityLineItem oppLineItem  =[Select Id from OpportunityLineItem limit 1];
    	// Case 1359 and  1254 -- Added due to Winter 11 FF release where the default company of the user is required to determine the appropriate data
    	c2g__codaUserCompany__c userCompany = [Select id, c.c2g__User__r.Username, c.c2g__Company__c From  c2g__codaUserCompany__c c Where c.c2g__User__r.Username = :UserInfo.getUserName() and c.c2g__Company__r.name='British Safety Council'];
         
		Test.startTest();
        Special_Event_Booking__c bookingEvt = TestHelper.CreateSpecialEventBooking();
        OpportunityLineItem opl = TestHelper.OppLineItem;
        Subscription_Line__c subsline = TestHelper.subscriptionLineItem;
        
        List<c2g__codaInvoiceLineItem__c> invoiceLineItemList= [Select c.Id,c.OPL_ID__c,c.c2g__Invoice__c,c.SL__c,c.BEB__c,c.c2g__LineDescription__c from c2g__codaInvoiceLineItem__c c Where c.c2g__Invoice__r.c2g__OwnerCompany__c = :userCompany.c2g__Company__c  and OPL_ID__c = :opl.Id];
        
        invoiceLineItemList.get(0).c2g__LineDescription__c = '12345'+';'+subsline.Id;
        InvoiceLineItemsTriggerMethods.populateFields(invoiceLineItemList);
        
        invoiceLineItemList.get(0).c2g__LineDescription__c = '12345'+';'+bookingEvt.Id;
        InvoiceLineItemsTriggerMethods.populateFields(invoiceLineItemList);
        Test.stopTest();
         
    }


}