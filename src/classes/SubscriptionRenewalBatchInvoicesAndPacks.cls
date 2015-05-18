global class SubscriptionRenewalBatchInvoicesAndPacks implements Database.Batchable<sObject>{

    global final String query;
    
    /* Constructor */
    global SubscriptionRenewalBatchInvoicesAndPacks(String q){
        query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('*** Batch start  ***');
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> subscriptionList) {
        
        // Create invoices (sublist, postInvoice = true)
        String result = SubscriptionRenewal.runSubscriptionRenewalInvPacks(subscriptionList, true);

        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('*** Batch finish ***');
    }
 
}