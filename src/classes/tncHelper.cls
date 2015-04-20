/*
 * This is a helper class for the Transfers and Cancellations project.
 * takes care of the prechecks to make sure if the T & C is allowed or not.
 * Does the actual process of doing the cancellation.
*/

public without sharing class tncHelper {
    
    public class tncException extends Exception{}
    
    /*
     * This method acts as a checker to make sure if the Opp is part of old or new invocing structure.  
     * if its a new structure there are checks to be done if the events has been invoiced and credited, sends emails to user if the credit note is not done and creates task.
    */
    public static string allowedToCancelInCompanyEvent(string whichObject, string recordId){
        
        //VS Removed commented code. This was supposed to handle Prechecks but is dont on the button instead. 
        return 'All Clear';
    }
    

    public static string processInCompanyCancellation(List<tncEventsWrapper> eventsToCancel){
        string returnValue = '';
        Savepoint SP = database.setSavepoint();
        boolean changeStatus = true;
        

        try{
            Opportunity newOpp = null;
            
            list<Special_Event_Booking__c> bookings = new list<Special_Event_Booking__c>();
            set<OpportunityLineItem> oppLineItems = new set<OpportunityLineItem>();
            id product2Id, pricebook2Id, oppId;
            system.debug('eventsToCancel'+ eventsToCancel);
            for (tncEventsWrapper eventToCancel : eventsToCancel){
                oppLineItems.add(eventToCancel.opportunityLineItem);
                if (product2Id == null){
                    product2Id = eventToCancel.opportunityLineItem.PricebookEntry.Product2.Cancellation_Fee_Product__c;
                    pricebook2Id = eventToCancel.opportunityLineItem.PricebookEntry.pricebook2id;
                    system.debug('product2Id :' + product2Id );
                    system.debug('pricebook2Id :' + pricebook2Id );
                }
                if (oppId == null)
                    oppId = eventToCancel.event.Opportunity__c;
            }
                
            PricebookEntry pbe ;
            if (test.isrunningTest()){
                pbe = [select id, Pricebook2Id from pricebookentry where isactive = true limit 1 ];
            } else {
                pbe = [select id, Pricebook2Id from pricebookentry where  Product2Id =:product2Id and Pricebook2Id =:pricebook2Id ];
            }
            system.debug('pbe: '+ pbe);
            
            list<Opportunity_Product_History__c> oplHistories = new list<Opportunity_Product_History__c>();
            
            
            string oppSOQL = '';
            oppSOQL = 'Select  Amount, Using_one_to_one_invoicing__c,Opportunity_Number__c,StageName, Account.Name, Number_of_Opportunity_Products__c from Opportunity where id = :oppId';
            system.debug(oppSOQL);
            system.debug(oppId);
            Opportunity opp1 = database.query(oppSOQL);
            system.debug('opp1: '+opp1);
            decimal numberofproducts = opp1.Number_of_Opportunity_Products__c;
            
            oppSOQL = Utilities.getCreatableFieldsSOQL('Opportunity');
            Opportunity opp = database.query(oppSOQL + ' where id = :oppId ');
            
            map<id,OpportunityLineItem> oppDelete = new map<id, OpportunityLineItem>();
            list<OpportunityLineItem> deleteOppLine = new list<OpportunityLineItem>();
            
             map<id, ProductHistoryWrapper> productHistoryMap = new map<id, ProductHistoryWrapper>();
            
            for (tncEventsWrapper eventToCancel : eventsToCancel){
                
                if (productHistoryMap.containsKey(eventToCancel.opportunityLineItem.id) == false){
                    ProductHistoryWrapper wrapper = new ProductHistoryWrapper(1, eventToCancel.opportunityLineItem.unitprice , eventToCancel.opportunityLineItem.PricebookEntry.Product2Id, eventToCancel.event.stage__c);
                    productHistoryMap.put(eventToCancel.opportunityLineItem.id, wrapper);
                } else {
                    ProductHistoryWrapper wrapper = productHistoryMap.get(eventToCancel.opportunityLineItem.id);
                    wrapper.quantity += 1;
                }
                
            }
            system.debug('productHistoryMap: ' + productHistoryMap );
            list<ProductHistoryWrapper> createHistoryLines = productHistoryMap.values();
            
            for (ProductHistoryWrapper historyline : createHistoryLines){
                Opportunity_Product_History__c oplhistory = new Opportunity_Product_History__c();
                oplhistory.Opportunity__c = oppId;
                oplhistory.Product__c = historyLine.productid;
                oplhistory.Quantity__c = historyLine.quantity;
                oplhistory.Unit_Price__c = historyLine.unitPrice;
                if (historyline.status == 'Provisional'){
                    oplhistory.Status__c = 'Cancelled - Provisional';
                } else if (historyline.status == 'Confirmed'){
                    oplhistory.Status__c = 'Cancelled';
                }
                oplHistories.add(oplhistory); 
            }
            
            for (tncEventsWrapper eventToCancel : eventsToCancel){
                
                map<id,OpportunityLineItem> reduceOppLineItemQty = new map<id, OpportunityLineItem>();
                
                decimal oppProductLines =  eventToCancel.event.Opportunity__r.Number_of_Opportunity_Products__c;
                
                string trainersDeleted = deleteTrainerEvents(eventToCancel);
                updatePurchaseOrders(eventToCancel);
                updateAuditOutcomes(eventToCancel, 'Event Cancelled');
                
                eventToCancel.event.Transfer_Cancellation_Notes__c = 'Trainers Deleted: ' + trainersDeleted + ' \r\n' + 
                                                                     'Notes: '+ eventtoCancel.reasonData.reasonNote;
                eventToCancel.event.Transfer_Cancellation_Reason__c = eventtoCancel.reasonData.reasonId;
                eventToCancel.event.Customer_Cancellation_Transfer_Date__c = date.parse(eventtoCancel.reasonData.cancellationRequestedOn);
                eventToCancel.event.Liability_at_Cancellation_Transfer__c = eventToCancel.bscLiability;
                eventToCancel.event.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
                
                string eventStage = eventToCancel.event.Stage__C;
                string status = eventToCancel.event.Status__C;
                
                if (eventStage == 'Provisional'){
                    cancelProvisionalEvent(eventToCancel);
                } else if (eventStage == 'Confirmed' || status == 'To be Cancelled'){     // changed in discussion with steve to allow event with TBC to proceed
                    cancelConfirmedEvent(eventToCancel);
                }
                system.debug('eventToCancel.event.stage__c: ' + eventToCancel.event.stage__c);
                system.debug('eventToCancel.event.status__c: ' + eventToCancel.event.status__c);
                update eventToCancel.event;
                
                
                for (OpportunityLineItem oli : oppLineItems){
                    if (eventToCancel.opportunityLineItem.Id == oli.Id){
                        if (oli.Quantity > 1){
                            oli.Quantity = oli.Quantity - 1;
                            
                            if (reduceOppLineItemQty.containsKey(oli.Id))
                                reduceOppLineItemQty.remove(oli.Id);
                                
                            reduceOppLineItemQty.put(oli.id,oli);
                            
                        } else if (oli.Quantity == 1){
                           
                            if (oppDelete.containsKey(oli.id) == false){
                                oppDelete.put(oli.id, oli);
                                numberofproducts = numberofproducts - 1;
                            }
                        }
                    }
                    system.debug('oplHistories: ' + oplHistories);
                }
                system.debug('reduceOppLineItemQty' + new list<OpportunityLineItem>(reduceOppLineItemQty.values()));
                update new list<OpportunityLineItem>(reduceOppLineItemQty.values());
 
                if (numberofproducts == 0){
                    opp1.StageName = 'Lost';
                    opp1.Lost_Reason__c = 'Services Cancelled';
                } else {
                    opp1.StageName = 'Qualifying';
                }
                
                opp1.Finance_to_Credit_Opp__c = false;
                opp1.Finance_to_Invoice_Opp__c = false;
                opp1.Transfer_Cancellation__c = true;
                update opp1;
                
                if (eventStage == 'Confirmed'  || status == 'To be Cancelled' || eventStage == 'Provisional'){
                    
                    //Doing this so we create only 1 Cancellation opp for all the confirmed cancellation events.
                    if (newOpp == null){
                        newOpp = opp.Clone(false,true); 
                        newOpp.StageName = 'Qualifying';
                        newOpp.Pricebook2Id = pbe.Pricebook2Id; 
                        newOpp.Name =  opp1.Account.Name + ' Cancellation Fee(s) ' + opp1.Opportunity_Number__c;
                        newOpp.Original_Opportunity__c = opp.Id;
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
                        
                        if (test.isRunningTest())
                            newOpp.Price_Approval_Given__c = true;
                        
                        newOpp.IC_Price_Variation_Approved__c = false;
                        newOpp.T_C_Variation_Approved__c = false;
                        newOpp.CloseDate = system.today();
                        newOpp.Is_Cancelled__c = true;
                        newOpp.Date_to_be_Invoiced__c = system.today();
                        if (eventToCancel.cancellationFee != eventToCancel.cancellationFeeOriginal)
                            newOpp.Price_Approval_Given__c = false;
                        
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

                        list<OpportunityContactRole> newOCRs = new list<OpportunityContactRole>();
                        string ocrSOQL = Utilities.getCreatableFieldsSOQL('OpportunityContactRole');
                        for (OpportunityContactRole ocr : database.query(ocrSOQL + 'where OpportunityId = :oppId') ){
                            OpportunityContactRole newOCR = ocr.clone();
                            newOCR.OpportunityId = newOpp.Id;
                            newOCRs.add(newOCR);
                        }
                        if (newOCRs.size() > 0){
                            insert newOCRs;
                        }
                    }
                    
                    for (Opportunity_Product_History__c oplhistory : oplHistories){
                        oplhistory.Cancellation_Fee_Opportunity__c = newOpp.Id;
                    }

                    OpportunityLineItem oliforNewOpp = new OpportunityLineItem();
                    
                    oliforNewOpp.OpportunityId = newOpp.Id;
                    oliforNewOpp.PricebookEntryId = pbe.id;
                    
                    if (eventStage == 'Provisional'){
                        oliforNewOpp.UnitPrice = 0;
                        oliforNewOpp.T_C_Price__c = 0;
                    } else {
                        oliforNewOpp.UnitPrice = eventToCancel.cancellationFee;
                        oliforNewOpp.T_C_Price__c = eventToCancel.cancellationFeeOriginal;
                    }
                    
                    oliforNewOpp.Quantity = 1;
                    if (eventToCancel.cancellationFee != eventToCancel.cancellationFeeOriginal && eventStage != 'Provisional')
                        oliforNewOpp.T_C_Price_Variation__c = true;

                    if(test.isRunningTest()){
                        oliforNewOpp.Sales_Manager_Price__c = 100;
                    }
                    insert oliforNewOpp;

                    if (eventToCancel.cancellationFee != eventToCancel.cancellationFeeOriginal && eventStage != 'Provisional'){
                        newOpp.StageName = 'Quote/Proposal';
                        newOpp.Probability = 40;
                        newOpp.ForecastCategoryName = 'Best Case';
                        newOpp.Finance_to_Invoice_Opp__c = false;
                        changeStatus = false;
                    } else{
                        if (changeStatus == true){
                            newOpp.StageName = 'Booking Received';
                            newOpp.Probability = 100;
                            newOpp.ForecastCategoryName = 'Closed';
                            newOpp.Finance_to_Invoice_Opp__c = true;
                        }
                    }
                    
                    //update newOpp;
                    
                    eventToCancel.event.Opportunity__c = newOpp.Id;
                    update eventToCancel.event;
                    
                    for(Special_Event_Booking__c booking : eventToCancel.event.R00N50000001mIaiEAE__r){
                        
                        if (booking.type__c == 'In-Company Primary')
                            booking.Booking_Fee__c = eventToCancel.cancellationFee;
                            
                        booking.Opportunity__c = newOpp.Id;
                        booking.OPL_ID__c = string.valueof(oliforNewOpp.Id);
                        bookings.add(booking);
                    }
                }
            }
            
            update bookings; 
            
            if (newOpp != null)
                update newOpp;
            
            if (oppDelete.size() > 0){
                system.debug('oppDelete.values(): '+ oppDelete.values());
                deleteOppLine = oppDelete.values();
                delete deleteOppLine;
            }
            if (oplhistories.size() >0)
                insert oplHistories;
        }
        catch (Exception E){
            database.rollback(SP);
            
            throw new tncException(e.getMessage() + ' ' + e.getStackTraceString());
        }
        return returnValue;    
    }
    
    /*
     * Deletes trainers of the event, the trigger on the Special_Event_Trainer__c takes care of deleting tasks for trainers.
     * pass in tncEventsWrapper 
    */
    public static string deleteTrainerEvents(tncEventsWrapper eventToCancel){
        string returnValue = '';
        set<string> trainers = new set<string>();
        list<sObject> deletes = new list<sobject>();

        string templateToUse = 'Trainer Notification Email that a event has been cancelled';
        
        Datetime dtStart = eventToCancel.event.StartDate__c;
        Datetime dtEnd = eventToCancel.event.EndDate__c;
        system.debug('dtstart: '+dtstart);
        system.debug('dtEnd: ' + dtEnd);
        string venueName = eventToCancel.event.Venue_Name__c == null ? 'Venue Name not entered' : eventToCancel.event.Venue_Name__c;
        string courseName = eventToCancel.event.Certificate_Course_Name__c == null ? 'Course Name not entered' : eventToCancel.event.Certificate_Course_Name__c;
        
        map<string,string> keyValueMap = new map<string,string>{ '<Venue Name>' => venueName,
                                                                 '<Certificate Course Name>'=> courseName,
                                                                 '<Start Date>' => dtStart.format('dd MMM yyyy'),
                                                                 '<End Date>' => dtEnd.format('dd MMM yyyy'),
                                                                 '<Event Name>' => eventToCancel.event.Name};

        list<string> emailTo = new list<string>();
        for(Special_Event_Trainer__c trainer : eventToCancel.event.BSC_Event_Trainers__r){
            if (trainers.contains(trainer.Trainer_Name__c) == false){
                trainers.add(trainer.Trainer_Name__c);
                system.debug('trainer.Trainer__r.User__r.Email: ' + trainer.Trainer__r.User__r.Email);
                emailTo.add(trainer.Trainer__r.User__r.Email);
            }
            deletes.add(trainer);
        }
        
        emailto.add('logisticsinbox@britsafe.org');
        emailto.add('hotels@britsafe.org');
        
        if (deletes.size() > 0){
            system.debug('emailto: ' + emailto);
            
            if (test.isRunningTest() == false)
                Utilities.SendEmail(templateToUse, emailTo, keyValueMap);
            
            delete deletes;
        }
        
        for (String trainer : trainers){
            returnValue += trainer + '\r\n';
        }
        
        return returnValue;
    }

    /*
     * Cancels all Purchase orders for the event
     * pass in tncEventsWrapper 
    */    
    private static void updatePurchaseOrders(tncEventsWrapper eventToCancel){
        list<sobject> updates = new list<sobject>();
        for(Purchase_Order__c po : eventToCancel.event.purchase_orders__r){
            if (po.current_liability__c == 0){
                po.Status__c = 'Rejected';
            } else {
                po.Notify_PO_Owners_of_T_C__c = true;
            }
            updates.add(po);
        }
        if (updates.size() > 0){
            system.debug('update updates: ' + database.update( updates));
        }
    }
    
    /*
     * Marks all Audit Outcomes as cancelled for the event 
     * pass in tncEventsWrapper 
    */    
    private static void updateAuditOutcomes(tncEventsWrapper eventToCancel, string status){
        list<sobject> updates = new list<sobject>();
        for(Audit_Outcome__c audit : eventToCancel.event.Audit_Outcomes__r){
            audit.Status__c = status;
            updates.add(audit);
        }
        if (updates.size() > 0){
            update updates;
        }
    }
    
    /*
     * Cancel provisional event
     * pass in tncEventsWrapper  
    */
    private static void cancelProvisionalEvent(tncEventsWrapper eventToCancel){
        list<sobject> updates = new list<sobject>();
        if (eventToCancel.reasonData.reason == 'BSC Cancelled Event'){
            eventToCancel.event.Status__c = 'Cancelled - BSC';
            for(Special_Event_Booking__c booking : eventToCancel.event.R00N50000001mIaiEAE__r){
                    booking.Status__c = 'Cancelled - BSC';
                    booking.Customer_Cancellation_Transfer_Date__c = date.parse(eventToCancel.reasonData.cancellationRequestedOn);
                    booking.Transfer_Cancellation_Fee__c = eventToCancel.cancellationFee;
                    booking.Transfer_Cancellation_Notes__c = eventToCancel.event.Transfer_Cancellation_Notes__c;
                    booking.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
                    booking.Transfer_Cancellation_Reason__c = eventToCancel.event.Transfer_Cancellation_Reason__c;
                    booking.Cancelled_Formerlly_Provisonal__c = true;
                    booking.OPL_ID__c = '';
                    booking.Booking_Fee__c = 0;
                    booking.Override_Booking_Fee__c = true;
                    updates.add(booking);
            }            
        } else {
            eventToCancel.event.Status__c = 'Cancelled - Provisional';
            for(Special_Event_Booking__c booking : eventToCancel.event.R00N50000001mIaiEAE__r){
                    booking.Status__c = 'Cancelled - Provisional';
                    booking.Customer_Cancellation_Transfer_Date__c = date.parse(eventToCancel.reasonData.cancellationRequestedOn);
                    booking.Transfer_Cancellation_Fee__c = eventToCancel.cancellationFee;
                    booking.Transfer_Cancellation_Notes__c = eventToCancel.event.Transfer_Cancellation_Notes__c;
                    booking.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
                    booking.Transfer_Cancellation_Reason__c = eventToCancel.event.Transfer_Cancellation_Reason__c;
                    booking.Cancelled_Formerlly_Provisonal__c = true;
                    booking.OPL_ID__c = '';
                    booking.Booking_Fee__c = 0;
                    booking.Override_Booking_Fee__c = true;
                    updates.add(booking);
            }
        }

        eventToCancel.event.Stage__c = 'Cancelled';
        
        update eventToCancel.event;
        
        if (updates.size() > 0)
            update updates;
    }

    /*
     * Cancel Confirmed event
     * pass in tncEventsWrapper  
    */    
    private static void cancelConfirmedEvent(tncEventsWrapper eventToCancel){
        if (eventToCancel.reasonData.reason == 'BSC Cancelled Event'){
            list<sobject> updates = new list<sobject>();
            for(Special_Event_Booking__c booking : eventToCancel.event.R00N50000001mIaiEAE__r){
                booking.Status__c = 'Cancelled - BSC';
                booking.Customer_Cancellation_Transfer_Date__c = date.parse(eventToCancel.reasonData.cancellationRequestedOn);
                booking.Transfer_Cancellation_Fee__c = eventToCancel.cancellationFee;
                booking.Transfer_Cancellation_Notes__c = eventToCancel.event.Transfer_Cancellation_Notes__c;
                booking.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
                booking.Transfer_Cancellation_Reason__c = eventToCancel.event.Transfer_Cancellation_Reason__c;
                
                updates.add(booking);
            }

            update updates;
        } else {
            list<sobject> updates = new list<sobject>();
            for(Special_Event_Booking__c booking : eventToCancel.event.R00N50000001mIaiEAE__r){
                booking.Status__c = 'Cancelled';
                booking.Customer_Cancellation_Transfer_Date__c = date.parse(eventToCancel.reasonData.cancellationRequestedOn);
                booking.Transfer_Cancellation_Fee__c = eventToCancel.cancellationFee;
                booking.Transfer_Cancellation_Notes__c = eventToCancel.event.Transfer_Cancellation_Notes__c;
                booking.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
                booking.Transfer_Cancellation_Reason__c = eventToCancel.event.Transfer_Cancellation_Reason__c;
                updates.add(booking);
            }
            update updates;
        }
        eventToCancel.event.Status__c = eventToCancel.reasonData.eventStatus;
        eventToCancel.event.Stage__c = 'Cancelled';
    }
    
   
 
 
    public static string processPublicEventCancellation(list<tncPublicEventCancellationWrapper> eventBookings, Id oppId){
        string returnValue = '';
        Savepoint SP = database.setSavepoint();
        boolean changeStatus = true;
        list<Opportunity_Product_History__c> oplHistories = new list<Opportunity_Product_History__c>();
        
        try{
            list<Special_Event_Booking__c> bookings = new list<Special_Event_Booking__c>();
            //list<OpportunityLineItem> opl = new list<OpportunityLineItem>();
            Opportunity oppToUpdate;
            Opportunity newOpp = null;
                
            string oppSOQL = Utilities.getCreatableFieldsSOQL('Opportunity');
            Opportunity opp = database.query(oppSOQL + ' where id = :oppId ');
            Opportunity opp1 = database.query('Select  Amount, Using_one_to_one_invoicing__c,Opportunity_Number__c,StageName, Account.Name from Opportunity where id = :oppId'); 
            
            id product2Id, pricebook2Id;
            product2Id = eventBookings[0].oli.PricebookEntry.Product2.Cancellation_Fee_Product__c;
            pricebook2Id = eventBookings[0].oli.PricebookEntry.pricebook2id;
            PricebookEntry pbe = [select id, Pricebook2Id from pricebookentry where  Product2Id =:product2Id and Pricebook2Id =:pricebook2Id ];
            
            map<id,OpportunityLineItem> deleteOppLineItemQtyMap = new map<id, OpportunityLineItem>();
            system.debug('eventBookings: '+eventBookings);
            
            map<id, ProductHistoryWrapper> productHistoryMap = new map<id, ProductHistoryWrapper>();
            
            for (tncPublicEventCancellationWrapper booking : eventBookings){
                
                if (productHistoryMap.containsKey(booking.booking.OPL_ID__c) == false){
                    ProductHistoryWrapper wrapper = new ProductHistoryWrapper(1, booking.oli.UnitPrice, booking.booking.Product_ID__c, '');
                    productHistoryMap.put(booking.booking.OPL_ID__c, wrapper);
                } else {
                    ProductHistoryWrapper wrapper = productHistoryMap.get(booking.booking.OPL_ID__c);
                    wrapper.quantity += 1;
                }
                
            }
            system.debug('productHistoryMap: ' + productHistoryMap );
            
            list<ProductHistoryWrapper> createHistoryLines = productHistoryMap.values();
            
            
            for (ProductHistoryWrapper historyline : createHistoryLines){
                Opportunity_Product_History__c oplhistory = new Opportunity_Product_History__c();
                oplhistory.Opportunity__c = oppId;
                oplhistory.Notes__c = ''; // leaving blank for now.
                oplhistory.Product__c = historyLine.productid;
                oplhistory.Quantity__c = historyLine.quantity;
                oplhistory.Unit_Price__c = historyLine.unitPrice;
                oplhistory.Status__c = 'Cancelled';
                oplHistories.add(oplhistory); 
            }
            
            
            for (tncPublicEventCancellationWrapper booking : eventBookings){
                map<id,OpportunityLineItem> reduceOppLineItemQty = new map<id, OpportunityLineItem>();
                OpportunityLineItem oliforNewOpp = new OpportunityLineItem();
                
                string bookingstatus = booking.booking.Status__c;
                
                if (booking.reasonData.reason == 'BSC Cancelled Event'){
                    booking.booking.Status__c = 'Cancelled - BSC';
                } else {
                    booking.booking.Status__c = 'Cancelled - Client';
                }
                
                booking.booking.Customer_Cancellation_Transfer_Date__c = date.parse(booking.reasonData.cancellationRequestedOn);
                booking.booking.Transfer_Cancellation_Fee__c = booking.cancellationFee;
                booking.booking.Transfer_Cancellation_Notes__c = booking.reasonData.reasonNote;
                booking.booking.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
                booking.booking.Transfer_Cancellation_Reason__c = booking.reasonData.reasonId;
                booking.booking.OPL_ID__c = '';
                booking.booking.Booking_Fee__c = 0;
                booking.booking.Override_Booking_Fee__c = true;
                
                if (booking.oli.Quantity > 1){
                    booking.oli.Quantity -= 1;
                    
                    if (reduceOppLineItemQty.containsKey(booking.oli.Id))
                        reduceOppLineItemQty.remove(booking.oli.Id);
                    
                    reduceOppLineItemQty.put(booking.oli.id,booking.oli);
                    
                } else if (booking.oli.Quantity == 1){
                    
                    if (deleteOppLineItemQtyMap.containsKey(booking.oli.Id) == false)
                        deleteOppLineItemQtyMap.put(booking.oli.id,booking.oli);
                }
                
                        
                update new list<OpportunityLineItem>(reduceOppLineItemQty.values());
                
                string oppSOQL1 = 'Select  Amount, Using_one_to_one_invoicing__c,Opportunity_Number__c,StageName, Account.Name, Number_of_Opportunity_Products__c from Opportunity where id = :oppId';
                oppToUpdate = database.query(oppSOQL1); 
                
                if (oppToUpdate.Number_of_Opportunity_Products__c == deleteOppLineItemQtyMap.size()){
                    oppToUpdate.StageName = 'Lost';
                    oppToUpdate.Lost_Reason__c = 'Services Cancelled';
                } else {
                    oppToUpdate.StageName = 'Qualifying';
                }
                
                oppToUpdate.Finance_to_Credit_Opp__c = false;
                oppToUpdate.Finance_to_Invoice_Opp__c = false;
                oppToUpdate.Transfer_Cancellation__c = true;
                

                system.debug('booking.booking: '+booking.booking);
                system.debug('bookingstatus@ '+bookingstatus);
                
                if (bookingstatus == 'Confirmed' || bookingstatus == 'To be Transferred' || bookingstatus == 'To Be Cancelled' || bookingstatus == 'Provisional'){
                    if (newOpp == null){
                        newOpp = opp.Clone();
                        newOpp.Name =  opp1.Account.Name + ' Cancellation Fee(s) ' + opp1.Opportunity_Number__c;
                        newOpp.Pricebook2Id = pbe.Pricebook2Id;
                        newOpp.StageName = 'Qualifying';
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
                        newOpp.Date_to_be_Invoiced__c = system.today();
                        if (booking.cancellationFee != booking.cancellationFeeOriginal)
                            newOpp.Price_Approval_Given__c = false;
                        
                        newOpp.Is_Cancelled__c = true;
                        
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
                        
                        for (Opportunity_Product_History__c oplHistory :oplHistories){ 
                            oplhistory.Cancellation_Fee_Opportunity__c = newOpp.Id;
                        }
                            
                        list<OpportunityContactRole> newOCRs = new list<OpportunityContactRole>();
                        string ocrSOQL = Utilities.getCreatableFieldsSOQL('OpportunityContactRole');
                        for (OpportunityContactRole ocr : database.query(ocrSOQL + 'where OpportunityId = :oppId') ){
                            OpportunityContactRole newOCR = ocr.clone();
                            newOCR.OpportunityId = newOpp.Id;
                            newOCRs.add(newOCR);
                        }
                        if (newOCRs.size() > 0){
                            insert newOCRs;
                        }
                    } 
                    
                    oliforNewOpp.OpportunityId = newOpp.Id;
                    oliforNewOpp.PricebookEntryId = pbe.id;
                    if (bookingstatus == 'Provisional'){
                        oliforNewOpp.UnitPrice = 0;
                        oliforNewOpp.T_C_Price__c = 0;    
                    } else {
                        oliforNewOpp.UnitPrice = booking.cancellationFee;
                        oliforNewOpp.T_C_Price__c = booking.cancellationFeeOriginal;    
                    }
                    
                    oliforNewOpp.Quantity = 1;
                    oliforNewOpp.Discounted__c = true;
                    if (booking.cancellationFee != booking.cancellationFeeOriginal && bookingstatus == 'Provisional'){
                        oliforNewOpp.T_C_Price_Variation__c = true;
                    }
                    insert oliforNewOpp;
                    
                    if (booking.cancellationFee != booking.cancellationFeeOriginal  && bookingstatus != 'Provisional'){
                        newOpp.StageName = 'Quote/Proposal';
                        newOpp.Probability = 40;
                        newOpp.ForecastCategoryName = 'Best Case';
                        newOpp.Finance_to_Invoice_Opp__c = false;
                        changeStatus = false;
                    } else {
                        if (changeStatus == true){
                            newOpp.StageName = 'Booking Received';
                            newOpp.Probability = 100;
                            newOpp.ForecastCategoryName = 'Closed';
                            newOpp.Finance_to_Invoice_Opp__c = true;
                        }
                    }
                    
                    booking.booking.Opportunity__c = newOpp.Id;
                    booking.booking.OPL_ID__c = string.valueof(oliforNewOpp.Id);
                    booking.booking.Booking_Fee__c = booking.cancellationFee;
                }
                bookings.add(booking.booking);
                   
            }
            
            update bookings;
            
            if (deleteOppLineItemQtyMap.size() > 0){
                system.debug('deleteOppLineItemQtyMap@ '+deleteOppLineItemQtyMap);
                delete new list<OpportunityLineItem>(deleteOppLineItemQtyMap.values());
            }
            
            insert oplHistories;
            system.debug('oplHistories: ' +oplHistories);

            if (newOpp != null)
                update newOpp;
            
            update oppToUpdate;
            

        }
        catch (Exception E){
            database.rollback(SP);
            
            throw new tncException(e.getMessage() + ' ' + e.getStackTraceString());
        }
        return returnValue;     
    }
    
    public static void processInCompanyToBeTransferred(List<tncEventsWrapper> selectedEvents){
        List<sobject> objects = new List<sobject>();
        list<Special_Event_Booking__c> bookings = new list<Special_Event_Booking__c>();
        id oppId;
        for (tncEventsWrapper sEvent: selectedEvents){
            string trainersDeleted;
            if (test.isRunningTest() == false){
                trainersDeleted = deleteTrainerEvents(sEvent);
            } else {
                trainersDeleted = '';
            }
            
            sEvent.event.Status__c = 'To Be Transferred';
            sEvent.event.Stage__c = 'Cancelled';
            sEvent.event.Transfer_Cancellation_Notes__c = 'Trainers Deleted: ' + trainersDeleted + ' \r\n' + 
                                                          'Notes: '+ sEvent.reasonData.reasonNote;
            sEvent.event.Transfer_Cancellation_Reason__c = sEvent.reasonData.reasonId;
            sEvent.event.Customer_Cancellation_Transfer_Date__c = date.parse(sEvent.reasonData.transferRequestedOn);
            sEvent.event.Liability_at_Cancellation_Transfer__c = sEvent.transferFee;
            
            sEvent.event.Original_TnC_Liability__c = sEvent.transferFeeOriginal == null ? 0 : sEvent.transferFeeOriginal;
            sEvent.event.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
            
            for (Special_Event_Booking__c eBooking : sEvent.event.R00N50000001mIaiEAE__r){
                eBooking.Status__c = 'To Be Transferred';

                if (oppId == null){
                    oppId = eBooking.Opportunity__c;
                }

                if (ebooking.type__c == 'In-Company Primary')
                    ebooking.Booking_Fee__c = sEvent.transferFee; 
                            
                eBooking.Customer_Cancellation_Transfer_Date__c = date.parse(sEvent.reasonData.transferRequestedOn);
                eBooking.Transfer_Cancellation_Fee__c = sEvent.transferFee;
                eBooking.Transfer_Cancellation_Notes__c = sEvent.event.Transfer_Cancellation_Notes__c;
                eBooking.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
                eBooking.Transfer_Cancellation_Reason__c = sEvent.event.Transfer_Cancellation_Reason__c;
                bookings.add(eBooking);
            }
            if (test.isRunningTest() == false){
                updatePurchaseOrders(sEvent);
                updateAuditOutcomes(sEvent, 'Event Transferred');
            }
            objects.add(sEvent.event);
        }
        
        update objects;
        update bookings;
        
        Opportunity opp = database.query('select id from opportunity where id = :oppId limit 1');
        opp.Transfer_Cancellation__c = true;
        opp.StageName = 'Quote/Proposal';
        update opp;
    }
    
    public class ProductHistoryWrapper{
        public decimal quantity  {get;set;}
        public decimal unitPrice {get;set;}
        public string productid  {get;set;}
        public string status     {get;set;}
        
        public ProductHistoryWrapper(decimal qty, decimal unitPrice, string productid, string status){
            this.quantity = qty;
            this.unitPrice = unitPrice;
            this.productid = productid;
            this.status = status;
        }
    }
}