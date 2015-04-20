@isTest(SeeAllData = true)
public class addBookingExtensionTest {
    
    public static Account acc;
    public static Opportunity opp;
    public static OpportunityLineItem OppLineItem;
    public static Special_Event__c specialEvent;
    public static Special_Event_Booking__c specialEventbooking;
    public static Contact NewContact;
    
    private static string RandomString{
        get{
            return string.valueof(math.random()).substring(1,10);
        }
    }
    
    static testMethod void TestInCoProvisional() {
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2  testProd = new Product2 (name = 'InCompany Test');
        insert testProd;
        
        Pricebook2 pbe2Test = new Pricebook2(name =  'InCompany Test');
        insert pbe2Test;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = testProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        
        PricebookEntry pbeTest = new PricebookEntry(Product2Id = testProd.Id, Pricebook2Id = pbe2Test.Id, unitPrice = 100, UseStandardPrice = false, IsActive = true);
        insert pbeTest;
        
        RecordType rType = [select id from RecordType where name = 'In-Company Event' and sObjectType = 'Opportunity'];
        
        /* CREATE ACCOUNT*/
        acc = new Account(
            name = 'tnc '+ RandomString); 
        insert acc;
        
        /* CREATE ACCOUNT*/
        NewContact= new Contact(
            LastName='tnc ' +RandomString , 
            Email='testy13213@fffp.com'+RandomString, 
            FirstName = 'tnc'+RandomString, 
            Salutation = 'Mr',
            AccountId = acc.id
        );
        insert NewContact;
        
        /* CREATE OPPORTUNITY*/
        opp = new Opportunity(
            Name = 'tncopp '+RandomString,
            AccountId = acc.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today(), 
            Pricebook2Id = pbe2Test.Id,
            RecordTypeId = rType.Id);
        insert opp;
        
        /* CREATE OPP LINE ITEMS*/
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbeTest.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert OppLineItem;
        
        specialEvent = new Special_Event__c(
            Opportunity__c = opp.Id,
            Name = 'tnc1 '+ RandomString,
            Product__c = testProd.Id,
            Type__c = 'In-Company Training',
            Status__c = 'Allocating',
            Stage__c = 'Provisional',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(0));
        insert specialEvent;
        
        Special_Event_Unit__c evUn = new Special_Event_Unit__c(
            Name = 'TestDAy',
            Special_Event__c = specialEvent.id,
            Unit_Start_Time__c = datetime.newInstance(2014, 9, 9, 9, 0, 0),
            Unit_End_Time__c = datetime.newInstance(2014, 9, 9, 9, 0, 0)
        );
        insert evUn;
        
        /* CREATE BSC EVENT BOOKING*/
        specialEventbooking = new Special_Event_Booking__c(
            Opportunity__c = opp.Id,
            Booking_Fee__c =  10000,
            Special_Event__c = specialEvent.Id,
            Type__c = 'Public',
            OPL_ID__c = OppLineItem.Id,
            status__c = 'Provisional'
        );
        insert specialEventbooking;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        addBookingExtension bkgExt = new addBookingExtension(sc);
        
        PageReference ref = new PageReference('/apex/addBooking?id='+ opportunity.id);
        Test.setCurrentPage(ref); 
        
        for (addBookingExtension.prodEvts p : bkgExt.prodEvt){
            p.newBookings = 6;
            
           for (addBookingExtension.oppBookings o : p.bookings){
                o.selected = true;
            }
        }

        bkgext.eventName = specialEvent.Name;
        bkgext.selectBookingsForEvent();
        
        bkgExt.confirmBookings();
    }
    
}