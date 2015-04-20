public class AutoInvoiceHistory {

	public static void createHistory(decimal invAmount, id opportunity, decimal oppAmount, string oppStage,
	                                 id creditNote, id invoice, string status, string type, string errorMessage, string emailTo){ 
		
		Invoice_History__c ih = new Invoice_History__c();
		ih.Invoice_Credit_Amount__c = invAmount;
		ih.Opportunity__c = opportunity;
		ih.Opportunity_Amount__c = oppAmount;
		ih.Opportunity_Stage__c = oppStage;
		ih.Sales_Credit_Note__c = creditNote;
		ih.Sales_Invoice__c = invoice;
		ih.Status__c = status;
		ih.Type__c = type;
		ih.Failure_Message__c = errorMessage;
		ih.Evaluate_delivery_Workflow__c = AutoInvoiceSettings.evaluateDeliveryWorkflow;
		ih.Email_to__c = emailTo;
		insert ih;
	}

    
}