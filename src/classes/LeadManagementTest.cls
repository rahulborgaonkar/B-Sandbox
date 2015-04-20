@IsTest(SeeAllData = true)
public class LeadManagementTest {

    public static testmethod void LeadOwnerAssignmentTest(){
        
        list<lead> leads = new list<lead>();
        
        for(integer i = 0; i< 200; i++){
           
            integer employees = 1888;
            
            if (i > 100)
                employees = 5000;
           
            lead l = new lead(
            	Company = 'Test Company ' + string.valueOf(i),
                firstName = 'FirstName ' + string.valueOf(i),
                lastName = 'LastName ' + string.valueOf(i),
                phone = '0777777777' + string.valueOf(i),
                Principle_Address_ZIP_Postal_Code__c = 'OX1 1XO',
                Principle_Address_Country__c = i > 190 ? 'India' : 'United Kingdom',
                NumberOfEmployees = employees             
            );
            leads.add(l);    
        }
        
        insert leads;
    }
    
}