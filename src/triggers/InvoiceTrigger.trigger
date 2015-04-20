trigger InvoiceTrigger on c2g__codaInvoice__c (before update,after update) {


    if (execControl.stopInvoiceTrigger == true && trigger.isBefore) 
        InvoiceTriggerMethods.populateCustomerReference(trigger.new);
    
    if (execControl.stopInvoiceTrigger == true && trigger.isAfter)    
        InvoiceTriggerMethods.updateInvoiceLineItemsNonFuture(trigger.newMap.keySet()); 
        
    if (execControl.stopCreditNoteTrigger == false && execControl.stopInvoiceTrigger == false){ 
        
        if(trigger.isBefore)
            InvoiceTriggerMethods.populateCustomerReference(trigger.new);
        
        if(trigger.isAfter) {
            InvoiceTriggerMethods.updOppLineCredits(trigger.oldMap, trigger.newMap);
            InvoiceTriggerMethods.clearToBeInvoicedOppFlag(trigger.oldMap, trigger.newMap);
            InvoiceTriggerMethods.updateInvoiceLineItemsNonFuture(trigger.newMap.keySet());         
            InvoiceTriggerMethods.updateOppFields(trigger.new);
            InvoiceTriggerMethods.updateSubscription(trigger.new);
        } 
    }
}