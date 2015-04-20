@IsTest(SeeAllData=true)
public class tncTransferBookingTest{
    
    static testMethod void testtncTransferBooking()
    {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        insert opp;
        
        Product2 prod = new Product2();
        prod.Name = 'Test Event Product';
        prod.Allows_Provisional_Bookings__c = true;
        prod.Transfer_Charge_Day_1__c = 10;
        prod.Transfer_Charge_Day_2__c = 5;
        prod.Transfer_Charge_Day_3__c = 2;
        
        prod.Transfer_Charge_Fee_1__c = 120;
        prod.Transfer_Charge_Fee_2__c = 60;
        prod.Transfer_Charge_Fee_3__c = 40;
        prod.Transfer_Charge_Fee_Final__c = 10;
        insert prod;
        
        Special_Event__c event = new Special_Event__c();
        event.Product__c = prod.Id;
        event.City__c = 'London';
        event.StartDate__c = System.today().addDays(3);
        insert event;
        
        Special_Event_Booking__c eventBooking = new Special_Event_Booking__c();
        eventBooking.Opportunity__c = opp.Id;
        eventBooking.Special_Event__c = event.Id;
        insert eventBooking;
        
        PageReference pagRef = new PageReference('/apex/tncTransferBookingWizard?id='+eventBooking.Id+'&fieldname='+eventBooking.Id+'&events='+event.Name);
        Test.setCurrentPage(pagRef);
        tncTransferBookingWizard con = new tncTransferBookingWizard();
        system.assert(con.record != null);
    }
    
    @IsTest
    private static void testTransfer()
    {
        string random = string.valueof(math.random()).substring(1,10);
        system.debug('************* VS *******' + random);
        Account acc = new Account (
            Name = 'Test Acc'+random,
            Phone = '00000'
            );
        insert acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Test Opp'+random,
            StageName = 'Qualifying',
            IC_Price_Variation_Approved__c = true,
            CloseDate = System.today());
        system.debug('************* VS *******' + opp.Name);
        insert opp;
        
        Product2 prod = new Product2(
            Name = 'Test Event Product'+random,
            Allows_Provisional_Bookings__c = true,
            Transfer_Charge_Day_1__c = 10,
            Transfer_Charge_Day_2__c = 5,
            Transfer_Charge_Day_3__c = 2,
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
                IsStandard = true Limit 1];
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            UnitPrice = 300,
            Pricebook2Id = stdPricebook.Id,
            IsActive = true);
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert oli;
        
        Special_Event__c event = new Special_Event__c(
            Product__c = prod.Id,
            City__c = 'London',
            StartDate__c = System.today().addDays(3),
        	Name = 'Test123');
        insert event;
        
        Special_Event_Booking__c eventBooking = new Special_Event_Booking__c(
            Opportunity__c = opp.Id,
            Special_Event__c = event.Id);
        insert eventBooking;
        
        // Event to transfer
        Special_Event__c transferevent = new Special_Event__c(
            Product__c = prod.Id,
            City__c = 'London',
            Status__c= 'Confirmed',
            StartDate__c = System.today().addDays(30));
        insert transferevent;
        
        tncTransferBookingController con = new tncTransferBookingController();
        con.bookingType = 'Transfer';
        con.eventstoExclude  = event.Name;
        system.debug('con.eventstoExclude: '+con.eventstoExclude);
        con.fieldName = eventBooking.id;
        List<Special_Event_Booking__c> bookingQuery = [
            SELECT
                Id,
                Name,
                Special_Event__r.Product__c,
                Booking_Fee__c,
                Opportunity__c,
                Event_Start_Date__c
            FROM
                Special_Event_Booking__c
            WHERE
                Id = :eventBooking.id];
        
        if (bookingQuery.size() == 1)
            eventBooking = bookingQuery.get(0);
        
        con.booking = [
            SELECT
                Id,
                Name,
                Special_Event__r.Product__c,
                Contact__c,
                Company__c,
                Booking_Fee__c,
                Opportunity__c,
                Event_Start_Date__c 
            FROM
                Special_Event_Booking__c
            WHERE
                Id = :eventBooking.Id];
        
        con.locationCriteria.add('London');
        
        con.next();
        //System.assertEquals(new List<ApexPages.Message>(), ApexPages.getMessages());
        
        // Select the event we created above
        for (tncTransferBookingController.BSCEvent ev : con.eventSelections)
        {
            if (ev.record.Id == transferevent.Id) ev.selected = true;
        }
        
        con.next();
        //System.assertEquals(new List<ApexPages.Message>(), ApexPages.getMessages());
        
        con.save();
        //System.assertEquals(new List<ApexPages.Message>(), ApexPages.getMessages());
        con.cancel();
    }
    
}