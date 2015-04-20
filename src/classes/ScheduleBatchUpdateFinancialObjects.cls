global class ScheduleBatchUpdateFinancialObjects implements Schedulable
{
    global void execute(SchedulableContext SC){
        //where lastmodifieddate = LAST_N_DAYS:30 
        Integer recCount = [Select count() From c2g__codaInvoice__c where c2g__InvoiceStatus__c = 'Complete' and lastmodifieddate = LAST_N_DAYS:30];
        BatchUpdateFinancialObjects batch = new BatchUpdateFinancialObjects(recCount);
        Database.executeBatch(batch, 1);
    }
}