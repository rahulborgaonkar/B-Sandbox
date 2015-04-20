public class tncInCompanyTransferIterator  implements Iterator<List<tncEventsWrapper>>{
    
    public list<tncEventsWrapper> transferEvents                 {get; set;}
    public list<tncEventsWrapper> transferEventsPager            {get; set;}
    public list<OpportunityLineItem> oppLines                    {get; set;}
    
    public integer setPageSize                                   {get; set;}
    public integer recordNumber                                  {get; set;}
    public integer numberOfAttachments                           {get; set;}
    
    public boolean oldWorldInvoiceMessage                        {get; set;}
    
    public id oldWorldInvoiceOppID                               {get; set;}
    
    public string oldWorldInvoiceOppName                         {get; set;}
    
    
    public tncInCompanyTransferIterator (integer pageSize, Id oppId){
        
        transferEvents = new list<tncEventsWrapper>();
        transferEventsPager = new list<tncEventsWrapper>();
        list<id> oplIds = new list<id>();
        list<string> subQueries = new list<string>();
        list<string> relatedFields = new list<string>();
        
        subQueries.add('SELECT Current_Liability__c FROM purchase_orders__r');
        subQueries.add('SELECT Id,Trainer_Name__c, Trainer__r.User__r.Email FROM BSC_Event_Trainers__r');
        subQueries.add('SELECT id,Status__c, OPL_ID__c, Opportunity__c, Type__c FROM R00N50000001mIaiEAE__r');
        subQueries.add('SELECT Id FROM Audit_Outcomes__r');
        
        relatedFields.add('Opportunity__r.Number_of_Opportunity_Products__c');
        relatedFields.add('Product__r.Name');
        relatedFields.add('Opportunity__r.Opportunity_Number__c');
        relatedFields.add('Opportunity__r.StageName');
        relatedFields.add('Opportunity__r.Using_one_to_one_invoicing__c');
        relatedFields.add('Transfer_Cancellation_Reason__r.Name');
        //relatedFields.add('Special_Event__c.Customer_Cancellation_Transfer_Date__c');
        
        list<string> status = new list<string>{'Confirmed', 'To Be Transferred', 'Requested'};
        
        string query = Utilities.getSOQLQuery('Special_Event__c', relatedFields, subQueries);
        query += ' WHERE ';
        query += '(Status__c =\'Confirmed\' or ';
        query += ' (Status__c =\'To Be Transferred\' and Transferred_To__c = null)) ';
        query += 'AND Opportunity__c = :oppId';
        system.debug(query);
        for (Special_Event__c event : Database.query(query)){
            
            transferEvents.add(new tncEventsWrapper(false,event));
            
            for (Special_Event_Booking__c booking : event.R00N50000001mIaiEAE__r){
                oplIDs.add(id.valueof(booking.OPL_ID__c));
            }
            
            if (event.Opportunity__r.Using_one_to_one_invoicing__c == 'No' && oldWorldInvoiceMessage == false){ 
                oldWorldInvoiceMessage = true;
                oldWorldInvoiceOppID = event.Opportunity__c;
                oldWorldInvoiceOppName = event.Opportunity__r.Opportunity_Number__c;
            }
        }
        
        //defaulting to [0] as there will always be atleast 1 event, as this comes from a opp or a event record.
        try{
            numberOfAttachments  = (integer)[select count(Id) totalattachments from Attachment where ParentId = :transferEvents[0].event.Opportunity__c][0].get('totalattachments');
        }
        catch (Exception e){
            numberOfAttachments = 0;
        }
        
        oppLines = [select  unitprice, 
                    	   	id, 
                    		pricebookentry.product2.name, 
                    		Quantity, OpportunityId, 
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
                    where id in :oplIDs];
        
        //Assigning OPL to Event
        for (tncEventsWrapper wrapper : transferEvents){
            for (OpportunityLineItem opl : oppLines){
                for (Special_Event_Booking__c booking : wrapper.event.R00N50000001mIaiEAE__r){
                    if (string.valueof(opl.id) == booking.OPL_ID__c){
                        wrapper.opportunityLineItem = opl;
                        break;
                    }
                }
            }
        }
        
        system.debug('transferEvents ' + transferEvents);
        
        setPageSize = pagesize;
        recordNumber = 0;
    }
    
    /*
* checks if the next page is available.
*/
    public boolean hasNext(){ 
        if(recordNumber >= transferEvents.size()) {
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
    public List<tncEventsWrapper> next(){
        
        transferEventsPager = new List<tncEventsWrapper>(); 
        integer startNumber = 0;
        
        if(hasNext()) {
            if(transferEvents.size() <= (recordNumber + setPageSize)){
                startNumber = recordNumber;
                recordNumber = transferEvents.size();
            } else {
                recordNumber = (recordNumber + setPageSize);
                startNumber = (recordNumber - setPageSize);
            }
            
            for(integer start = startNumber; start < recordNumber; start++) {
                transferEventsPager.add(transferEvents[start]);
            }
        } 
        
        return transferEventsPager;
    }
    
    /*
     * Loads previous set of records
    */
    public List<tncEventsWrapper> previous(){
        
        integer size = transferEvents.size(); 
        transferEventsPager = new list<tncEventsWrapper>(); 
        
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
            transferEventsPager.add(transferEvents[start]);
        } 
        
        return transferEventsPager;
    }
    
    
}