global class SubscriptionRenewalBatch implements Database.Batchable<sObject>{

    global final String query;
    
    /* Constructor */
    global SubscriptionRenewalBatch(String q){
        query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('*** Batch start  ***');
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> subscriptionList) {
        
        String result  = SubscriptionRenewal.runSubscriptionRenewals(subscriptionList);

    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('*** Batch finish ***');
    }
 
}