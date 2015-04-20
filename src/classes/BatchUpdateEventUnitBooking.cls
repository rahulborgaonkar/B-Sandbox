global class BatchUpdateEventUnitBooking implements Database.Batchable<sObject>
/*
  Batch Process to run BSC Event Unit Booking update
*/
{

    global final String Query;
    public List<Integer> maxLevel = new List<Integer>();
    public static boolean isTest = false;

    global BatchUpdateEventUnitBooking(Integer size)
    {
        if (isTest)
            Query = 'SELECT Event_Unit__r.special_event__c, Event_Unit__r.name, Event_Booking__r.special_event__c FROM Special_Event_Unit_Booking__c Where Event_Unit__c <> null and  Event_Booking__c <> null LIMIT ' + size;
        else
        {
            Query = 'SELECT Event_Unit__r.special_event__c, Event_Unit__r.name, Event_Booking__r.special_event__c FROM Special_Event_Unit_Booking__c Where Event_Unit__c <> null and  Event_Booking__c <> null LIMIT ' + size;
        }
            
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Special_Event_Unit_Booking__c> scope)
    {
        BSCEventUnitBookingUpdate.updateBscEventUnitBooking(scope);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [
            SELECT
                Id,
                Status,
                NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems,
                CreatedBy.Email
            FROM
                AsyncApexJob
            WHERE
                Id = : BC.getJobId()];
                
        String message = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+
            a.NumberOfErrors + ' failures.';
        
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Email the current user regarding the completion of the process
        user getCurrentUser = [Select u.email from user u where u.id = :UserInfo.getUserId()];
        // system.debug(getCurrentUser.email);
        // String[] toAddresses = new String[] {a.CreatedBy.Email, getCurrentUser.email};
        String[] toAddresses = new String[] {a.CreatedBy.Email, 'it.helpdesk@britsafe.org'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('BSCEventUnitBookingUpdate ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }   

    public static testMethod void testBatchUpdateInvoice()
    {
        Test.startTest();
        BatchUpdateEventUnitBooking.isTest = true;
        BatchUpdateEventUnitBooking batch = new BatchUpdateEventUnitBooking(1);     
        Database.executeBatch(batch,1);
        Test.stopTest();
    }  
    
    


}