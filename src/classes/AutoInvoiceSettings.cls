public class AutoInvoiceSettings {
   
    static AutoInvoiceSettings__c settings;
    
    private static void initiateSettings(){
        if ( settings == null )
            settings = AutoInvoiceSettings__c.getOrgDefaults();    
    }
    
    public static Integer autoInvoiceDelay { get{ initiateSettings(); return (Integer)settings.Auto_Invoice_Delay__c; } }
    
    public static boolean autoPostCreditNotes { get{ initiateSettings(); return settings.AutoPost_CreditNotes__c; } }
    
    public static boolean autoPostInvoices { get{ initiateSettings(); return settings.AutoPost_Invoices__c; } }
    
    public static boolean autoInvoicingEnabled { get{ initiateSettings(); return settings.Enable_Auto_Invoicing__c; } }
    
    public static boolean evaluateDeliveryWorkflow { get{ initiateSettings(); return settings.Evaluate_Delivery_Workflow__c; } } 
    
    public static string emailNotificationTo { get{ initiateSettings(); return settings.Email_Notification_To__c; } }
    
    public static datetime cwLastExecution { get{ initiateSettings(); return (datetime)settings.Complywise_Last_Execution__c; } }
    
}