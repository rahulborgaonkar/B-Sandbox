global class FFTransactionLineFastLoad implements Schedulable{

    public String CRON_EXP = '0 0 0 3 9 ? 2022';

    @ReadOnly //this lets me query more than 50k records only using this to speed bulk data load services from 20 minutes to 1 minute
    global void execute(SchedulableContext sc){
        //list<Financial_Transactional_Line_Data__c > ffData = [Select f.SystemModstamp, f.Subscription_Type__c, f.Subscription_Status__c, f.Subscription_Start_Date__c, f.Subscription_Ref__c, f.Subscription_Product_Codes__c, f.Subscription_Line__c, f.Subscription_End_Date__c, f.Sales_invoice_Net_Line_amount__c, f.Sales_Invoice_Line_Item__c, f.Product__c, f.Payment_Status__c, f.Opportunity__c, f.Opportunity_Number__c, f.OPL_ID__c, f.Name, f.LastModifiedDate, f.LastModifiedById, f.IsDeleted, f.Invoice_Number__c, f.Invoice_Date__c, f.Id, f.Financial_Transactional_Header_Data__c, f.CurrencyIsoCode, f.Credit_Note_Status__c, f.CreatedDate, f.CreatedById, f.ConnectionSentId, f.ConnectionReceivedId, f.BSC_Event_Start_Date__c, f.BSC_Event_End_Date__c, f.BSC_Event_Booking__c, f.Account_Name__c From Financial_Transactional_Line_Data__c f];
        list<Financial_Transactional_Line_Data__c > ffData = [Select f.SystemModstamp, f.Subscription_Type__c, f.Subscription_Status__c, f.Subscription_Start_Date__c, f.Subscription_Ref__c, f.Subscription_Product_Codes__c, f.Subscription_Line__c, f.Subscription_End_Date__c, f.Sales_invoice_Net_Line_amount__c, f.Account_Name__c From Financial_Transactional_Line_Data__c f];
        system.debug(ffData.size());
    }
    
}