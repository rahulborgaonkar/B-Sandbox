trigger BookingEventTrigger on Special_Event_Booking__c (before update, after update) {

	if (Trigger.isBefore && Trigger.isUpdate){
		BookingEventTriggerMethods.updateInvoiceStatus(trigger.newMap);
	}
	
	if(trigger.isAfter && Trigger.isUpdate){

		Set<Id> evtsToUpd = new Set<Id>();
		
		for (Special_Event_Booking__c evt : Trigger.new){
			Special_Event_Booking__c oldEvt = Trigger.oldMap.get(evt.Id);
			if (evt.OPL_ID__c != oldEvt.OPL_ID__c && evt.OPL_ID__c !=null && evt.OPL_ID__c !=''){
				try{
					evtsToUpd.add(evt.OPL_ID__c);
				}catch(Exception e){
					evt.OPL_ID__c.addError('Invalid Formatted ID');
				}
			}
			if (evt.OPL_ID__c !=null && evt.OPL_ID__c.length() > 0 && (evt.OPL_ID__c.length() != 18)){
				evt.OPL_ID__c.addError('Invalid Id: This Id must be an 18 character Id');
			}
		}
		if (evtsToUpd.size() > 0){
	    	OpportunityLineItemsTriggerMethods.updateBookingPriceLines(evtsToUpd);
		}
	}
}