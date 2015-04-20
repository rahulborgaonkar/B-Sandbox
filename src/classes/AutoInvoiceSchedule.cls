/*

VS : This is the entry point for Auto Invoicing.
     The schedule will only execute if the Custom Setting AutoInvoiceSettings.Enable_Auto_Invoicing__c is enabled
     When the schedule executes first time the FF company is set to British Safety Council for the schedule executing user
     calls the batch : AutoInvoiceBatch

*/

global class AutoInvoiceSchedule implements Schedulable{
    
    public String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    string companyName;
        
    public AutoInvoiceSchedule(){
        /*if (!test.isRunningTest())
            companyName = AutoSwitchFFCompany.switchFFCompany(userinfo.getUserId(), 'FF Complywise Ltd');
        else 
            companyName = 'British Safety Council';*/
        
        //if (test.isRunningTest())
            companyName = c2g.CODACurrentCompanyDisplayController.getCompanyName().companyName;
            system.debug(companyName);
            
    }
    
    global void execute(SchedulableContext sc){
        system.debug(companyName);
        if (AutoInvoiceSettings.autoInvoicingEnabled){
            AutoInvoiceBatch aib = new autoInvoiceBatch(null, companyName);
            if (!test.isRunningTest())
                database.executeBatch(aib);
        } else {
            list<string> info = new list<string>();
            info.add(AutoInvoiceSettings.emailNotificationTo);
            AutoInvoiceHelper.sendMail('Auto Invoice Disabled', ' Auto Invoicing Disabled, Please enable from Auto Invoice Custom Setting ', info);
        }
        
    }
     
}