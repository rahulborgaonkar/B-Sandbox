public with sharing class SpecialEventUnitTriggerMethods {

	/*
	 * SYNC EVENT START AND END DATES (Special_Event_Unit__c)
	 *
	 * Works out the unique events from the event units that have been updated and passes to
	 * method to do start & end date calculations.
	 */
	public static void syncEventStartEndDate(List<Special_Event_Unit__c> oldVals, List<Special_Event_Unit__c> newVals){
		
		Set<Id> events = new Set<Id>();
		
		// Loop over records and see if the start or end dates have changed. If so add it to the list of events to re-sync
		for (Integer i=0; oldVals.size() > i; i++){
			if ((oldVals[i].Travel_Day__c <> newVals[i].Travel_Day__c) || (oldVals[i].Unit_Start_Time__c <> newVals[i].Unit_Start_Time__c) || (oldVals[i].Unit_End_Time__c <> newVals[i].Unit_End_Time__c)){
				events.add(newVals[i].Special_Event__c);
			}
		}
		syncEventStartEndDate(events);
	}
	
	/*
	 * SYNC EVENT START AND END DATES (Special_Event__c)
	 *
	 * Works out the MAX(End_Date) and MIN(Start_Date) on the event units for a particular event
	 * and sets the value on the event.
	 */
	public static void syncEventStartEndDate(Set<Id> eventsToSync){
		
		// Empty list to hold events that need to be updated
		List<Special_Event__c> eventsToUpd = new List<Special_Event__c>();
		
		List<Special_Event__c> eventsList = new List<Special_Event__c>([SELECT Id,
																			StartDate__c,
																			EndDate__c,
																			(SELECT
																				Unit_Start_Time__c,
																				Unit_End_Time__c
																			FROM
																				Sessions__r
																			WHERE
																				Travel_day__c = false)
																		FROM
																			Special_Event__c
																		WHERE
																			Id IN :eventsToSync]);
		
		// Loop over events and work out the min and max for the start and end dates.
		for (Special_Event__c event : eventsList){
			
			Date startDate;
			Date endDate;
			
			for (Special_Event_Unit__c evtUnit : event.Sessions__r){
				if((evtUnit.Unit_Start_Time__c < startDate) || startDate == null){
					startDate = date.newinstance(evtUnit.Unit_Start_Time__c.year(), evtUnit.Unit_Start_Time__c.month(), evtUnit.Unit_Start_Time__c.day());
				}
				if((evtUnit.Unit_End_Time__c > endDate) || endDate == null){
					endDate = date.newinstance(evtUnit.Unit_End_Time__c.year(), evtUnit.Unit_End_Time__c.month(), evtUnit.Unit_End_Time__c.day());
				}
			}
			if ((startDate != null && (startDate <> event.StartDate__c)) || (endDate != null && (endDate <> event.EndDate__c))){
				//System.debug('FJP old start/end: '+event.StartDate__c+'/'+event.EndDate__c);
				//System.debug('FJP new start/end: '+startDate+'/'+endDate);
				event.StartDate__c = startDate;
				event.EndDate__c = endDate;
				eventsToUpd.add(event);
			}
		}
		if (eventsToUpd.size() > 0){
			update eventsToUpd;
		}
	}
}