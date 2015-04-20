trigger OpportunityLineItems on OpportunityLineItem (after update, before update, before delete) {

    if(trigger.isBefore && Trigger.isUpdate)
        OpportunityLineItemsTriggerMethods.countQuantity(trigger.newMap,trigger.oldMap);
    
    if(trigger.isAfter && Trigger.isUpdate)
    {   
        try{
            
            if (execControl.stopOppLineTrigger == false){
                execControl.stopOppLineTrigger = true;
                OpportunityLineItemsTriggerMethods.updateOpportunityExt(trigger.newMap.keySet());
            }
        }
        catch(System.Asyncexception e)
        {
            OpportunityLineItemsTriggerMethods.updateOpportunity(trigger.newMap.keySet());
        }
        
        Set<Id> oppsToUpd = new Set<Id>();
        
        for (OpportunityLineItem oppLine : Trigger.new){
            OpportunityLineItem oldOppLine = Trigger.oldMap.get(oppLine.Id);
            if (oppLine.TotalPrice != oldOppLine.TotalPrice){
                oppsToUpd.add(oppLine.Id);
            }
        }
        if (oppsToUpd.size() > 0){
            OpportunityLineItemsTriggerMethods.updateBookingPriceLines(oppsToUpd);
        }
    }

    if(Trigger.isBefore && Trigger.isDelete){
        OpportunityLineItemsTriggerMethods.checkForOppLineLock(Trigger.old);
    }
}