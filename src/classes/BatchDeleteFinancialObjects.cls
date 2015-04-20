global class BatchDeleteFinancialObjects implements Database.Batchable<sObject> {
    /*
    Batch Process to delete the Financial Junction Objects
    */
    
    global final String Query;
	global final string complete = 'Complete';
    
    global BatchDeleteFinancialObjects(){
        
        Query = 'Select id from Financial_Transactional_Header_Data__c where sales_invoice__r.c2g__InvoiceStatus__c = :complete and sales_invoice__r.lastmodifieddate = LAST_N_DAYS:30';  
    }

    global BatchDeleteFinancialObjects(Integer size){
        Query = 'Select id from Financial_Transactional_Header_Data__c where sales_invoice__r.c2g__InvoiceStatus__c = :complete and sales_invoice__r.lastmodifieddate = LAST_N_DAYS:30 LIMIT ' + size;  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Financial_Transactional_Header_Data__c> scope)
    {
        List<Financial_Transactional_Header_Data__c> flh = [Select Id From Financial_Transactional_Header_Data__c Where Id IN :scope];
        if(flh.size()>0){
            delete flh;
        }
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

        String[] toAddresses = new String[] {a.CreatedBy.Email, 'it.helpdesk@britsafe.org'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('BatchDeleteFinancialObjects ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }

    public static testMethod void testBatchDeleteFinancialObjects()
    {
        Test.startTest();
        BatchDeleteFinancialObjects batch = new BatchDeleteFinancialObjects(1);     
        Database.executeBatch(batch,1);
        Test.stopTest();
    }
    
}