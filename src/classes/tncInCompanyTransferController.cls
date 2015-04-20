public  class tncInCompanyTransferController {
     
	public tncInCompanyTransferIterator pager;
	
    public tncReasonData selectedReasonData         {get; set;}
    
    public boolean oldworldMessage                  {get; set;}
    public id oldworldOppId                         {get; set;}
    public string oldworldoppNo                     {get; set;}
    public string reasonErrorMessage                {get; set;}
    public List<tncEventsWrapper> eventsListing     {get; set;}
    
    
    public boolean getReasonError                   {get; set;}
    public boolean displayCancellationFeesSection   {get; set;}
    public boolean displayEventSelectionSection     {get; set;}
    
    public List<tncEventsWrapper> selectedEventsListing      {get; set;}
    public List<SelectOption> selectOptionReasons            {get; set;}
    public List<Transfer_Cancellation_Reasons__c> tcReasons  {get; set;}
    public List<SelectOption> selectOptionAction            {get; set;}
    
    public boolean showError                                 {get; set;}
    public string transferError                              {get; set;}
    
    Id oppId;
        
    public tncInCompanyTransferController(){
    	
    	oppId = System.currentPageReference().getParameters().get('oppId');

        displayCancellationFeesSection = false;
        displayEventSelectionSection = true;
        
    	pager = new tncInCompanyTransferIterator(10, oppId);
    	
    	selectedReasonData = new tncReasonData();
    	selectedReasonData.cancellationRequestedOn = date.Today().format();
    	
    	oldworldMessage = pager.oldWorldInvoiceMessage;
        oldworldOppId = pager.oldWorldInvoiceOppID;
        oldworldoppNo = pager.oldWorldInvoiceOppName; 
        
        selectedEventsListing = new List<tncEventsWrapper>();
        
        selectOptionReasons = new List<SelectOption>();
        tcReasons = [select id, Name, Notes_Required__c, Fees_To_Be_Applied__c, Need_Attachments__c, Event_Status__c  from Transfer_Cancellation_Reasons__c where Active__c = true];
            
        selectOptionReasons.add(new SelectOption('Select Reason', 'Select Reason'));
        for (Transfer_Cancellation_Reasons__c tcReason : tcReasons){
                selectOptionReasons.add(new SelectOption(tcReason.Name, tcReason.Name));
        }
        selectOptionAction = new List<SelectOption>();
        selectOptionAction.add(new SelectOption('Select Action', 'Select Action'));
        selectOptionAction.add(new SelectOption('Request Event', 'Request Event'));
        selectOptionAction.add(new SelectOption('To be Transferred', 'To be Transferred'));
        
        next();
    }
     
    /*
     * checks if there is a next page
    */        
    public Boolean hasNext {
        get {
            return pager.hasNext();
        }
        set;
    }
    
    /*
     * checks if there is a previous page
    */     
    public Boolean hasPrevious {
        get {
            return pager.hasPrevious();
        }
        set;
    }
    
    /*
     * moves to next set of records
    */     
    public void next() {
        eventsListing = pager.next();
    }
    
    /*
     * moves to previous set of records
    */     
    public void previous() {
        eventsListing = pager.previous();
    }
    
    /*
	 * populates records that have been selected by the user 
	 * sets the flag to show or hide a section.
	*/ 
    public pagereference showTransferFeeSection(){
        
        transferError = '';
        showError = false;
        selectedEventsListing.clear();
        for (tncEventsWrapper eventIsSelected : pager.transferEvents ){
			if (eventIsSelected.isSelected) {
                boolean rowHasError = false;
                
                integer numberOfAttachments;
                try{
                	numberOfAttachments = (integer)[select count(Id) totalattachments from Attachment where ParentId = :oppId][0].get('totalattachments');
                } catch (Exception e) {
                    numberOfAttachments = 0;
                }
                
                system.debug('eventIsSelected.reasonData ' + eventIsSelected.reasonData);
                
                if (eventIsSelected.reasonData.transferRequestedOn == ''){
                    transferError += 'Error: ' + eventIsSelected.event.Name + ': Transfer Request Date is required <BR/>';
                    rowHasError = true;
                    system.debug('1');
                } else if (eventIsSelected.reasonData.transferRequestedOn != '' &&
                    date.parse(eventIsSelected.reasonData.transferRequestedOn) > system.today()){
                    transferError += 'Error: ' + eventIsSelected.event.Name + ': Transfer Request Date cannot be in the future <BR/>';
                    rowHasError = true;
                    system.debug('2');
                }
                if (eventIsSelected.reasonData.reason == 'Select Reason'){
                    transferError += 'Error: ' + eventIsSelected.event.Name + ': Transfer Reason Invalid. <BR/>';
                    rowHasError = true;
                    system.debug('3');
                } else {
                    for (Transfer_Cancellation_Reasons__c checkReason : tcReasons){
                        
                        if (eventIsSelected.reasonData.reason == checkreason.Name){
                            eventIsSelected.reasonData.reasonId = checkreason.Id;
                            eventIsSelected.reasonData.eventStatus = checkreason.Event_Status__c;
                            eventIsSelected.feesToBeApplied = checkReason.Fees_To_Be_Applied__c;
                        }
                        
                        if (eventIsSelected.reasonData.reason == checkreason.Name && 
                            eventIsSelected.reasonData.reasonNote == '' &&
                            (checkreason.Notes_Required__c == true || checkreason.Need_Attachments__c == true)){
                                if (checkreason.Notes_Required__c == true) {
                                    transferError += 'Error: ' + eventIsSelected.event.Name + ': Transfer Notes are required <BR/>';
                                    rowHasError = true;
                                 	system.debug('4');
                                }
                                if (checkreason.Need_Attachments__c == true && numberOfAttachments == 0){
                                    transferError += 'Error: ' + eventIsSelected.event.Name + ': Need Attachments for Opp <a href="/' + 
                                        				 eventIsSelected.event.Opportunity__c + '" target="_blank">' + eventIsSelected.event.Opportunity__r.Opportunity_Number__c +
                                        				 '</a> to proceed <BR/>';
                                    rowHasError = true;
                                    system.debug('5');
                                }
                        }
                    }
                    system.debug('eventIsSelected.reasonData ' + eventIsSelected.reasonData);
                }
                if (rowHasError == false){
                    tncEventsWrapper addEvent = eventIsSelected;
                    addEvent.processTransferFee();
                    addEvent.processBSCLiability();
                    selectedEventsListing.add(addEvent); 
                } else {
                	showError = true;
                }
            }
        }
        
        system.debug(transferError);
        if (selectedEventsListing.size() == 0 && transferError == ''){
        	showError = true;
            transferError += 'Error: Select atleast one Event OR correct errors.<BR/>';
            displayCancellationFeesSection = false;
            displayEventSelectionSection = true;
        }  else if (selectedEventsListing.size() > 0 && transferError == ''){
            displayCancellationFeesSection = true;
            displayEventSelectionSection = false;
        } else {
            displayCancellationFeesSection = false;
            displayEventSelectionSection = true;
        }
        return null;
    }
    
    /*
	 * show the events selection section 
	*/
    public void showEventsToSelect(){
        displayCancellationFeesSection = false;
        displayEventSelectionSection = true;
    }
    
    
    /*
	 * Auto select all records.
	*/ 
    public void AutoSelectAllRecords(){
        for (tncEventsWrapper eventWrap : pager.transferEvents ){
            eventWrap.isSelected = true;
        }
        //this.showTransferFeeSection();
    }
    
    public pagereference process(){
        system.debug('Start Transfer Process');
        //list<tncEventsWrapper> eventsToBeTransferred = new list<tncEventsWrapper>();
        list<tncEventsWrapper> requestEvent = new list<tncEventsWrapper>();
        
        set<string> idRequest = new set<string>();
        
        for (tncEventsWrapper evt : selectedEventsListing){
            if (evt.transferAction == 'To be Transferred'){
                //eventsToBeTransferred.add(evt);
            } else {
                requestEvent.add(evt);
                idRequest.add(evt.opportunityLineItem.Id +':'+evt.event.id);
            }
        }
        
        system.debug('eventsToBeTransferred: ' + selectedEventsListing);
        system.debug('requestEvent: ' + requestEvent);
        
        tncHelper.processInCompanyToBeTransferred(selectedEventsListing);
        //
        system.debug('Finish Transfer Process');
        
        
        if (requestEvent.size() > 0){
            string idString = '';
            integer i = 1;
            for (string idURL :idRequest){
                if (i == idrequest.size())
                    idstring += string.valueof(idURL);
                else
	                idstring += string.valueof(idURL) + ',';
                
                i++;
            }
            return new pagereference('/apex/tncRequestEvent?Id=' + string.valueOf(oppId)+'&opl='+idstring);
        } else {
        	return new pagereference('/' + oppId);
        }
        //return new pagereference('/' + oppId);
    }
    
    public pagereference cancel(){
        return new pagereference('/' + oppId);
    }
}