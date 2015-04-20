public class Utilities{
    
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName){
        
        String selects = '';
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' ';
        
    }
    
    public static string getSOQLQuery(String objectName, list<string> relatedFields, list<string> subQueries){
        
        String selects = '';
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe();
                if (fd.isAccessible())
                	selectFields.add(ft.getDescribe().getName());
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            
            for (string query : subQueries){
                selects += '(' + query + '),';
            }
            
            for (string field : relatedFields){
                selects +=  field + ',';
            }
            
            if (selects.endsWith(',')){
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
        }
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' ';
        
    }
    
    
    
    /*
* Creates a new task
* Pass the first parameter as true if the task needs to be marked recurring.
*/
    public static task createTask(boolean isRecurring, date activityDate, id whatId, string subject, string description, string ownerId){
        task tasks = new task();
        tasks.WhatId = whatId;
        if (isRecurring == false){
            tasks.ActivityDate = activityDate;
        }
        tasks.Type = 'Other';
        tasks.Subject = subject;
        tasks.Description = description;
        tasks.OwnerId = ownerId;
        if (isRecurring){
            tasks.IsRecurrence = true;
            tasks.RecurrenceStartDateOnly = date.today();
            tasks.RecurrenceEndDateOnly = date.today().addMonths(1);
            tasks.RecurrenceType = 'RecursEveryWeekday';
            tasks.IsReminderSet = true;
            tasks.ReminderDateTime = system.today();
            tasks.RecurrenceDayOfWeekMask = 62;
        }
        return tasks;
    } 
    
    
    public static void SendEmail(string customEmailTemplate, list<string> toEmail, map<string,string> keyValue) {
        system.debug('toemail' +toemail);
        list<string> data = getCustomTemplate(customEmailTemplate, keyValue);
        system.debug('data: ' + data);
        string subject = data[0];
        string body = data[1];
        
        string[] toAddress = new string[toEmail.size()];
        integer i = 0;
        for (string email : toEmail){
            toAddress[i] = email;
            i++;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(data[2]);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setToAddresses(toAddress);
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            return;
        } catch (EmailException e) {
            throw new UtilException('Utilities.SendEmail error. ' + e.getMessage());
        }
    }
    
    public static void SendEmail(string body, string subject, list<string> toEmail) {
        
        string[] toAddress = new string[toEmail.size()];
        integer i = 0;
        for (string email : toEmail){
            toAddress[i] = email;
            i++;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setToAddresses(toAddress);
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            return;
        } catch (EmailException e) {
            throw new UtilException('sendTemplatedEmail error. ' + e.getMessage());
        }
        
    }
    
    
    public class UtilException extends Exception{}
    
    //  -------------------------------------------------------------------------
    //  HELPER method: sendTemplatedEmail
    //  -------------------------------------------------------------------------
    public static void sendTemplatedEmail(String[] toRecipients, String templateApiName,  Id whatId, Id targetObjId  ) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        Id templateId;  
        try {
            templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
        } catch (Exception e) {
            throw new UtilException ('Unable to locate EmailTemplate using name: ' + templateApiName + 
                                     ' refer to Setup | Communications Templates ' + templateApiName);
        }
        
        email.setToAddresses(toRecipients);
        email.setTargetObjectId(targetObjId);
        email.setWhatId(whatId);
        email.setTemplateId(templateId);
        email.setSaveAsActivity(false); 

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            return;
        } catch (EmailException e) {
            throw new UtilException('[U-02] sendTemplatedEmail error. ' + e.getMessage());
        }
    }  
    
    
    public static list<string> getCustomTemplate(string customEmailTemplate, map<string,string> keyValue){
        list<Custom_Email_Template__c> customEmail = [select Name,EmailBody__c, EmailFrom__c, EmailSubject__c, EmailToTest__c  from Custom_Email_Template__c where name = :customEmailTemplate];
        list<string> returnValue = new list<string>();
        
        if (customEmail.size() == 1){
            
            string body = customEmail[0].EmailBody__c;    
            string subject = customEmail[0].EmailSubject__c;
            
            system.debug('customEmailTemplate '+ customEmailTemplate);
            system.debug('keyValue '+ keyValue);
            
            for (string key : keyValue.keyset()){
                if (keyvalue != null){
                    body = body.replace(key, keyvalue.get(key) == null ? '' : keyvalue.get(key));
                    subject = subject.replace(key, keyvalue.get(key) == null ? '' : keyvalue.get(key));
                }
            }
            system.debug('body '+ body);
            system.debug('subject '+ subject);
            
            returnValue.add(subject);
            returnValue.add(body);
            returnValue.add(customEmail[0].EmailFrom__c);
        }
        
        return returnValue;
    }
    
}