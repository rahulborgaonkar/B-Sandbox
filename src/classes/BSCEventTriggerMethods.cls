public with sharing class BSCEventTriggerMethods
// This class contains methods relating to Special_Event__c(BSCEvents) object
// triggers
{
    public class BaseException extends Exception {}
    Public static void updateBookingStatus(List<Special_Event__c> bEvent)
    // Method to update the BSCEventBooking status to Confirmed
    // when the status of the event is set to confirmed.
    // for In-Company and Audit Events only 
    // Case 00001323
    {
        system.debug('Inside updateBookingStatus');

        List<RecordType> recType = [Select r.Name From RecordType r where r.sObjectType = 'Special_Event__c' and r.name in ('Audit','In-Company Event') and isactive=true];
        if (recType.size() < 2)
        {
            bEvent[0].addError('Missing Record Types Audit or In-Company Event '+ recType.size());
            System.debug('');
        }
        else
        {

/* -- SOQL outside loop - Rahul */
            List<Special_Event_Booking__c> all_bscEventBooking = new List<Special_Event_Booking__c>([Select se.Id, se.Status__c, se.Special_event__c
                                                                                                        From Special_Event_Booking__c se 
                                                                                                        Where se.Special_event__c in :bEvent 
                                                                                                            And se.Status__c in ('Confirmed','Provisional','Cancelled - Provisional')]);
            
            //system.debug('all_bscEventBooking - '+ all_bscEventBooking);
            //system.debug('all_bscEventBooking.size() - '+ all_bscEventBooking.size());

            List<Special_Event_Booking__c> allbscEventBooking = new List<Special_Event_Booking__c> ();
            
            for (Special_Event__c bscEvent: bEvent)
            {
                if ((bscEvent.RecordTypeId==recType[0].Id||bscEvent.RecordTypeId==recType[1].Id)&&(bscEvent.stage__c=='Confirmed'||bscEvent.stage__c=='Provisional'||bscEvent.status__c=='Cancelled - Provisional'||bscEvent.status__c=='Cancelled - Error'))
                {
                    List<Special_Event_Booking__c> new_bscEventBooking = new List<Special_Event_Booking__c>();

                    for(Special_Event_Booking__c seb : all_bscEventBooking)
                    {
                        if(seb.Special_event__c == bscEvent.id)
                        {
                            //system.debug('Found seb.id - '+ seb.id);
                            new_bscEventBooking.add(seb);
                        }
                    }

                    //system.debug('new_bscEventBooking - ' + new_bscEventBooking);
                    //system.debug('new_bscEventBooking.size() - ' + new_bscEventBooking.size());

/* -- Took this SOQL outside loop Line 23 - Rahul

                    List<Special_Event_Booking__c> bscEventBooking = new List<Special_Event_Booking__c>([
                    Select se.Id, se.Status__c
                    From   Special_Event_Booking__c se
                    Where  se.Special_event__c = :bscEvent.Id
                    And    se.Status__c in ('Confirmed','Provisional','Cancelled - Provisional')
                    ]);
*/

                    List<Special_Event_Booking__c> bscEventBooking = new List<Special_Event_Booking__c>(new_bscEventBooking);

                    for (Special_Event_Booking__c a: bscEventBooking)
                    {
                        if(bscEvent.stage__c == 'Cancelled'){
                            a.status__c = bscEvent.status__c;
                        }else{
                            a.status__c = bscEvent.stage__c;
                        }
                    }
                    if(bscEventBooking.size() > 0)
                    {
                        allbscEventBooking.addAll(new List<Special_Event_Booking__c>(bscEventBooking));
                        system.debug('allbscEventBooking.size() - ' + allbscEventBooking.size());
                        //update bscEventBooking; Took this update command out of loop Line 98 - Rahul
                    }
                }
                // Create Audit outcome when bsc events of type audit are created
                // Case 00001473
                // Case 00001791
                // Audit Outcome should only be created for Audit Events

                ID auditRecordType;
                for(RecordType r:recType)
                {
                    if(r.name=='Audit')
                    {
                        auditRecordType = r.id;
                    }
                }   
                if ((!ProcessorControl.inFutureContext)&&(bscEvent.RecordTypeId==auditRecordType))
                {
                    createAuditOutcome(bscEvent);                   
                }

            }
            //system.debug('Last allbscEventBooking.size() - ' + allbscEventBooking.size());
            update allbscEventBooking; // New update statement to avoid Too many SOQL queries - Rahul
        }
    }


    //@future
    Public static void createAuditOutcome(Special_Event__c bEvent)
    // Method to create Audit outcome when bsc events of type audit are created
    // Case 00001473
    // Case 00001791
    // There should only be one Audit Outcome created per Audit Event   
    {
        
        Audit_Outcome__c auditRec;

        // @todo Record Type must be audit or advisory not type__c = audit
        
        if ((bEvent.Type__c=='Audit'||bEvent.Type__c=='Advisory')&&bEvent.stage__c=='Confirmed')
        {
            // Case 0001791
            List<Audit_Outcome__c> checkOldAudit = [Select id From Audit_Outcome__c Where bsc_event__c=:bEvent.Id];
            if (checkOldAudit.size()==0)
            {
                system.debug('bEvent.name: '+ bEvent.name );
                Opportunity opp = new Opportunity();
                try
                {
                    opp = [Select o.accountid from Opportunity o Where o.Id = :bEvent.opportunity__c];
                }
                catch(Exception e)
                {
                    bEvent.addError('Cannot find the Opportunity associated with the record.');
                }
                // Case: 2333
                list<Special_Event_Trainer__c> eventTrainer = new list<Special_Event_Trainer__c>([Select s.Id, s.Trainer__r.User__c From Special_Event_Trainer__c s Where s.Bsc_Event__c = :bEvent.Id ORDER BY s.BSC_Event_Unit__r.Primary_c__c DESC LIMIT 1]);
                Audit_Outcome__c auditor = new Audit_Outcome__c();
                if (eventTrainer.size()>1||eventTrainer.size()==0)
                {
                    auditor.Auditor__c = null;
                }
                else
                {
                    auditor.Auditor__c = eventTrainer[0].trainer__r.User__c;
                }
                auditRec = new Audit_Outcome__c(account__c=opp.AccountId, status__c='Not Started',bsc_event__c=bEvent.Id,currencyIsoCode=bEvent.CurrencyIsoCode,Auditor__c=auditor.Auditor__c);
                ProcessorControl.inFutureContext = true;
                insert auditRec;
            }
            // End of Case 0001791
        }
            
    }
    
    Public static void createDimension4(List<Special_Event__c> bEvent)
    {
        // Created all four variable to write new logic and to run SOQL out of loop - Rahul
        Map<Id, Product2> allProductMap = new Map<Id, Product2> (); // Var 1
        Set<Id> ProductIds = new Set<Id> (); // Var 2
        List<Special_Event__c> allEvents = new List<Special_Event__c>(); // Var 3
        List<c2g__codaDimension4__c> dimList = new List<c2g__codaDimension4__c>(); // Var 4

        system.debug('RSB Inside createDimension4');
            
        try // Added this exeception handler to catch unknow error while creating events after pressing 'Request Event'. Adhoc creating event name same as it's ID
        {
        // This loop create a set of unique products - Rahul
            for (Special_Event__c se : bEvent)
            {
                ProductIds.add(se.product__c);
            }        

        // Product map of all products, SOQL from line 172 is taken out of loop - Rahul
            allProductMap = new Map<Id, Product2>([Select id, productcode From product2 where id in :ProductIds]);

            for (Special_Event__c se : bEvent)
            {
                Special_Event__c b = new Special_Event__c();
                b=se.clone();
                system.debug('Special_Event__c b - ' + b);
                //product2 prod = [Select productcode  From product2 where id = :b.product__c][0]; commented for testing - Rahul
                product2 prod2 = allProductMap.get(se.product__c); // Get current product from map, this will replace above SOQL - Rahul
            
                //system.debug('prod - ' + prod);
                system.debug('RSB prod2 - ' + prod2);
            
                //b.name = prod.productcode + '/'+ b.Event_Auto_Number__c; commented for testing - Rahul
                //system.debug('b.name using prod var - ' + b.name);

                // New assignment using prod2 variable to create name - Rahul
                b.name = prod2.productcode + '/'+ b.Event_Auto_Number__c;
                system.debug('Special_Event__c b - ' + b);
                system.debug('b.name using prod2 var - ' + b.name);
                        
                c2g__codaDimension4__c dim = new c2g__codaDimension4__c();
            
                if (test.isRunningTest()){
                    dim.c2g__ReportingCode__c = b.name + string.valueof(math.random()).substring(1,4);
                }else{
                    dim.c2g__ReportingCode__c=b.name;
                }
            
                dim.Name=b.name;
                dim.CurrencyIsoCode=se.currencyIsoCode;
                dimList.add(dim); // Added dimension changes to dim List - Rahul
            
                try
                {
                    //insert dim; commented for testing - Rahul
                    system.debug('dim.id - ' + dim.id);
                    b.Dimension_4__c = dim.id;
                    allEvents.add(b); // All updated events are collected in list - Rahul
                    try
                    {
                        system.debug('Inside dimension');
                        //update b; commented for testing - Rahul
                    }
                    catch(DMLException e)
                    {
                        se.addError(e);
                    }
                }
                catch(DMLException f)
                {
                    se.addError(f);            
                }
            }

            // Below insert and update commands are replacing Line 199 & 205, this is bulk insert and update - Rahul
            try
            {
                insert dimList;
                system.debug('dimList - ' + dimList);
                Map<String, ID> mapDim = new Map<String, ID>();
                for(c2g__codaDimension4__c dim : dimList)
                {
                    mapDim.put(dim.name, dim.id);
                }
                try
                {
                    system.debug('After loop Inside dimension');
                    system.debug('allEvents - ' + allEvents);
                    for(Special_Event__c e : allEvents)
                    {
                        e.Dimension_4__c = mapDim.get(e.name);
                    }
                    update allEvents;
                }
                catch(DMLException e)
                {
                    for(Special_Event__c se : allEvents)
                    {
                        se.addError(e);                    
                    }
                }
            }
            catch(DMLException f)
            {
                for(Special_Event__c se : allEvents)
                {
                    se.addError(f);
                }
            }
        }
//        catch(System.Exception ex)
        catch(BaseException ex)
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            bEvent[0].addError(ex);
        }
    }
}