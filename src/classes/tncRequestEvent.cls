public class tncRequestEvent{
	public Opportunity oppy                 {get; private set;}
    public List<myProduct> theProducts      {get; set;}
    public id theProductId                  {get; set;}
    public id oplId                         {get; set;}
    
    private Map<Id, list<decimal>> productCosts;
    private String recordTypeId;
    private Map<Id,Id> oppLineItemsProdMapping;
    //private map<string,string> oplEventMap;
    
    list<EventOplLink> eventopl;
    public boolean processComplete	{get; set;}
    
    
    public tncRequestEvent(ApexPages.StandardController con)
    {
        processComplete = false;
        oppLineItemsProdMapping =  new Map<Id,Id>();
        oppy = (Opportunity)con.getRecord();
        theProducts = new List<myProduct>();
        productCosts = new Map<Id, list<decimal>>();
        
        string[] oplEvent = System.currentPageReference().getParameters().get('opl').split(',',0);
        list<string> opls = new list<string>();
        //oplEventMap = new map<string,string>();
        
        eventopl = new list<EventOplLink>();
        
        for (string s : oplEvent){
            opls.add(s.split(':')[0]);
            //oplEventMap.put(s.split(':')[0], s.split(':')[1]);
            
            EventOplLink link = new EventOplLink();
            link.oplId = Id.Valueof(s.split(':')[0]);
            link.EventId = Id.Valueof(s.split(':')[1]);
            link.hasRow = false;
            eventopl.add(link);
        }

        system.debug('opl: ' + opls);
        system.debug('oplEvent: ' + oplEvent);
        system.debug('eventopl: ' + eventopl);
        //system.debug('oplEventMap: ' + oplEventMap);
        
        oppy = [
            SELECT
                id,
                name,
                AccountId,
                Account.RecordType.Name,
                CloseDate,
                CurrencyIsoCode, // Case 0001747
               (
                    SELECT
                        id,
                        contactId
                    FROM
                        OpportunityContactRoles
                    WHERE
                        isPrimary=true
                ),
                (
                    SELECT
                        Id,
                        TotalPrice,
                        UnitPrice,
                        PricebookEntry.Product2Id,
                        Number_of_Delegates__c, 
                    	quantity,
                    	In_Company_Number_of_Days__c
                    FROM
                        OpportunityLineItems o
                    WHERE
                        PricebookEntry.Product2.No_Event__c = False and Id in :opls
                )
            FROM
                Opportunity
            WHERE
                id =: oppy.Id];
        
        list<Id> productIds = new list<Id>();
        for(OpportunityLineItem o : oppy.OpportunityLineItems)
        {
            productIds.add(o.PricebookEntry.Product2Id);
        }
        
        map<id,Product2> products = new map<id,product2>( [ SELECT id, name, Family, Event_Record_Type__c, Event_Type__c FROM Product2 WHERE id in :productIds order by name]);
        
        for(OpportunityLineItem o : oppy.OpportunityLineItems)
        {
            list<decimal> ds = new List<decimal>();
            ds.add(o.UnitPrice);
            ds.add(o.Number_Of_Delegates__c < 1 ? 1 : o.Number_Of_Delegates__c );
            productCosts.put(o.PricebookEntry.Product2Id, ds);
            oppLineItemsProdMapping.put(o.PricebookEntry.Product2Id,o.Id);
            myProduct product = new myProduct(products.get(o.PricebookEntry.Product2Id),ds);
            product.oppLineItemId  = o.Id;
            product.oliQty = o.Quantity;
            product.oliNoOfDays = o.In_Company_Number_of_Days__c;
            product.oliUnitPrice = o.UnitPrice;
            product.oliDelegates = o.Number_of_Delegates__c;
            theProducts.add(product);
        }

        system.debug('theProducts '+ theProducts);
    }
    
    public void addRow()
    {
        system.debug('oplid: ' + oplid);
        for(myProduct p : theProducts)
        {
            if(p.oppLineItemId == oplId )
            {
                Id transferredFrom = null;//oplEventMap.get(oplId)
                decimal numOfOPL = 0;
                for (EventOplLink link : eventopl){
                    if (link.oplId == p.oppLineItemId && link.hasRow == false){
                        transferredFrom = link.eventId;
                        link.hasRow = true;
                        break;
                    }
                }
                
                system.debug('eventopl: ' + eventopl);
                system.debug('transferredFrom: ' + transferredFrom);
                
                for (EventOplLink link : eventopl){
                    if (link.oplId == p.oppLineItemId){
                        numOfOPL++;
                    }
                }

                if (p.theEvents.size() <  numOfOpl){
                    
                    p.theEvents.add(new Special_Event__c(Venue__c = oppy.Account.RecordType.Name== 'Venue' ? oppy.AccountId :null,
                                                         Transferred_From__c = transferredFrom));
                } else {
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot add more rows for product ' + p.me.Name));
                }
                break;
            }
        }
    }
    
    public PageReference save()
    {
        List<RecordType> rts = [SELECT id, name FROM RecordType WHERE SObjectType = 'Special_Event__c'];
        Id recordTypeId;
        List<Special_Event__c> events;
        List<Special_Event_Booking__c> bookings = new List<Special_Event_Booking__c>();
        // Case 0001747
        List<Special_Event_Unit__c> units = new List<Special_Event_Unit__c>();
        List<Special_Event_Unit_Booking__c> unitBookings = new List<Special_Event_Unit_Booking__c>(); 
        Id rtsId;
        Id rtsAuditId; // Case 00001850
        for (RecordType rt: rts)
        {
            if (rt.name == 'In-Company Event')
                rtsId = rt.id;
            else // Case 00001850 - added Audit Record Type
                if (rt.name == 'Audit')
                    rtsAuditId = rt.id;
        }
        // End of Case 0001747
        for(myProduct p : theProducts)
        {
            events = new List<Special_Event__c>();
            recordTypeId = null;
            if(p.createable)
            {               
                for(RecordType rt : rts)
                {
                    if(rt.name == p.me.Event_Record_Type__c){
                        recordTypeId = rt.Id;
                    }
                }               
                
                for(Special_Event__c e : p.theEvents)
                {
                    if(e.StartDate__c != null && e.Latest_Start_Date__c != null)
                    {
                        e.RecordTypeId = recordTypeId;
                        e.type__c = p.me.Event_Type__c;
                        e.Opportunity__c = oppy.Id;
                        e.Status__c = 'Requested';
                        e.Stage__c = 'Provisional';
                        e.Product__c = p.myId;
                        events.add(e);
                    }
                }
            
                if(events.size() > 0)
                {
                    try
                    {
                        insert events;
                        
                        map<id,id> transferto = new map<id,id>();

                        boolean primaryBooking = true;
                        for(Special_Event__c e : events)
                        {
                            if (transferto.containsKey(e.Transferred_From__c) == false){
                                transferTo.put(e.Transferred_From__c, e.Id);
                            }
                            
                            if (e.RecordTypeId==rtsId||e.RecordTypeId==rtsAuditId)
                            {
                                OpportunityLineItem opl = [Select ol.In_Company_Number_of_Days__c From OpportunityLineItem ol Where Id = :p.oppLineItemId ][0];
                                
                                Date usableStartDate = e.StartDate__c;
                                Integer duration;
                                if (opl.In_Company_Number_of_Days__c==null)
                                {
                                    duration = 0;
                                }
                                else
                                {
                                    duration = opl.In_Company_Number_of_Days__c.Round().intValue();
                                }
                                System.debug('Duration: '+ duration);
                                if (duration==0)
                                {
                                    duration = 1;
                                }
                                System.debug('Duration before run: '+ duration);
                                for (Integer i=0;i<duration;i++)
                                {
                                    System.debug('looping creating the event unit: '+ i);
                                    Datetime startDate = datetime.newInstance(usableStartDate.year(), usableStartDate.month(), usableStartDate.day(), 9, 0, 0);
                                    Datetime endDate = datetime.newInstance(usableStartDate.year(), usableStartDate.month(), usableStartDate.day(), 17, 0, 0);
                                    Boolean primaryUnit;
                                    if(i==0)
                                    {
                                        primaryUnit=True;
                                    }
                                    else
                                    {
                                        primaryUnit=False;
                                    }
                                    Special_Event_Unit__c unit = new Special_Event_Unit__c(
                                                                    name = 'Day '+(i+1),
                                                                    primary_c__c = primaryUnit,
                                                                    unit_start_time__c = startDate,
                                                                    unit_end_time__c = endDate,
                                                                    venue__c = e.Venue__c,
                                                                    Special_Event__c= e.id,
                                                                    CurrencyIsoCode = oppy.CurrencyIsoCode);
                                    units.add(unit);
                                    usableStartDate=usableStartDate.addDays(1);                                 
                                }
                                if(e.RecordTypeId==rtsAuditId)
                                    e.Audit_Number_of_Days__c=duration;
                                
                            }

                            primaryBooking = true;
                            Special_Event_Booking__c booking = new Special_Event_Booking__c(
                                Opportunity__c = oppy.Id,
                                Special_Event__c = e.Id,
                                Status__c='Provisional',
                                Type__c = 'In-Company Primary',
                                Contact__c = oppy.OpportunityContactRoles[0].contactid,
                                Company__c = oppy.AccountId,
                                Primary_Booking__c = primaryBooking,
                                Booking_Fee__c = primaryBooking ? p.cost : 0.0);
                                
                            primaryBooking = false;

                            booking.OPL_ID__c = p.oppLineItemId;
                            bookings.add(booking);                          
                        
                            if(p.numberOfDelegates > 1)
                            {
                                for(integer i = 1; i < p.numberOfDelegates; i++)
                                {
                                    Special_Event_Booking__c bookingAdditional = new Special_Event_Booking__c(
                                        Opportunity__c = oppy.Id,
                                        Status__c='Provisional',
                                        Type__c = 'In-Company Additional',
                                        Special_Event__c = e.Id,
                                        Company__c = oppy.AccountId,
                                        Booking_Fee__c = 0.0);
                                    if(!oppLineItemsProdMapping.isEmpty())
                                    {
                                        if(oppLineItemsProdMapping.containsKey(p.myId))
                                            bookingAdditional.OPL_ID__c  = p.oppLineItemId;
                                    }
                                    bookings.add(bookingAdditional);
                                }
                            }
                        }
                        
                        list<Special_Event__c> mainEvents = [select id from Special_Event__c where id in :transferTo.keySet()];
                        for (Special_Event__c evt : mainEvents){
                            evt.Transferred_To__c = transferTo.get(evt.id);
                        }
                        update mainEvents;
                        
                        update events;
                        processComplete = true;
                    }
                    catch(System.Exception ex)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
                        return null;
                    }
                }
            }
        }
        try
        {
            if(bookings.size() > 0)
                insert bookings;
        }
        catch(System.Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            return null;
        }   
        
        // Case 0001747
        try
        {
            if(units.size() > 0)
                insert units;

        }
        catch(System.Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            return null;
        }
        
        for (Special_Event_Booking__c e: bookings)
        {
            Integer i = 0;
            System.debug('Looping Event Booking: ');
            // Case 00001851
            for (Special_Event_Unit__c u:[Select Id From Special_Event_Unit__c Where Special_Event__c=:e.Special_Event__c])
            {
                System.debug('Looping special Event unit to create special event Unit Booking: '+u.id);
                Special_Event_Unit_Booking__c unitBooking = new Special_Event_Unit_Booking__c(currencyIsoCode=oppy.CurrencyIsoCode,
                                                                                            attended__c = false,
                                                                                            event_unit__c = u.Id,
                                                                                            contact__c = e.contact__c,
                                                                                            event_booking__c=e.id);
                unitBookings.add(unitBooking);
                i++;
            }
        }
        
        try
        {
            if(unitBookings.size() > 0)
                insert unitBookings;

        }
        catch(System.Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            return null;
        }
        
        // End Case 0001747             
        //return new PageReference('/'+oppy.id);

        return null;
    }
    
    public PageReference returnToOpp(){
        return new PageReference('/'+oppy.id);      
    }
    
    public PageReference transferMore(){
        return new PageReference('/apex/tncInCompanyTransfer?oppId='+oppy.id);      
    }
    
    public PageReference confirmPendingTransfer(){
        return new PageReference('/apex/tncConfirmTransfer?oppId='+oppy.id);      
    }
    
    public class EventOplLink{
        
        public Id eventId     {get;set;}
        public Id oplId       {get;set;}
        public boolean hasRow {get;set;}
        
    }
    
    public class myProduct
    {
        public List<Special_Event__c> theEvents{get; set;}
        public Product2 me{get; set;}
        public Id myId{get; private set;}
        private decimal cost;
        private decimal numberOfDelegates;
        public boolean createable{get; private set;}
        
        public Id oppLineItemId {get; set;}
        public decimal oliQty {get; set;}
        public decimal oliNoOfDays {get; set;}
        public decimal oliUnitPrice {get; set;}
        public decimal oliDelegates {get; set;}
        public string linebreak {get; set;}
        
        public myProduct(Product2 me, List<decimal> ds)
        {
            this.linebreak = '\n';
            this.me = me;
            this.myId = me.Id;
            this.cost = ds[0];
            this.numberOfDelegates = ds[1];
            if(numberOfDelegates == null || numberOfDelegates < 1)
                numberOfDelegates = 1;
            theEvents = new List<Special_Event__c>();
            if(me.Family == 'Audit' || me.Family == 'In-Company Training' || me.Family == 'Advisory'){
                createable = true;
            }else{
                createable = false;
            }
        }
    }
}