global with sharing class InvoiceHelper {

	public static Map<String,Id> dim1CodeCache = new Map<String, Id>();
	public static Map<Id, Id> usrDim1Cache = new Map<Id, Id>();
	
    /*
     * GET DIMENSION 1 CODE
     *
     * Gets the dimension code from the user record (if filled out) and returns
     * the Dimension Code 1 record ID.
     * Method caches results to MAPs (above)
     */
    public static Id getDimension1CodeFromOwner(Id ownerId){

		Id firstdim = '006c0000002gUR4';
		Id seconddim = '006c0000002gUR4';
		
		System.debug(usrDim1Cache);
		usrDim1Cache.put(firstdim,seconddim);

    	Id dim1CodeId = null;

    	if (ownerId != null){
	    	if(usrDim1Cache.containsKey(ownerId)){
	    		dim1CodeId = usrDim1Cache.get(ownerId);
	    	}else{
	    		try{
		    		User usr = [SELECT Dimension_1__c FROM User WHERE Id = :ownerId][0];
	    			
	    			if (usr.Dimension_1__c != null && usr.Dimension_1__c != ''){
		    			if (dim1CodeCache.containsKey(usr.Dimension_1__c)){
		    				dim1CodeId = dim1CodeCache.get(usr.Dimension_1__c);
		    			}else{	    				
				    		c2g__codaDimension1__c dim1 = [SELECT Id FROM c2g__codaDimension1__c WHERE c2g__ReportingCode__c = :usr.Dimension_1__c][0];
				    		dim1CodeCache.put(usr.Dimension_1__c,dim1.Id);
				    		dim1CodeId = dim1.Id;
		    			}
		    			usrDim1Cache.put(ownerId,dim1CodeId);
	    			}
	    		}catch(Exception e){
	    			// ERROR: Either Opp Owner Dimension 1 code is missing or can't find a dimension code match.
	    		}
	    	}
			if (dim1CodeId == null){
				// ERROR: Unable to find correct dimension 1 code
			}else{
				usrDim1Cache.put(ownerId,dim1CodeId);
			}
    	}else{
			// ERROR: No OwnerId specified when getting dimension code 1
    	}
    	return dim1CodeId;
    }

    @IsTest
    private static void testGetDimensionCodeFromOwner(){
    	
		c2g__codaDimension1__c dim1 = new c2g__codaDimension1__c (
			Name = 'Test Reporting Code',
			c2g__ReportingCode__c = 'repCode'
		);
		insert dim1;
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0];

		User usr = new User (
			alias = 'stUser2', 
			email='testuser9284@newdomain.com',
			emailencodingkey='UTF-8',
			firstname='USER',
			lastname='TEST',
			languagelocalekey='en_US',
			localesidkey='en_US', 
			profileid = p.Id,
			timezonesidkey='America/Los_Angeles',
			username='testuser9284@newdomain.com',
			Dimension_1__c = 'repCode'
		);    	
    	insert usr;
    	
		User usrNoDim = new User (
			alias = 'stUser2', 
			email='testuser9285@newdomain.com',
			emailencodingkey='UTF-8',
			firstname='USER',
			lastname='TEST',
			languagelocalekey='en_US',
			localesidkey='en_US', 
			profileid = p.Id,
			timezonesidkey='America/Los_Angeles',
			username='testuser9285@newdomain.com'
		);    	
    	insert usrNoDim;
    	    	
    	
    	Test.startTest();
    	
    	// Positive test. Get DIM code from user with existing DIM code
    	System.assertEquals(getDimension1CodeFromOwner(usr.Id),dim1.Id);
    	
    	// Negative test. Get DIM code from user that doesn't have DIM code
    	System.assertEquals(getDimension1CodeFromOwner(usrNoDim.Id),null);
    	
    	Test.stopTest();
    }
    
}