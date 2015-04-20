@istest(seeAllData=true)
class testMarketoIntegrationScheduledClass
{
    @istest
    static void testMarketoIntegrationScheduledClass_Method1() 
    {
        Test.startTest();

        MarketoIntegrationScheduledClass mi = new MarketoIntegrationScheduledClass();
        String jobId = System.schedule('Marketo Integration', MarketoIntegrationScheduledClass.CRON_EXP, mi);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(MarketoIntegrationScheduledClass.CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }
}