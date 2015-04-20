trigger ContactTrigger on Contact (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

	if(trigger.isDelete){
		// Check to see if WebId is filled out, if so stop the Contact from being deleted
		for (Integer i = 0; i < Trigger.Old.size(); i++) {
			if (Trigger.Old[i].WebId__c != null){
				Trigger.Old[i].addError('Unable to delete contact. Contact is linked to a website account');
			}
		}
	}

}