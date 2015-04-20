trigger UserTrigger on User (before insert, before update) {

	// Check to make sure Dimension_1__c exists
	UserTriggerMethods.validateDim1Code(Trigger.new);
}