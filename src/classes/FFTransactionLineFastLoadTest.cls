@IsTest
public class FFTransactionLineFastLoadTest{

    private static testmethod void testFFTransactionLineFastLoad(){
        FFTransactionLineFastLoad tlLoad= new FFTransactionLineFastLoad ();
        System.schedule( 'FFTransactionLineFastLoad', tlLoad.CRON_EXP , tlLoad);
    }

}