public class clsContactsForTrainerEmail{ 

    private List<special_event_booking__c> bookings;
    
    public id eventId {get;set;}
        
	public clsContactsForTrainerEmail() {
	}

	public List<special_event_booking__c> getBookings() {
        bookings = [select id, name, Primary_Booking__c, contact__r.name, contact__r.email, contact__r.phone from special_event_booking__c where special_event__c =: eventId];
		return bookings;
	}
    
}