global class BSCDelegateCaptureClass
{
    webservice static void sendDelegateFormToTrainer(Id event)
    {
        system.debug('Inside sendDelegateFormToTrainer');
        system.debug('Id event - ' + event);

        Special_Event__c curr_event = [SELECT Id, Name, StartDate__c, EndDate__c, Trainer_Email__c, Trainer_Name__c FROM Special_Event__c WHERE id = :event];
        system.debug('Special_Event__c curr_event - ' + curr_event);

        EmailTemplate sendLinkEmail = [SELECT Id, Name, Subject, Body, IsActive, Description, HtmlValue, BrandTemplateId, Markup, NamespacePrefix, TemplateStyle, TemplateType, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Delegate_Form_Link_Email'];
        system.debug('EmailTemplate email - ' + sendLinkEmail);
        if(sendLinkEmail != null && curr_event != null)
        {
            String subject = sendLinkEmail.Subject;
            subject = subject.replace('Event_Name__c', curr_event.Name);
            subject = subject.replace('StartDate__c', curr_event.StartDate__c.format());

            String body = sendLinkEmail.body;
            body = body.replace('Trainer_Name__c', curr_event.Trainer_Name__c);
            body = body.replace('Event_Name__c', curr_event.Name);
            body = body.replace('StartDate__c', curr_event.StartDate__c.format());
            body = body.replace('EndDate__c', curr_event.EndDate__c.format());
            body = body.replace('Id__c', curr_event.Id);
            system.debug('EmailTemplate email.subject - ' + subject);
            system.debug('EmailTemplate email.Body - ' + body);

            List<String> emailList = new List<String> ();
            emailList.add(curr_event.Trainer_Email__c);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailList);
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}, false);
            system.debug('Messaging.SendEmailResult - ' + results);
        }
        else
        {
            system.debug('Email Template (Send_Delegate_Form_Link) OR Event Id is missing');
        }
    }
}