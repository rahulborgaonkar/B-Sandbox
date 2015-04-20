global class tncPublicEventCancellation{
    
    webservice static string cancelPublicEvent(id eventId){
        
        Special_Event__c event = [select id, status__c, 
                                  (select id,Special_Event__c, Opportunity__r.Opportunity_Number__c, Status__c, Event_Certificate_Course_Name__c, Opportunity__r.OwnerId, Opportunity__r.Name, 
                                   Opportunity__r.Owner.IsActive, Opportunity__r.Owner.Email,  Opportunity__r.Account.OwnerId, Opportunity__r.Account.Owner.Email, Contact_Salutation__c, 
                                   Contact_Last_Name__c, Contact__r.FirstName, Transfer_To__c  from R00N50000001mIaiEAE__r where not (Status__c like '%Cancelled%' and Status__c like '%Transferred%')),
                                  Venue_Name__c, Certificate_Course_Name__c, StartDate__c, EndDate__c, Name,
                                  Transfer_Cancellation_Notes__c, Customer_Cancellation_Transfer_Date__c,
                                  (select id, Trainer_Name__c, Trainer__r.User__r.Email from BSC_Event_Trainers__r), Transfer_Cancellation_Reason__r.Name, Transfer_Cancellation_Reason__c
                                  from Special_Event__c where Id = :eventId];
        
        tncEventsWrapper trainersToDelete = new tncEventsWrapper(false, event);
        event.Status__c = 'To Be Cancelled';
        event.Stage__c = 'Cancelled';
        
        id reason = [select id from Transfer_Cancellation_Reasons__c where name = 'BSC Cancelled Event' limit 1].id;
        
        string notes= tncHelper.deleteTrainerEvents(trainersToDelete);
        event.Transfer_Cancellation_Notes__c = notes == '' ? '' : 'Trainers Deleted: \n' + notes;
        event.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
        event.Transfer_Cancellation_Reason__c = reason;
        event.Customer_Cancellation_Transfer_Date__c = system.today();
        
        list<Special_Event_booking__C> bookings = new list<Special_Event_booking__C>();
        list<Task> tasks = new list<task>();
        
        for (Special_Event_booking__C booking : event.R00N50000001mIaiEAE){
            system.debug('cancelling booking');
            string status = booking.Status__C;
            
            if (booking.Status__C == 'Provisional'){
                booking.Status__C = 'Cancelled - BSC';
                booking.OPL_ID__c = '';
                booking.Booking_Fee__c = 0;
                booking.Override_Booking_Fee__c = true;
            } else if (booking.Status__C == 'Confirmed'){
                booking.Status__C = 'To be Transferred';
            }
            
            
            booking.Transfer_Cancellation_Notes__c = notes == '' ? '' : 'Trainers Deleted: \n' + notes;
            booking.Transfer_Cancellation_Process_Date__c = system.Datetime.now();
            booking.Transfer_Cancellation_Reason__c = reason;
            booking.Customer_Cancellation_Transfer_Date__c = system.today();
            
            if (status == 'Provisional' || status == 'Confirmed' || status == 'To be Transferred'){
                
                Id taskFor; 
                if (booking.Opportunity__r.Owner.IsActive == true){
                    taskFor = booking.Opportunity__r.OwnerId;
                } else {
                    taskFor = booking.Opportunity__r.Account.OwnerId;
                }
                
                system.debug('taskFor' +taskFor);
                
                map<string,string> keyValueMap = new map<string,string>{ '<Event Name>' => booking.Event_Certificate_Course_Name__c,
                    '<Event_Booking.Status>'=> booking.Status__c ,
                    '<Event_Booking.Contact.Saluation>' => booking.Contact_Salutation__c,
                    '<Event_Booking.Contact.surname>' => booking.Contact_Last_Name__c,
                    '<Event_Booking.Contact.firstname>' => booking.Contact__r.FirstName,
                    '<Booking.Event.Opportunity.Name>' => booking.Opportunity__r.Opportunity_Number__c};
                        
                        list<string> data = Utilities.getCustomTemplate('Sales Rep: Public Event Cancellation task template', keyValueMap);
                string subject = data[0];
                string description = data[1];
                task t =  Utilities.createTask(true, system.today(), booking.Special_Event__c, subject, description, taskFor);
                insert t;
                tasks.add(t);
                system.debug('tasks'  + tasks);
            }
            
            bookings.add(booking);
        }
        
        update event;        
        update bookings;
        system.debug('tasks size'  + tasks.size());
        
        for (Special_Event_booking__C booking : event.R00N50000001mIaiEAE){
            
            if (booking.Status__C == 'Provisional' || booking.Status__C == 'Confirmed' || booking.Status__C == 'To be Transferred'){
                
                string emailTo;
                id taskId;
                if (booking.Opportunity__r.Owner.IsActive == true){
                    emailTo = booking.Opportunity__r.Owner.Email;
                } else {
                    emailTo = booking.Opportunity__r.Account.Owner.Email;                
                }
                
                for (task t: tasks){
                    if (t.whatId == booking.Special_Event__c){
                        taskId = t.Id;
                        break;
                    }                
                }
                
                map<string,string> keyValueMap = new map<string,string>{ '<Event Name>' => booking.Event_Certificate_Course_Name__c,
                    '<task link>' => URL.getSalesforceBaseUrl().toExternalForm() + '/' + taskId};
                        system.debug ('keyValueMapEmail ' + keyValueMap);    
                Utilities.SendEmail('Public Event Cancellation email template',new list<string>{ emailTo }, keyValueMap);
                system.debug ('email sent');
            }
        }
        
        return string.valueof(eventId);
    } 
}