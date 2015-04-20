public with sharing class SalesCreditNoteTriggerMethods {

	
	public static void updateOppReference(List<c2g__codaCreditNote__c> creditNotes){
		
		List<c2g__codaCreditNote__c> cNotesToUpd = new List<c2g__codaCreditNote__c>();
				
		Map<Id,c2g__codaCreditNote__c> cnoteMap = new Map<Id,c2g__codaCreditNote__c>([SELECT
																	Id,
																	c2g__Invoice__r.c2g__Opportunity__c
																FROM
																	c2g__codaCreditNote__c
																WHERE
																	c2g__Invoice__r.c2g__Opportunity__c !=null AND
																	Id IN :creditNotes]);
		
		for (Integer i = 0; i < creditNotes.size(); i++) {
			c2g__codaCreditNote__c creditNote = creditNotes.get(i);
			if (creditNote.c2g__Opportunity__c == null){
				if (cnoteMap.containsKey(creditNote.Id)){
					if (cnoteMap.get(creditNote.Id).c2g__Invoice__r.c2g__Opportunity__c != null){
						
						creditNote.c2g__Opportunity__c = cnoteMap.get(creditNote.Id).c2g__Invoice__r.c2g__Opportunity__c;
						cNotesToUpd.add(creditNote);
					}
				}
			}
		}
		
		if (cNotesToUpd.size() > 0){
			update cNotesToUpd;
		}
	}
}