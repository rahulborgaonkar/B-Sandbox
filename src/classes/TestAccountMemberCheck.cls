@isTest
private class TestAccountMemberCheck {

    static testMethod void testAccountMemberUpdate() {
        Account account = new Account(
			name = 'testAcount');
		insert account;
		
		Contact cont = new Contact ();
        cont.FirstName = 'TestFN';
        cont.LastName = 'TestLN';
        cont.Accountid = account.id;
        insert cont;
        
		/*
		Project__c project = new Project__c();
		project.Account__c = account.Id;
		insert project;
		*/
		
	
		Subscription__c subs = new Subscription__c();
		subs.Name = '2013';
		subs.Status__c = 'Current';
		subs.Account_Name__c = account.id;
		subs.CurrencyIsoCode = 'GBP';
		subs.Type__c = 'New';
		subs.Contact__c = cont.id;
		insert subs;
		
		/*Subscription__c subs = [select Id, Status__c from 
			Subscription__c where Status__c like 'Current%' limit 1];*/
		
		Subscription_Site__c site = new Subscription_Site__c();
		site.Subscription__c = subs.Id;		
		insert site;
		
		// CREATE SUBSCRIPTION LINE HERE
		Subscription_Line__c sline = new Subscription_Line__c();
		sline.Subscription__c = subs.id;
		sline.CurrencyIsoCode = 'GBP';
		sline.Product__c = [select id from Product2 where name = '1 Year Subscription Module - Tools (1 to 5 Sites)'].id;
		sline.Quantity__c = 1;
		sline.Quantity_Available__c = 0;
		insert sline;
		
		Site_Product__c prod  = new Site_Product__c();
		prod.Subscription_Site__c = site.id;
		prod.Subscription__c = subs.Id;
		prod.Subscription_Line__c = sline.id;
		prod.Site_Product_Contact__c = cont.id;
		
		/*Site_Product__c prod = [select Id, Membership_Product__c
		from Site_Product__c where Membership_Product__c = 'true' limit 1];
		*/
		
		prod.Subscription_Site__c = site.id;
		subs.Account_Name__c = account.Id;
		site.Site_Account__c = account.Id;
		
		update subs;
		update site;
		
		Set<Id> accsToUpdate = new Set<Id>();
		accsToUpdate.add(account.Id);
		AccountMemberCheck.setAccountMemberFlagByAcc(accsToUpdate);
		
    }
}