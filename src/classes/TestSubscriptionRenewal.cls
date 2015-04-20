@istest
class TestSubscriptionRenewal
{
	static testmethod void TestSubscriptionRenewalMethod()
	{
		
		Date startDate = System.Today()-366;
		
		// Core Product
		Product2 prod = new Product2(
			Name = 'Product Test', 
			Initial_Reminder_Days__c = 1,
			Core_Subscription_Product__c = True,
			Subscription_Product__c = True,
			Membership__c = True,
			Duration__c = '1 Year'
		);
		insert prod;		
		
		Pricebook2 standardPb = [Select Id From Pricebook2 Where IsStandard = True Limit 1];
		Pricebook2 pb = [Select Id From Pricebook2 Where Name = 'Mem/Subs: Intl Members' Limit 1];
		
		//Pricebook2 pb = new Pricebook2(
		//	Name = 'Test Pricebook',
		//	IsActive = True
		//);
		//insert pb;
		
		PricebookEntry pbeSt = new PricebookEntry(
			Pricebook2Id = standardPb.Id,
			Product2Id = prod.Id,
			UnitPrice = 100,
			CurrencyIsoCode = 'GBP',
			UseStandardPrice = false,
			IsActive = true);
		insert pbeSt;

		PricebookEntry pbe = new PricebookEntry(
			Pricebook2Id = pb.Id,
			Product2Id = prod.Id,
			UnitPrice = 100,
			CurrencyIsoCode = 'GBP',
			UseStandardPrice = false,
			IsActive = true);
		insert pbe;
		
		// Module Product
		Product2 prodModule = new Product2(
			Name = 'Product Module Test', 
			Initial_Reminder_Days__c = 1,
			Tools_Membership_Product__c = True,
			Duration__c = '1 Year'
		);
		insert prodModule;
		
		PricebookEntry pbeModuleStd = new PricebookEntry(
			Pricebook2Id = standardPb.Id,
			Product2Id = prodModule.Id,
			UnitPrice = 100,
			CurrencyIsoCode = 'GBP',
			UseStandardPrice = false,
			IsActive = true);
		insert pbeModuleStd;

		PricebookEntry pbeModule = new PricebookEntry(
			Pricebook2Id = pb.Id,
			Product2Id = prodModule.Id,
			UnitPrice = 100,
			CurrencyIsoCode = 'GBP',
			UseStandardPrice = false,
			IsActive = true);
		insert pbeModule;

		
		Account account  = new Account(
			Name = 'test account',
			Principle_Address_Country__c = 'United Kindgom'
		);
		System.debug('** inserting account');
		insert account;
		
        // Add a Contact to it
        Contact NewContact= new Contact(
        	LastName='Test SSCreation Contact', 
        	Email='testy13213@fffp.com', 
        	FirstName = 'Test', 
        	Salutation = 'Mr'
        );
        
        NewContact.AccountId=account.id;
        insert NewContact;


  		System.debug('** finished inserting account');
  		
  		RecordType SubRecordType = [SELECT Id FROM RecordType WHERE
				SobjectType = 'Opportunity' AND
				Name = 'Subscription' LIMIT 1];
		
  		Opportunity opp = new Opportunity(
  			AccountId = account.Id,
  			StageName = 'Preparation',
  			Probability = 100,
  			RecordTypeId = SubRecordType.Id,
  			Name = 'Test Opp Name',
  			CloseDate = System.Today()+30,
  			CurrencyISOCode = 'GBP',
  			PriceBook2Id = pb.Id
  		);
  		insert opp;
  		
  		OpportunityLineItem oppLine = new OpportunityLineItem(
  			OpportunityId = opp.Id,
  			PriceBookEntryId = pbe.Id,
  			Quantity = 1,
  			UnitPrice = 100.00,
  			Duration_Years__c = 1,
  			Subscription_Product__c = true
  		);
  		insert oppLine;
  		System.debug('Test Opp Line: '+oppLine);
  		System.debug('Test Opp: '+opp);
  		
        Subscription__c subscription=new Subscription__c(
        	Account_Name__c = account.id,
        	Status__c = 'Current - Renewing',
        	Contact__c = NewContact.id,
        	Start_Date__c = startDate,
        	End_Date__c = startDate+364,
        	Type__c = 'New',
        	Renewal_Opportunity__c = true,
        	Renewal_Opportunity_Created__c = false,
        	Renewal_Reminders__c = true,
        	Opportunity__c = opp.Id,
        	Longest_Duration_Years__c = 1
        );
        insert subscription;
        
        opportunity oppUpdate = [select id from opportunity where id = :opp.Id];
        oppUpdate.StageName = 'Customer Approved';
        update oppUpdate;
            
		Subscription_Line__c subscriptionLineItem = new Subscription_Line__c(
			Subscription__c = subscription.Id,
			Quantity__c = 1,
			Quantity_Available__c = 0,
			Product_Sales_Price__c = 100,
			Renewal_Price__c = 100,
			Product__c =  prod.id);
		insert subscriptionLineItem;
		
		Subscription_Site__c subSite = new Subscription_Site__c(
			Subscription__c = subscription.id,
			No_Magazine_Mailing__c = False,
			Site_Account__c = account.Id,
			Site_Contact__c = NewContact.Id,
			Site_Start_Date__c = startDate,
			Type__c = 'Single Site',
			Active__c = True
		);
		insert subSite;
		
		Site_Product__c siteProd = new Site_Product__c(
			Site_Product_Contact__c = NewContact.Id,
			Subscription__c = subscription.Id,
			Subscription_Line__c = subscriptionLineItem.Id,
			Subscription_Site__c = subSite.Id
		);
				
		insert siteProd;
		
		Subscription__c subCheck = [SELECT 
										Id,
										Status__c, 
										Start_Date__c,
										End_Date__c,
										First_Reminder_Date__c,
										Create_Renewal_Objects_on__c,
										Renewal_Opportunity_Created__c,
										Includes_Membership_Product__c,
										Includes_Publication_Product__c,
										Subsequent_Subscription__c,
										Renewal_Sales_Invoice__c,
										Auto_Create_Sales_Invoice__c,
										Subscription_Sites__c,
                                        Opportunity__c
									FROM 
										Subscription__c 
									WHERE 
										Id = :subscription.Id Limit 1];
		System.debug('TEST SCRIPT Sub Info2: '+subCheck);
		
        

		
       	List<Subscription__c> subList = new List<Subscription__c>();
       	subList.add(subscription);
       	

        
		Test.startTest();

		System.debug('Run Renewals:');

        // Run Renwals on single Subscription
		SubscriptionRenewal.runSubscriptionRenewals(subscription.Id);
		

        SubscriptionRenewal.runSubscriptionRenewalInvPacks(subscription.Id,false);
		Test.stopTest();
		
		// Retrieve the created record
		RecordType recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Subscription' LIMIT 1];
		List<Opportunity> renewalApps = [select Id from Opportunity where Type = 'Subscription Renewal' and
			StageName = 'Qualifying' and Name = 'Subscription Renewal' and Renewal_Opportunity__c = true
			and AccountId = :account.Id];
		
		Integer numberOfOppsCreated = renewalApps.size();
		
	}

}