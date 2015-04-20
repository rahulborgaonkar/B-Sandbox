/*
    Author - Richard Durrant
    Controller for 0818-IPE development task.
    
    Modified by Ben Mansfield 6 August 2010
    Modified by N Muneesamy   15 March 2011 -  Case 00001682 Change done to ensure that the user selected Venue applies
    Modified by N Muneesamy   29 March 2011 -  Case 00001747 Create Event Units at the same time as creating the Event.
    Modified by N.Muneesamy   26 April 2011 -  Case 00001850 Include Audit Record Types when creating Special Event Unit Bookings
    Modified by N.Muneesamy   26 April 2011 -  Case 00001851 Special Event Unit Bookings should not double up when there are more than 1 Opportunity Product Line
    Modified by F.Pindar      29 Feb 2012   -  No Case - Phone request from Steve to only allow events with "No Event" = False to be requested
    Modified by VS 18 11 2013  - OPT-584 - ISSUE WITH LINKING BOOKINGS WITH OPL ID. 
*/

public with sharing class CreateProvisionalEventsController {

    public Opportunity oppy                 {get; private set;}
    public List<myProduct> theProducts      {get; set;}
    public id theProductId                  {get; set;}
    public id oplId                         {get; set;}
    private Map<Id, list<decimal>> productCosts;
    private  String recordTypeId;
    private Map<Id,Id> oppLineItemsProdMapping;
    public Debug_Tracing__c dt;
                
    public CreateProvisionalEventsController(ApexPages.StandardController con)
    {
        oppLineItemsProdMapping =  new Map<Id,Id>();
        oppy = (Opportunity)con.getRecord();
        theProducts = new List<myProduct>();
        productCosts = new Map<Id, list<decimal>>();
        dt = new Debug_Tracing__c ();
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
                        Quantity,
                        In_Company_Number_of_Days__c
                    FROM
                        OpportunityLineItems o
                    WHERE
                        PricebookEntry.Product2.No_Event__c = False
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

        map<id,Product2> products = new map<id,product2>( [ SELECT id, name, Family, Event_Record_Type__c, Event_Type__c, ProductCode FROM Product2 WHERE id in :productIds order by name]);
        
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
        
        
       /* for(Product2 p : [
            SELECT
                id,
                name,
                Family,
                Event_Record_Type__c,
                Event_Type__c
            FROM
                Product2
            WHERE
                id in :productCosts.keySet()
            ORDER BY
                Name])
        {
            if(p.Family == 'Audit' || p.Family == 'In-Company Training' || p.Family == 'Advisory')
                theProducts.add(new myProduct(p, productCosts.get(p.id)));
        }*/
    }
    
    public void addRow() 
    {
        for(myProduct p : theProducts)
        {
            /*if(p.me.Id == theProductId)*/
            //system.debug('p.oliQty - ' + p.oliQty);
            //system.debug('p.theEvents.size() - ' + p.theEvents.size());
                        
            if(p.oppLineItemId == oplId)
            {
                //if(p.theEvents.size()+1 <= p.oliQty)
                //{
                    p.theEvents.add(new Special_Event__c(Venue__c = oppy.Account.RecordType.Name== 'Venue' ? oppy.AccountId :null));
                    break;
                //}
                //else
                //{
                //    String errMsg = 'You cannot add Rows more than Quantity ' + p.oliQty + ' specified.';
                //    system.debug('errMsg - ' + errMsg);
                //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errMsg));
                //}
            }
        }
    }
    
    public PageReference save()
    {
        List<RecordType> rts = [
            SELECT
                id,
                name
            FROM
                RecordType
            WHERE
                SObjectType = 'Special_Event__c'];
        Id recordTypeId;
        List<Special_Event__c> events = new List<Special_Event__c>(); // Initialised events - Rahul
        List<Special_Event_Booking__c> bookings = new List<Special_Event_Booking__c>();
        // Case 0001747
        List<Special_Event_Unit__c> units = new List<Special_Event_Unit__c>();
        List<Special_Event_Unit_Booking__c> unitBookings = new List<Special_Event_Unit_Booking__c>(); 
        Id rtsId;
        Id rtsAuditId; // Case 00001850

        dt = new Debug_Tracing__c(Debug_Details__c='Start Saving');
        insert dt;


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
            //events = new List<Special_Event__c>(); // Commented as not required to initialise after each product.
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
                        //e.Status__c = 'Cancelled - Error'; // Added for Testing by Rahul
                        e.Stage__c = 'Provisional';
                        e.Product__c = p.myId;
                        system.debug('Event - ' + e);
                        events.add(e);
                    }
                }
            }
        } // Loop finishes here after collecting all events - Rahul

        system.debug('All events 1 - ' + events);

        if(events.size() > 0) // New if and inserting events records here. - Rahul
        {
            try
            {
                System.debug('Before Insert Events');
                System.debug('events.size() - ' + events.size());
                insert events; //Took this insert outside loop to avoid Too many SOQL error
                dt = new Debug_Tracing__c(Debug_Details__c='INSERT 1 - Inserting events');
                insert dt;
                System.debug('After Insert Events');
            }
            catch(System.Exception ex)
            {
                dt = new Debug_Tracing__c(Debug_Details__c=ex.getMessage());
                insert dt;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
                return null;
            }
        }

        system.debug('All events 2 - ' + events);

        List<ID> eventIds = new List<ID>();

        for(Special_Event__c e : events)
        {
            eventIds.add(e.id);
        }

        events = [select Name, RecordTypeId, Venue__c, Latest_Start_Date__c, Product__c, Opportunity__c, Type__c, StartDate__c, Status__c, stage__c, Event_Auto_Number__c FROM Special_Event__c where id in :eventIds];

        for(myProduct p : theProducts)
        {
            for(Special_Event__c pe : p.theEvents)
            {
                if(events.size() > 0) // New if and updating events records here - Rahul
                {
                    for(Special_Event__c e : events)
                    {
                        if(p.myId == e.Product__c && pe.id == e.id)
                        {
                            system.debug('Product - ' + p.me.ProductCode);
                            system.debug('Event Auto Number - ' + e.Event_Auto_Number__c);
                            system.debug('Event Product - ' + e.Product__c);
                            e.name = p.me.ProductCode + '/' + e.Event_Auto_Number__c;
                            pe.name = e.name;
                        }
                    }
                }
            }
        }
       
        if(events.size() > 0) // New if and updating events records here - Rahul
        {
            try
            {
                System.debug('Before Update Events');
                update events; //Took this update outside loop to avoid Too many SOQL error - Rahul
                dt = new Debug_Tracing__c(Debug_Details__c='UPDATE 1 - Updating events');
                insert dt;
                System.debug('After Update Events');
            }
            catch(System.Exception ex)
            {
                dt = new Debug_Tracing__c(Debug_Details__c=ex.getMessage());
                insert dt;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
                return null;
            }
        }

        system.debug('p.theEvents 1 - ' + events);

        for(myProduct p : theProducts)
        {
            //events = new List<Special_Event__c>(); // Commented as not required at this stage - Rahul
            system.debug('p.theEvents - ' + p.theEvents);
            if(p.createable)
            {               
                if(events.size() > 0)
                {
                    try
                    {
                        //insert events; //Took this insert command outside loop to avoid Too many SOQL error - Rahul

                        boolean primaryBooking = true;
                        //Took this SOQL outside loop - Rahul
                        OpportunityLineItem opl = [Select ol.In_Company_Number_of_Days__c From OpportunityLineItem ol Where Id = :p.oppLineItemId ][0];
                        for(Special_Event__c e : p.theEvents)
                        {
                            system.debug('p.theEvents 2 - ' + e);
                            if(p.myId == e.Product__c)
                            {

                                if (e.RecordTypeId==rtsId||e.RecordTypeId==rtsAuditId)
                                {
                                    //OpportunityLineItem opl = [Select ol.In_Company_Number_of_Days__c From OpportunityLineItem ol Where ol.OpportunityId = :e.Opportunity__c and ol.PricebookEntry.product2id = :e.Product__c ][0];
                                    //OpportunityLineItem opl = [Select ol.In_Company_Number_of_Days__c From OpportunityLineItem ol Where Id = :p.oppLineItemId ][0]; // commented by Rahul, moving outside loop

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

                                system.debug('Product - ' + p.me.ProductCode);
                                system.debug('Event Auto Number - ' + e.Event_Auto_Number__c);
                                system.debug('Event Product - ' + e.Product__c);
                                e.name = p.me.ProductCode + '/' + e.Event_Auto_Number__c;

                                //List<Special_Event_Booking__c> currentEventBooking = new List<Special_Event_Booking__c>();

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
                                //if(!oppLineItemsProdMapping.isEmpty())
                                //{
                                //    if(oppLineItemsProdMapping.containsKey(e.Product__c))
                                //        booking.OPL_ID__c  = oppLineItemsProdMapping.get(e.Product__c);
                                //}
                                booking.OPL_ID__c = p.oppLineItemId;
                                //currentEventBooking.add(booking);
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
                                            //bookingAdditional.OPL_ID__c  = oppLineItemsProdMapping.get(p.myId);
                                            bookingAdditional.OPL_ID__c  = p.oppLineItemId;
                                        }
                                        //currentEventBooking.add(booking);
                                        bookings.add(bookingAdditional);
                                    }
                                }
                                //bookings.addAll(currentEventBooking);
                            }
                        }
                        //update events; Commented and took this update commmand outside loop Line 318 - Rahul
                    }
                    catch(System.Exception ex)
                    {
                        dt = new Debug_Tracing__c(Debug_Details__c=ex.getMessage());
                        insert dt;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
                        return null;
                    }
                }
            }
        }

        if(events.size() > 0) // New if and updating events records here - Rahul
        {
            try
            {
                System.debug('Before Update Events');
                update events; //Took this update outside loop to avoid Too many SOQL error - Rahul
                dt = new Debug_Tracing__c(Debug_Details__c='UPDATE 2 - Updating events');
                insert dt;
                System.debug('After Update Events');
            }
            catch(System.Exception ex)
            {
                dt = new Debug_Tracing__c(Debug_Details__c=ex.getMessage());
                insert dt;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
                return null;
            }
        }

        try
        {
            if(bookings.size() > 0)
            {
                insert bookings;
                dt = new Debug_Tracing__c(Debug_Details__c='INSERT 2 - Inserting bookings');
                insert dt;
            }
        }
        catch(System.Exception ex){
            dt = new Debug_Tracing__c(Debug_Details__c=ex.getMessage());
            insert dt;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            return null;
        }   
        
        // Case 0001747
        try
        {
            if(units.size() > 0)
            {
                insert units;
                dt = new Debug_Tracing__c(Debug_Details__c='INSERT 3 - Inserting units');
                insert dt;
            }
        }
        catch(System.Exception ex){
            dt = new Debug_Tracing__c(Debug_Details__c=ex.getMessage());
            insert dt;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            dt = new Debug_Tracing__c(Debug_Details__c=ex.getMessage());
            insert dt;
            return null;
        }


        List<Special_Event__c> allEvents = new List<Special_Event__c> ();
        for (Special_Event_Booking__c e: bookings)
        {
            allEvents.add(new Special_Event__c(id=e.Special_Event__c));
        }

        // Took this SOQL outside for loop from Line 378 - Rahul
        List<Special_Event_Unit__c> allEvent_Units = new List<Special_Event_Unit__c>([Select Id, Special_Event__c From Special_Event_Unit__c Where Special_Event__c = :allEvents]);

        for (Special_Event_Booking__c e: bookings)
        {
            Integer i = 0;
            System.debug('Looping Event Booking: ');
            // Case 00001851

            // Added for loop to get units for specific booking - Rahul
            List<Special_Event_Unit__c> requiredEvent_Units = new List<Special_Event_Unit__c> ();
            for (Special_Event_Unit__c eu: allEvent_Units)
            {
                if(eu.Special_Event__c == e.Special_Event__c)
                {
                    requiredEvent_Units.add(eu);
                }
            }

            system.debug('requiredEvent_Units - ' + requiredEvent_Units);

//          for (Special_Event_Unit__c u:[Select Id From Special_Event_Unit__c Where Special_Event__c=:e.Special_Event__c]) // Taken this SOQL outside loop - Rahul
            for (Special_Event_Unit__c u : requiredEvent_Units)
            {
                System.debug('Looping special Event unit to create special event Unit Booking: ' + u.id);
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
            {
                insert unitBookings;
                dt = new Debug_Tracing__c(Debug_Details__c='INSERT 4 - Inserting unitBookings');
                insert dt;
            }
        }
        catch(System.Exception ex){
            dt = new Debug_Tracing__c(Debug_Details__c=ex.getMessage());
            insert dt;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            return null;
        }
        // End Case 0001747
        dt = new Debug_Tracing__c(Debug_Details__c='End Saving');
        insert dt;

        return new PageReference('/'+oppy.id);      
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
    /*
    private static TestMethod void CreateProvisionalEventsControllerTest()
    {
       string random = string.valueof(math.random()).substring(1,10);
         
        Opportunity opp = new Opportunity(
            Name = 'Test Opp ' + random,
            StageName = 'Qualifying',
            IC_Price_Variation_Approved__c = true,
            CloseDate = System.today());
        insert opp;
        
        Product2 prod = new Product2(
            Name = 'Test Event Product' +random,
            Allows_Provisional_Bookings__c = true,
            Transfer_Charge_Day_1__c = 10,
            Transfer_Charge_Day_2__c = 5,
            Transfer_Charge_Day_3__c = 2,
            family = 'Audit',
            Event_Record_Type__c = 'Audit',
            Event_Type__c = 'Audit',
            Transfer_Charge_Fee_1__c = 120,
            Transfer_Charge_Fee_2__c = 60,
            Transfer_Charge_Fee_3__c = 40,
            Transfer_Charge_Fee_Final__c = 10);
        insert prod;
        
        Pricebook2 stdPricebook = [
            SELECT
                Id
            FROM
                Pricebook2
            WHERE
                IsStandard = true and Name = 'Standard Price Book' Limit 1];
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            UnitPrice = 300,
            Pricebook2Id = stdPricebook.Id,
            IsActive = true);
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            Pricing_Exception__c = true, 
            UnitPrice = 320,
            Number_of_Delegates__c=3,
            In_Company_Number_of_Days__c=2);
        insert oli;
        
        Account acc = new Account(name = 'TestAccount'+random);
        insert acc;
        
        Contact cont = new Contact ();
        cont.FirstName = 'TestFN'+random;
        cont.LastName = 'TestLN'+random;
        cont.Accountid = acc.id;
        insert cont;

        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = cont.Id,
            isPrimary = true);
        insert ocr;
        
        Test.startTest();
        CreateProvisionalEventsController con = new CreateProvisionalEventsController(new ApexPages.Standardcontroller(opp));
        con.theProductId = prod.Id;
        con.addRow();
        
        for(CreateProvisionalEventsController.myProduct p : con.theProducts){
            Special_Event__c ev = p.theEvents[0];
            ev.StartDate__c = System.today();
            ev.Latest_Start_Date__c = system.today();
            Account a = [
                SELECT
                    id
                FROM
                    Account
                LIMIT
                    1];
            ev.Venue__c = a.Id;
        }
    
        con.save();
        Test.stopTest();
        
    }*/
}