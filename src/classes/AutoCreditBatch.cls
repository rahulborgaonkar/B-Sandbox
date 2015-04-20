/*

VS : This batch generate credit notes for the opps that meets the criteria
     Generates 10 credit notes at a time.
     for testing purpose, pass the oppId to teh constructor
     invCompany is set from the AutoInvoiceBatch or the AutoGenerateFinancialTransactions
     
     once there are no more credit notes, calls  AutoInvCreditMatchBatch to match invoices and credit notes
     
*/

global class AutoCreditBatch implements Database.Batchable<sObject>{

    id opportunityId;  
    string invoiceCompany;
    
    global AutoCreditBatch(id oppId, string invCompany){
        opportunityId = oppId;
        invoiceCompany = invCompany;
    }

    
    global Database.QueryLocator  start(Database.BatchableContext BC){
        
        datetime oppsLastModified = datetime.now();
        
        if (AutoInvoiceSettings.autoInvoiceDelay > 0)
            oppsLastModified = oppsLastModified.addHours(AutoInvoiceSettings.autoInvoiceDelay * -1);
        
        system.debug('finding opps that were modified before ' + oppsLastModified);
        
        if (opportunityId == null)
            return Database.getQueryLocator([select id,
                                                    Latest_Invoice__c
                                               from opportunity 
                                              where Finance_to_Credit_Opp__c = true 
                                                and Invoice_Status__c = 'To Be Credited'
                                                and Using_one_to_one_invoicing__c = 'Yes' 
                                                and Invoice_Company__r.Name = :invoiceCompany
                                                and Latest_Invoice__r.Is_Credited_In_Full__c = false
                                                and Exclude_from_Auto_Invoicing__c = false 
                                                and Website_Order_Id__c = null
                                                and lastmodifieddate < :oppsLastModified
                                              limit 10]);
        //and Account.billingCountry in ('United Kingdom','England' ,'Wales' , 'Northern Ireland' , 'Scotland' , 'UK')
        else
            return Database.getQueryLocator([select id,
                                                    Latest_Invoice__c
                                               from opportunity 
                                              where id = : opportunityId
                                              limit 1]);
    }
     
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        system.debug('invoiceCompany ' + invoiceCompany);
        
        list<string> info = new list<string>();
        info.add(AutoInvoiceSettings.emailNotificationTo);
        AutoInvoiceHelper.sendMail('Started CreditNote Generation', 'Opportunities to Credit: ' + scope, info);
        
        list<id> invoicesToCredit = new list<id>();
        
        for (opportunity opp : (list<opportunity>)scope){
            invoicesToCredit.add(opp.Latest_Invoice__c);
        }
        system.debug('scope: ' + scope);
        List<id> creditNotes = AutoInvoiceHelper.createCreditNotes(invoicesToCredit, AutoInvoiceSettings.autoPostCreditNotes, invoiceCompany);
        
        
        if (creditNotes!= null &&  creditNotes.size() > 0){
            
            AutoInvoiceHelper.sendMail('Finished CreditNote Generation', 'Following Credit Notes Processed: ' + string.valueof(creditNotes) + ' for '+invoiceCompany, info);
        } else {
            AutoInvoiceHelper.sendMail('Finished CreditNote Generation', 'No Credit Notes Processed for ' +invoiceCompany, info);
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
        system.debug('executing invoice credit match batch for BSC..');         
        AutoInvCreditMatchBatch acmb = new AutoInvCreditMatchBatch(invoiceCompany);
        database.executeBatch(acmb);
    
    }
}