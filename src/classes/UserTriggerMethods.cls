public with sharing class UserTriggerMethods {
	
	/*
	 * VALIDATE DIMENSION 1 CODE
	 *
	 * Validates the DIM1 code on the users record is valid.
	 */
	public static Boolean validateDim1Code(List<User> users){
		
		Map<String, Id> dimCodes = new Map<String, Id>();
		for (c2g__codaDimension1__c dim : [SELECT Id,
												c2g__ReportingCode__c
											FROM
												c2g__codaDimension1__c]){
			dimCodes.put(dim.c2g__ReportingCode__c, dim.Id);
		}
		// Loop over users and check to see the entered DIM1 Code is correct
		for (User usr : users){
			if (usr.Dimension_1__c != '' && usr.Dimension_1__c != null){
				if (!dimCodes.containsKey(usr.Dimension_1__c)){
					usr.addError('Dimension Code 1 on the user is invalid');
				}
			}
		}
		return True;
	}
	
	
    @IsTest
    private static void testValidateDim1Code(){
		
		c2g__codaDimension1__c dim1 = new c2g__codaDimension1__c (
			Name = 'Test Reporting Code',
			c2g__ReportingCode__c = 'repCode'
		);
		insert dim1;
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0];
		
		User userDimNotExist = new User(
			alias = 'stUser', 
			email='testuser9283@newdomain.com',
			emailencodingkey='UTF-8',
			firstname='USER',
			lastname='TEST',
			languagelocalekey='en_US',
			localesidkey='en_US', 
			profileid = p.Id,
			timezonesidkey='America/Los_Angeles',
			username='testuser9283@newdomain.com',
			Dimension_1__c = 'doesNotExist'
		);

		User userDimExists = new User (
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
		
		Test.startTest();
		
		// NEGATIVE TEST: add user with wrong DIM1 code
		try {
			insert userDimNotExist;
			System.assertEquals(true,false);
		}catch(Exception e){
			System.assertEquals(true,true);
		}
		
		// POSITIVE TEST: add user with the correct DIM1 code
		try {
			insert userDimExists;
			System.assertEquals(true,true);
		}catch(Exception e){
			System.assertEquals(true,false);
		}
		Test.stopTest();
	}
}