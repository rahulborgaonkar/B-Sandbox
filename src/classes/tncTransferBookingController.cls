public class tncTransferBookingController{
    // Error messages   
    private static final String ERROR_MULTIPLE_EVENTS =         'Only one event can be selected when transferring a booking.';
    private static final String ERROR_SAME_EVENT_TRANSFER =     'You cannot transfer a booking to the same event.';
    private static final String ERROR_NO_EVENT_SELECTED =       'Please select at least one event.';
    private static final String ERROR_INVALID_UNK_DELEGATES =   'The Unknown Delegates field is not a valid number.';
    private static final String ERROR_NO_CONTACT_UNK_DELEGATE = 'Please select at least one contact or specify at least one unknown delegate.';
    private static final String ERROR_NO_EVT_SPACES_AVAILABLE = ' does not have enough space on the event. You cannot book that many delegates.';
    private static final String ERROR_SAME_EVENT_TRANSFER1 = 'One of the bookings you are attempting to transfer is currently booked on the Event selected, please select a different event / booking to transfer.';
    
    private Boolean requiresInit;
    
    public string eventstoExclude {get; set;}
    public string eventUnitString {get; set;}
    
    public string fieldName 	{get; set;}
    public Special_Event__c specialEvent {get;set;}
    public string bookingStatus{get;set;}
    // Used for booking
    public Opportunity opportunity                  { get; set { this.opportunity = value; if (requiresInit) initialise(); } }
    
    // Used for transfer
    public Special_Event_Booking__c booking         { get; set { this.booking = value; if (requiresInit) initialise(); } }
    
    public String bookingType                       { get; set { this.bookingType = value; if (requiresInit) initialise(); } }
    
    // Page 1
    public Special_Event__c eventCriteria           { get; set; }
    public String[] locationCriteria                { get; set; }
    
    public List<Product> productSelections          { get; set; }
    // transfer only
    public Boolean customerTransferRequest          { get; set; }
    
    // Page 2
    // booking
    public List<Product> eventSelectionsByProduct   { get; set; }
    // transfer
    public List<BSCEvent> eventSelections           { get; set; }
    
    // Page 3
    public List<BSCEvent> eventUnitSelections       { get; set; }
    
    // Page 4 - booking only
    public List<OpportunityContact> linkedContacts  { get; private set; }
    public String numberUnknownDelegates            { get; set; }
    
    
    public Integer pageNum                          { get; private set; }
    private final Integer maxPages = 4;
    
    public tncTransferBookingController()
    {
        eventUnitString = 'Test';
            
        requiresInit = true;
        locationCriteria = new String[] {};
        // Select all locations as default
        for (SelectOption so : getEventCityPicklistOptions())
        {
            locationCriteria.add(so.getValue());
        }
    }
    
    public void initialise()
    {
        // If the booking type is null, don't initialise yet
        if (bookingType == null)
            return;
        // If both opportunity and booking are null, don't initialise yet
        if (opportunity == null && booking == null)
            return;
        
        eventCriteria = new Special_Event__c(StartDate__c = System.today());
        if (bookingType == 'Transfer')
        {
            productSelections = null;
            linkedContacts = null;
            customerTransferRequest = true;
        }
        
        pageNum = 1;
        requiresInit = false;
    }
    

    
    private void generateBSCEvents()
    {
        Set<Id> productIds = new Set<Id>();
        if (bookingType == 'Transfer')
            productIds.add(booking.Special_Event__r.Product__c);
        
        List<Special_Event__c> selectedEvents = [
            SELECT
                Id,
                Name,
                Product__c,
                StartDate__c,
                EndDate__c,
                City__c,
                Maximum_Places__c,
                No_of_Delegates_Booked__c,
                Available_Places__c,
                Minimum_Places__c,
                Allow_Overbooking__c
            FROM
                Special_Event__c
            WHERE
                City__c in :locationCriteria
            AND
                Status__c ='Confirmed' 
            AND
                StartDate__c >= :eventCriteria.StartDate__c
            AND
                EndDate__c <= :eventCriteria.EndDate__c
            AND
                Product__c in :productIds];
        
        // Group events by products for bookings
        if (bookingType == 'Transfer')
        {
            eventSelections = new List<BSCEvent>();
            for (Special_Event__c bscEvent : selectedEvents)
            {
                if (eventCriteria.Maximum_Places__c == null ||
                    bscEvent.Maximum_Places__c == null ||
                    (bscEvent.Maximum_Places__c - bscEvent.No_of_Delegates_Booked__c) >= eventCriteria.Maximum_Places__c)
                {
                    eventSelections.add(new BSCEvent(bscEvent));
                }
            }
        }
    }
    
    private Boolean generateBSCEventUnits()
    {
        Set<Id> eventIds = new Set<Id>();
        
        if (bookingType == 'Transfer')
        {
            string eventName = '';
            for (BSCEvent e : eventSelections)
            {
                if (e.selected == true){
                    eventIds.add(e.record.Id);
                    eventName = e.record.Name;
                }
            }
            if (eventIds.size() > 1)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ERROR_MULTIPLE_EVENTS));
                return false;
            }
            if (eventIds.contains(booking.Special_Event__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ERROR_SAME_EVENT_TRANSFER));
                return false;
            }
            if (eventstoExclude.contains(eventName)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ERROR_SAME_EVENT_TRANSFER1));
                return false;
            }
        }
        if (eventIds.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ERROR_NO_EVENT_SELECTED));
            return false;
        }
        
        List<Special_Event_Unit__c> selectedEventUnits = [
            SELECT
                Id,
                Name,
                Unit_Description__c,
                Venue__c,
                Unit_Start_Time__c,
                Duration__c,
                Special_Event__c
            FROM
                Special_Event_Unit__c
            WHERE
                Special_Event__c in :eventIds];
        
        eventUnitSelections = new List<BSCEvent>();
        if (bookingType == 'Transfer')
        {
            for (BSCEvent e : eventSelections)
            {
                if (e.selected == true)
                {
                    BSCEvent selected = new BSCEvent(e.record);
                    specialEvent = e.record;
                    selected.units = new List<BSCEventUnit>();
                    for (Special_Event_Unit__c bscEventUnit : selectedEventUnits)
                    {
                        if (bscEventUnit.Special_Event__c == e.record.Id)
                        {
                            selected.units.add(new BSCEventUnit(bscEventUnit));
                        }
                    }
                    eventUnitSelections.add(selected);
                }
            }
        }
        
        return true;
    }
    
    public SelectOption[] getEventCityPicklistOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.Picklistentry pe : Schema.SObjectType.Special_Event__c.fields.City__c.getPicklistValues())
        {
            if (pe.isActive())
                options.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        return options;
    }
    
    public void next()
    {
        if (pageNum < maxPages) pageNum++;
        
        if (pageNum == 2)
        {
            generateBSCEvents();
        }
        else if (pageNum == 3)
        {
            Boolean success = generateBSCEventUnits();
            if (!success)
                pageNum--;
        }
    }
    
    public void prev()
    {
        if (pageNum > 1)
            pageNum--;
    }
    
    public void save()
    {
        if (bookingType == 'Transfer')
        {
            transferBooking();
        }
        
        //return cancel();
    }
     

    
    public void transferBooking()
    {
        system.debug('entering transferBooking');
        list<string> bookingList = fieldName.split(',');
         string units = '';
        for (BSCEvent event : eventUnitSelections)
        {
            for (BSCEventUnit unit : event.units)
            {
                if (unit.selected)
                {
                    units += unit.record.Id + ',';
                }
            }
        }
        eventUnitString = units;
        system.debug(eventUnitString);
        
        list<Special_Event_Booking__c> bookings = [select name from Special_Event_Booking__c where id in :bookingList];
        
        for (Special_Event_Booking__c bookingtoUpdate : bookings){
            bookingtoUpdate.Transfer_To__c = eventUnitSelections[0].record.Id;
            bookingtoUpdate.Customer_Requested_Transfer__c = customerTransferRequest;
            bookingtoUpdate.Status__c = 'To Be Transferred';
            bookingtoUpdate.TnC_Event_Units__c = units;
        }
        bookingStatus = 'To Be Transferred';
        update bookings;
        
        booking = bookings[0];
        
        system.debug('finished transferBooking');
    }
    
    public PageReference cancel()
    {
        if (opportunity != null)
            return new PageReference('/' + opportunity.Id);
        if (booking != null)
            return new PageReference('/' + booking.Id);
        
        return new PageReference('/home/home.jsp');
    }
    
    public class Product
    {
        public OpportunityLineItem record       { get; private set; }
        public Boolean selected                 { get; set; }
        
        public List<BSCEvent> events            { get; set; }
        
        public Product(OpportunityLineItem target)
        {
            this.record = target;
            this.selected = true;
        }
    }
    
    public class BSCEvent
    {
        public Special_Event__c record          { get; private set; }
        public Boolean selected                 { get; set; }
        
        public List<BSCEventUnit> units         { get; set; }
        
        public BSCEvent(Special_Event__c target)
        {
            this.record = target;
            this.selected = false;
        }
    }
    
    public class BSCEventUnit
    {
        public Special_Event_Unit__c record     { get; private set; }
        public Boolean selected                 { get; set; }
        
        public BSCEventUnit(Special_Event_Unit__c target)
        {
            this.record = target;
            this.selected = true;
        }
    }
    
    public class OpportunityContact
    {
        public OpportunityContactRole record    { get; private set; }
        public Boolean selected                 { get; set; }
        
        public OpportunityContact(OpportunityContactRole target)
        {
            this.record = target;
            this.selected = false;
        }
    }
}