global class BatchCreateInvoices implements Database.Batchable<sObject> {

	global final String Query;
	
	global BatchCreateInvoices(Integer size){
		query = 'SELECT Id FROM Opportunity WHERE create_invoice__c = True AND Latest_Invoice__c = null AND Invoice_Company__r.Name = \'Complywise Ltd\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Opportunity> scope){
		
		System.debug('FJP Executing create invoice batch based on: '+scope);
		
		for (Opportunity opp : scope){
			System.debug('FJP Creating invoice for opp: '+opp.Id);
			FinanceHelper.createInvoiceFromOpp(opp.Id, true);
		}
		
	}
	
	global void finish(Database.BatchableContext BC){
		
		AsyncApexJob a = [
			SELECT
				Id,
				Status,
				NumberOfErrors,
				JobItemsProcessed,
				TotalJobItems,
				MethodName,
				JobType,
				CreatedBy.Email
			FROM
				AsyncApexJob
			WHERE
				Id = : BC.getJobId()];
		
		Error_Log__c err = new Error_Log__c();
		
		err.Function__c = 'BatchCreateInvoices';
		if (a.NumberOfErrors > 0){
			err.Severity__c = 'Medium';
		}else{
			err.Severity__c = 'Message';
		}
		err.Debug_Text__c = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+
			a.NumberOfErrors + ' failures.';
		
		insert err;
				
	}
	
	
	public static testMethod void testBatchCreateInvoices(){
		Test.startTest();
		BatchCreateInvoices batch = new BatchCreateInvoices(1);		
		Database.executeBatch(batch,1);
		Test.stopTest();
	}
	
}