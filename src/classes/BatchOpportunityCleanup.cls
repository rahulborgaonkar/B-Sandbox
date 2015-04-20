global class BatchOpportunityCleanup implements Database.Batchable<sObject>
{
    global final String Query;
    global integer Summary;
    public static boolean isTest = false;
    
    global BatchOpportunityCleanup(Integer size)
    {
        if (isTest)
            Query='Select o.Id, o.OwnerId, o.Owner.isActive, o.CreatedBy.name, o.Account.OwnerId from Opportunity o Where o.Disable_re_assignment__c = False and o.Renewal_Opportunity__c = false and o.AccountId!=null and (o.isclosed = false or o.CloseDate > 2011-01-01) limit '+ size ;
        else
            Query='Select o.Id, o.OwnerId, o.Owner.isActive, o.CreatedBy.name, o.Account.OwnerId from Opportunity o Where o.Disable_re_assignment__c = False and o.Renewal_Opportunity__c = false and o.AccountId!=null and (o.isclosed = false or o.CloseDate > 2011-01-01)';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {   
        CleanUpUtilities.opportunitiesCleanup(scope);
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
        mail.setSubject('BatchOpportunityCleanup ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }   

    public static testMethod void testBatchUpdateInvoice()
    {
        Test.startTest();
        BatchOpportunityCleanup.isTest = true;
        BatchOpportunityCleanup batch = new BatchOpportunityCleanup(1);     
        Database.executeBatch(batch);
        Test.stopTest();
    }  
    
}