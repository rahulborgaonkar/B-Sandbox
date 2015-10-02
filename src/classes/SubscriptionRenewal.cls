global without sharing class SubscriptionRenewal {
    
    static Boolean isClassVarsSet = false;

    static Id PRICEBOOK_INTL_MEMBERS;
    static Id PRICEBOOK_UK_MEMBERS;
    static Id PRICEBOOK_STANDARD = null; // Prod value: '01s20000000Hb8eAAC'
    static Id DEFAULT_OWNER; // Prod value: '005D0000001q7Pt'; // Website User
    //static final String DEFAULT_DIMENSION_1_NAME = '510 - Sales Management';
    static final Boolean isTest = false;
    //static final String FF_COMPANY_NAME_CONTEXT = '(British Safety Council)';

    static final Integer INVOICE_DUE_IN = 90; // The number of days from creation of invoice to when invoice is due
    //static final Integer POST_INVOICE_IN = 50; // The number of days from creation of invoice to when invoice is due
    
    public class myException extends Exception{}
    
    public static Boolean setDefaultValues(){
        
        if (!isClassVarsSet){
            // Get website user
            // 005D0000001q7Pt
            try {
                User websiteUser = [SELECT Id, Alias FROM User WHERE Alias = 'Website'][0];
                DEFAULT_OWNER = websiteUser.Id;
            }catch(Exception e){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find user with the alias of \'Website\'');
            }
            
            // Setup pricebooks
            Boolean foundStandardPB = false;
            Boolean foundUKPB = false;
            Boolean foundIntlPB = false;
            String errorMsg = 'unknown';
            for (Pricebook2 pb : [SELECT Id, isStandard, Name FROM Pricebook2 W
                                    WHERE ((isActive = True AND 
                                        (isStandard = true OR Name = 'Mem/Subs: UK Members' OR 
                                            Name = 'Mem/Subs: Intl Members')
                                        ) 
                                        OR Name = 'Standard Price Book')]){
                if (pb.IsStandard == true){
                    PRICEBOOK_STANDARD = pb.Id;
                    foundStandardPB = true;
                }
                if (pb.Name == 'Mem/Subs: UK Members'){
                    PRICEBOOK_UK_MEMBERS = pb.Id;
                    foundUKPB = true;
                }
                if (pb.Name == 'Mem/Subs: Intl Members'){
                    PRICEBOOK_INTL_MEMBERS = pb.Id;
                    foundIntlPB = true;
                }
            }
            if (!foundStandardPB){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find \'Standard Price book\'');
            }else if (!foundUKPB){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find \'Mem/Subs: UK Members price book\'');
            }else if(!foundIntlPB){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find \'Mem/Subs: Intl Members\'');
            }else{
                isClassVarsSet = true;
            }
        }
        return true;
    }


    
    /*
     * PUBLIC CLASSES
     * 
     */
    
    /*
     * RUN SUBSCRIPTION RENEWAL: STAGE 1 - CREATE RENEWAL OPP & CLONED SUBSCRIPTION (List of subscriptions)
     * 
     * Creates the cloned subscription and child objects as well as renewal opportunity.
     */
     webservice static String runSubscriptionRenewals(Id subscription){
        
        setDefaultValues();
        
        List<Subscription__c> subscriptionList = new List<Subscription__c>([SELECT
                                                                        Id,
                                                                        Renewal_Reminders__c,
                                                                        End_Date__c,
                                                                        Account_Name__c,
                                                                        Subscription_Manager__c,
                                                                        Account_Name__r.OwnerId
                                                                        
                                                                    FROM
                                                                        Subscription__c
                                                                    WHERE
                                                                        Id = :subscription]);
        System.debug('runSubscriptionRenewalWithId subList: '+subscriptionList);

        String result = runSubscriptionRenewals(subscriptionList);
        
        return result;
    }
    
    /*
     * RUN SUBSCRIPTION RENEWAL: STAGE 1 - CREATE RENEWAL OPP & CLONED SUBSCRIPTION (List of subscriptions)
     * 
     * Creates the cloned subscription and child objects as well as renewal opportunity.
     */
    public static String runSubscriptionRenewals(List<sObject> subscriptionList){
        
        setDefaultValues();
        
        ApexCodePatrol.disable('AccountSubscriptionFlags');
        
        System.debug('** running SubscriptionRenewal batch execute. Rowcount: ' + subscriptionList.size());
        
        //Get the opportunity record type of "Subscription"
        RecordType recordType = [SELECT Id FROM RecordType WHERE
                SobjectType = 'Opportunity' AND
                Name = 'Subscription' LIMIT 1];
        
        List<Subscription__c> subscriptions = new List<Subscription__c>([SELECT 
                                                                    Account_Name__c,
                                                                    Contact__c,
                                                                    End_Date__c,
                                                                    Opportunity__c,
                                                                    Previous_Subscription__c,
                                                                    Renewal_Opportunity__c,
                                                                    Renewal_Opportunity_Created__c,
                                                                    Renewal_Reminders__c,
                                                                    Start_Date__c,
                                                                    Original_Start_date__c,
                                                                    Status__c,
                                                                    Subsequent_Subscription__c,
                                                                    Id,
                                                                    Owner.IsActive,
                                                                    OwnerId,
                                                                    Account_Name__r.OwnerId,
                                                                    Account_Name__r.Pricebook__c,
                                                                    Account_Name__r.Member__c,
                                                                    Account_Name__r.Principle_Address_Country__c,
                                                                    Account_Name__r.Name,
                                                                    Opportunity__r.Pricebook2Id,
                                                                    Opportunity__r.Invoice_Company__c,
                                                                    Opportunity__r.Owner.IsActive,
                                                                    Send_Subscription_by__c,
                                                                    Longest_Duration_Years__c,
                                                                    Product_Codes__c,
                                                                    Paying_By__c,
                                                                    Subscription_Contract_End_Date__c,
                                                                    Subscription_Notice_Period_Days__c,
                                                                    Subscription_Contract_Start_Date__c,
                                                                    Includes_E_Delivery_Product__c,
                                                                    (SELECT 
                                                                            Id,
                                                                            Product__c,
                                                                            Quantity__c,
                                                                            Renewal_Quantity__c,
                                                                            Renewal_Price__c,
                                                                            Ongoing_Renewal_Price__c,
                                                                            OPL_ID__c,
                                                                            Product_Sales_Price__c,
                                                                            Subscription__c,
                                                                            Previous_Subscription_Line__c,
                                                                            Product__r.Renew_at_this_price__c,
                                                                            Product__r.E_Delivery_Subscription__c,
                                                                            E_Delivery_Number_of_Licences__c
                                                                        FROM 
                                                                            Subscription_Lines__r
                                                                        WHERE
                                                                            Renewal_Quantity__c != 0
                                                                        ),
                                                                    (SELECT
                                                                            Id,
                                                                            Alternative_Address__c,
                                                                            Site_Product_Contact__c,
                                                                            Subscription__c,
                                                                            Subscription_Line__c,
                                                                            Subscription_Site__c,
                                                                            Previous_Site_Product__c
                                                                        FROM
                                                                            Site_Products__r
                                                                        WHERE
                                                                            Subscription_Site__r.Active__c = True
                                                                            AND Subscription_Site__r.Do_Not_Renew_This_Site__c = false),
                                                                    (SELECT
                                                                            Id,
                                                                            Delivery_Address__c,
                                                                            Main_Site__c,
                                                                            No_Magazine_Mailing__c,
                                                                            Password__c,
                                                                            Site_Account__c,
                                                                            Site_Contact__c,
                                                                            Site_Start_Date__c,
                                                                            Subscription__c,
                                                                            Type__c,
                                                                            Username__c,
                                                                            Previous_Subscription_Site__c,
                                                                            Subscription_Site_Product_Codes__c,
                                                                            Do_Not_Renew_This_Site__c
                                                                        FROM
                                                                            Subscriptions__r
                                                                        WHERE
                                                                            Active__c = True
                                                                            AND Do_Not_Renew_This_Site__c = false
                                                                            )
                                                                FROM 
                                                                    Subscription__c 
                                                                WHERE
                                                                    Id = :subscriptionList
                                                                    AND Subscription_Sites__c > 0
                                                                ]);
        
         System.debug('SW Subscription Lines '+subscriptions+ ' Subscription Lines End');
        //For each renewal subscription create an opportunity
        for (Subscription__c subscription : subscriptions) {
            
            // *** START: CREATE OPPORTUNITY
            date myDate = date.today();
            
            Id OWNER = DEFAULT_OWNER;
            if (subscription.Includes_E_Delivery_Product__c && subscription.Opportunity__c !=null && subscription.Opportunity__r.Owner.IsActive == true){
                OWNER = subscription.Opportunity__r.OwnerId;
            }
            
            Opportunity opportunity = new Opportunity(
                Type = 'Subscription Renewal',
                StageName = 'Quote/Proposal',
                OwnerId = OWNER,
                Name = subscription.Account_Name__r.Name+': Sub Renewal '+myDate.year(),
                Subscription_Initiating_Renewal__c = subscription.Id,
                Renewal_Reminders__c = subscription.Renewal_Reminders__c,
                Renewal_Opportunity__c = true,
                AccountId = subscription.Account_Name__c,
                RecordTypeId = recordType.Id,
                Invoice_Company__c = subscription.Opportunity__r.Invoice_Company__c,
                Subscription_Start_Date__c = subscription.End_Date__c+1,
                Subscription_Contract_Start_Date__c = Subscription.Subscription_Contract_Start_Date__c,
                Subscription_Contract_End_Date__c = Subscription.Subscription_Contract_End_Date__c,
                Subscription_Notice_Period_Days__c = Subscription.Subscription_Notice_Period_Days__c
                );
                
            // Opportunity Close dates can't be in the past
            if (subscription.End_Date__c < Date.Today()){
                opportunity.CloseDate = Date.Today();
            }else{
                opportunity.CloseDate = subscription.End_Date__c;
            }
            
            //Set the owner and create opportunity
            
            opportunity.OwnerId = OWNER;
            opportunity.Disable_re_assignment__c = true;
            
            insert opportunity;
            
            OpportunityContactRole oppContRole = new OpportunityContactRole(
                OpportunityId = opportunity.id,
                ContactId = subscription.Contact__c,
                IsPrimary = True,
                Role = 'Sales Contact'
            );
            
            insert oppContRole;
            
            
            System.debug('** Created opportunity: ' + opportunity.id);
            
            subscription.Renewal_Opportunity_Created__c = true;
            

            // *** END: CREATE OPPORTUNITY
            
            // *** START: CREATE OPPORTUNITY LINES
            //Create opportunity line items from subscription line items
            List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
            
            System.debug('FJP Subscription Lines: '+subscription.Subscription_Lines__r);

            Id pricebookId = null;

            // Check to see if a productbook has been set on the opportunity if so use this product book.
            System.debug('Current Pricebook: '+subscription.Opportunity__r.Pricebook2Id);
            System.debug('Standard Pricebook is: '+PRICEBOOK_STANDARD);
            if (subscription.Opportunity__r.Pricebook2Id != null && subscription.Opportunity__r.Pricebook2Id != PRICEBOOK_STANDARD){
                pricebookId = subscription.Opportunity__r.Pricebook2Id;
            }else{          
                // No opportunity pricebook exists so use account country to work out pricebook to use.
                if (subscription.Account_Name__r.Principle_Address_Country__c == 'United Kingdom'){
                    pricebookId = PRICEBOOK_UK_MEMBERS;
                }else{
                    pricebookId = PRICEBOOK_INTL_MEMBERS;
                }
            }

            // Case 6704 - This is added to get correct number of Site Product records and update Quantity on Subscriptions Lines.
            Map<Id, Integer> MapLineSiteCount = new Map<Id, Integer> ();
            Map<Id, Id> MapSubscriptionNewProduct = new Map<Id, Id> ();

            for (Site_Product__c siteProduct:subscription.Site_Products__r)
            {
                if(MapLineSiteCount.containsKey(siteProduct.Subscription_Line__c))
                {
                    Integer siteCount = MapLineSiteCount.get(siteProduct.Subscription_Line__c);
                    siteCount++;
                    MapLineSiteCount.put(siteProduct.Subscription_Line__c, siteCount);
                }
                else
                {
                    MapLineSiteCount.put(siteProduct.Subscription_Line__c, 1);
                }
            }
            system.debug('RSB MapLineSiteCount - ' + MapLineSiteCount);
            // Case 6704

            // Create a mapping between opp line and old sub line for later on... 
            Map<Id,OpportunityLineItem> oldSubLineToOppLine = new Map<Id,OpportunityLineItem>();
            
            for (Subscription_Line__c subscriptionLine : subscription.Subscription_Lines__r) {

                 // Case 00001610 changing the reference from Account_Name__r.Pricebook__c to Account_Name__r.Pricebook2__c.
                System.debug('FJP PriceBook being used: '+pricebookId);
                System.debug('FJP subscriptionLine.Product__c: '+subscriptionLine.Product__c);
                if (pricebookId != null) {

                    List<PricebookEntry> pricebookEntries = null;
                    
                    if (subscriptionLine.Product__c !=null){
                        pricebookEntries = [SELECT 
                                                Id, 
                                                UnitPrice,
                                                Product2.Renewal_Multiplier__c,
                                                Product2.Duration_Years__c,
                                                Product2.Minimum_Attendees__c,
                                                Product2.Maximum_Attendees__c,
                                                Product2.Product_Correspondence_Name__c
                                            FROM 
                                                PricebookEntry
                                            WHERE 
                                                Pricebook2Id = :pricebookId
                                                AND Product2Id = :subscriptionLine.Product__c 
                                            LIMIT 1];
                        System.debug('RSB PriceBook Entry: '+pricebookEntries);
                        System.debug('RSB pricebookEntries[0].Product2.Minimum_Attendees__c - ' + pricebookEntries[0].Product2.Minimum_Attendees__c);
                        System.debug('RSB pricebookEntries[0].Product2.Maximum_Attendees__c - ' + pricebookEntries[0].Product2.Maximum_Attendees__c);
                        System.debug('RSB pricebookEntries[0].Product2.Product_Correspondence_Name__c - ' + pricebookEntries[0].Product2.Product_Correspondence_Name__c);
                    }
                    //PricebookEntry pricebookEntry = pricebookId;
                    Double totalPrice = 0;  
                    
                    // Check to to see if there is a renewal quantity and if there is use that instead of the normal qty.               
                    Double quantity;
                    if(subscriptionLine.Renewal_Quantity__c == null){
                        quantity = subscriptionLine.Quantity__c;
                    }else{
                        quantity = subscriptionLine.Renewal_Quantity__c;
                    }
                    
                    // Case 6704 - Find correct PricebookEntry as per Quantity Range and assign it to Opportunity Line
                    system.debug('RSB subscriptionLine.Id - ' + subscriptionLine.Id);
                    system.debug('RSB MapLineSiteCount Line Exists - ' + MapLineSiteCount.containsKey(subscriptionLine.Id));
                    system.debug('RSB MapLineSiteCount Quantity - ' + MapLineSiteCount.get(subscriptionLine.Id));
                    if(MapLineSiteCount.containsKey(subscriptionLine.Id))
                    {
                        quantity = MapLineSiteCount.get(subscriptionLine.Id);
                        // Case 6704 - Check first if min and max attendees are not null then check if quantity fits within range
                        if(pricebookEntries[0].Product2.Minimum_Attendees__c != null && pricebookEntries[0].Product2.Maximum_Attendees__c != null && !(quantity >= pricebookEntries[0].Product2.Minimum_Attendees__c && quantity <= pricebookEntries[0].Product2.Maximum_Attendees__c))
                        {
                            system.debug('RSB Wrong Range');
                            List<PricebookEntry> newPBE = null;
                            newPBE = [SELECT Id, Name, UnitPrice, Product2.Id, Product2.Name,
                                                Product2.Renewal_Multiplier__c,Product2.Duration_Years__c,
                                                Product2.Minimum_Attendees__c,Product2.Maximum_Attendees__c,
                                                Product2.Product_Correspondence_Name__c
                                                FROM PricebookEntry 
                                                WHERE Pricebook2Id = :pricebookId
                                                AND Product2.Product_Correspondence_Name__c like :pricebookEntries[0].Product2.Product_Correspondence_Name__c + '%'
                                                AND (Product2.Minimum_Attendees__c <= :quantity AND Product2.Maximum_Attendees__c >= :quantity) LIMIT 1];

                            system.debug('RSB List<PricebookEntry> newPBE - ' + newPBE);
                            pricebookEntries = newPBE;

                        }
                        else
                        {
                            system.debug('RSB Correct Range');
                        }
                        MapSubscriptionNewProduct.put(subscriptionLine.Id, pricebookEntries[0].Product2.Id);
                    }
                    // Case 6704

                    if (pricebookEntries != null && !pricebookEntries.isEmpty()){
                        System.debug('pricebookEntries is not empty or null');
                        if (subscriptionLine.Renewal_Price__c == null && subscriptionLine.Ongoing_Renewal_Price__c == null){
                            System.debug('Subscription Renewal Price is null');
                            
                            // Check to see if someone has
                            if (subscriptionLine.Product__r.Renew_at_this_price__c == null || subscriptionLine.Product__r.Renew_at_this_price__c == 0){
                                // No-one has entered a renewal price so work out the renewal price based on renewal multiplier if on the product otherwise
                                // based on Product Unit price.
                                if (pricebookEntries[0].Product2.Renewal_Multiplier__c !=null){
                                    System.debug('Using Multiplier to determine price. Multiplier = '+pricebookEntries[0].Product2.Renewal_Multiplier__c+', UnitPrice = '+pricebookEntries[0].UnitPrice+', Qty = '+quantity);
                                    totalPrice = (pricebookEntries[0].Product2.Renewal_Multiplier__c * pricebookEntries[0].UnitPrice) * quantity;
                                }else{
                                    System.debug('Using Pricebook unitprice ('+pricebookEntries[0].UnitPrice+')* qty ('+quantity+') to determine price');
                                    totalPrice = pricebookEntries[0].UnitPrice * quantity;
                                }
                            }else{
                                totalPrice = subscriptionLine.Product__r.Renew_at_this_price__c * quantity;
                            }
                            System.debug('Total Price set to: '+totalPrice);
                        
                        }else if ((subscriptionLine.Renewal_Price__c != null && subscriptionLine.Ongoing_Renewal_Price__c == null) || (subscriptionLine.Renewal_Price__c != null && subscriptionLine.Ongoing_Renewal_Price__c != null)){

                            totalPrice = subscriptionLine.Renewal_Price__c;
                            
                        }else{
                            System.debug('Total Price set to (2):'+totalPrice);
                        }
                    }
                    if (pricebookEntries.size() < 1){
                        System.debug('In myException');
                        throw new myException('Subscription line product is not in the correct price book');
                    }

                    OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
                        Quantity = quantity,
                        OpportunityId = opportunity.Id,
                        PricebookEntryId = pricebookEntries[0].Id,
                        Duration_Years__c = pricebookEntries[0].Product2.Duration_Years__c,
                        E_Delivery_Number_of_Licences__c = subscriptionLine.E_Delivery_Number_of_Licences__c,
                        //Renewal_Price__c = subscriptionLine.Renewal_Price__c > 0 ? subscriptionLine.Renewal_Price__c : null,
                        Pricing_Exception__c = subscriptionLine.Renewal_Price__c > 0 ? true : false);
                    
                    if (subscriptionLine.Ongoing_Renewal_Price__c != null){
                        
                        opportunityLineItem.Renewal_Price__c = subscriptionLine.Ongoing_Renewal_Price__c;
                    }
                    
                    
                    
                    if (subscriptionLine.Renewal_Price__c == null){
                        opportunityLineItem.TotalPrice = totalPrice;
                    }else{
                        // Someone has entered a renewal price
                        System.debug('Renewal price is blank so use subscription Line renewal price');
                        opportunityLineItem.TotalPrice = (subscriptionLine.Renewal_Price__c*quantity);
                    }
                    if (subscriptionLine.Product__r.E_Delivery_Subscription__c){
                        opportunityLineItem.E_Delivery_Override_Algorithm_Price__c = true;
                    }
                    opportunityLineItems.add(opportunityLineItem);
                    oldSubLineToOppLine.put(subscriptionLine.Id,opportunityLineItem);
                }
                System.debug('RSB Opp Lines: '+opportunityLineItems);
                
                
            }
            insert opportunityLineItems;
            // *** END: CREATE OPPORTUNITY LINES
            
            
            // *** START: CREATE SUBSCRTPTION
            
            Decimal durationInDays = subscription.Longest_Duration_Years__c*365.0;
            Date endDate = subscription.End_Date__c+(durationInDays.intValue());
            
            // @todo product codes have been copied from original sub but actually may not be the same if
            // sites have been cancelled during the year.
            
            //Subscription__c subscription = (Subscription__c)item;
            Subscription__c newSub = new Subscription__c(
                                    Account_Name__c = subscription.Account_Name__c,
                                    Contact__c = subscription.Contact__c,
                                    Start_Date__c = subscription.End_Date__c+1,
                                    End_Date__c = endDate,
                                    OwnerId = OWNER,
                                    Opportunity__c = opportunity.Id,
                                    Previous_Subscription__c = subscription.id,
                                    Status__c = 'Pending - Not Paid',
                                    Original_Start_date__c = subscription.Original_Start_date__c,
                                    Type__c = 'Renewal',
                                    Paying_By__c = subscription.Paying_By__c,
                                    Product_Codes__c = subscription.Product_Codes__c,
                                    Subscription_Account_Owner__c = Subscription.Account_Name__r.OwnerId     
            );
            
            insert newSub;
            
            
            subscription.Subsequent_Subscription__c = newSub.Id;
            subscription.Status__c = 'Current - Renewing';
                        
            System.debug('Inserted New Sub: '+newSub);
            
            // *** END: CREATE SUBSCRTPTION
            
            // *** START: CREATE SUBSCRTPTION SITES
            List<Subscription_Site__c> newSubSites = new List<Subscription_Site__c>();
            
            for (Subscription_Site__c subSite :subscription.Subscriptions__r){
                Subscription_Site__c newSubSite = new Subscription_Site__c(
                                                                Delivery_Address__c = subSite.Delivery_Address__c,
                                                                No_Magazine_Mailing__c = subSite.No_Magazine_Mailing__c,
                                                                Password__c = subSite.Password__c,
                                                                Site_Account__c = subSite.Site_Account__c,
                                                                Site_Contact__c = subSite.Site_Contact__c,
                                                                Site_Start_Date__c = subscription.End_Date__c+1,
                                                                Subscription__c = newSub.id,
                                                                Type__c = subSite.Type__c,
                                                                Username__c = subSite.Username__c,
                                                                Previous_Subscription_Site__c = subSite.Id,
                                                                Subscription_Site_Product_Codes__c = subSite.Subscription_Site_Product_Codes__c
                    );
                newSubSites.add(newSubSite);
            }
            system.debug('RSB newSubSites - ' + newSubSites);
            insert newSubSites;
            
            // *** END: CREATE SUBSCRTPTION SITES

            // *** START: CREATE SUBSCRTPTION LINES
            
            // The list to hold the new subscriptions lines that are going to be created
            List<Subscription_Line__c> newSubLines = new List<Subscription_Line__c>();
            
            System.debug('Creating '+subscription.Subscription_Lines__r.size()+ ' Subscription Lines');
            
            for (Integer i=0; subscription.Subscription_Lines__r.size() > i; i++) {
                
                // Get the oppline that was created for this subscription line to get the new pricing info for sub line.
                OpportunityLineItem oppLine = oldSubLineToOppLine.get(subscription.Subscription_Lines__r[i].Id);
                system.debug('RSB OpportunityLineItem oppLine - ' + oppLine);
                system.debug('RSB OpportunityLineItem oppLine.PricebookEntry.Product2 - ' + oppLine.PricebookEntry.Product2);
                system.debug('RSB OpportunityLineItem oppLine.PricebookEntry.Product2.Id - ' + oppLine.PricebookEntry.Product2Id);
                                
                Double quantity;
                if(subscription.Subscription_Lines__r[i].Renewal_Quantity__c == null){
                    quantity = subscription.Subscription_Lines__r[i].Quantity__c;
                }else{
                    quantity = subscription.Subscription_Lines__r[i].Renewal_Quantity__c;
                }
                // Case 6704 - quantity assignment for Subscription Lines
                system.debug('RSB subscription.Subscription_Lines__r[i].Id - ' + subscription.Subscription_Lines__r[i].Id);
                system.debug('RSB MapLineSiteCount Line Exists - ' + MapLineSiteCount.containsKey(subscription.Subscription_Lines__r[i].Id));
                system.debug('RSB MapLineSiteCount Quantity - ' + MapLineSiteCount.get(subscription.Subscription_Lines__r[i].Id));
                if(MapLineSiteCount.containsKey(subscription.Subscription_Lines__r[i].Id))
                {
                    quantity = MapLineSiteCount.get(subscription.Subscription_Lines__r[i].Id);
                }
                // Case 6704

                Subscription_Line__c subLine = new Subscription_Line__c(
                                                        //Product__c = subscription.Subscription_Lines__r[i].Product__c,
                                                        Product__c = MapSubscriptionNewProduct.get(subscription.Subscription_Lines__r[i].id), // Case 6704
                                                        Quantity__c = quantity,
                                                        E_Delivery_Number_of_Licences__c = subscription.Subscription_Lines__r[i].E_Delivery_Number_of_Licences__c,
                                                        //Renewal_Price__c = subscription.Subscription_Lines__r[i].Renewal_Price__c,
                                                        OPL_ID__c = opportunityLineItems[i].Id,
                                                        Product_Sales_Price__c = oppLine.TotalPrice,//  subscription.Subscription_Lines__r[i].Product_Sales_Price__c,
                                                        Subscription__c = newSub.id,
                                                        Previous_Subscription_Line__c = subscription.Subscription_Lines__r[i].Id
                    );
                if (subscription.Subscription_Lines__r[i].Ongoing_Renewal_Price__c != null){
                    
                    subLine.Renewal_Price__c = subscription.Subscription_Lines__r[i].Ongoing_Renewal_Price__c;
                    subLine.Ongoing_Renewal_Price__c = subscription.Subscription_Lines__r[i].Ongoing_Renewal_Price__c;
                }
                
                newSubLines.add(subLine);
                
            }
            System.debug('RSB Inserting newSubLines: '+newSubLines);
            insert newSubLines;
            
            // *** END: CREATE SUBSCRTPTION LINES
            
            // *** START: CREATE SUBSCRTPTION PRODUCTS
            
            // Create MAP of previous_subscription_Line__c, Id
            Map<Id, Id> subLineMap = new Map<Id,Id>();
            for(Subscription_Line__c subline:newSubLines){
                subLineMap.put(subline.Previous_Subscription_Line__c, subline.Id);
            }
            System.debug('RSB subLineMap : ' + subLineMap);

            // Create MAP of previous_subscription_Site__c, Id
            Map<Id, Id> subSiteMap = new Map<Id,Id>();
            for(Subscription_Site__c subSite:newSubSites){
                subSiteMap.put(subSite.Previous_Subscription_Site__c, subSite.Id);
            }           
            System.debug('RSB subSiteMap : ' + subSiteMap);

            List<Site_Product__c> newSubProducts = new List<Site_Product__c>();
            
            for (Site_Product__c siteProduct:subscription.Site_Products__r) {

                if(subLineMap.containsKey(siteProduct.Subscription_Line__c) && subSiteMap.containsKey(siteProduct.Subscription_Site__c))
                {
                    Site_Product__c newSiteProduct = new Site_Product__c
                                                    (
                                                        Alternative_Address__c = siteProduct.Alternative_Address__c,
                                                        Previous_Site_Product__c = siteProduct.Id,
                                                        Site_Product_Contact__c = siteProduct.Site_Product_Contact__c,
                                                        Subscription__c = newSub.Id
                                                    );
                
                    newSiteProduct.Subscription_Line__c = subLineMap.get(siteProduct.Subscription_Line__c);
                    newSiteProduct.Subscription_Site__c = subSiteMap.get(siteProduct.Subscription_Site__c);
                    newSubProducts.add(newSiteProduct);
                }
            }

            system.debug('RSB List<Site_Product__c> newSubProducts - ' + newSubProducts);
            insert newSubProducts;
            update newSubProducts; // Case 6704 - This will update Subscription -> Subscription Sites -> Product code with current products.
            // *** END: CREATE SUBSCRIPTION PRODUCTS



            //String response = createInvoiceFromOpp(opportunity, postInvoice);
            update subscription;

            opportunity.Subscription__c = newSub.id;
            
            update opportunity;
        }
        
        ApexCodePatrol.enable('AccountSubscriptionFlags');
        update subscriptionList;
        
        
        return 'true:No Errors';
    }
    
    /*
     * RUN SUBSCRIPTION RENEWAL: STAGE 2 - CREATE INVOICE
     * 
     * Creates the invoice renewal packs and send/print for customer.
     */
     webservice static String runSubscriptionRenewalInvPacks(Id subscription, boolean postInvoice){
    
        setDefaultValues();
        System.debug('First Post Invoice Value: '+postInvoice);
        
        List<Subscription__c> subscriptionList = new List<Subscription__c>([SELECT
                                                                        Id,
                                                                        Renewal_Reminders__c,
                                                                        End_Date__c,
                                                                        Account_Name__c,
                                                                        Subscription_Manager__c,
                                                                        Account_Name__r.OwnerId,
                                                                        Opportunity__c,
                                                                        Renewal_Sales_Invoice__c,
                                                                        Send_Subscription_by__c,
                                                                        Includes_E_Delivery_Product__c
                                                                    FROM
                                                                        Subscription__c
                                                                    WHERE
                                                                        Id = :subscription]);
        System.debug('runSubscriptionRenewalWithId subList: '+subscriptionList);

        String result = runSubscriptionRenewalInvPacks(subscriptionList, postInvoice);
        
        return result;
    }
    
    /*
     * RUN SUBSCRIPTION RENEWAL: STAGE 2 - CREATE INVOICE & PACKS (Multiple subscriptions)
     * 
     * Creates the invoice renewal packs and send/print for customer.
     */
    public static String runSubscriptionRenewalInvPacks(List<Subscription__c> subscriptionList, Boolean postInvoice){

        setDefaultValues();
        
        String result = 'false';
        if (postInvoice == null){
            postInvoice = false;
        }
        
        List<Subscription__c> subsToUpdate = new List<Subscription__c>();

        // Create invoice
        
        for(Subscription__c sub : subscriptionList){
            Id salesInvoiceId = createInvoiceFromOpp(sub.Opportunity__c, postInvoice);
            System.debug('Sales Invoice ID: '+salesInvoiceId+' Post Invoice? '+postInvoice);
            /*
            if (salesInvoiceId !=null){
                sub.Renewal_Sales_Invoice__c = salesInvoiceId;
                subsToUpdate.add(sub);
            }
            */
            
        }
        //update subsToUpdate;
        
        return result;
    }
    
    /*
     * PRINT REMINDERS
     *
     * Checks to see which subscriptions need reminders created and updates the respected print flags
     * on the subs to fire the workflows to print the packs.
     *
     */
    public static void printReminders(){
        
        setDefaultValues();
        
        // START: Update those subscriptions that need the first reminder printed
        ApexCodePatrol.disable('AccountSubscriptionFlags');
        List<Subscription__c> firstReminderToUpdate = new List<Subscription__c>([SELECT
                Id,
                Print_First_Reminder__c
            FROM
                Subscription__c
            WHERE
                First_Reminder_Date__c <= :Date.TODAY() AND
                First_reminder_sent__c = 'No' AND
                Status__c = 'Pending - Not Paid' AND
                Renewal_Reminders__c = True AND
                Paying_By__c = 'Invoice' AND
                Invoice_Status__c != 'Paid' AND
                (CreatedDate >= 2012-06-11T00:00:00Z AND
                    (
                        (Includes_Membership_Product__c = True OR Includes_Publication_Product__c = True OR Includes_SUSA_Product__c = True) OR
                        (CreatedDate >= 2013-02-11T00:00:00Z AND Includes_RCP_Product__c = True) OR 
                        (CreatedDate >= 2013-05-16T00:00:00Z AND Includes_E_Delivery_Product__c = True)
                    )
                )              
                ]);
            
        for(Subscription__c sub : firstReminderToUpdate){
            sub.Print_First_Reminder__c = True;
        }
        update firstReminderToUpdate;

        // Second Reminder
        List<Subscription__c> secondReminderToUpdate = new List<Subscription__c>([SELECT
                Id,
                Print_Second_Reminder__c
            FROM
                Subscription__c
            WHERE
                Second_Reminder_Date__c <= :Date.TODAY() AND
                Second_reminder_sent__c = 'No' AND
                CreatedDate >= 2012-06-11T00:00:00Z AND
                Status__c = 'Pending - Not Paid' AND
                Renewal_Reminders__c = True AND
                (Includes_Membership_Product__c = True OR Includes_Publication_Product__c = True) AND
                Paying_By__c = 'Invoice' AND
                Invoice_Status__c != 'Paid'
                ]);
            
        for(Subscription__c sub : secondReminderToUpdate){
            sub.Print_Second_Reminder__c = True;
        }
        update secondReminderToUpdate;
        
        // Third Reminder
        List<Subscription__c> thirdReminderToUpdate = new List<Subscription__c>([SELECT
                Id,
                Print_Third_Reminder__c
            FROM
                Subscription__c
            WHERE
                Third_Reminder_Date__c <= :Date.TODAY() AND
                Third_reminder_sent__c = 'No' AND
                CreatedDate >= 2012-06-11T00:00:00Z AND
                Status__c = 'Pending - Not Paid' AND
                Renewal_Reminders__c = True AND
                (Includes_Membership_Product__c = True OR Includes_Publication_Product__c = True) AND
                Paying_By__c = 'Invoice' AND
                Invoice_Status__c != 'Paid'
                ]);
            
        for(Subscription__c sub : thirdReminderToUpdate){
            sub.Print_Third_Reminder__c = True;
        }
        update thirdReminderToUpdate;
        ApexCodePatrol.enable('AccountSubscriptionFlags');
        // END: Update those subscriptions that need the first reminder printed
        
    }

    /*
     * PRIVATE CLASSES
     * 
     */
     
    /*
     * CREATE INVOICE FROM OPP
     *
     * Creates an invoice based on an Opportunity Id
     */
    private static Id createInvoiceFromOpp(Id oppId, Boolean postInvoice){

        Opportunity opp = [SELECT Invoice_Company__r.Name, Create_Invoice__c FROM Opportunity WHERE Id = :oppId][0];
        
        if (opp.Invoice_Company__r.Name == 'Complywise Ltd' && !FinanceHelper.usrInCorrectFFCompany('Complywise Ltd')){
            opp.Create_Invoice__c = true;
            update opp;
            return null;
        }else{
            return FinanceHelper.createInvoiceFromOpp(oppId, postInvoice);      
        }
        
        /*
        setDefaultValues();
        
        Boolean errorOccurred = false;
        Boolean hadQtyOverZero = false;
        Id proformaId;
        
        Opportunity opp = [SELECT Id,
                                    Amount,
                                    AccountId,
                                    Subscription_Start_Date__c,
                                    Subscription__c
                                FROM
                                    Opportunity
                                WHERE
                                    Id = :oppId
                                LIMIT 1][0];
        
        System.debug('Opportunity to create invoice for: '+opp.Id+' for the amount: '+opp.Amount);
        // Check that opportunities exist and have an amount greater than 0:        
        Double totalOppAmount = opp.Amount;

        if(opp.Amount == 0 || opp.Amount == null){
            errorOccurred = true;
        }
        
        //Savepoint sp = Database.setSavepoint();
        
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
        
        if (opp.Subscription_Start_Date__c < Date.today()){
            invoice.DueDate = Date.today();
        }else{
            invoice.DueDate = opp.Subscription_Start_Date__c;
        }
        
        invoice.InvoiceStatus = c2g.CODAAPIInvoiceTypes_4_0.enumInvoiceStatus.InProgress;
        // invoice.Account is NOT the salesforce account object but the FF account (custom FF object record).
        invoice.Account = new c2g.CODAAPICommon.Reference();
        invoice.LineItems = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItems();
        invoice.LineItems.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem>();
        invoice.Opportunity = new c2g.CODAAPICommon.Reference();
        invoice.Opportunity.Id = opp.Id;
        
        // Need to update the quantity invoiced on the opp line to create a list to add lines to, to be updated. 
        List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
        
        // Create Line Items for invoice
        Double totalOppLineAmount = 0.0;
        
        //LineDescription = oppLineItemExt.oppLineItem.Id+';'+subsLineExt.subsLine.Id;
        // Get Subscription lines for opp and add them to line description if required.
        
        Map<Id,Id> oppLineSubLineMap = getOppLineSubLineMap(opp);
        
        for(OpportunityLineItem oppLineItem:[SELECT Id,
                                                Opportunity.AccountId,
                                                Opportunity.Account.c2g__CODADimension1__c,
                                                Opportunity.Tax_Code__c,
                                                PriceBookEntry.Product2.Name,
                                                PriceBookEntry.Product2Id,
                                                PriceBookEntry.Product2.Dimension_2__c,
                                                PriceBookEntry.Product2.Web_Dimension_2__c,
                                                PriceBookEntry.Product2.Renewal_Dimension_1__c,
                                                PriceBookEntry.Product2.Renewal_Dimension_2__c,
                                                OpportunityId,
                                                Quantity,
                                                Set_an_Invoice_Quantity__c, 
                                                Quantity_Invoiced__c,
                                                Quantity_Credited__c,
                                                Website_Tax_Percentage__c,
                                                TotalPrice,
                                                Website_Tax_Amount__c,
                                                UnitPrice 
                                            FROM 
                                                OpportunityLineItem
                                                WHERE Opportunity.Id = :opp.Id])
        {
            Double quantity = 0;
            System.debug('Set an invoice qty: '+oppLineItem.Set_an_Invoice_Quantity__c);
            if(oppLineItem.Set_an_Invoice_Quantity__c == null)
            {
                if(oppLineItem.Quantity_Invoiced__c == null)
                    oppLineItem.Quantity_Invoiced__c = 0;
                if(oppLineItem.Quantity_Credited__c == null)
                    oppLineItem.Quantity_Credited__c = 0;
                
                quantity = oppLineItem.Quantity - oppLineItem.Quantity_Invoiced__c + oppLineItem.Quantity_Credited__c;
            }   
            else{ 
                quantity = oppLineItem.Set_an_Invoice_Quantity__c;
            }
            System.debug('Qty: '+quantity);
            if (quantity != 0){
                
                System.debug('Creating invoice line');
                c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem lineItem = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem();
                lineItem.Product = new c2g.CODAAPICommon.Reference();
                lineItem.Product.Id = oppLineItem.PriceBookEntry.Product2Id;
                lineItem.Quantity = quantity;
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
                
                if (oppLineItem.PriceBookEntry.Product2.Renewal_Dimension_1__c != null){
                    // OPT-759: Use the Renewal Dimension 1 code if its filled out on the product.
                    lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                    lineItem.Dimension1.Id = oppLineItem.PriceBookEntry.Product2.Renewal_Dimension_1__c;
                }else{
                    // Otherwise use the default Dimension 1 code
                    lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                    List<c2g__codaDimension1__c> dimension1 = [Select c.Name, c.Id From c2g__codaDimension1__c c WHERE c.Name = :DEFAULT_DIMENSION_1_NAME LIMIT 1];
                    lineItem.Dimension1.Id = dimension1[0].Id;
                }
                
                // Dimension 2 = Product Dimension code.
                lineItem.Dimension2 = new c2g.CODAAPICommon.Reference();
                lineItem.Dimension2.Id = oppLineItem.PriceBookEntry.Product2.Renewal_Dimension_2__c;
                
                if (quantity > 0){
                    hadQtyOverZero = true;
                }
                invoice.LineItems.LineItemList.add(lineItem);
            }

            invoice.Account.Id = oppLineItem.Opportunity.AccountId;
            System.debug('opplineItem.Opp.AccountId: '+oppLineItem.Opportunity.AccountId);
            
        }
        // Update OppLines
        //update oppLinesToUpdate;
                
        //Specify the company to consider
        c2g.CODAAPICommon_4_0.Context context = new c2g.CODAAPICommon_4_0.Context();
        if(!isTest)
        {
            List<String> companyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
            context.CompanyName = companyName.get(0);
            if (context.CompanyName == null){
                context.CompanyName = FF_COMPANY_NAME_CONTEXT;
            }
        }

        if (hadQtyOverZero == false){
            System.debug('In myException');
            throw new myException('Unable to create invoice. No opportunity lines to invoice found');
        }
        
        try {
            if (errorOccurred == false){
                System.debug('Creating Invoice');
                result=c2g.CODAAPISalesInvoice_4_0.CreateInvoice(context, invoice);
                proformaId = result.Id;
                
            }
        }catch(Exception e){
            // error occurred populate error object.
            System.debug('Create Invoice Error: '+e.getMessage());
            errorOccurred = true;
        }
        
        try {
            if (errorOccurred == false){
                c2g__codaInvoice__c updateInvoice = [Select c.Id,c.c2g__CustomerReference__c From c2g__codaInvoice__c c where c.Id =:result.Id];
                updateInvoice.Post_Invoice_at__c = datetime.now()+POST_INVOICE_IN;
                update updateInvoice;
            }
        // Posting of the invoice is done in the trigger code.
            
        }catch(Exception e){
            // error occurred populate error object.
            System.debug('Update Invoice Error: '+e.getMessage());
            errorOccurred = true;
        }
        System.debug('Create Subscription Renewal Invoice finished');

        return proformaId;
        
     */   
    }
    
}