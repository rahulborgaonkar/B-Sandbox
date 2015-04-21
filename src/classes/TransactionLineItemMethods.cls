public with sharing class TransactionLineItemMethods {

    public class Test_Exception extends Exception{}

     public static void copyStatusPayment(Set<Id> transLineId)
     { 
     
         Map<Id,Double> DocumentTotal = new Map<Id,Double>();
         Map<Id,Double> DocumentOutstandingTotal = new Map<Id,Double>();
         List<c2g__codaTransactionLineItem__c> transLineItemsList = new List<c2g__codaTransactionLineItem__c>([Select Id,
                                                                                                                       c2g__Transaction__c,
                                                                                                                       c2g__AccountRollup__c,
                                                                                                                       c2g__DocumentValue__c,
                                                                                                                       c2g__DocumentOutstandingValue__c,
                                                                                                                       c2g__LineType__c
                                                                                                                       from c2g__codaTransactionLineItem__c
                                                                                                                       where Id In:transLineId]);
         Set<Id> transactionId = new Set<Id>();
         List<c2g__codaInvoice__c> updateInvoice = new List<c2g__codaInvoice__c>();
         List<Opportunity> updateOpportunity = new List<Opportunity>();
         //Transaction Id
         for(c2g__codaTransactionLineItem__c transLineItem:transLineItemsList)
         {
             if(transLineItem.c2g__AccountRollup__c == 'True' && transLineItem.c2g__LineType__c =='Account')
             {
                 //Roll up summary DocumentOutstandingTotal
                 if(!DocumentOutstandingTotal.containsKey(transLineItem.c2g__Transaction__c))
                 {    
                     if(transLineItem.c2g__DocumentOutstandingValue__c == null)
                         DocumentOutstandingTotal.put(transLineItem.c2g__Transaction__c,0);
                     else{
                         DocumentOutstandingTotal.put(transLineItem.c2g__Transaction__c,transLineItem.c2g__DocumentOutstandingValue__c);
                     }     
                 }
                 else{
                     Double value = DocumentOutstandingTotal.get(transLineItem.c2g__Transaction__c);
                     value += transLineItem.c2g__DocumentOutstandingValue__c;
                     DocumentOutstandingTotal.put(transLineItem.c2g__Transaction__c,value);
                 }
                 
                 
                 //Roll up summary DocumentValue
                 if(!DocumentTotal.containsKey(transLineItem.c2g__Transaction__c))
                 {    
                     if(transLineItem.c2g__DocumentValue__c == null)
                         DocumentTotal.put(transLineItem.c2g__Transaction__c,0);
                     else{
                         DocumentTotal.put(transLineItem.c2g__Transaction__c,transLineItem.c2g__DocumentValue__c);
                     }     
                 }
                 else{
                     Double value = DocumentTotal.get(transLineItem.c2g__Transaction__c);
                     value += transLineItem.c2g__DocumentValue__c;
                     DocumentTotal.put(transLineItem.c2g__Transaction__c,value);
                 }
               
               transactionId.add(transLineItem.c2g__Transaction__c);  
             }
             
             
              
         }
         
         
         //Invoice Records
         for(c2g__codaInvoice__c invoice:[Select Id,
                                                 c.c2g__PaymentStatus__c, 
                                                 c.Copy_Invoice_Status__c,
                                                 c.c2g__Transaction__c,
                                                 c.c2g__Transaction__r.c2g__MatchType__c,
                                                 c.c2g__Opportunity__r.StageName
                                                 From c2g__codaInvoice__c c
                                                 where 
                                                 (NOT c2g__InvoiceDescription__c LIKE 'Data Migration%')
                                                 AND c.c2g__Transaction__c IN:transactionId])
         {
             if(DocumentTotal.containsKey(invoice.c2g__Transaction__c)&& DocumentOutstandingTotal.containsKey(invoice.c2g__Transaction__c))
             {
                 // Code added to update text field ->invoice.Copy_Match_Type__c
                 System.debug('In Invoice field updates');
                 if(invoice.c2g__Transaction__r.c2g__MatchType__c != 'Credited')
                 {
                     System.debug('invoice.Copy_Match_Type__c - empty');
                     invoice.Copy_Match_Type__c = '';
                 }
                 else
                 {
                     System.debug('invoice.Copy_Match_Type__c - Credited');
                     invoice.Copy_Match_Type__c = 'Credited';
                     if(invoice.c2g__Opportunity__c != null)
                     {
                         invoice.c2g__Opportunity__r.StageName = 'Credited';
                     }
                 }
                 // Code added to update text field ->invoice.Copy_Match_Type__c

                 if(DocumentOutstandingTotal.get(invoice.c2g__Transaction__c)== 0)
                 {
                     System.debug('invoice.Copy_Match_Type__c - Paid');
                     invoice.Copy_Invoice_Status__c ='Paid';
                     if(invoice.c2g__Opportunity__c != null)
                     {
                         invoice.c2g__Opportunity__r.StageName = 'Booking Received';
                     }
                 }
                 else{
                     if(DocumentOutstandingTotal.get(invoice.c2g__Transaction__c)== DocumentTotal.get(invoice.c2g__Transaction__c))    
                         invoice.Copy_Invoice_Status__c ='Unpaid';
                     else{
                         invoice.Copy_Invoice_Status__c = 'Part Paid';
                     }
                 }
                 System.debug('INVOICE ADDED: '+invoice.Id);
                 updateInvoice.add(invoice);
                 if(invoice.c2g__Opportunity__c != null)
                 {
                     updateOpportunity.add(invoice.c2g__Opportunity__r);
                 }
             }
         
         }
         
         if(!updateInvoice.isEmpty())        
         {    
            update updateInvoice;
            //throw new Test_Exception (updateInvoice.get(0).Copy_Invoice_Status__c);
         }
         if(!updateOpportunity.isEmpty())        
         {    
            update updateOpportunity;
         }

     }
    
    public testmethod static void testTransactionLineItemMethods()
    {

        //Id transactionId = [Select c.c2g__Transaction__c, c.c2g__Account__c, c.Id From c2g__codaInvoice__c c where c.c2g__Account__c != null and c.c2g__Transaction__c!=null and c.Id='a1ZD0000000TTYV' limit 1].c2g__Transaction__c;
        // Old: a1ZD0000000TdLc 
        Id transactionId = [Select c.c2g__Transaction__c, c.c2g__Account__c, c.Id From c2g__codaInvoice__c c where c.c2g__Account__c != null and c.c2g__Transaction__c!=null and c.Id='a1ZD0000000TTTA' limit 1].c2g__Transaction__c;
        Map<Id,c2g__codaTransactionLineItem__c> transId = new Map<Id,c2g__codaTransactionLineItem__c>([Select Id from c2g__codaTransactionLineItem__c  where c2g__Transaction__c=:transactionId  limit 4]);

        TransactionLineItemMethods.copyStatusPayment(transId.keySet());

        update transId.values();

    }

}