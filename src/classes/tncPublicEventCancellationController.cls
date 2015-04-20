public class tncPublicEventCancellationController{
     
    private Id oppId	                                            {get; set;}
    public tncPublicEventCancellationHandler handler               {get; set;}
    
    public list<tncPublicEventCancellationWrapper> selectedBookings {get; set;}
    public list<tncPublicEventCancellationWrapper> listBookings     {get; set;}


    public boolean displaySelectionSection                          {get; set;}
    public boolean displayFeeEntrySection                           {get; set;}
    public boolean showError                                        {get; set;}
    public string cancellationError                                 {get; set;}
    public List<SelectOption> selectOptionReasons                   {get; set;}
    public List<Transfer_Cancellation_Reasons__c> tcReasons         {get; set;}

    
    public tncPublicEventCancellationController(){
        
        oppId = id.ValueOf(System.currentPageReference().getParameters().get('oppId'));
        
        string allClear = tncHelper.allowedToCancelInCompanyEvent('Opportunity', oppId);
        system.debug(allclear);
        if (allClear == 'All Clear' || allClear == 'Part Invoicing'){

            handler = new tncPublicEventCancellationHandler(oppId);
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
        cancellationError = '';
        showError = false;
        selectedBookings.clear();
        integer numberOfAttachments;
		try{
			numberOfAttachments = (integer)[select count(Id) totalattachments from Attachment where ParentId = :oppId][0].get('totalattachments');
		} catch (Exception e) {
			numberOfAttachments = 0;
        }
        for (tncPublicEventCancellationWrapper bookingSelected : handler.allBookings){
            if (bookingSelected.isSelected) {
                boolean rowHasError = false;
                
                system.debug('bookingSelected.reasonData ' + bookingSelected.reasonData);
                
                if (bookingSelected.reasonData.cancellationRequestedOn == ''){
                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Cancellation Request Date is required <BR/>';
                    rowHasError = true;
                    system.debug('1');
                } else if (bookingSelected.reasonData.cancellationRequestedOn != '' &&
                    date.parse(bookingSelected.reasonData.cancellationRequestedOn) > system.today()){
                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Cancellation Request Date cannot be in the future <BR/>';
                    rowHasError = true;
                    system.debug('2');
                }
                if (bookingSelected.reasonData.reason == 'Select Reason'){
                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Cancellation Reason Invalid. <BR/>';
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
                                    cancellationError += 'Error: ' + bookingSelected.booking.Name + ': Cancellation Notes are required <BR/>';
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
                    system.debug('bookingSelected.reasonData ' + bookingSelected.reasonData);
                }
                if (rowHasError == false){
                    tncPublicEventCancellationWrapper bookingwrap = bookingSelected;
                    bookingwrap.processCancellationFee();
                    selectedBookings.add(bookingSelected); 
                } else {
                    showError = true;
                }
            }
        }
        
        system.debug(cancellationError);
        if (selectedBookings.size() == 0 && cancellationError == ''){
            showError = true;
            cancellationError += 'Error: Select atleast one event OR correct errors.<BR/>';
            visibleSection(true, false);
        }  else if (selectedBookings.size() > 0 && cancellationError == ''){
            visibleSection(false, true);
        } else {
            visibleSection(true, false);
        }
        return null;
    }
    
    public PageReference cancel(){
        return new pagereference('/' + oppId);
    }    
    
    public PageReference processCancellation(){
        system.debug('Calling tncHelper.processPublicEventCancellation');
        tncHelper.processPublicEventCancellation(selectedBookings, oppId);
        system.debug('Finished tncHelper.processPublicEventCancellation');
        
        return new pagereference('/' + oppId);
    }

}