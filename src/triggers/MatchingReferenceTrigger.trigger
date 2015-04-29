trigger MatchingReferenceTrigger on c2g__codaMatchingReference__c (after insert, after update) {

    FinancialTransactionPopulationMethods.cashMatching(trigger.newMap.keySet());
}