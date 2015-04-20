@istest(SeeAllData=true)
public with sharing class TestHelper {

    /*
    * Steps to create a salesinvoice and salesline item
    * 1. CreateAccount
    * 2. CreateOpportunity
    * 3. CreateOpportunityLineItem
    * 4. CreateSpecialEvent
    * 5. CreateSpecialEventBooking
    */ 

    public static Account account;
    public static Opportunity opportunity;
    public static OpportunityLineItem OppLineItem;
    public static Special_Event__c specialEvent;
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
    
    public static testmethod Special_Event_Booking__c CreateSpecialEventBooking(){
        
        Date startDate = System.Today()-366;

        
        /* CREATE ACCOUNT*/
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

        /* CREATE OPPORTUNITY*/
        opportunity = new Opportunity(
            Name = 'testOpportunity '+RandomString,
            AccountId = account.Id,
            StageName = 'Qualifying',
            Product_Delivered__c =  'Fully delivered',
            CloseDate = Date.today());
        insert opportunity;
        
        id Dimension1Id = [select id from c2g__codaDimension1__c where name = '110 - Finance' limit 1].id;
        id Dimension2Id = [select id from c2g__codaDimension2__c where name = '0000 - General' limit 1].id;
        id glaid = [select id from c2g__codaGeneralLedgerAccount__c where name = '3000 - Income - Sales Activities' Limit 1].Id;
        /* CREATE PRODUCT2*/
         product2 = new Product2(
            Name = 'Test Event Product' + RandomString,
            Allows_Provisional_Bookings__c = true,
            c2g__CODASalesRevenueAccount__c = glaid,
            Dimension_1__c = Dimension1Id,
            Dimension_2__c = Dimension2Id,
            Auto_Post_Invoice__c=true);
        insert product2;
        
        /* GET STANDARD PRICEBOOK*/
        Pricebook2 stdPricebook = [
            SELECT
                Id
            FROM
                Pricebook2
            WHERE
                IsStandard = true and name = 'Standard Price Book' Limit 1];
        
        
       // Core Product
        Product2 prod = new Product2(
            Name = 'Product Test' + RandomString, 
            Initial_Reminder_Days__c = 1,
            Core_Subscription_Product__c = True,
            Subscription_Product__c = True,
            Membership__c = True,
            Duration__c = '1 Year'
        );
        insert prod;
        
        
        /* CREATE PRICEBOOK*/
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product2.Id,
            UnitPrice = 300,
            Pricebook2Id = stdPricebook.Id,
            IsActive = true);
        insert pbe;
        
        /* CREATE OPP LINE ITEMS*/
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert OppLineItem;
        system.debug('Opp Line Item id : ' + OppLineItem.id);
        
        /*CREATE SUBSCRIPTION*/
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
        
        /* CREATE SUBSCRIPTION LINE*/
        subscriptionLineItem = new Subscription_Line__c(
            Subscription__c = subscription.Id,
            Quantity__c = 1,
            Quantity_Available__c = 0,
            Product_Sales_Price__c = 100,
            Renewal_Price__c = 100,
            Product__c =  prod.id);
        insert subscriptionLineItem;
        
        /* CREATE SUBSCRIPTION SITE*/
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
                
        /* CREATE BSC EVENT*/
        specialEvent = new Special_Event__c(
                Opportunity__c = opportunity.Id,
                Name = 'Test Event x'+ RandomString,
                Product__c = product2.Id,
                Type__c = 'In-Company Training',
                Status__c = 'Anything but Confirmed',
                Stage__c = 'Anything but Provisional',
                StartDate__c = Date.today(),
                EndDate__c = Date.today().addDays(5));
                
        insert specialEvent;
        system.debug('Special Event id : ' + specialEvent.id);
    
        /* CREATE BSC EVENT BOOKING*/
        specialEventbooking = new Special_Event_Booking__c(
                Opportunity__c = opportunity.Id,
                Booking_Fee__c =  10000 ,
                Special_Event__c = specialEvent.Id,
                Override_Booking_Fee__c = false,
                Type__c = 'Public');
        insert specialEventbooking;
        system.debug('Special Event Booking id : ' + specialEventbooking.id);
        
        FinanceHelper.createInvoiceFromOpp(opportunity.id,true);
        
        system.debug('vs -------------------------------');
        list<id> invoices = new list<id>();
        for (c2g__codaInvoice__c invoice :[select id from c2g__codaInvoice__c where c2g__Opportunity__c =:opportunity.id]){
                invoices.add(invoice.id);
        }

        list<id> ids = FinanceHelper.createCreditNotes(invoices,true);
        system.debug('vs' + ids);
        system.debug('vs -------------------------------end');
        return specialEventbooking;     
    }
                    
}