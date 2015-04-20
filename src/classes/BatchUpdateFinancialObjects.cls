global class BatchUpdateFinancialObjects implements Database.Batchable<sObject>
    /*
    Batch Process to populate the Financial Junction Objects
    */
{
    global final String Query;
    public List<Integer> maxLevel = new List<Integer>();
    public static boolean isTest = false;
	global final string complete = 'Complete';
    
    global BatchUpdateFinancialObjects(Integer size)
    {
        if (isTest)
            Query = 'Select c2g__PaymentStatus__c, c2g__InvoiceStatus__c, name, c2g__transaction__c, c2g__InvoiceDate__c, c2g__OutstandingValue__c From c2g__codaInvoice__c where c2g__InvoiceStatus__c = :complete and lastmodifieddate = LAST_N_DAYS:30 LIMIT ' + size;
        else
            Query = 'Select c2g__PaymentStatus__c, c2g__InvoiceStatus__c, name, c2g__transaction__c, c2g__InvoiceDate__c, c2g__OutstandingValue__c From c2g__codaInvoice__c where c2g__InvoiceStatus__c = :complete and lastmodifieddate = LAST_N_DAYS:30 LIMIT ' + size;            
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> scope)
    {
        Set<Id> resultIds = (new Map<Id,SObject>(scope)).keySet();
        FinancialTransactionPopulationMethods.populateFinancialJunctionObject(resultIds);
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
        mail.setSubject('BatchUpdateFinancialObjects ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }   

    public static testMethod void testBatchUpdateInvoice()
    {
        Test.startTest();
        BatchUpdateFinancialObjects.isTest = true;
        BatchUpdateFinancialObjects batch = new BatchUpdateFinancialObjects(1);     
        Database.executeBatch(batch,1);
        Test.stopTest();
    }  
    
    

}