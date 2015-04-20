trigger EventTrainerTrigger on Special_Event_Trainer__c (after delete, before update) {

	if(trigger.isAfter){
		if(trigger.isDelete){
			// Deletes the related activity/Events for the trainer when the special_Event_Trainer__c record is deleted
			EventTrainerHelper.deleteTrainers(trigger.old);
		}
	}
}