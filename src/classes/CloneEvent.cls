public class CloneEvent {
    
    public id eventId {get; set;}
    public integer  numberOfDays  {get; set;}
    public datetime  startDate        {get; set;}
    
    public CloneEvent(ApexPages.StandardController controller) {
        Special_Event__c event1 = (Special_Event__c)controller.getRecord();
        system.debug(event1);
        eventId = event1.id;
    }
    
    public PageReference CloneRecord(){
        
        Special_Event__c event = database.query(Utilities.getCreatableFieldsSOQL('Special_Event__c') + ' where id = :eventId');

        Special_Event__c cloneEvent = new Special_Event__c();
        
        cloneEvent.Product__c = event.Product__c;
        cloneEvent.Type__c = event.Type__c;
        cloneEvent.Status__c = 'Confirmed';
        cloneEvent.Stage__c = 'Confirmed';
        cloneEvent.Alternative_Certificate_Course_Name__c = event.Alternative_Certificate_Course_Name__c;
        cloneEvent.Maximum_Places__c = event.Maximum_Places__c;
        cloneEvent.Minimum_Places__c = event.Minimum_Places__c;
        cloneEvent.Allow_Overbooking__c = event.Allow_Overbooking__c;
        cloneEvent.Venue__c = event.Venue__c;
        cloneEvent.City__c = event.City__c;
        cloneEvent.International__c = event.International__c;
        cloneEvent.Event_Notes__c = event.Event_Notes__c;
        cloneEvent.Courier_Costs__c = event.Courier_Costs__c;
        cloneEvent.Venue_Flat_Rate__c = event.Venue_Flat_Rate__c;
        cloneEvent.Delegate_Pack_Costs__c = event.Delegate_Pack_Costs__c;
        cloneEvent.Course_Note_Costs__c = event.Course_Note_Costs__c;
        cloneEvent.Venue_Delegate_Day_Rate__c = event.Venue_Delegate_Day_Rate__c;
        cloneEvent.Target_Contribution_Event__c = event.Target_Contribution_Event__c;
        cloneEvent.Course_Reference__c = event.Course_Reference__c;
        cloneEvent.Revenue_Code__c = event.Revenue_Code__c;
        cloneEvent.Private__c = event.Private__c;
        cloneEvent.Dimension_4__c = event.Dimension_4__c;

        // This part was added as cloneEvent.name was not populated before -- Rahul
        system.debug('cloneEvent - ' + cloneEvent);

        insert cloneEvent;

        Product2 prod = [SELECT Id, IsActive, ProductCode FROM Product2 where id = :event.Product__c][0];
        Special_Event__c b = [select Event_Auto_Number__c from Special_Event__c where id = :cloneEvent.id][0];
        cloneEvent.name = prod.ProductCode + '/' + b.Event_Auto_Number__c;

        system.debug('cloneEvent.name - ' + cloneEvent.name);
        update cloneEvent;
        system.debug('cloneEvent.name - ' + cloneEvent.name);
        // -- Rahul

        list<Special_Event_Unit__c> eventUnits = new list<Special_Event_Unit__c>();
        
        for (integer i=1; i<=numberOfDays ; i++){
            Special_Event_Unit__c eventUnit = new Special_Event_Unit__c();
            
            if (i == 1){
                eventUnit.Primary_c__c = true;
            }
            eventUnit.Special_Event__c = cloneEvent.Id;
            eventUnit.Name = 'Day ' + string.valueOf(i);
            eventUnit.Unit_Start_Time__c = startDate;
            eventUnit.Unit_End_Time__c = startDate.addHours(8);
            eventUnit.Venue__c = cloneEvent.Venue__c;
            startDate = startDate.addDays(1);
            
            if (startDate.format('E') == 'Sat')
                startDate = startDate.addDays(2);
            else if (startDate.format('E') == 'Sun') 
                startDate = startDate.addDays(1);
            
            system.debug('startDate.format(E): '+startDate.format('E'));
            
            eventUnits.add(eventUnit);
        }
        
        insert eventUnits;

        return new PageReference('/' + cloneEvent.Id);
    }
}