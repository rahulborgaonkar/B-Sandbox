public class BookingEventTriggerMethods
{
    public class Test_Exception extends Exception{}

    public static void updateInvoiceStatus(Map<Id,Special_Event_Booking__c>bookingMap)
    {
    
        system.debug('Booking Select 1');
        List<c2g__codaInvoiceLineItem__c> ListinvoiceLineItem = [Select c2g__Invoice__r.Copy_Invoice_Status__c,
                                                                c2g__Invoice__r.c2g__InvoiceStatus__c,
                                                                BEB__c
                                                                from c2g__codaInvoiceLineItem__c
                                                                where BEB__c IN:bookingMap.keySet()
                                                                ];
/* SOQL removed from loop for optimization. - Rahul
        for(c2g__codaInvoiceLineItem__c invoiceLineItem:[Select c2g__Invoice__r.Copy_Invoice_Status__c,
                                                                c2g__Invoice__r.c2g__InvoiceStatus__c,
                                                                BEB__c
                                                                from c2g__codaInvoiceLineItem__c
                                                                where BEB__c IN:bookingMap.keySet()
                                                                ])
*/
       for(c2g__codaInvoiceLineItem__c invoiceLineItem : ListinvoiceLineItem)
       {
                                                                                                               
            if(bookingMap.containsKey(invoiceLineItem.BEB__c))
            {
                Special_Event_Booking__c booking = bookingMap.get(invoiceLineItem.BEB__c);
                if(invoiceLineItem.c2g__Invoice__r.c2g__InvoiceStatus__c == 'Discarded')
                {    
                    booking.Invoice_Status__c = 'Not-Invoiced'; 
                }
                else{
                    booking.Invoice_Status__c = invoiceLineItem.c2g__Invoice__r.Copy_Invoice_Status__c;
                    // Removed as this field is updated by the Junction Object
                    /*if(booking.Invoice_Status__c =='Paid')
                    {
                        booking.Invoice_Paid_Date__c = Date.today();
                        
                    }*/
                }
                
                
            }    
        }
   
    }

    public testmethod static void testBookingEventTriggerMethods()
    {
        // Case 1359 and  1254 -- Added due to Winter 11 FF release where the default company of the user is required to determine the appropriate data
        c2g__codaUserCompany__c userCompany = [Select id, c.c2g__User__r.Username, c.c2g__Company__c From  c2g__codaUserCompany__c c Where c.c2g__User__r.Username = :UserInfo.getUserName() and c.c2g__Company__r.name='British Safety Council'];
        
        /*create test records for Special_event_booking__c*/
        Special_Event_Booking__c booking = TestHelper.CreateSpecialEventBooking();
        OpportunityLineItem opl = TestHelper.OppLineItem;

        system.debug('VS : ' + opl.id);
        system.debug('userCompany.c2g__Company__c : ' + userCompany.c2g__Company__c);
                
        c2g__codaInvoiceLineItem__c invoiceLineItem = [Select c.Id, c.BEB__c from c2g__codaInvoiceLineItem__c c Where c.c2g__Invoice__r.c2g__OwnerCompany__c = :userCompany.c2g__Company__c and OPL_ID__c = :opl.Id limit 1];

        system.debug('VS : ' + invoiceLineItem.id);
   
        Map<Id,Special_Event_Booking__c> bookingMap = new Map<Id,Special_Event_Booking__c>();
        bookingMap.put(booking.Id,booking);
        invoiceLineItem.BEB__c = booking.Id;
        update invoiceLineItem;
        BookingEventTriggerMethods.updateInvoiceStatus(bookingMap );                 

    }

}