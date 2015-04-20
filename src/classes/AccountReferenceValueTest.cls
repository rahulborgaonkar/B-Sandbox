@isTest
public class AccountReferenceValueTest{
    
    static testMethod void test(){
        
        account a = new Account(
            name = 'AccountReferenceValueTest'); 
        insert a;
        
        AccountReferenceValue arv = new AccountReferenceValue();
        system.assertEquals(arv.accReference, '', 'Reference Not Found' );
        arv.accId = a.id;
        system.assert( arv.accReference.startsWith('Account Reference'), 'Found Reference ' + arv.accReference );
    }

}