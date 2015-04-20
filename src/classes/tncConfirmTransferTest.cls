@IsTest(SeeAllData=true)
public class tncConfirmTransferTest{
    
    static testmethod void testConfirmTransfer(){
        string random = string.valueof(math.random()).substring(1,10);

        Account acc = new Account(name = 'BSC Test');
        insert acc;
        system.debug('Account acc - ' + acc);
        
        Contact cont = new Contact (FirstName = 'BSC', LastName = 'Test', Accountid = acc.id);
        insert cont;
        system.debug('Contact cont - ' + cont);

/*        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp ' + random,
            StageName = 'Qualifying',
            IC_Price_Variation_Approved__c = true,
            CloseDate = System.today());
        insert opp;
*/

        RecordType rt = [SELECT Id, DeveloperName, SobjectType FROM RecordType where DeveloperName = 'In_Company_Event' and sObjectType = 'Opportunity' limit 1];

        Opportunity opp = new Opportunity(
            Name = 'BSC Test',
            RecordTypeId = rt.id,
            AccountId = acc.id,
            Type = 'Audit',
            StageName = 'Quote/Proposal',
            IC_Price_Variation_Approved__c = true,
            Price_Approval_Given__c = true,
            CloseDate = System.today());
        insert opp;
        system.debug('Opportunity opp - ' + opp);
        
/*
         Product2 prod1 = new Product2(
            Name = 'Test Event1 Product' +random
            );
        insert prod1;
*/
         Product2 prod1 = [select name, Maximum_Discount__c from product2 where name = 'Transfer Fees (Audit)'];
        system.debug('Product2 prod1 - ' + prod1);
/*
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
            Transfer_Charge_Fee_Final__c = 10,
            Transfer_Fee_Product__c = prod1.id);
        insert prod;
*/
         Product2 prod = [select name, Maximum_Discount__c, Allows_Provisional_Bookings__c, Transfer_Charge_Day_1__c, Transfer_Charge_Day_2__c, Transfer_Charge_Day_3__c,
                            family, Event_Record_Type__c, Event_Type__c, 
                            Transfer_Charge_Fee_1__c, Transfer_Charge_Fee_2__c, Transfer_Charge_Fee_3__c, Transfer_Charge_Fee_Final__c,
                            Transfer_Fee_Product__c
                            from product2 where name = 'Five Star Occupational Health and Safety Audit'];
        system.debug('Product2 prod - ' + prod);

        Pricebook2 stdPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true and Name = 'Standard Price Book' Limit 1];
        system.debug('Pricebook2 stdPricebook - ' + stdPricebook);
/*
        PricebookEntry pbe1 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 300,
            Pricebook2Id = stdPricebook.Id,
            IsActive = true);
        insert pbe1;
*/

        PricebookEntry pbe1 = [SELECT IsActive, UnitPrice, Id, Pricebook2Id, ProductCode, Product2Id, Name, UseStandardPrice 
                                FROM PricebookEntry where Product2Id = :prod1.id and Pricebook2Id = :stdPricebook.id];
        system.debug('PricebookEntry pbe1 - ' + pbe1);
/*
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            UnitPrice = 300,
            Pricebook2Id = stdPricebook.Id,
            IsActive = true);
        insert pbe;
*/
        PricebookEntry pbe = [SELECT IsActive, UnitPrice, Id, Pricebook2Id, ProductCode, Product2Id, Name, UseStandardPrice 
                                FROM PricebookEntry where Product2Id = :prod.id and Pricebook2Id = :stdPricebook.id];
        system.debug('PricebookEntry pbe - ' + pbe);

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.unitprice,
            Number_of_Delegates__c=1,
            E_Delivery_Number_of_Licences__c = 1,
            In_Company_Number_of_Days__c=1);
        insert oli;
        system.debug('OpportunityLineItem oli - ' + oli);
/*        
        Account acc = new Account(name = 'TestAccount'+random);
        insert acc;
        
        Contact cont = new Contact ();
        cont.FirstName = 'TestFN'+random;
        cont.LastName = 'TestLN'+random;
        cont.Accountid = acc.id;
        insert cont;
*/
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = cont.Id,
            isPrimary = true);
        insert ocr;
        system.debug('OpportunityContactRole ocr - ' + ocr);
/*        
        Special_Event__c event = new Special_Event__c();
        event.Product__c = prod.Id;
        event.City__c = 'London';
        event.StartDate__c = System.today();
        event.Latest_Start_Date__c = system.today().addDays(3);
        event.Status__c ='Confirmed';
        insert event;
*/

        Special_Event__c event = new Special_Event__c();
        event.Product__c = prod.Id;
        event.Opportunity__c = opp.id;
        event.Status__c ='To Be Transferred';
        event.Stage__c ='Cancelled';
        event.StartDate__c = System.today();
        event.Latest_Start_Date__c = system.today();
        event.Audit_Number_of_Days__c = 1;
        event.Minimum_Places__c = 1;
        event.Maximum_Places__c = 1;
        event.Liability_at_Cancellation_Transfer__c = 0;
        insert event;
        system.debug('Special_Event__c event - ' + event);

        Special_Event_Booking__c eventBooking = new Special_Event_Booking__c();
        eventBooking.Opportunity__c = opp.Id;
        eventBooking.Contact__c = cont.id;
        eventBooking.Special_Event__c = event.Id;
        eventBooking.OPL_ID__c = oli.id;
        insert eventBooking;
        system.debug('Special_Event_Booking__c eventBooking - ' + eventBooking);

        Special_Event__c event1 = new Special_Event__c();
        event1.Product__c = prod.Id;
        event1.Opportunity__c = opp.id;
        event1.Status__c ='Resourced';
        event1.Stage__c ='Provisional';
        event1.StartDate__c = System.today();
        event1.Latest_Start_Date__c = system.today().addDays(1);
        insert event1;
        system.debug('Special_Event__c event1 - ' + event1);
       
        event.Transferred_To__c = event1.id;
        update event;
       
        Special_Event_Booking__c eventBooking1 = new Special_Event_Booking__c();
        eventBooking1.Opportunity__c = opp.Id;
        eventBooking1.Special_Event__c = event1.Id;
        eventBooking1.OPL_ID__c = oli.id;
        insert eventBooking1;
        system.debug('Special_Event_Booking__c eventBooking1 - ' + eventBooking1);

        Test.startTest();
        PageReference pagRef = new PageReference('/apex/tncConfirmTransfer?oppId=' + string.valueOf(opp.Id));
        Test.setCurrentPage(pagRef);
        tncConfirmTransfer con = new tncConfirmTransfer();
        for (tncConfirmTransfer.ConfirmEvents conf : con.events){
            conf.selected = true;
        }
        con.confirmTransfer();
    }
}