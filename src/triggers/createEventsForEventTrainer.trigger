trigger createEventsForEventTrainer on Special_Event_Trainer__c (before delete, after insert, before update,after update) {
    
    List<Special_Event_Trainer__c> nonMigratedEvents = new List<Special_Event_Trainer__c>();
    Map<Id, Special_Event_Trainer__c> nonMigratedMap = new Map<Id, Special_Event_Trainer__c>();
 
    if(Trigger.new != null){
        for(Special_Event_Trainer__c event: Trigger.new){
            if(event.Migrated__c == false){
                
                nonMigratedEvents.add(event);       
            }
        }
    }
    
    if(Trigger.old != null){
        for(Special_Event_Trainer__c event: Trigger.old){
            if(event.Migrated__c == false){
                nonMigratedMap.put(event.Id, event);        
            }
        }
    }
    
    if(trigger.isBefore || trigger.isInsert)
        EventTrainerHelper.generateEvents(nonMigratedEvents, nonMigratedMap); 
    
    if(trigger.isAfter && trigger.isInsert){   
        list<Special_Event_Trainer__c> eventTrainers = new list<Special_Event_Trainer__c>();
        
        for(Special_Event_Trainer__c et: Trigger.new){
            if(et.Is_Primary_Event_Unit__c)
                eventTrainers.add(et);
        }
        
        if(eventTrainers.size() > 0)
            EventTrainerHelper.propogateTrainerToAO(eventTrainers);
    }
    
    if(trigger.isAfter)
        EventTrainerHelper.createSharingRule(nonMigratedEvents);
}