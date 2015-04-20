@isTest(SeeAllData=True)
public class AutoInvoiceCreditTest {
    
    private static string RandomString{
        get{
            return string.valueof(math.random()).substring(1,11);
        }
    }
    
    
    static testMethod void autoInvoiceCreditTest(){

        Account account;
        Opportunity opportunity;
        OpportunityLineItem OppLineItem;
        Special_Event__c specialEvent;
        Special_Event_Booking__c specialEventbooking;
        Product2 product2;
        Subscription__c subscription;
        Subscription_Line__c subscriptionLineItem;
        Subscription_Site__c subSite;
        Contact NewContact;
        Date startDate = System.Today()-366;

        //CREATE ACCOUNT
        account = new Account(
            name = 'testAcount '+RandomString);
        insert account;
        system.debug('Account id : ' + account.id);

        NewContact= new Contact(
            LastName='Test' +RandomString , 
            Email='testy13213@fffp.com'+RandomString, 
            FirstName = 'Test'+RandomString, 
            Salutation = 'Mr',
            AccountId = account.id
        );
        insert NewContact;
        system.debug('NewContact : ' + NewContact);
        
        // CREATE OPPORTUNITY
        opportunity = new Opportunity(
            Name = 'testOpportunity '+RandomString,
            AccountId = account.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today(),
            Do_Not_Auto_Post_SIN_SCR__c = false);
        insert opportunity;
        system.debug('Opportunity id : ' + opportunity.id);

        PricebookEntry pbe = [select id, Product2Id from PricebookEntry where Product2.Name = 'Test Prod'];
        
        // CREATE OPP LINE ITEMS
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity =1,
            UnitPrice = 300);
        insert OppLineItem;
        system.debug('Opp Line Item id : ' + OppLineItem.id);
        
        OpportunityLineItem OppLineItem1 = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity =1,
            UnitPrice = 600);
        insert OppLineItem1;
        system.debug('Opp Line Item id : ' + OppLineItem1.id);
        
        
        // CREATE SUBSCRIPTION
        subscription=new Subscription__c(
            Account_Name__c = account.id,
            Status__c = 'Current - Renewing',
            Contact__c = NewContact.id,
            Start_Date__c = startDate,
            End_Date__c = startDate+364,
            Type__c = 'New',
            Renewal_Opportunity__c = true,
            Renewal_Opportunity_Created__c = false,
            Renewal_Reminders__c = true,
            Opportunity__c = opportunity.Id,
            Longest_Duration_Years__c = 1
        );
        insert subscription;
        
        // CREATE SUBSCRIPTION LINE
        subscriptionLineItem = new Subscription_Line__c(
            Subscription__c = subscription.Id,
            Quantity__c = 1,
            Quantity_Available__c = 0,
            Product_Sales_Price__c = 300,
            Renewal_Price__c = 0,
            opl_id__c = string.valueof(OppLineItem.id),
            Product__c =  pbe.Product2Id);
        insert subscriptionLineItem;
        
        // CREATE SUBSCRIPTION SITE
        subSite = new Subscription_Site__c(
            Subscription__c = subscription.id,
            No_Magazine_Mailing__c = False,
            Site_Account__c = account.Id,
            Site_Contact__c = NewContact.Id,
            Site_Start_Date__c = startDate,
            Type__c = 'Single Site',
            Active__c = True
        );
        insert subSite;
        
        // CREATE BSC EVENT
        specialEvent = new Special_Event__c(
            Opportunity__c = opportunity.Id,
            Name = 'Test Event x'+ RandomString,
            Product__c = pbe.Product2Id,
            Type__c = 'In-Company Training',
            Status__c = 'Anything but Confirmed',
            Stage__c = 'Anything but Provisional',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        
        insert specialEvent;
        system.debug('Special Event id : ' + specialEvent.id);
        
        // CREATE BSC EVENT BOOKING
        specialEventbooking = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  0 ,
            Special_Event__c = specialEvent.Id,
            Override_Booking_Fee__c = false,
            opl_id__c = string.valueof(OppLineItem.id),
            Type__c = 'Public');
        insert specialEventbooking;
        system.debug('Special Event Booking id : ' + specialEventbooking.id);
        
        specialEvent.Status__c = 'Confirmed';
        specialEvent.Stage__c = 'Confirmed';
        update specialEvent; 
        
        specialEventbooking.status__c = 'Confirmed';
        update specialEventbooking;
        
        opportunity.stageName = 'Booking Received';
        opportunity.Finance_to_Invoice_Opp__c = true;
        update opportunity;

        test.startTest();
        database.executeBatch(new AutoInvoiceBatch(opportunity.Id, 'British Safety Council')); 
        list<id> oppList = new list<id>();
        oppList.add(opportunity.Id);
        list<Id> invs = AutoInvoiceHelper.bulkCreateInvoiceFromOpps(oppList, AutoInvoiceSettings.autoPostInvoices, 'British Safety Council');

        
        Opportunity oop = [select id from opportunity where id = :opportunity.Id][0];
        oop.Credit_Note_Reason__c = 'Cancelled';
        oop.Credit_Note_Product_Group__c = 'Audit and Advisory';
        oop.Product_Delivered__c = 'NO POD';
        oop.Finance_to_Invoice_Opp__c = false;
        oop.Finance_to_Credit_Opp__c = true;
        update oop;

        database.executeBatch(new AutoCreditBatch(oop.Id, 'British Safety Council'));
        
        database.executeBatch(new AutoInvCreditMatchBatch('British Safety Council'));
        
        AutoInvoiceHelper.setCWExecutionTime();

        test.stopTest();
    }

     static testMethod void autoInvoiceBatchTest(){
        Account account;
        Opportunity opportunity;
        OpportunityLineItem OppLineItem;
        Special_Event__c specialEvent;
        Special_Event_Booking__c specialEventbooking;
        Product2 product2;
        Subscription__c subscription;
        Subscription_Line__c subscriptionLineItem;
        Subscription_Site__c subSite;
        Contact NewContact;
        Date startDate = System.Today()-366;
        
        test.startTest();
        
        //CREATE ACCOUNT
        account = new Account(
            name = 'testAcount '+RandomString);
        insert account;
        system.debug('Account id : ' + account.id);
        
        NewContact= new Contact(
            LastName='Test' +RandomString , 
            Email='testy13213@fffp.com'+RandomString, 
            FirstName = 'Test'+RandomString, 
            Salutation = 'Mr',
            AccountId = account.id
        );
        insert NewContact;
        
        // CREATE OPPORTUNITY
        opportunity = new Opportunity(
            Name = 'testOpportunity '+RandomString,
            AccountId = account.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today(),
            Do_Not_Auto_Post_SIN_SCR__c = false);
        insert opportunity;
        system.debug('Opportunity id : ' + opportunity.id);
        
        PricebookEntry pbe = [select id, Product2Id from PricebookEntry where Product2.Name = 'Test Prod'];
        
        // CREATE OPP LINE ITEMS
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity =1,
            UnitPrice = 300);
        insert OppLineItem;
        system.debug('Opp Line Item id : ' + OppLineItem.id);
        
        OpportunityLineItem OppLineItem1 = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity =1,
            UnitPrice = 600);
        insert OppLineItem1;
        system.debug('Opp Line Item id : ' + OppLineItem1.id);
        
        // CREATE BSC EVENT
        specialEvent = new Special_Event__c(
            Opportunity__c = opportunity.Id,
            Name = 'Test Event x'+ RandomString,
            Product__c = pbe.Product2Id,
            Type__c = 'In-Company Training',
            Status__c = 'Anything but Confirmed',
            Stage__c = 'Anything but Provisional',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        
        insert specialEvent;
        system.debug('Special Event id : ' + specialEvent.id);
        
        // CREATE BSC EVENT BOOKING
        specialEventbooking = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  0 ,
            Special_Event__c = specialEvent.Id,
            Override_Booking_Fee__c = false,
            opl_id__c = string.valueof(OppLineItem.id),
            Type__c = 'Public');
        insert specialEventbooking;
        system.debug('Special Event Booking id : ' + specialEventbooking.id);
        
        specialEvent.Status__c = 'Confirmed';
        specialEvent.Stage__c = 'Confirmed';
        update specialEvent; 
        
        specialEventbooking.status__c = 'Confirmed';
        update specialEventbooking;
        
        opportunity.stageName = 'Booking Received';
        opportunity.Finance_to_Invoice_Opp__c = true;
        update opportunity;
        
        database.executeBatch(new AutoInvoiceBatch(opportunity.Id, 'British Safety Council')); 
        test.stopTest();
     }

}