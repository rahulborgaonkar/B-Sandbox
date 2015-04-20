trigger SpecialEventUnitTrigger on Special_Event_Unit__c (after update) {
	
	SpecialEventUnitTriggerMethods.syncEventStartEndDate(Trigger.Old, Trigger.New);
	
}