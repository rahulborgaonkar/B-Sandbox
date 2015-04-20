trigger calculateUltimateParentAndOwnersOnAccount on Account (before delete, before insert, after insert, before update) {
    
    system.debug('Inside calculateUltimateParentAndOwnersOnAccount');
    Account_Trigger_Flags__c settings = Account_Trigger_Flags__c.getInstance('Deactivated');

    if(!ApexCodePatrol.isDisabled('AccountReAssignment') )
    {
        System.debug('in AccountReAssignment');
        TriggerContextHelper helper = new TriggerContextHelper();
        

        System.debug('\nDEBUG_CLASS\nCalling "Account Trigger Before Call"\nDEBUG_CLASS"');
        if ((helper.runningFirstTime || TriggerContextHelper.triggerStage == 'HIERARCHY_UPDATE') && Trigger.isBefore)
        {
            TriggerContextHelper.triggerStage = 'HIERARCHY_UPDATE';
            AccountHierarchyHelper.calculateHierarchyFields(trigger.new, trigger.oldmap);
        }
    
        // Run owner update logic
        if ((helper.runningFirstTime || TriggerContextHelper.triggerStage == 'OWNER_UPDATE') &&
            (!Trigger.isInsert || (Trigger.isInsert && Trigger.isAfter)))
        {
            TriggerContextHelper.triggerStage = 'OWNER_UPDATE';
            AccountAssignmentHelper.calculateOwnersOnTrigger(trigger.new, trigger.oldMap, Trigger.isDelete);
        }
    
        // Reset all values ready for after triggers
        if (helper.runningFirstTime)
            TriggerContextHelper.resetRun();
    }else{
        System.debug('skipping AccountReAssignment '+!ApexCodePatrol.isDisabled('AccountReAssignment'));
    }
}