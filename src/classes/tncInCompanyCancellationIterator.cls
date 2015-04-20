/*
Created to support pagination and selection of events records for Transfer and Cancellations project
This Class is used in tncInCompanyCancellationController class.
*/

public class tncInCompanyCancellationIterator implements Iterator<List<tncEventsWrapper>>{
    
    // Used to store the original events listing.
    public List<tncEventsWrapper> eventsList          {get; set;}
    
    // Used to store the events that are needed during paging
    public List<tncEventsWrapper> eventsListRequested {get; set;}
    
    //Used to dynamically set the page size.
    public integer setPageSize                        {get; set;}
    
    //Holds Current record number
    integer recordNumber                              {get; set;}
    
    // holds the list of Opp lines for the selected opp or event 
    public list<OpportunityLineItem> oppLines         {get; set;}
    
    //public integer numberOfAttachments                {get; set;}
    public boolean oldWorldInvoiceMessage             {get; set;}
    public id oldWorldInvoiceOppID                    {get; set;}
    public string oldWorldInvoiceOppName              {get; set;}
    
    /*
     * Constructor. 
     * accepts queryfilter as a parameter, if none passed limits the number of records to 20.
     * Populates the eventsList public property.
    */
    public tncInCompanyCancellationIterator(string queryfilter, integer pagesize){
        eventsList = new List<tncEventsWrapper>();
        eventsListRequested = new List<tncEventsWrapper>();
        
        if (queryFilter == ''){
            queryFilter = 'where status__c in (\'Confirmed\',\'Resourced\', \'Agreed\',\'Allocating\',\'To be Cancelled\')';
        } else {
            queryFilter += ' and status__c in (\'Confirmed\',\'Resourced\', \'Agreed\',\'Allocating\',\'To be Cancelled\')';
        }
        
        //pulling all the child relationships that need to be updated by the process, to save querying further along the process.
        string query = '';
        query += 'SELECT name, Status__c, Delegate_Fees__c, StartDate__c, Product__r.Name, Total_Variable_Costs__c, Trainer_Fees__c,  Opportunity__r.Number_of_Opportunity_Products__c,';
        query += 'Total_Fixed_Costs__c, Stage__c, Certificate_Course_Name__c, EndDate__c, Opportunity__c, Customer_Cancellation_Transfer_Date__c , Opportunity__r.Opportunity_Number__c, Opportunity__r.StageName, Product__c, Account_Name__c, Venue_Name__c, Opportunity__r.Using_one_to_one_invoicing__c, ';
        query += 'Transfer_Cancellation_Reason__r.Name, Transfer_Cancellation_Reason__c, (SELECT Current_Liability__c FROM purchase_orders__r ), Transfer_Cancellation_Notes__c ,';
        query += '(SELECT Id,Trainer_Name__c, Trainer__r.User__r.Email FROM BSC_Event_Trainers__r), ';
        query += '(SELECT id,Status__c, OPL_ID__c, Opportunity__c,Type__c FROM R00N50000001mIaiEAE__r), '; /* R00N50000001mIaiEAE__r is the Special_Event_Booking__c relation */
        query += '(SELECT Id FROM Audit_Outcomes__r)  ';
        query += 'FROM Special_Event__c ' + queryfilter;
        system.debug(query);
        
        list<id> oplIds = new list<id>();
        
        
                
        for (Special_Event__c event : Database.query(query)){
            eventsList.add(new tncEventsWrapper(false,event));
            
            for (Special_Event_Booking__c booking : event.R00N50000001mIaiEAE__r){
                oplIDs.add(id.valueof(booking.OPL_ID__c));
            }
            
            if (event.Opportunity__r.Using_one_to_one_invoicing__c == 'No'&& oldWorldInvoiceMessage == false){ 
                oldWorldInvoiceMessage = true;
                oldWorldInvoiceOppID = event.Opportunity__c;
                oldWorldInvoiceOppName = event.Opportunity__r.Opportunity_Number__c;
            }
            
        }
        
        //defaulting to [0] as there will always be atleast 1 event, as this comes from a opp or a event record.
        //numberOfAttachments  = (integer)[select count(Id) totalattachments from Attachment where ParentId = :eventsList[0].event.Opportunity__c][0].get('totalattachments');
        
        oppLines = [select  unitprice, 
							id, 
							pricebookentry.product2.name, 
							Quantity, 
							OpportunityId, 
							PricebookEntry.Product2Id, 
							PricebookEntry.Product2.Cancellation_Fee_Product__c, 
							PricebookEntry.pricebook2id, 
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
        
        for (tncEventsWrapper wrapper : eventsList){
            for (OpportunityLineItem opl : oppLines){
                for (Special_Event_Booking__c booking : wrapper.event.R00N50000001mIaiEAE__r){
                    if (string.valueof(opl.id) == booking.OPL_ID__c){
                        wrapper.opportunityLineItem = opl;
                        break;
                    }
                }
            }
        }
        
        setPageSize = pagesize;
        recordNumber = 0;
    }
    
    /*
     * checks if the next page is available.
    */
    public boolean hasNext(){ 
        if(recordNumber >= eventsList.size()) {
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
        
        eventsListRequested = new List<tncEventsWrapper>(); 
        integer startNumber = 0;
        
        if(hasNext()) {
            if(eventsList.size() <= (recordNumber + setPageSize)){
                startNumber = recordNumber;
                recordNumber = eventsList.size();
            } else {
                recordNumber = (recordNumber + setPageSize);
                startNumber = (recordNumber - setPageSize);
            }
            
            for(integer start = startNumber; start < recordNumber; start++) {
                eventsListRequested.add(eventsList[start]);
            }
        } 
        
        return eventsListRequested;
    }
    
    /*
     * Loads previous set of records
    */
    public List<tncEventsWrapper> previous(){
        
        integer size = eventsList.size(); 
        eventsListRequested = new list<tncEventsWrapper>(); 
        
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
            eventsListRequested.add(eventsList[start]);
        } 
        
        return eventsListRequested;
    }
    
}