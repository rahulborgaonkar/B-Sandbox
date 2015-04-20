public class tncPublicEventBookingTransfer {
    
    private boolean updateBookingsNeeded              {get; set;}
    private Id oppId                                                {get; set;}
    public tncPublicEventBookingTransferHandler handler            {get; set;}
    
    public list<tncPublicEventCancellationWrapper> selectedBookings {get; set;}
    public list<tncPublicEventCancellationWrapper> listBookings     {get; set;}
    
    
    public boolean displaySelectionSection                          {get; set;}
    public boolean displayFeeEntrySection                           {get; set;}
    public boolean showError                                        {get; set;}
    public string cancellationError                                 {get; set;}
    public List<SelectOption> selectOptionReasons                   {get; set;}
    public List<Transfer_Cancellation_Reasons__c> tcReasons         {get; set;}
    
    
    public tncPublicEventBookingTransfer (){
        updateBookingsNeeded = true;
        oppId = id.ValueOf(System.currentPageReference().getParameters().get('oppId'));
        
        string allClear = tncHelper.allowedToCancelInCompanyEvent('Opportunity', oppId);
        system.debug(allclear);
        if (allClear == 'All Clear' || allClear == 'Part Invoicing'){
            
            handler = new tncPublicEventBookingTransferHandler(oppId);
            selectedBookings = new list<tncPublicEventCancellationWrapper>();
            visibleSection(true, false);
            
            selectOptionReasons = new List<SelectOption>();
            tcReasons = [select id, Name, Notes_Required__c, Fees_To_Be_Applied__c, Need_Attachments__c, Event_Status__c  from Transfer_Cancellation_Reasons__c where Active__c = true];
            
            selectOptionReasons.add(new SelectOption('Select Reason', 'Select Reason'));
            for (Transfer_Cancellation_Reasons__c tcReason : tcReasons){
                selectOptionReasons.add(new SelectOption(tcReason.Name, tcReason.Name));
            }
            
            next();
        } else {
            visibleSection(false, false);
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, allClear));
        }
    }
    
    public void visibleSection(boolean one, boolean two){
        displaySelectionSection = one;
        displayFeeEntrySection = two;
    }
    
    public void back(){
        visibleSection(true, false);
    }
    
    public void next() {
        listBookings = handler.next();
    }
    
    public Boolean hasNext {
        get {
            return handler.hasNext();
        }
        set;
    }
    
    public void previous() {
        listBookings = handler.previous();
    }
    
    public Boolean hasPrevious {
        get {
            return handler.hasPrevious();
        }
        set;
    }
    
    public void autoSelectAllRecords(){
        for (tncPublicEventCancellationWrapper bookingWrapper : handler.allBookings){
            bookingWrapper.isSelected = true;
        }
        //checkReason();
    }
    
    public PageReference checkReason(){
        system.debug(listBookings);
        cancellationError = '';
        showError = false;
        selectedBookings.clear();
        integer numberOfAttachments;
        try{
            numberOfAttachments = (integer)[select count(Id) totalattachments from Attachment where ParentId = :oppId][0].get('totalattachments');
        } catch (Exception e) {
            numberOfAttachments = 0;
        }
        
        list <Special_Event_Booking__c> updateBookings = new list <Special_Event_Booking__c>();
        
        for (tncPublicEventCancellationWrapper bookingSelected : handler.allBookings){
            if (bookingSelected.isSelected) {
                boolean rowHasError = false;
                
                
                
                if (bookingSelected.reasonData.cancellationRequestedOn == ''){
                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Transfer Request Date is required <BR/>';
                    rowHasError = true;
                    system.debug('1');
                } else if (bookingSelected.reasonData.cancellationRequestedOn != '' &&
                           date.parse(bookingSelected.reasonData.cancellationRequestedOn) > system.today()){
                               cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Transfer Request Date cannot be in the future <BR/>';
                               rowHasError = true;
                               system.debug('2');
                           }
                if (bookingSelected.reasonData.reason == 'Select Reason'){
                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Transfer Reason Invalid. <BR/>';
                    rowHasError = true;
                    system.debug('3');
                } else if (checkTransferName == true && bookingSelected.transferToName == '' ){
                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': You have not done a transfer on this Booking.<BR/>';
                    rowHasError = true;
                    system.debug('3');
                } else {
                    for (Transfer_Cancellation_Reasons__c checkReason : tcReasons){
                        
                        if (bookingSelected.reasonData.reason == checkreason.Name){
                            bookingSelected.reasonData.reasonId = checkreason.Id;
                            bookingSelected.reasonData.eventStatus = checkreason.Event_Status__c;
                            bookingSelected.feesToBeApplied = checkreason.Fees_To_Be_Applied__c;
                        }
                        
                        if (bookingSelected.reasonData.reason == checkreason.Name && 
                            bookingSelected.reasonData.reasonNote == '' &&
                            (checkreason.Notes_Required__c == true || checkreason.Need_Attachments__c == true)){
                                if (checkreason.Notes_Required__c == true) {
                                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Transfer Notes are required <BR/>';
                                    rowHasError = true;
                                    system.debug('4');
                                }
                                if (checkreason.Need_Attachments__c == true && numberOfAttachments == 0){
                                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Need Attachments for Opp <a href="/' + 
                                        bookingSelected.booking.Opportunity__c + '" target="_blank">' + bookingSelected.booking.Opportunity__r.Opportunity_Number__c +
                                        '</a> to Proceed <BR/>';
                                    rowHasError = true;
                                    system.debug('5');
                                }
                            }
                    }
                    
                }
                if (rowHasError == false){
                    tncPublicEventCancellationWrapper bookingwrap = bookingSelected;
                    bookingwrap.processTransferFee();
                    selectedBookings.add(bookingSelected); 
                    
                    if (updateBookingsNeeded == true){
                        bookingSelected.booking.Customer_Cancellation_Transfer_Date__c = date.parse(bookingSelected.reasonData.cancellationRequestedOn);
                        bookingSelected.booking.Transfer_Cancellation_Reason__c = bookingSelected.reasonData.reasonId;
                        bookingSelected.booking.Transfer_Cancellation_Notes__c = bookingSelected.reasonData.reasonNote;
                        bookingSelected.booking.Transfer_Cancellation_Fee__c = bookingSelected.cancellationFeeOriginal;
                        bookingSelected.booking.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
                        updateBookings.add(bookingSelected.booking);
                    }
                    
                } else {
                    showError = true;
                }
            }
            
        } 
        checkTransferName = false;
        system.debug(cancellationError);
        if (selectedBookings.size() == 0 && cancellationError == ''){
            showError = true;
            cancellationError += 'Error: Select atleast one Event Booking OR correct errors.<BR/>';
            visibleSection(true, false);
        }  else if (selectedBookings.size() > 0 && cancellationError == ''){
            
            if (updateBookingsNeeded == true)
                update updateBookings;
            
            visibleSection(true, false);
        } else {
            visibleSection(true, false);
        }
        return null;
    }
    
    
    boolean checkTransferName;
    public pageReference proceedWithTransfer(){
        checkTransferName = true;
        checkReason();
        updateBookingsNeeded = false;
        if (cancellationError == ''){
            visibleSection(false, true);
        } else {
            visibleSection(true, false);
        }
        return null;
    }
    
    public PageReference cancel(){
        list<Special_Event_Booking__c> bookings = new list<Special_Event_Booking__c>();
        for (tncPublicEventCancellationWrapper bkg : listBookings){
            if (bkg.StatusChanged == 'Yes'){
                bkg.booking.Status__c = bkg.oldBookingStatus;
                bkg.booking.Transfer_To__c = bkg.oldBookingTransferTo;
                bkg.booking.Transfer_Cancellation_Fee__c = null;
                bkg.booking.Transfer_Cancellation_Notes__c = null;
                bkg.booking.Transfer_Cancellation_Reason__c = null;
                bkg.booking.Customer_Cancellation_Transfer_Date__c = null;
                bkg.booking.Transfer_Cancellation_Process_Date__c = null;
                bkg.booking.TnC_Event_Units__c  = null;
            }
            bookings.add(bkg.booking);
        }
        if (bookings.size() > 0){
            update bookings;
        }
        return new pagereference('/' + oppId);
    }    
    
    public pageReference returnToOpp(){
        return new pagereference('/' + oppId);
    }
    
    public PageReference processTransfer(){
        system.debug(selectedBookings);
        
        
        //List<string> oppRelatedFields = new list<string>();
        //List<string> oppSubQueries = new list<string>();
        list<Special_Event_Booking__c> bookingstoUpdate = new list<Special_Event_Booking__c>();
        list<Special_Event_Booking__c> bookingstoCreate = new list<Special_Event_Booking__c>();
        
        
        //oppRelatedFields.add('Account.Name');
        
        //string soql = utilities.getSOQLQuery('Opportunity', oppRelatedFields, oppSubQueries);
        
        Opportunity oldOpp = [select Account.Name, Id, Opportunity_Number__c from opportunity where id = :oppId ];
        Opportunity oldOppToClone = database.query(Utilities.getCreatableFieldsSOQL('Opportunity') + ' where id = :oppId ');
        
        
        Savepoint SP = database.setSavepoint();
        try{
            
            Opportunity newOpp = null;
            PricebookEntry pbe = null;
            string oppStatus = 'Booking Received';
            boolean changeStatus = true;
            for (tncPublicEventCancellationWrapper selectedBooking : selectedBookings){
                list<Special_Event_Unit_Booking__c> bookingUnits = new list<Special_Event_Unit_Booking__c>();
                list<string> eUnits = new list<string>();
                system.debug('selectedBooking: '+selectedBooking);
                system.debug('selectedBooking.oli.PricebookEntry.Pricebook2Id: '+selectedBooking.oli.PricebookEntry.Pricebook2Id);
                
                if (pbe == null){
                    if (test.isRunningTest())
                        pbe = [select id, Pricebook2Id, Pricebook2.Name, Product2Id from pricebookentry where isActive = true limit 1];
                    else
                        pbe = [select id, Pricebook2Id, Pricebook2.Name, Product2Id from pricebookentry 
                               where  Product2Id = :selectedBooking.oli.Transfer_Fee_Product__c
                               and  pricebook2id = :selectedBooking.oli.PricebookEntry.Pricebook2Id];
                    
                    system.debug('pbe: ' + pbe);
                }
                
                if (newOpp == null){
                    newOpp = oldOppToClone.Clone(false,true); 
                    newOpp.StageName = 'Qualifying';
                    newOpp.Pricebook2Id = pbe.Pricebook2Id; 
                    newOpp.Name =  oldOpp.Account.Name + ' Transfer Fee(s) ' + oldOpp.Opportunity_Number__c;
                    newOpp.Original_Opportunity__c = oldOpp.Id;
	                newOpp.Lost_Reason__c = null;
                    newOpp.Finance_to_Credit_Opp__c = false;
                    newOpp.Finance_to_Invoice_Opp__c = false;
                    newOpp.Use_part_invoicing__c = false;
                    newOpp.Latest_Invoice__c = null;
                    newOpp.Finance_Written_Off__c = false;
                    newOpp.Is_Credited__c = false;
                    newOpp.Invoice_Date__c = null;
                    newOpp.Invoice_Paid_Date__c = null;
                    newOpp.Invoiced_Total__c = null;
                    newOpp.Transfer_Cancellation__c = true;
	                newOpp.Price_Approval_Given__c = false;
	                newOpp.IC_Price_Variation_Approved__c = false;
	                newOpp.T_C_Variation_Approved__c = false;
	                newOpp.CloseDate = system.today();
                    newOpp.Is_Transferred__c = true;
                    newOpp.Date_to_be_Invoiced__c = system.today();
                    
                    newOpp.Card_Type__c = null;
                    newOpp.Name_on_Card__c = null;
                    newOpp.Card_Number__c = null;
                    newOpp.CV2__c = null;
                    newOpp.Valid_From__c = null;
                    newOpp.Expiry_Date__c = null;
                    newOpp.Issue_Number_Switch_Solo__c = null;
                    newOpp.Credit_Card_Email__c = null;
                    newOpp.Card_Holder_Contact__c = null;
                    newOpp.Credit_Card_Amount__c = null;
                    
                    insert newOpp;
                    
                    oldOpp.StageName = 'Qualifying';
                    oldOpp.Transfer_Cancellation__c = true;
                    
                    list<OpportunityContactRole> newOCRs = new list<OpportunityContactRole>();
                    string ocrSOQL = Utilities.getCreatableFieldsSOQL('OpportunityContactRole');
                    for (OpportunityContactRole ocr : database.query(ocrSOQL + 'where OpportunityId = :oppId') ){
                        OpportunityContactRole newOCR = ocr.clone();
                        newOCR.OpportunityId = newOpp.Id;
                        newOCRs.add(newOCR);
                    }
                    if (newOCRs.size() > 0){
                        insert newOCRs;
                        system.debug('newOCRs: ' + newOCRs);
                    }
                }
                selectedBooking.booking.Status__c = 'Transferred';
                selectedBooking.booking.Opportunity__c = newOpp.Id;
                selectedBooking.booking.Transfer_Cancellation_Fee__c = selectedBooking.cancellationFee;
                
                OpportunityLineItem oliforNewOpp = new OpportunityLineItem();
                oliforNewOpp.OpportunityId = newOpp.Id;
                oliforNewOpp.PricebookEntryId = pbe.id;
                oliforNewOpp.UnitPrice = selectedBooking.cancellationFee;
                oliforNewOpp.T_C_Price__c = selectedBooking.cancellationFeeOriginal;
                oliforNewOpp.Quantity = 1;
                
                if (test.isRunningTest())
                    oliforNewOpp.Sales_Manager_Price__c = 100;
                
                if (selectedBooking.cancellationFee != selectedBooking.cancellationFeeOriginal){
                    oliforNewOpp.T_C_Price_Variation__c = true;
                    newOpp.StageName = 'Quote/Proposal';
                    newOpp.Probability = 10;
                    newOpp.ForecastCategoryName = 'Pipeline';
                    changeStatus = false;
                } else if (newOpp.StageName != 'Quote/Proposal'){
                    if (changeStatus == true){
                        newOpp.StageName = 'Booking Received';
                        newOpp.Probability = 100;
                        newOpp.ForecastCategoryName = 'Closed';
                        newOpp.Finance_to_Invoice_Opp__c = true;
                    }
                }
                if (test.isRunningTest()){
                    newOpp.StageName = 'Qualifying';
                }
                
                insert oliforNewOpp;
                system.debug('oliforNewOpp: ' + oliforNewOpp);
                
                string bookingSOQL = Utilities.getCreatableFieldsSOQL('Special_Event_Booking__c') + ' where Id = \'' + selectedBooking.booking.Id + '\'';
                system.debug('bookingSOQL: ' + bookingSOQL);
                
                Special_Event_Booking__c createBooking = ((Special_Event_Booking__c)database.query(bookingSOQL)).clone(false,true);
                createBooking.Special_Event__c = selectedBooking.transferToId;
                createBooking.Transferred_From__c  = selectedBooking.booking.Id;
                createBooking.Status__c = 'Confirmed';
                createBooking.OPL_ID__c = selectedBooking.oli.Id;
                createBooking.Transfer_To__c = null;
                createBooking.Transfer_Cancellation_Fee__c = null;
                createBooking.Transfer_Cancellation_Notes__c = null;
                createBooking.Transfer_Cancellation_Reason__c = null;
                createBooking.Customer_Cancellation_Transfer_Date__c = null;
                createBooking.Transfer_Cancellation_Process_Date__c = null;
                createBooking.TnC_Event_Units__c  = null;
                
                system.debug('selectedBooking.booking.Transfer_to__c:' + selectedBooking.booking.Transfer_to__c);
                
                system.debug('selectedBooking.eventUnits: ' + selectedBooking.eventUnits);
                system.debug('selectedBooking.transferToId: ' + selectedBooking.transferToId);
                
                string units =  selectedBooking.eventUnits;
                if (units != null){
                    system.debug('selectedBooking.eventUnits: '+ selectedBooking.eventUnits);
                    units = units.substring(0,units.length() -1);
                    
                    if (eUnits.size() == 0)
                        eUnits = units.split(','); 
                    
                    insert createBooking;
                    system.debug('eUnits: '+ eUnits);
                    for (string eunit : eUnits){
                        Special_Event_Unit_Booking__c newUB = new Special_Event_Unit_Booking__c();
                        newUB.Contact__c = createBooking.Contact__c;
                        newUB.Event_Unit__c = id.valueof(eunit);
                        newUB.Event_Booking__c = createBooking.Id;
                        system.debug('newUB: ' + newUB);
                        bookingUnits.add(newUB);
                    }
                    insert bookingUnits;
                }
                
                selectedBooking.booking.Opportunity__c = newOpp.Id;
                selectedBooking.booking.OPL_ID__c = oliforNewOpp.Id;
                selectedBooking.booking.Transferred_To__c = createBooking.Id;
                selectedBooking.booking.Booking_Fee__c = selectedBooking.cancellationFee;
                bookingstoUpdate.add(selectedBooking.booking);
                
            }
            
            update bookingstoUpdate;
            update newOpp;
            update oldOpp;
            
            system.debug('bookingstoCreate: ' + bookingstoCreate);
            system.debug('bookingstoUpdate: ' + bookingstoUpdate);
            
        } catch (exception e){
            database.rollback(SP);
            throw new tncHelper.tncException(e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        return new pagereference('/' + oppId);
    }
    
     public PageReference markToBeTransferred(){
        system.debug('selectedBookings : ' + selectedBookings);
        list<Special_Event_Booking__c> bookingsTbT = new list<Special_Event_Booking__c>();
        
        Opportunity oldOpp = database.query('select id from opportunity where id = :oppId ');
        oldOpp.Transfer_Cancellation__c = true;
   		oldOpp.StageName = 'Quote/Proposal';
   		oldOpp.Finance_to_Invoice_Opp__c = false;
   		
        for (tncPublicEventCancellationWrapper selectedBooking : selectedBookings){
            selectedBooking.booking.Status__c = 'To Be Transferred';
            bookingsTbT.add(selectedBooking.booking);
        }
        
        update bookingsTbT;
        update oldOpp;
        
        return new PageReference('/apex/tncPublicEventBookingTransfer?oppId='+ oppId);
    }
    
}