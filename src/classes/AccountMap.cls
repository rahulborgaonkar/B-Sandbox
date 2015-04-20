public with sharing class AccountMap {

    private limitWrapper[] thousandBlocks = new limitWrapper[]{};
    
    private final integer listLimit;
    
    public AccountMap()
    {
        listLimit = 999;
    }
    
    public limitWrapper[] getAccountBlocks()
    {
        thousandBlocks = new limitWrapper[]{};
        
        integer counter = 0;
        integer loopCount = 0;
        Account[] tmpAccount = new Account[]{};
        
        String MembershipQuery = 'SELECT Id, Name, Longitude__c, Latitude__c, Last_Opportunity_Close_Date__c FROM Account WHERE latitude__c != null AND Last_Opportunity_Close_Date__c != NULL AND Last_Opportunity_Close_Date__c > 2007-01-01 AND Member__c = True';
        String accountQuery = 'SELECT Id, Name, Longitude__c, Latitude__c, Last_Opportunity_Close_Date__c FROM Account WHERE latitude__c != null AND Last_Opportunity_Close_Date__c != NULL AND Last_Opportunity_Close_Date__c > 2007-01-01';
        for(Account a:[SELECT Id, Name, Longitude__c, Latitude__c, Last_Opportunity_Close_Date__c FROM Account WHERE latitude__c != null AND Last_Opportunity_Close_Date__c != NULL AND Last_Opportunity_Close_Date__c > 2007-01-01 AND Member__c = True ORDER BY Last_Opportunity_Close_Date__c DESC NULLS LAST])
        {
            if(counter < listLimit)
            {
                tmpAccount.add(a);
                counter++;
            }
            else
            {
                loopCount++;
                thousandBlocks.add(new limitWrapper(tmpAccount,loopCount));
                tmpAccount = new Account[]{};
                tmpAccount.add(a);
                counter = 0;
            }            
        }
        
        if(thousandBlocks.size() == 0)
        {
            loopCount++;
            thousandBlocks.add(new limitWrapper(tmpAccount,loopCount));
        }
        
        return thousandBlocks;
    }
    
    public class limitWrapper
    {
        public Account[] accounts {get;set;}
        public integer blockNumber {get;set;}
        public limitWrapper(Account[] accs, integer i)
        {
            accounts = accs;
            blockNumber = i;
        }
        
    }
    
    /**
    * GETTERS
    */
    /*
	public static List<Account> getAccounts(){
		List<Account> accountList = new list<Account>([SELECT Id, Name, Longitude__c, Latitude__c, Last_Opportunity_Close_Date__c FROM Account WHERE latitude__c != null AND LastActivityDate != NULL ORDER BY Last_Opportunity_Close_Date__c DESC NULLS LAST LIMIT 10000]); 
		
		return accountList;
	}
	*/
}