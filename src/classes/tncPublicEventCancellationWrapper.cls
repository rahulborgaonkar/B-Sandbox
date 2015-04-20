public class tncPublicEventCancellationWrapper{
	
    private double percentage = 0.30; // VS-TODO get the percentages from the product object rather than hardcode. page 58
    
    public boolean isSelected 	                {get; set;}
    public Special_Event_Booking__c booking		{get; set;}
    public double cancellationFee				{get; set;}
    public double cancellationFeeOriginal       {get; set;}
    public tncReasonData reasonData             {get; set;}
    public OpportunityLineItem oli              {get; set;}
    public string transferToId					{get; set;} 
    public string transferToName				{get; set;}
    public string StatusChanged				    {get; set;}
    public string oldBookingStatus				{get; set;}
    public id oldBookingTransferTo   			{get; set;}
    public string eventUnits 	    			{get; set;}
    public boolean feesToBeApplied              {get; set;}
    public double unitPrice                     {get{
        												if (oli == null ) {
                                                            return 0;
                                                        } else {
                                                            system.debug('opportunityLineItem.UnitPrice' + oli.UnitPrice);
                                                            return double.valueof(oli.UnitPrice);
                                                        }
    												}
                                                }
    
    public tncPublicEventCancellationWrapper(Special_Event_Booking__c booking){
        this.isSelected = false;
        this.booking = booking;
        this.cancellationFee = 0;
        this.oldBookingStatus = booking.Status__c;
        this.reasonData = new tncReasonData();
        if (booking.Transfer_To__c != null){
            transferToName = booking.Transfer_To__r.Name;
            transferToId = booking.Transfer_To__c;
            oldBookingTransferTo = booking.Transfer_To__c; 
        }
        
        if(booking.Customer_Cancellation_Transfer_Date__c != null){
            datetime dt = booking.Customer_Cancellation_Transfer_Date__c;
            this.reasonData.cancellationRequestedOn = dt.format('dd/MM/yyyy');
            this.reasonData.reasonId = booking.Transfer_Cancellation_Reason__c;
            this.reasonData.reason = booking.Transfer_Cancellation_Reason__r.Name;
            this.reasonData.reasonNote = booking.Transfer_Cancellation_Notes__c;
            this.cancellationFeeOriginal = booking.Transfer_Cancellation_Fee__c;
        }
        
        this.eventUnits = booking.TnC_Event_Units__c;
        this.transferToId = booking.Transfer_to__c;
    }
    
    
        /*
     * Calculates cancellation fees for the selected event
    */
    public double processTransferFee(){
        
        if (feesToBeApplied){
            if (booking.Status__c != 'Provisional'){
                
                double daysBetween = date.parse(reasonData.cancellationRequestedOn).daysBetween(booking.Event_Start_Date__c);
            	
            	
            	
                if (daysBetween >= oli.PricebookEntry.Product2.Transfer_Charge_Day_1__c )
                    percentage = oli.PricebookEntry.Product2.Transfer_Charge_Fee_1__c;
                    
            	else if (daysBetween < oli.PricebookEntry.Product2.Transfer_Charge_Day_1__c &&
                         daysBetween >= oli.PricebookEntry.Product2.Transfer_Charge_Day_2__c)
                     percentage = oli.PricebookEntry.Product2.Transfer_Charge_Fee_2__c;

            	else if (daysBetween < oli.PricebookEntry.Product2.Transfer_Charge_Day_2__c &&
                         daysBetween >= oli.PricebookEntry.Product2.Transfer_Charge_Day_3__c)
            	    percentage = oli.PricebookEntry.Product2.Transfer_Charge_Fee_3__c;
                
                else
            		percentage = oli.PricebookEntry.Product2.Transfer_Charge_Fee_Final__c;

                system.debug('daysBetween/unitPrice/percentage: ' + daysBetween +'/' + unitPrice+'/'+percentage);

            		
            	cancellationFee = unitPrice * (percentage/100);
       
            } else if (booking.Status__c == 'Provisional'){
                cancellationFee = 0;
            }
            
            cancellationFee =  decimal.valueof( cancellationFee ).setScale(2);
            cancellationFeeOriginal = cancellationFee;
        } else {
            cancellationFeeOriginal = 0;
            cancellationFee = 0;
        }
        return cancellationFee;
    }
    
    
    /*
     * Calculates cancellation fees for the selected event
    */
    public double processCancellationFee(){
        
        if (feesToBeApplied){
            if (booking.Status__c != 'Provisional'){
                
                double daysBetween = date.parse(reasonData.cancellationRequestedOn).daysBetween(booking.Event_Start_Date__c);
            	
                if (daysBetween >= oli.PricebookEntry.Product2.Cancellation_Charge_Day_1__c )
                    percentage = oli.PricebookEntry.Product2.Cancellation_Charge_Fee_1__c;
                    
            	else if (daysBetween < oli.PricebookEntry.Product2.Cancellation_Charge_Day_1__c &&
                         daysBetween >= oli.PricebookEntry.Product2.Cancellation_Charge_Day_2__c)
                     percentage = oli.PricebookEntry.Product2.Cancellation_Charge_Fee_2__c;

            	else if (daysBetween < oli.PricebookEntry.Product2.Cancellation_Charge_Day_2__c &&
                         daysBetween >= oli.PricebookEntry.Product2.Cancellation_Charge_Day_3__c)
            	    percentage = oli.PricebookEntry.Product2.Cancellation_Charge_Fee_3__c;

                else
            		percentage = oli.PricebookEntry.Product2.Cancellation_Charge_Fee_Final__c;

                system.debug('daysBetween/unitPrice/percentage: ' + daysBetween +'/' + unitPrice+'/'+percentage);

                cancellationFee = unitPrice * (percentage/100);
                
            } else if (booking.Status__c == 'Provisional'){
                cancellationFee = 0;
            }
            
            cancellationFee = decimal.valueof( cancellationFee ).setScale(2);
            cancellationFeeOriginal = cancellationFee;
        } else {
            cancellationFeeOriginal = 0;
            cancellationFee = 0;
        }
        return cancellationFee;
    }
    
}