public with sharing class CustomInvoicePrint {
    
    Id recordId {get;private set;}
    
    public CustomInvoicePrint(ApexPages.StandardController controller){
        
        recordId = controller.getId();
        
    }
    /*
* GET BILLING CONTACT
*
* Tries to find the finance contact on the opportunity, if it can't be found it uses the Account
* Finance Contact
*/
    public String getBillingContact(){
        
        String result = '';
        
        c2g__codaInvoice__c inv = [SELECT 
                                   Id,
                                   c2g__Opportunity__c,
                                   c2g__Opportunity__r.Account.c2g__CODAFinanceContact__r.Name
                                   FROM
                                   c2g__codaInvoice__c
                                   WHERE 
                                   Id = :recordId 
                                   LIMIT 1][0];
        
        
        OpportunityContactRole contactRole = [SELECT
                                              Id,
                                              Contact.Name,
                                              Contact.Salutation
                                              FROM
                                              OpportunityContactRole
                                              WHERE
                                              OpportunityId = :inv.c2g__Opportunity__c
                                              AND Role = 'Finance Contact'
                                              LIMIT 1][0];
        System.debug('Opp: '+contactRole);
        
        
        try {   
            if (contactRole.Id != null){
                result = contactRole.Contact.Salutation+' '+contactRole.Contact.Name;
            }else if(inv.c2g__Opportunity__r.Account.c2g__CODAFinanceContact__r.Name != null){
                result = inv.c2g__Opportunity__r.Account.c2g__CODAFinanceContact__r.Name;
            }else{
                result = '';
            }
        } catch (Exception e) {
            
        }
        
        if (result == null){
            result = '';
        }
        
        return result;
    }
    
    public String getBookingContact(){
        
        String result = '';
        
        c2g__codaInvoice__c inv = [SELECT 
                                   Id,
                                   c2g__Opportunity__c
                                   FROM
                                   c2g__codaInvoice__c
                                   WHERE 
                                   Id = :recordId 
                                   LIMIT 1][0];
        
        try {
            OpportunityContactRole contactRole = [SELECT
                                                  Id,
                                                  Contact.Name,
                                                  Contact.Salutation
                                                  FROM
                                                  OpportunityContactRole
                                                  WHERE
                                                  OpportunityId = :inv.c2g__Opportunity__c
                                                  AND isPrimary = True 
                                                  LIMIT 1][0];
            System.debug('Opp: '+contactRole); 
            if (contactRole.Contact.Salutation == null)
                result = contactRole.Contact.Name;
            else
                result = contactRole.Contact.Salutation + ' '+ contactRole.Contact.Name;
        } catch (Exception e) {
            
        }
        
        if (result == null){
            result = '';
        }
        
        return result;
    }
}