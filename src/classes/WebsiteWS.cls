/* 
 * Website Web Service
 * 
 * By: Francis Pindar
 * Date: 25/07/2011
 *
 * This was written for the website and eCommerce solution to communicate with Salesforce.
 *
 * The web service methods are:
 *
 * addAccountContact   - Add Account or Contact or link to Account/Contact
 * addOpportunity      - Adds opportunity
 * addOpportunityLine  - Adds opportunity line
 * addSubscription     - Creates subscription
 * addSubscriptionSite - Creates subscription site
 * updateOrderStatus   - Creates invoice if invoice hasn't been created
 * updateWebsiteUserId - Updates a users website id using a contact id.
 * productIdOk         - Checks Salesforce Product ID is ok
 * postInvoice         - Posts the invoice specified
 *
 *
 * TESTING: Make sure you test using the test website after making changes to this.
 * VS05/03/2014  Added: Autoposting of invoices and Cash entries and added code for auto cash matching. 
 
 
 */
global without sharing class WebsiteWS  {

    public class myException extends Exception{}
    
    static Boolean isClassVarsSet = false;
    static String PRICEBOOK_ID = null;
    static Id COMPANY_ACCOUNT_RECORDTYPE;
    static Id PD_ACCOUNT_RECORDTYPE;
    static Id GBP_CURRENCY_ID;
    static Id DEFAULT_CODAINPUTVATCODE_ID;
    static Id DEFAULT_CODAOUTPUTVATCODE_ID;
    static Id TAX_CODE_20_PERCENT;
    static Id TAX_CODE_ZERO_PERCENT;
    static Id ACCOUNTS_RECEIVABLE_ID;
    static Id DEFAULT_CODAACCOUNTSRECEIVABLECONTROL_ID;
    static Id DEFAULT_CODAACCOUNTSPAYABLECONTROL_ID;
     
    // FINAL STATICs
    static final String ACCOUNTING_COMPANY = 'British Safety Council';
    static final String CURRENCY_ISO_CODE = 'GBP';
    static final String DEFAULT_SUBSCRIPTION_STATUS = 'Pending - Not Paid';
    static final String DEFAULT_SUBSCRIPTION_TYPE = 'New';
    static final String OPP_PENDING_STATUS = 'Online - Pending';
    static final String OPP_PAID_STATUS = 'Online - Paid';
    static final String OPP_FAILED_STATUS = 'Online - Payment Failed';
    static final String FF_COMPANY_NAME_CONTEXT = '(British Safety Council)';
    static final String DIMENSION_1_NAME = '505 - Sales - Website';
    static final String DEFAULT_CODATAXCALCULATIONMETHOD_VALUE = 'Gross';
    static final String DEFAULT_CODAVATSTATUS_VALUE = 'Home';
    static final String DEFAULT_CODABASEDATE1_VALUE = 'Invoice Date';
    static final String DEFAULT_CODADESCRIPTION1_VALUE = '30 Days';
    static final Integer DEFAULT_CODADAYSOFFSET1_VALUE = 30;
    static final String DEFAULT_CODABASEDATE2_VALUE = 'Invoice Date';
    static final String DEFAULT_CODADESCRIPTION2_VALUE = '60 Days';
    static final Integer DEFAULT_CODADAYSOFFSET2_VALUE = 60;
    static final String DEFAULT_CODABASEDATE3_VALUE = 'Invoice Date';
    static final String DEFAULT_CODADESCRIPTION3_VALUE = '90 Days';
    static final Integer DEFAULT_CODADAYSOFFSET3_VALUE = 90;
    static final String SUBSCRIPTION_RECORD_TYPE_NAME = 'Subscription';
    static final Boolean POST_CASH_ENTRY = true;
    static final Boolean POST_INVOICE = true;
    
    public static boolean isTest = false;
    
    // A class to send back as an output to the website (PHP)
    global class wsOutputs{
        webservice String errorMessage = 'No Errors';
        webservice Boolean success = true;
        webservice Id id;
        webservice Id contactId;
    }

    global class wsContactOutput{
        webservice Id contactId;
        webservice Id accountId;
        webservice String username;
        webservice String email;
        webservice String title;
        webservice String firstname;
        webservice String lastname;
        webservice String phoneNumber;
        webservice String companyName;
        webservice String numberOfEmployees;
        webservice String streetAddress;
        webservice String city;
        webservice String areaTown;
        webservice String country;
        webservice String zipPostalCode;
    }
    
    /* 
     * CONSTRUCTOR
     *
     * Get the IDs from the database needed in the WebsiteWS class.
     */
    public WebsiteWS() {
        WebsiteWS.isTest = false;

    }
    
    /*
     * SETUP GLOBALS
     *
     * Sets up global values based on developer names etc rather than using IDs (which is bad!)
     */
    private static void setupGlobals(){
        
        // GET PRICEBOOK_ID for online eCommerce online products
        if (PRICEBOOK_ID == null){
            List<Pricebook2> pbList = new List<PriceBook2>([SELECT Id 
                FROM Pricebook2
                WHERE Name = 'Online eCommerce Prices'
                 LIMIT 1
                 ]);
        
        
            if (!pbList.isEmpty())
            {
                PRICEBOOK_ID = pbList[0].Id;
            }
        }
        
        if (!isClassVarsSet){
            // ** RECORD TYPES
            Boolean foundAccRT = false;
            Boolean foundPDRT = false;
            
            for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE DEVELOPERNAME = 'Business_Account' OR DEVELOPERNAME = 'Private_Delegate']){
                if (rt.DeveloperName == 'Business_Account'){
                    COMPANY_ACCOUNT_RECORDTYPE = rt.Id; // In Prod: 012200000001VUEAA2
                    foundAccRT = true;
                }
                if (rt.DeveloperName == 'Private_Delegate'){
                    PD_ACCOUNT_RECORDTYPE = rt.Id; // In Prod: 012D0000000JBKbIAO
                    foundPDRT = true;
                }
                
            }
            
            if (foundAccRT == false || foundPDRT == false){
                // Throw exception
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find \'Business_Acount\' or \'Private_Delegate\' RecordType');
            }           
            // *** FinancialForce Records
            
            // * ACCOUNT CURRENCY OBJECT
            try {
                c2g__codaCompany__c accCcompany = [SELECT Id FROM c2g__codaCompany__c WHERE Name = :ACCOUNTING_COMPANY LIMIT 1][0];
                c2g__codaAccountingCurrency__c aCurr = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE Name = 'GBP' AND c2g__OwnerCompany__c = :accCcompany.Id][0];
                
                GBP_CURRENCY_ID = aCurr.Id; // In Prod: a0gD00000015yiBIAQ
                
            }catch(Exception e){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find Accounting Currency');
            }
            
            
            // * GENERAL LEDGER
            Boolean found1200 = false;
            Boolean found1700 = false;
            
            for (c2g__codaGeneralLedgerAccount__c gAL : [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = '1200' OR c2g__ReportingCode__c = '1700']){
                
                if (gAL.c2g__ReportingCode__c == '1200'){
                    ACCOUNTS_RECEIVABLE_ID = gAL.Id; // In Prod: a1M20000000HDPJEA4
                    System.debug('FJP SETTING VALUE'+ACCOUNTS_RECEIVABLE_ID);
                    DEFAULT_CODAACCOUNTSRECEIVABLECONTROL_ID = gAL.Id; // In Prod: a1M20000000HDPJEA4
                    found1200 = true;
                }
                if (gAL.c2g__ReportingCode__c == '1700'){
                    DEFAULT_CODAACCOUNTSPAYABLECONTROL_ID = gAL.Id; // In Prod: a1M200000008V88EAE
                    found1700 = true;
                }
            }
            
            if (found1200 == false){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find Accounts Receivable Code 1200');
            }
            if (found1700 == false){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find Accounts Receivable Code 1700');
            }
            
            // * TAX CODES
            Boolean foundVIS = false;
            Boolean foundVOS = false;
            Boolean foundVOZERO = false;
            
            for(c2g__codaTaxCode__c taxCode : [SELECT Id, Name FROM c2g__codaTaxCode__c WHERE Name = 'VIS' OR Name = 'VOS' OR Name = 'VOZERO']){
                if (taxCode.Name == 'VIS'){
                    DEFAULT_CODAINPUTVATCODE_ID = taxCode.Id; // In Prod: a2A200000004FRCEA2
                    foundVIS = true;
                }
                if (taxCode.Name == 'VOS'){
                    DEFAULT_CODAOUTPUTVATCODE_ID = taxCode.Id; // In Prod: a2A200000004FRHEA2
                    TAX_CODE_20_PERCENT = taxCode.Id; // In Prod: a2A200000004FRHEA2
                    foundVOS = true;
                }
                if (taxCode.Name == 'VOZERO'){
                    TAX_CODE_ZERO_PERCENT = taxCode.Id; // In Prod: a2A200000004FRREA2
                    foundVOZERO = true;
                }
            }
            if (foundVIS == false){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find Tax Code VIS');
            }
            if (foundVOS == false){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find Tax Code VOS');
            }
            if (foundVOZERO == false){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find Tax Code VOZERO');
            }
            
            isClassVarsSet = true;
        }
    }

    /* 
     * ADD ACCOUNT CONTACT - addAccountContact()
     * 
     * Creates an account & contact or links to an account and created/links to contact.
     *
     * The contactId isn't always populated and shouldn't be used for matching records as duplicates exist in Salesforce
     * It is only used to update the website Id on the contact if the contact doesn't have one yet.
    
    Test:
    
        WebsiteWS.addAccountContact(
        'Company_Name', 
        'Company_Phone',
        'Principle_Address_Building',
        'Principle_Address_Street',
        'Principle_Address_Area',
        'Principle_Address_City',
        'Principle_Address_State_Province',
        'Postal_Code',
        'Principle_Address_Country',
        'Principle_Address_Global_Region',
        True,
        'Lead_Source',
        'Industry',
        'Industry_Sector',
        100,
        'BillingStreet',
        'BillingCity',
        'BillingState',
        'BillingPostalCode',
        'BillingCountry',
        'VAT_Reg_Number',
        'Website_User_Id',
        'Salutation',
        'Firstname',
        'Lastname',
        'Title',
        'Email@myemail.com',
        'Phone',
        'Membership_Number',
        null
        );
     */
    webService static wsOutputs addAccountContact( 
        String Company_Name, 
        String Company_Phone,
        String Principle_Address_Building,
        String Principle_Address_Street,
        String Principle_Address_Area,
        String Principle_Address_City,
        String Principle_Address_State_Province,
        String Principle_Address_ZIP_Postal_Code,
        String Principle_Address_Country,
        String Principle_Address_Global_Region,
        Boolean Email_Opt_Out,
        String Lead_Source,
        String Industry,
        String Industry_Sector,
        Integer NumberOfEmployees,
        String BillingStreet,
        String BillingCity,
        String BillingState,
        String BillingPostalCode,
        String BillingCountry,
        String VAT_Registration_Number,
        String Website_User_Id,
        String Salutation,
        String Firstname,
        String Lastname,
        String Title,
        String Email,
        String Phone,
        String Membership_Number,
        Id ContactId) {
        
        setupGlobals();
        
        // @todo: need to code up if contactId is populated the contact already exists so need
        // to do a search to see if the order they are doing should match another account or create a new one
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs();
        
        Boolean isPDAccount = false;
        if (Company_Name.length() == 0 || Company_Name == null){
            isPDAccount = true;
        }
        // Based on the email and webId coming in update all the contacts in Salesforce which don't have a webId linked
        // and match the email address.
        
        if (Website_User_Id !='' && Email !=''){
            List<Contact> contactEmailList = new List<Contact>([SELECT Id, WebId__c FROM Contact WHERE (Email = :Email AND WebId__c = null) ]);
            if (!contactEmailList.isEmpty()){
                System.debug('Found at least one contact and updating WebId');
                for(Contact ContactItem:contactEmailList)
                {
                    ContactItem.WebId__c = Website_User_Id;
                    update ContactItem;
                }
            }
        }
        // Try and find account
        Id accId = findAccountContact(Membership_Number, Principle_Address_ZIP_Postal_Code, Company_Name, isPDAccount, Firstname, Lastname, Email, ContactId);
        
        
        // If the adding of the contact fails then we need to roll back the database changes so create a save point here
        Savepoint sp = Database.setSavepoint();
        
        if (accId == null){
            System.debug('Creating Account after FindAccountContact failed to find an account');
            // Account couldn't be found so creating one:
            Account acc = new Account();
            if (isPDAccount){
                acc.Name = Firstname+' '+Lastname+' - PD';
            }else{
                acc.Name = Company_Name;
                
            }
            
            acc.CurrencyIsoCode = CURRENCY_ISO_CODE;
            if (Company_Phone == ''){
                acc.Phone = Phone;
            }else{
                acc.Phone = Company_Phone;
            }
            
            acc.Type = 'Customer';
            acc.Active__c = True;
            //acc.Relationship__c = 'Prospect';
            if (isPDAccount){
                // Private Delegate account
                System.debug('Is a PD account');
                acc.RecordTypeId = PD_ACCOUNT_RECORDTYPE;
            }else{
                System.debug('Is a company account');
                // Company Account
                acc.RecordTypeId = COMPANY_ACCOUNT_RECORDTYPE;
            }
            acc.Principle_Address_Building__c = Principle_Address_Building;
            acc.Principle_Address_Street__c = Principle_Address_Street;
            acc.Principle_Address_Area__c = Principle_Address_Area;
            acc.Principle_Address_City__C = Principle_Address_City;
            acc.Principle_Address_State_Province__c = Principle_Address_State_Province;
            acc.Principle_Address_ZIP_Postal_Code__c = Principle_Address_ZIP_Postal_Code;
            acc.Principle_Address_Country__c = Principle_Address_Country;
            acc.Principle_Address_Global_Region__c = Principle_Address_Global_Region;
            acc.Email_Opt_Out__c = Email_Opt_Out;
            acc.Lead_Source__c = Lead_Source;
            acc.Industry = Industry;
            acc.Industry_Sector__c = Industry_Sector;
            acc.NumberOfEmployees = NumberOfEmployees;
            acc.BillingStreet = BillingStreet;
            acc.BillingCity = BillingCity;
            acc.BillingState = BillingState;
            acc.BillingPostalCode = BillingPostalCode;
            acc.BillingCountry = BillingCountry;
            acc.c2g__CODAVATRegistrationNumber__c = VAT_Registration_Number;
            
            // Financial Force Default fields:
            acc.c2g__CODAAccountsReceivableControl__c = ACCOUNTS_RECEIVABLE_ID;
            acc.C2G__CODAINPUTVATCODE__C = DEFAULT_CODAINPUTVATCODE_ID;
            acc.C2G__CODAACCOUNTSRECEIVABLECONTROL__C = DEFAULT_CODAACCOUNTSRECEIVABLECONTROL_ID;
            acc.C2G__CODAACCOUNTSPAYABLECONTROL__C = DEFAULT_CODAACCOUNTSPAYABLECONTROL_ID;
            acc.C2G__CODAOUTPUTVATCODE__C = DEFAULT_CODAOUTPUTVATCODE_ID;
            acc.C2G__CODATAXCALCULATIONMETHOD__C = DEFAULT_CODATAXCALCULATIONMETHOD_VALUE;
            acc.C2G__CODAVATSTATUS__C = DEFAULT_CODAVATSTATUS_VALUE;
            
            acc.C2G__CODABASEDATE1__C = DEFAULT_CODABASEDATE1_VALUE;
            acc.C2G__CODADESCRIPTION1__C = DEFAULT_CODADESCRIPTION1_VALUE;
            acc.c2g__CODADaysOffset1__c = DEFAULT_CODADAYSOFFSET1_VALUE;
            
            acc.C2G__CODABASEDATE2__C = DEFAULT_CODABASEDATE2_VALUE;
            acc.C2G__CODADESCRIPTION2__C = DEFAULT_CODADESCRIPTION2_VALUE;
            acc.c2g__CODADaysOffset2__c = DEFAULT_CODADAYSOFFSET2_VALUE;
            
            acc.C2G__CODABASEDATE3__C = DEFAULT_CODABASEDATE3_VALUE;
            acc.C2G__CODADESCRIPTION3__C = DEFAULT_CODADESCRIPTION3_VALUE;
            acc.c2g__CODADaysOffset3__c = DEFAULT_CODADAYSOFFSET3_VALUE;
            acc.c2g__CODAAccountTradingCurrency__c = 'GBP';
            acc.c2g__CODAInvoiceEmail__c = Email;
            try {
                insert acc;
                
            }catch(Exception e){
                // error occurred populate error object.
                output.errorMessage = 'Create Account Error: '+e.getMessage();
                output.success = false;
            }
            
            output.Id = acc.Id;
            
        }else{
            System.debug('FindAccountContact() Found an account so setting accId to output');
            
            Account modAccount = [select id, c2g__CODAAccountTradingCurrency__c from Account where id = :accId];
            if (modAccount.c2g__CODAAccountTradingCurrency__c == null){
                modAccount.c2g__CODAAccountTradingCurrency__c = 'GBP';
                update modAccount;
            }
            output.id = accId;

        }
        
        // The account Id has been found or created so next to find or create he contact:
        
        if(output.success){
            // Search for contact
            List<Contact> contactList = new List<Contact>([SELECT Id FROM Contact WHERE AccountId = :output.Id AND Email = :Email LIMIT 1]);
    
            if (contactList.isEmpty()){
                System.debug('Unable to find contact on account so creating contact');
                // Contact can't be found so create
                Contact c = new Contact();
                c.WebId__c = Website_User_Id;
                c.Salutation = Salutation;
                c.Firstname = Firstname;
                c.Lastname = Lastname;
                c.Title = Title;
                c.Email = Email;
                c.Phone = Phone;
                c.AccountId = output.id;
                c.Preferred_Comm_Method__c = 'Email';
                c.HasOptedOutOfEmail = Email_Opt_Out;
                c.Active__c = True;
                c.Key_Contact__c = True;
                
                try{
                    insert c;
                                
                }catch(Exception e){
                    // error occurred populate error object.
                    output.errorMessage = 'Create Contact Error: '+e.getMessage();
                    output.success = false;
                }

                output.contactId = c.Id;
                
            }else{
                // Use the id which the contact was found
                output.contactId = contactList[0].Id;
            }
        }
        
        if (!output.success){
            System.debug('Rolled back databsee calls due to error');
            // An error occurred during processing so roll back the database.
                
        }
        System.debug('addAccountContact() Output: '+output);
        return output;
    }


    /* 
     * FIND ACCOUNT - findAccountContact()
     * 
     * System tries to find an account based on membership number and postcode or 
     * postcode and account name.
     
     TESTs:
     Find match on Sub site ref:
     WebsiteWS.findAccountContact('S0336868-ME159BZ','xxx','xxxx');
     
     Find match on account:
     
     Find 
     */
    static public Id findAccountContact(String membershipNumber, String postCode, String AccName, Boolean isPDAccount, String Firstname, String Lastname, String Email, Id ContactId){
        
        setupGlobals();
        
        Id accId;
        String postCodeCleaned;
        String accNamePD = '';
        String strContactId = contactId;
        if (contactId != null && strContactId.length() > 0){
            Contact contact = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId][0];
            accId = contact.AccountId;
        }else{
        
            // If no company name has been entered assume its a private delegate so find based on name and PD
            if (isPDAccount){
                accNamePD = Firstname+' '+Lastname+' - PD';
            }
            
            if (membershipNumber !=null)
            {
                // Find account based on Subscription ref and postcode
                System.debug('Membership entered trying to find membership');
                List<Subscription_Site__c> siteList = new List<Subscription_Site__c>([SELECT Site_Account__c FROM Subscription_Site__c WHERE Subscription_Site_Ref__c = :membershipNumber LIMIT 1]);
            
                if (!siteList.isEmpty())
                {
                    System.debug('Found Membership');
                    accId = siteList[0].Site_Account__c;
                }
            }
            
            if (accId == null)
            {
                // Find based on company name or and post code.
                if (postCode !=null){
                    postCodeCleaned = postCode.trim();
                    postCodeCleaned = postCode.replace(' ','');
                }
                // Account Id hasn't been found so try looking based on account:
                if (isPDAccount){
    
                    List<Contact> contList = new List<Contact>([SELECT Account.Id FROM contact WHERE Account.Name = :accNamePD AND Email = :Email LIMIT 1]);
                    if (!contList.isEmpty())
                    {
                        AccId = contList[0].Account.Id;                 
                    }
    
                }else{
                    List<Account> accList = new List<Account>([SELECT id FROM account WHERE (Name = :accName OR Name = :accNamePD) AND Principle_Address_Postal_Code_no_spaces__c = :postCodeCleaned LIMIT 1]);
                    if (!accList.isEmpty())
                    {
                        AccId = accList[0].Id;                  
                    }
                }
            }
        }    
        
        if (accId == null){
            System.debug('No account found');
        }else{
            System.debug('Found Account: '+AccId);
        }

        return accId;
    }

    /* 
     * ADD OPPORTUNITY - addOpportunity()
     * 
     * Creates an Opportunity in Salesforce, if the account_id is null the opportunity will be created based on the contacts default
     * account.
     
     Other Opp Record Types:
        012200000001W3IAAU = In-Company Event
        012200000001bPhAAI = E-Delivery
        012200000001W41AAE = Public Event
        012200000001W6WAAU = Subscription
        012200000001bPrAAI = Tangible Goods
        012200000001kwyAAA = Audit   
     
     TEST call:
     
     WebsiteWS.addOpportunity(
        'Website_order_Id', 
        '012200000001W6WAAU',
        '003D000000jsWUU',
        '001D000000gxsYa',  <<<   Also try with null account (defaults to contacts account if null)
        'Shipping_Street',
        'Shipping_City',
        'Shipping_State',
        'Shipping_Postal_Code',
        'Shipping_Country',
        'BillingStreet',
        'BillingCity',
        'BillingState',
        'BillingPostalCode',
        'BillingCountry',
        'GBP',
        'Google_Keywords',
        'All_Keywords',
        'Google_Adwords',
        'Google_Referrer',
        'Google_utm_campaign',
        'Google_utm_source',
        'Google_utm_medium',
        'Google_utm_term',
        'Google_utm_content',
        'Purchase_Order_Reference',
        'Order comments');
     
     @todo Tests:
                * Contact not linked to account specified
                * Id's not populated
                
     */ 
    webService static wsOutputs addOpportunity(
        String Website_order_Id, 
        Id Opportunity_Record_Type,
        Id Contact_Id,
        Id Account_Id,
        String Shipping_Street,
        String Shipping_City,
        String Shipping_State,
        String Shipping_Postal_Code,
        String Shipping_Country,
        String BillingStreet,
        String BillingCity,
        String BillingState,
        String BillingPostalCode,
        String BillingCountry,
        String CurrencyIsoCode,
        String Google_Keywords,
        String All_Keywords,
        String Google_Adwords,
        String Google_Referrer,
        String Google_utm_campaign,
        String Google_utm_source,
        String Google_utm_medium,
        String Google_utm_term,
        String Google_utm_content,
        String Purchase_Order_Reference,
        String Order_Comments,
        String VAT_Registration_Number
        ){

        setupGlobals();
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs();
        
    // START addOpportunity Data Validation Checks

        // Check to see if the account is filled out and if not default to the contacts account
        if (Account_Id ==null){
            List<Contact> contactList = new List<Contact>([SELECT AccountId FROM Contact WHERE Id = :Contact_Id]);
        
            if (contactList.isEmpty())
            {
                output.errorMessage = 'Unable to find contact using ID specified: '+Contact_Id;
                output.success = false;
            }else{
                Account_Id = contactList[0].AccountId;
            }
        }

        // Check and get Account details for generating Opportunity
        List<Account> accList = new List<Account>([SELECT id,name FROM account WHERE id = :Account_id LIMIT 1]);
        
        if (accList.isEmpty())
        {
            // account can't be found
            output.errorMessage = 'No account ('+Account_id+') found';
            output.success = false;         
        }
        
        // Check and get RecordType details for generating Opportunity
        List<RecordType> rtList = new List<RecordType>([SELECT id,name FROM RecordType WHERE id = :Opportunity_Record_Type LIMIT 1]);
        
        if (rtList.isEmpty())
        {
            // recordType can't be found
            output.errorMessage = 'No opportunity recordType found with the id '+Opportunity_Record_Type;
            output.success = false;        
        }
        
    // END: addOpportunity Data Validation Checks
        
    // START: Generate fields required for opportunity creation & opp creation.
        
        if(output.success){
            // Add Opportunity
            Opportunity opp = new Opportunity();
            opp.Name = accList[0].Name+': '+rtList[0].Name;
            opp.Website_order_Id__c = Website_order_Id;
            opp.RecordTypeId = Opportunity_Record_Type;
            opp.AccountId = Account_Id;
            opp.shipping_street__c = Shipping_Street;
            opp.shipping_city__c = Shipping_City;
            opp.shipping_state__c = Shipping_State;
            opp.shipping_Postal_Code__c = Shipping_Postal_Code;
            opp.shipping_country__c  = Shipping_Country;
            opp.billing_street__c = BillingStreet;
            opp.billing_city__c = BillingCity;
            opp.billing_state__c = BillingState;
            opp.billing_postalcode__c = BillingPostalCode;
            opp.billing_country__c = BillingCountry;
            opp.Description = 'ONLINE ORDER COMMENTS:\n'+
                                Order_Comments;
            opp.CurrencyIsoCode = CurrencyIsoCode;
            opp.Google_Keywords__c = EncodingUtil.urlDecode(Google_Keywords,'UTF-8');
            opp.All_Keywords__c = EncodingUtil.urlDecode(All_Keywords,'UTF-8');
            opp.Google_Adwords__c = EncodingUtil.urlDecode(Google_Adwords,'UTF-8');
            opp.Google_Referrer__c = EncodingUtil.urlDecode(Google_Referrer,'UTF-8');
            opp.Google_utm_campaign__c = EncodingUtil.urlDecode(Google_utm_campaign,'UTF-8');
            opp.Google_utm_source__c = EncodingUtil.urlDecode(Google_utm_source,'UTF-8');
            opp.Google_utm_medium__c = EncodingUtil.urlDecode(Google_utm_medium,'UTF-8');
            opp.Google_utm_term__c = EncodingUtil.urlDecode(Google_utm_term,'UTF-8');
            opp.Google_utm_content__c = EncodingUtil.urlDecode(Google_utm_content,'UTF-8');
            opp.Purchase_Order_Reference__c = Purchase_Order_Reference;
            opp.VAT_Registration_Number__c = VAT_Registration_Number;
            opp.Use_part_invoicing__c = True;

            opp.CloseDate = Date.today()+7;
            opp.StageName = OPP_PENDING_STATUS;
            
            //Get Campaign ID if Google Campaign has been entered
            List<Campaign> camList = new List<Campaign>([SELECT id,name FROM Campaign WHERE Google_Campaign_Name__c = :Google_utm_campaign OR Name = :Google_utm_campaign ORDER BY Google_Campaign_Name__c LIMIT 1]);
            
            if (!camList.isEmpty())
            {
                opp.CampaignId = camList[0].Id;
            }
            
            try {
                // Try to insert the opportunity
                insert opp;
                output.id = opp.id;
                
            }catch(Exception e){
                // error occurred populate error object.
                output.errorMessage = 'Create Opp Error: '+e.getMessage();
                output.success = false;
            }
            // Add Contact Role
            
            if (output.success){
                OpportunityContactRole oppContRole = new OpportunityContactRole();
                oppContRole.OpportunityId = opp.id;
                oppContRole.ContactId = Contact_Id;
                oppContRole.IsPrimary = True;
                oppContRole.Role = 'Sales Contact';
                insert oppContRole;
            }

        }
    
    // END: Generate fields required for opportunity creation.
        System.debug('addOpportunity() Output: '+output);
        return output;
                
    }


    /* 
     * ADD OPPORTUNITY LINE - addOpportunityLine()
     * 
     * Adds an opportunity line to an opportunity.
     *
     * @param Total_Price Total price of line excluding Taxes
     *
     * WebsiteWS.addOpportunityLine('006M0000002fDx5','GBP',100.00,2,200.00,'01t200000010WeR',10,20);
     * 
     *
     */
    webService static wsOutputs addOpportunityLine(
        Id Opportunity_id,
        String CurrencyIsoCode,
        Decimal Unit_Price,
        Integer Quantity,
        Decimal Total_Price,
        Id Product_Id,
        Decimal Tax_Amount,
        Decimal Tax_Percentage
        ){
        system.debug('CurrencyIsoCode'+CurrencyIsoCode);
        system.debug('Unit_Price'+Unit_Price);
        system.debug('Quantity'+Quantity);
        system.debug('Total_Price'+Total_Price);
        system.debug('Product_Id'+Product_Id);
        system.debug('Tax_Amount'+Tax_Amount);
        system.debug('Tax_Percentage'+Tax_Percentage);

        
        setupGlobals();
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs();
        
        if (Tax_Amount == null){
            output.errorMessage = 'Tax amount cannot be empty';
            output.success = false;
        } else if (Tax_Percentage == null){
            output.errorMessage = 'Tax percentage cannot be empty';
            output.success = false;
            
        }
        
        if (output.success){
            OpportunityLineItem oppLine = new OpportunityLineItem();
            oppLine.OpportunityId = Opportunity_id;
            
            //oppLine.UnitPrice = Unit_Price;
            oppLine.Quantity = Quantity;
            oppLine.TotalPrice = Total_Price;
            oppLine.Website_Tax_Amount__c = Tax_Amount;
            oppLine.Website_Tax_Percentage__c = Tax_Percentage;
            
            
            // Check to see it the Opportunity line exists.
            List<PricebookEntry> pbeList = new List<PriceBookEntry>([SELECT Id,Name,Product2Id,UnitPrice,CurrencyIsoCode,Pricebook2Id,isActive 
                FROM PricebookEntry 
                WHERE Product2Id = :Product_Id
                 AND Pricebook2Id = :PRICEBOOK_ID
                 AND CurrencyIsoCode = :CURRENCY_ISO_CODE
                 AND isActive = True
                 LIMIT 1
                 ]);
            
            if (pbeList.isEmpty())
            {
                // Unable to find product
                output.errorMessage = 'Unable to find product specified; either it is inactive, not in GBP, or not in the online pricebook';
                output.success = false;
                
            }else{
                // Product is ok
                oppLine.PricebookEntryId = pbeList[0].Id;
                
                try {   
                    insert oppLine;
                    output.id = oppLine.Id;
                    system.debug('-----------------------------------------OppLine ------------ ' + oppline);
                    
                }catch(Exception e){
                    // error occurred populate error object.
                    output.errorMessage = 'Create Opp Error: '+e.getMessage();
                    output.success = false;
                }
            }
        }
        System.debug('addOpportunityLine() Output: '+output);
        return output;
    }


    /* 
     * ADD SUBSCRIPTION - addSubscription()
     *
     * Creates a subscription in Salesforce and returns the subscription id.
     *
     * TEST: WebsiteWS.addSubscription('001D000000gxsYa','003D000000jsWUU','006M0000002clgN');
     * 
     */
    webService static wsOutputs addSubscription(
        Id Account_Id,
        Id Contact_Id,
        Id Opportunity_Id
        ){
        
        setupGlobals();
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs();
        
        // Check to see if the account is filled out and if not default to the contacts account
        if (Account_Id ==null){
            List<Contact> contactList = new List<Contact>([SELECT AccountId FROM Contact WHERE Id = :Contact_Id]);
        
            if (contactList.isEmpty())
            {
                output.errorMessage = 'Unable to find contact using ID specified: '+Contact_Id;
                output.success = false;
                
            }else{
                Account_Id = contactList[0].AccountId;
            }
        }
        
        Subscription__c sub = new Subscription__c();
        sub.Account_Name__c = Account_Id;
        sub.Contact__c = Contact_Id;
        sub.Opportunity__c = Opportunity_Id;
        sub.Start_Date__c = Date.today();
        sub.Status__c = DEFAULT_SUBSCRIPTION_STATUS;
        sub.Type__c = DEFAULT_SUBSCRIPTION_TYPE;

        // Get Number of years subscription is for:
        Boolean iRecEntered = false;

        for(OpportunityLineItem oppLine : [SELECT PricebookEntry.Product2.Duration_Years__c FROM OpportunityLineItem WHERE Opportunity.Id = :Opportunity_Id AND PricebookEntry.Product2.Duration_Years__c != null]){
            System.debug('oppLine: '+oppLine+' Duration Years: '+OppLine.PricebookEntry.Product2.Duration_Years__c);
            if(OppLine.PricebookEntry.Product2.Duration_Years__c>0.0) {
                if (iRecEntered == false){
                    System.debug('Subscription Start Date: '+sub.Start_Date__c.addYears((OppLine.PricebookEntry.Product2.Duration_Years__c.intValue())));
                    sub.End_Date__c=(sub.Start_Date__c.addYears((OppLine.PricebookEntry.Product2.Duration_Years__c.intValue())))-1;
                    iRecEntered = true;
                }
            }
        }
        if (iRecEntered == false){
            // error occurred populate error object.
            //output.errorMessage = 'Create Subscription Error, unable to find OppLine with a product subscription duration';
            //output.success = false;
        }else{
            try {   
                insert sub;
                output.id = sub.Id;
                Opportunity opp = [select id, Subscription_Start_Date__c from opportunity where id = :Opportunity_Id];
                opp.Subscription_Start_Date__c = sub.Start_Date__c;
                update opp;
                
            }catch(Exception e){
                // error occurred populate error object.
                output.errorMessage = 'Create Subscription Error: '+e.getMessage();
                output.success = false;
            }
        }
        System.debug('addSubscription() Output: '+output);
        return output;
    }

    /* 
     * ADD SUBSCRIPTION SITE - addSubscriptionSite()
     *
     * Creates the subscription site, subscription lines & site products for a site based on the opportunity line(s)
     * 
     * This is the webservice call which is made but the method detects to see if RPCs are included and creates
     * seperate subscriptions for those if that is the case.
     *
     * @todo this now only supports the creation of one site due to requirement changes.
     * 
     * TEST: 
            Id subId = 'a0MM0000000MJvr';
            Id AccId = '001M0000006cay1';
            Id ContactId = '003M00000050Tgh';
            Id oppId = '006M000000371yH';
            
            List<Id> oppLines1 = new List<Id>();
            List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem WHERE opportunityId = :oppId]);
            for (OpportunityLineItem oppLine : oppLines ){
                oppLines1.add(OppLine.Id);
            }
            
            WebsiteWS.addSubscriptionSite(subId,AccId,ContactId,'Single Site',oppId,oppLines1);
     */
    webservice static wsOutputs addSubscriptionSite(
        Id Subscription_Id,
        Id Account_Id,
        Id Contact_Id,
        String Site_Type,
        Id Opportunity_Id,
        Id [] OppLineIdList
    ){
        setupGlobals();
        
        System.debug('Account Id = '+Account_Id);
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs(); 
        
        // Create a savepoint so we can rollback if something goes wrong
        Savepoint sp = Database.setSavepoint();
        
        
        // Check to see if the account is filled out and if not default to the contacts account
        /*
        // NO LONGER A REQUIREMENT FOR THE ACCOUNT TO BE FILLED OUT AS THIS CAN BE SET BY MEMBERSHIP/CUSTOMER
        
        if (Account_Id ==null){
            List<Contact> contactList = new List<Contact>([SELECT AccountId FROM Contact WHERE Id = :Contact_Id]);
        
            if (contactList.isEmpty())
            {
                output.errorMessage = 'Unable to find contact using ID specified: '+Contact_Id;
                output.success = false;
                
            }else{
                Account_Id = contactList[0].AccountId;
            }
        }
        */
        
        // Get Opportunity Lines
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>([SELECT o.Id, o.Quantity, o.TotalPrice, o.UnitPrice, o.PriceBookEntry.ProductCode, o.PriceBookEntry.Product2Id, o.PriceBookEntry.Product2.Duration_Years__c FROM OpportunityLineItem o WHERE Id IN :oppLineIdList]);
        
        if (oppLines.isEmpty()){
            // error occurred populate error object.
            output.errorMessage = 'Create Sub Site Error: Unable to find at least 1 Opportunity Line';
            output.success = false;
        }

        if (output.success){
            
            //addSubSite(Account_Id,Contact_Id,subscription_Id,Site_Type,oppLines);
            // Create the subscription site first
            Subscription_Site__c subSite = new Subscription_Site__c();
            subSite.Site_Account__c = Account_Id;
            subSite.Site_Contact__c = Contact_Id;
            subSite.Subscription__c = subscription_Id;
            subSite.Type__c = Site_Type;
            subSite.Active__c = true;
            subSite.Site_Start_Date__c = Date.today();
            insert subSite;
            output.id = subSite.id;
            
            string StrProductCodes='';
            List<Subscription_Line__c> SubscriptionLineList = new list<Subscription_Line__c>();
            
            // Loop over opportunity lines creating the product Codes field used for subscription sites
            // As well as creating the subscription line and site products at the same time.
            for(opportunityLineItem oppLine : oppLines )
            {
                // Build product codes line
                if(oppLine.Quantity > 0)
                {
                    if (StrProductCodes == ''){
                        StrProductCodes=oppLine.PriceBookEntry.ProductCode;
                    }else{
                        StrProductCodes=StrProductCodes + ';' + oppLine.PriceBookEntry.ProductCode;
                    }
                
                }
                //StrProductCodes=StrProductCodes.substring(1,StrProductCodes.length());
                
                // Build Subscription Line
                Subscription_Line__c subLine = new Subscription_Line__c();
                subLine.Product__c = oppLine.PriceBookEntry.Product2Id;
                subLine.Quantity__c = 1;
                subLine.Product_Sales_Price__c = oppLine.TotalPrice;
                subLine.Subscription__c = subscription_Id;
                subLine.OPL_ID__c = oppLine.Id;
                subLine.Product_Sales_Price__c = oppLine.TotalPrice;
                
                // Add subscription to the Subscription lines list.
                SubscriptionLineList.add(subLine);
            }
            
            System.debug(SubscriptionLineList);
            insert SubscriptionLineList;
            
            // Build Subscription Site Products
            List<Site_Product__c> SiteProductsList = new list<Site_Product__c>();       
            
            // START: Create Subscription Products
            for(Subscription_Line__c subLineWithId : SubscriptionLineList )
            {
                Site_Product__c siteProduct = new Site_Product__c();
                // add the product to the subscription products list
                siteProduct.Subscription__c = subscription_Id;
                siteProduct.Subscription_Site__c = subSite.id;
                siteProduct.CurrencyISOCode = CURRENCY_ISO_CODE;
                siteProduct.Subscription_Line__c  = subLineWithId.Id;
                siteProduct.Site_Product_Contact__c = Contact_Id;
                SiteProductsList.add(siteProduct);
            }
            
            try {
                insert SiteProductsList;
    
            }catch(Exception e){
                // error occurred populate error object.
                output.errorMessage = 'Create Site Product List Error: '+e.getMessage();
                output.success = false;
            }       
            // END: Create Subscription Products
            
            
            // Now we have iterated through the opp products and got the codes update the subscription with the codes:
            subSite.Subscription_Site_Product_Codes__c = StrProductCodes;
            update subSite;         
            

        }
        System.debug('addSubscriptionSite() Output: '+output);
        return output;
    }

    /* 
     * ADD SUBSCRIPTION SITE - addSubscriptionSite()
     *
     * Creates the subscription site, subscription lines & site products for a site based on the opportunity line(s)
     * 
     * This is the webservice call which is made but the method detects to see if RPCs are included and creates
     * seperate subscriptions for those if that is the case.
     *
     * @todo this now only supports the creation of one site due to requirement changes.
     * 
     * TEST: 
     *  List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem WHERE opportunityId = '006M0000002clgN']);
     *  WebsiteWS.addSubscriptionSite('a0MM0000000MD4XMAW','001D000000gxsYa','003D000000jsWUU','Single Site','006M0000002clgN',oppLines);
     */
    webservice static wsOutputs addSubscriptionSitev2(
        Id Subscription_Id,
        Id Account_Id,
        Id Contact_Id,
        String Site_Type,
        Id Opportunity_Id,
        Id [] OppLineIdList
    ){
        
        setupGlobals();
        // Create new return response & default response
        wsOutputs output = new wsOutputs(); 
        
        // Create a savepoint so we can rollback if something goes wrong
        Savepoint sp = Database.setSavepoint();
        
        
        // Check to see if the account is filled out and if not default to the contacts account
        if (Account_Id ==null){
            List<Contact> contactList = new List<Contact>([SELECT AccountId FROM Contact WHERE Id = :Contact_Id]);
        
            if (contactList.isEmpty())
            {
                output.errorMessage = 'Unable to find contact using ID specified: '+Contact_Id;
                output.success = false;
                
            }else{
                Account_Id = contactList[0].AccountId;
            }
        }
        
        Subscription__c rcpSub = [Select s.Id, s.Includes_Publication_Product__c, s.Includes_Membership_Product__c From Subscription__c s WHERE Opportunity__c = :Opportunity_Id AND Includes_Publication_Product__c = true LIMIT 1];
        Subscription__c memSub = [Select s.Id, s.Includes_Publication_Product__c, s.Includes_Membership_Product__c From Subscription__c s WHERE Opportunity__c = :Opportunity_Id AND Includes_Membership_Product__c = true LIMIT 1];
        
        // Get Opportunity Lines
        //List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>([SELECT o.Id, o.Quantity, o.ListPrice, o.TotalPrice, o.UnitPrice, o.PriceBookEntryId__r.ProductCode, o.PriceBookEntryId__r.Product2Id FROM OpportunityLineItem o WHERE Id = :oppLineIdList]);
        //List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>([SELECT o.Id, o.Quantity, o.TotalPrice, o.UnitPrice, o.PriceBookEntry.ProductCode, o.PriceBookEntry.Product2Id, o.PriceBookEntryId__r.Product2Id__r.RCP_Product__c FROM OpportunityLineItem o WHERE Id IN :oppLineIdList]);
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>([SELECT o.Id, o.Quantity, o.TotalPrice, o.UnitPrice, o.PriceBookEntry.ProductCode, o.PriceBookEntry.Product2Id, o.PriceBookEntry.Product2.RCP_Product__c, o.PriceBookEntry.Product2.Membership__c FROM OpportunityLineItem o WHERE Id IN :oppLineIdList ORDER BY o.PriceBookEntry.Product2.RCP_Product__c]);

        if (oppLines.isEmpty()){
            // error occurred populate error object.
            output.errorMessage = 'Create Sub Site Error: Unable to find at least 1 Opportunity Line';
            output.success = false;
        }

        if (output.success){
            
            addSubSite(Account_Id,Contact_Id,subscription_Id,Site_Type,oppLines);
            

        }
        System.debug('addSubscriptionSite() Output: '+output);
        return output;
    }

    /* 
     * UPDATE ORDER STATUS - updateOrderStatus
     * 
     * TEST: WebsiteWS.updateOrderStatus('67','Paid','123123123');
     */
    webService static wsOutputs updateOrderStatus (
        String Website_order_id,
        String Order_Status,
        String WorldPay_Reference_Id
        ){
        
        setupGlobals();
        
        id salesInvoiceId, cashEntryId, currentPeriodId;
        string invoiceName;
        // Update Account.Relationship__c = 'Trader' on succesful process (check workflow/triggers may do it already)
        //
        // Create new return response & default response
        wsOutputs output = new wsOutputs();

        // Check and get RecordType details for generating Opportunity
        List<RecordType> subRtList = new List<RecordType>([SELECT id,name FROM RecordType WHERE name = :SUBSCRIPTION_RECORD_TYPE_NAME LIMIT 1]);

        if (subRtList.isEmpty())
        {
            // recordType can't be found
            output.errorMessage = 'Unable to find opportunity subscription recordType (name: '+SUBSCRIPTION_RECORD_TYPE_NAME+')';
            output.success = false;        
        }
        
        // Check that opportunities exist and have an amount greater than 0:        
        Double totalOppAmount = 0;
        AggregateResult OppAmount = [Select SUM(Amount) amt From Opportunity WHERE Website_order_Id__c = :Website_order_id][0];
        totalOppAmount = Double.valueof(OppAmount.get('amt'));

        if(totalOppAmount == 0 || totalOppAmount == null){
            output.errorMessage = 'Create Invoice Error: No opportunities found with a positive amount ('+totalOppAmount+')';
            System.debug(output.errorMessage);
            output.success = false;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        // Create invoice
        if (Order_Status == 'Paid' && output.success)
        {
            System.debug('Order is Paid, so construct invoice');
            
            // @todo need to check to see if the invoice has already been created.
            c2g.CODAAPICommon.Reference result;
            Set<String> invoiceDescription = new Set<String>();
            List<Opportunity> updateOppList = new List<Opportunity>();
            List<OpportunityLineItem> updateOppLineItemList = new List<OpportunityLineItem>();
            //Webservice reference invoice 
            c2g.CODAAPIInvoiceTypes_4_0.Invoice invoice = new c2g.CODAAPIInvoiceTypes_4_0.Invoice();
            invoice.InvoiceDate = Date.today();
            invoice.PrintedText1AllowEdit = false;
            invoice.PrintedText2AllowEdit = false;
            invoice.PrintedText3AllowEdit = false;
            invoice.PrintedText4AllowEdit = false;
            invoice.PrintedText5AllowEdit = false;
            invoice.Usepartperiods = false;
            invoice.InvoiceDescription = ''; // @todo should be purchase order number from customer
            invoice.DueDate = Date.today().addDays(30);
            invoice.InvoiceStatus = c2g.CODAAPIInvoiceTypes_4_0.enumInvoiceStatus.InProgress;
            // invoice.Account is NOT the salesforce account object but the FF account (custom FF object record).
            invoice.Account = new c2g.CODAAPICommon.Reference();
            invoice.LineItems = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItems();
            invoice.LineItems.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem>();
            invoice.InvoiceCurrency = new c2g.CODAAPICommon.Reference();
            invoice.InvoiceCurrency.Id = GBP_CURRENCY_ID;
            
            // Need to update the quantity invoiced on the opp line to create a list to add lines to, to be updated. 
            List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
            
            // Create Line Items for invoice
            Double totalOppLineAmount = 0.0;
            
            Map<Id,Id> oppLineSubLineMap = getOppLineSubLineMap(Website_order_id);
            
            Boolean hasMultipleOpps = false;
            Id currentOppId;
            
            // List of unique opportunity Id
            List<Id> oppIds = new List<Id>();
            
            for(OpportunityLineItem oppLineItem:[SELECT Id,
                                                    Opportunity.Id,
                                                    Opportunity.AccountId,
                                                    Opportunity.Account.c2g__CODADimension1__c,
                                                    PriceBookEntry.Product2.Name,
                                                    PriceBookEntry.Product2Id,
                                                    PriceBookEntry.Product2.Dimension_1__c,
                                                    PriceBookEntry.Product2.Dimension_2__c,
                                                    PriceBookEntry.Product2.Renewal_Dimension_2__c,
                                                    PriceBookEntry.Product2.Web_Dimension_2__c,
                                                    OpportunityId,
                                                    Quantity,
                                                    Set_an_Invoice_Quantity__c, 
                                                    Quantity_Invoiced__c,
                                                    Quantity_Credited__c,
                                                    Website_Tax_Percentage__c,
                                                    TotalPrice,
                                                    Website_Tax_Amount__c,
                                                    UnitPrice,
                                                    Opportunity.Subscription__c,
                                                    Opportunity.Subscription__r.Includes_E_Delivery_Product__c,
                                                    Opportunity.Subscription__r.Account_Name__r.E_Delivery_Subscriber__c,
                                                    Opportunity.Subscription__r.Consolidated_Subscription__c,
                                                    Opportunity.Website_Order_Id__c,
                                                    Opportunity.Type
                                                 FROM 
                                                    OpportunityLineItem
                                                 WHERE 
                                                    Opportunity.Website_order_id__c = :Website_order_id])
            {
                oppIds.add(oppLineItem.Opportunity.Id);
                system.debug( ' - --------------------------------oppLineItem.UnitPrice ' + oppLineItem.UnitPrice);
                if (currentOppId == null){
                    currentOppId = oppLineItem.Opportunity.Id;
                }
                if ((currentOppId != oppLineItem.Opportunity.Id) && hasMultipleOpps == false){
                    hasMultipleOpps = true;
                }
                System.debug('Creating invoice line');
                c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem lineItem = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem();
                lineItem.Product = new c2g.CODAAPICommon.Reference();
                lineItem.Product.Id = oppLineItem.PriceBookEntry.Product2Id;
                lineItem.UnitPrice = oppLineItem.UnitPrice;
                lineItem.Usepartperiods = false;
                
                Id subLineId = oppLineSubLineMap.get(oppLineItem.Id);
                if (subLineId == null){
                    // No subline exists:
                    lineItem.LineDescription = oppLineItem.Id+';void';
                }else{
                    // Subline exists and 
                    lineItem.LineDescription = oppLineItem.Id+';'+subLineId;
                }
                
                // Add product price to today price:
                totalOppLineAmount = totalOppLineAmount + (oppLineItem.Website_Tax_Amount__c + oppLineItem.TotalPrice);
                
                if(oppLineItem.Set_an_Invoice_Quantity__c == null)
                {   
                    if(oppLineItem.Quantity_Invoiced__c == null)
                        oppLineItem.Quantity_Invoiced__c = 0;
                    if(oppLineItem.Quantity_Credited__c == null)
                        oppLineItem.Quantity_Credited__c = 0;
                    
                    lineItem.Quantity = oppLineItem.Quantity - oppLineItem.Quantity_Invoiced__c + oppLineItem.Quantity_Credited__c;
                }   
                else{
                    lineItem.Quantity = oppLineItem.Set_an_Invoice_Quantity__c;
                }
                
                // Dimension 1 = online order dimension 1 code
                lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                if (oppLineItem.PriceBookEntry.Product2.Dimension_1__c == null){
                    List<c2g__codaDimension1__c> dimension1 = [Select c.Name, c.Id From c2g__codaDimension1__c c WHERE c.Name = :DIMENSION_1_NAME LIMIT 1];
                    lineItem.Dimension1.Id = dimension1[0].Id;
                }else{
                    lineItem.Dimension1.Id = oppLineItem.PriceBookEntry.Product2.Dimension_1__c;
                }
                // Dimension 2 = Product Dimension code.
                lineItem.Dimension2 = new c2g.CODAAPICommon.Reference();
                lineItem.Dimension2.Id = FinanceHelper.getDim2Code(oppLineItem);
                
                // TaxCode Reference
                lineItem.TaxCode1 = new c2g.CODAAPICommon.Reference();
                if (oppLineItem.Website_Tax_Percentage__c == 20.00){
                    // Apply 20% Tax rate
                    lineItem.TaxCode1.Id = TAX_CODE_20_PERCENT;
                }else if (oppLineItem.Website_Tax_Percentage__c == 0.00){
                    // Apply Zero rated tax rate
                    lineItem.TaxCode1.Id = TAX_CODE_ZERO_PERCENT;
                }else{
                    // error occurred populate error object.
                    output.errorMessage = 'Unable to match tax rate '+oppLineItem.Website_Tax_Percentage__c+' to invoice line';
                    System.debug(output.errorMessage);
                    output.success = false;
                }
                
                if (output.success){
                    invoice.LineItems.LineItemList.add(lineItem);
                    invoice.Account.Id = oppLineItem.Opportunity.AccountId;
                    System.debug('opplineItem.Opp.AccountId: '+oppLineItem.Opportunity.AccountId);
                    
                    // Create the opp line that needs to be updated
                    oppLineItem.Quantity_Invoiced__c = oppLineItem.Quantity;
                    oppLineItem.Invoice_Date__c = Date.today();
                    //oppLineItem.Set_an_Invoice_Quantity__c = true;
                    oppLineItem.Quantity_Paid__c = oppLineItem.Quantity;
                    oppLineItem.Invoice_Paid_Date__c = Date.today();
                    oppLinesToUpdate.add(oppLineItem);
                }
                
            }
            if (!hasMultipleOpps){
                invoice.Opportunity = new c2g.CODAAPICommon.Reference();
                invoice.Opportunity.id = currentOppId;
            }
            
            // Update OppLines
            update oppLinesToUpdate;
                    
            //Specify the company to consider
            c2g.CODAAPICommon_4_0.Context context = new c2g.CODAAPICommon_4_0.Context();
            if(!WebsiteWS.isTest)
            {
                List<String> companyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
                context.CompanyName = companyName.get(0);
                if (context.CompanyName == null){
                    context.CompanyName = FF_COMPANY_NAME_CONTEXT;
                }
            }
    
            try {
                if (output.success){
                    System.debug('Creating Invoice' + invoice);
                    result=c2g.CODAAPISalesInvoice_4_0.CreateInvoice(context, invoice);
                    output.id = result.Id;    
                }
            }catch(Exception e){
                // error occurred populate error object.
                output.errorMessage = 'Create Invoice Error: '+e.getMessage();
                System.debug(output.errorMessage);
                output.success = false;
            }
            
            try {
                if (output.success){
                    System.debug('Update invoice with WorldPay & order id refs');
                    c2g__codaInvoice__c updateInvoice = [Select c.Id,c.c2g__CustomerReference__c,Name From c2g__codaInvoice__c c where c.Id =:result.Id];
                    updateInvoice.Worldpay_Id__c = WorldPay_Reference_Id;
                    updateInvoice.Website_Order_Id__c = Website_order_id;
                    updateInvoice.Post_Invoice_at__c = datetime.now();
                    invoiceName = updateInvoice.Name;
                    update updateInvoice;
                    
                     //POST INVOICE
                    if (POST_INVOICE){
                        //postInvoice(result.Id);
                        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
                        ref.Id = result.Id;
                        salesInvoiceId = result.id;
                        c2g.CODAAPISalesInvoice_4_0.PostInvoice(context, ref); 
                    }
                    
                    // Update "Latest Invoice field"
                    List<Opportunity> oppsToUpd = new List<Opportunity>([SELECT Id, Latest_Invoice__c FROM Opportunity WHERE Id IN:oppIds]);
                    for (Opportunity opp : oppsToUpd){
                        opp.Finance_to_Invoice_Opp__c = false;
                        opp.Latest_Invoice__c = output.id;
                    }
                    if (oppsToUpd.size() > 0){
                        update oppsToUpd;
                    }
                }
            // Posting of the invoice is done in the trigger code.
                
            }catch(Exception e){
                // error occurred populate error object.
                output.errorMessage = 'Update/Post Invoice Error: '+e.getMessage();
                output.success = false;
            }
            System.debug('Invoice segement finished');
            
            if(output.success){
                System.debug('Invoice successfully created (invoice Id: '+result.Id+')');
                // Add Payment
                // totalOppAmount
                System.debug('Construct Cash Entry');
                
                try {
                    System.debug('Constructing Cash Entry');
                    c2g.CODAAPICashEntryTypes_5_0.CashEntry cashEntry = new c2g.CODAAPICashEntryTypes_5_0.CashEntry();
                    
                    cashEntry.Account = new c2g.CODAAPICommon.Reference();
                    cashEntry.Account.Id = invoice.Account.Id;
                    cashEntry.TypeRef = c2g.CODAAPICashEntryTypes_5_0.enumType.Receipt;
                    cashEntry.BankAccount = new c2g.CODAAPICommon.Reference();
                    //if (test.isRunningTest()){
                    //  cashEntry.BankAccount.Id = [select id from c2g__codaBankAccount__c limit 1].Id;
                    //}else{
                        cashEntry.BankAccount.Id = 'a0wD0000000W4x1';
                    //}
                    system.debug('vs : ' + cashEntry.BankAccount.Id);
                    cashEntry.BankAccountCurrency = CURRENCY_ISO_CODE;
                    // cashEntry.BankAccountValue = totalOppAmount;
                    cashEntry.BankAccountValue = totalOppLineAmount;
                    cashEntry.CashEntryCurrency = new c2g.CODAAPICommon.Reference();
                    cashEntry.CashEntryCurrency.Id = GBP_CURRENCY_ID;
                    cashEntry.DateValue = Date.today();
                    cashEntry.Reference = invoice.Name; //'WorldPay Ref: '.WorldPay_Reference_Id;
                    cashEntry.CashEntryCurrency = new c2g.CODAAPICommon.Reference();
                    cashEntry.CashEntryCurrency.Id = GBP_CURRENCY_ID; 
                    cashEntry.PaymentMethod = 'Electronic';
                    //cashEntry.Description = invoice.Name;
                    //cashEntry.Reference = ' Worldpay ' + String.Valueof(cashEntry.DateValue) + ' ID ' + Website_Order_id;
                    cashEntry.Period  = new c2g.CODAAPICommon.Reference();
                    if (test.isRunningTest()){
                        cashEntry.Period.Id = [SELECT Id,Name FROM c2g__codaPeriod__c WHERE c2g__StartDate__c <= TODAY AND c2g__EndDate__c >= TODAY  AND c2g__OwnerCompany__c = 'a17D0000000MJyy' limit 1].Id; // 'a1uD0000000PCgc'; // NEED TO WORK OUT AUTOMATICALLY
                    }else {
                        cashEntry.Period.Id = [SELECT Id,Name FROM c2g__codaPeriod__c WHERE c2g__StartDate__c <= TODAY AND c2g__EndDate__c >= TODAY AND c2g__OwnerCompany__c = 'a17D0000000MJyy'].Id; // 'a1uD0000000PCgc'; // NEED TO WORK OUT AUTOMATICALLY
                    }
                    
                    currentPeriodId = cashEntry.Period.Id;
                    cashEntry.Status = c2g.CODAAPICashEntryTypes_5_0.enumStatus.InProgress;
                    
                    // Create Cash entry line list an
                    cashEntry.LineItems = new c2g.CODAAPICashEntryLineItemTypes_5_0.CashEntryLineItems();
                    cashEntry.LineItems.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_5_0.CashEntryLineItem>();
                    
                    c2g.CODAAPICashEntryLineItemTypes_5_0.CashEntryLineItem cashEntryLine = new c2g.CODAAPICashEntryLineItemTypes_5_0.CashEntryLineItem();
                    
                    cashEntryLine.Account = new c2g.CODAAPICommon.Reference();
                    cashEntryLine.Account.Id = invoice.Account.Id;
                    cashEntryLine.AccountReference = invoiceName;
                    cashEntryLine.AccountPaymentMethod = 'Electronic';
                    cashEntryLine.CashEntryValue = totalOppLineAmount;
                    //cashEntryLine.CashEntryValue = totalOppAmount;
                    //cashEntryLine.PaymentValue = totalOppAmount;
                    //cashEntryLine.PaymentCurrency = new c2g.CODAAPICommon.Reference();
                    //cashEntryLine.PaymentCurrency.Id = CURRENCY_ISO_CODE;
                    cashEntryLine.BankAccountValue = totalOppLineAmount;
                    
                    cashEntry.LineItems.LineItemList.add(cashEntryLine);
                    
                    // Insert cash entry
                    System.debug('Attempting to create cash entry');
                    c2g.CODAAPICommon_5_0.Context paymentContext = new c2g.CODAAPICommon_5_0.Context();
                    c2g.CODAAPICommon.Reference paymentResult = c2g.CODAAPICashEntry_5_0.CreateCashEntry(paymentContext, cashEntry);
                    
                    
                    c2g__codaCashEntry__c cashEntryRecord = [select id,name from c2g__codaCashEntry__c where id = :paymentResult.Id];
                    Datetime dateTimeToday = Datetime.now();
                    cashEntryRecord.c2g__Reference__c = cashEntryRecord.Name + ' Worldpay ' + dateTimeToday.format('dd/MM/yyyy') + ' ID ' + Website_Order_id;
                    cashEntryRecord.c2g__Description__c = cashEntryRecord.Name + ' Worldpay ' + dateTimeToday.format('dd/MM/yyyy') + ' ID ' + Website_Order_id;
                    system.debug('cashEntryRecord: '+cashEntryRecord);
                    update cashEntryRecord;
                    
                    // Post the cash entry
                    if(POST_CASH_ENTRY){
                        System.debug('Attempting to post cash entry');
                        c2g.CODAAPICommon.Reference cashEntryRef = new c2g.CODAAPICommon.Reference();
                        cashEntryRef.Id = paymentResult.Id;
                        cashEntryId = paymentResult.Id;
                        c2g.CODAAPICashEntry_5_0.PostCashEntry(paymentContext, cashEntryRef); 
                    }
                    
                }catch(Exception e){
                    // error occurred populate error object.
                    System.debug('Unable to create cash entry');
                    output.errorMessage = 'Unable to create cash entry: '+e.getMessage();
                    output.success = false;
                    output.id = null;
                }
            }
        
            if (output.success){
                // Update Opportunities to paid
                // OPP_PAID_STATUS
                System.debug('Update opportunities with new status');
                List<Opportunity> oppsList = new List<Opportunity>([Select Id From Opportunity WHERE Website_order_Id__c = :Website_order_id]);
                System.debug('Opps to update: '+oppsList);
                List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
                for (Opportunity opp:oppsList){
                    opp.StageName = OPP_PAID_STATUS;
                    oppsToBeUpdated.add(opp);
                    System.debug('adding opp'+opp);
                    update opp;
                }
                
                try {
                    System.debug('doing big update: '+OppsToBeUpdated);
                    update OppsToBeUpdated;

                }catch(Exception e){
                    // error occurred populate error object.
                    output.errorMessage = 'Unable to update opportunities with paid status: '+e.getMessage();
                    output.success = false;
                    output.id = null;
                }
                
                try {
                    // Update all subscriptions linked to opps to 'Current'
                    List <Subscription__c> subList = [SELECT Id FROM Subscription__c WHERE Opportunity__c IN :oppsList];
                    for (Subscription__c sub:subList){
                        sub.status__c = 'Current';
                    }
                    update subList;             
                
                }catch(Exception e){
                    // error occurred populate error object.
                    output.errorMessage = 'Unable to update opportunity subscriptions with status of "Current": '+e.getMessage();
                    output.success = false;
                    output.id = null;
                }
            }
            
            // Auto Cash Matching : by VS 05/03/2014
            if (output.success){
                
                system.debug('starting cash auto matching');
                
                //futureCashMatch(salesInvoiceId,cashEntryId, invoice.Account.Id,currentPeriodId);
                
                system.debug('end cash auto matching');
            }
        }else if(Order_Status == 'Payment Failed' && output.success){
            // Loop over all Opportunities for based on webId on the lines.
            //OPP_FAILED_STATUS
            System.debug('Payment failed so update opportunities to reflect this');
            List<Opportunity> oppsList = new List<Opportunity>([Select Id, Finance_to_Invoice_Opp__c From Opportunity WHERE Website_order_Id__c = :Website_order_id]);
            List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
            for (Opportunity opp:oppsList){
                opp.StageName = OPP_FAILED_STATUS;
                opp.Finance_to_Invoice_Opp__c = false;
                oppsToBeUpdated.add(opp);
            }
            try {
                update OppsToBeUpdated;
            
            }catch(Exception e){
                    // error occurred populate error object.
                    output.errorMessage = 'Unable to update opportunit(ies) with failed status: '+e.getMessage();
                    output.success = false;
                    output.id = null;
            }
        }
        
        if (!output.success){
            Database.rollback(sp);
        }
        
        system.debug('updateOrderStatus: '+output);
        return output;
    }

    /* 
     * UPDATE WEBSITE USER ID - updateWebsiteUserId
     * 
     * Updates a contact with a web Id.
     *
     * TEST: WebsiteWS.updateWebsiteUserId('99a9a','003D000000jsWUU');
     */
    webService static wsOutputs updateWebsiteUserId (String Website_User_Id, Id ContactId){
        
        setupGlobals();
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs();

        if (Website_User_Id ==null || ContactId ==null){
            // error occurred populate error object.
            output.errorMessage = 'Website_User_id and ContactId are both required';
            output.success = false;
            output.id = null;
        }
        
        if (output.success){
            List<Contact> contactEmailList = new List<Contact>([SELECT Id, WebId__c FROM Contact WHERE Id = :ContactId]);
            if (!contactEmailList.isEmpty()){
                System.debug('Found at least one contact and updating WebId');
                for(Contact ContactItem:contactEmailList)
                {
                    ContactItem.WebId__c = Website_User_Id;
                    
                }
                update contactEmailList;
            }else{
                // error occurred populate error object.
                output.errorMessage = 'ContactId could not be found';
                output.success = false;
                output.id = null;
            }
        }
        return output;
        
    }

    /*
     * CASH MATCHING
     *
     * Future Method to Cash match Invoices and Cash entry.
     *
     */
    @future static void futureCashMatch(id salesInvoiceId, id cashentryId, id accountId, id periodId){
    
        // path to financial force documentation
        // http://developer.financialforce.com/technical-reference/automating-cash-matching/
        
        system.debug('in Cash matching Future Call');
        
        List<string> documentRefs = new List<string>();
        documentRefs.add([select Id, Name from c2g__codaInvoice__c where Id = :salesInvoiceId].Name);
        documentRefs.add([select Id, Name from c2g__codaCashEntry__c where Id = :cashEntryId].Name);
        List<c2g__codatransactionlineitem__c> transactionLinesToMatch = [select Id, c2g__AccountValue__c from c2g__codaTransactionLineItem__c
                                                                         where c2g__Transaction__r.c2g__DocumentNumber__c in :documentRefs and c2g__LineType__c = 'Account'];
        
        system.debug('transactionLinesToMatch: '+ transactionLinesToMatch);
        
        // Match Invoice with Cash Entry
        c2g.CODAAPICommon_6_0.Context context1 = new c2g.CODAAPICommon_6_0.Context();
        c2g.CODAAPICashMatchingTypes_6_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_6_0.Configuration();
        configuration.Account = c2g.CODAAPICommon.getRef(accountId, null);
        configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_6_0.enumMatchingCurrencyMode.Account; 
        configuration.MatchingDate = System.today();
        configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(periodId, null);
        List<c2g.codaapicashmatchingtypes_6_0.item> items = new List<c2g.codaapicashmatchingtypes_6_0.item>();
        for (c2g__codaTransactionLineItem__c transactionLine : transactionLinesToMatch)
        {
            c2g.CODAAPICashMatchingTypes_6_0.Item item = new c2g.CODAAPICashMatchingTypes_6_0.Item();
            item.TransactionLineItem = c2g.CODAAPICommon.getRef(transactionLine.Id, null);
            item.Paid = transactionLine.c2g__AccountValue__c;
            item.Discount = 0;
            item.WriteOff = 0;
            items.add(item);
            system.debug('--------------------------------------------------item'+item);
        }
        c2g.CODAAPICashMatchingTypes_6_0.Analysis analisysInfo = new c2g.CODAAPICashMatchingTypes_6_0.Analysis();
        c2g.CODAAPICommon.Reference matchReference =  c2g.CODAAPICashMatching_6_0.Match(context1, configuration, items, analisysInfo);
       
        system.debug('in Cash matching Future Call completed');
    }

    /*
     * POST INVOICES
     *
     * Method to Post invoices.
     *
     */
    public static void postInvoice(Id invoiceId){ 
        
        setupGlobals();
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs();

        // Get Invoice
        c2g__codaInvoice__c inv = [Select c.Id From c2g__codaInvoice__c c WHERE c.Id = :InvoiceId];

        // Try to post invoice
        try {
            c2g.CODAAPICommon_4_0.Context paymentContext = new c2g.CODAAPICommon_4_0.Context();
            c2g.CODAAPICommon.Reference invoiceRef = new c2g.CODAAPICommon.Reference();
            invoiceRef.Id = inv.Id;
            c2g.CODAAPISalesInvoice_4_0.PostInvoice(paymentContext, invoiceRef); 

        }catch(Exception e){
            // error occurred populate error object.
            output.errorMessage = 'Unable to post Invoice'+e.getMessage();
            output.success = false;
            output.id = null;
        }
        
    }
    
    /* 
     * CREATE SUBSCRIPTION SITE - Creates a subscription site
     * 
     * This is called by the main webservice method addSubscriptionSite() to create a subscription site.
     * This is due to the introduction of having seperate subscriptions for RCPs.
     * 
     * TEST: WebsiteWS.addSubSite(??);
     */
    private static wsOutputs addSubSite (Id Account_Id, Id Contact_Id, Id Subscription_Id, String Site_Type, List<OpportunityLineItem> OppLines){

        setupGlobals();
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs();


        // Create the subscription site first
        Subscription_Site__c subSite = new Subscription_Site__c();
        subSite.Site_Account__c = Account_Id;
        subSite.Site_Contact__c = Contact_Id;
        subSite.Subscription__c = subscription_Id;
        subSite.Type__c = Site_Type;
        subSite.Active__c = true;
        
        insert subSite;
        output.id = subSite.id;
        
        string StrProductCodes='';
        List<Subscription_Line__c> SubscriptionLineList = new list<Subscription_Line__c>();
        
        // Loop over opportunity lines creating the product Codes field used for subscription sites
        // As well as creating the subscription line and site products at the same time.
        for(opportunityLineItem oppLine : oppLines )
        {
            // Build product codes line
            if(oppLine.Quantity > 0)
            {
                StrProductCodes=StrProductCodes + ';' + oppLine.PriceBookEntry.ProductCode;
            }
            StrProductCodes=StrProductCodes.substring(1,StrProductCodes.length());
            
            // Build Subscription Line
            Subscription_Line__c subLine = new Subscription_Line__c();
            subLine.Product__c = oppLine.PriceBookEntry.Product2Id;
            subLine.Quantity__c = 1;
            subLine.Product_Sales_Price__c = oppLine.TotalPrice;
            subLine.Subscription__c = subscription_Id;
            subLine.OPL_ID__c = oppLine.Id;
            subLine.Product_Sales_Price__c = oppLine.TotalPrice;
            
            // Add subscription to the Subscription lines list.
            SubscriptionLineList.add(subLine);
        }
        
        System.debug(SubscriptionLineList);
        insert SubscriptionLineList;
        
        // Build Subscription Site Products
        List<Site_Product__c> SiteProductsList = new list<Site_Product__c>();       
        
        // START: Create Subscription Products
        for(Subscription_Line__c subLineWithId : SubscriptionLineList )
        {
            Site_Product__c siteProduct = new Site_Product__c();
            // add the product to the subscription products list
            siteProduct.Subscription__c = subscription_Id;
            siteProduct.Subscription_Site__c = subSite.id;
            siteProduct.CurrencyISOCode = CURRENCY_ISO_CODE;
            siteProduct.Subscription_Line__c  = subLineWithId.Id;
            siteProduct.Site_Product_Contact__c = Contact_Id;
            SiteProductsList.add(siteProduct);
        }
        
        try {
            insert SiteProductsList;

        }catch(Exception e){
            // error occurred populate error object.
            output.errorMessage = 'Create Site Product List Error: '+e.getMessage();
            output.success = false;
        }       
        // END: Create Subscription Products
        
        
        // Now we have iterated through the opp products and got the codes update the subscription with the codes:
        subSite.Subscription_Site_Product_Codes__c = StrProductCodes;
        update subSite;
        
        return output;
    }   


    /* 
     * PRODUCT ID OK - productIdOk
     * 
     * Validates a product Id to make sure that:
     *      1. The product exists and is active
     *      2. The product is part of the online price book
     *      3. The product has a GBP price
     *
     * TEST: WebsiteWS.productIdOk('a2RD0000000TXvl');
     */
    webService static wsOutputs productIdOk (Id Product_Id){
        
        setupGlobals();
        
        // Get a list of pricebook entries based on product and pricebook id.
        List<PricebookEntry> pbeList = new List<PriceBookEntry>([SELECT Id,Name,Product2Id,UnitPrice,CurrencyIsoCode,Pricebook2Id,isActive 
            FROM PricebookEntry 
            WHERE Product2Id = :Product_Id
             AND Pricebook2Id = :PRICEBOOK_ID]);
        
        // Create new return response & default response
        wsOutputs output = new wsOutputs();
        
        
        if (pbeList.isEmpty())
        {
            // product can't be found or isn't in the online pricebook.
            output.errorMessage = 'Product ('+Product_id+') not found or not in online pricebook';
            output.success = false;
        }else{
            Boolean foundGBP = false;
            Boolean foundProductActive = false;
            
            for (PricebookEntry pbeItem:pbeList){
    
                if (pbeItem.IsActive)
                {
                    // Product is not active
                    if (!foundProductActive)
                        foundProductActive = true;
                }
                if (pbeItem.CurrencyIsoCode == CURRENCY_ISO_CODE)
                {
                    if(!foundGBP)
                        foundGBP = true;
                }
            }

            if (!foundProductActive)
            {
                // Product is not active
                output.errorMessage = 'Product specified is not active';
                output.success = false;
            }
            if (!foundGBP)
            {
                // Product doesn't have a GBP price
                output.errorMessage = 'Product does not have a pricebook entry in GBP';
                output.success = false;
            }
        }

        return output;
        
    }
    
    /* 
     * GET CONTACT DETAILS
     * 
     * Gets details for the contact which is shown in the website.
     *
     * NOTE: If you are making changes to this you may need to update the WebsitePermissions.getAreFieldsFilledOut()
     *       method.
     *
     * COMPANY ACCOUNTS:
     *   Title
     *   FirstName
     *   LastName
     *   Phone Number
     *   Company Name
     *   Number of Employees,
     *   Street Address
     *   City
     *   Area/Town
     *   Country
     *   ZIP / Postal Code
     * 
     * TEST: WebsiteWS.getAccountDetails('066D0000000IZsg');
     */
    webService static wsContactOutput getAccountDetails (Id contactId){
        // Create new return response & default response
        wsContactOutput output = new wsContactOutput();
        
        List<Contact> contactDetails = new List<Contact>([SELECT 
                                                    Id,
                                                    Name,
                                                    Firstname,
                                                    Lastname,
                                                    Salutation,
                                                    Email,
                                                    Account.Name,
                                                    Account.RecordTypeId,
                                                    Account.Id,
                                                    Account.Active__c,
                                                    Account.Phone,
                                                    Account.NumberOfEmployees,
                                                    Account.Correspondence_Name__c,
                                                    Account.Principle_Address_Building__c,
                                                    Account.Principle_Address_Street__c,
                                                    Account.Principle_Address_Area__c,
                                                    Account.Principle_Address_City__c,
                                                    Account.Principle_Address_State_Province__c,
                                                    Account.Principle_Address_ZIP_Postal_Code__c,
                                                    Account.Principle_Address_Country__c
                                                 FROM 
                                                    Contact
                                                 WHERE 
                                                    Id = :contactId]);
        
        RecordType PDAccRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Private_Delegate'][0];
        
        if (contactDetails.size() > 0){
            Contact contact = contactDetails[0];

            output.contactId = contact.Id;
            output.accountId = contact.Account.Id;
            output.username = contact.Email;
            output.email =  contact.Email;
            output.title = contact.Salutation;
            output.firstname = contact.Firstname;
            output.lastname = contact.Lastname;
            output.phoneNumber = contact.Account.Phone;
            if (contact.Account.RecordTypeId == PDAccRecordType.Id){
                // Is Private Delegate
                output.companyName = '';
            }else{
                output.companyName = contact.Account.Correspondence_Name__c;
            }

            String numberOfEmployees = '0';
            
            if (contact.Account.NumberOfEmployees <= 0){
                numberOfEmployees = '0';
            }else if (contact.Account.NumberOfEmployees < 500){
                numberOfEmployees = '1-499';
            }else if (contact.Account.NumberOfEmployees >= 500){
                numberOfEmployees = '500+';
            }
            
            output.numberOfEmployees = numberOfEmployees;
            
            String streetAddress = '';
            if (contact.Account.Principle_Address_Building__c != null){
                streetAddress = contact.Account.Principle_Address_Building__c + ', ';
            }
            
            if (contact.Account.Principle_Address_Street__c != null && contact.Account.Principle_Address_Street__c.length() > 0){
                streetAddress += contact.Account.Principle_Address_Street__c.replaceAll('\n',', ');
            }
            if (contact.Account.Principle_Address_Area__c != null && contact.Account.Principle_Address_Area__c.length() > 0){
                streetAddress += ', '+contact.Account.Principle_Address_Area__c;
            }
            if (streetAddress !=null){
                output.streetAddress = streetAddress; //.left(255);
            }

            if (contact.Account.Principle_Address_City__c != null && contact.Account.Principle_Address_City__c.length() > 0){
                // Truncated due to website limitation
                output.city = contact.Account.Principle_Address_City__c; //.left(40);
            }else{
                output.city = '';
            }
            if (contact.Account.Principle_Address_State_Province__c != null && contact.Account.Principle_Address_State_Province__c.length() > 0){
                // Truncated due to website limitation
                output.areaTown = contact.Account.Principle_Address_State_Province__c; //.left(20);
            }else{
                output.areaTown = '';
            }
            if (contact.Account.Principle_Address_ZIP_Postal_Code__c != null && contact.Account.Principle_Address_ZIP_Postal_Code__c.length() > 0){
                output.zipPostalCode = contact.Account.Principle_Address_ZIP_Postal_Code__c;
            }else{
                output.zipPostalCode = '';
            }

            if (contact.Account.Principle_Address_Country__c != null && contact.Account.Principle_Address_Country__c.length() > 0){
                output.country = contact.Account.Principle_Address_Country__c;
            }else{
                output.country = '';
            }
            
        }
        return output;
        
    }
    
    /*
     * GET OPPORTUNITY LINE AND SUBSCRIPTION LINE OPPORTUNITY MAP
     *
     * Returns a map which links opportunity lines to subscription lines
     *
     * Returns: map<OpportunityLineId,SubscriptionLineId>
     */
    public static Map<Id,Id> getOppLineSubLineMap(String Website_Order_Id){
        
        setupGlobals();
        
        // Get Subscriptions on opportunity
        Set<Id> subsList = new Set<Id>();

        for(Subscription__c sub : [SELECT Id FROM Subscription__c WHERE opportunity__r.Website_Order_Id__c = :Website_Order_Id]){
            subsList.add(sub.Id);
        }
        
        Map<Id,Id> oppLineSubLineList = new Map<Id,Id>();
        
        for (Subscription_Line__c subLine : [SELECT
                Id,
                OPL_ID__c
            FROM
                Subscription_Line__c
            WHERE
                Subscription__c IN :subsList]){
            
            if (subLine.OPL_ID__c !=null){
                oppLineSubLineList.put(subLine.OPL_ID__c,subLine.Id);
            }
            
        }
        
        return oppLineSubLineList;
    }
}