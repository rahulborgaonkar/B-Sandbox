public with sharing class WebsitePermissions {

	public String strToEncode {get; set;}	
    private final Contact thisContact;
	
    /**
    * CONSTRUCTOR
    */
    public WebsitePermissions(ApexPages.StandardController stdController) {
        this.thisContact = (Contact)stdController.getRecord();
        getMD5();
    }

    /**
    * GETTERS
    */
    
    /*
     * ARE FIELDS FILLED OUT
     *
     * Checks to make sure that the fields in Salesforce required for the website permissions
     * are filled out correctly.
     */
    public String getAreFieldsFilledOut(){
    	
    	String error = '';

		Contact contact = [SELECT
								FirstName,
								LastName,
								WebId__c,
								Account.Principle_Address_Building__c,
								Account.Principle_Address_Street__c,
								Account.Principle_Address_Area__c,
								Account.Principle_Address_City__c,
								Account.Principle_Address_ZIP_Postal_Code__c,
								Account.Principle_Address_Country__c
							FROM
								Contact
							WHERE
								Id = :thisContact.Id
							LIMIT 1][0];
							
		if (contact.WebId__c == null || contact.WebId__c.length() == 0){
			
	    	if (contact.FirstName == null || contact.FirstName.length() == 0){
	    		error+= 'The contact\'s firstname is missing. <br />';
	    	}
	
	    	if (contact.Lastname == null || contact.Lastname.length() == 0){
	    		error+= 'The contact\'s lastname is missing. <br />';
	    	}
	
			String streetAddress = '';
			if (contact.Account.Principle_Address_Building__c != null){
				streetAddress = contact.Account.Principle_Address_Building__c + ', ';
			}
			
			if (contact.Account.Principle_Address_Street__c != null && contact.Account.Principle_Address_Street__c.length() > 0){
				streetAddress += contact.Account.Principle_Address_Street__c.replaceAll('\n',', ');
			}
			if (contact.Account.Principle_Address_Area__c != null && contact.Account.Principle_Address_Area__c.length() > 0){
				streetAddress += ', '+contact.Account.Principle_Address_Area__c;
			}
	    	
	    	if (streetAddress.length() == 0){
	    		error+= 'The contact\'s account doesn\'t have a principle address. <br />';
	    	}
	    	
	    	if (contact.Account.Principle_Address_City__c == null || contact.Account.Principle_Address_City__c == ''){
	    		error+= 'The contact\'s account doesn\'t have a principle address city. <br />';
	    	}
	    	
	    	if ((contact.Account.Principle_Address_ZIP_Postal_Code__c == null || contact.Account.Principle_Address_ZIP_Postal_Code__c == '') && 
	    		(
	    			/*contact.Account.Principle_Address_Country__c == 'Afghanistan' ||
	    			contact.Account.Principle_Address_Country__c == 'Åland Islands' ||
	    			contact.Account.Principle_Address_Country__c == 'Albania' ||
	    			contact.Account.Principle_Address_Country__c == 'Algeria' ||
	    			contact.Account.Principle_Address_Country__c == 'American Samoa' ||
	    			contact.Account.Principle_Address_Country__c == 'Andorra' ||
	    			contact.Account.Principle_Address_Country__c == 'Anguilla' ||
	    			contact.Account.Principle_Address_Country__c == 'Argentina' ||
	    			contact.Account.Principle_Address_Country__c == 'Armenia' ||
	    			contact.Account.Principle_Address_Country__c == 'Australia' ||
	    			contact.Account.Principle_Address_Country__c == 'Austria' ||
	    			contact.Account.Principle_Address_Country__c == 'Azerbaijan' ||
	    			contact.Account.Principle_Address_Country__c == 'Bahrain' ||
	    			contact.Account.Principle_Address_Country__c == 'Bangladesh' ||
	    			contact.Account.Principle_Address_Country__c == 'Barbados' ||
	    			contact.Account.Principle_Address_Country__c == 'Belarus' ||
	    			contact.Account.Principle_Address_Country__c == 'Belgium' ||
	    			contact.Account.Principle_Address_Country__c == 'Bermuda' ||
	    			contact.Account.Principle_Address_Country__c == 'Bhutan' ||
	    			contact.Account.Principle_Address_Country__c == 'Bosnia and Herzegovina' ||
	    			contact.Account.Principle_Address_Country__c == 'Brazil' ||
	    			contact.Account.Principle_Address_Country__c == 'British Indian Ocean Territory' ||
	    			contact.Account.Principle_Address_Country__c == 'Bulgaria' ||
	    			contact.Account.Principle_Address_Country__c == 'Cambodia' ||
	    			contact.Account.Principle_Address_Country__c == 'Canada' ||
	    			contact.Account.Principle_Address_Country__c == 'Cape Verde' ||
	    			contact.Account.Principle_Address_Country__c == 'Cayman Islands' ||
	    			contact.Account.Principle_Address_Country__c == 'Chad' ||
	    			contact.Account.Principle_Address_Country__c == 'Chile' ||
	    			contact.Account.Principle_Address_Country__c == 'China' ||
	    			contact.Account.Principle_Address_Country__c == 'Christmas Island' ||
	    			contact.Account.Principle_Address_Country__c == 'Colombia' ||
	    			contact.Account.Principle_Address_Country__c == 'Costa Rica' ||
	    			contact.Account.Principle_Address_Country__c == 'Croatia' ||
	    			contact.Account.Principle_Address_Country__c == 'Cuba' ||
	    			contact.Account.Principle_Address_Country__c == 'Cyprus' ||
	    			contact.Account.Principle_Address_Country__c == 'Czech Republic' ||
	    			contact.Account.Principle_Address_Country__c == 'Denmark' ||
	    			contact.Account.Principle_Address_Country__c == 'Dominican Republic' ||
	    			contact.Account.Principle_Address_Country__c == 'Ecuador' ||
	    			contact.Account.Principle_Address_Country__c == 'El Salvador' ||
	    			contact.Account.Principle_Address_Country__c == 'Egypt' ||
	    			contact.Account.Principle_Address_Country__c == 'Estonia' ||
	    			contact.Account.Principle_Address_Country__c == 'Ethiopia' ||
	    			contact.Account.Principle_Address_Country__c == 'Falkland Islands (Malvinas)' ||
	    			contact.Account.Principle_Address_Country__c == 'Faroe Islands' ||
	    			contact.Account.Principle_Address_Country__c == 'Finland' ||
	    			contact.Account.Principle_Address_Country__c == 'France' ||
	    			contact.Account.Principle_Address_Country__c == 'French Guiana' ||
	    			contact.Account.Principle_Address_Country__c == 'French Polynesia' ||
	    			contact.Account.Principle_Address_Country__c == 'Gabon' ||
	    			contact.Account.Principle_Address_Country__c == 'Georgia' ||
	    			contact.Account.Principle_Address_Country__c == 'Germany' ||
	    			contact.Account.Principle_Address_Country__c == 'Gibraltar' ||
	    			contact.Account.Principle_Address_Country__c == 'Greece' ||
	    			contact.Account.Principle_Address_Country__c == 'Greenland' ||
	    			contact.Account.Principle_Address_Country__c == 'Guadeloupe' ||
	    			contact.Account.Principle_Address_Country__c == 'Guam' ||
	    			contact.Account.Principle_Address_Country__c == 'Guatemala' ||
	    			contact.Account.Principle_Address_Country__c == 'Guernsey' ||
	    			contact.Account.Principle_Address_Country__c == 'Guinea-Bissau' ||
	    			contact.Account.Principle_Address_Country__c == 'Haiti' ||
	    			contact.Account.Principle_Address_Country__c == 'Heard Island and McDonald Islands' ||
	    			contact.Account.Principle_Address_Country__c == 'Honduras' ||
	    			contact.Account.Principle_Address_Country__c == 'Hungary' ||
	    			contact.Account.Principle_Address_Country__c == 'Iceland' ||
	    			contact.Account.Principle_Address_Country__c == 'India' ||
	    			contact.Account.Principle_Address_Country__c == 'Indonesia' ||
	    			contact.Account.Principle_Address_Country__c == 'Iran, Islamic Republic of' ||
	    			contact.Account.Principle_Address_Country__c == 'Iraq' ||
	    			contact.Account.Principle_Address_Country__c == 'Isle of Man' ||
	    			contact.Account.Principle_Address_Country__c == 'Israel' ||
	    			contact.Account.Principle_Address_Country__c == 'Italy' ||
	    			contact.Account.Principle_Address_Country__c == 'Jamaica' ||
	    			contact.Account.Principle_Address_Country__c == 'Japan' ||
	    			contact.Account.Principle_Address_Country__c == 'Jersey' ||
	    			contact.Account.Principle_Address_Country__c == 'Jordan' ||
	    			contact.Account.Principle_Address_Country__c == 'Kazakhstan' ||
	    			contact.Account.Principle_Address_Country__c == 'Kyrgyzstan' ||
	    			contact.Account.Principle_Address_Country__c == 'Latvia' ||
	    			contact.Account.Principle_Address_Country__c == 'Lebanon' ||
	    			contact.Account.Principle_Address_Country__c == 'Lesotho' ||
	    			contact.Account.Principle_Address_Country__c == 'Liberia' ||
	    			contact.Account.Principle_Address_Country__c == 'Libyan Arab Jamahiriya' ||
	    			contact.Account.Principle_Address_Country__c == 'Liechtenstein' ||
	    			contact.Account.Principle_Address_Country__c == 'Lithuania' ||
	    			contact.Account.Principle_Address_Country__c == 'Luxembourg' ||
	    			contact.Account.Principle_Address_Country__c == 'Macedonia, the former Yugoslav Republic of' ||
	    			contact.Account.Principle_Address_Country__c == 'Madagascar' ||
	    			contact.Account.Principle_Address_Country__c == 'Malawi' ||
	    			contact.Account.Principle_Address_Country__c == 'Maldives' ||
	    			contact.Account.Principle_Address_Country__c == 'Malaysia' ||
	    			contact.Account.Principle_Address_Country__c == 'Malta' ||
	    			contact.Account.Principle_Address_Country__c == 'Marshall Islands' ||
	    			contact.Account.Principle_Address_Country__c == 'Martinique' ||
	    			contact.Account.Principle_Address_Country__c == 'Mayotte' ||
	    			contact.Account.Principle_Address_Country__c == 'Micronesia, Federated States of' ||
	    			contact.Account.Principle_Address_Country__c == 'Mexico' ||
	    			contact.Account.Principle_Address_Country__c == 'Moldova, Republic of' ||
	    			contact.Account.Principle_Address_Country__c == 'Monaco' ||
	    			contact.Account.Principle_Address_Country__c == 'Mongolia' ||
	    			contact.Account.Principle_Address_Country__c == 'Montenegro' ||
	    			contact.Account.Principle_Address_Country__c == 'Morocco' ||
	    			contact.Account.Principle_Address_Country__c == 'Mozambique' ||
	    			contact.Account.Principle_Address_Country__c == 'Myanmar' ||
	    			contact.Account.Principle_Address_Country__c == 'Namibia' ||
	    			contact.Account.Principle_Address_Country__c == 'Nepal' ||
	    			contact.Account.Principle_Address_Country__c == 'Netherlands' ||
	    			contact.Account.Principle_Address_Country__c == 'New Caledonia' ||
	    			contact.Account.Principle_Address_Country__c == 'New Zealand' ||
	    			contact.Account.Principle_Address_Country__c == 'Nicaragua' ||
	    			contact.Account.Principle_Address_Country__c == 'Niger' ||
	    			contact.Account.Principle_Address_Country__c == 'Norfolk Island' ||
	    			contact.Account.Principle_Address_Country__c == 'Northern Mariana Islands' ||
	    			contact.Account.Principle_Address_Country__c == 'Norway' ||
	    			contact.Account.Principle_Address_Country__c == 'Oman' ||
	    			contact.Account.Principle_Address_Country__c == 'Pakistan' ||
	    			contact.Account.Principle_Address_Country__c == 'Palau' ||
	    			contact.Account.Principle_Address_Country__c == 'Panama' ||
	    			contact.Account.Principle_Address_Country__c == 'Papua New Guinea' ||
	    			contact.Account.Principle_Address_Country__c == 'Paraguay' ||
	    			contact.Account.Principle_Address_Country__c == 'Peru' ||
	    			contact.Account.Principle_Address_Country__c == 'Philippines' ||
	    			contact.Account.Principle_Address_Country__c == 'Pitcairn' ||
	    			contact.Account.Principle_Address_Country__c == 'Poland' ||
	    			contact.Account.Principle_Address_Country__c == 'Portugal' ||
	    			contact.Account.Principle_Address_Country__c == 'Puerto Rico' ||
	    			contact.Account.Principle_Address_Country__c == 'Réunion' ||
	    			contact.Account.Principle_Address_Country__c == 'Romania' ||
	    			contact.Account.Principle_Address_Country__c == 'Russian Federation' ||
	    			contact.Account.Principle_Address_Country__c == 'Saint Barthélemy' ||
	    			contact.Account.Principle_Address_Country__c == 'Saint Helena, Ascension and Tristan da Cunha' ||
	    			contact.Account.Principle_Address_Country__c == 'Saint Martin' ||
	    			contact.Account.Principle_Address_Country__c == 'Saint Pierre and Miquelon' ||
	    			contact.Account.Principle_Address_Country__c == 'Saint Vincent and the Grenadines' ||
	    			contact.Account.Principle_Address_Country__c == 'San Marino' ||
	    			contact.Account.Principle_Address_Country__c == 'Saudi Arabia' ||
	    			contact.Account.Principle_Address_Country__c == 'Senegal' ||
	    			contact.Account.Principle_Address_Country__c == 'Serbia' ||
	    			contact.Account.Principle_Address_Country__c == 'Singapore' ||
	    			contact.Account.Principle_Address_Country__c == 'Slovenia' ||
	    			contact.Account.Principle_Address_Country__c == 'South Africa' ||
	    			contact.Account.Principle_Address_Country__c == 'South Georgia and the South Sandwich Islands' ||
	    			contact.Account.Principle_Address_Country__c == 'Spain' ||
	    			contact.Account.Principle_Address_Country__c == 'Sri Lanka' ||
	    			contact.Account.Principle_Address_Country__c == 'Sudan' ||
	    			contact.Account.Principle_Address_Country__c == 'Swaziland' ||
	    			contact.Account.Principle_Address_Country__c == 'Sweden' ||
	    			contact.Account.Principle_Address_Country__c == 'Switzerland' ||
	    			contact.Account.Principle_Address_Country__c == 'Taiwan, Province of China' ||
	    			contact.Account.Principle_Address_Country__c == 'Tajikistan' ||
	    			contact.Account.Principle_Address_Country__c == 'Thailand' ||
	    			contact.Account.Principle_Address_Country__c == 'Trinidad and Tobago' ||
	    			contact.Account.Principle_Address_Country__c == 'Tunisia' ||
	    			contact.Account.Principle_Address_Country__c == 'Turkmenistan' ||
	    			contact.Account.Principle_Address_Country__c == 'Turks and Caicos Islands' ||
	    			contact.Account.Principle_Address_Country__c == 'Ukraine' || */
	    			contact.Account.Principle_Address_Country__c == 'United Kingdom'
	    			/* contact.Account.Principle_Address_Country__c == 'United States' ||
	    			contact.Account.Principle_Address_Country__c == 'Uruguay' ||
	    			contact.Account.Principle_Address_Country__c == 'Virgin Islands, U.S.' ||
	    			contact.Account.Principle_Address_Country__c == 'Uzbekistan' ||
	    			contact.Account.Principle_Address_Country__c == 'Holy See (Vatican City State)' ||
	    			contact.Account.Principle_Address_Country__c == 'Venezuela, Bolivarian Republic of' ||
	    			contact.Account.Principle_Address_Country__c == 'Vietnam' ||
	    			contact.Account.Principle_Address_Country__c == 'Wallis and Futuna' ||
	    			contact.Account.Principle_Address_Country__c == 'Zambia'*/
	    		)){
	    		error+= 'The contact\'s account is in a country that has a post/zip code and doesn\'t have a principle address postal code. <br />';
	    	}
	    	
	    	if (contact.Account.Principle_Address_Country__c == null || contact.Account.Principle_Address_Country__c == ''){
	    		error+= 'The contact\'s account doesn\'t have a principle address country. <br />';
	    	}
		}
    	
    	return error;
    }
    
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
    	// The production org ID will never change so this is hardcoded.
    	if (orgId == '00D20000000MXUnEAO'){
    		// Is Production
    		hostname = 'https://www.britsafe.org';
    	}else{
    		// Is a sandbox (anything else)
    		hostname = 'https://testbsc01.britsafe.org';
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
		System.debug('controller Id: ' + this.thisContact);
		
		
		String secretText = 'asdasxiwei';
		if (this.thisContact.WebId__c == null){
			this.thisContact.WebId__c = '';
		}
		if (this.thisContact.email == null){
			this.thisContact.email = '';
		}
		
		//String inputStr = EncodingUtil.urlEncode(secretText+this.thisContact.email+this.thisContact.WebId__c+this.thisContact.Id, 'UTF-8');
		String inputStr = secretText+this.thisContact.email+this.thisContact.WebId__c+this.thisContact.Id;
		this.strToEncode = inputStr;
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

        // Insert Contact to generate the MD5 Hash against
        Contact contact = new Contact(
            FirstName='Francis',
            Lastname='Pindar',
            Email='francis+bscfftest@netstronghold.com',
            webId__c='56');
        insert Contact;

        
        ApexPages.StandardController stc = new ApexPages.StandardController(contact);
        websitePermissions websitePermissions = new WebsitePermissions(stc);
				        
        // Generate MD5 HASH and compare against returned value:
        String algorithmName = 'MD5';
		String secretText = 'asdasxiwei';
		String inputStr = secretText+contact.email+contact.WebId__c+contact.Id;
      	Blob mac = Crypto.generateDigest(algorithmName, Blob.valueOf(inputStr));
    	String macUrl = EncodingUtil.urlEncode(EncodingUtil.ConvertToHex(mac), 'UTF-8');
        
        System.debug('MacURL: '+macURL);
        System.debug('MD5: '+WebsitePermissions.getMD5());
        System.assertEquals(macUrl, WebsitePermissions.getMD5());        

    }
    
    static testMethod void getAreFieldsFilledOutTest(){
    	
        Account acc = new Account();        
        acc.Name = 'The Company Inc Plc 3668923';
        acc.CurrencyIsoCode = 'GBP';
        acc.Active__c = True;
        acc.Principle_Address_Street__c = 'Street';
        acc.Principle_Address_City__c = 'London';
        acc.Principle_Address_Country__c = 'United Kingdom';
        acc.Principle_Address_ZIP_Postal_Code__c = 'SW20 999';
        acc.BillingPostalCode = 'SW20 999';
        insert acc;

        Contact contact = new Contact(
        	AccountId=acc.id,
            FirstName='Francis',
            Lastname='Pindar',
            Email='francis+bscfftest@netstronghold.com');
        insert Contact;
    	
        ApexPages.StandardController stc = new ApexPages.StandardController(contact);
        websitePermissions websitePermissions = new WebsitePermissions(stc);

        System.assertEquals('', WebsitePermissions.getAreFieldsFilledOut());        

    }
}