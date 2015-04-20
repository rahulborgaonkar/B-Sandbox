global class ScheduleSubscriptionRenewalBatch implements Schedulable {
    
    // First Stage create subscription 
    private String subRenewalQuery = 'SELECT Id FROM Subscription__c  WHERE Renewal_Opportunity__c = true  AND Renewal_Opportunity_Created__c <> true AND Status__c = \'Current - Renewing\' AND (Includes_Membership_Product__c = true OR Includes_Publication_Product__c = true OR Includes_RCP_Product__c = true OR Includes_E_Delivery_Product__c = true OR Includes_SUSA_Product__c = true) AND Create_Renewal_Objects_on__c <= TODAY AND Subsequent_Subscription__c = null';

    // Secound Stage create subscription invoice 
    private String subRenewalInvoiceQuery = 'SELECT Id, Opportunity__c FROM Subscription__c WHERE (Status__c = \'Pending - Not Paid\' OR Status__c = \'Current - Not Paid\') AND (Includes_Membership_Product__c = true OR Includes_Publication_Product__c = true OR Includes_RCP_Product__c = true OR Includes_E_Delivery_Product__c = true OR Includes_SUSA_Product__c = true) AND First_Reminder_Date__c <= TODAY AND Renewal_Sales_Invoice__c = null AND Auto_Create_Sales_Invoice__c = true';
    
    global void execute(SchedulableContext SC) {
        
        // START: Update subscriptions that need need to be updates from "Current" to "Current - Renewing"
        System.debug('** Updating subscriptions from "Current" to "Current - Renewing" if needed');
        
        // Disable the Subscription account flag triggers. This is because the subscription
        // is still a current subscription so won't effect the flags.
        ApexCodePatrol.disable('AccountSubscriptionFlags');

        List<Subscription__c> subList = new List<Subscription__c>([SELECT 
                                        Id,
                                        Status__c, 
                                        First_Reminder_Date__c 
                                    FROM
                                        Subscription__c 
                                    WHERE 
                                        Status__c = 'Current'
                                        AND Create_Renewal_Objects_on__c <= TODAY]);

        for(Subscription__c sub : subList){
            sub.Status__c = 'Current - Renewing';
        }
        
        if (subList.size() > 0){
            update subList;
        }
        
        ApexCodePatrol.enable('AccountSubscriptionFlags');
        // END: Update subscriptions that need need to be updates from "Current" to "Current - Renewing"
        
        // START: Create new opps and cloned subscriptions
        System.debug('** running ScheduleSubscriptionRenewalBatch');
        System.debug('** subRenewalQuery: ' + subRenewalQuery);
        
        SubscriptionRenewalBatch subsRenewal = new SubscriptionRenewalBatch(subRenewalQuery); 
        ID batchprocessid = Database.executeBatch(subsRenewal, 1);
        
        // END: Create new opps and cloned subscriptions
        
        // START: Create invoice 
        System.debug('** running SubscriptionRenewalBatchInvoicesAndPacks');
        System.debug('** subRenewalQuery: ' + subRenewalInvoiceQuery);

        SubscriptionRenewalBatchInvoicesAndPacks subsInvRenewal = new SubscriptionRenewalBatchInvoicesAndPacks(subRenewalInvoiceQuery); 
        ID batchprocess2id = Database.executeBatch(subsInvRenewal, 1);
        
        // END: Create invoice
        
        
    }
    
    
}