public class tncEventsWrapper{
    
    private double percentage = 0.30; // VS-TODO get the percentages from the product object rather than hardcode. page 58
    
    public double bscLiability                       {get;set;}
    public double cancellationFee                    {get;set;}
    public double transferFee                        {get;set;}
	public double cancellationFeeOriginal            {get;set;}    
    public double transferFeeOriginal                {get;set;}    
    public tncReasonData reasonData                  {get;set;}
    public boolean isSelected                        {get;set;}
    public Special_Event__c event                    {get;set;}
    public OpportunityLineItem opportunityLineItem   {get;set;}
    public string transferAction					 {get;set;} 
    public List<SelectOption> selectTransferAction	 {get;set;}
    public boolean feesToBeApplied            {get;set;}     
    
    public double unitPrice                          {get{
                                                            if (opportunityLineItem == null ) {
                                                            	return 0;
                                                            } else {
                                                            	return opportunityLineItem.UnitPrice;
                                                            }
                                                         }
                                                     }
    
    private string calledFrom                        {get;set;}
    
    /*
     * Constructor
    */
    public tncEventsWrapper(boolean isSelected, Special_Event__c event){
        this.isSelected = isSelected;
        this.event = event;
        this.reasonData = new tncReasonData();
        
        if (event.Customer_Cancellation_Transfer_Date__c != null){
            Datetime transferDate = event.Customer_Cancellation_Transfer_Date__c;
            this.reasonData.transferRequestedOn = transferDate.format('dd/MM/yyyy');
        
            this.reasonData.reason = event.Transfer_Cancellation_Reason__r.Name;
            this.reasonData.reasonNote = event.Transfer_Cancellation_Notes__c;
        }
        selectTransferAction = new List<SelectOption>();
        if (event.Status__c == 'To Be Transferred'){
            selectTransferAction.add(new SelectOption('Request Event', 'Request Event'));
        } else {
            selectTransferAction.add(new SelectOption('Select Action', 'Select Action'));
            selectTransferAction.add(new SelectOption('Request Event', 'Request Event'));
            selectTransferAction.add(new SelectOption('To be Transferred', 'To be Transferred'));
        }
        
    }
    
    /*
     * Calculates cancellation fees for the selected event
    */
    public double processCancellationFee(){
        transferFee = 0;
        calledFrom = 'Cancellation';
        
        if (feesToBeApplied){
            if (event.Stage__c != 'Provisional'){
            	double daysBetween = date.parse(reasonData.cancellationRequestedOn).daysBetween(event.StartDate__c);
            	
            	system.debug('daysBetween: ' + daysBetween);
            	
                if (daysBetween >= opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Day_1__c )
                    percentage = opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Fee_1__c;
                    
            	else if (daysBetween < opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Day_1__c &&
                         daysBetween >= opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Day_2__c)
                     percentage = opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Fee_2__c;
                     
            	else if (daysBetween < opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Day_2__c &&
                         daysBetween >= opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Day_3__c)
            	    percentage = opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Fee_3__c;

                else
            		percentage = opportunityLineItem.PricebookEntry.Product2.Cancellation_Charge_Fee_Final__c;
                
            	system.debug('daysBetween/unitPrice/percentage: ' + daysBetween +'/' + unitPrice+'/'+percentage);
            		
            	cancellationFee = unitPrice * (percentage/100);
            	
            } else if (event.Stage__c == 'Provisional'){
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
     * Calculates Transfer fees for the selected event
    */
    public double processTransferFee(){
        cancellationFee = 0;
        calledFrom = 'Transfer';
        
        if (feesToBeApplied){
	        if (event.Stage__c != 'Provisional'){
                
                double daysBetween = date.parse(reasonData.transferRequestedOn).daysBetween(event.StartDate__c);
            	
                if (daysBetween >= opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Day_1__c )
                    percentage = opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Fee_1__c;
                    
            	else if (daysBetween < opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Day_1__c &&
                         daysBetween >= opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Day_2__c)
                     percentage = opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Fee_2__c;
            	
            	else if (daysBetween < opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Day_2__c &&
                         daysBetween >= opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Day_3__c)
            	    percentage = opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Fee_3__c;
                
                else
            		percentage = opportunityLineItem.PricebookEntry.Product2.Transfer_Charge_Fee_Final__c;

            	system.debug('daysBetween/unitPrice/percentage: ' + daysBetween +'/' + unitPrice+'/'+percentage);
                
            	transferFee = unitPrice * (percentage/100);
                
	        } else if (event.Stage__c == 'Provisional'){
	            transferFee = 0;
	        }
            
            transferFee = decimal.valueof( transferFee ).setScale(2);
	        transferFeeOriginal = transferFee;
            
        } else {
            transferFee = 0;
            transferFeeOriginal = 0;
        }
        
        return transferFee;
    }
    
    /* 
     * Calculates BSC Liability for the selected event
    */
    public void processBSCLiability(){
        double liability = 0;
        double trainerFees = 0;
        bscLiability = 0;
        for (Purchase_Order__c order : event.purchase_orders__r){
            liability = liability + order.Current_Liability__c;
        }
        integer timeLeft;
        if (calledFrom == 'Cancellation'){
        	timeLeft = date.parse(reasonData.cancellationRequestedOn).daysBetween(event.StartDate__c);
        } else {
        	timeLeft = date.parse(reasonData.transferRequestedOn).daysBetween(event.StartDate__c);
        }
        
        if (timeleft < 14){
            trainerFees = event.Trainer_Fees__c;
        } else if(timeleft > 14){
            trainerFees = event.Trainer_Fees__c * 0.50;
        } 
        system.debug('transfer fee2 : ' + transferFee);
        system.debug('calledFrom '+ calledFrom);
        system.debug('transferfee: ' + (calledFrom != 'Transfer'? 0 : (transferFee * 0.10)));
        bscLiability = liability + trainerFees + 
            		   (calledFrom != 'Cancellation' ? 0 : (cancellationFee * 0.10)) + 
            		   (calledFrom != 'Transfer'? 0 : (transferFee * 0.10))  ;
    }
    

}