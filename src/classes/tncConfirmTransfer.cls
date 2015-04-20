public class tncConfirmTransfer{
    
    public id oppId;
    public list<ConfirmEvents> events {get;set;}
    public list<ConfirmEvents> selectedEvents {get;set;}
    PricebookEntry pbe;
    Opportunity newOpp;
    Opportunity opp;
    
    public boolean hasRows {get; set;}
    
    public tncConfirmTransfer(){
        oppId = System.currentPageReference().getParameters().get('oppId');
        events = new list<ConfirmEvents>();
        selectedEvents = new list<ConfirmEvents>();
        
        list<id> oplIds = new list<id>();

        for (Special_Event__c evt :[select Id,Name,StartDate__c,EndDate__c,Liability_at_Cancellation_Transfer__c,
                                    Transferred_To__r.Id, Transferred_To__r.Name,Transferred_To__r.StartDate__c, Transferred_To__r.EndDate__c,
                                    (select id, OPL_ID__c  from R00N50000001mIaiEAE__r), Transfer_Cancellation_Reason__r.Transfer_Event_Status__c,
                                    Opportunity__r.Account.Name, Opportunity__r.Opportunity_Number__c, 
                                    Product__c, Original_TnC_Liability__c
                                    from Special_Event__c where Status__c ='To Be Transferred' and Transferred_To__c != null 
                                    and Transferred_To__r.Status__c = 'Resourced' 
                                    and Opportunity__c = :oppId] ){

            events.add(new ConfirmEvents(evt,false));
                                        
            for (Special_Event_Booking__c booking : evt.R00N50000001mIaiEAE__r){
                system.debug('Special_Event_Booking__c booking - ' + booking);
                oplIDs.add(id.valueof(booking.OPL_ID__c));
            }
        }
        if (events.size() > 0){
            hasRows = true;
            list<OpportunityLineItem> oppLines = [select unitprice, id, pricebookentry.product2.name, Quantity, OpportunityId, 
                                                  PricebookEntry.Product2.Cancellation_Fee_Product__c,
                                                  PricebookEntry.Product2.Transfer_Fee_Product__c,
                                                  PricebookEntry.pricebook2id, PricebookEntry.Product2Id 
                                                  from opportunitylineitem where id in :oplIDs];
            
            id product2Id, pricebook2Id;
            
            for (OpportunityLineItem opl : oppLines){
                product2Id = opl.PricebookEntry.Product2.Transfer_Fee_Product__c;
                pricebook2Id = opl.PricebookEntry.pricebook2id;
            }
            
            pbe = [select id, Pricebook2Id from pricebookentry where  Product2Id =:product2Id and Pricebook2Id =:pricebook2Id ];
            system.debug('pbe:'+pbe);
            string oppSOQL = Utilities.getCreatableFieldsSOQL('Opportunity');
            opp = database.query(oppSOQL + ' where id = :oppId ');
            //system.debug('opp.IC_Price_Variation_Approved__c - ' + opp.IC_Price_Variation_Approved__c);
            newOpp = null;
        } else {
            hasRows = false;
        }
    }
    
    
    public class ConfirmEvents{
        public Special_Event__c event {get; set;}
        public boolean selected       {get; set;}
        OpportunityLineItem oli       {get; set;}
            
        public ConfirmEvents(Special_Event__c event, boolean selected){
            this.event = event;
            this.selected = selected;
        }
    }
    
    public PageReference cancel(){
        return new PageReference('/'+oppId); 
    }
    
    public PageReference confirmTransfer(){

        Savepoint SP = database.setSavepoint();
        
        try{
            selectedEvents.clear();
            boolean quoteProposal = false;
            list<Opportunity_Product_History__c> oplHistories = new list<Opportunity_Product_History__c>();

            
            list<id> eventsTransferredTo = new list<id>();
            
            for (ConfirmEvents ce :  events){
                if (ce.selected){
                    eventsTransferredTo.add(ce.event.Transferred_To__c);
                }
            }
            
            Map<id,Special_Event__c> transferredTo = new map<id,Special_Event__c>([select id,(select id from R00N50000001mIaiEAE__r) 
                                                                                   from Special_Event__c where id in :eventsTransferredTo]);
            
            //list<sobject> updates = new list<sobject>(); // Commented By Rahul
            list<Special_Event_Booking__c> updatesSpecial_Event_Booking = new list<Special_Event_Booking__c>(); // New Variable created - Rahul
            list<Special_Event__c> updatesSpecial_Event = new list<Special_Event__c>(); // New Variable created - Rahul

            system.debug('ConfirmEvents events');
            
            for (ConfirmEvents ce :  events){
                if (ce.selected){
                    if (newOpp == null){

                        newOpp = opp.Clone(false,true); 
                        
                        newOpp.StageName = 'Qualifying';
                        newOpp.Pricebook2Id = pbe.Pricebook2Id; 
                        newOpp.Name = ce.event.Opportunity__r.Account.Name + ' Transfer Fee(s) ' + ce.event.Opportunity__r.Opportunity_Number__c;
                        newOpp.Original_Opportunity__c = oppId;
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
                        
                        opp.Transfer_Cancellation__c = true;
                        
                        list<OpportunityContactRole> newOCRs = new list<OpportunityContactRole>();
                        string ocrSOQL = Utilities.getCreatableFieldsSOQL('OpportunityContactRole');
                        for (OpportunityContactRole ocr : database.query(ocrSOQL + 'where OpportunityId = :oppId') ){
                            system.debug('for (OpportunityContactRole ocr');
                            OpportunityContactRole newOCR = ocr.clone();
                            newOCR.OpportunityId = newOpp.Id;
                            newOCRs.add(newOCR);
                        }
                        if (newOCRs.size() > 0){
                            system.debug('if (newOCRs.size() > 0)');
                            insert newOCRs;
                        }
                    }
                    
                    //oplhistory.Cancellation_Fee_Opportunity__c = newOpp.Id;
                    //oplHistories.add(oplhistory);
                    system.debug('OpportunityLineItem creation');
                    OpportunityLineItem oliforNewOpp = new OpportunityLineItem();
                    
                    oliforNewOpp.OpportunityId = newOpp.Id;
                    oliforNewOpp.PricebookEntryId = pbe.id;
                    oliforNewOpp.UnitPrice = ce.event.Liability_at_Cancellation_Transfer__c;
                    oliforNewOpp.T_C_Price__c = ce.event.Original_TnC_Liability__c;
                    if (ce.event.Original_TnC_Liability__c != ce.event.Liability_at_Cancellation_Transfer__c){
                        system.debug('if (ce.event.Original_TnC_Liability__c');
                        oliforNewOpp.T_C_Price_Variation__c = true;
                    }
                    oliforNewOpp.Quantity = 1;
                    oliforNewOpp.T_C_Price_Variation__c = true;
                    insert oliforNewOpp;
                    
                    if (ce.event.Liability_at_Cancellation_Transfer__c == ce.event.Original_TnC_Liability__c && quoteProposal == false){
                        system.debug('if (ce.event.Liability_at_Cancellation_Transfer__c');
                        newOpp.StageName = 'Booking Received';
                        newOpp.Probability = 100;
                        newOpp.ForecastCategoryName = 'Closed';
                        newOpp.Finance_to_Invoice_Opp__c = true;
                    } else if (ce.event.Liability_at_Cancellation_Transfer__c != ce.event.Original_TnC_Liability__c ){
                        system.debug('else if (ce.event.Liability_at_Cancellation_Transfer__c');
                        quoteProposal = true;
                        newOpp.StageName = 'Quote/Proposal';
                        newOpp.Probability = 40;
                        newOpp.ForecastCategoryName = 'Best Case';
                        newOpp.Finance_to_Invoice_Opp__c = false;
                    }

                    system.debug('Migrated__c - ' + newOpp.Migrated__c);
                    system.debug('Price_Approval_Given__c - ' + newOpp.Price_Approval_Given__c);
                    system.debug('Discounted_Products__c - ' + newOpp.Discounted_Products__c);
                    system.debug('StageName - ' + newOpp.StageName);
                    
                    if (newOpp.StageName == 'Booking Received' || newOpp.StageName == 'Quote/Proposal'){
                        system.debug('if (newOpp.StageName');
                        update newOpp;
                    }
                    ce.event.Status__c = ce.event.Transfer_Cancellation_Reason__r.Transfer_Event_Status__c;
                    ce.event.Stage__c = 'Cancelled';
                    ce.event.Opportunity__c = newOpp.Id;
                    //updates.add(ce.event); // Commented By Rahul
                    updatesSpecial_Event.add(ce.event);
                    
                    for (Special_Event_Booking__c booking  :ce.event.R00N50000001mIaiEAE__r){
                        system.debug('for (Special_Event_Booking__c 1');
                        booking.Status__c = 'Transferred';
                        booking.Opportunity__c = newOpp.Id;
                        booking.OPL_ID__c = oliforNewOpp.id;
                        booking.Transfer_To__c = ce.event.Transferred_To__c;
                        //updates.add(booking); // Commented By Rahul
                        updatesSpecial_Event_Booking.add(booking);
                    }
                    
                    Special_Event__c transferevt = transferredTo.get(ce.event.Transferred_To__c);
                    transferevt.Status__c = 'Confirmed';
                    transferevt.Stage__c = 'Confirmed';
                    for (Special_Event_Booking__c booking  : transferevt.R00N50000001mIaiEAE__r){
                        system.debug('for (Special_Event_Booking__c 2');
                        booking.Status__c = 'Confirmed';
                        //updates.add(booking); // Commented By Rahul
                        updatesSpecial_Event_Booking.add(booking);
                    }
                    //updates.add(transferevt); // Commented By Rahul
                    updatesSpecial_Event.add(transferevt);
                }
            }

            system.debug('Before update & insert');
/*
            if (updates.size() >0) // Commented By Rahul
                update updates;
*/
            if (updatesSpecial_Event.size() >0)
                update updatesSpecial_Event;
            if (updatesSpecial_Event_Booking.size() >0)
                update updatesSpecial_Event_Booking;


            system.debug('update updates');
            if (oplHistories.size() >0)
                insert oplHistories;
            system.debug('insert oplHistories');
                        
            if (opp != null){
                update opp;
            }

            system.debug('update opp');
        }
        catch (Exception E){
            database.rollback(SP);
             
            throw new tncHelper.tncException(e.getMessage() + ' ' + e.getStackTraceString());
        }

        system.debug('End confirmTransfer - ' + oppId);
        return new pagereference('/'+oppId );
    }

}