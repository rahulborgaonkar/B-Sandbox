@istest(seeAllData=true)
class testBSCDelegateCapture
{
    private static string RandomString
    {
        get
        {
            return string.valueof(math.random()).substring(1,10);
        }
    }

    @istest
    static void testBSCDelegateCapture_Method1() 
    {
        Date startDate = System.Today()-366;

        Account acc;
        Contact cnt1;
        Contact cnt2;
        Contact cnt3;
        Contact cnt4;
        ID dim1Id;
        ID dim2Id;
        ID glaId;
        Product2 prd;
        Pricebook2 spb;
        PricebookEntry pbe;
        Opportunity opp;
        OpportunityLineItem oli;
        Subscription__c sub;
        Subscription_Line__c subln;
        Subscription_Site__c subsite;
        Special_Event__c spe;
        Special_Event_Booking__c speb;
        Temp_Special_Event_Booking__c tspeb1, tspeb2;

        acc = new Account(name = 'testAccount' + RandomString);
        insert acc;
        system.debug('Account : ' + acc);
        cnt1 = new Contact(Email='test1@testing.com', 
                        FirstName = 'testFirstName' + RandomString, 
                        LastName='testLastName' + RandomString , 
                        Title = 'Test Title',
                        Phone = '0707070707',
                        AccountId = acc.id
                    );
        insert cnt1;
        system.debug('Contact : ' + cnt1);

        cnt2 = new Contact(Email='test2@testing.com', 
                        FirstName = 'testFirstName' + RandomString, 
                        LastName='testLastName' + RandomString , 
                        Title = 'Test Title',
                        Phone = '0707070707',
                        AccountId = acc.id
                    );
        insert cnt2;
        system.debug('Contact : ' + cnt2);

        cnt3 = new Contact(Email='test3@testing.com', 
                        FirstName = 'testFirstName' + RandomString, 
                        LastName='testLastName' + RandomString , 
                        Title = 'Test Title',
                        Phone = '0707070707',
                        AccountId = acc.id
                    );
        insert cnt3;
        system.debug('Contact : ' + cnt3);

        cnt4 = new Contact(Email='test4@testing.com', 
                        FirstName = 'testFirstName', 
                        LastName='testLastName', 
                        Title = 'Test Title',
                        Phone = '0707070707',
                        AccountId = acc.id
                    );
        insert cnt4;
        system.debug('Contact : ' + cnt4);

        dim1Id = [select id from c2g__codaDimension1__c where name = '110 - Finance' limit 1].id;
        system.debug('ID dim1Id - ' + dim1Id);
        dim2Id = [select id from c2g__codaDimension2__c where name = '0000 - General' limit 1].id;
        system.debug('ID dim2Id - ' + dim2Id);
        glaId = [select id from c2g__codaGeneralLedgerAccount__c where name = '3000 - Income - Sales Activities' Limit 1].Id;
        system.debug('ID glaId - ' + glaId);
        
        /* CREATE PRODUCT2*/
        prd = [SELECT id, Name, Allows_Provisional_Bookings__c, c2g__CODASalesRevenueAccount__c, Dimension_1__c, Dimension_2__c, Auto_Post_Invoice__c FROM Product2 WHERE name = 'Bespoke Training'];
        system.debug('Product2 prd - ' + prd);
        
        /* GET STANDARD PRICEBOOK*/
        spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true and name = 'Standard Price Book' Limit 1];
        system.debug('Pricebook2 spb - ' + spb);

        pbe = [SELECT IsActive, UnitPrice, Id, Pricebook2Id, ProductCode, Product2Id, Name, UseStandardPrice FROM PricebookEntry where Product2Id = :prd.Id and Pricebook2Id = :spb.Id];
        system.debug('PricebookEntry pbe - ' + pbe);

        opp = new Opportunity(Name = 'testOpportunity' + RandomString, AccountId = acc.Id, StageName = 'Qualifying', RecordTypeId = '012200000001W3IAAU', CloseDate = Date.today());
        insert opp;
        system.debug('Opportunity - ' + opp);

        oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Pricing_Exception__c = true, Quantity = 3, UnitPrice = 320);
        insert oli;
        system.debug('Opportunity Line Item - ' + oli.id);

        sub = new Subscription__c(Account_Name__c = acc.id, Status__c = 'Current - Renewing', Contact__c = cnt1.id, 
                        Start_Date__c = startDate, End_Date__c = startDate+364, Type__c = 'New', Renewal_Opportunity__c = true,
                        Renewal_Opportunity_Created__c = false, Renewal_Reminders__c = true, Opportunity__c = opp.Id, Longest_Duration_Years__c = 1 );
        insert sub;
        
        /* CREATE SUBSCRIPTION LINE*/
        subln = new Subscription_Line__c(Subscription__c = sub.Id, Quantity__c = 1, Quantity_Available__c = 0, Product_Sales_Price__c = 100,
                        Renewal_Price__c = 100, Product__c =  prd.id);
        insert subln;
        
        /* CREATE SUBSCRIPTION SITE*/
        subsite = new Subscription_Site__c(Subscription__c = sub.id, No_Magazine_Mailing__c = False, Site_Account__c = acc.Id,
                        Site_Contact__c = cnt1.Id, Site_Start_Date__c = startDate, Type__c = 'Single Site', Active__c = True);
        insert subsite;

        /* CREATE BSC EVENT*/
        spe = new Special_Event__c(Opportunity__c = opp.Id, Name = 'Test Event'+ RandomString, Product__c = prd.Id, 
                        Type__c = 'In-Company Event', Status__c = 'Confirmed', Stage__c = 'Confirmed', RecordTypeId = '012200000001W3hAAE',
                        StartDate__c = Date.today(), EndDate__c = Date.today().addDays(5), Trainer_Name__c = 'Rahul', Trainer_Email__c = 'rahul.borgaonkar@gmail.com');
                
        insert spe;
        system.debug('Special Event - ' + spe);
    
        /* CREATE BSC EVENT BOOKING*/
        speb = new Special_Event_Booking__c(Opportunity__c = opp.Id, Booking_Fee__c = 10000, Special_Event__c = spe.Id, 
                        Company__c = acc.id, Contact__c = cnt1.id, 
                        Override_Booking_Fee__c = false, Status__c = 'Attended', Type__c = 'In-Company Primary');
        insert speb;
        system.debug('Special Event Booking - ' + speb);
        tspeb1 = new Temp_Special_Event_Booking__c(Opportunity__c = opp.Id, Special_Event__c = spe.Id, 
                        Company__c = acc.id, Contact__c = cnt2.id, Status__c = 'Attended');
        insert tspeb1;
        system.debug('Temp Special Event Booking - ' + tspeb1);
                
        tspeb2 = new Temp_Special_Event_Booking__c(Opportunity__c = opp.Id, Special_Event__c = spe.Id, 
                        Company__c = acc.id, Status__c = 'Attended');


        insert tspeb2;
        system.debug('Temp Special Event Booking - ' + tspeb2);
        
        Test.starttest();

        PageReference pageRef = Page.BSCDelegateCapture;
        system.debug('PageReference pageRef - ' + pageRef);
        pageRef.getParameters().put('id', spe.id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.standardController controller = new ApexPages.standardController(spe);
        system.debug('ApexPages.standardController controller - ' + controller);
        
        BSCDelegateCaptureController delegateCapture = new BSCDelegateCaptureController(controller);
        system.debug('BSCDelegateCaptureController bscDelCap - ' + delegateCapture);
        system.debug('EventBookingRecords - ' + delegateCapture.EventBookingRecords);
        integer index = 3;
        delegateCapture.index = index;
        delegateCapture.EventBookingRecords[index].bookingContact.email = 'test3@testing.com';
        delegateCapture.searchContact();
        delegateCapture.saveValues();
        
        index = 4;
        delegateCapture.index = index;
        delegateCapture.addDelegates();
        delegateCapture.EventBookingRecords[index].bookingContact.FirstName = 'testFirstName';
        delegateCapture.EventBookingRecords[index].bookingContact.LastName = 'testLastName';
        delegateCapture.searchDuplicateName();
        delegateCapture.saveValues();
        delegateCapture.popupIndex = 0;
        delegateCapture.savePopup();
        delegateCapture.saveData();

        delegateCapture.deleteDelegate();

        index = 0;
        delegateCapture.index = index;
        delegateCapture.isSubstitute = false;
        delegateCapture.substituteDelegate();
        delegateCapture.EventBookingRecords[index+1].bookingContact.email = 'sub@testing.com';
        delegateCapture.EventBookingRecords[index+1].bookingContact.FirstName = 'testFirstName' + RandomString;
        delegateCapture.EventBookingRecords[index+1].bookingContact.LastName = 'testLastName' + RandomString;
        delegateCapture.EventBookingRecords[index+1].bookingContact.Title = 'Test Title';
        delegateCapture.EventBookingRecords[index+1].bookingContact.Phone = '0707070707';
        delegateCapture.saveValues();
        delegateCapture.saveData();
        
        delegateCapture.isSubstitute = true;
        delegateCapture.substituteDelegate();
        delegateCapture.saveValues();
        delegateCapture.saveData();

        BSCDelegateCaptureClass.sendDelegateFormToTrainer(spe.id);

        Test.stoptest();
    }
}