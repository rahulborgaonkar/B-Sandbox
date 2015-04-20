public with sharing class WebsiteOrder {
	
    private final Opportunity thisOpportunity;
	
    /**
    * CONSTRUCTOR
    */
    public WebsiteOrder(ApexPages.StandardController stdController) {
        this.thisOpportunity = (Opportunity)stdController.getRecord();    
    }

    /**
    * GETTERS
    */

    /*
     * GET ORGANISATION ID
     *
     * Gets the current org's organisation ID.
     */
    public Id getOrgId(){
		return UserInfo.getOrganizationId();
		
    }
    
    /*
     * GET HOSTNAME
     *
     * Gets the hostname/URL to talk to the website and test system depending on if we
     * are in test or production. Hostname turned into full URL after an issue with SSL
     * keys within WebAnywhere.
     */
    public String getHostname(){
    	Id orgId = getOrgId();
    	String hostname = '';
    	if (orgId == '00D20000000MXUnEAO'){
    		// Is Production
    		hostname = 'www.britsafe.org';
    	}else{
    		// Is a sandbox (anything else)
    		hostname = 'britsafe.drupal.webanywhere.co.uk';
    	}
    	return hostname;
    }
    
    /*
     * GET MD5 HASH
     *
     * Generates the security hash to communicate with the britSafe website
     * to make sure communication from Salesforce is authenticated.
     */
	public String getMD5(){
		System.debug('controller Id: ' + this.thisOpportunity);
		
		
		String secretText = 'asdasxiwei';
		if (this.thisOpportunity.Website_order_Id__c == null){
			this.thisOpportunity.Website_order_Id__c = '';
		}
		
		Datetime cDT = Date.today();
		
	    String formattedDate = cDT.format('yyyyMMdd');
	    
		String inputStr = secretText+this.thisOpportunity.Website_order_Id__c+formattedDate;
		
		System.debug('md5 String: '+inputStr);
		String algorithmName = 'MD5';
      	Blob mac = Crypto.generateDigest(algorithmName, Blob.valueOf(inputStr));
    	String macUrl = EncodingUtil.urlEncode(EncodingUtil.ConvertToHex(mac), 'UTF-8');
	
		return macUrl;
		
	}

    /**
    * Test Class for getMD5();
    * 
    * Tests the getting of the MD5 Hash.
    */  
    static testMethod void getMD5Test(){
/*
        // Insert Contact to generate the MD5 Hash against
        Opportunity opportunity = new Opportunity(
            FirstName='Francis',
            Lastname='Pindar',
            Website_order_Id__c='56');
        insert Opportunity;

        
        ApexPages.StandardController stc = new ApexPages.StandardController(Opportunity);
        websitePermissions websiteOrder = new WebsiteOrder(stc);
				        
        // Generate MD5 HASH and compare against returned value:
        String algorithmName = 'MD5';
		String secretText = 'asdasxiwei';
		String inputStr = secretText+opportunity.WebId__c+Date.today('YYYYMMDD');
      	Blob mac = Crypto.generateDigest(algorithmName, Blob.valueOf(inputStr));
    	String macUrl = EncodingUtil.urlEncode(EncodingUtil.ConvertToHex(mac), 'UTF-8');
        
        System.debug('MacURL: '+macURL);
        System.debug('MD5: '+WebsitePermissions.getMD5());
        System.assertEquals(macUrl, WebsitePermissions.getMD5());        
*/
    }
}