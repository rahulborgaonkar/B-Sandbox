/*
 * 18 11 2013: VS: Added this code to update the reason * notes on the Event bookings when the reason & notes change on Event  
*/

trigger BSCEventStatusTrigger on Special_Event__c (after update) {
// Trigger to update the BSCEventBooking status to Confirmed
// when the status of the event is set to confirmed.
// for In-Company Events only 
// Case 00001323
    BSCEventTriggerMethods.updateBookingStatus(trigger.new);
    
    Set<Id> events = new Set<Id>();
        for (Special_Event__c evt : trigger.new){
        events.add(evt.Id); 
    }
    
    SpecialEventUnitTriggerMethods.syncEventStartEndDate(events);
    
}