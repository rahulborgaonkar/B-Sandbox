@IsTest(SeeAllData=true)
public class tncRequestEventTest{
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
        
        Special_Event__c event = new Special_Event__c();
        event.Product__c = prod.Id;
        event.City__c = 'London';
        event.StartDate__c = System.today();
       
        event.Latest_Start_Date__c = system.today().addDays(3);
        insert event;
        
        Special_Event_Booking__c eventBooking = new Special_Event_Booking__c();
        eventBooking.Opportunity__c = opp.Id;
        eventBooking.Special_Event__c = event.Id;
        eventBooking.OPL_ID__c = oli.id;
        insert eventBooking;
        
        Test.startTest();
        PageReference pagRef = new PageReference('/apex/tncRequestEvent?Id=' + string.valueOf(opp.Id)+'&opl='+string.valueOf(oli.id)+':'+string.valueOf(event.id)+',' );
        Test.setCurrentPage(pagRef);
        
        tncRequestEvent con = new tncRequestEvent(new ApexPages.Standardcontroller(opp));
        con.theProductId = prod.Id;
        con.oplId = oli.id;
        con.addRow();
        
         for(tncRequestEvent.myProduct p : con.theProducts){
            Special_Event__c ev = p.theEvents[0];
            ev.StartDate__c = System.today();
            ev.Latest_Start_Date__c = system.today();
         }
        con.save();
        Test.stopTest();
    }
}