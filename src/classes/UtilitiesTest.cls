@IsTest(SeeAllData=true)
public class UtilitiesTest{

    static testmethod void testGetCreatableFieldsSOQL(){
        
        account acc = new account(name = 'test utility');
        insert acc;
        contact NewContact= new Contact(
            LastName='Test util' , 
            Email='testutil@bsc.com', 
            FirstName = 'Testutil', 
            Salutation = 'Mr',
            AccountId = acc.id
        );
        insert NewContact;
        opportunity opp = new Opportunity(
            Name = 'testutility',
            AccountId = acc.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today());
        insert opp;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId  = NewContact.id;
        ocr.OpportunityId = opp.id;
        insert ocr;
        
        test.starttest();
        
        string soql = Utilities.getCreatableFieldsSOQL('Account') + ' limit 1 ';
        system.assert(soql.contains('SELECT'));
        list<Account> acc1 = database.query(soql);
        system.assert(acc1.size() == 1 , 'found account');
    
        
        list<string> relatedFields = new list<string>();
        relatedFields.add('Account.Name');
        relatedFields.add('Account.Id');
        
        list<string> subQueries = new list<string>();
        subQueries.add('select id, name from Opportunities__r');
        
        string soql1 = Utilities.getSOQLQuery('Contact', relatedFields, subQueries) + ' limit 10 ';
        system.assert(soql1.contains('SELECT'));
        system.debug(soql1);
        list<contact> contacts = [select id, account.id, account.name, (select id, name from Opportunities__r) from contact where (Account.Data_Cleanse_1__c != true and Account.Data_Cleanse_3__c != true and Account.Data_Cleanse_6__c != true) limit 2];
        system.assert(contacts.size() > 0 , 'found contacts');
        
        list<task> tasks = new list<task>();
        for (contact con : contacts){
            system.assert(con.Account.Id != null);
            system.assert(con.Opportunities__r.size() >= 0);
            
            task t = Utilities.createTask(true, system.today(), con.Account.Id, 'Test', 'Test Description', userinfo.getUserId() );
            tasks.add(t);
            insert t;
        }

        Custom_Email_Template__c template = new Custom_Email_Template__c();
        template.EmailBody__c = 'Emailbody <Test>';
        template.EmailSubject__c = 'EmailSubject <Test>';
        template.EmailFrom__c = 'VishantShah@yahoo.com';
        template.Name = 'Test';
        template.EmailToTest__c = 'vishant.shah@britsafe.org';
        insert template;
        
        list<string> toEmail = new list<string>();
        toEmail.add('vishant.shah@britsafe.org');
        
        map<string,string> keyValue = new map<string,string>();
        keyvalue.put('<Test>', 'replaced via key value');
        
        Utilities.SendEmail('Test', toEmail, keyValue);
        
        Utilities.SendEmail(' body', 'subject',  toEmail);
        
        
        string[] toEmail1 = new string[1];
        toEmail1[0] = 'vishant.shah@britsafe.org'; 
        
        Utilities.sendTemplatedEmail(toEmail1, 'Request_To_Add_or_Remove_Bookings', acc.id, UserInfo.getUserId());
        
            
        test.stopTest();
    }
}