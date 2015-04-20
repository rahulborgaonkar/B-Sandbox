public with sharing class SiteProductTriggerMethods {

	/*
	 * SET SUB SITE PRODUCT CODES (Subscription Line)
	 *
	 * If the product has changed on the subscription line then force an update of the product codes on the subscription site.
	 */
	public static void setSubSiteProductCodes(List<Subscription_Line__c> oldSubLines, List<Subscription_Line__c> newSubLines){

		Set<Id> subLinesToUpd = new Set<Id>();
                
        // Loop over records and see if the products have changed and if so then trigger an update of the sub site product codes
        for (Integer i=0; oldSubLines.size() > i; i++){
            if ((oldSubLines[i].Product__c <> newSubLines[i].Product__c)){
                subLinesToUpd.add(newSubLines[i].Id);
            }
        }
        if (subLinesToUpd.size() > 0){
        	
	        List<Site_Product__c> siteProdsToUpd = new List<Site_Product__c>([SELECT
	        																Id,
	        																Subscription_Site__c
	        															FROM
	        																Site_Product__c
	        															WHERE
	        																Subscription_Line__c IN :subLinesToUpd]);
	        setSubSiteProductCodes(siteProdsToUpd);
        }
        
	}
	
	/*
	 * SET SUB SITE PRODUCT CODES (Site_Product__c)
	 *
	 * Gets unique set of subscription sites and then passes to method to work out product codes
	 */
	public static void setSubSiteProductCodes(List<Site_Product__c> siteProducts){
		
		Set<Id> subSites = new Set<Id>();
		for (Site_Product__c siteProduct : siteProducts){
			subSites.add(siteProduct.Subscription_Site__c);
		}
		setSubSiteProductCodes(subSites);
	}
	
	/*
	 * SET SUB SITE PRODUCT CODES (Subscription_Site__c)
	 *
	 * Works out the product codes for the sub site.
	 */
	public static void setSubSiteProductCodes(Set<Id> subSiteIds){
		
    	if (subSiteIds.size() > 0){
	    	List<Subscription_Site__c> allSubSites = new List<Subscription_Site__c>([SELECT
	    											Id,
	    											Subscription_Site_Product_Codes__c,
	    											Site_Status__c,
	    											(SELECT
	    												Id,
	    												Subscription_Line__r.Product__r.ProductCode
	    												FROM
	    													Site_Products__r)
	    											FROM
	    												Subscription_Site__c
	    											WHERE
	    												Id IN :subSiteIds]);
	    	String strProductCodes = '';
	    	for (Subscription_Site__c subSite : allSubSites){
				strProductCodes = '';
				for (Site_Product__c subSiteProd : subSite.Site_Products__r){
					if (strProductCodes == ''){
						strProductCodes = subSiteProd.Subscription_Line__r.Product__r.ProductCode;
					}else{
						// Add new product code but only if it fits in the string:
						if (strProductCodes.length()+subSiteProd.Subscription_Line__r.Product__r.ProductCode.length() < 255){
							strProductCodes=strProductCodes+';'+subSiteProd.Subscription_Line__r.Product__r.ProductCode;
						}
					}
				}
				subSite.Subscription_Site_Product_Codes__c = strProductCodes.left(255);
	    	}
	    	update allSubSites;
    	}		
	}
	
	@isTest
	static void testSetSubSiteProductCodes(){
		
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
        prod.ProductCode = 'TESTCODE1';
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
        oli.Quantity = 1;
        oli.UnitPrice = 120;
        
        insert oli;
        
        Subscription__c sub = new Subscription__c();
        sub.Account_Name__c = NewAccount.Id;
        sub.Contact__c = NewContact.Id;
        sub.End_Date__c = Date.today()+365;
        sub.Opportunity__c = opp.Id;
        sub.Start_Date__c = Date.today()-1;
        sub.Status__c = 'Current';
        sub.Type__c = 'New';
        insert sub;
        
        Subscription_Line__c subLine = new Subscription_Line__c();
        subLine.OPL_ID__c = oli.Id;
        subLine.Product__c = prod.Id;
        subLine.Quantity__c = 1;
        subLine.Subscription__c = sub.Id;
        insert subLine;
        
        Subscription_Site__c subSite = new Subscription_Site__c();
        subSite.Active__c = True;
        subSite.Main_Site__c = True;
        subSite.Site_Account__c = NewAccount.Id;
        subSite.Site_Contact__c = NewContact.id;
        subSite.Site_Start_Date__c = Date.today()-1;
        subSite.Subscription__c = sub.Id;
        subSite.Type__c = 'Single Site';
        subSite.Subscription_Site_Product_Codes__c = null;
        insert subSite;
        
        Site_Product__c siteProd = new Site_Product__c();
        siteProd.Site_Product_Contact__c = NewContact.Id;
        siteProd.Subscription__c = sub.Id;
        siteProd.Subscription_Line__c = subLine.Id;
        siteProd.Subscription_Site__c = subSite.Id;
        insert siteProd;
        update siteProd;
        //System.assertEquals(subSite.Subscription_Site_Product_Codes__c, 'TESTCODE1');
        
	}
	
}