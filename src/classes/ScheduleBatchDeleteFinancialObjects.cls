global class ScheduleBatchDeleteFinancialObjects implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        //Integer recCount = [Select count() From Financial_Transactional_Header_Data__c];
        //BatchDeleteFinancialObjects batch = new BatchDeleteFinancialObjects(recCount);
        BatchDeleteFinancialObjects batch = new BatchDeleteFinancialObjects();
        Database.executeBatch(batch, 100);
    }
}