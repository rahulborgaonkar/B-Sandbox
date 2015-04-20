public class tncPublicEventCancellationHandler  implements Iterator<List<tncPublicEventCancellationWrapper>>{
    
    public list<tncPublicEventCancellationWrapper> allBookings		 {get; set;}
    public list<tncPublicEventCancellationWrapper> requestedBookings {get; set;}
    public integer setPageSize                                       {get; set;}
    
    integer recordNumber                                             {get; set;}
    
    public tncPublicEventCancellationHandler(Id oppId){
        allBookings = new list<tncPublicEventCancellationWrapper>(); 
        requestedBookings = new list<tncPublicEventCancellationWrapper>();
        
        List<Special_Event_Booking__c> bookings = [SELECT Name, Contact__r.Name, Product__c, Special_Event__r.Name,
                                                   Event_Start_Date__c, Event_End_Date__c, Status__C, OPL_ID__c, Special_Event__r.Stage__c, Product_ID__c,
                                                   Opportunity__c, Opportunity__r.Opportunity_Number__c, Transfer_To__c , Transfer_To__r.Name, 
                                                   Customer_Cancellation_Transfer_Date__c , TnC_Event_Units__c , Transfer_Cancellation_Reason__c,
                                                   Transfer_Cancellation_Reason__r.Name, Transfer_Cancellation_Notes__c, Transfer_Cancellation_Fee__c
                                                   FROM Special_Event_Booking__c 
                                                   where opportunity__r.recordtype.name = 'Public Event' and 
                                                   status__c in ('To Be Transferred', 'Confirmed', 'Provisional', 'To Be Cancelled') and Opportunity__c  = :oppId
                                                  ];
        List<Id> oliIds = new List<Id>();
        
        for (Special_Event_Booking__c booking: bookings){
            allbookings.add(new tncPublicEventCancellationWrapper(booking));
            oliIds.add(Id.ValueOf(booking.OPL_ID__c));
        }
        
        list<OpportunityLineItem> oppLines = [select unitprice, 
                                                     id, 
                                                     pricebookentry.product2.name, 
                                                     Quantity, 
                                                     OpportunityId,
                                                     PricebookEntry.Product2.Cancellation_Fee_Product__c, 
                                                     PricebookEntry.pricebook2id,
                                                     PricebookEntry.Product2Id, 
                                                     Transfer_Cancellation__c,
                                                     PricebookEntry.Product2.Transfer_Charge_Fee_Final__c, 
                                                     PricebookEntry.Product2.Transfer_Charge_Fee_3__c, 
                                                     PricebookEntry.Product2.Transfer_Charge_Fee_2__c, 
                                                     PricebookEntry.Product2.Transfer_Charge_Fee_1__c, 
                                                     PricebookEntry.Product2.Transfer_Charge_Day_3__c, 
                                                     PricebookEntry.Product2.Transfer_Charge_Day_2__c, 
                                                     PricebookEntry.Product2.Transfer_Charge_Day_1__c, 
                                                     PricebookEntry.Product2.Cancellation_Charge_Fee_Final__c, 
                                                     PricebookEntry.Product2.Cancellation_Charge_Fee_3__c, 
                                                     PricebookEntry.Product2.Cancellation_Charge_Fee_2__c, 
                                                     PricebookEntry.Product2.Cancellation_Charge_Fee_1__c, 
                                                     PricebookEntry.Product2.Cancellation_Charge_Day_3__c, 
                                                     PricebookEntry.Product2.Cancellation_Charge_Day_2__c, 
                                                     PricebookEntry.Product2.Cancellation_Charge_Day_1__c  
                                                from opportunitylineitem 
                                               where id in :oliIds];
        system.debug('oppLines' + oppLines);
        for (tncPublicEventCancellationWrapper wrapper : allbookings){
            for (OpportunityLineItem opl : oppLines){
                if (string.valueof(opl.id) == wrapper.booking.OPL_ID__c){
                    wrapper.oli = opl;
                    break;
                }
            }
        }
        
        
        setPageSize = 10;
        recordNumber = 0;
    }
    
    /*
    * checks if the next page is available.
    */
    public boolean hasNext(){ 
        if(recordNumber >= allBookings.size()) {
            return false; 
        } else {
            return true; 
        }
    } 
    
    /*
    * checks if previous page is available.
    */   
    public boolean hasPrevious(){ 
        if(recordNumber <= setPageSize) {
            return false; 
        } else {
            return true;
        }
    }
    
    /*
    * Loads next set of records
    */
    public List<tncPublicEventCancellationWrapper> next(){
        
        requestedBookings = new List<tncPublicEventCancellationWrapper>(); 
        integer startNumber = 0;
        
        if(hasNext()) {
            if(allBookings.size() <= (recordNumber + setPageSize)){
                startNumber = recordNumber;
                recordNumber = allBookings.size();
            } else {
                recordNumber = (recordNumber + setPageSize);
                startNumber = (recordNumber - setPageSize);
            }
            
            for(integer start = startNumber; start < recordNumber; start++) {
                requestedBookings.add(allBookings[start]);
            }
        } 
        
        return requestedBookings;
    }
    
    /*
    * Loads previous set of records
    */
    public List<tncPublicEventCancellationWrapper> previous(){
        
        integer size = allBookings.size(); 
        requestedBookings = new list<tncPublicEventCancellationWrapper>(); 
        
        if(recordNumber == size){
            if(math.mod(size, setPageSize) > 0)
            {    
                recordNumber = size - math.mod(size, setPageSize);
            }
            else
            {
                recordNumber = (size - setPageSize);
            } 
        } else {
            recordNumber = (recordNumber - setPageSize);
        }
        
        for(integer start = (recordNumber - setPageSize); start < recordNumber; ++start) {
            requestedBookings.add(allBookings[start]);
        } 
        
        return requestedBookings;
    }
}