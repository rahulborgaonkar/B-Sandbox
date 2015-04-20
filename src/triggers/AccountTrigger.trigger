trigger AccountTrigger on Account (before insert) {
    
    // Set default lookup field values for accounts
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        
        if(trigger.new[i].C2G__CODAOUTPUTVATCODE__C ==null)
            trigger.new[i].C2G__CODAOUTPUTVATCODE__C = 'a2A200000004FRHEA2';
        
        if(trigger.new[i].C2G__CODAACCOUNTSRECEIVABLECONTROL__C ==null)
            trigger.new[i].C2G__CODAACCOUNTSRECEIVABLECONTROL__C = 'a1M20000000HDPJEA4';
        
        if(trigger.new[i].c2g__CODAInputVATCode__c ==null)
            trigger.new[i].c2g__CODAInputVATCode__c = 'a2A200000004FRCEA2';
        
        if(trigger.new[i].C2G__CODAACCOUNTSPAYABLECONTROL__C ==null)
            trigger.new[i].C2G__CODAACCOUNTSPAYABLECONTROL__C = 'a1M200000008V88EAE';
        
        if(trigger.new[i].Correspondence_Name__c ==null)
            trigger.new[i].Correspondence_Name__c = trigger.new[i].Name;
        
        trigger.new[i].c2g__CODAAccountTradingCurrency__c = 'GBP';
    }
}