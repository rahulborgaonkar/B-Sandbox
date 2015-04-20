global class BatchUpdateInvoiceRetropective implements Database.Batchable<sObject>
{
    global final String Query;
    global integer Summary;
    public static boolean isTest = false;
    
    global BatchUpdateInvoiceRetropective(Integer size)
    {
        // Query='Select id, opl_id__c, beb__c, sl__c from c2g__codaInvoiceLineItem__c where opl_id__c != null limit '+ size ;
        if (isTest)
           Query = 'Select o.id, o.pricebookentry.product2id,o.Opportunity.Invoice_Paid_Date__c, o.Opportunity.StageName, o.OpportunityId, o.LastModifiedDate, o.Invoice_Paid_Date__c, o.Invoice_Date__c From OpportunityLineItem o where o.Invoice_Paid_Date__c = 2011-03-22 limit '+ size;
        else
           Query = 'Select o.id, o.pricebookentry.product2id,o.Opportunity.Invoice_Paid_Date__c, o.Opportunity.StageName, o.OpportunityId, o.LastModifiedDate, o.Invoice_Paid_Date__c, o.Invoice_Date__c From OpportunityLineItem o where o.Invoice_Paid_Date__c = 2011-03-23';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope)
    {   
        // List<c2g__codaInvoiceLineItem__c> invoiceList=[Select id, opl_id__c, beb__c, sl__c from c2g__codaInvoiceLineItem__c where opl_id__c != null];
        /*List<c2g__codaInvoiceLineItem__c> invUpdate = new List<c2g__codaInvoiceLineItem__c>();
        for (c2g__codaInvoiceLineItem__c inv:scope)
        {
            invUpdate.add(inv);
        }
        InvoiceLineItemsTriggerMethods.updateOppLineItemSubsLineBookingEvent(invUpdate);*/
        
        for (OpportunityLineItem opl:scope)
        {    
            c2g__codaInvoiceLineItem__c invdate = [Select LastModifiedDate from c2g__codaInvoiceLineItem__c where OPL_ID__c =:opl.id and c2g__Product__c = :opl.pricebookentry.product2id and c2g__Invoice__r.c2g__InvoiceStatus__c!='Discarded' limit 1];
            opportunity ops = [Select id from opportunity where id = :opl.OpportunityId];
            If (invdate<>null)
            {
                opl.Invoice_Paid_Date__c = date.newinstance(invdate.LastModifiedDate.year(), invdate.LastModifiedDate.month(), invdate.LastModifiedDate.day());
                ops.Invoice_Paid_Date__c = opl.Invoice_Paid_Date__c;
                update ops;
            }
            // Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        }
        
        update scope;
        
            
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
        mail.setSubject('BatchUpdateInvoiceRetropective ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }   

    public static testMethod void testBatchUpdateInvoice()
    {
        Test.startTest();
        BatchUpdateInvoiceRetropective.isTest = true;
        BatchUpdateInvoiceRetropective batch = new BatchUpdateInvoiceRetropective(1);       
        Database.executeBatch(batch,1);
        Test.stopTest();
    }  
    
}