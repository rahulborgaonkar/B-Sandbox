global class MarketoIntegrationScheduledClass Implements Schedulable
{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    global void execute(SchedulableContext sc)
    {
        system.debug('In Execute');
        Set<Contact> allContact_site = new Set<Contact>();
        Set<Contact> allContact_oppc = new Set<Contact>();
        Set<Contact> allContact_eve = new Set<Contact>();
        Set<Lead> allLead = new Set<Lead>();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :sc.getTriggerId()];

        //System.assertEquals(CRON_EXP, ct.CronExpression);
        //System.assertEquals(0, ct.TimesTriggered);
        //System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        for(Subscription_Site__c ssc : [SELECT Site_Contact__r.X18_Digit_Contact_ID__c, Site_Contact__r.Integrate_With_Marketo__c 
                                                    FROM Subscription_Site__c 
                                                    WHERE Site_Status__c LIKE 'Current%' 
                                                    AND Site_Contact__r.Integrate_With_Marketo__c = false 
                                                    AND Site_Contact__r.X18_Digit_Contact_ID__c != null])
        {
            Contact c = new Contact(Id = ssc.Site_Contact__r.X18_Digit_Contact_ID__c, Integrate_With_Marketo__c = true);
            allContact_site.add(c);
        }
        system.debug('allContact_site.size() - ' + allContact_site.size());

        try
        {
            List<Contact> l_allContact = new List<Contact> (allContact_site);
            update new List<Contact> (l_allContact);
        }
        catch(Exception e)
        {
            system.debug('allContact Exception - ' + e);
        }

        for(OpportunityContactRole ocr : [SELECT Contact.X18_Digit_Contact_ID__c, Contact.Integrate_With_Marketo__c 
                                                    FROM OpportunityContactRole 
                                                    WHERE IsPrimary = true 
                                                    AND (Opportunity.CloseDate >= 2012-03-01) 
                                                    AND Contact.Integrate_With_Marketo__c = false 
                                                    AND Opportunity.IsWon = true])
        {
            Contact c = new Contact(Id = ocr.Contact.X18_Digit_Contact_ID__c, Integrate_With_Marketo__c = true);
            allContact_oppc.add(c);
        }
        system.debug('allContact_oppc.size() - ' + allContact_oppc.size());

        try
        {
            List<Contact> l_allContact = new List<Contact> (allContact_oppc);
            update new List<Contact> (l_allContact);
        }
        catch(Exception e)
        {
            system.debug('allContact Exception - ' + e);
        }

        for(Special_Event_Booking__c seb : [SELECT Contact__r.X18_Digit_Contact_ID__c, Contact__r.Integrate_With_Marketo__c 
                                                                FROM Special_Event_Booking__c 
                                                                WHERE Event_Start_Date__c > 2012-03-01 
                                                                AND Status__c in ('Provisional','Confirmed','Attended','No Show','Attended - Fail','Attended - Pass','Attended - Merit','Attended - Distinction') 
                                                                AND Contact__r.Integrate_With_Marketo__c = false 
                                                                AND Contact__r.X18_Digit_Contact_ID__c != null])
        {
            Contact c = new Contact(Id = seb.Contact__r.X18_Digit_Contact_ID__c, Integrate_With_Marketo__c = true);
            allContact_eve.add(c);
        }
        system.debug('allContact_eve.size() - ' + allContact_eve.size());

        try
        {
            List<Contact> l_allContact = new List<Contact> (allContact_eve);
            update new List<Contact> (l_allContact);
        }
        catch(Exception e)
        {
            system.debug('allContact Exception - ' + e);
        }

        for(Lead l : [SELECT Id, Integrate_With_Marketo__c FROM Lead WHERE LeadSource = 'Live Chat' AND Integrate_With_Marketo__c = false AND IsConverted = false])
        {
            l.Integrate_With_Marketo__c = true;
            allLead.add(l);
        }

        system.debug('allLead.size() - ' + allLead.size());

        try
        {
            update new List<Lead> (allLead);
        }
        catch(Exception e)
        {
            system.debug('allLead Exception - ' + e);
        }

        try
        {
            List<String> EmailId = new List<String> ();
            EmailId.add('salesforcealerts@britsafe.org');
            //EmailId.add('rahul.borgaonkar@britsafe.org');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(EmailId);
            mail.setSubject('Daily Update Count of Integrate With Marketo flag On Contacts - ' + Date.today().format());

            String mailBody = 'Hi\n\nCount of Integrate With Marketo flag Updated for Related Contacts\n\n';
            mailBody = mailBody + 'Subscription Sites Contact Count - ' + allContact_site.size() + '\n\n';
            mailBody = mailBody + 'Opportunity Contact Role Contact Count - ' + allContact_oppc.size() + '\n\n';
            mailBody = mailBody + 'Event Booking Contact Count - ' + allContact_eve.size() + '\n\n';
            mailBody = mailBody + 'And\n\n';
            mailBody = mailBody + 'Lead Count - ' + allLead.size() + '\n\n';
            mailBody = mailBody + 'Thank You\n';
            mail.setPlainTextBody(mailBody);

            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('Mail Result - ' + results);
        }
        catch(Exception e)
        {
            system.debug('Email Exception - ' + e);
        }

    }
}