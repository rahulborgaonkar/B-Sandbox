public class addBookingExtension {

    public Opportunity opp               {get; set;}
    public list<prodEvts> prodEvt        {get; set;}
    public boolean showsection			 {get; set;}
    
    public string eventName {get; set;}
    
    public addBookingExtension(ApexPages.StandardController con){
        opp = (Opportunity)con.getRecord();
        id oppId = opp.Id;
        
        map <id,special_event__c> oppEvents = new map<id, special_event__c>();
        map <id,OpportunityLineItem> oppProduct = new map<id, OpportunityLineItem>();
        map <id,Special_Event_Booking__c> oppBookings = new map<id, Special_Event_Booking__c>();
        set <id> productIds = new set<id>();
        
        prodEvt = new list<prodEvts>();

		opp = [select id, Name, Opportunity_Number__c,AccountId,CurrencyIsoCode,StageName,Invoice_Status__c,
               (SELECT Id,Name,TotalPrice,UnitPrice,PricebookEntry.Product2.Name,PricebookEntry.Product2Id,Number_of_Delegates__c,Quantity FROM OpportunityLineItems o WHERE PricebookEntry.Product2.No_Event__c = False),
               (SELECT Id,Name,Special_Event__c, opl_id__c, Contact__c,Booking_Fee__c,Primary_Booking__c,Status__c from BSC_Event_Bookings__r order by Primary_Booking__c desc, Name),
               (SELECT Id,Name,StartDate__c,EndDate__c,Status__c,Add_Remove_Bookings__c, No_of_Delegates_Booked__c, Maximum_Places__c  from BSC_Events__r)
               from Opportunity where id = :oppId];

        boolean proceed = true;
        

        if(opp.StageName == 'Invoiced' || opp.StageName == 'Part Invoiced' || opp.StageName == 'Paid' || opp.StageName == 'Part Paid' ||
           opp.Invoice_Status__c == 'Invoiced' || opp.Invoice_Status__c == 'Paid' || opp.Invoice_Status__c == 'Part Paid'  || opp.Invoice_Status__c == 'To Be Credited'){
               proceed = false;
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This opportunity has an invoice associated with it which first needs to be credited by Finance.  Please tick the Finance To Credit Opp flag on this opportunity.  You will need to wait for the opportunity to be credited before continuing'));
           }
        
        if (opp.StageName == 'Booking Received' || opp.StageName == 'Customer Approved'){
            showsection = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Add/Remove bookings when the Opp stage is at  Booking Received or  Customer Approved'));
            
        } else if (proceed) {
        	showsection = true;
            AggregateResult[] bookings = [SELECT Special_Event__c, opl_id__c from Special_Event_Booking__c where Opportunity__c = :oppId Group by Special_Event__c, opl_id__c];
            
            system.debug('bookings for opp: ' + bookings);
            
            for (AggregateResult ar :  bookings){
                id evnt = (Id)ar.get('Special_Event__c');
                id opl = (id)ar.get('opl_id__c');
                
                system.debug('event' + evnt);
                
                Special_Event__c foundEvent;
                OpportunityLineItem foundOPL;
                list<oppBookings> foundBookings = new list<oppBookings>();
                
                for (Special_Event__c bscEvent : opp.BSC_Events__r){
                    if (evnt == bscEvent.Id){
                        foundEvent = bscEvent;
                    }
                }
                
                for (OpportunityLineItem oppLine : opp.OpportunityLineItems){
                    if (opl == oppLine.Id){
                        foundOPL = oppLine;
                    }
                }
                
                system.debug('foundEvent ' + foundEvent);
                system.debug('foundOPL ' + foundOPL);
                
                if (foundEvent != null && foundOPL != null){
                    for (Special_Event_Booking__c bkg : opp.BSC_Event_Bookings__r){
                        if (bkg.Special_Event__c == evnt && bkg.opl_id__c == opl){
                            foundBookings.add( new oppBookings(bkg) );
                        }
                    }
                    
                    prodEvt.add(new prodEvts(foundEvent, foundOPL, foundBookings));
                }
                
            }
            
            system.debug('Product Event Map: '+ prodEvt);
            system.debug('Product Event Map size: '+ prodEvt.size());
        }
        
    }

    public class addBookingException extends Exception{}
    
    public PageReference confirmBookings(){
        
        try{
            
            list<Special_Event__c> updateEvents = new list<Special_Event__c>();
            list<Special_Event_Booking__c> addBookings = new list<Special_Event_Booking__c>();
            list<Special_Event_Booking__c> deleteBookings = new list<Special_Event_Booking__c>();
            
            list<task> tasks = new list<task>();
            
            map<id,opportunitylineitem> oppmap = new map<id,opportunitylineitem> ();
            for (prodEvts p : prodEvt){
                if (oppmap.containsKey(p.opl.id) == false){
                    oppmap.put(p.opl.id, p.opl);
                }
            }
            
            
            User manager = [select Manager.Email,ManagerId,email from User where id = :UserInfo.getUserId()];
            
            for (prodEvts p : prodEvt){
                
                system.debug('Adding ' + p.newBookings + ' bookings to Event ' + p.event.Name);
                
                opportunitylineitem oplUpd = oppmap.get(p.opl.id);
                
                if (!p.requestApproval){
                    for(integer i = 0; i < p.newBookings; i++){
                        Special_Event_Booking__c bookingAdditional = new Special_Event_Booking__c(
                            Opportunity__c = opp.Id,
                            Status__c='Provisional',
                            Type__c = 'In-Company Additional',
                            Special_Event__c = p.event.Id,
                            Company__c = opp.AccountId,
                            Booking_Fee__c = 0.0,
                            OPL_ID__c  = p.opl.Id);
                        
                        p.opl.Number_of_Delegates__c = oplUpd.Number_of_Delegates__c + 1;
                        addBookings.add(bookingAdditional);
                    }
                    
                    for(oppBookings b : p.bookings){
                        if (b.selected){
                            system.debug('Deleting booking ' + b.booking.Name + ' from event ' + p.event.Name);
                            p.opl.Number_of_Delegates__c = oplUpd.Number_of_Delegates__c  - 1;
                            deleteBookings.add(b.Booking);
                        }
                    }
                    oppmap.remove(p.opl.id);
                    oppmap.put(p.opl.id, oplUpd);
                    
                    if(p.newBookings > 0 || p.bookingsRemoved > 0 ){
                        string subject = 'Bookings Added/Removed for Event:' + p.event.Name;
                        
                        string body = 'Event: ' + p.event.Name  +  
                            '\r\n' + 
                            'Start Date: ' + p.Event.StartDate__c + 
                            '\r\n' + 
                            'End Date: ' + p.Event.EndDate__c + 
                            '\r\n' + 
                            'Number of Bookings added: ' + p.newBookings + 
                            '\r\n' + 
                            'Number of Bookings removed: '+ p.bookingsRemoved;
                        
                        string[] toEmail = new string[3];
                        toEmail[0] = 'operations.inbox@britsafe.org';
                        toEmail[1] = manager.Manager.Email;
                        toEmail[2] = manager.Email;
                        
                        Utilities.SendEmail(body, subject, toEmail);
                        p.event.Add_Remove_Bookings__c = false;
                        updateEvents.add(p.event);
                    }
                } else {
                    
                    string body = 'Please authorise to Add/Remove bookings on this Event: '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + p.event.id + ' '+ p.event.Name + '\r\nSubmitted by: ' + UserInfo.getName();
                    string subject = 'Request to Add/Remove Bookings for Event ' + p.event.Name;
                    task t  = Utilities.createTask(false, date.today(), p.event.id, subject, body, manager.ManagerId );
                    tasks.add(t);
                    string[] toEmail = new string[2];
                    toEmail[0] = 'operations.inbox@britsafe.org'; 
                    toEmail[1] = manager.Manager.Email;
                    

                    Utilities.sendTemplatedEmail(toEmail, 'Request_To_Add_or_Remove_Bookings', p.event.id, UserInfo.getUserId());
                    
                }
            }
            system.debug('OPL Updates' + oppmap.values());
            insert tasks;
            update oppmap.values();
            delete deleteBookings;
            insert addBookings;
            update updateEvents;
           
            system.debug('Adding Special_Event_Unit_Booking__c ');
            list<Special_Event_Unit_Booking__c> unitBookings = new list<Special_Event_Unit_Booking__c>();
            for (Special_Event_Booking__c b : addBookings){
                for (Special_Event_Unit__c u:[Select Id From Special_Event_Unit__c Where Special_Event__c=:b.Special_Event__c])
                {
                    System.debug('Looping special Event unit to create special event Unit Booking: '+u.id);
                    Special_Event_Unit_Booking__c unitBooking = new Special_Event_Unit_Booking__c(currencyIsoCode=opp.CurrencyIsoCode,
                                                                                                  attended__c = false,
                                                                                                  event_unit__c = u.Id,
                                                                                                  event_booking__c=b.id);
                    unitBookings.add(unitBooking);
                }
            }
            
            insert unitBookings;
            
            opp.Price_Approval_Given__c = false;
            opp.IC_Price_Variation_Approved__c = false;
            opp.T_C_Variation_Approved__c = false;
            
            update opp;
            
            return new pagereference('/' + opp.id);
            
        } catch (Exception e) {
             throw new addBookingException(e.getMessage());
        }
    }
    
    public PageReference selectBookingsForEvent(){
        system.debug(' in selectBookingsForEvent' + eventName);
        for (prodEvts p : prodEvt){
            if (p.event.Name == eventName){
                for(oppBookings b : p.bookings){
                    if (b.booking.Primary_Booking__c == false)
                        b.selected= true;
                }
            }
        }
        return null;
    }
    
    public class prodEvts{
        
        public OpportunityLineItem opl {get; set;}
        public Product2 product; 
        public Special_Event__c event {get; set;}
        public list<oppBookings> bookings {get; set;}
        public boolean requestApproval {get; set;}
        public integer newBookings {get; set;}
        
        public integer avaliableBookings{
            get{
                return (Integer)(event.Maximum_Places__c - event.No_of_Delegates_Booked__c);
            }
        }
        
        public integer bookingsRemoved{
            get{
                integer i= 0;
                for (oppBookings b : bookings){
                    if (b.selected){
                        i = i + 1;
                    }
                }
                return i;
            }
        }
        
        
        public boolean validEvent { 
            get {
                date current = date.today();
                
                if (current.daysBetween(event.StartDate__c) < 22 && event.Add_Remove_Bookings__c == false)
                    return false;
                else
                    return true;
            }
        }
        
        public prodEvts(Special_Event__c e,OpportunityLineItem o, list<oppBookings> b){
            this.event = e;
            opl = o; 
            bookings = b;
            requestApproval = false;
        }
    }
    
    public class oppBookings{
        public boolean selected {get; set;}
        public Special_Event_Booking__c booking {get; set;}
        
        public oppBookings(Special_Event_Booking__c b){
            booking = b;
            selected = false;
        }
    }
    
    
}