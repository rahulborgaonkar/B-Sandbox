/**
 * By: Francis Pindar
 * Date: 29/July/2011
 *
 * Tests the TransactionLineItem trigger
 *
 * ************************************************************************************************
 * THIS NEEDS TO BE DONE PROPERLY I DIDN'T WRITE THE TransactionLineItem TRIGGER IN THE FIRST PLACE
 * ************************************************************************************************
 */
@isTest
private class TestTransactionLineItemTrigger {

    static testMethod void testTranLineItemTrigger() {
        
        //Id transactionId = [Select c.c2g__Transaction__c, c.c2g__Account__c, c.Id From c2g__codaInvoice__c c where c.c2g__Account__c!=null and c.c2g__Transaction__c!=null and c.Id='a1ZD0000000TTYV' limit 1].c2g__Transaction__c;
        c2g__codaTransactionLineItem__c transactionLine = [Select Id from c2g__codaTransactionLineItem__c limit 1];
        
        update transactionLine;

    }
}