trigger OpportunityTrigger on Opportunity (before update,after update, before insert ) {
    
        
        if (execControl.stopCreditNoteTrigger == false){ 
            if(trigger.isBefore && trigger.isUpdate){ 
                if(execControl.stopOppControls == false){
                    execControl.stopOppControls = true; // COMMENT THIS LINE IF YOU FIND ANY ISSUES RELATING WITH OPP CONTROLS. 
                    system.debug('AutoInvoiceSettings__c.getOrgDefaults().Stop_Opp_Controls__c = '+AutoInvoiceSettings__c.getOrgDefaults().Stop_Opp_Controls__c);
                    if (AutoInvoiceSettings__c.getOrgDefaults().Stop_Opp_Controls__c == false)
                    {
                        OpportunityTriggerMethods.opportunityControl(trigger.newMap);
                    }
                    else
                        system.debug('ByPassed Opp Controls');
                }
                OpportunityTriggerMethods.updateOpportunityFields(trigger.newMap);
            }
            
            if(trigger.isAfter && trigger.isUpdate) {
                OpportunityTriggerMethods.updateAccountFields(trigger.new);
                //Only fire when saving a single opportunity, we dont want this to fire for bulk data migration
                if(trigger.new.size() == 1){
                    Opportunity thisOpp = trigger.new.get(0);
                    OpportunityRollup.rollUpOpportunityValue(thisOpp);
                }
            }
        }
        
        if(trigger.isBefore && trigger.isInsert){
             OpportunityTriggerMethods.setDefaultFields(trigger.new);
        }

        if(trigger.isBefore && trigger.isUpdate)
        {
             OpportunityTriggerMethods.updateOpportunityContactField(trigger.newMap);
        }

}