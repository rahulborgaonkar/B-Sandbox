@isTest(SeeAllData=True)
public class AutoInvoiceTests {
    

    
    private static string RandomString{
        get{
            return string.valueof(math.random()).substring(1,11);
        }
    }
    
    static testMethod void autoSwithCompanyTest(){
        
        test.startTest();
        
        AutoSwitchFFCompany.switchFFCompany(userinfo.getUserId(), 'FF Complywise Ltd');
        
        test.stopTest();
    }
    
    static testMethod void autoSwithCompanyTest1(){
        
        test.startTest();
        
        AutoSwitchFFCompany.switchFFCompany(userinfo.getUserId(), 'FF British Safety Council');
        
        test.stopTest();
    }
    
    
    static testMethod void autoInvoiceScheduleTest(){
        
        test.startTest();
        
        AutoInvoiceSettings__c aiSetting = [Select id From AutoInvoiceSettings__c][0];
        aiSetting.Enable_Auto_Invoicing__c = false;
        update aiSetting;
        
        AutoInvoiceSchedule sch = new AutoInvoiceSchedule();
        system.schedule('Test Invoice Schedule', sch.CRON_EXP , sch);
        
        test.stopTest();
    }
    
    static testMethod void autoInvoiceScheduleTest1(){
        
        test.startTest();
        
        AutoInvoiceSettings__c aiSetting = [Select id From AutoInvoiceSettings__c][0];
        aiSetting.Enable_Auto_Invoicing__c = true;
        update aiSetting;
        
        AutoInvoiceSchedule sch = new AutoInvoiceSchedule();
        system.schedule('Test Invoice Schedule', sch.CRON_EXP , sch);
        
        test.stopTest();
    }
}