/*
* This Controller class is used in the PageComponent tncInCompanyCancellation
* The corresponding VF component and page can be used in Opportunity and BSC Events via click of a Button.
* The button should be set to send parameter ie. opportunity.id or Special_Event__c.id and
* set another parameter "Object" to the value of "Opportunity" or "Event" respectively.
*/

public without sharing class tncInCompanyCancellationController{

    public tncInCompanyCancellationIterator obj;
    public List<tncEventsWrapper> eventsListing                            {get; set;}
    public boolean displayCancellationFeesSection                        {get; set;}
    public boolean displayEventSelectionSection                  {get; set;}

    public boolean oldworldMessage                                   {get; set;}
    public id oldworldOppId                                          {get; set;}
    public string oldworldoppNo                                  {get; set;}
    public List<tncEventsWrapper> selectedEventsListing      {get; set;}
    public List<SelectOption> selectOptionReasons            {get; set;}
    public List<Transfer_Cancellation_Reasons__c> tcReasons  {get; set;}
    public boolean showError                                 {get; set;}
    public string cancellationError                          {get; set;}

    private string whichObject                               {get; set;}
    private string recordId                                  {get; set;}

    /*
    * Constructor
    * Sets the query filter and initiates paging. Defaults to first page.
    */
    public tncInCompanyCancellationController(){
        
        recordid = System.currentPageReference().getParameters().get('id');
        whichobject = System.currentPageReference().getParameters().get('Object');
        
        string allClear = tncHelper.allowedToCancelInCompanyEvent(whichobject, recordid);
        allClear = 'All Clear';
        if (allClear == 'All Clear' || allClear == 'Part Invoicing'){
            string filter = '';
            displayCancellationFeesSection = false;
            displayEventSelectionSection = true;
            
            if (whichobject=='Opportunity') {
                filter = ' where Opportunity__c = \''+recordid+'\' ';
            } else if (whichobject=='Event') {
                filter = ' where id = \''+recordid+'\' ';
            }
            
            if (test.isRunningTest()){
                obj = new tncInCompanyCancellationIterator(filter,1);
            } else {
                obj = new tncInCompanyCancellationIterator(filter,10);
            }
            
            oldworldMessage = obj.oldWorldInvoiceMessage;
            oldworldOppId = obj.oldWorldInvoiceOppID;
            oldworldoppNo = obj.oldWorldInvoiceOppName;
            
            selectedEventsListing = new List<tncEventsWrapper>(); 
            
            selectOptionReasons = new List<SelectOption>();
            tcReasons = [select id, Name, Notes_Required__c, Fees_To_Be_Applied__c, Need_Attachments__c, Event_Status__c  from Transfer_Cancellation_Reasons__c where Active__c = true];
            
            selectOptionReasons.add(new SelectOption('Select Reason', 'Select Reason'));
            for (Transfer_Cancellation_Reasons__c tcReason : tcReasons){
                selectOptionReasons.add(new SelectOption(tcReason.Name, tcReason.Name));
            }
            
            next();
        } else {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, allClear));
        }
        
    }
    
    /*
    * checks if there is a next page
    */        
    public Boolean hasNext {
        get {
            return obj.hasNext();
        }
        set;
    }
    
    /*
    * checks if there is a previous page
    */     
    public Boolean hasPrevious {
        get {
            return obj.hasPrevious();
        }
        set;
    }
    
    /*
    * moves to next set of records
    */     
    public void next() {
        eventsListing = obj.next();
    }
    
    /*
    * moves to previous set of records
    */     
    public void previous() {
        eventsListing = obj.previous();
    }
    
    /*
    * populates records that have been selected by the user 
    * sets the flag to show or hide a section.
    */ 
    public pagereference showCancellationFeeSection(){
        
        cancellationError = '';
        showError = false;
        selectedEventsListing.clear();
        for (tncEventsWrapper eventIsSelected : obj.eventsList ){
                        if (eventIsSelected.isSelected) {
                boolean rowHasError = false;
                
                integer numberOfAttachments;
                try{
                        numberOfAttachments = (integer)[select count(Id) totalattachments from Attachment where ParentId = :recordid][0].get('totalattachments');
                } catch (Exception e) {
                    numberOfAttachments = 0;
                }
                
                system.debug('eventIsSelected.reasonData ' + eventIsSelected.reasonData);
                
                if (eventIsSelected.reasonData.cancellationRequestedOn == ''){
                    cancellationError += 'Error: ' + eventIsSelected.event.Name + ': Cancellation Request Date is required <BR/>';
                    rowHasError = true;
                    system.debug('1');
                } else if (eventIsSelected.reasonData.cancellationRequestedOn != '' && date.parse(eventIsSelected.reasonData.cancellationRequestedOn) > system.today()){
                    cancellationError += 'Error: ' + eventIsSelected.event.Name + ': Cancellation Request Date cannot be in the future <BR/>';
                    rowHasError = true;
                    system.debug('2');
                }
                if (eventIsSelected.reasonData.reason == 'Select Reason'){
                    cancellationError += 'Error: ' + eventIsSelected.event.Name + ': Cancellation Reason Invalid. <BR/>';
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
                                    cancellationError += 'Error: ' + eventIsSelected.event.Name + ': Cancellation Notes are required <BR/>';
                                    rowHasError = true;
                                        system.debug('4');
                                }
                                if (checkreason.Need_Attachments__c == true && numberOfAttachments == 0){
                                    cancellationError += 'Error: ' + eventIsSelected.event.Name + ': Need Attachments for Opp <a href="/' + 
                                                                         eventIsSelected.event.Opportunity__c + '" target="_blank">' + eventIsSelected.event.Opportunity__r.Opportunity_Number__c +
                                                                         '</a> to Proceed <BR/>';
                                    rowHasError = true;
                                    system.debug('5');
                                }
                            }
                    }
                    system.debug('eventIsSelected.reasonData ' + eventIsSelected.reasonData);
                }
                if (rowHasError == false){
                    tncEventsWrapper addEvent = eventIsSelected; 
                    addEvent.processCancellationFee();
                    addEvent.processBSCLiability();
                    selectedEventsListing.add(addEvent); 
                } else {
                        showError = true;
                }
            }
        }
        
        system.debug(cancellationError);
        if (selectedEventsListing.size() == 0 && cancellationError == ''){
                showError = true;
            cancellationError += 'Error: Select atleast one event OR correct errors.<BR/>';
            displayCancellationFeesSection = false;
            displayEventSelectionSection = true;
        }  else if (selectedEventsListing.size() > 0 && cancellationError == ''){
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
        for (tncEventsWrapper eventWrap : obj.eventsList ){
            eventWrap.isSelected = true;
        }
        //this.showCancellationFeeSection();
    }
    
    public PageReference cancel(){
        return new pagereference('/' + recordid);
    } 
    
    /*
    * Process cancellation of events.
    * Calls method in tncHelper to do all the work needed.
    */
    public PageReference processCancellation(){
        system.debug('Calling tncHelper.processInCompanyCancellation');
        tncHelper.processInCompanyCancellation(selectedEventsListing);
        system.debug('Finished tncHelper.processInCompanyCancellation');
        
        return new pagereference('/' + recordid);
    }
}