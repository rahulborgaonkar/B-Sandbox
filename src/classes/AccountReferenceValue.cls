public class AccountReferenceValue{
    
    public Id accId {get; set;}
    
    public string accReference{
        get{
            list<Account> acc = [select Account_Reference__c from account where id  = :accId limit 1];
            
            if (acc.size() == 1 && acc[0].Account_Reference__c != null)
                return 'Account Reference: ' + acc[0].Account_Reference__c;
            else
            	return '';
        }
    }
}