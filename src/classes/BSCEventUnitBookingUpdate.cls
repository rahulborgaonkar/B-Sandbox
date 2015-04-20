public with sharing class BSCEventUnitBookingUpdate
/*
This Class will allow us to update the BSC Event Unit Booking to the correct Unit
*/
{
	public static void updateBscEventUnitBooking(List<Special_Event_Unit_Booking__c> seub)
	{
		//List<Special_Event_Unit_Booking__c> seub = [SELECT Event_Unit__r.special_event__c, Event_Unit__r.name, Event_Booking__r.special_event__c FROM Special_Event_Unit_Booking__c];
		for(Special_Event_Unit_Booking__c s: seub)
		{
			if(s.Event_Unit__r.special_event__c!=s.Event_Booking__r.special_event__c)
			{
				try
				{
					Special_Event_Unit__c seu = [Select id From Special_Event_Unit__c Where Special_Event__c = :s.Event_Booking__r.special_event__c and name=:s.Event_Unit__r.name limit 1];
					s.Event_Unit__c = seu.id;
				}
				catch (QueryException Q1)
				{
					// Do Nothing
				}
				catch (Exception e)
				{
					
				}
				
			}
		}
		if(seub.size()>0)
			update seub;
	}

}