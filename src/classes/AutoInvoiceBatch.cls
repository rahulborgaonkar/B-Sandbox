/*

VS : This batch is called from AutoInvoiceSchedule
     On start of the batch, check is done for the invCompany(in constructor) is passed from AutoInvoiceSchedule and AutoInvCreditMatchBatch. 
     If the invCompany is Complywise Ltd
        for the scheduled user we change the current FF company to Complywise using  AutoSwitchFFCompany.switchFFCompany(userinfo.getUserId(), 'FF British Safety Council');
     
     the oppId in the constructor is only used for test purpose.
     
     Only 10 invoices are generated based on the query (if the oppId is not passed). 

     calls AutoInvoiceHelper.bulkCreateInvoiceFromOpps to bulk generate invoices.
     
     if invoices are created calls the AutoGenerateFinancialTransactions to generate financial lines for reporting purposes
     else calls the credit notes batch (AutoCreditBatch)
     
*/

global class AutoInvoiceBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    id opportunityId; 
 
    global string invoiceCompany;
    global set<id> invoices;
    
    global AutoInvoiceBatch(id oppId, string invCompany){
        opportunityId = oppId;
        invoiceCompany = invCompany;
    }
    
    public class invoiceException extends Exception{}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('auto Invoice Batch Started');
        
        datetime oppsLastModified = datetime.now();
        
        if (invoiceCompany == 'Complywise Ltd')
            AutoSwitchFFCompany.switchFFCompany(userinfo.getUserId(), 'FF British Safety Council');
        
        if (AutoInvoiceSettings.autoInvoiceDelay > 0)
            oppsLastModified = oppsLastModified.addHours(AutoInvoiceSettings.autoInvoiceDelay * -1);
         
        system.debug('finding opps that were modified before ' + oppsLastModified);
        
        if (opportunityId == null)
            return Database.getQueryLocator([Select o.Id, 
                                                    LastModifiedDate, 
                                                    (select id from c2g__Invoices__r where is_credited_in_full__c=false and c2g__InvoiceStatus__c in ('Complete','InProgress') order by lastmodifieddate desc),
                                                    T_C_Variation_Approved__c,
                                                    T_C_Price_Variation_Products__c,
                                                    StageName,
                                                    Owner.Email
                                               From Opportunity o 
                                              where Finance_to_Invoice_Opp__c = true
                                                and StageName = 'Booking Received'
                                                and Invoice_Status__c = 'To Be Invoiced'    
                                                and Type not in ('Subscription Renewal')  
                                                and Using_one_to_one_invoicing__c = 'Yes' 
                                                and Amount > 0
                                                and Available_For_Invoice__c = true
                                                and Exclude_from_Auto_Invoicing__c = false
                                                and Website_Order_Id__c = null 
                                                and Invoice_Company__r.Name = :invoiceCompany
                                                and lastmodifieddate < :oppsLastModified
                                              limit 10]);
        //and Account.billingCountry in ('United Kingdom','England' ,'Wales' , 'Northern Ireland' , 'Scotland' , 'UK') 
        else
            return Database.getQueryLocator([Select o.Id, 
                                                    LastModifiedDate, 
                                                    (select id from c2g__Invoices__r order by lastmodifieddate desc) ,
                                                    T_C_Variation_Approved__c,
                                                    T_C_Price_Variation_Products__c,
                                                    StageName,
                                                    Owner.Email
                                               From Opportunity o 
                                              where Finance_to_Invoice_Opp__c = true
                                                and Website_Order_Id__c = null
                                                and id = :opportunityId 
                                              limit 1]);            
        
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<string> info = new list<string>();
        info.add(AutoInvoiceSettings.emailNotificationTo);
        
        
        list<Id> oppIds = new List<id>();
        list<Opportunity> oppToUpdate = new list<opportunity>();
        
        for (opportunity opp : (list<Opportunity>)scope){
            oppIds.add(opp.id);
        }

        try{
            AutoInvoiceHelper.sendMail('Started Invoice Generation', 'Opps to be invoiced: ' + scope , info);
            list<Id> invs = AutoInvoiceHelper.bulkCreateInvoiceFromOpps(oppIds, AutoInvoiceSettings.autoPostInvoices, invoiceCompany);
            invoices = new set<id>(invs);
            
            system.debug('Opps to be invoiced: ' + oppIds); 
            update oppToUpdate;
            
            AutoInvoiceHelper.sendMail('Finished Invoice Generation', 'Invoices created: ' + string.valueof(invs), info);
        } catch(Exception e) {
            AutoInvoiceHelper.sendMail('AI Invoice Generation Error', e.getMessage() + ' ' + e.getCause() + ' ' + e.getStackTraceString(), info);
            //throw new invoiceException(e.getMessage());
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('invoices: ' + invoices);
        
        if (invoices == null || invoices.Size() == 0){
            system.debug('executing credit note batch for BSC..');
            AutoCreditBatch acb = new AutoCreditBatch(null, invoiceCompany);
            database.executeBatch(acb);
        } else {
            AutoGenerateFinancialTransactions aft = new AutoGenerateFinancialTransactions(invoices, invoiceCompany);
            database.executeBatch(aft,1);
        }
    }
}