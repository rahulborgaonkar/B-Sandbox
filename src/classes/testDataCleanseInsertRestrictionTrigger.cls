@isTest
private class testDataCleanseInsertRestrictionTrigger
{
    @isTest
    static void testCreateTaskforAccountwithDC1or3or6()
    {
        Account account = new Account(name = 'testAcount for DC');
        insert account;
        system.debug('Account id : ' + account.id);
        
        Contact contact= new Contact(LastName='Test LastName', Email='testy13213@fffp.com.ffftest', FirstName = 'Test FirstName', Salutation = 'Mr', AccountId = account.id);
        insert contact;
        system.debug('Contact id : ' + contact.id);
        
        Task task = new task();
        task.WhatId = account.id;
        task.Type = 'Other';
        task.Subject = 'Test Task';
        task.Description = 'Test Task';
        task.OwnerId = UserInfo.getUserId();
        task.WhoId = contact.id;

        Event event = new event();
        event.WhatId = account.id;
        event.Type = 'Other';
        event.Subject = 'Test Event';
        event.Description = 'Test Event';
        event.OwnerId = UserInfo.getUserId();
        event.WhoId = contact.id;


        try
        {
            insert task;
        }
        catch(Exception e)
        {
            system.debug('Task Exception - ' + e);
        }

        try
        {
            insert event;
        }
        catch(Exception e)
        {
            system.debug('Event Exception - ' + e);
        }


    }
}