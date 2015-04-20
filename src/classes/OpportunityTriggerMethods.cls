public with sharing class OpportunityTriggerMethods{
    /*
Case 00001649 18/03/2011 Invoice Quantities are not being updated
The Account Triggers do not need to fire on this occassion
*/
    static final String DEFAULT_ACCOUNTING_COMPANY = 'British Safety Council';
    
    public class Test_Exception extends Exception{}
    
    
    /*
* SET DEFAULT FIELDS
* 
* Sets the default address fields on creation if the fields haven't been entered already.
*
*/

    public static void updateOpportunityContactField(Map<Id,Opportunity> newMap)
    {
        system.debug('Inside updateOpportunityContactField');
        system.debug('Map<Id,Opportunity> newMap - ' + newMap);

        system.debug('Map<Id> oppMap.keyset - ' + newMap.keyset());
        system.debug('Map<Id> oppMap.values - ' + newMap.values());
        Map<Id,OpportunityContactRole> oppContactRoles = new Map<Id,OpportunityContactRole> ([SELECT ContactId, Id, OpportunityId, IsPrimary, Role 
                                                                    FROM OpportunityContactRole WHERE OpportunityId in :newMap.keyset() AND IsPrimary = true]);
        system.debug('Map<Id,OpportunityContactRole> oppContactRoles - ' + oppContactRoles);
        for(OpportunityContactRole ocr : oppContactRoles.values())
        {
            if(ocr != null)
            {
                Opportunity o = newMap.get(ocr.OpportunityId);
                if(o != null )
                {
                    o.Opportunity_Contact__c = ocr.ContactId;
                }
            }
        }

    }


    public static void setDefaultFields(List<Opportunity> oppList){
        
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        c2g__codaCompany__c accCcompany = [SELECT Id FROM c2g__codaCompany__c WHERE Name = :DEFAULT_ACCOUNTING_COMPANY LIMIT 1][0];
        // @todo loop over oppList to pull out Accounts into list then loop over opps and do lookup to list rather than this hack
        for (Opportunity opp:oppList){
            
            if (opp.AccountId != null){
                Account acc = [SELECT Id,
                               Name,
                               Principle_Address_Building__c,
                               Principle_Address_Street__c,
                               Principle_Address_Area__c,
                               Principle_Address_City__c,
                               Principle_Address_State_Province__c,
                               Principle_Address_ZIP_Postal_Code__c,
                               Principle_Address_Country__c,
                               BillingStreet,
                               BillingCity,
                               BillingState,
                               BillingPostalCode,
                               BillingCountry,
                               c2g__CODAOutputVATCode__c,
                               Exclude_from_Auto_Invoicing__c
                               FROM Account 
                               WHERE Id = :opp.AccountId];
                
                if (''+opp.Billing_Address_Account_Name__c+opp.Billing_Street__c+opp.Billing_State__c+opp.Billing_PostalCode__c+opp.Billing_Country__c+opp.Billing_City__c != ''){
                    opp.Billing_Address_Account_Name__c = acc.Name;
                    //opp.Billing_Address_Building__c = acc.Principle_Address_Building__c;
                    opp.Billing_Street__c = acc.BillingStreet;
                    //Principle_Address_Area__c,
                    opp.Billing_City__c = acc.BillingCity;
                    opp.Billing_State__c = acc.BillingState;
                    opp.Billing_PostalCode__c = acc.BillingPostalCode;
                    opp.Billing_Country__c = acc.BillingCountry;
                }
                if (''+opp.Shipping_Address_Account_Name__c+opp.Shipping_Street__c+opp.Shipping_State__c+opp.Shipping_Postal_Code__c+opp.Shipping_Country__c+opp.Shipping_City__c != ''){
                    opp.Shipping_Address_Account_Name__c = acc.Name;
                    opp.Shipping_Address_Building__c = acc.Principle_Address_Building__c;
                    opp.Shipping_Street__c = acc.Principle_Address_Street__c;
                    opp.Shipping_Area__c = acc.Principle_Address_Area__c;
                    opp.Shipping_City__c = acc.Principle_Address_City__c;
                    opp.Shipping_State__c = acc.Principle_Address_State_Province__c;
                    opp.Shipping_Postal_Code__c = acc.Principle_Address_ZIP_Postal_Code__c;
                    opp.Shipping_Country__c = acc.Principle_Address_Country__c;
                }
                if (opp.Tax_Code__c == null){
                    opp.Tax_Code__c = acc.c2g__CODAOutputVATCode__c;
                }
                
                if (acc.Exclude_from_Auto_Invoicing__c){    
                    opp.Do_Not_Auto_Post_SIN_SCR__c = acc.Exclude_from_Auto_Invoicing__c;
                    opp.Exclude_from_Auto_Invoicing__c = acc.Exclude_from_Auto_Invoicing__c;
                }
                
                if (opp.Invoice_Company__c == null){
                    
                    opp.Invoice_Company__c = accCcompany.Id;
                }
            }
        }
    }
    
    //Update Relationship field
    public static void updateAccountFields(List<Opportunity> oppList)
    {
        Set<Id> accId = new Set<Id>();
        for(Opportunity opp:oppList)
        {
            if(opp.isWon || opp.isClosed)
            {   
                accId.add(opp.AccountId);
            }
        }
        if(!accId.isEmpty()) 
        {
            System.debug('Disabling AccountReAssignment');
            //ApexCodePatrol.disable('AccountReAssignment');
            Account_Trigger_Flags__c settings =Account_Trigger_Flags__c.getInstance('Deactivated');
            settings.Account_Assignment_Deactivated__c = true;
            update settings;
            
            List<Account> updateAccount = new List<Account>();
            for(Account acc:[Select Id,Relationship__c from Account where Relationship__c != 'Trader' AND Id IN:accId])
            {
                acc.Relationship__c = 'Trader';
                updateAccount.add(acc);
            }
            if(!updateAccount.isEmpty() )
                update updateAccount;
            
            System.debug('Enabing AccountReAssignment');
            //ApexCodePatrol.enable('AccountReAssignment'); 
            settings.Account_Assignment_Deactivated__c = false;
            update settings;               
        }
        
        
    }
    
    public static void opportunityControl(Map<Id,Opportunity> oppMap){
        Map<Id,Opportunity> oppUdpate = new Map<Id,Opportunity>();
        
        set<id> oppIds = oppMap.keySet();
        
/*        
        list<opportunity> oppList = [select Name,
                                     Opportunity_Number__c,
                                     id,
                                     (select UnitPrice, Quantity_Credited__c, Quantity_Invoiced__c, OpportunityId,  Quantity_Paid__c, Quantity, Number_of_Delegates__c, pricebookentry.product2.No_Event__c, pricebookentry.product2.Name, pricebookentry.product2.Subscription_Product__c, pricebookentry.product2.Core_Subscription_Product__c from OpportunityLineItems),
                                     (select id, Name, Special_Event__c, Special_Event__r.Status__c, OPL_ID__c,Status__c, Primary_Booking__c, Booking_Fee__c,Type__c, Event_Start_Date__c from BSC_Event_Bookings__r) ,
                                     (select id, Name, Special_Event__c, Special_Event__r.Status__c, OPL_ID__c,Status__c, Primary_Booking__c, Booking_Fee__c,Type__c, Event_Start_Date__c, Available_places_on_event__c, Opp_ID__c, Opportunity__c, Opportunity_ID__c, Product__c, Product_ID__c, RecordTypeId, Special_Event__r.Minimum_Places__c, Special_Event__r.Maximum_Places__c, Special_Event__r.Allow_Overbooking__c, Special_Event__r.No_of_Delegates_Booked__c, Special_Event__r.Provisional_Bookings__c, Special_Event__r.Total_Booking__c, Special_Event__r.Available_places__c, Special_Event__r.RecordTypeId from BSC_Event_Bookings__r) ,
                                     (select id from Subscriptions__r where Status__c like 'Current%' or Status__c like 'Pending%') ,
                                     RecordType.Name,
                                     isWon,
                                     Invoiced_Total__c,
                                     StageName,
                                     Credited_Total__c,
                                     Using_one_to_one_invoicing__c,
                                     Account.c2g__CODAAccountsReceivableControl__c,
                                     Account.c2g__CODAOutputVATCode__c,
                                     Account.c2g__CODATaxCalculationMethod__c,
                                     Account.c2g__CODAVATStatus__c, Owner.Name
                                     from opportunity 
                                     where id in :oppIds and 
                                     (Is_Cancelled__c = false and Is_Transferred__c = false) and 
                                     Bypass_Opp_Controls__c = false ];
*/
        list<opportunity> oppList = [select Name,
                                     Opportunity_Number__c,
                                     id,
                                     (select UnitPrice, Quantity_Credited__c, Quantity_Invoiced__c, OpportunityId,  Quantity_Paid__c, Quantity, Number_of_Delegates__c, pricebookentry.product2.No_Event__c, pricebookentry.product2.Name, pricebookentry.product2.Subscription_Product__c, pricebookentry.product2.Core_Subscription_Product__c from OpportunityLineItems),
                                     (select id, Name, Special_Event__c, Special_Event__r.Status__c, OPL_ID__c,Status__c, Primary_Booking__c, Booking_Fee__c,Type__c, Event_Start_Date__c, Available_places_on_event__c, Opp_ID__c, Opportunity__c, Opportunity_ID__c, Product__c, Product_ID__c, RecordTypeId, Special_Event__r.Name, Special_Event__r.Minimum_Places__c, Special_Event__r.Maximum_Places__c, Special_Event__r.Allow_Overbooking__c, Special_Event__r.No_of_Delegates_Booked__c, Special_Event__r.Provisional_Bookings__c, Special_Event__r.Total_Booking__c, Special_Event__r.Available_places__c, Special_Event__r.RecordTypeId from BSC_Event_Bookings__r) ,
                                     (select id from Subscriptions__r where Status__c like 'Current%' or Status__c like 'Pending%') ,
                                     RecordType.Name,
                                     isWon,
                                     Invoiced_Total__c,
                                     StageName,
                                     Credited_Total__c,
                                     Using_one_to_one_invoicing__c,
                                     Account.c2g__CODAAccountsReceivableControl__c,
                                     Account.c2g__CODAOutputVATCode__c,
                                     Account.c2g__CODATaxCalculationMethod__c,
                                     Account.c2g__CODAVATStatus__c, Owner.Name
                                     from opportunity 
                                     where id in :oppIds and 
                                     (Is_Cancelled__c = false and Is_Transferred__c = false) and 
                                     Bypass_Opp_Controls__c = false ];

        boolean hasErrors = false;
        for (opportunity opp : oppList ){
           
            for (opportunity oppCheck : oppMap.values()){
                
                if (oppCheck.id == opp.id &&
                    (opp.Account.c2g__CODAAccountsReceivableControl__c == null ||
                     opp.Account.c2g__CODAOutputVATCode__c == null ||
                     opp.Account.c2g__CODATaxCalculationMethod__c == null ||
                     opp.Account.c2g__CODAVATStatus__c == null) &&
                    oppCheck.StageName == 'Booking Received'){
                        
                        oppCheck.addError(' The Accounts Receivable Control/Output VAT Code/Tax Calculation Method/Tax Status has not been set on the Account.');
                        hasErrors = true;
                        break;
                    }                
                boolean notHaveCoreSubscriptionProduct = false;
                for(OpportunityLineItem opl : opp.OpportunityLineItems){
                   
                    if (!hasErrors && 
                        (oppCheck.StageName == 'Booking Received') && 
                        opp.Subscriptions__r.size() == 0  && 
                        opp.RecordType.Name == 'Subscription' && 
                        oppCheck.id == opp.id &&
                        opl.pricebookentry.product2.Core_Subscription_Product__c == true &&
                        notHaveCoreSubscriptionProduct == false) {
                            
                            notHaveCoreSubscriptionProduct = true; 
                            break;
                    }
                                    
                    if (!hasErrors && 
                        (oppCheck.StageName == 'Booking Received') && 
                        opp.BSC_Event_Bookings__r.size() == 0 && 
                        (opp.RecordType.Name == 'Public Event' || opp.RecordType.Name == 'In-Company Event') && 
                        oppCheck.id == opp.id && 
                        opl.pricebookentry.product2.No_Event__c == false){
                            
                            string error = ' Product \'' + opl.pricebookentry.product2.Name + '\' requires you set Events/Bookings for OPP: ' + opp.Opportunity_Number__c + ' before you change the stage to ' + oppCheck.StageName;
                            oppCheck.addError(error);
                            hasErrors = true;
                            break;
                        }
                }
                
                if (notHaveCoreSubscriptionProduct == true && opp.RecordType.Name == 'Subscription' && oppCheck.StageName == 'Booking Received' ) {
                    string error = ' You should have a Core Subscription Product for OPP: ' + opp.Opportunity_Number__c + ' before you change the stage to ' + oppCheck.StageName + ' and have atleast 1 Subscription' ;
                    hasErrors = true;
                    oppCheck.addError(error);
                }
                
                if (oppCheck.StageName == 'Lost' && opp.StageName != 'Lost' && oppCheck.id == opp.id && !hasErrors){
                    for (Special_Event_Booking__c booking : opp.BSC_Event_Bookings__r){
                        if (booking.Status__c == 'Provisional'  ||
                            booking.Status__c == 'No Show'  ||
                            booking.Status__c == 'Confirmed' ||
                            booking.Status__c == 'Attended'  ||
                            booking.Status__c == 'No Show' ||
                            booking.Status__c == 'Attended - Fail' ||
                            booking.Status__c == 'Attended - Pass' ||
                            booking.Status__c == 'Attended - Merit' ||
                            booking.Status__c == 'Attended - Distinction'){
                                oppCheck.addError(' There are bookings on this Opportunity that stop moving the stage to Lost. Please use Transfer and Cancellation Process to move the Bookings and then Change the stage of this opp to Lost.');
                                hasErrors = true;
                                break;
                            }
                    }
                }
               
                if (!hasErrors)
                    if (oppCheck.id == opp.id && (oppcheck.StageName == 'Booking Received' || oppcheck.StageName == 'Customer Approved')){
                        
                        Map<String, set<id>> countEvtProd = new Map<String, set<id>>();
                        Map<String, Double> countPubEvent = new Map<String, Double>();
                        Map<String, Double> countInCoDelegate = new Map<String, Double>();
                        
                        map<id, map<id,double>> incoCheck = new map<id, map<id,double>>();
                        boolean sendMail = false;
                        // This part is added to check if events are overbooked and Stage is chnaged to 'Customer Approved' - Rahul
                        Map<ID, Decimal> uniqEventIds = new Map<ID, Decimal> ();
                        String spEventName;
                        if (!hasErrors)
                        {
                            for(Special_Event_Booking__c booking : opp.BSC_Event_Bookings__r)
                            {
                                    uniqEventIds.put(booking.Special_Event__c, booking.Special_Event__r.Available_places__c);
                            }

                            for(ID id : uniqEventIds.keyset())
                            {
                                Integer provisionalBookingCount = 0;
                                for(Special_Event_Booking__c booking : opp.BSC_Event_Bookings__r)
                                {
                                    if(id == booking.Special_Event__c && booking.Status__c == 'Provisional')
                                    {
                                        provisionalBookingCount++;
                                        spEventName = booking.Special_Event__r.name;
                                    }
                                }
                                
                                if(provisionalBookingCount > uniqEventIds.get(id))
                                {
                                    oppCheck.addError('No of Provisional Bookings (' + provisionalBookingCount + ') are more than Available Spaces (' + uniqEventIds.get(id) + ') on Event - ' + spEventName);
                                    hasErrors = true;
                                    break;
                                }
                            }
                        }
                        // End of This part, added to check if events are overbooked and Stage is chnaged to 'Customer Approved' - Rahul

                        for (Special_Event_Booking__c booking : opp.BSC_Event_Bookings__r){

                            boolean foundOPL = false;
                            for (OpportunityLineItem opl : opp.OpportunityLineItems){
                                
                                if (string.valueOf(opl.id) == booking.OPL_ID__c){
                                    foundOPL = true;
                                }
                            }
                            
                            if (foundOPL == false){
                                oppCheck.addError(' Booking ' +booking.name + ' is not linked to a valid Product.');
                                hasErrors = true;
                                break;
                            }
                            
                            if (!hasErrors && 
                                (booking.Special_Event__r.Status__c != 'Confirmed' && (booking.Special_Event__r.Status__c !='Completed' && oppCheck.Using_one_to_one_invoicing__c == 'No') ) && 
                                (oppcheck.StageName == 'Booking Received') && 
                                (oppCheck.Is_Transferred__c == false && oppCheck.Is_Cancelled__c == false) ){
                                    oppCheck.AddError(' The Event related to booking ' + booking.Name + ' must be confirmed before you set the Opportunity stage to Booking Received.');
                                    hasErrors = true;
                            }
                            
                            //kims request case : 6263
                            if (!hasErrors && 
                                (booking.Special_Event__r.Status__c == 'Requested' || booking.Special_Event__r.Status__c == 'Allocating' || booking.Special_Event__r.Status__c == 'Agreed' ) && 
                                (oppcheck.StageName == 'Customer Approved' || oppcheck.StageName == 'Booking Received') && 
                                oppCheck.Is_Transferred__c == false && oppCheck.Is_Cancelled__c == false ){
                                    oppCheck.AddError(' The Event related to booking ' + booking.Name + ' must be Resourced before you set the Opportunity stage to ' + oppcheck.StageName);
                                    hasErrors = true;
                            }
                            
                            
                            //THIS CONTROL CHECK IS FOR PUBLIC AND INCOMPANY EVENTS
                            if (!hasErrors){
                                if (booking.Status__c != 'Confirmed' && booking.Status__c != 'Attended' && booking.Status__c != 'No Show' && oppcheck.StageName == 'Booking Received'){
                                    
                                    system.debug('booking.Status__c '+booking.Status__c);
                                    system.debug('oppcheck.StageName '+oppcheck.StageName);
                                    if (oppcheck.StageName == 'Customer Approved' && booking.Status__c != 'Provisional' )
                                        oppCheck.AddError(' All Bookings must be provisional before this opportunity is advanced to Customer Approved.');
                                    else
                                        oppCheck.AddError(' All Bookings must be Confirmed before this opportunity is advanced to ' + oppCheck.StageName);
                                    
                                    hasErrors = true;
                                    break;
                                }
                            }
                            if (!hasErrors)
                                for(OpportunityLineItem opl : opp.OpportunityLineItems){
                                    if (booking.Booking_Fee__c > 0 && booking.Primary_Booking__c == false && booking.type__c != 'Public'){
                                        oppCheck.addError(' Cannot set Booking Fee on NON primary booking: ' + booking.Name );
                                        hasErrors = true;
                                    }
                                    
                                    if (string.valueof(opl.id) == booking.OPL_ID__c && booking.Booking_Fee__c != opl.UnitPrice && 
                                        ((booking.Primary_Booking__c == true && opp.RecordType.Name == 'In-Company Event') || opp.RecordType.Name == 'Public Event')){
                                            oppCheck.addError(' The unit price on the booking ' + booking.Name + ' does not match the Sales Price on the product.');
                                            hasErrors = true;
                                        }
                                }
                            
                            if (!hasErrors)
                                if(opp.RecordType.Name == 'In-Company Event'){
                                    
                                    if (!incoCheck.containsKey(booking.OPL_ID__c)){
                                        map<id,double> m = new map<id,double>();
                                        m.put(booking.Special_Event__c, 1);
                                        incoCheck.put(booking.OPL_ID__c, m);
                                        
                                    } else {
                                        map<id,double> m = incoCheck.get(booking.OPL_ID__c);
                                        
                                        if (m.containsKey(booking.Special_Event__c)){
                                            m.put(booking.Special_Event__c, m.get(booking.Special_Event__c) + 1);
                                            incoCheck.put(booking.OPL_ID__c, m);
                                        } else{
                                            m.put(booking.Special_Event__c, 1);
                                            incoCheck.put(booking.OPL_ID__c, m);
                                        }
                                    }
                                    
                                }
                            
                            if (!hasErrors)
                                if (opp.RecordType.Name == 'Public Event'){
                                    if(!countPubEvent.containsKey(booking.OPL_ID__c))
                                        countPubEvent.put(booking.OPL_ID__c, 1);
                                    else 
                                        countPubEvent.put(booking.OPL_ID__c, countPubEvent.get(booking.OPL_ID__c) + 1 );
                                }
                            
                            if (!hasErrors && oppcheck.StageName == 'Customer Approved'){
                                Integer daysBetween = date.today().daysBetween(booking.Event_Start_Date__c);
                                if (daysBetween < 21 && daysBetween > 0)
                                    sendmail = true;                          
                            }
                        }
                        
                        if (sendmail){
                            string subject = 'Late Course Booking Opp:'+ opp.Opportunity_Number__c ;
                            
                            string body = 'Dear Operations, '+  
                                '\r\n \r\n' + 
                                UserInfo.getName() + ' has just put ' + opp.Opportunity_Number__c + ' to customer approved, this is due to happen in less than 21 days' +
                                '\r\n \r\n' + 
                                'Please process this to Booking Received and ensure the course note have been ordered if required.' + 
                                '\r\n \r\n' + 
                                'Please also advise any full time trainers and the Learning Zone Coordinator as required.' + 
                                '\r\n \r\n' + 
                                'Thanks';
                            
                            string[] toEmail = new string[1];
                            toEmail[0] = 'operations.inbox@britsafe.org';
                            Utilities.SendEmail(body, subject, toEmail);
                        }
                        system.debug('incoCheck: '+incoCheck);
                        
                        if (!hasErrors)
                            if(opp.RecordType.Name == 'In-Company Event'){
                                for(OpportunityLineItem opl : opp.OpportunityLineItems){
                                    if (incoCheck.containsKey(opl.id)){
                                        map<id,double> bkgs = incoCheck.get(opl.id);
                                        for (double delegate : bkgs.values()){
                                            if (delegate != opl.Number_of_Delegates__c){
                                                oppCheck.AddError(' Number of Delegates and number of Bookings do not match for OPL');
                                                hasErrors = true;
                                                break;
                                            }
                                        }
                                        
                                        if (opl.quantity != bkgs.size())
                                            oppCheck.addError(' You have more events than the number of quantity on the Product' );
                                    }
                                }
                            }
                        
                        if (!hasErrors)
                            if (opp.RecordType.Name == 'Public Event'){
                                for(OpportunityLineItem opl : opp.OpportunityLineItems){
                                    if (countPubEvent.containsKey(string.valueOf(opl.id)) ){
                                        if(countPubEvent.get(opl.Id) != opl.quantity ){
                                            oppCheck.AddError(' Quantity on Product and number of Bookings do not match.');
                                            hasErrors = true;
                                        }
                                    }
                                } 
                            }
                    }
            }
        }
    }
    
    public static void updateOpportunityFields(Map<Id,Opportunity> oppMap)
    {    
        // Set values to 0
        for(Opportunity opp:oppMap.values())
        {
            if(opp.isWon)
            {   opp.Invoiced_Total__c = 0;
             opp.Paid_Total__c = 0;
             opp.Credited_Total__c  = 0;
            }
        }      
        Map<Id,Double> countInvoiced = new Map<Id,Double>();
        Map<Id,Double> countQuantity = new Map<Id,Double>();
        Map<Id,Double> countPaid = new Map<Id,Double>();
        Map<Id,Double> countCredited = new Map<Id,Double>();
        
        
        for(OpportunityLineItem lineItem:[Select UnitPrice,
                                          Quantity_Credited__c,
                                          Quantity_Invoiced__c,
                                          OpportunityId, 
                                          Quantity_Paid__c, 
                                          Quantity from OpportunityLineItem 
                                          where OpportunityId IN:oppMap.keySet()
                                         ]) 
        {
            if(oppMap.containsKey(lineItem.OpportunityId))
            {
                if(oppMap.get(lineItem.OpportunityId).isWon)
                {       
                    if(lineItem.Quantity_Invoiced__c!=null)
                    {
                        //Sum up Opportunity Product Lines Quantity Invoiced
                        if(!countInvoiced.containsKey(lineItem.OpportunityId))
                            countInvoiced.put(lineItem.OpportunityId,lineItem.Quantity_Invoiced__c);
                        else{
                            Double quantity = countInvoiced.get(lineItem.OpportunityId);
                            quantity += lineItem.Quantity_Invoiced__c;
                            countInvoiced.put(lineItem.OpportunityId,quantity);
                        }
                        
                        //Calculate invoiced total 
                        if(lineItem.UnitPrice!=null) {      
                            Double credited = 0;
                            if (lineItem.Quantity_Credited__c != null){
                                credited = lineItem.Quantity_Credited__c;
                            }                                                               
                            System.debug('FJP before: '+oppMap.get(lineItem.OpportunityId).Invoiced_Total__c);
                            oppMap.get(lineItem.OpportunityId).Invoiced_Total__c += lineItem.UnitPrice * (lineItem.Quantity_Invoiced__c - credited);
                            System.debug('FJP after: '+oppMap.get(lineItem.OpportunityId).Invoiced_Total__c);
                            System.debug('FJP it:'+oppMap.get(lineItem.OpportunityId).Invoiced_Total__c+' up:'+lineItem.UnitPrice+' qi:'+lineItem.Quantity_Invoiced__c);                     
                        }
                        
                    }else{
                        
                        if(!countInvoiced.containsKey(lineItem.OpportunityId))
                            countInvoiced.put(lineItem.OpportunityId,0);                   
                        
                    }
                    
                    if(lineItem.Quantity_Paid__c!=null)
                    {
                        //Sum up Opportunity Product Lines Quantity Paid
                        if(!countPaid.containsKey(lineItem.OpportunityId))
                            countPaid.put(lineItem.OpportunityId,lineItem.Quantity_Paid__c);
                        else{
                            Double quantity = countPaid.get(lineItem.OpportunityId);
                            quantity += lineItem.Quantity_Paid__c;
                            countPaid.put(lineItem.OpportunityId,quantity);
                        }
                        
                        //Calculate paid total  
                        if(lineItem.UnitPrice!=null) 
                            oppMap.get(lineItem.OpportunityId).Paid_Total__c += lineItem.UnitPrice * lineItem.Quantity_Paid__c; 
                    }else{
                        
                        if(!countPaid.containsKey(lineItem.OpportunityId))
                            countPaid.put(lineItem.OpportunityId,0);
                        
                    }
                    
                    //Sum up Opportunity Product Lines Quantity
                    if(!countQuantity.containsKey(lineItem.OpportunityId))
                        countQuantity.put(lineItem.OpportunityId,lineItem.Quantity);
                    else{
                        Double quantity = countQuantity.get(lineItem.OpportunityId);
                        quantity += lineItem.Quantity;
                        countQuantity.put(lineItem.OpportunityId,quantity);
                    }
                    
                    //Calculate credited total 
                    if(lineItem.Quantity_Credited__c!=null){
                        oppMap.get(lineItem.OpportunityId).Credited_Total__c += lineItem.UnitPrice * lineItem.Quantity_Credited__c;
                        
                        //Sum up Opportunity Product Lines Quantity Credited
                        if(!countCredited.containsKey(lineItem.OpportunityId))
                            countCredited.put(lineItem.OpportunityId,lineItem.Quantity_Credited__c);
                        else{
                            Double quantity = countCredited.get(lineItem.OpportunityId);
                            quantity += lineItem.Quantity_Credited__c;
                            countCredited.put(lineItem.OpportunityId,quantity);
                        }
                        
                        
                    }
                    
                }          
            }  
            
        }
        
        system.debug('countInvoiced : ' +countInvoiced );
        system.debug('countPaid : ' + countPaid);
        system.debug('countCredited : ' +countCredited );
        system.debug('countQuantity : ' +countQuantity );
        
        for(Opportunity opp:oppMap.values())
        {   
            system.debug('opp.Using_one_to_one_invoicing__c: '+opp.Using_one_to_one_invoicing__c);
            
            if (opp.Using_one_to_one_invoicing__c == 'No'){
                if(countInvoiced.containsKey(opp.Id)){   
                    if(countPaid.containsKey(opp.Id) && countPaid.get(opp.Id) == countQuantity.get(opp.Id)){
                        system.debug('1');
                        opp.StageName  = 'Paid';
                        opp.Invoice_Paid_Date__c = Date.today();
                    } else if(countPaid.get(opp.Id)> 0 && countPaid.get(opp.Id) < countQuantity.get(opp.Id)){
                        system.debug('2');
                        opp.StageName  = 'Part Paid';
                    } else if(countInvoiced.get(opp.Id) > 0 && countInvoiced.get(opp.Id) < countQuantity.get(opp.Id)) {
                        system.debug('3');
                        opp.StageName  = 'Part Invoiced';
                    } else {
                        if(countQuantity.containsKey(opp.Id)&& (countInvoiced.get(opp.Id) - countCredited.get(opp.Id)) == countQuantity.get(opp.Id) ){
                            system.debug('4');
                            opp.StageName  = 'Invoiced';
                        } else if(countInvoiced.get(opp.Id) == 0 ) {
                            system.debug('5');
                            opp.StageName = 'Booking Received'; 
                        }
                    }
                }
            } else if (opp.Using_one_to_one_invoicing__c == 'Yes'){
                // Change the stage based on the opportunity using one to one invoicing.
                if(countInvoiced.containsKey(opp.Id))
                {   
                    if(countPaid.containsKey(opp.Id) && countPaid.get(opp.Id) == countQuantity.get(opp.Id)){
                        opp.StageName  = 'Paid';
                        opp.Invoice_Paid_Date__c = Date.today();
                    } else {
                        
                        if(countQuantity.containsKey(opp.Id)&& (countInvoiced.get(opp.Id) - countCredited.get(opp.Id)) == countQuantity.get(opp.Id) )
                            opp.StageName  = 'Invoiced';
                        else if(countInvoiced.get(opp.Id) == 0)
                            opp.StageName = 'Booking Received'; 
                    }
                    system.debug('opp1.StageName : ' +opp.StageName );
                }
            }
        }
    }

   public static testMethod void TestOpportunityTriggerMethods_1()
   {
       Account acc = new Account (
           Name = 'Test Acc',
           Principle_Address_Building__c = 'BuildingTest',
           BillingStreet = 'StreetTest',
           Phone = '00000',
           Exclude_from_Auto_Invoicing__c = true
       );
       insert acc;
       
       Contact NewContact= new Contact(
           LastName='Test SSCreation Contact', 
           Email='testy13213@fffp.com', 
           FirstName = 'Test', 
           Salutation = 'Mr',
           AccountId=acc.id
       );
       insert NewContact;

       RecordType rt = [SELECT Id, DeveloperName, SobjectType FROM RecordType where DeveloperName = 'Public_Event' and sObjectType = 'Opportunity' limit 1];
       
       Opportunity opp = new Opportunity(
           AccountId = acc.Id,
           Name = 'Test Opp',
           StageName = 'Qualifying',
           recordtypeid = rt.id,
           IC_Price_Variation_Approved__c = true,
           Price_Approval_Given__c = true,
           CloseDate = System.today());
       insert opp;
       
       Product2 prod = new Product2(
           Name = 'Test Event Product',
           Allows_Provisional_Bookings__c = true);
       insert prod;
       
       Pricebook2 stdPricebook = [
           SELECT
           Id
           FROM
           Pricebook2
           WHERE
           IsStandard = true Limit 1];
       
       PricebookEntry pbe = new PricebookEntry(
           Product2Id = prod.Id,
           UnitPrice = 300,
           Pricebook2Id = stdPricebook.Id,
           IsActive = true);
       insert pbe;
       
       Special_Event__c specialEvent1 = new Special_Event__c(
           Opportunity__c = opp.Id,
           Name = 'oppcont 1',
           Product__c = prod.Id,
           Type__c = 'In-Company Training',
           Status__c = 'Allocating',
           Stage__c = 'Provisional',
           StartDate__c = Date.today(),
           EndDate__c = Date.today().addDays(5));
       insert specialEvent1;
       
     
       System.debug('@' + opp.isWon + '@' + opp.HasOpportunityLineItem);
       update opp;
       System.debug('@@' + opp.isWon + '@@' + opp.HasOpportunityLineItem);
       OpportunityLineItem lineItem = new OpportunityLineItem (
           OpportunityId= opp.Id,
           PriceBookEntryId = pbe.Id,
           UnitPrice = 500,
           Quantity = 1,
           Quantity_Invoiced__c = 2,
           Quantity_Paid__c = 1,
           Quantity_Credited__c = 1);
       
       insert lineItem ;
       
       OpportunityLineItem lineItem2 = new OpportunityLineItem (
           OpportunityId= opp.Id,
           PriceBookEntryId = pbe.Id,
           UnitPrice = 500,
           Quantity = 1,
           Quantity_Invoiced__c = 2,
           Quantity_Paid__c = 1,
           Quantity_Credited__c = 1);
       
       insert lineItem2 ;
       
       // CREATE BSC EVENT BOOKING
       Special_Event_Booking__c specialEventbooking1 = new Special_Event_Booking__c(
           Opportunity__c = opp.Id,
           Booking_Fee__c =  10000,
           Special_Event__c = specialEvent1.Id,
           Type__c = 'Public',
           status__c = 'Provisional'
       );
       insert specialEventbooking1;
       
       Special_Event_Booking__c specialEventbooking2 = new Special_Event_Booking__c(
           Opportunity__c = opp.Id,
           Booking_Fee__c =  10000,
           Special_Event__c = specialEvent1.Id,
           Type__c = 'Public',
           status__c = 'Provisional'
       );
       insert specialEventbooking2;

       OpportunityTriggerMethods.updateOpportunityFields(new Map<Id,Opportunity>([Select Id,
                                                                                  Invoiced_Total__c,
                                                                                  IsWon,
                                                                                  HasOpportunityLineItem,
                                                                                  Using_one_to_one_invoicing__c,
                                                                                  Paid_Total__c,
                                                                                  Credited_Total__c
                                                                                  from Opportunity where Id=:opp.Id limit 1]));
       OpportunityTriggerMethods.setDefaultFields(new List<Opportunity>([Select Id,
                                                                         Invoiced_Total__c,
                                                                         IsWon,
                                                                         AccountId,
                                                                         HasOpportunityLineItem,
                                                                         Using_one_to_one_invoicing__c,
                                                                         Paid_Total__c,
                                                                         Credited_Total__c,
                                                                         Billing_Address_Account_Name__c,
                                                                         Billing_Street__c,
                                                                         Billing_State__c,
                                                                         Billing_PostalCode__c,
                                                                         Billing_Country__c,
                                                                         Billing_City__c ,
                                                                         Shipping_Address_Account_Name__c,
                                                                         Shipping_Street__c,
                                                                         Shipping_State__c,
                                                                         Shipping_Postal_Code__c,
                                                                         Shipping_Country__c,
                                                                         Shipping_City__c 
                                                                         from Opportunity where Id=:opp.Id]));

       System.debug('Opportunity opp - ' + opp);
        test.starttest();
       try{
           
           opp.StageName = 'Booking Received';
           opp.Probability = 100;
           update opp;
       } catch (System.DmlException e) {}    
       
       try{
           specialEventbooking1.OPL_ID__c = lineItem.Id;
           specialEventbooking1.Opportunity__c = null;
           update specialEventbooking1;
           
           specialEventbooking2.OPL_ID__c = lineItem2.Id;
           specialEventbooking2.Opportunity__c = null;
           
           update specialEventbooking2;
           update opp;
       } catch (System.DmlException e) {}    
       
       specialEventbooking1.Opportunity__c = opp.id;
       update specialEventbooking1;
       specialEventbooking2.Opportunity__c = opp.id;
       update specialEventbooking2;
       
       try{
           opp.StageName = 'Booking Received';
           opp.Probability = 100;
           update opp;
       } catch (System.DmlException e) {}    
       
       specialEventbooking1.status__c = 'Provisional';
       update specialEventbooking1;
       
       specialEventbooking2.status__c = 'Provisional';
       update specialEventbooking2;

       try{
           opp.StageName = 'Booking Received';
           opp.Probability = 100;
           update opp;
       } catch (System.DmlException e) {}    
       
       specialEventbooking1.status__c = 'Confirmed';
       update specialEventbooking1;
       specialEventbooking2.status__c = 'Confirmed';
       update specialEventbooking2;
       
       specialEvent1.Status__c = 'Confirmed';
       specialEvent1.Stage__c = 'Confirmed';
       update specialEvent1;
       
       lineitem.Quantity_Invoiced__c = 0;
       lineitem.Quantity_Paid__c = 0;
       lineitem.Quantity_Credited__c = 0;
       update lineitem;
       
       lineitem2.Quantity_Invoiced__c = 0;
       lineitem2.Quantity_Paid__c = 0;
       lineitem2.Quantity_Credited__c = 0;
       update lineitem2;
       
       try{     
           opp.StageName = 'Booking Received';
           opp.Probability = 100;
           update opp;
       } catch (System.DmlException e) {}    
       
       try{
           lineitem.Quantity_Invoiced__c = 1;
           lineitem.Quantity_Paid__c = 0;
           lineitem.Quantity_Credited__c = 0;
           update lineitem;
           
           lineitem2.Quantity_Invoiced__c = 1;
           lineitem2.Quantity_Paid__c = 0;
           lineitem2.Quantity_Credited__c = 0;
           update lineitem2;
           
       } catch (System.DmlException e) {} 
       
       try{    
           opp.StageName = 'Booking Received';
           opp.Probability = 100;
           update opp;
       } catch (System.DmlException e) {} 
       lineItem.quantity = 1;
       update lineitem;
       
       lineItem2.quantity = 1;
       update lineitem2;
       
       try{ 
           opp.StageName = 'Booking Received';
           opp.Probability = 100;
           update opp;
       } catch (System.DmlException e) {} 
       
       try{
           opp.StageName = 'Lost';
           update opp;
       } catch (System.DmlException e) {}

       try{ 
           opp.StageName = 'Customer Approved';
           execControl.stopOppControls = false;
           update opp;
       } catch (System.DmlException e) {} 

       try{ 
           opp.StageName = 'Booking Received';
           execControl.stopOppControls = false;
           acc.c2g__CODAOutputVATCode__c = null;
           update acc;
           update opp;
       } catch (System.DmlException e) {}
        test.stoptest();
   } 

    public static testmethod void TestOpportunityTriggerMethods_2()
    {
        Account acc = new Account(name = 'BSC Test');
        acc.Exclude_from_Auto_Invoicing__c = true;
        insert acc;
        system.debug('Account acc - ' + acc);
        
        Contact cont = new Contact (FirstName = 'BSC', LastName = 'Test', Accountid = acc.id);
        insert cont;
        system.debug('Contact cont - ' + cont);

        RecordType rt = [SELECT Id, DeveloperName, SobjectType FROM RecordType where DeveloperName = 'In_Company_Event' and sObjectType = 'Opportunity' limit 1];
        RecordType rt1 = [SELECT Id, DeveloperName, SobjectType FROM RecordType where DeveloperName = 'Subscription' and sObjectType = 'Opportunity' limit 1];

        Opportunity opp = new Opportunity(
            Name = 'BSC Test',
            RecordTypeId = rt.id,
            AccountId = acc.id,
            Type = 'Audit',
            StageName = 'Quote/Proposal',
            IC_Price_Variation_Approved__c = true,
            Price_Approval_Given__c = true,
            Exclude_from_Auto_Invoicing__c = true,
            Do_Not_Auto_Post_SIN_SCR__c = true,
            Use_part_invoicing__c = true,
            CloseDate = System.today());
        insert opp;
        system.debug('Opportunity opp - ' + opp);

        Product2 prod = [select name, Maximum_Discount__c, Allows_Provisional_Bookings__c, Transfer_Charge_Day_1__c, Transfer_Charge_Day_2__c, Transfer_Charge_Day_3__c,
                            family, Event_Record_Type__c, Event_Type__c, No_Event__c, 
                            Transfer_Charge_Fee_1__c, Transfer_Charge_Fee_2__c, Transfer_Charge_Fee_3__c, Transfer_Charge_Fee_Final__c,
                            Transfer_Fee_Product__c
                            from product2 where name = 'Five Star Occupational Health and Safety Audit'];
        system.debug('Product2 prod - ' + prod);
       
       
        Pricebook2 stdPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true and Name = 'Standard Price Book' Limit 1];
        system.debug('Pricebook2 stdPricebook - ' + stdPricebook);       

        PricebookEntry pbe = [SELECT IsActive, UnitPrice, Id, Pricebook2Id, ProductCode, Product2Id, Name, UseStandardPrice 
                                FROM PricebookEntry where Product2Id = :prod.id and Pricebook2Id = :stdPricebook.id];
        system.debug('PricebookEntry pbe - ' + pbe);
                       
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.unitprice,
            Number_of_Delegates__c=1,
            E_Delivery_Number_of_Licences__c = 1,
            In_Company_Number_of_Days__c=1);
        insert oli;
        system.debug('OpportunityLineItem oli - ' + oli);

        Special_Event__c event = new Special_Event__c();
        event.Product__c = prod.Id;
        event.Opportunity__c = opp.id;
        event.Status__c ='Requested';
        event.Stage__c ='Provisional';
        event.StartDate__c = System.today();
        event.Latest_Start_Date__c = system.today();
        event.Audit_Number_of_Days__c = 1;
        event.Minimum_Places__c = 1;
        event.Maximum_Places__c = 1;
        event.Liability_at_Cancellation_Transfer__c = 0;
        insert event;
        system.debug('Special_Event__c event - ' + event);

        Special_Event_Booking__c eventBooking = new Special_Event_Booking__c();
        eventBooking.Opportunity__c = opp.Id;
        eventBooking.Contact__c = cont.id;
        eventBooking.Special_Event__c = event.Id;
        eventBooking.Status__c = 'Provisional';
        eventBooking.OPL_ID__c = oli.id;
        eventBooking.Booking_Fee__c = pbe.unitprice;
        insert eventBooking;
        system.debug('Special_Event_Booking__c eventBooking - ' + eventBooking);               

        Special_Event_Booking__c eventBooking1 = new Special_Event_Booking__c();
        eventBooking1.Opportunity__c = opp.Id;
        eventBooking1.Contact__c = cont.id;
        eventBooking1.Special_Event__c = event.Id;
        eventBooking1.Status__c = 'Provisional';
        eventBooking1.OPL_ID__c = oli.id;
        eventBooking1.Booking_Fee__c = pbe.unitprice;
        insert eventBooking1;
        system.debug('Special_Event_Booking__c eventBooking1 - ' + eventBooking1);

// above new 
        test.starttest();
       try{ 
           opp.StageName = 'Customer Approved';
           execControl.stopOppControls = false;
           update opp;
       } catch (System.DmlException e) {} 

       try{ 
           eventBooking1.Opportunity__c = null;
           update eventBooking1;
           event.StartDate__c = system.today().addDays(22);
           update event;
           opp.StageName = 'Customer Approved';
           execControl.stopOppControls = false;
           update opp;
       } catch (System.DmlException e) {} 

       try{ 
           eventBooking1.Opportunity__c = null;
           update eventBooking1;
           event.StartDate__c = system.today().addDays(22);
           update event;
           opp.StageName = 'Booking Received';
           execControl.stopOppControls = false;
           update opp;
       } catch (System.DmlException e) {} 

       try{ 
           eventBooking.OPL_ID__c = '';
           update eventBooking;
           eventBooking1.OPL_ID__c = '';
           update eventBooking1;
           execControl.stopOppControls = false;
           opp.StageName = 'Customer Approved';
           update opp;
       } catch (System.DmlException e) {} 

       try{ 
           acc.c2g__CODATaxCalculationMethod__c = 'GROSS';
           update acc;
           eventBooking.Opportunity__c = null;
           update eventBooking;
           eventBooking1.Opportunity__c = null;
           update eventBooking1;
           prod.No_Event__c = false;
           update prod;
           opp.StageName = 'Booking Received';
           execControl.stopOppControls = false;
           update opp;
       } catch (System.DmlException e) {} 

       try{ 
           acc.c2g__CODATaxCalculationMethod__c = null;
           update acc;
           eventBooking.Opportunity__c = opp.id;
           update eventBooking;
           eventBooking1.Opportunity__c = opp.id;
           update eventBooking1;
           opp.StageName = 'Booking Received';
           execControl.stopOppControls = false;
           update opp;
       } catch (System.DmlException e) {} 
        test.stoptest();
   } 

    public static testmethod void TestOpportunityTriggerMethods_3()
    {
        Account acc = new Account(name = 'BSC Test');
        acc.Exclude_from_Auto_Invoicing__c = true;
        insert acc;
        system.debug('Account acc - ' + acc);
        
        Contact cont = new Contact (FirstName = 'BSC', LastName = 'Test', Accountid = acc.id);
        insert cont;
        system.debug('Contact cont - ' + cont);

        RecordType rt = [SELECT Id, DeveloperName, SobjectType FROM RecordType where DeveloperName = 'In_Company_Event' and sObjectType = 'Opportunity' limit 1];
        RecordType rt1 = [SELECT Id, DeveloperName, SobjectType FROM RecordType where DeveloperName = 'Subscription' and sObjectType = 'Opportunity' limit 1];

        Opportunity opp = new Opportunity(
            Name = 'BSC Test',
            RecordTypeId = rt.id,
            AccountId = acc.id,
            Type = 'Audit',
            StageName = 'Quote/Proposal',
            IC_Price_Variation_Approved__c = true,
            Price_Approval_Given__c = true,
            Exclude_from_Auto_Invoicing__c = true,
            Do_Not_Auto_Post_SIN_SCR__c = true,
            Use_part_invoicing__c = true,
            CloseDate = System.today());
        insert opp;
        system.debug('Opportunity opp - ' + opp);

        Product2 prod = [select name, Maximum_Discount__c, Allows_Provisional_Bookings__c, Transfer_Charge_Day_1__c, Transfer_Charge_Day_2__c, Transfer_Charge_Day_3__c,
                            family, Event_Record_Type__c, Event_Type__c, No_Event__c, 
                            Transfer_Charge_Fee_1__c, Transfer_Charge_Fee_2__c, Transfer_Charge_Fee_3__c, Transfer_Charge_Fee_Final__c,
                            Transfer_Fee_Product__c
                            from product2 where name = 'Five Star Occupational Health and Safety Audit'];
        system.debug('Product2 prod - ' + prod);
       
       
        Pricebook2 stdPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true and Name = 'Standard Price Book' Limit 1];
        system.debug('Pricebook2 stdPricebook - ' + stdPricebook);       

        PricebookEntry pbe = [SELECT IsActive, UnitPrice, Id, Pricebook2Id, ProductCode, Product2Id, Name, UseStandardPrice 
                                FROM PricebookEntry where Product2Id = :prod.id and Pricebook2Id = :stdPricebook.id];
        system.debug('PricebookEntry pbe - ' + pbe);
                       
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.unitprice,
            Number_of_Delegates__c=1,
            E_Delivery_Number_of_Licences__c = 1,
            In_Company_Number_of_Days__c=1);
        insert oli;
        system.debug('OpportunityLineItem oli - ' + oli);
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = cont.id, IsPrimary = true, Role = 'Sales Contact');
        insert ocr;
        system.debug('OpportunityContactRole ocr - ' + ocr);

        Special_Event__c event = new Special_Event__c();
        event.Product__c = prod.Id;
        event.Opportunity__c = opp.id;
        event.Status__c ='Confirmed';
        event.Stage__c ='Confirmed';
        event.StartDate__c = System.today().addDays(20);
        event.Latest_Start_Date__c = system.today();
        event.Audit_Number_of_Days__c = 1;
        event.Minimum_Places__c = 1;
        event.Maximum_Places__c = 1;
        event.Liability_at_Cancellation_Transfer__c = 0;
        insert event;
        system.debug('Special_Event__c event - ' + event);

        Special_Event_Booking__c eventBooking = new Special_Event_Booking__c();
        eventBooking.Opportunity__c = opp.Id;
        eventBooking.Contact__c = cont.id;
        eventBooking.Special_Event__c = event.Id;
        eventBooking.Status__c = 'Confirmed';
        eventBooking.Type__c = 'Public';
        eventBooking.OPL_ID__c = oli.id;
        eventBooking.Booking_Fee__c = pbe.unitprice;
        insert eventBooking;
        system.debug('Special_Event_Booking__c eventBooking - ' + eventBooking);               

        test.starttest();
       try{ 
           opp.StageName = 'Customer Approved';
           execControl.stopOppControls = false;
           update opp;
       } catch (System.DmlException e) {} 
        test.stoptest();
    }

}