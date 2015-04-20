@isTest(SeeAllData=True)
public class tncPublicEventTest{
    
        
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
    
    static testMethod void TestPubEvtCancellation() {
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2  tranProd = new Product2 (name = 'Tran Fee InPEC' );
        insert tranProd;
        
        Product2  cancProd = new Product2 (name = 'Cancellation Fee InPEC');
        insert cancProd;
        
        Product2  testProd = new Product2 (name = 'InPEC Test', Cancellation_Fee_Product__c=cancProd.id, Transfer_Fee_Product__c= tranProd.id);
        insert testProd;
        
        
        Pricebook2 pbe2Test = new Pricebook2(name =  'InPEC Test');
        insert pbe2Test;
        
        Pricebook2 pbe2Tran = new Pricebook2(name =  'Tran Fee InPEC');
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
            name = 'tnc InPEC'+ RandomString); 
        insert account;
        
        /* CREATE ACCOUNT*/
        NewContact= new Contact(
            LastName='tnc InPEC' +RandomString , 
            Email='tnc@britsafe.org'+RandomString, 
            FirstName = 'tnc'+RandomString, 
            Salutation = 'Mr',
            AccountId = account.id
        );
        insert NewContact;
        
        /* CREATE OPPORTUNITY*/
        opportunity = new Opportunity(
            Name = 'InPEC '+RandomString,
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
            Type__c = 'InPEC Training',
            Status__c = 'Requested',
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
        
        Special_Event_Booking__c specialEventbooking3 = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  10000,
            Special_Event__c = specialEvent1.Id,
            Type__c = 'Public',
            OPL_ID__c = OppLineItem.Id,
            status__c = 'Confirmed'
        );
        insert specialEventbooking3;
        
        string returnValue = tncPublicEventCancellation.cancelPublicEvent(specialEvent1.id);
        system.assertEquals(returnvalue, string.valueOf(specialEvent1.id));
    }
}