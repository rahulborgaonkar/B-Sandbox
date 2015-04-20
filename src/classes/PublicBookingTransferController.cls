/*
    Test Coverage - 86%     06-10-10
    Created by Ben Mansfield 4 August 2010
    Modified by Ben Mansfield 6 August 2010
    
    Description:
    
    Changes:
    
        6 August 2010:
        * Changed way products are added to transfer fee opp - now takes pricebook into account
    
*/
public with sharing class PublicBookingTransferController
{   
    private static final String ERROR_NO_TRANSFER_SCHEDULED = 'Unable to transfer booking. Please make sure you have initiated a transfer ' +
        'by clicking on the \'Public Transfer\' button and following the wizard.';
    private static final String ERROR_NO_ORIG_OPPORTUNITY = 'Cannot find original Opportunity for this booking.';
    private static final String ERROR_NO_ORIG_PRODUCT = 'Cannot find original Product for this booking.';
    private static final String ERROR_NO_TRANSFER_FEE_FOUND = 'Cannot find \'Transfer Fees (Public)\' product. ' +
        'Please make sure this product is in the system and has been assigned to the correct pricebooks.';
        
        
        
    public Special_Event_Booking__c record              { get; set; }
    public Boolean transferSuccess                      { get; set; }
    
    public PublicBookingTransferController()
    {
        record = getEventBooking(ApexPages.CurrentPage().getParameters().get('id'));
        transferSuccess = false;
    }
    
    private Special_Event_Booking__c getEventBooking(Id id)
    {
        List<Special_Event_Booking__c> bookingQuery = [
            SELECT
                Id,
                Name,
                Special_Event__r.Product__c,
                Special_Event__r.RecordTypeId,
                Contact__c,
                Company__c,
                Type__c,
                Transfer_To__c,
                Customer_Requested_Transfer__c,
                Booking_Fee__c,
                Opportunity__c,
                OPL_ID__c,
                Event_Start_Date__c
            FROM
                Special_Event_Booking__c
            WHERE
                Id = :id];
                
        if (bookingQuery.size() == 1)
            return bookingQuery.get(0);
        
        return null;
    }
    
    public PageReference doTransfer()
    {
        System.savePoint sp = Database.setSavepoint();
        
        if (record.Transfer_To__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ERROR_NO_TRANSFER_SCHEDULED));
            return null;
        }
        
        // Get the old opportunity
        List<Opportunity> opps = [
            SELECT
                Id,
                Name,
                OwnerId,
                AccountId,
                Pricebook2Id
            FROM
                Opportunity
            WHERE
                Id = :record.Opportunity__c];
        if (opps.size() != 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ERROR_NO_ORIG_OPPORTUNITY));
            return null;
        }
        Opportunity oldOpp = opps.get(0);
        
        List<RecordType> recordTypes = [
            SELECT
                Id
            FROM
                RecordType
            WHERE
                SObjectType = 'Opportunity'
            AND
                Name = 'Public Event'];
        
        // Create a new opportunity
        Opportunity newOpp = new Opportunity(
            AccountId = oldOpp.AccountId,
            OwnerId = oldOpp.OwnerId,
            Name = oldOpp.Name + ' (' + record.name + ') - Transfer Fee',
            // brm - 6 August 2010 - add pricebook id to new opp
            Pricebook2Id = oldOpp.Pricebook2Id,
            RecordTypeId = (recordTypes.size() == 1 ? recordTypes.get(0).Id : null),
            Type = 'Public Course',
            CloseDate = System.today(),
            StageName = 'Quote/Proposal',
            Rollover_Opportunity__c = true,
            Date_to_be_Invoiced__c = Date.today(),
            Expected_Delivery_Date__c = Date.today(),
            Original_Opportunity__c = oldOpp.Id
            );

        insert newOpp;

        // START: Add old contact roles to new opportunity
        List<OpportunityContactRole> oppConts = new List<OpportunityContactRole>([SELECT ContactId, 
        																				isPrimary,
        																				Role
        																				FROM
        																					OpportunityContactRole
        																				WHERE
            																				isDeleted = False
	        																				AND OpportunityId = :oldOpp.Id]);
        List<OpportunityContactRole> newOppConts = new List<OpportunityContactRole>();
        
        for(OpportunityContactRole oppCont : oppConts){
        	OpportunityContactRole newOCR = new OpportunityContactRole(
        		ContactId = oppCont.ContactId,
        		OpportunityId = newOpp.Id,
	        	isPrimary = oppCont.isPrimary,
	        	Role = oppCont.Role);
        	newOppConts.add(newOCR);
        }
        if (newOppConts.size() > 0){
            insert newoppConts;
        }
        // END: Add old contact roles to new opportunity

        // Get public transfer fee product - brm - 6 August 2010 - now takes into account the pricebook
        Map<String, PricebookEntry> entries = BookingHelper.getPricebookEntries(newOpp.Pricebook2Id, new String[] { 'Transfer Fees (Public)' } );
        
        // Create a new line item for the new opp
        OpportunityLineItem oli = null;
        if (entries.containsKey('Transfer Fees (Public)'))
        {
            oli = new OpportunityLineItem(
                PricebookEntryId = entries.get('Transfer Fees (Public)').Id,
                OpportunityId = newOpp.Id,
                Quantity = 1,
                UnitPrice = 0,
                T_C_Price__c = 0);
        }
        else
        {
            // brm - 6 August 2010 - if we can't find product, rollback database and add error
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ERROR_NO_TRANSFER_FEE_FOUND));
            return null;
        }
        
        Double transferCost = 0;
        if (record.Customer_Requested_Transfer__c)
        {
            // Get currently booked product
            List<Product2> products = [
                SELECT
                    Id,
                    Transfer_Charge_Day_1__c,
                    Transfer_Charge_Day_2__c,
                    Transfer_Charge_Day_3__c,
                    Transfer_Charge_Fee_1__c,
                    Transfer_Charge_Fee_2__c,
                    Transfer_Charge_Fee_3__c,
                    Transfer_Charge_Fee_Final__c
                FROM
                    Product2
                WHERE
                    Id = :record.Special_Event__r.Product__c];
            if (products.size() != 1)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ERROR_NO_ORIG_PRODUCT));
                return null;
            }
            
            // Calculate transfer fees
            transferCost = BookingHelper.calculateTransferCost(record, products.get(0));
            
            // Set a transfer fee on opportunity product
            if (oli != null)
            {
                oli.UnitPrice = transferCost;
                oli.T_C_Price__c = transferCost;
            }
        }
        if (oli != null)
            insert oli;
        
        // Create a new BSC Event booking
        Special_Event_Booking__c newBooking = new Special_Event_Booking__c(
            Opportunity__c = oldOpp.Id,
            Special_Event__c = record.Transfer_To__c,
            Status__c = 'Confirmed',
            Contact__c = record.Contact__c,
            Company__c = record.Company__c,
            Transferred_From__c = record.Id,
            Type__c = record.Type__c,
            OPL_ID__c = record.OPL_ID__c,
            Booking_Fee__c = record.Booking_Fee__c);
        insert newBooking;
        
        // Modify existing event booking
        record.Status__c = 'Transferred';
        record.Opportunity__c = newOpp.Id;
        record.Transferred_To__c = newBooking.Id;
        record.Booking_Fee__c = transferCost;
        record.Transfer_Cancellation_Date__c = System.today();
        // brm - 4 August 2010 - Reset transfer to field
        //booking.Transfer_To__c = null;
        update record;
        transferSuccess = true;
        return new PageReference('/' + newOpp.Id);
    }
    
    @IsTest
    private static void test()
    {
    	string random = string.valueof(math.random()).substring(1,10);
    	
        Opportunity opp = new Opportunity(
            Name = 'Test Opp' + random,
            StageName = 'Closed Won',
            CloseDate = System.today());
        insert opp;
        
        Product2 prod = new Product2(
            Name = 'Test Event Product' + random,
            Allows_Provisional_Bookings__c = true,
            Transfer_Charge_Day_1__c = 10,
            Transfer_Charge_Day_2__c = 5,
            Transfer_Charge_Day_3__c = 2,
            Transfer_Charge_Fee_1__c = 120,
            Transfer_Charge_Fee_2__c = 60,
            Transfer_Charge_Fee_3__c = 40,
            Maximum_Attendees__c = 100,
            Transfer_Charge_Fee_Final__c = 10);
        insert prod;
        
        Special_Event__c event = new Special_Event__c(
            Product__c = prod.Id,
            Name = 'hello test'  + random,
            City__c = 'London',
            StartDate__c = System.today().addDays(3),
            Maximum_Places__c = 1000);
            
        insert event;
        
        Special_Event__c transferToEvent = new Special_Event__c(
            Product__c = prod.Id,
            Name = 'hello test2' + random,
            City__c = 'Birmingham',
            StartDate__c = System.today().addDays(3),
            Maximum_Places__c = 1000
            );
            
        insert transferToEvent;
        
        Special_Event_Booking__c eventBooking = new Special_Event_Booking__c(
            Opportunity__c = opp.Id,
            Special_Event__c = event.Id,
            Transfer_To__c = transferToEvent.Id,
            Customer_Requested_Transfer__c = true);
        insert eventBooking;
        
        PageReference pagRef = new PageReference('/apex/test');
        pagRef.getParameters().put('id', eventBooking.Id);
        Test.setCurrentPage(pagRef);
        //ApexPages.Standardcontroller stdContr = new ApexPages.Standardcontroller(eventBooking);
        PublicBookingTransferController controller = new PublicBookingTransferController();
        
        controller.doTransfer();
    }
}