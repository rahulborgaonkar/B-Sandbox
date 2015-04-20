trigger EventBeforeDelete on Special_Event__c (before delete) {

    //Delete is allowed using this trigger and Permission set Delete_Events
    for(Special_Event__c evt: trigger.Old){
        if (evt.Status__c != 'Cancelled - Error'){
            evt.addError('You cannot delete event ' + evt.name + ' with status of ' + evt.Status__c);
        }
    }
}