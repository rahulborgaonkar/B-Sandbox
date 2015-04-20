public without sharing class GenerateInvoiceController {
    
   public static boolean isTest = false;
    
    public class Test_Exception extends Exception{}
    public List<AccountExt> accontExtList {get; set;}
    public String stage {get;set;}
    public List<OpportunityExt> defaultOppExtList;
    public AccountExt currentAcc{get;set;}
    public Boolean use121 {get;set;}
    
    private String sObjectid;
    public GenerateInvoiceController()
    {

        GenerateInvoiceController.isTest = false;
        sObjectid = ApexPages.currentPage().getParameters().get('id');
        
        String strUse121 = ApexPages.currentPage().getParameters().get('use121');
        if (strUse121 == null){
            strUse121 = 'false';
        }
        use121 = strUse121.equals('true');
        System.debug('FJP strUse121: '+strUse121);
        
        stage = 'Default';
        defaultOppExtList = new List<OpportunityExt>();
        if(sObjectid!=null)
        {
            accontExtList = new List<AccountExt>();
            
            Set<String> oppLineId = new  Set<String>();
            if(isOpportunity(sObjectid))
            {
                System.debug('isOpportunity');
                
                
                //Current record is an opportunity. It should be on top of the list
                //***************************************************************************
                //Change done by Navin Muneesamy on 09/02/2011 
                //Change to the SOQL query to retrieve non zero Unit Prices on OpportunityLineItems.
                //This was causing the error: Aggregate query has too many rows for direct assignment, use FOR loop
                //***************************************************************************                 
                Opportunity currentOpp = [Select o.Id,
                                                o.Name,
                                                o.Opportunity_Number__c,
                                                o.CloseDate, 
                                                o.Owner.Name,
                                                o.OwnerId,
                                                o.Purchase_Order_Reference__c,
                                                o.Subscription__c,
                                                o.Type,
                                                (Select l.Id,
                                                  l.OpportunityId,
                                                  l.PriceBookEntry.Product2.Name,
                                                  l.PriceBookEntry.Product2Id, 
                                                  l.Quantity,
                                                  l.Set_an_Invoice_Quantity__c, 
                                                  l.Dimension_1__c,
                                                  l.Dimension_2__c,
                                                  l.Quantity_Invoiced__c,
                                                  l.Quantity_Credited__c,
                                                  l.PricebookEntry.Product2.Dimension_1__c,
                                                  l.PricebookEntry.Product2.Dimension_2__c,
                                                  l.PricebookEntry.Product2.Renewal_Dimension_2__c,
                                                  l.PricebookEntry.Product2.Web_Dimension_2__c,
                                                  l.PricebookEntry.Product2.Renewal_Dimension_1__c,
                                                  l.Opportunity.Subscription__c,
                                                  l.Opportunity.Subscription__r.Includes_E_Delivery_Product__c,
                                                  l.Opportunity.Subscription__r.Account_Name__r.E_Delivery_Subscriber__c,
                                                  l.Opportunity.Subscription__r.Consolidated_Subscription__c,
                                                  l.Opportunity.Website_Order_Id__c,
                                                  l.Opportunity.Type,
                                                  l.UnitPrice 
                                                  from OpportunityLineItems l
                                                  ), 
                                                o.AccountId from Opportunity o
                                                where o.Id=:sObjectid limit 1];
                
                currentAcc = new AccountExt([Select Id,
                                                    Name,
                                                    (Select Id,
                                                            Name,
                                                            CloseDate, 
                                                            Owner.Name,
                                                            OwnerId,
                                                            AccountId 
                                                            from Opportunities WHERE Id = :sObjectid),
                                                    Ultimate_Parent__c from Account where Id=:currentOpp.AccountId]);
                                                    
                
                //First opportunity wihtin the list
                currentAcc.opportunityExtList.add(new OpportunityExt(currentOpp));
                
                //Opportunities list
                //***************************************************************************
                //Change done by Navin Muneesamy on 09/02/2011 
                //Change to the SOQL query to retrieve non zero Unit Prices on OpportunityLineItems.
                //This was causing the error: Aggregate query has too many rows for direct assignment, use FOR loop
                //***************************************************************************                 
                /*
                // Case: 00002677 - Generate Invoice Error if an account has many opportunities
                for(Opportunity opp:[Select o.Id,
                                          o.Name,
                                          o.CloseDate, 
                                          o.Owner.Name,
                                          o.OwnerId,
                                          o.Purchase_Order_Reference__c, 
                                          (Select l.Id,
                                                  l.OpportunityId,
                                                  l.PriceBookEntry.Product2.Name,
                                                  l.PriceBookEntry.Product2Id,
                                                  l.Set_an_Invoice_Quantity__c, 
                                                  l.Quantity, 
                                                  l.Quantity_Invoiced__c,
                                                  l.Quantity_Credited__c,
                                                  l.UnitPrice from OpportunityLineItems l
                                                  Where l.UnitPrice <> 0),
                                          o.AccountId from Opportunity o where o.AccountId=:currentAcc.acc.Id
                                          and (o.IsClosed = true or o.StageName = 'Part Invoiced')
                                          and o.Id!=:currentOpp.Id])
                {
                    
                    currentAcc.opportunityExtList.add(new OpportunityExt(opp));
                }
                
                */
                
            }
            
            if(isAccount(sObjectid))
            {
                System.debug('isAccount');
                //Current record is an account
                currentAcc = new AccountExt([Select Id,
                                                    Name,
                                                    (Select Id,
                                                            Name,
                                                            OwnerId,
                                                            CloseDate, 
                                                            Owner.Name,
                                                            Purchase_Order_Reference__c,
                                                            AccountId 
                                                            from Opportunities
                                                            where(IsClosed = true or StageName = 'Part Invoiced')),
                                                    Ultimate_Parent__c from Account where Id=:sObjectid]);
                
                //Opportunities list
                //***************************************************************************
                //Change done by Navin Muneesamy on 09/02/2011 
                //Change to the SOQL query to retrieve non zero Unit Prices on OpportunityLineItems.
                //This was causing the error: Aggregate query has too many rows for direct assignment, use FOR loop
                //***************************************************************************                                 
                for(Opportunity opp:[Select o.Id,
                                            o.Name,
                                            o.Opportunity_Number__c,
                                            o.CloseDate, 
                                            o.Owner.Name,
                                            o.OwnerId,
                                            o.Purchase_Order_Reference__c,
                                            o.Subscription__c,
                                            o.Type,
                                            (Select l.Id,
                                                    l.PriceBookEntry.Product2.Name, 
                                                    l.PriceBookEntry.Product2Id,
                                                    l.Quantity,
                                                    l.Set_an_Invoice_Quantity__c, 
                                                    l.Quantity_Invoiced__c,
                                                    l.Quantity_Credited__c,
                                                    l.PricebookEntry.Product2.Dimension_1__c,
                                                    l.PricebookEntry.Product2.Dimension_2__c,
                                                    l.PricebookEntry.Product2.Renewal_Dimension_2__c,
                                                    l.PricebookEntry.Product2.Web_Dimension_2__c,
                                                    l.PricebookEntry.Product2.Renewal_Dimension_1__c,
                                                    l.Opportunity.Subscription__c,
                                                    l.Opportunity.Subscription__r.Includes_E_Delivery_Product__c,
                                                    l.Opportunity.Subscription__r.Account_Name__r.E_Delivery_Subscriber__c,
                                                    l.Opportunity.Subscription__r.Consolidated_Subscription__c,
                                                    l.Opportunity.Website_Order_Id__c,
                                                    l.Opportunity.Type,
                                                    l.UnitPrice from OpportunityLineItems l
                                             ), 
                                            o.AccountId from Opportunity o where o.AccountId=:currentAcc.acc.Id
                                            and (o.IsClosed = true or o.StageName = 'Part Invoiced')
                                          ])
                {
                    System.debug('@@@@'+opp.OpportunityLineItems);
                    currentAcc.opportunityExtList.add(new OpportunityExt(opp));
                }
                    
             }
            
            //Opportunity Line Items list
            if(!currentAcc.opportunityExtList.isEmpty())
            {
                for(OpportunityExt oppExt :currentAcc.opportunityExtList)   
                {
                     System.debug('FJP step 1');
                        for(OpportunityLineItem oppLineItem: oppExt.opp.OpportunityLineItems)
                        {
                            System.debug('FJP step 2');
                            //Can be invoiced
                            //throw new Test_Exception('Quantity_Invoiced__c'+oppLineItem.Quantity_Invoiced__c+'@@'+oppLineItem.Quantity);
                            if (strUse121.equals('true')){
                                System.debug('FJP step 3');
                                oppLineItem.Set_an_Invoice_Quantity__c = oppLineItem.Quantity;
                            }else{
                                System.debug('FJP step 4');
                                if (oppLineItem.Quantity_Invoiced__c == null || oppLineItem.Quantity_Invoiced__c == 0){
                                    System.debug('FJP step 5');
                                    oppLineItem.Set_an_Invoice_Quantity__c = oppLineItem.Quantity;
                                }else if (oppLineItem.Quantity_Invoiced__c > 0 && oppLineItem.Quantity_Credited__c == 0){
                                    System.debug('FJP step 6');
                                    oppLineItem.Set_an_Invoice_Quantity__c = oppLineItem.Quantity - oppLineItem.Quantity_Invoiced__c;
                                }else if (oppLineItem.Quantity_Invoiced__c > 0 && oppLineItem.Quantity_Credited__c > 0){
                                    oppLineItem.Set_an_Invoice_Quantity__c = oppLineItem.Quantity + oppLineItem.Quantity_Credited__c - oppLineItem.Quantity_Invoiced__c;
                                    System.debug('FJP step 7:'+oppLineItem.Set_an_Invoice_Quantity__c);
                                }
                            }
                            System.debug('FJP step 8');
                            if(oppLineItem.Quantity_Invoiced__c == null || oppLineItem.Quantity_Invoiced__c == 0)
                            {
                                System.debug('FJP step 9');
                                oppLineId.add(oppLineItem.Id);
                                oppExt.oppLineItemExtList.add(new oppLineItemExt(oppLineItem));
                            }
                            else
                            {
                                System.debug('FJP step 10');
                                if(oppLineItem.Quantity - oppLineItem.Quantity_Invoiced__c > 0)
                                {
                                    System.debug('FJP step 11');
                                    oppLineId.add(oppLineItem.Id);
                                    oppExt.oppLineItemExtList.add(new oppLineItemExt(oppLineItem));
                                }
                            }
                            //Credited opportunity line item
                            if(oppLineItem.Quantity_Credited__c!=null && oppLineItem.Quantity_Credited__c>0)
                            {   
                                System.debug('FJP step 12');
                                oppExt.creditOppLineItemExtList.add(new oppLineItemExt(oppLineItem));
                                if(!oppLineId.contains(oppLineItem.Id)){
                                    System.debug('FJP step 13');
                                    oppLineId.add(oppLineItem.Id);
                                }
                            }   
                        } 
                  
                }
                System.debug('@@'+oppLineId);
                //Booking events list
                for(Special_Event_Booking__c booking : [Select s.Status__c, 
                                                               s.Special_Event__r.Status__c,
                                                               s.Special_Event__c, 
                                                               s.Name,
                                                               s.Special_Event__r.Name,
                                                               s.Special_Event__r.Product__c,
                                                               s.Product__c,
                                                               s.Special_Event__r.Product__r.Dimension_1__c,
                                                               s.Special_Event__r.Product__r.Dimension_2__c,
                                                               s.Special_Event__r.Dimension_4__c,
                                                               s.OPL_ID__c, 
                                                               s.Invoice_Status__c, 
                                                               s.Event_Start_Date__c, 
                                                               s.Credited_Status__c, 
                                                               s.Contact__r.FirstName,
                                                               s.Contact__r.LastName, 
                                                               s.Booking_Fee__c,
                                                               s.Transfer_Cancellation_Reason__c
                                                               From Special_Event_Booking__c s
                                                               where s.OPL_ID__c IN:oppLineId
                                                               and Type__c!='In-Company Additional' and Cancelled_Formerlly_Provisonal__c=false ])                                               
                {
                    
                    for(OpportunityExt oppExt :currentAcc.opportunityExtList)   
                    {
                        if(!oppExt.oppLineItemExtList.isEmpty())
                        {
                            for(OppLineItemExt oppLineItemExt: oppExt.oppLineItemExtList)
                            {
                                if(oppLineItemExt.oppLineItem.Id == booking.OPL_ID__c)
                                    oppLineItemExt.bookingExtList.add(new BookingExt(booking));
    
                            }
                        }
                        
                        if(!oppExt.creditOppLineItemExtList.isEmpty())
                        {
                            for(OppLineItemExt oppLineItemExt: oppExt.creditOppLineItemExtList)
                            {
                                if(oppLineItemExt.oppLineItem.Id == booking.OPL_ID__c)
                                    oppLineItemExt.bookingExtList.add(new BookingExt(booking));
    
                            }
                        }
                      system.debug('oppExt : '+oppExt );   
                    }
                        
                }
               
                //Subscription lines
                for(Subscription_Line__c subsLine :[Select s.Subscription__r.Sub_Ref__c, 
                                                           s.Subscription__r.Account_Name__r.Name,
                                                           s.Quantity__c, 
                                                           s.Product__c,
                                                           s.Product__r.Dimension_1__c,
                                                           s.Product__r.Dimension_2__c,
                                                           s.Product__r.Renewal_Dimension_2__c,
                                                           s.Product_Sales_Price__c, 
                                                           s.OPL_ID__c, 
                                                           s.Name, 
                                                           s.Invoice_Status__c, 
                                                           s.Credited_Status__c 
                                                           from Subscription_Line__c s
                                                           where s.OPL_ID__c IN:oppLineId ])                                               
                {
                    
                    for(OpportunityExt oppExt :currentAcc.opportunityExtList)   
                    {
                        if(!oppExt.oppLineItemExtList.isEmpty())
                        {
                            for(OppLineItemExt oppLineItemExt: oppExt.oppLineItemExtList)
                            {
                                if(oppLineItemExt.oppLineItem.Id == subsLine.OPL_ID__c)
                                    oppLineItemExt.subscriptionLineExtList.add(new SubscriptionLineExt(subsLine));
    
                            }
                        }
                        
                        if(!oppExt.creditOppLineItemExtList.isEmpty())
                        {
                            for(OppLineItemExt oppLineItemExt: oppExt.creditOppLineItemExtList)
                            {
                                if(oppLineItemExt.oppLineItem.Id == subsLine.OPL_ID__c)
                                    oppLineItemExt.subscriptionLineExtList.add(new SubscriptionLineExt(subsLine));
    
                            }
                        }
                    }
                        
                }
                
            }
            //currentAcc.stage = 'Default';
            
            accontExtList.add(currentAcc);      
            if (use121){
                creditedView();
            }
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Id missing'); 
            ApexPages.addMessage(myMsg);
        }  
        system.debug('fjp99: '+accontExtList);
        
    }
    
    public PageReference Cancel()
    {
        return new PageReference('/' + sObjectid);
    }
    
    
    public List<OpportunityExt> copyOpportunityExt(List<OpportunityExt> inExt)
    {
        List<OpportunityExt> copyList = new List<OpportunityExt>();
        for(OpportunityExt oppExt:inExt)
        {
            OpportunityExt oppExtCopy = new OpportunityExt(oppExt.opp);
            oppExtCopy.creditOppLineItemExtList = new List<OppLineItemExt>(oppExt.creditOppLineItemExtList);
            oppExtCopy.oppLineItemExtList = new List<OppLineItemExt>(oppExt.oppLineItemExtList);
            copyList.add(oppExtCopy);
        }
        return copyList;
    }
    
    //Check if it's an id of an Opportunity record
    public boolean isOpportunity(String id)
    {
        Schema.DescribeSObjectResult result = Opportunity.SObjectType.getDescribe();
        return(id.startsWith(result.getKeyPrefix()));

    }
    
    
    //Check if it's an id of an Account record
    public boolean isAccount(String id)
    {
        Schema.DescribeSObjectResult result = Account.SObjectType.getDescribe();
        return(id.startsWith(result.getKeyPrefix()));

    }
    
    public boolean containsAccount(Id accId)
    {
        if(!accontExtList.isEmpty())
        {
            for(AccountExt accExt:accontExtList)
            {
                if(accExt.acc.Id == accId)
                {
                    return true;
                    
                }
            }
        }
        return false;
    }
    
    public boolean containsOppLineItem(Id oppLineId)
    {
        if(!accontExtList.isEmpty())
        {
            for(AccountExt accExt:this.accontExtList)
            {
                for(OpportunityExt oppExt :accExt.opportunityExtList)
                {
                    for(OppLineItemExt oppLineItemExt: oppExt.oppLineItemExtList)
                    {
                        if(oppLineItemExt.oppLineItem.Id == oppLineId)
                             return true;
                     }
                } 
            } 
        }
        return false;
    }
    
    
    // populate the booking list for each opportunity line item
    public void populateBookingList(Set<String> oppLineId)
    {
        for(Special_Event_Booking__c booking : [Select s.Status__c, 
                                                               s.Special_Event__r.Status__c,
                                                               s.Special_Event__c,
                                                               s.Special_Event__r.Name,
                                                               s.Special_Event__r.Product__c, 
                                                               s.Name,
                                                               s.Special_Event__r.Product__r.Dimension_1__c,
                                                               s.Special_Event__r.Product__r.Dimension_2__c,
                                                               s.Special_Event__r.Dimension_4__c,
                                                               s.Product__c, 
                                                               s.Invoice_Status__c, 
                                                               s.Event_Start_Date__c, 
                                                               s.Credited_Status__c, 
                                                               s.Contact__r.FirstName,
                                                               s.Contact__r.LastName,
                                                               s.OPL_ID__c, 
                                                               s.Booking_Fee__c From Special_Event_Booking__c s
                                                               where s.OPL_ID__c IN:oppLineId
                                                               and Type__c!='In-Company Additional' ])                                               
                {
                    
                    for(AccountExt accExt:this.accontExtList)
                    {
                        for(OpportunityExt oppExt :accExt.opportunityExtList)
                        {
                            //Default view
                            for(OppLineItemExt oppLineItemExt: oppExt.oppLineItemExtList)
                            {
                                if(oppLineItemExt.oppLineItem.Id == booking.OPL_ID__c && oppLineItemExt.bookingExtList.isEmpty())
                                    oppLineItemExt.bookingExtList.add(new BookingExt(booking));
                            }
                            //Credited view
                            for(OppLineItemExt oppLineItemExt: oppExt.creditOppLineItemExtList)
                            {
                                if(oppLineItemExt.oppLineItem.Id == booking.OPL_ID__c)
                                    oppLineItemExt.bookingExtList.add(new BookingExt(booking));
    
                            }
                            
                        } 
               
                    } 
                    
                }
    }
    
    // populate the subscription line list for each opportunity line item
    public void populateSubsLineList(Set<String> oppLineId)
    {
        //All Subscription lines
                for(Subscription_Line__c subsLine :[Select s.Subscription__r.Sub_Ref__c, 
                                                           s.Subscription__r.Account_Name__r.Name,
                                                           s.Subscription__c,
                                                           s.Quantity__c, 
                                                           s.Product__c,
                                                           s.Product__r.Dimension_1__c,
                                                           s.Product__r.Dimension_2__c,
                                                           s.Product__r.Renewal_Dimension_2__c,
                                                           s.Product_Sales_Price__c, 
                                                           s.OPL_ID__c, 
                                                           s.Name, 
                                                           s.Invoice_Status__c, 
                                                           s.Credited_Status__c 
                                                           from Subscription_Line__c s
                                                           where s.OPL_ID__c IN:oppLineId ])                                               
                {
                    for(AccountExt accExt:this.accontExtList)
                    {
                        for(OpportunityExt oppExt :accExt.opportunityExtList)
                        {
                            for(OppLineItemExt oppLineItemExt: oppExt.oppLineItemExtList)
                            {
                                if(oppLineItemExt.oppLineItem.Id == subsLine.OPL_ID__c && oppLineItemExt.subscriptionLineExtList.isEmpty())
                                    oppLineItemExt.subscriptionLineExtList.add(new SubscriptionLineExt(subsLine));
                            }
                            for(OppLineItemExt oppLineItemExt: oppExt.creditOppLineItemExtList)
                            {
                                if(oppLineItemExt.oppLineItem.Id == subsLine.OPL_ID__c)
                                    oppLineItemExt.subscriptionLineExtList.add(new SubscriptionLineExt(subsLine));
    
                            }
                        } 
               
                    } 
                    
                    
                    
                }
        
    
    }
    
    //Create an invoice and invoice line items
    public PageReference createInvoice()
    {
        Set<Id> subscriptionsToUpdate = new Set<Id>();
        
        c2g.CODAAPICommon.Reference  result;
        Set<String> invoiceDescription = new Set<String>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<OpportunityLineItem> updateOppLineItemList = new List<OpportunityLineItem>();
        //Webservice reference invoice 
        c2g.CODAAPIInvoiceTypes_4_0.Invoice invoice = new c2g.CODAAPIInvoiceTypes_4_0.Invoice()  ;
        invoice.InvoiceDate = Date.today();
        invoice.PrintedText1AllowEdit = false;
        invoice.PrintedText2AllowEdit = false;
        invoice.PrintedText3AllowEdit =  false;
        invoice.PrintedText4AllowEdit = false;
        invoice.PrintedText5AllowEdit = false;
        invoice.Usepartperiods = false;
        invoice.InvoiceDescription = '';
        //invoice.DueDate = Date.today().addDays(30);
        invoice.Account = new c2g.CODAAPICommon.Reference();
        
        if(sObjectid!=null){
            if(isOpportunity(sObjectid)){
                invoice.Opportunity = new c2g.CODAAPICommon.Reference();
                invoice.Opportunity.Id = ApexPages.currentPage().getParameters().get('id');
            }
        }
        invoice.LineItems = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItems();
        invoice.LineItems.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem>();
        
        //Specify the company to consider
        c2g.CODAAPICommon_4_0.Context context = new c2g.CODAAPICommon_4_0.Context();
        if(!GenerateInvoiceController.isTest)
        {
            List<String> usrCurrentCompanyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
            Opportunity oppCompanyName = [SELECT Invoice_Company__r.Name FROM Opportunity WHERE Id = :invoice.Opportunity.Id][0];
            System.debug('FJP Opp: '+oppCompanyName);
            if (oppCompanyName.Invoice_Company__r.Name == null){
                context.CompanyName = usrCurrentCompanyName.get(0);
                System.debug('FJP Using current company');
            }else{
                context.CompanyName = oppCompanyName.Invoice_Company__r.Name;
                System.debug('FJP Using opp company');
            }
        }
        
        if(accontExtList.size()>1)
            invoice.Account.Id = accontExtList.get(0).acc.Ultimate_Parent__c;
        else{
            invoice.Account.Id = accontExtList.get(0).acc.Id;
        }
        system.debug('accontExtList: '+accontExtList);
        if(!this.accontExtList.isEmpty())
        {
        system.debug('1');
            for(AccountExt accExt:this.accontExtList)
            {
                    system.debug('2');
               for(OpportunityExt oppExt :accExt.opportunityExtList)
               {                
                       system.debug('oppExt.oppLineItemExtList: '+  oppExt.oppLineItemExtList);
                 for(OppLineItemExt oppLineItemExt: oppExt.oppLineItemExtList)
                 {
                         system.debug('4');
                    //Create invoice invoice line item against a product line item selected
                    system.debug('entering if');
                    if(oppLineItemExt.selected && oppLineItemExt.bookingExtList.isEmpty() &&  oppLineItemExt.subscriptionLineExtList.isEmpty())
                    {
                        if(oppExt.opp.Purchase_Order_Reference__c!=null)
                            invoiceDescription.add(oppExt.opp.Purchase_Order_Reference__c);
                        c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem lineItem = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem();
                        lineItem.Product = new c2g.CODAAPICommon.Reference();
                        lineItem.Product.Id = oppLineItemExt.oppLineItem.PriceBookEntry.Product2Id;
                        lineItem.UnitPrice = oppLineItemExt.oppLineItem.UnitPrice;
                        if(oppLineItemExt.oppLineItem.Set_an_Invoice_Quantity__c == null)
                        {   
                            if(oppLineItemExt.oppLineItem.Quantity_Invoiced__c == null){
                                oppLineItemExt.oppLineItem.Quantity_Invoiced__c = 0;
                            }
                            if(oppLineItemExt.oppLineItem.Quantity_Credited__c == null){
                                oppLineItemExt.oppLineItem.Quantity_Credited__c = 0;
                            }
                            lineItem.Quantity = oppLineItemExt.oppLineItem.Quantity - oppLineItemExt.oppLineItem.Quantity_Invoiced__c + oppLineItemExt.oppLineItem.Quantity_Credited__c;
                        }   
                        else{
                            lineItem.Quantity = oppLineItemExt.oppLineItem.Set_an_Invoice_Quantity__c;
                        }
                        lineItem.LineDescription = oppLineItemExt.oppLineItem.Id+';void';
                        lineItem.UsePartPeriods = false;
                        
                        if (oppLineItemExt.oppLineItem.PricebookEntry.Product2.Dimension_1__c != null){
                            lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                            lineItem.Dimension1.Id = oppLineItemExt.oppLineItem.PricebookEntry.Product2.Dimension_1__c;
                        }else{
                            if(InvoiceHelper.getDimension1CodeFromOwner(oppExt.opp.OwnerId) != null){
                                lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                                lineItem.Dimension1.Id = InvoiceHelper.getDimension1CodeFromOwner(oppExt.opp.OwnerId);
                            }
                        }
                        lineItem.Dimension2 = new c2g.CODAAPICommon.Reference();
                        lineItem.Dimension2.Id = FinanceHelper.getDim2Code(oppLineItemExt.oppLineItem);
                        
                        invoice.LineItems.LineItemList.add(lineItem);
                        updateOppList.add(oppExt.opp);
                        updateOppLineItemList.add(oppLineItemExt.oppLineItem);
                    }   
                    //throw new Test_Exception('Done');
                    for(SubscriptionLineExt subsLineExt:oppLineItemExt.subscriptionLineExtList)
                    {
                        //Create invoice invoice line item against a susbscription line selected
                        if(subsLineExt.selected)
                        {
                            // Add the subscription to the subscription update list
                            subscriptionsToUpdate.add(subsLineExt.subsLine.Subscription__c);
                            System.debug('Added '+subsLineExt.subsLine.Subscription__c+' to Subscription Update list');

                            if(oppExt.opp.Purchase_Order_Reference__c!=null)
                                invoiceDescription.add(oppExt.opp.Purchase_Order_Reference__c);
                            c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem lineItem2 = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem();
                            lineItem2.Product = new c2g.CODAAPICommon.Reference();
                            lineItem2.Product.Id = subsLineExt.subsLine.Product__c;
                            lineItem2.Quantity = subsLineExt.subsLine.Quantity__c;
                            lineItem2.UnitPrice = oppLineItemExt.oppLineItem.UnitPrice;
                            lineItem2.LineDescription = oppLineItemExt.oppLineItem.Id+';'+subsLineExt.subsLine.Id;
                            lineItem2.UsePartPeriods = false;
                            if(subsLineExt.subsLine.Product__r.Dimension_1__c!=null){
                                lineItem2.Dimension1 = new c2g.CODAAPICommon.Reference();
                                lineItem2.Dimension1.Id = subsLineExt.subsLine.Product__r.Dimension_1__c;                                   
                             }else{
                                if(InvoiceHelper.getDimension1CodeFromOwner(oppExt.opp.OwnerId) != null){
                                    lineItem2.Dimension1 = new c2g.CODAAPICommon.Reference();
                                    lineItem2.Dimension1.Id = InvoiceHelper.getDimension1CodeFromOwner(oppExt.opp.OwnerId);
                                }
                            }
                            // @todo needs to use the financehelper.dim2code code
                            if (oppExt.opp.Type == 'Subscription Renewal' && subsLineExt.subsLine.Product__r.Renewal_Dimension_2__c !=null){
                                lineItem2.Dimension2 = new c2g.CODAAPICommon.Reference();
                                lineItem2.Dimension2.Id = subsLineExt.subsLine.Product__r.Renewal_Dimension_2__c;
                            }else{
                                if(subsLineExt.subsLine.Product__r.Dimension_2__c!=null){
                                    lineItem2.Dimension2 = new c2g.CODAAPICommon.Reference();
                                    lineItem2.Dimension2.Id = subsLineExt.subsLine.Product__r.Dimension_2__c;
                                }
                            }
                            invoice.LineItems.LineItemList.add(lineItem2);
                            updateOppList.add(oppExt.opp);
                            updateOppLineItemList.add(oppLineItemExt.oppLineItem);
                        }
                    }
                      
                    for(BookingExt bookingExt:oppLineItemExt.bookingExtList)
                    {
                        //Create invoice invoice line item against a booking event selected
                        if(bookingExt.selected)
                        {
                            if(oppExt.opp.Purchase_Order_Reference__c!=null)
                                invoiceDescription.add(oppExt.opp.Purchase_Order_Reference__c);
                                                               
                            c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem lineItem2 = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem();
                            lineItem2.Product = new c2g.CODAAPICommon.Reference();
                            //lineItem2.Product.Id = bookingExt.bookingEvt.Special_Event__r.Product__c;
                            //VS amended this line to get the product 
                            if (bookingExt.bookingEvt.Transfer_Cancellation_Reason__c == null)
                                lineItem2.Product.Id = bookingExt.bookingEvt.Special_Event__r.Product__c;
                            else
                                lineItem2.Product.Id = oppLineItemExt.oppLineItem.PriceBookEntry.Product2Id;
                                
                            lineItem2.Quantity = 1;
                            lineItem2.UnitPrice = oppLineItemExt.oppLineItem.UnitPrice;
                            lineItem2.LineDescription = oppLineItemExt.oppLineItem.Id+';'+bookingExt.bookingEvt.Id+';'+bookingExt.bookingEvt.Special_Event__r.Name+';'+bookingExt.bookingEvt.Event_Start_Date__c;
                            lineItem2.UsePartPeriods = false;
                            if(bookingExt.bookingEvt.Special_Event__r.Dimension_4__c!=null)
                            {
                                lineItem2.Dimension4 = new c2g.CODAAPICommon.Reference();
                                lineItem2.Dimension4.Id  = bookingExt.bookingEvt.Special_Event__r.Dimension_4__c;
                            }
                            // @todo needs to use the financehelper.dim2code code
                            //if(bookingExt.bookingEvt.Special_Event__r.Product__r.Dimension_2__c!=null)
                            system.debug('oppLineItemExt.oppLineItem.PricebookEntry.Product2.Dimension_2__c: ' + oppLineItemExt.oppLineItem.PricebookEntry.Product2.Dimension_2__c);
                            if(oppLineItemExt.oppLineItem.Dimension_2__c!=null)
                            {
                                lineItem2.Dimension2 = new c2g.CODAAPICommon.Reference();
                               // if (bookingExt.bookingEvt.Transfer_Cancellation_Reason__c == null)
                               //     if(bookingExt.bookingEvt.Special_Event__r.Product__r.Dimension_2__c!=null)
                               //         lineItem2.Dimension2.Id  = bookingExt.bookingEvt.Special_Event__r.Product__r.Dimension_2__c;
                               // else 
                                    lineItem2.Dimension2.Id  = oppLineItemExt.oppLineItem.PricebookEntry.Product2.Dimension_2__c;
                            }
                            //if(bookingExt.bookingEvt.Special_Event__r.Product__r.Dimension_1__c!=null)
                            if(oppLineItemExt.oppLineItem.Dimension_1__c!=null)
                            {
                                lineItem2.Dimension1 = new c2g.CODAAPICommon.Reference();
                                lineItem2.Dimension1.Id  = oppLineItemExt.oppLineItem.PricebookEntry.Product2.Dimension_1__c;
                            }else{
                                if(InvoiceHelper.getDimension1CodeFromOwner(oppExt.opp.OwnerId) != null){
                                    lineItem2.Dimension1 = new c2g.CODAAPICommon.Reference();
                                    lineItem2.Dimension1.Id = InvoiceHelper.getDimension1CodeFromOwner(oppExt.opp.OwnerId);
                                }
                            }
                            invoice.LineItems.LineItemList.add(lineItem2);
                            updateOppList.add(oppExt.opp);
                            updateOppLineItemList.add(oppLineItemExt.oppLineItem);
                        }
                    }   
                 }
               }
            }
            
            try
            {
                if(!GenerateInvoiceController.isTest)
                {    
                    if(!invoiceDescription.isEmpty())
                    {
                        //Populate description of the invoice
                        List<String> invoiceDescriptionList = new List<String>();
                        invoiceDescriptionList.addAll(invoiceDescription);
                        
                        for(Integer i = 0;i<invoiceDescriptionList.size()-1;i++)
                        {
                            invoice.InvoiceDescription += invoiceDescriptionList.get(i)+';';
                        }
                        invoice.InvoiceDescription += invoiceDescriptionList.get(invoiceDescriptionList.size()-1);
                        //throw new Test_Exception(invoice.InvoiceDescription);     
                    }
                    invoice.InvoiceStatus =c2g.CODAAPIInvoiceTypes_4_0.enumInvoiceStatus.InProgress;
                    system.debug('invoice.LineItems:'+invoice.LineItems);
                    if (invoice.LineItems.LineItemList.size() > 0){
                        System.debug('FJP Context: '+context);
                        System.debug('FJP Invoice: '+invoice);
                        result=c2g.CODAAPISalesInvoice_4_0.CreateInvoice(context , invoice);
                    }else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You must generate at least one invoice line'); 
                        ApexPages.addMessage(myMsg);
                    }
                    
                    // subscriptionsToUpdate
                    if (!subscriptionsToUpdate.isEmpty()){
                        System.debug('Subscriptions need to updated with invoice id.');
                        List<Subscription__c> subsToUpd = new List<Subscription__c>([SELECT Id, Renewal_Sales_Invoice__c FROM Subscription__c WHERE Id IN :subscriptionsToUpdate]);
                        System.debug('Subscriptions updating with invoice: '+result.Id+' = '+subsToUpd);
                        for (Subscription__c sub:subsToUpd){
                            sub.Renewal_Sales_Invoice__c = result.Id;
                        }
                        update subsToUpd;
                    }
                    
                    // Update Latest Invoice on opportunity
                    System.debug('FJP sObject 1');

                    // *** THIS DOESN'T FIRE ***
                    
                    if(sObjectid!=null){
                        System.debug('FJP sObject 2');
                        System.debug('FJP opportunities need to updated with invoice id.');
                        Id oppId = ApexPages.currentPage().getParameters().get('id');
                        If (oppId !=null){
                            List<Opportunity> oppsList = [SELECT Id, Latest_Invoice__c FROM Opportunity WHERE Id = :oppId];
                            for (Opportunity indOpp : oppsList){
                                indOpp.Latest_Invoice__c = result.Id;
                                System.debug('FJP Updating opportunity Latest invoice: '+result.Id+' = '+indOpp);
                                update indOpp;
                                System.debug('FJP Opp: '+indOpp);
                            }
                        }
                    }
                    
                    
                    c2g__codaInvoice__c updateInvoice = [Select c.Id,c.c2g__CustomerReference__c From c2g__codaInvoice__c c where c.Id =:result.Id];
                    update updateInvoice;
                    
                    return new PageReference('/'+result.Id);
                }
                
            }catch(Exception e)
            {
                if(result!=null)
                { 
                  return new PageReference('/'+result.Id);
                  
                }else{
                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()); 
                  ApexPages.addMessage(myMsg);
                }
            }
        }
        return null;  

    }
    
    //Reset the view to the default view
    public PageReference defaultView()
    {
        if(!accontExtList.isEmpty())
        {
            Integer j = 1;
            for(Integer i=1;i< accontExtList.size();i++)
            {
                accontExtList.get(i).clear();
            }
            while(j <accontExtList.size())
            {
                accontExtList.remove(j);
                j++;    
            }
            if(!defaultOppExtList.isEmpty())
            {   
                accontExtList.get(0).clear();
                accontExtList.get(0).opportunityExtList.addAll(defaultOppExtList);
                //Clear list in order to clear all reference objects
                defaultOppExtList.clear();
                //New list of object copied from the current list
                defaultOppExtList.addAll(copyOpportunityExt(accontExtList.get(0).opportunityExtList));
            }
        }
        
        stage = 'Default';
        return null;
    }
    //Activate the credited view
    public PageReference creditedView()
    {
        
        if(!this.accontExtList.isEmpty())
        {
            for(integer i = 0;i < this.accontExtList.size();i++)
            {
               AccountExt accExt = this.accontExtList.get(i);
               if(i==0 && defaultOppExtList.isEmpty())
                defaultOppExtList.addAll(copyOpportunityExt(accExt.opportunityExtList));
               for(OpportunityExt oppExt :accExt.opportunityExtList)
               {
                  for(OppLineItemExt oppLineItemExt: oppExt.creditOppLineItemExtList)
                  {
                     if(!containsOppLineItem(oppLineItemExt.oppLineItem.Id))
                        oppExt.oppLineItemExtList.add(oppLineItemExt);              
                  }                  
               }
            }                        
        }
        
        
        /*if(stage =='Hierarchy')
            stage = 'hierarchyCredited';
        if(stage!='hierarchyCredited')
            stage = 'Credited';*/
        
        return null;
    }
    //Display the hierarchy view
    public PageReference hierarchyView()
    {
        
        //stage = currentAcc.stage;
        system.debug('@@@'+currentAcc.stage);
        if(stage == 'Default')
        {
            
                
                Set<String> oppLineId = new  Set<String>();
                Set<String> oppId = new  Set<String>();
                //All accounts
                if(this.currentAcc.acc.Ultimate_Parent__c!=null)
                {
                    
                    for(Account acc:[Select Name,
                                            (Select Id,
                                                    Name,
                                                    CloseDate,
                                                    OwnerId, 
                                                    Owner.Name,
                                                    Purchase_Order_Reference__c,
                                                    AccountId 
                                                    from Opportunities
                                                   where (IsClosed = true 
                                                    or StageName = 'Part Invoiced'))
                                             from Account
                                             where Ultimate_Parent__c =:this.currentAcc.acc.Ultimate_Parent__c
                                             and Id!=:this.currentAcc.acc.Id ])
                    {
                    
                        if(!containsAccount(acc.Id))
                            this.accontExtList.add(new AccountExt(acc));
                        
                    }
                   
                    //All opportunities
                    if(!this.accontExtList.isEmpty())
                    {
                       for(AccountExt accExt:this.accontExtList)
                       {
                          
                          if(accExt.acc.Id != currentAcc.acc.Id /*&& accExt.opportunityExtList.isEmpty()*/)
                          {   
                              
                              for(Opportunity opp :accExt.acc.Opportunities)
                              {
                                  //throw new Test_Exception('done');
                                  oppId.add(opp.Id);
                                  accExt.opportunityExtList.add(new OpportunityExt(opp));
                              }
                          }
                       } 
                                    
                        //All Opportunity line items
                        for(OpportunityLineItem oppLineItem:[Select Id,
                                                                PriceBookEntry.Product2.Name,
                                                                PriceBookEntry.Product2Id, 
                                                                OpportunityId,
                                                                Quantity,
                                                                Set_an_Invoice_Quantity__c, 
                                                                Quantity_Invoiced__c,
                                                                Quantity_Credited__c,
                                                                PricebookEntry.Product2.Dimension_1__c,
                                                                PricebookEntry.Product2.Dimension_2__c,
                                                                PricebookEntry.Product2.Renewal_Dimension_2__c,
                                                                UnitPrice from OpportunityLineItem
                                                                where OpportunityId IN:oppId])
                         {
                            
                            for(AccountExt accExt:this.accontExtList)
                            {
                                for(OpportunityExt oppExt :accExt.opportunityExtList)
                                {
                                    if(oppLineItem.OpportunityId == oppExt.opp.Id)
                                    
                                    {   
                                        //Can be invoiced
                                        if(oppLineItem.Quantity_Invoiced__c == null)
                                        {
                                            oppLineId.add(oppLineItem.Id);
                                            oppExt.oppLineItemExtList.add(new oppLineItemExt(oppLineItem));
                                        }
                                        else
                                        {
                                            if(oppLineItem.Quantity - oppLineItem.Quantity_Invoiced__c > 0)
                                            {
                                                oppLineId.add(oppLineItem.Id);
                                                oppExt.oppLineItemExtList.add(new oppLineItemExt(oppLineItem));
                                            }
                                        }
                                        //Credited opportunity line item
                                        if(oppLineItem.Quantity_Credited__c!=null && oppLineItem.Quantity_Credited__c > 0)
                                        {   
                                            oppExt.creditOppLineItemExtList.add(new oppLineItemExt(oppLineItem));
                                            if(!oppLineId.contains(oppLineItem.Id)) 
                                                oppLineId.add(oppLineItem.Id);
                                        } 
                                    }
                                } 
                       
                            } 
                            
                         }
                         
                         
                        populateBookingList(oppLineId);
                        populateSubsLineList(oppLineId);
                
                } 
                
                }
            
            
             stage = 'Hierarchy';   
        }
        return null;
    }
    

    
    public class AccountExt
    {
        public Account acc {get;private set;}
        public List<OpportunityExt> opportunityExtList {get; private set;}
        public String stage {get;private set;}
        public boolean selected {get;set;}
        
        
        
        public AccountExt (Account acc)
        {
            this.acc = acc;
            opportunityExtList = new List<OpportunityExt>();
            this.selected = false;
        }
        //Clear all list
        public void clear()
        {
            if(!opportunityExtList.isEmpty())
            {
               for(OpportunityExt oppExt :opportunityExtList)
               {
                    oppExt.clear();
               }
               
                opportunityExtList.clear();              
            }
        }
        
    }

    public class OpportunityExt
    {
        public Opportunity opp {get;private set;}
        public boolean selected {get;set;}
        
        public List<OppLineItemExt>  oppLineItemExtList{get;set;}
        public List<OppLineItemExt>  creditOppLineItemExtList{get;set;}
        
        public OpportunityExt(Opportunity opp)
        {
            this.opp = opp;
            this.oppLineItemExtList = new List<OppLineItemExt>();
            this.creditOppLineItemExtList = new List<OppLineItemExt>();
            String strUse121 = ApexPages.currentPage().getParameters().get('use121');
            if (strUse121 == null){
                strUse121 = 'false';
            }
            
            if (strUse121.equals('true')){
                this.selected = true;
            }else{
                this.selected = false;
            }

            
        }
        //Clear all list
        public void clear()
        {
            if(!oppLineItemExtList.isEmpty())
            {
                for(OppLineItemExt oppLineItemExt: oppLineItemExtList)
                {
                    oppLineItemExt.clear();
                }
                oppLineItemExtList.clear(); 
            }
            
            if(!creditOppLineItemExtList.isEmpty())
            {
                for(OppLineItemExt oppLineItemExt: creditOppLineItemExtList)
                {
                    oppLineItemExt.clear();
                }
                creditOppLineItemExtList.clear(); 
            }
            
        }
    }
    
    
    public class OppLineItemExt
    {
        public OpportunityLineItem oppLineItem {get;private set;}
        public list<BookingExt> bookingExtList {get;set;}
        public list<SubscriptionLineExt> subscriptionLineExtList{get;set;}
        public Integer bookingLength {get{return bookingExtList.size(); } private set;}
        public Integer subsLineLength {get{return subscriptionLineExtList.size(); } private set;}
        public boolean selected {get;set;}
        
        public OppLineItemExt(OpportunityLineItem oppLineItem)
        {
            bookingExtList = new list<BookingExt>();
            subscriptionLineExtList = new List<SubscriptionLineExt>();

            String strUse121 = ApexPages.currentPage().getParameters().get('use121');
            if (strUse121 == null){
                strUse121 = 'false';
            }
            if (strUse121.equals('true')){
                this.selected = true;
            }else{
                this.selected = false;
            }
            this.oppLineItem = oppLineItem;
        }
        //Clear all list
        public void clear()
        {
            subscriptionLineExtList.clear();
            bookingExtList.clear();
        }
    }

    
    
    //Customize booking event object
    public class SubscriptionLineExt
    {
        public Subscription_Line__c  subsLine {get; private set;}
        public boolean selected {get;set;}
        
        public SubscriptionLineExt(Subscription_Line__c susbLine)
        {
            this.subsLine = susbLine;
            String strUse121 = ApexPages.currentPage().getParameters().get('use121');
            if (strUse121.equals('true')){
                this.selected = true;
            }else{
                this.selected = false;
            }
        }       
    }
    
    //Customize booking event object
    public class BookingExt
    {
        public Special_Event_Booking__c bookingEvt{get; private set;}
        public boolean selected {get;set;}
        
        public BookingExt(Special_Event_Booking__c bookingEvt)
        {
            this.bookingEvt = bookingEvt;
            String strUse121 = ApexPages.currentPage().getParameters().get('use121');
            if (strUse121.equals('true')){
                this.selected = true;
            }else{
                this.selected = false;
            }
        }       
    }

    public testmethod static void testGenerateInvoiceController()
    {
    
        Account acc = new Account (
            Name = 'Test Acc',
            Phone = '00000'
            );
        insert acc;
        
        Contact contact = new Contact (
            Active__c = True,
            Email = 'bsc+testscriptemail@netstronghold.com',
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            MailingCountry = 'United Kingdom',
            Title = 'Mr',
            AccountId = acc.Id
        );
        insert contact;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Test Opp',
            StageName = 'Negotiation',
            IC_Price_Variation_Approved__c = true,
            CloseDate = System.today());
        insert opp;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = opp.Id,
            IsPrimary = true
        );
        
        insert oppContRole;

        Product2 prod = new Product2(
            Name = 'Test Event Product',
            Allows_Provisional_Bookings__c = true);
        insert prod;
        
        Pricebook2 stdPricebook = [
            SELECT
                Id
            FROM
                Pricebook2
            WHERE
                IsStandard = true Limit 1];
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            UnitPrice = 300,
            Pricebook2Id = stdPricebook.Id,
            IsActive = true);
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Pricing_Exception__c = true,
            Quantity = 3,
            UnitPrice = 320);
        insert oli;
        
        
        Special_Event__c event = new Special_Event__c(
            Opportunity__c = opp.Id,
            Name = 'Test Event',
            Type__c = 'In-Company Training',
            Status__c = 'Anything but Confirmed',
            Stage__c = 'Anything but Provisional',
            Product__c = prod.Id,
            City__c = 'London',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        insert event;

        Special_Event_Booking__c[] bookings = new Special_Event_Booking__c[3];
        
        for (Integer i = 0; i < 3; i++)
        {       
            bookings[i] = new Special_Event_Booking__c(
                Opportunity__c = opp.Id,
                
                Booking_Fee__c = (i == 0 ? 10000 : 0),
                Special_Event__c = event.Id);
        }
        insert bookings;        
        // *** START TEST ***
        Test.startTest();
        
        PageReference pageRef = new PageReference('view');
        
        pageRef.getParameters().put('id',opp.Id);
        pageRef.getParameters().put('use121','false');
        
        Test.setCurrentPageReference(pageRef);
        GenerateInvoiceController ctr = new GenerateInvoiceController();
        GenerateInvoiceController.isTest = true;
        for(OpportunityExt oppExt:ctr.currentAcc.opportunityExtList)
        {
            for(OppLineItemExt oppLineExt:oppExt.oppLineItemExtList)
            {
                oppLineExt.selected = true;
            }
        }
        ctr.createInvoice(); 
        ctr.hierarchyView();
        ctr.creditedView();
        ctr.defaultView();
        
        pageRef.getParameters().put('id',opp.AccountId);
        Test.setCurrentPageReference(pageRef);
        GenerateInvoiceController ctr2 = new GenerateInvoiceController();
        
        Test.stopTest();
        // *** END TEST ***
        
    }

}