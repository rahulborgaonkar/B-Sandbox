public without sharing class EventApplicationForm {

    Opportunity opp;

    static Boolean isClassVarsSet = false;
    public class myException extends Exception{}
    
    private final String hash;
    public String iWantTo {get;set;}
    public Boolean fatalError {get;private set;}
    private String url = '';
    public String userId {get; private  set;}
    public String currencySymbol {get; private  set;}
    public Boolean confirmTerms {get;set;}
    public String authorisedBy {get;set;}
    public String authorisedPosition {get;set;}
    public String methodofPayment {get;set;}
    public String purchaseOrderReference {get;set;}
    public location [] allLocations {get; set;}
    public Boolean confirmed {public get; private set;}
    public String WorldPayInstallationId {public get; private set;}
    private String WorldPaySecret = 'r3v3ng3';
    
    public Customer_Approval__c custAppr {get; private set;}
    /*
    static Id RECORD_TYPE_PUBLICEVENT =null; // Prod: '012200000001W41AAE';
    static Id RECORD_TYPE_INCOMPANYEVENT = null; // Prod: '012200000001W3IAAU';
    static Id RECORD_TYPE_AUDIT = null; // Prod: '012200000001kwyAAA';
    static Id RECORD_TYPE_MEMBERSHIP = null; // Prod: '012200000001W6WAAU';
    */
    
    /*
     * CONSTRUCTOR
     */
    public EventApplicationForm(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        this.hash = ApexPages.currentPage().getParameters().get('hash');
        this.fatalError = false;
        this.userId = UserInfo.getUserType();
        this.allLocations = getLocations();
        this.fatalError = validateForm();
        this.confirmed = false;
        this.WorldPayInstallationId = '239879';

        List<Customer_Approval__c> customerApprovals = new List<Customer_Approval__c>([SELECT 
                                                                Id
                                                                FROM Customer_Approval__c
                                                                WHERE Opportunity__c = :this.opp.Id]);
        if (customerApprovals.isEmpty()) {
            this.confirmed = false;
        }else{
            this.confirmed = true;
        }

        if (UserInfo.getOrganizationId() == '00D20000000MXUnEAO'){
            // Production org
            this.url = 'http://britishsafetycouncil.force.com/forms/EventApplicationForm';
        }else{
            this.url = 'http://britishsafetycouncil.fftest.cs14.force.com/forms/EventApplicationForm';
        }
        /*
        if (!isClassVarsSet){
            // ** RECORD TYPES
            Boolean foundPubEventRT = false;
            Boolean foundInCompEvtRT = false;
            Boolean foundAuditRT = false;
            Boolean foundMembershipRT = false;
            Integer numOfRTs = 0;
            
            for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE 
                                    DEVELOPERNAME = 'Public_Event' OR 
                                    DEVELOPERNAME = 'In_Company_Event' OR
                                    DEVELOPERNAME = 'Audit' OR
                                    DEVELOPERNAME = 'Subscription']){
                if (rt.DeveloperName == 'Public_Event'){
                    RECORD_TYPE_PUBLICEVENT = rt.Id; // In Prod: 012200000001W41AAE
                    foundPubEventRT = true;
                }
                if (rt.DeveloperName == 'In_Company_Event'){
                    RECORD_TYPE_INCOMPANYEVENT = rt.Id; // In Prod: 012200000001W3IAAU
                    foundInCompEvtRT = true;
                }
                if (rt.DeveloperName == 'Audit'){
                    RECORD_TYPE_AUDIT = rt.Id; // In Prod: 012200000001kwyAAA
                    foundAuditRT = true;
                }
                if (rt.DeveloperName == 'Subscription'){
                    RECORD_TYPE_MEMBERSHIP = rt.Id; // In Prod: 012200000001W6WAAU
                    foundMembershipRT = true;
                }
                numOfRTs++;
            }
            
            if (!foundPubEventRT){
                // Throw exception
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find \'Public_Event\' RecordType');
            }else if (!foundInCompEvtRT){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find \'In_Company_Event\' RecordType');
            }else if (!foundAuditRT){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find \'Audit\' RecordType');
            }else if (!foundMembershipRT){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Unable to find \'Subscription\' RecordType');
            }else if (numOfRTs <> 4){
                throw new myException('SYSTEM DATA INTEGRITY FAULT: Duplicate Record Types with the same name found, unable to determine which one to use');
            }else{
                isClassVarsSet = true;
            }
        }*/
    }

    public class location {
        public Special_Event_Booking__c location {get;private set;}
        public event [] events {get;private set;}
    }

    public class event {
        public Special_Event__c event {get;private set;}
        public Special_Event_Booking__c [] eventBookings {get;private set;}
    }

    /*
     * VALIDATE FORM
     * 
     * Checks to make sure that the opportunity has been filled out correctly and if not gives a fatal error.
     */
    public Boolean validateForm(){
        
        Boolean fatalError = false;
        
        Opportunity opp = [SELECT Owner.Id, Price_Approval_Given__c, 
                                    Discounted_Products__c, 
                                    IC_Price_Difference_Count__c, 
                                    IC_Price_Variation_Approved__c,
                                    T_C_Variation_Approved__c,
                                    T_C_Price_Variation_Products__c,
                                    RecordType.DEVELOPERNAME 
                            FROM 
                                Opportunity
                            WHERE Id = :this.opp.Id LIMIT 1][0];
        
        // START: Check to make sure opp doesn't need approval
        // Check to see if current user is excluded from the approval process if so don't fire any approval errors
        User userDetails = [select Exclude_from_Opp_Approval_Processes__c, Alias from User where id = :opp.Owner.Id];
        
        if((opp.Price_Approval_Given__c == false && opp.Discounted_Products__c != 0) && userDetails.Exclude_from_Opp_Approval_Processes__c == false){
            // Approval is still required, throw error
            fatalError = true;
            String errorText;
            
            if (userDetails.Alias == 'guest'){
                // Give different error message to customer than internal staff (it is possible that approval has been requested multiple
                // times and the possibility that the client clicks the link between the subsequent approval is given).
                errorText = 'This booking form cannot be completed at this time please contact your Account Manager (Awaiting internal approval)';
            }else{
                errorText = 'Unable to continue, Opportunity requires approval (Discounted Products)';
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorText);
            ApexPages.addMessage(myMsg);

        }
        
        if ((opp.IC_Price_Difference_Count__c > 0 && opp.IC_Price_Variation_Approved__c == False) && userDetails.Exclude_from_Opp_Approval_Processes__c == false){
            // Approval is still required, throw error
            fatalError = true;
            if (userDetails.Alias == 'guest'){
                // Give different error message to customer than internal staff (it is possible that approval has been requested multiple
                // times and the possibility that the client clicks the link between the subsequent approval is given).
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This booking form cannot be completed at this time please contact your Account Manager (Awaiting internal approval)');
                ApexPages.addMessage(myMsg);
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to continue, Opportunity requires approval (Price Difference)');
                ApexPages.addMessage(myMsg);
            }
        }
        
        if ((opp.T_C_Variation_Approved__c == False && opp.T_C_Price_Variation_Products__c > 0) && userDetails.Exclude_from_Opp_Approval_Processes__c == false){
            // Approval is still required, throw error
            fatalError = true;
            if (userDetails.Alias == 'guest'){
                // Give different error message to customer than internal staff (it is possible that approval has been requested multiple
                // times and the possibility that the client clicks the link between the subsequent approval is given).
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This booking form cannot be completed at this time please contact your Account Manager (Awaiting internal approval)');
                ApexPages.addMessage(myMsg);
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to continue, Opportunity requires approval (Price Variation)');
                ApexPages.addMessage(myMsg);
            }
        }
        // END: Check to make sure opp doesn't need approval
        
        
        return fatalError;
    }
    
    /****************************
     *    *** VF GETTERS ***    *
     ****************************/

    /*
     * GET OPPORTUNITY TYPE
     *
     * Gets the opportunity record type to allow for changes to the VF page based on different types of
     * opportunity (eg title text etc)
     * 
     */
    public String getOppType(){
        String oppType = 'Unknown';
        Opportunity opp = [SELECT RecordType.Id, RecordType.DEVELOPERNAME FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
        
        return opp.RecordType.DEVELOPERNAME;
    }
    
    /*
     * GET LATEST CUSTOMER APPROVAL
     *
     * Gets the latest customer approval for the opportunity
     * 
     */
    public Customer_Approval__c getCustApproval(){
        
                // Get the latest authorisation information
        Customer_Approval__c[] custApprRec = [SELECT Authorised_By__c, 
                                Authorised_Position__c,
                                Method_of_Payment__c,
                                Purchase_Order_Reference__c,
                                CreatedDate
                            FROM
                                Customer_Approval__c
                            WHERE
                                Opportunity__c = :this.opp.Id ORDER BY CreatedDate DESC LIMIT 1];
        if (custApprRec.size() > 0){
            return custApprRec[0];
        }else{
            return null;
        }
    }
    
    
    /*
     * GET OPP TYPE TEXT
     *
     * Used on the event application form allow for word changes based on the opportunity record type.
     */
    public String getOppTypeText(){
        
        String result = '';
        
        if (getOppType() == 'Subscription' ){
            result = 'Membership';
        }else{
            result = 'Booking';
        }
        
        return result;
    }
    /*
     * GET LOCATIONS
     *
     * Gets a list of venues and bookings for the form
     */
    public location [] getLocations() {

        Opportunity opp = [SELECT RecordType.Id FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
        
        // Get all the bookings from the opportunity        
        List <Special_Event_Booking__c> allBookings = new List<Special_Event_Booking__c>([SELECT 
                Special_Event__r.Venue__r.Id,
                Special_Event__r.Venue__r.Name,
                Special_Event__r.Venue__r.Venue_Contact__r.Name,
                Special_Event__r.Venue__r.Venue_Contact__r.Email,
                Special_Event__r.Venue__r.Venue_Contact__r.Phone,
                Special_Event__r.Venue_Name__c,
                Special_Event__r.Venue_Address__c,
                Special_Event__r.Product__r.Product_Correspondence_Name__c,
                Special_Event__r.Name,
                Special_Event__r.StartDate__c,
                Special_Event__r.EndDate__c,
                Special_Event__r.Maximum_Places__c,
                Special_Event__r.Total_Booking__c,
                Special_Event__r.Grand_Total_Revenue__c,
                Contact__c,
                Contact_Salutation__c,
                Delegate_Job_Title__c,
                CE_Contact_Brithdate__c,
                CE_Contact_Email__c,
                CE_Contact_Name__c,
                CE_Contact_Phone__c,
                Name,
                Id,
                Status__c
            FROM Special_Event_Booking__c 
            WHERE Opportunity__c = :opp.Id 
                AND (Special_Event__r.Status__c = 'Resourced' 
                        OR Special_Event__r.Status__c = 'Agreed'
                        OR Special_Event__r.Status__c = 'Confirmed'
                        OR Special_Event__r.Status__c = 'Completed')
                AND Dont_Show_on_Booking_Form__c = False
                AND (Status__c = 'Provisional' OR Status__c = 'Confirmed' OR Status__c = 'Attended')
            ORDER BY Special_Event__r.Venue__r.Id, 
                Special_Event__r.Name
            ]);
        
        
        // Find all the unique venues from the list
        Set<Id> unqVenuesIdList = new Set<Id>();
        
        for (Special_Event_Booking__c booking : allBookings){
            if(!unqVenuesIdList.contains(booking.Special_Event__r.Venue__r.id)){
                unqVenuesIdList.add(booking.Special_Event__r.Venue__r.id);
            }
        }
        
        System.debug('Unique Venues (Account Ids): '+unqVenuesIdList);

        // Create locations list to store all locations
        List<location> locations = new List<location>();

        // Booking list to keep track of which bookings have been added
        //Set<Id> addedBookingsList = new Set<Id>();
                
        // Loop over venues and get booking attach to location etc
        for (Id venueId : unqVenuesIdList){
            // Set location
            location location = new location();
            // Pick the first Booking
            location.location = [SELECT Id,
                                    Special_Event__r.Venue__r.Name,
                                    Special_Event__r.Venue_Name__c,
                                    Special_Event__r.Venue_Address__c,
                                    Special_Event__r.Venue__r.Venue_Contact__r.Name,
                                    Special_Event__r.Venue__r.Venue_Contact__r.Phone,
                                    Special_Event__r.Venue__r.Venue_Contact__r.Email,
                                    Status__c
                                FROM 
                                    Special_Event_Booking__c
                                WHERE
                                    Opportunity__c = :opp.Id
                                    AND Dont_Show_on_Booking_Form__c = False
                                    AND Special_Event__r.Venue__r.id = :venueId
                                    AND (Status__c = 'Provisional' OR Status__c = 'Confirmed' OR Status__c = 'Attended')
                                    LIMIT 1][0];
            List<event> eventList = new List<event>();
            location.events = eventList;
            
            Set<Id> unqEventsAtVenueList = new Set<Id>();
            for (Special_Event_Booking__c booking : allBookings){
                Id testId = booking.Special_Event__r.Id;
                
                if(!unqEventsAtVenueList.contains(booking.Special_Event__r.Id) && booking.Special_Event__r.Venue__r.Id == venueId){
                    unqEventsAtVenueList.add(booking.Special_Event__r.Id);
                }
            }
            System.debug('Unique Events for venue('+venueId+'): '+unqEventsAtVenueList);
            
            for (Special_Event__c event : [SELECT Id,
                                                    Name,
                                                    Product__r.Product_Correspondence_Name__c,
                                                    StartDate__c,
                                                    EndDate__c,
                                                    Total_Booking__c,
                                                    Maximum_Places__c,
                                                    Available_Places__c,
                                                    Grand_Total_Revenue__c,
                                                    Venue__r.Id
                                                FROM Special_Event__c
                                                WHERE Id IN :unqEventsAtVenueList
                                                ORDER BY StartDate__c
                                                ]){
                event curEvent = new event();
                curEvent.event = event;
                
                List<Special_Event_Booking__c> bookings = new List<Special_Event_Booking__c>([SELECT
                                                    Special_Event__r.Venue__r.Id,
                                                    Contact__c,
                                                    Contact_Salutation__c,
                                                    Delegate_Job_Title__c,
                                                    CE_Contact_Brithdate__c,
                                                    CE_Contact_Email__c,
                                                    CE_Contact_Name__c,
                                                    CE_Contact_Phone__c,
                                                    Contact__r.Name,
                                                    Contact__r.Email,
                                                    Contact__r.Phone,
                                                    Contact__r.Birthdate,
                                                    Name,
                                                    Id,
                                                    Status__c
                                                FROM Special_Event_Booking__c 
                                                WHERE Opportunity__c = :opp.Id
                                                    AND Dont_Show_on_Booking_Form__c = False
                                                    AND Special_Event__c = :event.Id
                                                    AND (Status__c = 'Provisional' OR Status__c = 'Confirmed' OR Status__c = 'Attended')
                                                ]);
                
                curEvent.eventBookings = bookings;
                location.events.add(curEvent);
                
            }
            
            // Add location to locations list and move onto the next location in loop
            locations.add(location);
        }
                
        System.debug('Locations: '+locations);

        return locations;
    }

    /*
     * GET THE CURRENCY SYMBOL FOR THE FORM
     * 
     */
    public String getCurrSymbol(){
        
        if (this.currencySymbol == null){
            Opportunity opp = [SELECT CurrencyIsoCode FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
            if (opp.CurrencyIsoCode == 'GBP'){
                this.currencySymbol = '£';
            }else{
                this.currencySymbol = opp.CurrencyIsoCode;
            } 
        }
        return this.currencySymbol;
    }
    
    /*
     * GET THE CURRENCY SYMBOL FOR THE FORM
     *
     * Based on the type of the opportunity the number of columns differ and a colspan is needed so this works it out.
     * 
     */
    public Decimal getColSpan(){
        
        if (this.getOppType() == 'In_Company_Event'){
            return 7;
        }else{
            return 5;
        }
    }

    /*
     * GET OPP LINES
     */
    public OpportunityLineItem [] getOppLines() {
        
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>([SELECT o.PriceBookEntry.ProductCode, 
                                                                                o.Quantity, 
                                                                                o.Qty_to_show_on_booking_form__c, 
                                                                                o.TotalPrice, 
                                                                                o.Booking_form_total_price__c, 
                                                                                o.UnitPrice, 
                                                                                o.Show_Price_as_TBA__c, 
                                                                                o.PriceBookEntry.Product2.Product_Correspondence_Name__c, 
                                                                                o.Product_Correspondence_Name__c 
                                                                            FROM OpportunityLineItem o
                                                                            WHERE OpportunityId = :this.opp.Id
                                                                                AND Qty_to_show_on_booking_form__c !=0
                                                                            ]);
        return oppLines;
    }

    /*
     * GET OPPORTUNITY TOTAL
     */
    public Decimal getOppTotal() {
        
        Decimal totalAmount = 0;
        
        for(OpportunityLineItem oppLine : [SELECT o.PriceBookEntry.ProductCode, o.Quantity, o.Qty_to_show_on_booking_form__c, o.TotalPrice, o.UnitPrice, o.PriceBookEntry.Product2.Product_Correspondence_Name__c 
                                                                            FROM OpportunityLineItem o
                                                                            WHERE OpportunityId = :this.opp.Id
                                                                                AND Qty_to_show_on_booking_form__c != 0
                                                                            ]){
            if(oppLine.Qty_to_show_on_booking_form__c > 0){
                totalAmount+=(oppLine.Qty_to_show_on_booking_form__c * oppLine.UnitPrice);
            }else{
                totalAmount+=(oppLine.Quantity * oppLine.UnitPrice);
            }
            
        }
        System.debug('Total Opp Amount: '+totalAmount);
        return totalAmount;
    }

    /*
     * GET CONTACT ROLE
     */
    public OpportunityContactRole getContactRole() {

        //@todo check for no records
        try {
            OpportunityContactRole oppContactRole = [SELECT ContactId, Contact.Name, Contact.Phone, Contact.Salutation, Role, Contact.Email, Contact.Title FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId = :this.opp.Id LIMIT 1][0];
            return oppContactRole;
    
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to continue, no primary contact role exists on the opportunity');
            ApexPages.addMessage(myMsg);
            
            fatalError = true;
            this.fatalError = true;
            return null;
        }
    }

    /*
     * GET TAX AMOUNTS
     * Gets the tax amounts of the invoice part of the membership application VF.
     */
    public List<Decimal> getTaxAmounts(){

        Decimal [] taxAmounts = new List<Decimal>();

        /*
        Account acc = [SELECT c2g__CODAInputVATCode__c FROM Account WHERE Id = :this.opp.AccountId LIMIT 1][0];
        Id taxCodeId = acc.c2g__CODAInputVATCode__c;
        */
        Opportunity oppTax = [SELECT Tax_Code__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
        Id taxCodeId = oppTax.Tax_Code__c;
        System.debug('TaxCodeId: '+taxCodeId);
        
        
        if (taxCodeId == null){
            // @todo error not appearing:
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The opportunity doesn\'t have an VAT code set');
            ApexPages.addMessage(myMsg);
            fatalError = true;
            this.fatalError = true;
            taxAmounts.add(0); taxAmounts.add(0);           
        }else{
            //@todo check for no records
            c2g__codaTaxRate__c taxRate = [SELECT c2g__Rate__c FROM c2g__codaTaxRate__c WHERE c2g__StartDate__c < :Date.Today() AND c2g__TaxCode__r.Id = :taxCodeId ORDER BY c2g__StartDate__c DESC LIMIT 1][0];
            
            taxAmounts.add(taxRate.c2g__Rate__c);
            try {
                taxAmounts.add(getOppTotal()*taxRate.c2g__Rate__c);
            }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity does not have any products!');
                ApexPages.addMessage(myMsg);
                fatalError = true;
                this.fatalError = true;
            }
        }
        
        return taxAmounts;
    }

    /*****************************
     *     *** VF ACTIONS ***    *
     *****************************/

    /*
     * ACTION: UPDATE BOOKINGS
     * 
     * Updates booking contact details.
     * 
     */
    public pageReference updateBookings(){
        
        List<Special_Event_Booking__c> bookingsToUpd = new List<Special_Event_Booking__c>();
        
        // Loop over bookings and add them to the bookings to update list and then update the object list.
        for (location loc : allLocations){
            for (event evt : loc.events){
                for (Special_Event_Booking__c booking : evt.eventBookings){
                    bookingsToUpd.add(booking);
                }
            }
        }
        update bookingsToUpd;
        
        // Refresh locations list
        this.allLocations = getLocations();
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your booking information has been saved');
        ApexPages.addMessage(myMsg);
        
        return null;
    }   

    /*
     * ACTION: SEND TO AE
     * 
     * Customer fills out the request amendment box on the booking form to contact their Account Exec.
     * 
     */
    public pageReference sendToAE(){
        
        updateBookings();
        
        Opportunity opp = [SELECT Opportunity_Number__c, Name, Owner.Email, Owner.Id FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];

        /*
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://www.mantissa.net/testMail.php?e=teststs');
        req.setMethod('GET');
        h.send(req);
        */
        String changeDetails = ApexPages.currentPage().getParameters().get('changeDetails');
        Id whoId = ApexPages.currentPage().getParameters().get('whoId');
        
        Task newTask = new Task(
                            Subject = 'Customer Feedback from '+opp.Opportunity_Number__c+' ("' + opp.Name + '") opportunity',
                            Priority = 'Normal',
                            Status = 'Not Started',
                            Description = 'RESPONSE FROM CUSTOMER:\n\n'+changeDetails,
                            IsReminderSet = true,
                            ReminderDateTime = System.now(),
                            ActivityDate = date.today(),
                            WhoId = whoId,
                            WhatId = this.opp.Id,
                            Type = 'Online Form',
                            OwnerId = this.opp.OwnerId
                            );
        insert newTask;
        
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {opp.Owner.Email};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('salesforce@britsafe.org');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('British Safety Council Order :: Customer Feedback from opportunity');
        mail.setUseSignature(true);
        mail.setPlainTextBody('A customer has feedback on their booking: https://eu1.salesforce.com/'+newTask.Id);
        mail.setHtmlBody('A customer has feedback on their booking: <a href="https://eu1.salesforce.com/'+newTask.Id+'">https://eu1.salesforce.com/'+newTask.Id+'</a>');
        
        System.debug('Sent email to Opp Owner: '+opp.Owner.Email);   
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        System.debug('sendToAE message to: '+this.opp.OwnerId);
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Account Manager has been notifed and will contact you shortly');
        ApexPages.addMessage(myMsg);
        
        return null;
    }

    /*
     * ACTION: CONFIRM BOOKING
     * 
     * The customer clicks the "Confirm Booking" at the bottom of the booking form.
     * 
     */
    public pageReference confirmBooking(){

        updateBookings();

        Opportunity opp = [SELECT Opportunity_Number__c, Name, Owner.Email, Owner.Id FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];

        Id whoId = ApexPages.currentPage().getParameters().get('whoId');
        
        Boolean error = false;
        String errMsg;
        this.authorisedBy = ApexPages.currentPage().getParameters().get('authorisedBy');
        this.authorisedPosition = ApexPages.currentPage().getParameters().get('authorisedPosition');
        this.methodofPayment = ApexPages.currentPage().getParameters().get('methodofPayment');
        this.purchaseOrderReference = ApexPages.currentPage().getParameters().get('purchaseOrderReference');
        
        if(this.authorisedBy == ''){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must add a value in the authorised by field');
            ApexPages.addMessage(myMsg);
        }
        if(this.authorisedPosition == ''){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must add a value in the authorised position field');
            ApexPages.addMessage(myMsg);
        }
        if(this.methodofPayment == ''){
            error = true; 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must add a value in the method of payment field');
            ApexPages.addMessage(myMsg);
        }
        if(this.purchaseOrderReference == '' && this.methodofPayment != 'Credit Card'){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must add a value in the purchase order / other reference field if you select a payment method of purchase order or other reference');
            ApexPages.addMessage(myMsg);
        }

        if (!this.confirmTerms){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must confirm that you have read and accept the terms and conditions');
            ApexPages.addMessage(myMsg);
        }
        if (!error){     
            this.confirmed = true;
            Customer_Approval__c custApproval = new Customer_Approval__c(
                                Opportunity__c = this.opp.Id,
                                Authorised_By__c = this.authorisedBy,
                                Authorised_Position__c = this.authorisedPosition,
                                Method_of_Payment__c = this.methodofPayment,
                                Purchase_Order_Reference__c = this.purchaseOrderReference,
                                Type__c = 'Approval'
                                );
            insert custApproval;
            
            Task newTask = new Task(
                            Subject = 'Customer confirmed opportunity '+opp.Opportunity_Number__c+' ("' + opp.Name + '") booking',
                            Priority = 'Normal',
                            Status = 'Not Started',
                            Description = 'RESPONSE FROM CUSTOMER:\n\nAuthorised By: '+this.authorisedBy+'\nAuthorised Position: '+this.authorisedPosition+'\nMethod of Payment: '+this.methodofPayment+'\nPurchase Order Reference: '+this.purchaseOrderReference+'\n\nCustomer Approval Record: https://eu1.salesforce.com/'+custApproval.Id,
                            IsReminderSet = true,
                            ReminderDateTime = System.now(),
                            ActivityDate = date.today(),
                            WhoId = whoId,
                            WhatId = this.opp.Id,
                            Type = 'Online Form',
                            OwnerId = this.opp.OwnerId
                            );
            insert newTask;

            // Send email to Sales Rep
            
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {opp.Owner.Email};
            mail.setToAddresses(toAddresses);
            //mail.setOrgWideEmailAddressId('0D2M00000008OXA');
            mail.setReplyTo('salesforce@britsafe.org');
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('British Safety Council Order :: Confirmed Booking');
            mail.setUseSignature(true);
            mail.setPlainTextBody('A customer has confirmed their booking: https://eu1.salesforce.com/'+newTask.Id);//+newTask.Id);
            mail.setHtmlBody('A customer has confirmed their booking: <a href="https://eu1.salesforce.com/'+newTask.Id+'">View Task</a>');//+newTask.Id+'">https://eu1.salesforce.com/'+newTask.Id+'</a>');
            
            System.debug('Sent email to Opp Owner: '+opp.Owner.Email);            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            System.debug('sendToAE message to: '+this.opp.OwnerId+' Message:'+custApproval);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Event has been confirmed');
            ApexPages.addMessage(myMsg);

            // START: Create an attachment of the Booking form and attach it too the Customer Approval
            Attachment attach = new Attachment();
            PageReference pdf = Page.EventApplicationForm;
            pdf.setRedirect(false);
            // add parent id to the parameters for standardcontroller
            pdf.getParameters().put('id', this.opp.Id);
            pdf.getParameters().put('p','1');
            // Due to record not being saved until the end of the transaction the VF doesn't show the customer approval
            // So posting in url:
            pdf.getParameters().put('Authorised_By__c', this.authorisedBy);
            pdf.getParameters().put('Authorised_Position__c', this.authorisedPosition);
            pdf.getParameters().put('Method_of_Payment__c', this.methodofPayment);
            pdf.getParameters().put('Purchase_Order_Reference__c', this.purchaseOrderReference);
            pdf.getParameters().put('CreatedDate', String.valueOf(System.now()));

            // the contents of the attachment from the pdf
            Blob body;
            try
            {
                // returns the output of the page as a PDF
                body = pdf.getContent();
                
                // need to pass unit test -- current bug
            }
            catch (VisualforceException e)
            {
                body = Blob.valueOf('An error occurred trying to get the contents of the PDF, please try again');
            }

            attach.Body = body;
            
            // add the name
            attach.name = 'Booking Form ' + opp.Name + '.pdf';
            attach.IsPrivate = false;
            attach.ContentType = 'application/pdf';
            
            // attach the pdf to the Customer Approval
            attach.ParentId = custApproval.Id;
            insert attach;

            // END: Create an attachment of the Booking form and attach it too the Customer Approval

        }
        return null;
    }
    
    /*
     * ACTION: SEND TO CUSTOMER
     * 
     * Sales rep clicks the button on the form to send the form to the customer
     * 
     */
    public pageReference sendToCustomer(){

        Opportunity opp = [SELECT Opportunity_Number__c, Name, StageName, Owner.Email FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
        OpportunityContactRole oppContactRole = [SELECT ContactId, Contact.Name, Contact.Salutation, Role, Contact.Email, Contact.Title FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId = :this.opp.Id LIMIT 1][0];
        
        Boolean error = false;
        String errMsg;
        if(!(opp.StageName == 'Quote/Proposal' || opp.StageName == 'Negotiation')){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The order cannot be sent to the customer because the Opportunity is not at the stage: "Quote/Proposal" or "Negotiation". Update the stage before sending the form');
            ApexPages.addMessage(myMsg);
        }
        
        if (!error){
            // Create email & send to customer
            // Create email activity on opportunity
            
            // Reserve email capacity for the current Apex transaction to ensure,
            // that we won't exceed our daily email limits when sending email.
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {oppContactRole.Contact.Email};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(opp.Owner.Email);
            //mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('British Safety Council Order');
            mail.setUseSignature(true);
            mail.setPlainTextBody('Thank you for your order. Please click the following link to confirm your order. \n\n'+this.url+'?id='+this.opp.Id+'&hash='+getHash()+'\n\nIf you need to alter the order in any way please use the options at the bottom of the page. If you have any other questions please let me know.');

            System.debug('Sent email to customer: '+oppContactRole.Contact.Email);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The booking form has been sent to the customer.');
            ApexPages.addMessage(myMsg);

            // START: Create completed emailed activity
            Task newTask = new Task(
                            Subject = 'Booking form '+opp.Opportunity_Number__c+' ("' + opp.Name + '") sent to customer',
                            Priority = 'Normal',
                            Status = 'Completed',
                            Description = 'Email sent to customer asking them to review and confirm the booking',
                            ActivityDate = date.today(),
                            WhoId = oppContactRole.ContactId,
                            WhatId = this.opp.Id,
                            Type = 'Email',
                            OwnerId = UserInfo.getUserId()
                            );
            insert newTask;
            // END: Create completed emailed activity

            // START: Create an attachment of the Booking form and attach it too the Customer Approval
            Attachment attach = new Attachment();
            PageReference pdf = Page.EventApplicationForm;
            pdf.setRedirect(false);
            // add parent id to the parameters for standardcontroller
            pdf.getParameters().put('id', this.opp.Id);
            pdf.getParameters().put('p','1');

            // the contents of the attachment from the pdf
            Blob body;
            try
            {
                // returns the output of the page as a PDF
                body = pdf.getContent();
                
                // need to pass unit test -- current bug
            }
            catch (VisualforceException e)
            {
                body = Blob.valueOf('An error occurred trying to get the contents of the PDF, please try again');
            }

            attach.Body = body;
            
            // add the name
            attach.name = 'Booking Form ' + opp.Name + '.pdf';
            attach.IsPrivate = false;
            attach.ContentType = 'application/pdf';
            
            // attach the pdf to the Customer Approval
            attach.ParentId = newTask.Id;
            insert attach;

            // END: Create an attachment of the Booking form and attach it too the Customer Approval

        }
        return null;
    }

    private String getHash(){
        
        String inputStr = 'sjej2'+this.opp.Id;
        
        System.debug('md5 String: '+inputStr);
        String algorithmName = 'MD5';
        Blob mac = Crypto.generateDigest(algorithmName, Blob.valueOf(inputStr));
        String macUrl = EncodingUtil.urlEncode(EncodingUtil.ConvertToHex(mac), 'UTF-8');
    
        return macUrl;
    }
    
    public String getWorldPayMD5(){
                
        // instId:currency:cartId:secret
        Opportunity opp = [SELECT CurrencyIsoCode,Opportunity_Number__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
        
        String inputStr = this.WorldPaySecret+':'+this.WorldPayInstallationId+':'+opp.CurrencyIsoCode+':'+opp.Opportunity_Number__c;
        
        System.debug('md5 String: '+inputStr);
        String algorithmName = 'MD5';
        Blob mac = Crypto.generateDigest(algorithmName, Blob.valueOf(inputStr));
        String macUrl = EncodingUtil.urlEncode(EncodingUtil.ConvertToHex(mac), 'UTF-8');
    
        return macUrl;
    }

    @IsTest
    private static void testEventsPage(){
        
        Account acc = new Account (
            Name = 'Test Acc',
            Phone = '00000'
            );
        insert acc;
        
        Contact contact = new Contact (
            Active__c = True,
            Email = 'bsc+testscriptemail@netstronghold.com',
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            MailingCountry = 'United Kingdom',
            Title = 'Mr',
            AccountId = acc.Id
        );
        insert contact;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Test Opp',
            StageName = 'Negotiation',
            IC_Price_Variation_Approved__c = true,
            CloseDate = System.today());
        insert opp;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = opp.Id,
            IsPrimary = true
        );
        
        insert oppContRole;

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
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert oli;
        
        
        Special_Event__c event = new Special_Event__c(
            Product__c = prod.Id,
            City__c = 'London',
            StartDate__c = System.today().addDays(3));
        insert event;


        List<Opportunity> oppQuery = [
            SELECT
                Id,
                Name,
                IsWon,
                IsClosed,
                StageName,
                AccountId,
                OwnerId,
               (SELECT
                    Id,
                    PricebookEntry.Product2.Name,
                    PricebookEntry.Product2.Allows_Provisional_Bookings__c, Quantity,
                    UnitPrice From OpportunityLineItems)
            FROM
                Opportunity
            WHERE
                Id = :opp.id];
                                        
        if (oppQuery.size() == 1)
            opp = oppQuery.get(0);
        
        //controller.opportunity = opp;
 
        ApexPages.Standardcontroller stdContr = new ApexPages.Standardcontroller(opp);
        EventApplicationForm controller = new EventApplicationForm(stdContr);
        
        controller.opp = opp;
        controller.confirmTerms = True;
        
        //controller.updateSite();
        //controller.updateAddAndContant();
        
        controller.sendToCustomer();
        controller.sendToAE();
        controller.confirmBooking();
        
        
    }
    
}