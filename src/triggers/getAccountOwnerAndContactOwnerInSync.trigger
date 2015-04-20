trigger getAccountOwnerAndContactOwnerInSync on Contact (before insert, before update)
{
    System.debug('keepAccountOwnerAndContactOwnerInSync');
    try 
    {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Id> accountOwnerIdMap = new Map<Id, Id>();
   
        // all the accounts whose owner ids to look up
        for ( Contact c : Trigger.new )
        {
            if(c.accountId <> null)
            {
                accountIds.add( c.accountId );
            }
        }
       
        // look up each account owner id
        for ( Account acct : [ SELECT id, ownerId FROM account WHERE id IN :accountIds ] ) 
        {
            accountOwnerIdMap.put( acct.id, acct.ownerId );
        }

        // change contact owner to its account owner
        for ( Contact c : Trigger.new ) 
        {
            if(c.AccountId <> null)
            {
                c.ownerId = accountOwnerIdMap.get( c.accountId );
            }
        }
    }
    catch(Exception e)
    { //catch errors
        System.Debug('reassignContacts failure: '+e.getMessage()); //write error to the debug log
    }
}