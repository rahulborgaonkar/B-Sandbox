/*

VS : this batch generates financial transaction records for the invoices there were generated in AutoInvoiceBatch
     Generates lines for 3 invoices at a time due to soql limits
     goes round until financial transaction lines are generated for all invoices.
     Calls the AutoCreditBatch 

*/

global class AutoGenerateFinancialTransactions implements Database.Batchable<sObject>, Database.Stateful{
    
    set<id> invoiceIDs;
    string invoiceCompany;
    set<id> restInvoices;
    public boolean fromWs = false;
        
    global AutoGenerateFinancialTransactions(set<id> invoices, string invCompany){
        invoiceIDs = new set<id>();
        invoiceIDs = invoices;
        invoiceCompany = invCompany;
        restInvoices = new set<id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id from c2g__codaInvoice__c where id in :invoiceIds limit 1]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        set<id> threeInvoices = new set<id>();
      
        for (id invId : invoiceIDs){
            if (threeInvoices.size() < 3)
                threeInvoices.add(invid);
            else
                restInvoices.add(invid);
        }
        system.debug('threeInvoices: ' + threeInvoices);
        system.debug('restInvoices: ' + restInvoices);
        execControl.stopOppControls = true;
        FinancialTransactionPopulationMethods.populateFinancialJunctionObject(threeInvoices);
        
        list<string> info = new list<string>();
        info.add(AutoInvoiceSettings.emailNotificationTo);
        AutoInvoiceHelper.sendMail('Auto Generate Financial Transaction', 'Transactions records created for these invoices: ' + threeInvoices  , info);
    }
    
    global void finish(Database.BatchableContext BC){
        if (fromWS == false){
            system.debug('restInvoices: ' + restInvoices);
            if (restInvoices == null || restInvoices.size() == 0){
                system.debug('executing credit note batch for BSC..');
                AutoCreditBatch acb = new AutoCreditBatch(null, invoiceCompany);
                database.executeBatch(acb);
            } else {
                AutoGenerateFinancialTransactions aft = new AutoGenerateFinancialTransactions(restInvoices, invoiceCompany);
                database.executeBatch(aft,3);
            }
        }
    }
    
}