/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * @TODO - OpportunityLine tests disabled as need to add code to create product in Online pricebook first
 *
 */
@isTest
private class WebsiteWSTest {
    
    /*
     * UPDATE ORDER STATUS TEST
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *    - 
     *
     * NEGATIVE TESTS:
     *    - 
     */
    
    static testMethod void updateOrderStatusTest() {
        // TO DO: implement unit test
        /*
         * POSSITIVE TESTS
         */
        // Create Account & Contact
        WebsiteWS.wsOutputs accResult = WebsiteWS.addAccountContact('Company_Name', 'Company_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','Membership_Number',null);
        
        // Create Opportunity
        Test.StartTest();
        WebsiteWS.wsOutputs oppResult = WebsiteWS.addOpportunity('Website_order_Id', '012200000001bPrAAI',accResult.contactId,accResult.id,'Shipping_Street','Shipping_City','Shipping_State','Shipping_Postal_Code','Shipping_Country','BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','GBP','Google_Keywords','All_Keywords','Google_Adwords','Google_Referrer','Google_utm_campaign','Google_utm_source','Google_utm_medium','Google_utm_term','Google_utm_content','Purchase_Order_Reference','Order Comments','VAT Registration');
        System.assertEquals(oppResult.errorMessage, 'No Errors');
        System.assert(oppResult.id != null);

        // Create Opportunity Lines
        WebsiteWS.wsOutputs oppLineResult = WebsiteWS.addOpportunityLine(oppResult.id,'GBP',350.00,1,350.00,'01t200000010Wdn',70,20);
        System.assertEquals(oppLineResult.errorMessage, 'No Errors');
        System.assert(oppLineResult.id != null);
        
        WebsiteWS.wsOutputs OrderStatusResult = WebsiteWS.updateOrderStatus('Website_order_Id','Paid','WorldPay Reference');
        // If you get an error on the following line saying "Period Field: You must enter a period that belongs to the current company"
        // this is because the current period is closed and needs to be opened.
        System.assertEquals(OrderStatusResult.errorMessage, 'No Errors');

        /*
         * NEGATIVE TESTS
         */
        WebsiteWS.wsOutputs OrderStatusFailedResult = WebsiteWS.updateOrderStatus('Website_order_Id','Payment Failed','WorldPay Reference');
        System.assertEquals(OrderStatusFailedResult.errorMessage, 'No Errors');
        Test.StopTest();
    }


    static testMethod void findAccountTest() {
        Account acc = new Account();
        
        acc.Name = 'The Company Inc Plc 3668923';
        acc.CurrencyIsoCode = 'GBP';
        acc.Active__c = True;
        acc.Principle_Address_ZIP_Postal_Code__c = 'SW20 999';
        acc.BillingPostalCode = 'SW20 999';
        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'Test Account121 - PD';
        acc2.CurrencyIsoCode = 'GBP';
        acc2.Active__c = True;
        acc2.Principle_Address_ZIP_Postal_Code__c = 'SW20 999';
        acc2.BillingPostalCode = 'SW20 999';
        insert acc2;

        Contact contact = new Contact();
        contact.AccountId = acc2.Id;
        contact.LastName = 'Test';
        contact.FirstName = 'Account121';
        contact.Email = 'test@testaccount121.com';
        insert contact;
        
        Test.StartTest();
        // Find Account that exists based on name & postcode (no spaces)
        Id accId = WebsiteWS.findAccountContact('','SW20 999','The Company Inc Plc 3668923',false,'Firstnametest','surname-test','fakeemail@email121.com',null);
        System.assert(accId != null);

        // Find a PD account/contact for an account that exists and the contact matches correctly
        Id accId1 = WebsiteWS.findAccountContact('','SW20 999','',true,'Test','Account121','test@testaccount121.com',null);
        System.assert(accId1 != null);
        System.assertEquals(acc2.Id, accId1);
        
        // Find a non-existing account based on random info
        Id accId2 = WebsiteWS.findAccountContact('','adasdasdsa33338923','cmsm2211',false,'Firstnametest','surname-test','fakeemail@email121.com',null);
        System.assert(accId2 == null);

        // Find a non-existing account based on blank info
        Id accId3 = WebsiteWS.findAccountContact(null,null,null,false,'Firstnametest','surname-test','fakeemail@email121.com',null);
        System.assert(accId3 == null);

        Test.StopTest();
        
    }
    
    /*
     * ADD ACCOUNT CONTACT TESTS
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *      1. Find matching account based on postcode and company name (spacing in postcode)
     *      2. Insert of a company account and contact (matching account can't be found)
     *      3. Find matching account based on Membership number
     *      4. Find matching account based on postcode and company name (no spacing in postcode)
     *      5. Insert a PD account
     *
     * NEGATIVE TESTS:
     *      1. Incorrectly formatted email address
     */
    static testMethod void addAccountContactTest() {
        // TO DO: implement unit test
        
        /*
         * POSSITIVE TESTS
         */
        // 1. Find matching account based on postcode and company name (spacing in postcode)
/*        WebsiteWS.wsOutputs result1 = WebsiteWS.addAccountContact('Company_Name', 'Company_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','Membership_Number',null);
        System.assertEquals(result1.errorMessage, 'No Errors');
        System.assert(result1.id != null);
                
        // 2. Insert of a company account and contact (matching account can't be found)
        WebsiteWS.wsOutputs result2 = WebsiteWS.addAccountContact('XXXCompany_Name', 'XXXCompany_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','XXXXMembership_Number',null);
        System.assertEquals(result2.errorMessage, 'No Errors');
        System.assert(result2.id != null);
*/        
        /*
         * NEGATIVE TESTS
         */
        
        // 2. Insert of a PD account and contact (matching account can't be found)
        WebsiteWS.wsOutputs result3 = WebsiteWS.addAccountContact('', 'XXXCompany_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','XXXXMembership_Number',null);
        System.assertEquals(result3.errorMessage, 'No Errors');
        System.assert(result3.id != null);
         
    }

    /*
     * ADD OPPORTUNITY TESTS
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *    1. Create opportunity based on Account Details
     *
     * NEGATIVE TESTS:
     *    - 
     */
    static testMethod void addOpportunityTest() {
        // TO DO: implement unit test
        /*
         * POSSIBLE TESTS
         */
        // 1. Create opportunity
        // Create Account & Contact
        WebsiteWS.wsOutputs accResult = WebsiteWS.addAccountContact('Company_Name', 'Company_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','Membership_Number',null);
        System.assertEquals(accResult.errorMessage, 'No Errors');
        System.assert(accResult.id != null);

        // Create Opportunity
        Test.startTest();
        WebsiteWS.wsOutputs oppResult = WebsiteWS.addOpportunity('Website_order_Id', '012200000001bPrAAI',accResult.contactId,accResult.id,'Shipping_Street','Shipping_City','Shipping_State','Shipping_Postal_Code','Shipping_Country','BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','GBP','Google_Keywords','All_Keywords','Google_Adwords','Google_Referrer','Google_utm_campaign','Google_utm_source','Google_utm_medium','Google_utm%20term','Google_utm_content','Purchase_Order_Reference','Order Comments','VAT Number');
        System.assertEquals(oppResult.errorMessage, 'No Errors');
        System.assert(oppResult.id != null);
        Test.stopTest();

        Opportunity testOpp = [SELECT Google_utm_content__c, Google_utm_term__c FROM Opportunity WHERE Id = :oppResult.id];
        System.assertEquals(testOpp.Google_utm_content__c, 'Google_utm_content');
        System.assertEquals(testOpp.Google_utm_term__c,'Google_utm term');
        
        /*
         * NEGATIVE TESTS
         */
    }

    /*
     * ADD OPPORTUNITY LINE TESTS
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *    - 
     *
     * NEGATIVE TESTS:
     *    - 
     */
    static testMethod void addOpportunityLineTest() {
        // TO DO: implement unit test
        /*
         * POSSITIVE TESTS
         */
        // Create Account & Contact
        WebsiteWS.wsOutputs accResult = WebsiteWS.addAccountContact('xxxCompany_Name', 'Company_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','Membership_Number',null);
        
        // Create Opportunity
        WebsiteWS.wsOutputs oppResult = WebsiteWS.addOpportunity('Website_order_Id', '012200000001bPrAAI',accResult.contactId,accResult.id,'Shipping_Street','Shipping_City','Shipping_State','Shipping_Postal_Code','Shipping_Country','BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','GBP','Google_Keywords','All_Keywords','Google_Adwords','Google_Referrer','Google_utm_campaign','Google_utm_source','Google_utm_medium','Google_utm_term','Google_utm_content','Purchase_Order_Reference','Order Comments','VAT Number');
        System.assertEquals(oppResult.errorMessage, 'No Errors');
        System.assert(oppResult.id != null);

        // Create Opportunity Lines
        WebsiteWS.wsOutputs oppLineResult = WebsiteWS.addOpportunityLine(oppResult.id,'GBP',100.00,2,200.00,'01t200000010WeR',240,20);
        //System.assertEquals(oppLineResult.success, true);
        //System.assert(oppLineResult.id != null);

        WebsiteWS.wsOutputs oppLine2Result = WebsiteWS.addOpportunityLine(oppResult.id,'GBP',100.00,2,200.00,'01t200000010WeR',240,20);
        //System.assertEquals(oppLine2Result.success, true);
        //System.assert(oppLine2Result.id != null);

        
         
        /*
         * NEGATIVE TESTS
         */
    }

    /*
     * ADD SUBSCRIPTION TESTS
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *    - 
     *
     * NEGATIVE TESTS:
     *    - 
     */
    static testMethod void addSubscriptionTest() {
        // TO DO: implement unit test
        /*
         * POSSITIVE TESTS
         */
        // Create Account & Contact
        WebsiteWS.wsOutputs accResult = WebsiteWS.addAccountContact('Company_Name', 'Company_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','Membership_Number',null);
        
        // Create Opportunity
        WebsiteWS.wsOutputs oppResult = WebsiteWS.addOpportunity('Website_order_Id', '012200000001bPrAAI',accResult.contactId,accResult.id,'Shipping_Street','Shipping_City','Shipping_State','Shipping_Postal_Code','Shipping_Country','BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','GBP','Google_Keywords','All_Keywords','Google_Adwords','Google_Referrer','Google_utm_campaign','Google_utm_source','Google_utm_medium','Google_utm_term','Google_utm_content','Purchase_Order_Reference','Order Comments','VAT Number');
        System.assertEquals(oppResult.errorMessage, 'No Errors');
        System.assert(oppResult.id != null);

        // Create Opportunity Lines
        WebsiteWS.wsOutputs oppLineResult = WebsiteWS.addOpportunityLine(oppResult.id,'GBP',100.00,2,200.00,'01t20000001mCjb',240,20);
        //System.assertEquals(oppLineResult.success, true);
        //System.assert(oppLineResult.id != null);

        WebsiteWS.wsOutputs oppLine2Result = WebsiteWS.addOpportunityLine(oppResult.id,'GBP',100.00,2,200.00,'01t20000001mCjv',240,20);
        //System.assertEquals(oppLine2Result.success, true);
        //System.assert(oppLine2Result.id != null);

        // Create Subscription
        
        WebsiteWS.wsOutputs subResult = WebsiteWS.addSubscription(accResult.id,accResult.contactId,oppResult.id);
        System.assertEquals(subResult.errorMessage, 'No Errors');
        System.assert(subResult.id != null);
        
        /*
         * NEGATIVE TESTS
         */
    }
    /*
     * ADD SUBSCRIPTION SITE TESTS
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *    - 
     *
     * NEGATIVE TESTS:
     *    - 
     */
    static testMethod void addSubscriptionSiteTest() {
        // TO DO: implement unit test
        /*
         * POSSITIVE TESTS
         */
         
        // Create Account & Contact
        WebsiteWS.wsOutputs accResult = WebsiteWS.addAccountContact('Company_Name', 'Company_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','Membership_Number',null);
        
        // Create Opportunity
        WebsiteWS.wsOutputs oppResult = WebsiteWS.addOpportunity('Website_order_Id', '012200000001bPrAAI',accResult.contactId,accResult.id,'Shipping_Street','Shipping_City','Shipping_State','Shipping_Postal_Code','Shipping_Country','BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','GBP','Google_Keywords','All_Keywords','Google_Adwords','Google_Referrer','Google_utm_campaign','Google_utm_source','Google_utm_medium','Google_utm_term','Google_utm_content','Purchase_Order_Reference','Order Comments','VAT Registration');
        System.assertEquals(oppResult.errorMessage, 'No Errors');
        System.assert(oppResult.id != null);

        // Create Opportunity Lines
        WebsiteWS.wsOutputs oppLineResult = WebsiteWS.addOpportunityLine(oppResult.id,'GBP',100.00,22,200.00,'01t20000001mCjb',240,20);
        System.assertEquals(oppLineResult.errorMessage, 'No Errors');
        System.assert(oppLineResult.id != null);

        WebsiteWS.wsOutputs oppLine2Result = WebsiteWS.addOpportunityLine(oppResult.id,'GBP',100.00,2,200.00,'01t20000001mCjv',240,20);
        System.assertEquals(oppLine2Result.errorMessage, 'No Errors');
        System.assert(oppLine2Result.id != null);

        // Create Subscription
        WebsiteWS.wsOutputs subResult = WebsiteWS.addSubscription(accResult.id,accResult.contactId,oppResult.id);
        System.assertEquals(subResult.errorMessage, 'No Errors');
        System.assert(subResult.id != null);

        // Create Subscription Site
        
        List<Id> oppLineIds = new List<Id>();
        
        for (OpportunityLineItem oppLine : [SELECT Id FROM OpportunityLineItem WHERE Id = :oppLineResult.Id OR Id = :oppLine2Result.Id]){
            oppLineIds.add(oppLine.Id);
        }

        Test.startTest();
        WebsiteWS.wsOutputs subSiteResult = WebsiteWS.addSubscriptionSite(subResult.id,accResult.id,accResult.contactId,'Single Site',oppResult.id,oppLineIds);
        System.debug('FJP TESTY: '+subSiteResult);
        
        System.assertEquals(subSiteResult.errorMessage, 'No Errors');
        System.assert(subSiteResult.id != null);
        
        /*
         * NEGATIVE TESTS
         */
    }

    
    /*
     * UPDATE WEBSITE USER ID TEST
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *    - Pass valid information
     *
     * NEGATIVE TESTS:
     *    - Pass invalid contact
     *    - Pass no contact
     *    - Pass no webId
     */
    static testMethod void updateWebsiteUserIdTest() {

        // Create Contact & Account
        WebsiteWS.wsOutputs accResult = WebsiteWS.addAccountContact('Company_Name', 'Company_Phone','Principle_Address_Building','Principle_Address_Street','Principle_Address_Area','Principle_Address_City','Principle_Address_State_Province','Postal_Code','Principle_Address_Country','Principle_Address_Global_Region',True,'Lead_Source','Industry','Industry_Sector',100,'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry','VAT_Reg_Number','Website_User_Id','Salutation','Firstname','Lastname','Title','Email@emailtest35423.com','Phone','Membership_Number',null);

        // NEGATIVE TESTS
        // Invalid contact & userId
        Test.startTest();
        WebsiteWS.wsOutputs resultNoData = WebsiteWS.updateWebsiteUserId('',null);
        System.assert(resultNoData.success == false);

        // No web Id
        WebsiteWS.wsOutputs resultMissingWebId = WebsiteWS.updateWebsiteUserId(null,accResult.contactId);
        System.assert(resultMissingWebId.success == false);
        
        //
        WebsiteWS.wsOutputs resultOkdata = WebsiteWS.updateWebsiteUserId('testWebId',accResult.contactId);
        System.assertEquals(resultOkdata.errorMessage, 'No Errors');
        
        Test.stopTest();
    }

    /*
     * GET ACCOUNT DETAILS TEST
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *    P1: Add private delegate account and contact and get all details back based on whats put in.
     *    P2: Add business account and contact and get all details back based on whats put in.
     *    P3: " + based on 1 site employee
     *    P4: " + based on 500 site employees
     *
     * NEGATIVE TESTS:
     *    N1: Find contact where ID doesn't exist
     *    N2: Find contact where exists but has a negative site employee count.
     */
    static testMethod void getAccountDetailsTest() {

        // P1: Add private delegate account and contact and get all details back based on whats put in.
        Account accPD = new Account();
        accPD.Name = 'Correspondence_Name - PD';
        accPD.CurrencyIsoCode = 'GBP';
        accPD.Active__c = True;
        accPD.BillingPostalCode = 'SW20 999';
        
        RecordType PDAccRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Private_Delegate'][0];
        accPD.RecordTypeId = PDAccRecordType.Id;
        accPD.Phone = '0000';
        accPD.Correspondence_Name__c = 'Correspondence_Name';
        accPD.Principle_Address_Building__c = 'Building';
        accPD.Principle_Address_Street__c = 'Street';
        accPD.Principle_Address_Area__c = 'Area';
        accPD.Principle_Address_City__c = 'City';
        accPD.Principle_Address_State_Province__c = 'State';
        accPD.Principle_Address_ZIP_Postal_Code__c = 'SW20 999';
        accPD.Principle_Address_Country__c = 'United Kingdom';
        accPD.NumberOfEmployees = 100;
        insert accPD;

        Contact PDcontact = new Contact();
        PDcontact.AccountId = accPD.Id;
        PDcontact.LastName = 'Test';
        PDcontact.FirstName = 'Account121';
        PDContact.Salutation = 'Mr';
        PDcontact.Email = 'test@testaccount121.com';
        insert PDcontact;

        WebsiteWS.wsContactOutput P1AccountDetails = WebsiteWS.getAccountDetails(PDcontact.Id);
        System.assertEquals(P1AccountDetails.contactId, PDContact.Id);
        System.assertEquals(P1AccountDetails.accountId, PDContact.AccountId);
        System.assertEquals(P1AccountDetails.username, 'test@testaccount121.com');
        System.assertEquals(P1AccountDetails.email, 'test@testaccount121.com');
        System.assertEquals(P1AccountDetails.title,'Mr');
        System.assertEquals(P1AccountDetails.firstname, 'Account121');
        System.assertEquals(P1AccountDetails.lastname, 'Test');
        System.assertEquals(P1AccountDetails.phoneNumber, '0000');
        System.assertEquals(P1AccountDetails.companyName, '');
        System.assertEquals(P1AccountDetails.numberOfEmployees, '1-499'); // 0, 1-499, 500+
        //System.assertEquals(P1AccountDetails.streetAddress, 'Building, Street, Area,');

        // P2: Add business account and contact and get all details back based on whats put in.
        Account accBusAcc = accPD.clone(false,true,false,false);
        RecordType BusAccRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Account'][0];
        accBusAcc.RecordTypeId = BusAccRecordType.Id;
        accBusAcc.NumberOfEmployees = 500;
        insert accBusAcc; 
        
        Contact BusAccContact = new Contact();
        BusAccContact.AccountId = accBusAcc.Id;
        BusAccContact.Salutation = 'Mr';
        BusAccContact.FirstName = 'Account121';
        BusAccContact.LastName = 'Test';        
        BusAccContact.Email = 'test@testaccount121.com';
        insert BusAccContact;
        
        WebsiteWS.wsContactOutput P2AccountDetails = WebsiteWS.getAccountDetails(BusAccContact.Id);
        
        System.assertEquals(P2AccountDetails.contactId, BusAccContact.Id);
        System.assertEquals(P2AccountDetails.accountId, BusAccContact.AccountId);
        System.assertEquals(P2AccountDetails.username, 'test@testaccount121.com');
        System.assertEquals(P2AccountDetails.email, 'test@testaccount121.com');
        System.assertEquals(P2AccountDetails.title, 'Mr');
        System.assertEquals(P2AccountDetails.lastname, 'Test');
        System.assertEquals(P2AccountDetails.firstname, 'Account121');
        System.assertEquals(P2AccountDetails.phoneNumber, '0000');
        System.assertEquals(P2AccountDetails.companyName, 'Correspondence_Name');
        System.assertEquals(P2AccountDetails.numberOfEmployees, '500+'); // 0, 1-499, 500+
        
        
        
    }

    /*
     * UPDATE ORDER STATUS TEST
     * 
     * Tests all functionality within the API method with positive and negative tests
     *
     * POSITIVE TESTS:
     *    - Find existing correctly setup product
     *
     * NEGATIVE TESTS:
     *    - Find product which can't be found
     *    - 
     */
    static testMethod void productIdOkTest() {

        // Product doesn't exist at all
        WebsiteWS.wsOutputs productIdOkResult = WebsiteWS.productIdOk('a2RD0000000TXvl');
        System.assert(productIdOkResult.success == false);
        
        
    }
    

}