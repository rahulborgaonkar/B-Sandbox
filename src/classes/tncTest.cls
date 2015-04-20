@isTest(SeeAllData=True)
private class tncTest {
    
    public static Account account;
    public static Opportunity opportunity;
    public static OpportunityLineItem OppLineItem;
    public static Special_Event__c specialEvent;
    public static Special_Event__c specialEvent1;
    public static Special_Event_Booking__c specialEventbooking;
    public static Product2 product2;
    public static Subscription__c subscription;
    public static Subscription_Line__c subscriptionLineItem;
    public static Subscription_Site__c subSite;
    public static Contact NewContact;
    
    private static string RandomString{
        get{
            return string.valueof(math.random()).substring(1,10);
        }
    }
    
    static testMethod void TestInCoProvisional() {
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2  tranProd = new Product2 (name = 'Tran Fee InCompanyC',Maximum_Discount__c=100, Discount_Permitted__c=true );
        insert tranProd;
        
        Product2  cancProd = new Product2 (name = 'Cancellation Fee InCompanyC',Maximum_Discount__c=100, Discount_Permitted__c=true);
        insert cancProd;
        
        Product2  testProd = new Product2 (name = 'InCompanyC Test', Cancellation_Fee_Product__c=cancProd.id, Transfer_Fee_Product__c= tranProd.id);
        insert testProd;
        
        
        Pricebook2 pbe2Test = new Pricebook2(name =  'InCompanyC Test');
        insert pbe2Test;
        
        Pricebook2 pbe2Tran = new Pricebook2(name =  'Tran Fee InCompanyC');
        insert pbe2Tran;
        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = testProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        PricebookEntry pbeTest = new PricebookEntry(Product2Id = testProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTest;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = cancProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice1;
        PricebookEntry pbeCanc = new PricebookEntry(Product2Id = cancProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeCanc;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id=tranProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice2;
        PricebookEntry pbeTran = new PricebookEntry(Product2Id = tranProd.Id, Pricebook2Id = pbe2Tran.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTran; 
        
        RecordType rType = [select id from RecordType where name = 'In-Company Event' and sObjectType = 'Opportunity'];
        
        id Dimension1Id = [select id from c2g__codaDimension1__c where name = '110 - Finance' limit 1].id;
        id Dimension2Id = [select id from c2g__codaDimension2__c where name = '0000 - General' limit 1].id;
        id glaid = [select id from c2g__codaGeneralLedgerAccount__c where name = '3000 - Income - Sales Activities' Limit 1].Id;
        
        /* CREATE ACCOUNT*/
        account = new Account(
            name = 'tnc '+ RandomString); 
        insert account;
        
        /* CREATE ACCOUNT*/
        NewContact= new Contact(
            LastName='tnc ' +RandomString , 
            Email='testy13213@fffp.com'+RandomString, 
            FirstName = 'tnc'+RandomString, 
            Salutation = 'Mr',
            AccountId = account.id
        );
        insert NewContact;
        
        /* CREATE OPPORTUNITY*/
        opportunity = new Opportunity(
            Name = 'tncopp '+RandomString,
            AccountId = account.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today(), 
            Pricebook2Id = pbe2Test.Id,
            RecordTypeId = rType.Id);
        insert opportunity;
        
        /* CREATE OPP LINE ITEMS*/
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbeTest.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert OppLineItem;
        
        specialEvent1 = new Special_Event__c(
            Opportunity__c = opportunity.Id,
            Name = 'tnc1 '+ RandomString,
            Product__c = testProd.Id,
            Type__c = 'In-Company Training',
            Status__c = 'Allocating',
            Stage__c = 'Provisional',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        insert specialEvent1;
        
        /* CREATE BSC EVENT BOOKING*/
        Special_Event_Booking__c specialEventbooking2 = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  10000,
            Special_Event__c = specialEvent1.Id,
            Type__c = 'Public',
            OPL_ID__c = OppLineItem.Id,
            status__c = 'Provisional'
        );
        insert specialEventbooking2;
        
        PageReference ref = new PageReference('/apex/tncInCompanyCancellation?id='+ opportunity.id +'&Object=Opportunity');
        Test.setCurrentPage(ref); 
        tncInCompanyCancellationController con = new tncInCompanyCancellationController();
        
        system.assert (con.eventsListing.size() > 0);
        system.debug(con.hasNext);
        system.debug(con.hasPrevious);
        if (con.hasNext)
            con.next();
        if (con.hasPrevious)
            con.previous();
        
        
        con.showCancellationFeeSection(); 
        
        datetime dated = system.Date.today();
        for (tncEventsWrapper wrapper : con.eventsListing){
            wrapper.isSelected = true;
            wrapper.reasonData.cancellationRequestedOn = (dated +1).format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Client postponed decision';
            wrapper.reasonData.reasonNote = '';
            
        }
        
        con.AutoSelectAllRecords();
        
        for (tncEventsWrapper wrapper : con.eventsListing){
            if (wrapper.isSelected){
                wrapper.reasonData.cancellationRequestedOn = (dated +1).format('dd/MM/yyyy');
                wrapper.reasonData.reason = 'Select Reason';
                wrapper.reasonData.reasonNote = '';
            }
        }
        con.showCancellationFeeSection(); 
        
        for (tncEventsWrapper wrapper : con.eventsListing){
            if (wrapper.isSelected){
                wrapper.reasonData.cancellationRequestedOn = (dated + 1).format('dd/MM/yyyy');
                wrapper.reasonData.reason = 'Adverse weather or safety risk';
                wrapper.reasonData.reasonNote = '';
            }
        }
        con.showCancellationFeeSection(); 
        
        for (tncEventsWrapper wrapper : con.eventsListing){
            if (wrapper.isSelected){
                wrapper.reasonData.cancellationRequestedOn = dated.format('dd/MM/yyyy');
                wrapper.reasonData.reason = 'Client no longer interested';
                wrapper.reasonData.reasonNote = 'Test';
            }
        }
        system.debug('con.eventsListing'+ con.eventsListing);
        con.showCancellationFeeSection(); 
        con.showEventsToSelect();
        con.processCancellation();
        con.cancel();
    }
    
    static testMethod void TestInCoConfirmed() {
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2  tranProd = new Product2 (name = 'Tran Fee InCompanyC' );
        insert tranProd;
        
        Product2  cancProd = new Product2 (name = 'Cancellation Fee InCompanyC');
        insert cancProd;
        
        Product2  testProd = new Product2 (name = 'InCompanyC Test', Cancellation_Fee_Product__c=cancProd.id, Transfer_Fee_Product__c= tranProd.id);
        insert testProd;
        
        
        Pricebook2 pbe2Test = new Pricebook2(name =  'InCompanyC Test');
        insert pbe2Test;
        
        Pricebook2 pbe2Tran = new Pricebook2(name =  'Tran Fee InCompanyC');
        insert pbe2Tran;
        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = testProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        PricebookEntry pbeTest = new PricebookEntry(Product2Id = testProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTest;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = cancProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice1;
        PricebookEntry pbeCanc = new PricebookEntry(Product2Id = cancProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeCanc;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id=tranProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice2;
        PricebookEntry pbeTran = new PricebookEntry(Product2Id = tranProd.Id, Pricebook2Id = pbe2Tran.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTran; 
        
        RecordType rType = [select id from RecordType where name = 'In-Company Event' and sObjectType = 'Opportunity'];
        
        id Dimension1Id = [select id from c2g__codaDimension1__c where name = '110 - Finance' limit 1].id;
        id Dimension2Id = [select id from c2g__codaDimension2__c where name = '0000 - General' limit 1].id;
        id glaid = [select id from c2g__codaGeneralLedgerAccount__c where name = '3000 - Income - Sales Activities' Limit 1].Id;
        
        /* CREATE ACCOUNT*/
        account = new Account(
            name = 'tnc '+ RandomString); 
        insert account;
        
        /* CREATE ACCOUNT*/
        NewContact= new Contact(
            LastName='tnc ' +RandomString , 
            Email='testy13213@fffp.com'+RandomString, 
            FirstName = 'tnc'+RandomString, 
            Salutation = 'Mr',
            AccountId = account.id
        );
        insert NewContact;
        
        /* CREATE OPPORTUNITY*/
        opportunity = new Opportunity(
            Name = 'tncopp '+RandomString,
            AccountId = account.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today(), 
            Pricebook2Id = pbe2Test.Id,
            RecordTypeId = rType.Id);
        insert opportunity;
        
        /* CREATE OPP LINE ITEMS*/
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbeTest.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert OppLineItem;
        
        /* CREATE BSC EVENT*/
        Special_Event__c specialEvent2 = new Special_Event__c(
            Opportunity__c = opportunity.Id,
            Name = 'tnc1 '+ RandomString,
            Product__c = testProd.Id,
            Type__c = 'In-Company Training',
            Status__c = 'Confirmed',
            Stage__c = 'Confirmed',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        insert specialEvent2;
        
        /* CREATE BSC EVENT BOOKING*/
        Special_Event_Booking__c specialEventbooking2 = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  10000,
            Special_Event__c = specialEvent2.Id,
            Type__c = 'Public',
            OPL_ID__c = OppLineItem.Id,
            status__c = 'Confirmed'
        );
        insert specialEventbooking2;
        
        PageReference ref = new PageReference('/apex/tncInCompanyCancellation?id='+ opportunity.id +'&Object=Opportunity');
        Test.setCurrentPage(ref); 
        tncInCompanyCancellationController con = new tncInCompanyCancellationController();
        
        system.assert (con.eventsListing.size() > 0);
        system.debug(con.hasNext);
        system.debug(con.hasPrevious);
        if (con.hasNext)
            con.next();
        if (con.hasPrevious)
            con.previous();
        
        
        con.showCancellationFeeSection(); 
        
        con.AutoSelectAllRecords();
        
        datetime dated = system.Date.today();
        for (tncEventsWrapper wrapper : con.eventsListing){
            wrapper.reasonData.cancellationRequestedOn = (dated).format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Select Reason';
        }
        con.showCancellationFeeSection(); 
        
        for (tncEventsWrapper wrapper : con.eventsListing){
            wrapper.reasonData.cancellationRequestedOn = (dated + 1).format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Adverse weather or safety risk';
            wrapper.reasonData.reasonNote = '';
        }
        con.showCancellationFeeSection(); 
        
        for (tncEventsWrapper wrapper : con.eventsListing){
            wrapper.reasonData.cancellationRequestedOn = dated.format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Client no longer interested';
            wrapper.reasonData.reasonNote = 'Test';
        }
        system.debug('con.eventsListing'+ con.eventsListing);
        con.showCancellationFeeSection(); 
        con.showEventsToSelect();
        con.processCancellation();
        con.cancel();
    }
    
    
    static testMethod void TestInCoConfirmedTransfer() {
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2  tranProd = new Product2 (name = 'Tran Fee InCompanyC' );
        insert tranProd;
        
        Product2  cancProd = new Product2 (name = 'Cancellation Fee InCompanyC');
        insert cancProd;
        
        Product2  testProd = new Product2 (name = 'InCompanyC Test', Cancellation_Fee_Product__c=cancProd.id, Transfer_Fee_Product__c= tranProd.id);
        insert testProd;
        
        
        Pricebook2 pbe2Test = new Pricebook2(name =  'InCompanyC Test');
        insert pbe2Test;
        
        Pricebook2 pbe2Tran = new Pricebook2(name =  'Tran Fee InCompanyC');
        insert pbe2Tran;
        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = testProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        PricebookEntry pbeTest = new PricebookEntry(Product2Id = testProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTest;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = cancProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice1;
        PricebookEntry pbeCanc = new PricebookEntry(Product2Id = cancProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeCanc;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id=tranProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice2;
        PricebookEntry pbeTran = new PricebookEntry(Product2Id = tranProd.Id, Pricebook2Id = pbe2Tran.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTran; 
        
        RecordType rType = [select id from RecordType where name = 'In-Company Event' and sObjectType = 'Opportunity'];
        
        id Dimension1Id = [select id from c2g__codaDimension1__c where name = '110 - Finance' limit 1].id;
        id Dimension2Id = [select id from c2g__codaDimension2__c where name = '0000 - General' limit 1].id;
        id glaid = [select id from c2g__codaGeneralLedgerAccount__c where name = '3000 - Income - Sales Activities' Limit 1].Id;
        
        /* CREATE ACCOUNT*/
        account = new Account(
            name = 'tnc '+ RandomString); 
        insert account;
        
        /* CREATE ACCOUNT*/
        NewContact= new Contact(
            LastName='tnc ' +RandomString , 
            Email='testy13213@fffp.com'+RandomString, 
            FirstName = 'tnc'+RandomString, 
            Salutation = 'Mr',
            AccountId = account.id
        );
        insert NewContact;
        
        /* CREATE OPPORTUNITY*/
        opportunity = new Opportunity(
            Name = 'tncopp '+RandomString,
            AccountId = account.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today(), 
            Pricebook2Id = pbe2Test.Id,
            RecordTypeId = rType.Id);
        insert opportunity;
        
        /* CREATE OPP LINE ITEMS*/
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbeTest.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert OppLineItem;
        
        /* CREATE BSC EVENT*/
        Special_Event__c specialEvent2 = new Special_Event__c(
            Opportunity__c = opportunity.Id,
            Name = 'tnc1 '+ RandomString,
            Product__c = testProd.Id,
            Type__c = 'In-Company Training',
            Status__c = 'Confirmed',
            Stage__c = 'Confirmed',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        insert specialEvent2;
        
        /* CREATE BSC EVENT BOOKING*/
        Special_Event_Booking__c specialEventbooking2 = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  10000,
            Special_Event__c = specialEvent2.Id,
            Type__c = 'Public',
            OPL_ID__c = OppLineItem.Id,
            status__c = 'Confirmed'
        );
        insert specialEventbooking2;
        
        PageReference ref = new PageReference('/apex/tncInCompanyTransfer?oppId='+ opportunity.id +'&Object=Opportunity');
        Test.setCurrentPage(ref); 
        tncInCompanyTransferController con = new tncInCompanyTransferController();
        
        system.assert (con.eventsListing.size() > 0);
        system.debug(con.hasNext);
        system.debug(con.hasPrevious);
        if (con.hasNext)
            con.next();
        if (con.hasPrevious)
            con.previous();
        
        con.showTransferFeeSection(); 
        con.showEventsToSelect(); 
        con.AutoSelectAllRecords();
        
        datetime dated = system.Date.today();
        for (tncEventsWrapper wrapper : con.pager.transferEvents){
            wrapper.reasonData.transferRequestedOn = (dated).format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Select Reason';
        }
        con.showTransferFeeSection(); 
        for (tncEventsWrapper wrapper : con.pager.transferEvents){
            wrapper.reasonData.transferRequestedOn = (dated + 1).format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Adverse weather or safety risk';
            wrapper.reasonData.reasonNote = '';
        }
        con.showTransferFeeSection(); 
        
        for (tncEventsWrapper wrapper : con.pager.transferEvents){
            wrapper.reasonData.transferRequestedOn = dated.format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Client no longer interested';
            wrapper.reasonData.reasonNote = 'Test';
            wrapper.isSelected = true;
        }
        con.showTransferFeeSection(); 
        system.assert (con.selectedEventsListing.size() > 0);
        for (tncEventsWrapper wrapper : con.pager.transferEvents){
            wrapper.transferAction = 'To be Transferred';
        }
        
        con.process();
    }
    
    static testMethod void TestPubEventBookingCancellation() {
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2  tranProd = new Product2 (name = 'Tran Fee pubCanc', Maximum_Discount__c=100, Discount_Permitted__c=true );
        insert tranProd;
        
        Product2  cancProd = new Product2 (name = 'Cancellation Fee pubCanc', Maximum_Discount__c=100, Discount_Permitted__c=true);
        insert cancProd;
        
        Product2  testProd = new Product2 (name = 'pubCanc Test', Cancellation_Fee_Product__c=cancProd.id, Transfer_Fee_Product__c= tranProd.id);
        insert testProd;
        
        
        Pricebook2 pbe2Test = new Pricebook2(name =  'pubCanc Test');
        insert pbe2Test;
        
        Pricebook2 pbe2Tran = new Pricebook2(name =  'Tran Fee pubCanc');
        insert pbe2Tran;
        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = testProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        PricebookEntry pbeTest = new PricebookEntry(Product2Id = testProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTest;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = cancProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice1;
        PricebookEntry pbeCanc = new PricebookEntry(Product2Id = cancProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeCanc;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id=tranProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice2;
        PricebookEntry pbeTran = new PricebookEntry(Product2Id = tranProd.Id, Pricebook2Id = pbe2Tran.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTran; 
        
        RecordType rType = [select id from RecordType where name = 'Public Event' and sObjectType = 'Opportunity'];
        
        id Dimension1Id = [select id from c2g__codaDimension1__c where name = '110 - Finance' limit 1].id;
        id Dimension2Id = [select id from c2g__codaDimension2__c where name = '0000 - General' limit 1].id;
        id glaid = [select id from c2g__codaGeneralLedgerAccount__c where name = '3000 - Income - Sales Activities' Limit 1].Id;
        
        /* CREATE ACCOUNT*/
        account = new Account(
            name = 'tnc '+ RandomString); 
        insert account;
        
        /* CREATE ACCOUNT*/
        NewContact= new Contact(
            LastName='tnc ' +RandomString , 
            Email='testy13213@fffp.com'+RandomString, 
            FirstName = 'tnc'+RandomString, 
            Salutation = 'Mr',
            AccountId = account.id
        );
        insert NewContact;
        
        /* CREATE OPPORTUNITY*/
        opportunity = new Opportunity(
            Name = 'tncopp '+RandomString,
            AccountId = account.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today(), 
            Pricebook2Id = pbe2Test.Id,
            RecordTypeId = rType.Id);
        insert opportunity;
        
        /* CREATE OPP LINE ITEMS*/
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbeTest.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert OppLineItem;
        
        /* CREATE BSC EVENT*/
        Special_Event__c specialEvent2 = new Special_Event__c(
            Name = 'tnc1 '+ RandomString,
            Product__c = testProd.Id,
            Type__c = 'In-Company Training',
            Status__c = 'Resourced',
            Stage__c = 'Provisional',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        insert specialEvent2;
        
        Transfer_Cancellation_Reasons__c tr = [select id from Transfer_Cancellation_Reasons__c limit 1][0];
        
        /* CREATE BSC EVENT BOOKING*/
        Special_Event_Booking__c specialEventbooking2 = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  10000,
            Special_Event__c = specialEvent2.Id,
            Type__c = 'Public',
            OPL_ID__c = OppLineItem.Id,
            status__c = 'Provisional',
            Transfer_Cancellation_Reason__c = tr.id,
            Transfer_Cancellation_Notes__c = 'Test',
            Transfer_Cancellation_Fee__c = 100,
            Customer_Cancellation_Transfer_Date__c = system.today()
        );
        insert specialEventbooking2;
        
        Special_Event_Booking__c specialEventbooking3 = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  1000,
            Special_Event__c = specialEvent2.Id,
            Type__c = 'Public',
            OPL_ID__c = OppLineItem.Id,
            status__c = 'Confirmed'
        );
        insert specialEventbooking3;
        
        PageReference ref = new PageReference('/apex/tncPublicEventCancellation?oppId='+ opportunity.id);
        Test.setCurrentPage(ref); 
        
        tncPublicEventCancellationController con = new tncPublicEventCancellationController();
        con.visibleSection(true,false);
        
        system.assert (con.listBookings.size() > 0);
        system.debug(con.hasNext);
        system.debug(con.hasPrevious);
        
        con.handler.setPageSize = 1;
        if (con.hasNext)
            con.next();
        if (con.hasPrevious)
            con.previous();
        con.handler.setPageSize = 10;
        
        con.checkReason(); 
        con.autoSelectAllRecords();
        
        datetime dated = system.Date.today();
        for (tncPublicEventCancellationWrapper wrapper : con.handler.allBookings){
            wrapper.reasonData.cancellationRequestedOn = (dated).format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Select Reason';
        }
        con.checkReason(); 
        for (tncPublicEventCancellationWrapper wrapper : con.handler.allBookings){
            wrapper.reasonData.cancellationRequestedOn = (dated + 1).format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Adverse weather or safety risk';
            wrapper.reasonData.reasonNote = '';
        }
        con.checkReason(); 
        
        for (tncPublicEventCancellationWrapper wrapper : con.handler.allBookings){
            wrapper.reasonData.cancellationRequestedOn = dated.format('dd/MM/yyyy');
            wrapper.reasonData.reason = 'Client no longer interested';
            wrapper.reasonData.reasonNote = 'Test';
            wrapper.isSelected = true;
        }
        con.checkReason(); 
        con.processCancellation();
    }
    
}