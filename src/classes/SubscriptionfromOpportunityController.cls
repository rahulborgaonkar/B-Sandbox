public with sharing class SubscriptionfromOpportunityController {
	
	private Opportunity record;
	
	public class Custom_Exception extends Exception{}
	
  	public SubscriptionfromOpportunityController(ApexPages.StandardController controller){
    	record = getOpportunity(controller.getId()); 
 	}
  
  	private class subscriptionSite {
  	    public Id Subscription_Id;
        public Id Account_Id;
        public Id Contact_Id;
        public String Site_Type;
        public Id Opportunity_Id;
        public Id [] SubLineIdList;
  	}
  	
  	private Opportunity getOpportunity(Id id){
    	List<Opportunity> OpportunityQuery = [Select Pricebook2Id,Subscription_Start_Date__c, Subscription_Initiating_Renewal__c, 
    	Renewal_Opportunity__c, Id, AccountId From Opportunity Where Id = :id];
    	
    	if (OpportunityQuery.size() == 1) return OpportunityQuery.get(0);
    	
    	return null;
	}  
 
	public PageReference doAction() {    
		
		// Disable the Subscription account flag triggers. This is because this subscription
		// is a new subscription which will not be current so no need to run update.
		ApexCodePatrol.disable('AccountSubscriptionFlags');
		// Disabling SubLine sub flags this will need to be fixed at the end of the process
		ApexCodePatrol.disable('AccountSubscriptionLineFlags');
		
		Savepoint SP = Database.setSavepoint();     
        
        //Create a new Subscription Record
        Subscription__c NewSubscription=new Subscription__c();
        NewSubscription.Opportunity__c=record.id;
        NewSubscription.Account_Name__c =record.AccountId;
        NewSubscription.Status__c='Pending - Not Paid';
        NewSubscription.Start_Date__c=record.Subscription_Start_Date__c;
        NewSubscription.Previous_Subscription__c=record.Subscription_Initiating_Renewal__c;
        
        List<OpportunityContactRole> OppContRole=[Select ContactId  from OpportunityContactRole where IsPrimary=true and  OpportunityId=:record.id limit 1];
        if (!OppContRole.IsEmpty()) {
            NewSubscription.Contact__c=OppContRole[0].ContactId;
            System.debug('Adding Contact to Subscription ('+OppContRole[0].ContactId);
        }else{
            System.debug('Unable to add Contact to Subscription');
        }
        
        if (record.Renewal_Opportunity__c) { 
                NewSubscription.Type__c='Renewal';
        } else {
                NewSubscription.Type__c='New';
        }
        
        insert NewSubscription; 

		// Update opp with subscription
		Opportunity oppToUpdate = [SELECT Id, Subscription__c FROM Opportunity WHERE Id = :record.Id];
		oppToUpdate.Subscription__c = NewSubscription.Id;
		update oppToUpdate;
		
		//try{      
	        List<Subscription__c> Subscription4Update = [Select Id,Status__c From Subscription__c  where Id=:record.Subscription_Initiating_Renewal__c LIMIT 1 ];
	        
	        if (!Subscription4Update.IsEmpty())  {
	            Subscription4Update[0].Subsequent_Subscription__c=NewSubscription.id;
	            if(Subscription4Update[0].End_Date__c>system.today()){
	                    Subscription4Update[0].Status__c='Current - Renewed';
	            } else {
                    Subscription4Update[0].Status__c='Ended - Renewed'; 
                } 
            	Update Subscription4Update[0];
        	} 
        	
	        //Create SubscriptionLines
	        String strProductCodes='';
	        Integer iRecCnt=0;
	        List<Subscription_Line__c> NewSubscriptionLineItems = new List<Subscription_Line__c>();                                      
	        for (OpportunityLineItem OppLineItem: [Select Id,PricebookEntry.product2Id,PricebookEntry.Product2.Duration_Years__c,Quantity,
	        	PricebookEntry.Product2.ProductCode,TotalPrice,Renewal_Price__c,E_Delivery_Total_Licences__c From OpportunityLineItem 
	        	where  OpportunityId= :record.Id and PricebookEntry.Product2.Subscription_Product__c = true]) {   
	        		
                Subscription_Line__c NewSubscriptionLineItem=new Subscription_Line__c();
                NewSubscriptionLineItem.Subscription__c=NewSubscription.Id;
                NewSubscriptionLineItem.Quantity__c=OppLineItem.Quantity;
                NewSubscriptionLineItem.Quantity_Available__c=0;
                NewSubscriptionLineItem.Product_Sales_Price__c=OppLineItem.TotalPrice;
                NewSubscriptionLineItem.Product__c=OppLineItem.PricebookEntry.product2Id;
                NewSubscriptionLineItem.Renewal_Price__c=OppLineItem.Renewal_Price__c;
                NewSubscriptionLineItem.OPL_ID__c  = OppLineItem.Id;
                NewSubscriptionLineItem.E_Delivery_Number_of_Licences__c=OppLineItem.E_Delivery_Total_Licences__c;
                NewSubscriptionLineItems.add(NewSubscriptionLineItem);
                
                strProductCodes = strProductCodes + OppLineItem.PricebookEntry.Product2.ProductCode + ',';
                iRecCnt = iRecCnt+1;
                if (iRecCnt==1) {
                    if(OppLineItem.PricebookEntry.Product2.Duration_Years__c>0.0 && NewSubscription.Start_Date__c != null) {
                            //NewSubscription.End_Date__c=NewSubscription.Start_Date__c.addYears((Integer)(OppLineItem.PricebookEntry.Product2.Duration_Years__c));
                            NewSubscription.End_Date__c=(NewSubscription.Start_Date__c.addYears((OppLineItem.PricebookEntry.Product2.Duration_Years__c.intValue())))-1;
                     }
                }
            }           
	            
            update NewSubscription;

			System.debug('Subscription Lines: '+NewSubscriptionLineItems);
            if (!NewSubscriptionLineItems.IsEmpty()){
              strProductCodes = strProductCodes.substring(0, strProductCodes.length()-1);
              NewSubscription.Product_Codes__c=strProductCodes;
              update NewSubscription;
              insert NewSubscriptionLineItems;
            }
            
            /*
            START: SETUP SITES AND PRODUCTS
            */
	            
	            List<SubscriptionSite> subSites = new List<SubscriptionSite>();
	            
	            List<Subscription_Line__c> coreSubLines = new List<Subscription_Line__c>([SELECT 
														Id,
														Quantity__c, 
														Product__r.Core_Subscription_Product__c,
														Product__r.RCP_Product__c,
														Product__r.E_Delivery_Subscription__c
													FROM 
														Subscription_Line__c
													WHERE 
														Subscription__c = :NewSubscription.Id AND 
														Product__r.Core_Subscription_Product__c = True]);

	            List<Subscription_Line__c> nonCoreSubLines = new List<Subscription_Line__c>([SELECT 
														Id,
														Quantity__c, 
														Product__r.Core_Subscription_Product__c,
														Product__r.RCP_Product__c,
														Product__r.E_Delivery_Subscription__c
													FROM 
														Subscription_Line__c
													WHERE 
														Subscription__c = :NewSubscription.Id AND 
														Product__r.Core_Subscription_Product__c = False]);
	            
	            // See if the site is part of a multi-site subscription
	            
	            Double totalQtyCoreProducts = 0;
	            Boolean isSingleSiteSub = false;
	            for(Subscription_Line__c coreSubLine : coreSubLines){
	            	if (coreSubLine.Product__r.RCP_Product__c == True || coreSubLine.Product__r.E_Delivery_Subscription__c == True){
	            		// RCPs always only have 1 site.
	            		totalQtyCoreProducts = 1;
	            		isSingleSiteSub = True;
	            	}else{
		            	totalQtyCoreProducts = coreSubLine.Quantity__c + totalQtyCoreProducts;
	            	}
	            }
	            
	            // Reorder the core and non core products for RCPs & LMS so that there are only one core and the rest non-core
	            if (isSingleSiteSub){
	            	
	            	List<Subscription_Line__c> newCoreSubLinesList = new List<Subscription_Line__c>();
	            	
	            	System.debug('FJP IS RCP:'+coreSubLines.size());
		            for (integer i=0; i < coreSubLines.size(); i++){
		            	if (i==0 && coreSubLines[i].Quantity__c > 1){
		            		throw new Custom_Exception('First opportunity product MUST have a quantity of 1');
            				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'First opportunity product MUST have a quantity of 1'); 
            				ApexPages.addMessage(myMsg);
            			}else if (i==0){
		            		newCoreSubLinesList.add(coreSubLines[i]);
		            	}else{
		            		nonCoreSubLines.add(coreSubLines[i]);
		            	}
		            }
		            coreSubLines = newCoreSubLinesList;
	            }
	            System.debug('Core Products List: '+coreSubLines);
	            System.debug('Non Core Products List: '+nonCoreSubLines);
	            
	            System.debug('Number of Core Products: '+totalQtyCoreProducts);

	            Double totalQtyNonCoreProducts = 0;
	            List<Subscription_Line__c> nonCoreSubLinesExploded = new List<Subscription_Line__c>();
	            
	            // Need to swap out the no-core products list with the core products if its RCP.
	            // Also add a validation on products that all RCPs must be core products.
	            System.debug('FJP: CoreSubLines Size: '+coreSubLines.size());
	            System.debug('FJP: nonCoreSubLines Size: '+isSingleSiteSub+' '+noncoreSubLines.size());

				
	            for(Subscription_Line__c nonCoreSubLine : nonCoreSubLines){
	            	// Get total of non Core products
	            	totalQtyNonCoreProducts = nonCoreSubLine.Quantity__c + totalQtyNonCoreProducts;
	            	
	            	// Create a list of lines based on the quantity so that items can be popped off the list and allocated
	            	// to sites.
	            	for (Decimal i=0; nonCoreSubLine.Quantity__c > i; i++){
	            		nonCoreSubLinesExploded.add(nonCoreSubLine);
	            	}
	            }
	            System.debug('Number of Non Core Products: '+totalQtyNonCoreProducts);

	            Double prodsPerCoreProd = 0;
	            
	            if (totalQtyCoreProducts != 0){
		            prodsPerCoreProd = totalQtyNonCoreProducts / totalQtyCoreProducts;
	            }
	            System.debug('prodsPerCoreProd: '+prodsPerCoreProd);
	            //AggregateResult qtyCoreProducts = [Select SUM(Quantity) amt From OpportunityLineItem WHERE Opportunity.Id = :record.id AND PriceBookEntry.Product2.Core_Subscription_Product__c = True][0];
				//Double totalQtyCoreProducts = Double.valueof(qtyCoreProducts.get('amt'));
				
				Boolean primarySet = false;
				
	            for (Subscription_Line__c coreSubLine : coreSubLines){
	            	System.debug('Core subLine quantity: '+coreSubLine.Quantity__c);
	            	
					for (Decimal i = 0; coreSubLine.Quantity__c > i; i++){

						String SubType = null;
						
						if(!(totalQtyCoreProducts == 1)){
							if (primarySet){
								SubType = 'Multi-Site Subsidiary';
							}else{
								SubType = 'Multi-Site Primary';
							}
						}else{
							SubType = 'Single Site';
						}
						primarySet = true;
						
						SubscriptionSite subSite = new SubscriptionSite();
						subSite.Subscription_Id = NewSubscription.Id;
						subSite.Account_Id = record.AccountId;
				        if (!OppContRole.IsEmpty()) {
            				subSite.Contact_Id = OppContRole[0].ContactId;
        				}
						
        				subSite.Site_Type = SubType;
        				subSite.Opportunity_Id = record.Id;
        				// Set Products to site
    					Set<Id> subLineIds = new Set<Id>();
						// Add core product
        				subLineIds.add(coreSubLine.Id);
        				Boolean prodsToAssign = true;
        				Integer productsAssigned = 0;
        				Integer arrItemToLookAt = 0;
        				// Emergancy break to stop loop if more modules are added than available sites.
        				Double EmergancyBreak = 0;
        				
        				// Add non core products to site
        				while(prodsToAssign){
        					System.debug('More modules need to be assigned to site FJP: '+nonCoreSubLinesExploded.size());
        					if (!nonCoreSubLinesExploded.isEmpty()){
        						if (isSingleSiteSub){
	        							subLineIds.add(nonCoreSubLinesExploded[arrItemToLookAt].Id);
	        							nonCoreSubLinesExploded.remove(arrItemToLookAt);
	        							productsAssigned++;
        						}else{
	        						System.debug('The available modules list is not empty: '+arrItemToLookAt+' nonCore: '+nonCoreSubLinesExploded);
	        						if(!subLineIds.contains(nonCoreSubLinesExploded[arrItemToLookAt].Id)){
		        						System.debug('The module hasnt been added before to this site so add it');
		     
	        							subLineIds.add(nonCoreSubLinesExploded[arrItemToLookAt].Id);
	        							nonCoreSubLinesExploded.remove(arrItemToLookAt);
	        							productsAssigned++;
	        						}else{
		        						System.debug('The module has already been added to this site, increment arrItemToLookAt');
	        							arrItemToLookAt++;
	        						}
        						}
        					}
        					if(nonCoreSubLinesExploded.isEmpty() || productsAssigned >= prodsPerCoreProd){
        						System.debug('The available modules have been exhaused or the number of modules needed for the site has been allocated');
        						prodsToAssign = false;        						
        					}
        					EmergancyBreak++;
        					if(EmergancyBreak > 30){
        						System.debug('Emergancy break has been activated, caught in infinate loop');
        						prodsToAssign = false;
        					}
        				}
        				System.debug('subline ids: '+subLineIds);
    					List<Id> subLineIdsList = new List<Id>();
						for(Id subLineId : subLineIds){
							subLineIdsList.add(subLineId);
						}
        				subSite.SubLineIdList = subLineIdsList;

        				//
        				subSites.add(subSite);
					}
				}
				System.debug('Sub Sites: '+subSites);
				
				// Loop over all sites and create sites
				List<Subscription_Site__c> newSitesList = new List<Subscription_Site__c>();
				for (SubscriptionSite subSite: subSites){
					
					System.debug(subSite);

			        Subscription_Site__c newSubSite = new Subscription_Site__c();
			        newSubSite.Subscription__c = subSite.Subscription_Id;
			        newSubSite.Type__c = subSite.Site_Type;
			        newSubSite.Active__c = true;
					newSitesList.add(newSubSite);
					
					//Boolean result = addSubSiteWithoutSubLines(null, null, subSite.Subscription_Id,subSite.Site_Type, subSite.SubLineIdList);
					//System.debug('Site Add Result: '+result);
				}
				insert newSitesList;
				
		        // Build Subscription Site Products
		        List<Site_Product__c> SiteProductsList = new list<Site_Product__c>();       

				// Loop over inserted sites and create products list to create
				for (Integer i=0; newSitesList.size() > i; i++){
					// The subSite class with the subLines attached to it.
					SubscriptionSite subSite = subSites.get(i);
					// The new subSites list
					Subscription_Site__c newSubsite = newSitesList.get(i);
								        
			        // START: Create Subscription Products
			        for(Id subLineWithId : subSite.SubLineIdList )
			        {
			            Site_Product__c siteProduct = new Site_Product__c();
			            // add the product to the subscription products list
			            siteProduct.Subscription__c = subSite.Subscription_Id;
			            siteProduct.Subscription_Site__c = newSubsite.id;
			            siteProduct.Subscription_Line__c  = subLineWithId;
			            //siteProduct.Site_Product_Contact__c = null;
			            SiteProductsList.add(siteProduct);
			        }
				}

			    insert SiteProductsList;
			    
	            /*
	            END: SETUP SITES AND PRODUCTS
	            */

		/*}catch(Exception e) {
            	
            	System.debug('** found exception, rolling back' + e);
            	
                // roll back everything
                Database.rollback(SP);
                Apexpages.addMessages(e);
                return null;
        }*/
            
        System.debug('** No exception found committing');
        
        // Re-enable triggers
		ApexCodePatrol.enable('AccountSubscriptionFlags');
		ApexCodePatrol.enable('AccountSubscriptionLineFlags');
		
		// Run the flag flags update trigger AccountSubscriptionLineTriggers that was disabled as part of the logic above:
		List<Subscription_Line__c> subLineList = new List<Subscription_Line__c>([SELECT Id, 
																					Subscription__c 
																				FROM 
																					Subscription_Line__c 
																				WHERE 
																					Subscription__c = :NewSubscription.Id]);
		SubscriptionLineTriggerMethods.updateSubscriptionProdStatus(subLineList);
		
    	//return new Pagereference('/'+ NewSubscription.Id);
    	//return new PageReference('/apex/MembershipApplicationForm?id='+record.Id);
    	return new PageReference('/'+record.Id);
	} 
    
    /* 
     * CREATE SUBSCRIPTION SITE - Creates a subscription site
     * 
     */
    private static Boolean addSubSiteWithoutSubLines (Id Account_Id, Id Contact_Id, Id Subscription_Id, String Site_Type, List<Id> SubscriptionLineList){

        // Create the subscription site first
        Subscription_Site__c subSite = new Subscription_Site__c();
        subSite.Site_Account__c = Account_Id;
        subSite.Site_Contact__c = Contact_Id;
        subSite.Subscription__c = subscription_Id;
        subSite.Type__c = Site_Type;
        subSite.Active__c = true;
        
        insert subSite;
        
        string StrProductCodes='';

        // Build Subscription Site Products
        List<Site_Product__c> SiteProductsList = new list<Site_Product__c>();       
        
        // START: Create Subscription Products
        for(Id subLineWithId : SubscriptionLineList )
        {
            Site_Product__c siteProduct = new Site_Product__c();
            // add the product to the subscription products list
            siteProduct.Subscription__c = subscription_Id;
            siteProduct.Subscription_Site__c = subSite.id;
            siteProduct.Subscription_Line__c  = subLineWithId;
            siteProduct.Site_Product_Contact__c = Contact_Id;
            SiteProductsList.add(siteProduct);
        }
        
        try {
            insert SiteProductsList;

        }catch(Exception e){
            // error occurred populate error object.
            // @todo
        }       
        // END: Create Subscription Products
        
        
        // Now we have iterated through the opp products and got the codes update the subscription with the codes:
        subSite.Subscription_Site_Product_Codes__c = StrProductCodes;
        update subSite;
        
        return true;		
    }    


    @IsTest
    private static void testNonSubscriptionProduct()
    {   
        //Create an Account
        Account NewAccount=new Account(name='Test SSCreation Account');
        insert NewAccount;       
        
        // Add a Contact to it
        Contact NewContact= new Contact(LastName='Test SSCreation Contact', Email='testy13213@fffp.com', FirstName = 'Test', Salutation = 'Mr');
        NewContact.AccountId=NewAccount.id;
        insert NewContact;
            
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Qualifying';
        opp.CloseDate = System.today();
        opp.AccountId=NewAccount.id;
        opp.Subscription_Start_Date__c = System.today();
        insert opp;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = NewContact.id;
        oppContRole.OpportunityId = opp.id;
        oppContRole.IsPrimary = true;
        insert oppContRole;
        
        Product2 prod = new Product2();
        prod.Name = 'Test  Product';
      	prod.Subscription_Product__c = true;
        insert prod;
        
        Pricebook2 stdPricebook = [Select Id From Pricebook2 Where IsStandard = true Limit 1];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 300;
        pbe.Pricebook2Id = stdPricebook.Id;
        pbe.IsActive = true;
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 3;
        oli.UnitPrice = 320;
        
        insert oli;
        
        PageReference PageRef=Page.CreateSubscriptionFromOpportunity;
        test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        SubscriptionfromOpportunityController controller= new SubscriptionfromOpportunityController(sc);
        controller.doAction();  
        
        System.debug('** Assert looking for account: ' + NewAccount.id + ' , opp id: ' + opp.Id);
        
        List<Subscription__c> subscriptionList = [select Id from Subscription__c where Account_Name__c = :NewAccount.id and Opportunity__c = :opp.Id];
        Integer subsCount = subscriptionList.size();
        
        System.debug('** Found subscriptions count: ' + subsCount);
        
        System.assertEquals(1, subsCount);
        
        Integer subLineCount = [select count() from Subscription_Line__c where Subscription__c = :subscriptionList.get(0).Id];
        System.assertEquals(1, subLineCount);
    }


    @IsTest
    private static void tesSubscriptionProduct()
    {   
        //Create an Account
        Account NewAccount=new Account(name='Test SSCreation Account');
        insert NewAccount;       
        
        // Add a Contact to it
        Contact NewContact= new Contact(LastName='Test SSCreation Contact', Email='testy13213@fffp.com', FirstName = 'Test', Salutation = 'Mr');
        NewContact.AccountId=NewAccount.id;
        insert NewContact;
            
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Qualifying';
        opp.CloseDate = System.today();
        opp.AccountId=NewAccount.id;
        opp.Subscription_Start_Date__c = System.today();
        insert opp;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = NewContact.id;
        oppContRole.OpportunityId = opp.id;
        oppContRole.IsPrimary = true;
        insert oppContRole;
        
        Product2 prod = new Product2();
        prod.Name = 'Test  Product';
        prod.Duration__c='1 Year';
      	prod.Subscription_Product__c = false;
        insert prod;
        
        Pricebook2 stdPricebook = [Select Id From Pricebook2 Where IsStandard = true Limit 1];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 300;
        pbe.Pricebook2Id = stdPricebook.Id;
        pbe.IsActive = true;
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 3;
        oli.UnitPrice = 320;
        
        insert oli;
        
        PageReference PageRef=Page.CreateSubscriptionFromOpportunity;
        test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        SubscriptionfromOpportunityController controller= new SubscriptionfromOpportunityController(sc);
        controller.doAction();  
        
        System.debug('** Assert looking for account: ' + NewAccount.id + ' , opp id: ' + opp.Id);
        
        List<Subscription__c> subscriptionList = [select Id from Subscription__c where Account_Name__c = :NewAccount.id and Opportunity__c = :opp.Id];
        Integer subsCount = subscriptionList.size();
        
        System.debug('** Found subscriptions count: ' + subsCount);
        
        System.assertEquals(1, subsCount);
        
        Integer subLineCount = [select count() from Subscription_Line__c where Subscription__c = :subscriptionList.get(0).Id];
        System.assertEquals(0, subLineCount);
    }
    
    @IsTest
    private static void testExceptionPath()
    {   
        //Create an Account
        Account NewAccount=new Account(name='Test SSCreation Account');
        insert NewAccount;       
        
        // Add a Contact to it
        Contact NewContact= new Contact(LastName='Test SSCreation Contact', Email='testy13213@fffp.com', FirstName = 'Test', Salutation = 'Mr');
        NewContact.AccountId=NewAccount.id;
        insert NewContact;
            
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Qualifying';
        opp.CloseDate = System.today();
        opp.AccountId=NewAccount.id;
        insert opp;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = NewContact.id;
        oppContRole.OpportunityId = opp.id;
        oppContRole.IsPrimary = true;
        insert oppContRole;
        
        Product2 prod = new Product2();
        prod.Name = 'Test  Product';
        prod.Duration__c='1 Year';
      	prod.Subscription_Product__c = true;
        insert prod;
        
        Pricebook2 stdPricebook = [Select Id From Pricebook2 Where IsStandard = true Limit 1];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 300;
        pbe.Pricebook2Id = stdPricebook.Id;
        pbe.IsActive = true;
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 3;
        oli.UnitPrice = 320;
        
        insert oli;
        
        PageReference PageRef=Page.CreateSubscriptionFromOpportunity;
        test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        SubscriptionfromOpportunityController controller= new SubscriptionfromOpportunityController(sc);
        controller.doAction(); 
    }
}