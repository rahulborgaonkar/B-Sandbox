/*

VS : This batch matches Invoices to credit notes that were generated as part of the AutoCreditBatch
does 3 at a time  and reschedules the batch if there are more to be matched
once all are done, run the auto invoiceing on Complywise ff company based on AutoInvoiceSettings.cwLastExecution


*/

global class AutoInvCreditMatchBatch implements Database.Batchable<sObject>, Database.Stateful{  
    
    global id creditNoteId;
    global string invoiceCompany;
    
    global AutoInvCreditMatchBatch(string invCompany){
        invoiceCompany = invCompany;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if (creditNoteId == null)
            return Database.getQueryLocator([select id, Name,
                                             c2g__Invoice__r.Name, 
                                             c2g__Account__c, 
                                             c2g__Period__c 
                                             from c2g__codaCreditNote__c 
                                             where Match_Invoice__c = true
                                             and c2g__CreditNoteStatus__c = 'Complete'
                                             and c2g__OwnerCompany__r.name = :invoiceCompany
                                             and c2g__Transaction__c in (select c2g__Transaction__c from c2g__codaTransactionLineItem__c where c2g__MatchingStatus__c ='Available')
                                             limit 1]);
        else
            return Database.getQueryLocator([select id, Name,
                                             c2g__Invoice__r.Name, 
                                             c2g__Account__c, 
                                             c2g__Period__c 
                                             from c2g__codaCreditNote__c 
                                             where Match_Invoice__c = true
                                             and c2g__CreditNoteStatus__c = 'Complete'
                                             and c2g__OwnerCompany__r.name = :invoiceCompany
                                             and c2g__Transaction__c in (select c2g__Transaction__c from c2g__codaTransactionLineItem__c where c2g__MatchingStatus__c ='Available')
                                             and id = :creditNoteId]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<string> info = new list<string>();
        info.add(AutoInvoiceSettings.emailNotificationTo);
        AutoInvoiceHelper.sendMail('Started Auto Invoice Credit Match Process', 'Credit notes to Match: ' + scope , info);
        
        list<c2g__codaCreditNote__c> listCN = new list<c2g__codaCreditNote__c>();
        for (c2g__codaCreditNote__c cn : (list<c2g__codaCreditNote__c>)scope){
            try{
                AutoInvoiceHelper.InvoiceCreditMatch(cn.c2g__Invoice__r.Name, cn.c2g__Account__c, cn.c2g__Period__c);
                cn.Match_Invoice__c = false;
            } catch (exception e){
                cn.Processed__c = 'Manually';
                cn.Match_Invoice__c = false;
                
                AutoInvoiceHelper.sendMail('Auto Match Invoice Credit Process: Failed Match', 'Failed to Match Invoice: ' + cn.c2g__Invoice__r.Name +' Credit Note ' + cn.Name + 'Error: ' + e.getMessage() , info);
            }
            
            listCN.add(cn);
        }
        if (listCN.size() > 0)
            update listCN;
        
        AutoInvoiceHelper.sendMail('Finished Auto Invoice Credit Match Process', '' , info);
    }
    
    global void finish(Database.BatchableContext BC){
        
        if (creditNoteId == null){
            
            list<c2g__codaCreditNote__c> checkforMore =  [select id
                                                          from c2g__codaCreditNote__c 
                                                          where Processed__c = 'Automatically'
                                                          and c2g__CreditNoteStatus__c = 'Complete'
                                                          and Match_Invoice__c = true
                                                          and c2g__CreditNoteStatus__c = 'Complete'
                                                          and c2g__OwnerCompany__r.name = :invoiceCompany
                                                          and c2g__Transaction__c in (select c2g__Transaction__c from c2g__codaTransactionLineItem__c where c2g__MatchingStatus__c ='Available') limit 1];
            if (checkforMore.size() > 0){
                AutoInvCreditMatchBatch acmb = new AutoInvCreditMatchBatch(invoiceCompany);
                database.executeBatch(acmb);
            } else {
                datetime today = datetime.now();
                if (AutoInvoiceSettings.cwLastExecution.date() != today.date() &&  AutoInvoiceSettings.cwLastExecution.time() < today.time() && invoiceCompany == 'British Safety Council'){
                    AutoInvoiceHelper.setCWExecutionTime();
                    AutoInvoiceBatch aib = new autoInvoiceBatch(null, 'Complywise Ltd');
                    database.executeBatch(aib);
                } else if (c2g.CODACurrentCompanyDisplayController.getCompanyName().companyName == 'Complywise Ltd' && invoiceCompany == 'Complywise Ltd'){
                    AutoSwitchFFCompany.switchFFCompany(userinfo.getUserId(), 'FF Complywise Ltd');
                }
                
            }
        }
        
    }
    
}