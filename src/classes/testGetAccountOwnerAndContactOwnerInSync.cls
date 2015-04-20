@isTest
private class testGetAccountOwnerAndContactOwnerInSync
{
    @isTest 
    static void testGetAccountOwnerAndContactOwnerInSync_Method1()
    {
        Account a = new Account(name='Rahul Test', phone='090909', industry='14:Education', Industry_Sector__c='14.4: Other Institutions', NumberOfEmployees = 10);
        insert a;
        Contact c = new Contact(firstname='Rahul', lastname='Test', accountId=a.id);
        insert c;
    }

    @isTest 
    static void testGetAccountOwnerAndContactOwnerInSync_Method2()
    {
        Account a = new Account(name='Rahul Test', phone='090909', industry='14:Education', Industry_Sector__c='14.4: Other Institutions', NumberOfEmployees = 10);
        insert a;
        list<Contact> l_c = new list<Contact> ();
        for(integer i=0;i<=200;i++)
        {
            string fname = 'Rahul'+i;
            string lname = 'Test'+i;
            Contact c = new Contact(firstname=fname, lastname=lname, accountId=a.id);
            l_c.add(c);
        }
        insert l_c;
    }

}