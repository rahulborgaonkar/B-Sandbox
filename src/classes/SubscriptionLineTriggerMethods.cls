public without sharing class SubscriptionLineTriggerMethods
{
	/* 
	 * UPDATE SUBSCRIPTION PRODUCT STATUS
	 * 
	 * Updates the subscription includes e-learning product, subscription product, publication and RCP Product
	 * fields on the subscription.
	 * 
	*/
	public static void updateSubscriptionProdStatus(List<Subscription_Line__c> subLineList){
		
		// Identify the subscriptions that need to be updated
		Map<ID,ID> subsToBeUpdated = new Map<ID,ID>();
		for(Subscription_Line__c subLine : subLineList){
			if(!subsToBeUpdated.containsKey(subLine.Subscription__c)){
				subsToBeUpdated.put(subLine.Subscription__c,subLine.Subscription__c);
			}
		}
		
		List<Subscription__c> subsToUpdate = new List<Subscription__c>();
		
		for(Subscription__c sub : [SELECT Includes_RCP_Product__c, 
											Includes_Membership_Product__c, 
											Includes_E_Delivery_Product__c,
											Includes_Publication_Product__c,
											(SELECT s.Product__r.Subscription_Product__c, 
															s.Product__r.RCP_Product__c,
															s.Product__r.Membership__c, 
															s.Product__r.E_Delivery_Subscription__c, 
															s.Product__r.Publication_Subscription__c,
															s.Product__r.Tools_Membership_Product__c,
															s.Product__r.Info_Membership_Product__c,
															s.Product__r.Guides_Publication_Product__c,
															s.Product__r.HSWA_Publication_Product__c,
															s.Product__r.Safety_Management_Product__c,
															s.Product__r.ProductCode,
															s.Product__r.Duration_Years__c,
															s.Product__r.SUSA_Product__c,
															Quantity__c
													 FROM Subscription_Lines__r s )
		 							FROM Subscription__c WHERE Id IN :subsToBeUpdated.values()]){

			System.debug('Current Sub: '+sub);
			sub.Includes_RCP_Product__c = false;
			sub.Includes_Membership_Product__c = false;
			sub.Includes_E_Delivery_Product__c = false;
			sub.Includes_Publication_Product__c = false;
			sub.Includes_Tools_Membership_Product__c = false;
			sub.Includes_Info_Membership_Product__c = false;
			sub.Includes_Guides_Publication_Product__c = false;
			sub.Includes_HSWA_Publication_Product__c = false;
			sub.Includes_Safety_Management_Product__c = false;
			sub.Includes_SUSA_Product__c = false;
			
			String StrProductCodes = '';
			Double longestDuration = 0;

			//List<SObject> subLines=sub.getSObjects('Subscription_Lines__c');
			for (Subscription_Line__c allSubLine : sub.Subscription_Lines__r)
			{
				if (allSubLine.Product__r.Tools_Membership_Product__c == true){
					System.debug(sub.Id+' has at least one Tools Membership Product');
					sub.Includes_Tools_Membership_Product__c = true;
				}
				if (allSubLine.Product__r.Info_Membership_Product__c == true){
					System.debug(sub.Id+' has at least one Info Membership Product');
					sub.Includes_Info_Membership_Product__c = true;
				}
				if (allSubLine.Product__r.RCP_Product__c == true){
					System.debug(sub.Id+' has at least one RCP Product');
					sub.Includes_RCP_Product__c = true;
				}
				if (allSubLine.Product__r.Membership__c == true){
					System.debug(sub.Id+' has at least one Membership Product');
					sub.Includes_Membership_Product__c = true;
				}
				if (allSubLine.Product__r.E_Delivery_Subscription__c == true){
					System.debug(sub.Id+' has at least one E Delivery Subscription');
					sub.Includes_E_Delivery_Product__c = true;
				}
				if (allSubLine.Product__r.Publication_Subscription__c == true){
					System.debug(sub.Id+' has at least one Publication Subscription');
					sub.Includes_Publication_Product__c = true;
				}

				if (allSubLine.Product__r.Guides_Publication_Product__c == true){
					System.debug(sub.Id+' has at least one Guides Publication Subscription');
					sub.Includes_Guides_Publication_Product__c = true;
				}
				if (allSubLine.Product__r.HSWA_Publication_Product__c == true){
					System.debug(sub.Id+' has at least one HSWA Publication Subscription');
					sub.Includes_HSWA_Publication_Product__c = true;
				}
				if (allSubLine.Product__r.Safety_Management_Product__c == true){
					System.debug(sub.Id+' has at least one Safety Management Publication Subscription');
					sub.Includes_Safety_Management_Product__c = true;
				}
				if (allSubLine.Product__r.SUSA_Product__c == true){
					System.debug(sub.Id+' has at least one SUSA Subscription');
					sub.Includes_SUSA_Product__c = true;
				}
				system.debug('Steve Code has set sub SUSA value'+sub.Includes_SUSA_Product__c);

                // Build product codes line
                if(allSubLine.Quantity__c > 0)
                {
                    if (StrProductCodes == ''){
                        StrProductCodes=allSubLine.Product__r.ProductCode;
                    }else{
                        StrProductCodes=StrProductCodes + ';' + allSubLine.Product__r.ProductCode;
                    }
                }
                // Work out longest product duration (used for renewals to work out the length of the renewal)
                if (allSubLine.Product__r.Duration_Years__c > longestDuration){
                	longestDuration = allSubLine.Product__r.Duration_Years__c;
                }
                
                
			}
			
			sub.Longest_Duration_Years__c = longestDuration;
			
			// Set the product codes value.
			sub.Product_Codes__c = StrProductCodes;
			subsToUpdate.add(sub);
		}
		update subsToUpdate;
	}
	
    public static void updateInvoiceStatus(Map<Id,Subscription_Line__c> subsLineMap)
    {
    
    	List<Id> subsToMarkPaid = new List<Id>();
    	
        for(c2g__codaInvoiceLineItem__c invoiceLineItem:[Select c2g__Invoice__c,
        														c2g__Invoice__r.Copy_Invoice_Status__c,
                                                                c2g__Invoice__r.c2g__InvoiceStatus__c,
                                                                SL__c,
                                                                SL__r.Subscription__c
                                                                from c2g__codaInvoiceLineItem__c
                                                                where SL__c IN:subsLineMap.keySet()
                                                                ])
       {
                                                                                                               
            if(subsLineMap.containsKey(invoiceLineItem.SL__c))
            {
                Subscription_Line__c subsLine = subsLineMap.get(invoiceLineItem.SL__c);
                if(invoiceLineItem.c2g__Invoice__r.c2g__InvoiceStatus__c == 'Discarded')
                {    
                    subsLine.Invoice_Status__c = 'Not-Invoiced'; 
                }
                else{
                
                    subsLine.Invoice_Status__c = invoiceLineItem.c2g__Invoice__r.Copy_Invoice_Status__c;
                    if(subsLine.Invoice_Status__c == 'Paid')
                    {
                    	System.debug('Sub Line has invoice paid'+invoiceLineItem.SL__c);
                         subsLine.Invoice_Paid_Date__c = Date.today();
                         subsToMarkPaid.add(invoiceLineItem.SL__r.Subscription__c);
                    }
                }
            }    
        }
        
    }
    
    
    public testmethod static void testUpdateSubscriptionProductType()
    {
    	
		//Set variables
		Pricebook2 stdPricebook = [Select Id From Pricebook2 Where IsStandard = true Limit 1];
		//Create Data
    	
		//Create Pricebook
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'TestPb';
		pb.IsActive = True;
		insert pb;
		System.debug('Steve pbId'+' '+pb.Id);
    	
		//Create product Positive test
		Product2 proPos = new Product2();
		proPos.Name = 'TestProd';
		proPos.RecordType = [Select Id from RecordType where sObjectType = 'Product2' and Name = 'Subscription' LIMIT 1][0];
		proPos.IsActive = True;
		proPos.Subscription_Product__c = True;
		proPos.SUSA_Product__c = True;
		insert proPos;
		System.debug('Steve is produt positive SUSA'+' '+proPos.SUSA_Product__c);
		
		//Create product Negative test
		Product2 proNeg = new Product2();
		proNeg.Name = 'TestProd';
		proNeg.RecordType = [Select Id from RecordType where sObjectType = 'Product2' and Name = 'Subscription' LIMIT 1][0];
		proNeg.IsActive = True;
		proNeg.Subscription_Product__c = False;
		proNeg.SUSA_Product__c = False;
		insert proNeg;
		System.debug('Steve is product Neg SUSA'+' '+proNeg.SUSA_Product__c);
    	
		//Create Pricebook entry
		PricebookEntry pbe = new PricebookEntry();
		pbe.IsActive = True;
		pbe.Pricebook2Id = stdPricebook.Id;
		pbe.Product2Id = proPos.Id;
		pbe.UnitPrice = 100;
		insert pbe;
		System.debug('Steve priceBookId'+' '+pbe.Id);

		//Create Account
		Account acc = new Account();
		acc.Name = 'TestCo';
		acc.CurrencyIsoCode = 'GBP';
		acc.Active__c = True;
		insert acc;
		System.debug('Steve acc Name'+' '+acc.Name);
		
		//Create conatct
		Contact contact = new Contact();
		contact.AccountId = acc.Id;
		contact.LastName = 'Contact';
		contact.FirstName = 'Test';
		insert contact;
        System.debug('Steve ContactId'+' '+contact.Id);
        
		//Create Opportunity
		Opportunity opp = New Opportunity();
		opp.Name = 'Test Opp';
		RecordType rType = [Select Id From RecordType where sObjectType = 'Opportunity' and name = 'Subscription' and isactive=true LIMIT 1][0];
		opp.RecordTypeId = rType.Id;
		opp.AccountId = acc.id;
		opp.Subscription_Start_Date__c = Date.today();
		opp.CloseDate = Date.today();
		opp.StageName = 'Qualifying';
		insert Opp;
        System.debug('Steve Opp Stage on creation'+' '+Opp.StageName);
        
        //Create Contact Role
		OpportunityContactRole oppContRole = new OpportunityContactRole();
		oppContRole.OpportunityId = opp.Id;
		oppContRole.ContactId = contact.Id;
		oppContRole.IsPrimary = True;
		oppContRole.Role = 'Sales Contact';
		insert oppContRole;
		System.debug('Steve contact role Id'+' '+oppContRole.Id);
        
        //Create Opp Line item
		OpportunityLineItem oppLine = new OpportunityLineItem();
		oppLine.OpportunityId = opp.Id;
		oppLine.PricebookEntryId = pbe.Id;
		oppLine.Quantity = 1;
		oppLine.TotalPrice = 100;
		insert oppLine;
		System.debug('Steve Opp Line Id'+' '+oppLine.Id);
        
        //Update Opp stagename after product has been added to deal with validation rule
		//Opp.StageName = 'Booking Received';
		//update Opp;
		//system.debug('Steve Opp Stage after update'+Opp.StageName);
        
        
        //Create subcription
		Subscription__c sub = new Subscription__c();     
		sub.Account_Name__c = Acc.Id;
		sub.Contact__c = contact.Id;
		sub.Opportunity__c = opp.Id;
		sub.Start_Date__c = Date.today();
		sub.Status__c = 'Current';
		sub.Type__c = 'New';
		insert sub;
        System.debug('Steve Sub Includes SUSA? on creation'+' '+sub.Includes_SUSA_Product__c);
        system.debug('Steve SubID ' +sub.Id);
        
        //Create Subscription Line
		Subscription_Line__c subLn= new Subscription_Line__C();
		subLn.Subscription__c = sub.Id;
		subLn.Product__c = proPos.Id;
		System.debug('Steve1111'+' '+subLn.Id);
		insert subLn;
		System.debug('Steve'+' '+subLn.Id);
		System.debug('Steve Sub Includes SUSA? on creation of Sub Line'+[Select Includes_SUSA_Product__c from subscription__c where Id = :Sub.Id]);
        
        //Create Subscription Site
		Subscription_Site__C subSite = new Subscription_Site__C();
		subSite.Subscription__c = sub.Id;
		subSite.Site_Start_Date__c = sub.Start_Date__c;
		subSite.Active__c = True;
		subSite.Type__c = 'Single Site';
		subSite.Site_Account__c = acc.Id;
		subSite.Site_Contact__c = contact.Id;
		insert subSite;
		System.debug('Steve subSiteId'+' '+subSite.Id);
        
        //Create Subscription site product
		Site_Product__c siteProd = new Site_Product__c();
		siteProd.Subscription__c = sub.Id;
        siteProd.Subscription_Line__c = subLn.Id;
        siteProd.Subscription_Site__c = subSite.Id;
        siteProd.Site_Product_Contact__c = contact.Id;
        insert siteProd;
		System.debug('Steve SiteProdId'+' '+siteProd.Id); 
		
		//Create subcription
		Subscription__c subNeg = new Subscription__c();     
		subNeg.Account_Name__c = Acc.Id;
		subNeg.Contact__c = contact.Id;
		subNeg.Opportunity__c = opp.Id;
		subNeg.Start_Date__c = Date.today();
		subNeg.Status__c = 'Current';
		subNeg.Type__c = 'New';
		insert subNeg;
        System.debug('Steve Sub Includes SUSA? on creation'+' '+subNeg.Includes_SUSA_Product__c);
        system.debug('Steve SubID ' +subNeg.Id);
        
        //Create Subscription Line
		Subscription_Line__c subLnNeg= new Subscription_Line__C();
		subLnNeg.Subscription__c = subNeg.Id;
		subLnNeg.Product__c = proNeg.Id;
		System.debug('Steve1111'+' '+subLnNeg.Id);
		insert subLnNeg;
		System.debug('Steve'+' '+subLnNeg.Id);
		System.debug('Steve Sub Includes SUSA? on creation of Sub Line'+[Select Includes_SUSA_Product__c from subscription__c where Id = :SubNeg.Id]);
        
        //Create Subscription Site
		Subscription_Site__C subSiteNeg = new Subscription_Site__C();
		subSiteNeg.Subscription__c = subNeg.Id;
		subSiteNeg.Site_Start_Date__c = sub.Start_Date__c;
		subSiteNeg.Active__c = True;
		subSiteNeg.Type__c = 'Single Site';
		subSiteNeg.Site_Account__c = acc.Id;
		subSiteNeg.Site_Contact__c = contact.Id;
		insert subSiteNeg;
		System.debug('Steve subSiteId'+' '+subSiteNeg.Id);
        
        //Create Subscription site product
		Site_Product__c siteProdNeg = new Site_Product__c();
		siteProdNeg.Subscription__c = subNeg.Id;
        siteProdNeg.Subscription_Line__c = subLnNeg.Id;
        siteProdNeg.Subscription_Site__c = subSiteNeg.Id;
        siteProdNeg.Site_Product_Contact__c = contact.Id;
        insert siteProdNeg;
		System.debug('Steve SiteProdId'+' '+siteProd.Id); 
		
		Test.StartTest();
		//Positive test - product flag - true
		//Subscription__c Output;
		//Output = [Select Includes_SUSA_Product__c from subscription__c where Id = :Sub.Id LIMIT 1][0].Includes_SUSA_Product__c;
		Boolean returnflagPos = [Select Includes_SUSA_Product__c from subscription__c where Id = :Sub.Id LIMIT 1][0].Includes_SUSA_Product__c;
		System.assert(returnflagPos == True,'Inc SUSA flag update has failed FAIL');
		
		//Negative test - product flag - false 
		Boolean returnFlagNeg = [Select Includes_SUSA_Product__c from subscription__c where Id = :SubNeg.Id LIMIT 1][0].Includes_SUSA_Product__c;
		System.assert(returnFlagNeg == False,'Inc SUSA flag update has failed FAIL');
		
		Test.StopTest();
        
    	/*
    		CREATE TEST DATA
    		================
    		Create an account
    		Create a contact
    		Create a opp
    		Create prods (one with Product2.SUSA_Product__c == true, one Product2.SUSA_Product__c == false)
    		Create Opp lines
    		Create sub
    		create sub lines
    		c sub prod
    		c sub sites
    		join sub opps
    		
    		1. Prod.Product__r.SUSA_Product__c == true & Sub = INCLUDES_SUSA_Product__c == true EXPECTED: sub.INCLUDES_SUSA_Product__c == true
    		2. Prod.Product__r.SUSA_Product__c == false & Sub = INCLUDES_SUSA_Product__c == true EXPECTED: sub.INCLUDES_SUSA_Product__c == false
    		3. Prod.Product__r.SUSA_Product__c == true (multiple false with one true) & Sub = INCLUDES_SUSA_Product__c == true EXPECTED: sub.INCLUDES_SUSA_Product__c == true
    		4. Prod.Product__r.SUSA_Product__c == false (multiple true with one false) & Sub = INCLUDES_SUSA_Product__c == true EXPECTED: sub.INCLUDES_SUSA_Product__c == false
    		5. Bulk tests (clone subs and opps etc for XXX records and put in list);
    		
    		
    		
    		START TEST
    		==========
    		Test.StartTest();
    		
    		
    		CHECK RESULTS:
    		==============
    		System.assert(sub.INCLUDES_SUSA_Product__c == true, 'The sub isnt updating the XXX field for whatever test');
    		
    		Test.StopTest();
    		
    	
    	*/
    	
    	
	  /*
	  Subscription_Line__c subsLine = [Select Id from Subscription_Line__c limit 1];
	  c2g__codaInvoiceLineItem__c invoiceLineItem = [Select Id,SL__c,c2g__Invoice__c from c2g__codaInvoiceLineItem__c where c2g__Invoice__c='a1ZD0000000TTYV' limit 1];
	  c2g__codaInvoice__c invoice = [Select c.Id, c.Copy_Invoice_Status__c From c2g__codaInvoice__c c where Id=:invoiceLineItem.c2g__Invoice__c limit 1];
	  invoice.Copy_Invoice_Status__c = 'Paid';
	  update invoice;
	  Map<Id,Subscription_Line__c> subsLineMap= new Map<Id,Subscription_Line__c>();
	  subsLineMap.put(subsLine.Id,subsLine);
	  invoiceLineItem.SL__c = subsLine.Id;
	  update invoiceLineItem;
	  SubscriptionLineTriggerMethods.updateInvoiceStatus(subsLineMap);
	  */
    }
}