@istest(SeeAllData=True)
public class EventBeforeDeleteTest
{
    
    private static string RandomString{
        get{
            return string.valueof(math.random()).substring(1,10);
        }
    }

    private static testmethod void testTrigger()
    {
        Account account;
        Opportunity opportunity;
        OpportunityLineItem OppLineItem;
        Special_Event__c specialEvent;
        Special_Event_Booking__c specialEventbooking;
        Product2 product2;

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
        
        // CREATE OPPORTUNITY
        opportunity = new Opportunity(
            Name = 'testOpportunity '+RandomString,
            AccountId = account.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today());
        insert opportunity;
        system.debug('Opportunity id : ' + opportunity.id);
        
        id Dimension1Id = [select id from c2g__codaDimension1__c where name = '110 - Finance' limit 1].id;
        id Dimension2Id = [select id from c2g__codaDimension2__c where name = '0000 - General' limit 1].id;
        id glaid = [select id from c2g__codaGeneralLedgerAccount__c where name = '3000 - Income - Sales Activities' Limit 1].Id;
        
        // CREATE PRODUCT2
        product2 = new Product2(
            Name = 'Test Event Product' + RandomString,
            Allows_Provisional_Bookings__c = true,
            c2g__CODASalesRevenueAccount__c = glaid,
            Dimension_1__c = Dimension1Id,
            Dimension_2__c = Dimension2Id,
            Auto_Post_Invoice__c=true);
        insert product2;
       
        // GET STANDARD PRICEBOOK
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
            Duration__c = '1 Year',
            c2g__CODASalesRevenueAccount__c = glaid,
            Dimension_1__c = Dimension1Id,
            Dimension_2__c = Dimension2Id
        );
        insert prod;
        
        
        // CREATE PRICEBOOK
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product2.Id,
            UnitPrice = 300,
            Pricebook2Id = stdPricebook.Id,
            IsActive = true);
        insert pbe;
        
        // CREATE OPP LINE ITEMS
        OppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity =1,
            UnitPrice = 300);
        insert OppLineItem;
        system.debug('Opp Line Item id : ' + OppLineItem.id);
        
        // CREATE BSC EVENT
        specialEvent = new Special_Event__c(
            Opportunity__c = opportunity.Id,
            Name = 'Test Event x'+ RandomString,
            Product__c = product2.Id,
            Type__c = 'In-Company Training',
            Status__c = 'Cancelled - Error',
            Stage__c = 'Anything but Provisional',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        
        insert specialEvent;
        system.debug('Special Event id : ' + specialEvent.id);
        
                specialEventbooking = new Special_Event_Booking__c(
            Opportunity__c = opportunity.Id,
            Booking_Fee__c =  0 ,
            Special_Event__c = specialEvent.Id,
            Override_Booking_Fee__c = false,
            opl_id__c = string.valueof(OppLineItem.id),
            Type__c = 'Public');
        insert specialEventbooking;
        system.debug('Special Event Booking id : ' + specialEventbooking.id);
        
        
        delete specialEvent ;
        
    }
}