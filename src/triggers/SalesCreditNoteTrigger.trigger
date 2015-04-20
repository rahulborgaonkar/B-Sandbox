trigger SalesCreditNoteTrigger on c2g__codaCreditNote__c (after insert, after update) {
    
    if (Trigger.isAfter && Trigger.isInsert) 
        system.assertNotEquals(trigger.New.Size(), 0, 'Found Lines to insert');
    
    system.debug('SalesCreditNoteTrigger execControl.stopCreditNoteTrigger' + execControl.stopCreditNoteTrigger);
    
    if (test.isRunningTest() == false && execControl.stopCreditNoteTrigger == false){
        
        FinanceHelper.updateCreditedStatus(Trigger.new);
        FinancialTransactionPopulationMethods.populateFinancialObjectFromCN(trigger.newMap);
    }
}