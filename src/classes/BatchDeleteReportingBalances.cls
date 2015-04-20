global class BatchDeleteReportingBalances implements Database.Batchable<SObject>
{
    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        delete scope;
        DataBase.emptyRecycleBin(scope);
    }

    global void finish(Database.BatchableContext BC){
   }
}