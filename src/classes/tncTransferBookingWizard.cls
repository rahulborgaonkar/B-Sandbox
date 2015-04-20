public class tncTransferBookingWizard {

    public String fieldName                { get; set; }
    public string eventExclusions 		   { get; set; }
    public Special_Event_Booking__c record { get; set; }
    
    public tncTransferBookingWizard ()
    {
        record = getEventBooking(ApexPages.CurrentPage().getParameters().get('id'));
        fieldName = ApexPages.CurrentPage().getParameters().get('fieldName');
        eventExclusions = ApexPages.CurrentPage().getParameters().get('events');
        //id=a08L0000005A2cSIAS&fieldName=a08L0000005A2cSIAS&events=D1A/210666 
        system.debug('record: '+ record);
    }
    
    private Special_Event_Booking__c getEventBooking(Id id)
    {
        List<Special_Event_Booking__c> bookingQuery = [Select Id, Name, Special_Event__r.Product__c, 
                                                        Contact__c, Company__c,OPL_ID__c, Type__c,
                                                        Booking_Fee__c, Opportunity__c, Event_Start_Date__c , status__c, TnC_Event_Units__c
                                                        From Special_Event_Booking__c Where Id = :id];
        
        if (bookingQuery.size() == 1) return bookingQuery.get(0);
        
        return null;
    }

}