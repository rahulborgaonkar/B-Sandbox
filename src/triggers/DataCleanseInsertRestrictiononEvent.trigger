trigger DataCleanseInsertRestrictiononEvent on Event (before insert) 
{
    List<ID> whatids = new List<ID>();
    List<ID> whoids = new List<ID>();
    
    for (Event event : trigger.new)
    {
        if(event.WhatId != null && (String.valueOf(event.WhatId).substring(0, 3) == '001'))
        {
            // WhatId is an Account object.
            whatids.add(event.WhatId);
        }

        if(event.WhoId != null && (String.valueOf(event.WhoId).substring(0, 3) == '003'))
        {
            // WhoId is an Contact object.
            whoids.add(event.WhoId);
        }

    }

    Map<id, Account> DataCleanseAccounts = new Map<id, Account> ([select id, Data_Cleanse_1__c, Data_Cleanse_3__c, Data_Cleanse_6__c from account where id in :whatids and (Data_Cleanse_1__c = true or Data_Cleanse_3__c = true or Data_Cleanse_6__c = true)]);

    Map<id, Contact> DataCleanseAccount_Contacts = new Map<id, Contact> ([Select Account.Id, Account.Name, Account.Data_Cleanse_1__c, Account.Data_Cleanse_3__c, Account.Data_Cleanse_6__c, Id, Name From Contact where id in :whoids  and (Account.Data_Cleanse_1__c = true or Account.Data_Cleanse_3__c = true or Account.Data_Cleanse_6__c = true)]);

    for (Event event : trigger.new)
    {
        if(DataCleanseAccounts.containsKey(event.whatid) || DataCleanseAccount_Contacts.containsKey(event.whoid))
        {
            event.addError('You can not insert new Event as this account will be deleted under Data Cleanse Project. Please contact IT team on 07789933270');
        }
    }
}