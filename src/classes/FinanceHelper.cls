global without sharing class FinanceHelper { 

    //static Map<Id,Boolean> OPP_STATUS;
    static final String DEFAULT_DIMENSION_1_NAME = '510 - Sales Management';
    static final String FF_COMPANY_NAME_CONTEXT = 'British Safety Council';
    static final Boolean isTest = false;
    static final Integer POST_INVOICE_IN = 50; // The number of days from creation of invoice to when invoice is due
    static Map<String,Id> dimCodes {get; set;}
    
    public class myException extends Exception{}
    
    /*
     * USE ONE TO ONE INVOICING 
     *
     * Determines if the opportunity should be using one to one invoicing. 
     * This does not check to see if it should be invoiced only that it is part of the new one 2 one system.
     *
     */
    webService static Boolean useOneToOneInvoicing(Id opportunityId){
        Boolean result = false;
        List<Id> oppIds = new List<Id>();
        oppIds.add(opportunityId);
        
        return useOneToOneInvoicing(oppIds).get(opportunityId);
    }

    /*
     * USE ONE TO ONE INVOICING
     *
     * Determines if the opportunity should be using one to one invoicing. 
     * This does not check to see if it should be invoiced only that it is part of the new one 2 one system.
     *
     * @todo Cache the results so if the same opp is checked just return the result from memory.
     */
    public static Map<Id,Boolean> useOneToOneInvoicing(List<Id> oppIds){

        Map<Id,Boolean> result = new Map<Id,Boolean>();
        
        // Get the custom setting for the one to one start date time.
        Feature_Settings__c fs = Feature_Settings__c.getInstance();
        Datetime startDate = fs.One_to_One_Invoicing_Start_Date__c;
        
        
        if (oppIds.size() > 0){
        
            for (Opportunity opp : [
                                    SELECT 
                                        Id, 
                                        CreatedDate, 
                                        Use_part_invoicing__c 
                                    FROM 
                                        Opportunity 
                                    WHERE 
                                        Id IN :oppIds]){
                
                System.debug('Sys Date: '+startDate);
                System.debug('Opp Date: '+opp.CreatedDate);
                if (opp.CreatedDate > startDate && opp.Use_part_invoicing__c == False){
                    result.put(opp.Id,true);
                    //OPP_STATUS.put(opp.Id,true);
                }else{
                    result.put(opp.Id,false);
                    //OPP_STATUS.put(opp.Id,false);
                }
            }
        }
        
        return result;
    }

    /*
     * USER IN CORRECT FINANCIAL FORCE COMPANY
     *
     * Check to see if the current user has the company selected or not.
     */
    webService static Boolean usrInCorrectFFCompany(String company){
        
        Boolean found = false;
        List<String> usrCurrentCompanyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
        for (String comp : usrCurrentCompanyName){
            if (comp == company){
                found = true;
            }
        }
        return found;
    }
    
    /*
     * UPDATE CREDITED STATUS ON OPP
     *
     * If a credit note is posted and matches the invoice net value mark the invoice as fully credited and
     * if "Finance to Credit Opp" is true on the opportunity make it false.
     *
     */
    public static List<c2g__codaInvoice__c> updateCreditedStatus(List<c2g__codaCreditNote__c> creditNotes){
        
        List<Id> invIdsToUpd = new List<Id>();
        Map<Id,Double> cnNetTotals = new Map<Id,Double>();
        
        // Checks to make sure the credit notes are posted & match the invoice amount.
        for (c2g__codaCreditNote__c cn : creditNotes){
            if(cn.c2g__CreditNoteStatus__c == 'Complete'){
                invIdsToUpd.add(cn.c2g__Invoice__c);
            }
        }
        
        List<c2g__codaInvoice__c> invsToUpd = new List<c2g__codaInvoice__c>([SELECT
                                            Id,
                                            Is_Credited_In_Full__c,
                                            c2g__Opportunity__c
                                        FROM
                                            c2g__codaInvoice__c
                                        WHERE
                                            Is_Credited_In_Full__c = false AND
                                            Id IN:invIdsToUpd]);

        List<Id> oppIdsToUpd = new List<Id>();
        
        for(c2g__codaInvoice__c inv : invsToUpd){
            inv.Is_Credited_In_Full__c = true;
            oppIdsToUpd.add(inv.c2g__Opportunity__c);
        }
        
        List<Opportunity> oppsToUpd = new List<Opportunity>([SELECT 
                                                                Id, 
                                                                Finance_to_Credit_Opp__c,
                                                                Using_one_to_one_invoicing__c,
                                                                StageName
                                                            FROM 
                                                                Opportunity 
                                                            WHERE 
                                                                Id IN:oppIdsToUpd]);
        
        System.debug(oppsToUpd);
        for(Opportunity opp : oppsToUpd){
            if (opp.Finance_to_Credit_Opp__c == true){
                opp.Finance_to_Credit_Opp__c = false;
            }
            if (opp.Using_one_to_one_invoicing__c == 'Yes'){
                opp.StageName = 'Credited';
            }
        }
        
        if (invsToUpd.size() > 0){
            update invsToUpd;
        }
        if (oppsToUpd.size() > 0){
            update oppsToUpd;
        }
        
        return invsToUpd;
    }

    /*
     *
     *
     */
    public static String updateOppLineCreditQty(List<c2g__codaCreditNote__c> oldCreditNotes, List<c2g__codaCreditNote__c> newCredtNotes){
        
        List<Id> creditNotesToUpd = new List<Id>();
        
        /*
        for (Integer i = 0; i < oldCreditNotes.size(); i++) {
            if (oldCreditNotes.c2g__CreditNoteStatus__c != 'Complete' && newCreditNotes.c2g__CreditNoteStatus__c == 'Complete'){
                creditNotesToUpd.add(newCreditNotes.Id);
            }
        }
        
        if (creditNotesToUpd.size() > 0){
            List<c2g__codaCreditNote__c> creditNotes = new List<c2g__codaCreditNote__c>([
                                                                SELECT
                                                                    c2g__Invoice__r.]);
        }
        */
        
        return 'feck';
        
    }
    
        
    /*
     * CREATE INVOICE FROM OPP
     *
     * Creates an invoice based on an Opportunity Id
     */
    public static Id createInvoiceFromOpp(Id oppId, Boolean postInvoice){
        
        //setDefaultValues();
        
        Boolean errorOccurred = false;
        Boolean hadQtyOverZero = false;
        Id proformaId;
        
        Opportunity opp = [SELECT Id,
                                    Amount,
                                    AccountId,
                                    Latest_Invoice__c,
                                    Subscription_Start_Date__c,
                                    Create_Invoice__c,
                                    Finance_to_Credit_Opp__c,
                                    Finance_to_Invoice_Opp__c,
                                    Subscription__c
                                FROM
                                    Opportunity
                                WHERE
                                    Id = :oppId
                                LIMIT 1][0];
        
        System.debug('Opportunity to create invoice for: '+opp.Id+' for the amount: '+opp.Amount);
        // Check that opportunities exist and have an amount greater than 0:        
        Double totalOppAmount = opp.Amount;

        if(opp.Amount == 0 || opp.Amount == null){
            errorOccurred = true;
        }
        
        //Savepoint sp = Database.setSavepoint();
        
        c2g.CODAAPICommon.Reference result;
        Set<String> invoiceDescription = new Set<String>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<OpportunityLineItem> updateOppLineItemList = new List<OpportunityLineItem>();
        //Webservice reference invoice 
        c2g.CODAAPIInvoiceTypes_7_0.Invoice invoice = new c2g.CODAAPIInvoiceTypes_7_0.Invoice();
        invoice.InvoiceDate = Date.today();
        invoice.PrintedText1AllowEdit = false;
        invoice.PrintedText2AllowEdit = false;
        invoice.PrintedText3AllowEdit = false;
        invoice.PrintedText4AllowEdit = false;
        invoice.PrintedText5AllowEdit = false;
        invoice.Usepartperiods = false;
        invoice.InvoiceDescription = ''; // @todo should be purchase order number from customer
        
        if (opp.Subscription_Start_Date__c < Date.today()){
            invoice.DueDate = Date.today();
        }else{
            invoice.DueDate = opp.Subscription_Start_Date__c;
        }
        
        invoice.InvoiceStatus = c2g.CODAAPIInvoiceTypes_7_0.enumInvoiceStatus.InProgress;
        // invoice.Account is NOT the salesforce account object but the FF account (custom FF object record).
        invoice.Account = new c2g.CODAAPICommon.Reference();
        invoice.LineItems = new c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItems();
        invoice.LineItems.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem>();
        invoice.Opportunity = new c2g.CODAAPICommon.Reference();
        invoice.Opportunity.Id = opp.Id;
        
        // Need to update the quantity invoiced on the opp line to create a list to add lines to, to be updated. 
        List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
        
        // Create Line Items for invoice
        Double totalOppLineAmount = 0.0;
        
        //LineDescription = oppLineItemExt.oppLineItem.Id+';'+subsLineExt.subsLine.Id;
        // Get Subscription lines for opp and add them to line description if required.
        
        Map<Id,Id> oppLineSubLineMap = getOppLineSubLineMap(opp);
        Boolean hasPostInvoiceProduct = false;
        
        for(OpportunityLineItem oppLineItem:[SELECT Id,
                                                Opportunity.AccountId,
                                                Opportunity.Account.c2g__CODADimension1__c,
                                                Opportunity.Tax_Code__c,
                                                PricebookEntry.Product2.Name,
                                                PricebookEntry.Product2Id,
                                                PricebookEntry.Product2.Dimension_2__c,
                                                PricebookEntry.Product2.Web_Dimension_2__c,
                                                PricebookEntry.Product2.Renewal_Dimension_1__c,
                                                PricebookEntry.Product2.Renewal_Dimension_2__c,
                                                PricebookEntry.Product2.Auto_Post_Invoice__c,
                                                OpportunityId,
                                                Quantity,
                                                Set_an_Invoice_Quantity__c, 
                                                Quantity_Invoiced__c,
                                                Quantity_Credited__c,
                                                Website_Tax_Percentage__c,
                                                TotalPrice,
                                                Website_Tax_Amount__c,
                                                UnitPrice,
                                                Opportunity.ownerID,
                                                Opportunity.Subscription__c,
                                                Opportunity.Subscription__r.Includes_E_Delivery_Product__c,
                                                Opportunity.Subscription__r.Account_Name__r.E_Delivery_Subscriber__c,
                                                Opportunity.Subscription__r.Consolidated_Subscription__c,
                                                Opportunity.Website_Order_Id__c,
                                                Opportunity.Type
                                            FROM 
                                                OpportunityLineItem
                                                WHERE Opportunity.Id = :opp.Id])
        {
            if (oppLineItem.PriceBookEntry.Product2.Auto_Post_Invoice__c){
                hasPostInvoiceProduct = true;
            }
            
            Double quantity = 0;
            
            
            if(oppLineItem.Set_an_Invoice_Quantity__c == null)
            {
                if(oppLineItem.Quantity_Invoiced__c == null)
                    oppLineItem.Quantity_Invoiced__c = 0;
                if(oppLineItem.Quantity_Credited__c == null)
                    oppLineItem.Quantity_Credited__c = 0;

                quantity = oppLineItem.Quantity - oppLineItem.Quantity_Invoiced__c + oppLineItem.Quantity_Credited__c;
            }   
            else{ 
                quantity = oppLineItem.Set_an_Invoice_Quantity__c;
            }
            System.debug('Qty: '+quantity);
            if (quantity != 0){
                
                System.debug('Creating invoice line');
                c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem lineItem = new c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem();
                lineItem.Product = new c2g.CODAAPICommon.Reference();
                lineItem.Product.Id = oppLineItem.PriceBookEntry.Product2Id;
                lineItem.Quantity = quantity;
                lineItem.UnitPrice = oppLineItem.UnitPrice;
                
                lineItem.Usepartperiods = false;
                            
                Id subLineId = oppLineSubLineMap.get(oppLineItem.Id);
                if (subLineId == null){
                    // No subline exists:
                    lineItem.LineDescription = oppLineItem.Id+';void';
                }else{
                    // Subline exists and 
                    lineItem.LineDescription = oppLineItem.Id+';'+subLineId;
                }
                
                if (oppLineItem.PriceBookEntry.Product2.Renewal_Dimension_1__c != null){
                    // OPT-759: Use the Renewal Dimension 1 code if its filled out on the product.
                    lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                    lineItem.Dimension1.Id = oppLineItem.PriceBookEntry.Product2.Renewal_Dimension_1__c;
                }else{
                    if(InvoiceHelper.getDimension1CodeFromOwner(oppLineItem.Opportunity.OwnerId) != null){
                        lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                        lineItem.Dimension1.Id = InvoiceHelper.getDimension1CodeFromOwner(oppLineItem.Opportunity.OwnerId);         

                    // Otherwise use the default Dimension 1 code
                    }else{ 
                        lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                        List<c2g__codaDimension1__c> dimension1 = [Select c.Name, c.Id From c2g__codaDimension1__c c WHERE c.Name = :DEFAULT_DIMENSION_1_NAME LIMIT 1];
                        lineItem.Dimension1.Id = dimension1[0].Id;
                    }
                }
                
                // Dimension 2 = Product Dimension code.
                lineItem.Dimension2 = new c2g.CODAAPICommon.Reference();
                lineItem.Dimension2.Id = getDim2Code(oppLineItem);
                system.debug('Opp dimension 2'+  getDim2Code(oppLineItem) + ' end');
                hadQtyOverZero = true;
                invoice.LineItems.LineItemList.add(lineItem);
            } else {
                errorOccurred = true;
                Error_Log__c err = new Error_Log__c();
                err.Function__c = 'FinanceHelper.createInvoiceFromOpp('+oppId+', '+postInvoice+')';
                err.Severity__c = 'Message';
                err.Debug_Text__c = 'could not find opp lines to invoice quantity - invoiced + credited = 0. Check!' + oppid;
                insert err;
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(err.Function__c);
                mail.setPlainTextBody(err.Debug_Text__c);
                mail.setToAddresses(new list<string>{'salesforcealerts@britsafe.org'});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }

            invoice.Account.Id = oppLineItem.Opportunity.AccountId;
            System.debug('opplineItem.Opp.AccountId: '+oppLineItem.Opportunity.AccountId);
            
        }
        // Update OppLines
        //update oppLinesToUpdate;

        //Specify the company to consider
        c2g.CODAAPICommon_7_0.Context context = new c2g.CODAAPICommon_7_0.Context();
        if(!isTest)
        {
            List<String> usrCurrentCompanyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
            Opportunity oppCompanyName = [SELECT Invoice_Company__r.Name FROM Opportunity WHERE Id = :invoice.Opportunity.Id][0];
            if (oppCompanyName.Invoice_Company__r.Name == null){
                context.CompanyName = usrCurrentCompanyName.get(0);
            }else{
                context.CompanyName = oppCompanyName.Invoice_Company__r.Name;
                //context.CompanyName = 'British Safety Council';
            }

        }

        try {
            if (errorOccurred == false){

                result=c2g.CODAAPISalesInvoice_7_0.CreateInvoice(context, invoice);
                proformaId = result.Id;

                if (hadQtyOverZero == false){
                    Error_Log__c err = new Error_Log__c();
                    
                    err.Function__c = 'FinanceHelper.createInvoiceFromOpp('+oppId+', '+postInvoice+')';
                    err.Severity__c = 'Message';
                    err.Debug_Text__c = 'Created proforma invoice ('+proformaId+') but invoice may not have any invoice lines. Check!';
                    
                    insert err;
                }

                
                if (postInvoice && hasPostInvoiceProduct){
                    
                    //List<c2g.CODAAPICommon.Reference> refs = new List<c2g.CODAAPICommon.Reference>();
                    c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
                    ref.Id = result.Id;
                    //refs.add(ref);
                    c2g.CODAAPISalesInvoice_7_0.PostInvoice(context, ref);

                }else{
                                   // Invoice is not being posted immediatly so update post invoice field.
                    try {
                        if (errorOccurred == false){
                            c2g__codaInvoice__c updateInvoice = [Select c.Id,c.c2g__CustomerReference__c From c2g__codaInvoice__c c where c.Id =:result.Id];
                            updateInvoice.Post_Invoice_at__c = datetime.now()+POST_INVOICE_IN;
                            update updateInvoice;
                        }
                        
                    }catch(Exception e){
                        // error occurred populate error object.
                        System.debug('Update Invoice Error: '+e.getMessage());
                        
                        Error_Log__c err = new Error_Log__c();
                        err.Function__c = 'FinanceHelper.createInvoiceFromOpp('+oppId+', '+postInvoice+')';
                        err.Severity__c = 'High';
                        err.Debug_Text__c = 'Unable to update invoice ('+proformaId+') with post date: '+datetime.now()+POST_INVOICE_IN+'. ERROR: '+e.getMessage();                 
                        insert err;
                        
                        errorOccurred = true;
                    }

                }
                
            }
        }catch(Exception e){
            // error occurred populate error object.
            Error_Log__c err = new Error_Log__c();
            err.Function__c = 'FinanceHelper.createInvoiceFromOpp('+oppId+', '+postInvoice+')';
            err.Severity__c = 'High';
            err.Debug_Text__c = 'Create Invoice Error: '+e.getMessage();                    
            insert err;
            System.debug('Create Invoice Error: '+e.getMessage());
            errorOccurred = true;
        }

        if (errorOccurred == false){
            opp.Latest_Invoice__c = result.Id;
            if (opp.Create_Invoice__c == true){
                opp.Create_Invoice__c = false;
            }
            if (opp.Finance_to_Invoice_Opp__c == true){
                opp.Finance_to_Invoice_Opp__c = false;
            }
            if (postInvoice && hasPostInvoiceProduct && opp.Finance_to_Credit_Opp__c == True){
                opp.Finance_to_Credit_Opp__c = false;
            }
            update opp;
            
            // Update latest invoice on sub if a sub was invoiced.
            List<Subscription__c> sub = new List<Subscription__c>([SELECT Renewal_Sales_Invoice__c FROM Subscription__c WHERE Id = :opp.Subscription__c]);
            if (sub.size() > 0){
                sub[0].Renewal_Sales_Invoice__c = proformaId;
                update sub;
            }
        }
        
        System.debug('Create Subscription Renewal Invoice finished');

        return proformaId;
    }
    
    /*
     * GET DIMENSION 2 CODE
     *
     * Determines the dimension 2 code to use for an invoice line based on an oppLine.
     */
    public static Id getDim2Code(OpportunityLineItem lineItem){
        
        Id dim2Code = null;
        if (dimcodes == null){
            dimCodes = new Map<String,Id>();
        }
        if (lineItem.Opportunity.Website_Order_Id__c !=null && lineItem.PriceBookEntry.Product2.Web_Dimension_2__c !=null){
            System.debug('Opp is a website order and has a web dimension 2 code');
            dim2Code = lineItem.PriceBookEntry.Product2.Web_Dimension_2__c;
        
        }else if (lineItem.Opportunity.Type == 'Subscription Renewal' && lineItem.PriceBookEntry.Product2.Renewal_Dimension_2__c !=null){
            System.debug('Opp Line is a renewal so using default DIM2 code from product');
            dim2Code = lineItem.PriceBookEntry.Product2.Renewal_Dimension_2__c;
            
        }else if (lineItem.Opportunity.Subscription__r.Includes_E_Delivery_Product__c == true && lineItem.Opportunity.Subscription__r.Consolidated_Subscription__c == true && lineItem.Opportunity.Subscription__r.Account_Name__r.E_Delivery_Subscriber__c == true){
            System.debug('Opp Line is an LMS Consolidation (8030)');
            dim2Code = getCachedDim('8030');
            
        }else if (lineItem.Opportunity.Subscription__r.Includes_E_Delivery_Product__c == true && lineItem.Opportunity.Subscription__r.Account_Name__r.E_Delivery_Subscriber__c == true && lineItem.Opportunity.Subscription__r.Consolidated_Subscription__c == false){
            System.debug('Opp Line is an existing customer which isnt an LMS Consolidation (8025)');
            dim2Code = getCachedDim('8025');
            
        }else if (lineItem.Opportunity.Subscription__r.Includes_E_Delivery_Product__c == true && lineItem.Opportunity.Subscription__r.Account_Name__r.E_Delivery_Subscriber__c == false && lineItem.Opportunity.Subscription__r.Consolidated_Subscription__c == false){
            System.debug('Opp Line is a new LMS customer');
            dim2Code = getCachedDim('8020');
        }else{
            // Use dem 2 on product
            System.debug('Using default Dim 2 code');
            dim2Code = lineItem.PriceBookEntry.Product2.Dimension_2__c;
        }
        return dim2Code;
    }
    
    /*
     *
     */
    public static Id getCachedDim(String dimCode){
        
        Id dimCodeResult = null;
        
        if (dimCodes != null && dimCodes.containsKey(dimCode)){
            System.debug('Found cached DIM code '+dimCode);
            dimCodeResult = dimCodes.get(dimCode);
        }else{
            List<c2g__codaDimension2__c> DimCodeLst = new List<c2g__codaDimension2__c>([SELECT Id FROM c2g__codaDimension2__c WHERE c2g__ReportingCode__c = :dimCode]);
            if (DimCodeLst.size() != 1){
                throw new myException('Unable to find Dimension 2 with the reporting code '+dimCode);
            }else{
                System.debug('Unable to find cached DIM code so searched and found '+dimCode+' from db');

                dimCodeResult = DimCodeLst[0].Id;
                // Cache DimCode:
                dimCodes.put(dimCode,DimCodeLst[0].Id);
            }
        }
        return dimCodeResult;
    }
    
    /*
     * GET OPPORTUNITY LINE AND SUBSCRIPTION LINE OPPORTUNITY MAP
     *
     * Returns a map which links opportunity lines to subscription lines
     *
     * Returns: map<OpportunityLineId,SubscriptionLineId>
     */
    public static Map<Id,Id> getOppLineSubLineMap(Opportunity opp){
        
        //setDefaultValues();
        
        // Get Subscriptions on opportunity
        Set<Id> subsList = new Set<Id>();
        if (opp.Subscription__c !=null){
            subsList.add(opp.Subscription__c);
        }
        for(Subscription__c sub : [SELECT Id FROM Subscription__c WHERE opportunity__c = :opp.Id]){
            subsList.add(sub.Id);
        }
        
        Map<Id,Id> oppLineSubLineList = new Map<Id,Id>();
        
        for (Subscription_Line__c subLine : [SELECT
                Id,
                OPL_ID__c
            FROM
                Subscription_Line__c
            WHERE
                Subscription__c IN :subsList]){
            
            if (subLine.OPL_ID__c !=null){
                oppLineSubLineList.put(subLine.OPL_ID__c,subLine.Id);
            }
            
        }
        
        return oppLineSubLineList;
    }
    
    
    /*
     * POST FINANCIALFORCE INVOICE
     *
     * This assumes that the user is in the correct company and has the company selected or is Multi-mode.
     */
    public static Boolean postInvoice(Id salesInv){
        
        List<Id> invoiceList = new List<Id>();
        invoiceList.add(salesInv);
        
        return postInvoice(invoiceList);
    }
    
    
    /*
     * BULK POST FINANCIALFORCE INVOICE
     *
     * This assumes that the user is in the correct company and has the company selected or is Multi-mode.
     * 
     */
    public static Boolean postInvoice(List<Id> salesInvs){
        // Build list of invoice references
        List<c2g.CODAAPICommon.Reference> refs = new List<c2g.CODAAPICommon.Reference>();
        for(ID id : salesInvs)
        { 
            c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
            ref.Id = id;
            refs.add(ref);
        }
        
        // Call FinancialForce API to bulk post given invocies (users current company)
        c2g.CODAAPISalesInvoice_3_0.BulkPostInvoice(null, refs);
        
        return true;
            
    }

    /*
    @isTest(SeeAllData=true)
    public static void testFinanceCreditNote()
    {
        List<c2g__codaCreditNote__c> cshmchLst = new List<c2g__codaCreditNote__c>([Select Id From c2g__codaCreditNote__c WHERE c2g__CreditNoteStatus__c = 'In Progress' ORDER BY CreatedDate DESC Limit 1]);
        update cshmchLst;
    }
    */
    
    /*
     * CREATE CREDIT NOTEs FROM invoices
     *
     * Creates an creditnotes based on Invoices
     */
     public static List<Id> createCreditNotes(List<id> invoiceIds, boolean postCreditNote){
        
        list<c2g.CODAAPICreditNoteTypes_7_0.CreditNote> creditNotes = new list<c2g.CODAAPICreditNoteTypes_7_0.CreditNote>();
        list<c2g__codaInvoice__c> invoices = new list<c2g__codaInvoice__c>();
        list<id> retList = new list<id>();
        //CREATE CONTEXT FOR FINANCIAL FORCE
        c2g.CODAAPICommon_7_0.Context context = new c2g.CODAAPICommon_7_0.Context();
        if(!isTest){
            List<String> usrCurrentCompanyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
            context.CompanyName = usrCurrentCompanyName.get(0);
            System.debug('Current company '+usrCurrentCompanyName.get(0));
        }
           
        for (c2g__codaInvoice__c invoice : [select  Id 
                                                    ,c2g__Account__c
                                                    ,c2g__InvoiceCurrency__c
                                                    ,c2g__InvoiceDate__c
                                                    ,c2g__Period__c
                                                    ,c2g__OwnerCompany__c
                                                    ,c2g__Dimension1__c
                                                    ,c2g__Dimension2__c
                                                    ,c2g__Opportunity__c
                                                    ,c2g__Opportunity__r.Credit_Note_Reason__c
                                                    ,c2g__Opportunity__r.Credit_Note_Product_Group__c
                                                    ,c2g__Opportunity__r.Product_Delivered__c
                                                    ,c2g__Opportunity__r.Amount
                                                    ,c2g__Opportunity__r.StageName
                                                    ,c2g__InvoiceTotal__c
                                                    ,Name
                                                    ,(SELECT  c2g__Product__c,c2g__Quantity__c,c2g__UnitPrice__c,c2g__Dimension1__c,c2g__Dimension2__c,
                                                              c2g__TaxRate1__c,c2g__TaxRate2__c,c2g__TaxRate3__c,c2g__TaxValue1__c,c2g__TaxValue2__c,c2g__TaxValue3__c,
                                                              c2g__TaxCode1__c,c2g__TaxCode2__c,c2g__TaxCode3__c,c2g__OwnerCompany__c
                                                        FROM c2g__InvoiceLineItems__r)
                                                    from c2g__codaInvoice__c 
                                                    where Id in :invoiceIds]){
            
            c2g.CODAAPICreditNoteTypes_7_0.CreditNote creditNote = new c2g.CODAAPICreditNoteTypes_7_0.CreditNote();
            creditNote.Account = new c2g.CODAAPICommon.Reference();
            creditNote.Account.Id = invoice.c2g__Account__c;
            creditNote.Opportunity = new c2g.CODAAPICommon.Reference();
            creditNote.Opportunity.Id = invoice.c2g__Opportunity__c;
            creditNote.CreditNoteCurrency = new c2g.CODAAPICommon.Reference();
            creditNote.CreditNoteCurrency.Id = invoice.c2g__InvoiceCurrency__c;
            creditNote.InvoiceDate = invoice.c2g__InvoiceDate__c;
            creditNote.Period = new c2g.CODAAPICommon.Reference();
            creditNote.Period.Id = invoice.c2g__Period__c;
            creditNote.OwnerCompany = new c2g.CODAAPICommon.Reference();
            creditNote.OwnerCompany.Id = invoice.c2g__OwnerCompany__c;
            creditNote.CreditNoteStatus = c2g.CODAAPICreditNoteTypes_7_0.enumCreditNoteStatus.InProgress;
            creditNote.CreditNoteDescription = '';
            creditNote.DueDate = Date.Today();
            creditNote.PrintedText1AllowEdit = false;
            creditNote.PrintedText2AllowEdit = false;
            creditNote.PrintedText3AllowEdit = false;
            creditNote.PrintedText4AllowEdit = false;
            creditNote.PrintedText5AllowEdit = false;
            creditNote.Dimension1 = new c2g.CODAAPICommon.Reference();
            creditNote.Dimension1.Id = invoice.c2g__Dimension1__c;
            creditNote.Dimension2 = new c2g.CODAAPICommon.Reference();
            creditNote.Dimension2.Id = invoice.c2g__Dimension2__c;
            creditNote.CreditNoteReason = invoice.c2g__Opportunity__r.Credit_Note_Reason__c;
            creditNote.Invoice = new c2g.CODAAPICommon.Reference();
            creditNote.Invoice.Id = invoice.Id;
            creditNote.CustomerReference = invoice.Name;
            system.debug('Dimension 2 value: ' + invoice.c2g__Dimension2__c + 'end');
            
            creditNote.LineItems = new c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItems();
            creditNote.LineItems.LineItemList = new List<c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItem>();
        
            for (c2g__codaInvoiceLineItem__c invoiceLine : invoice.c2g__InvoiceLineItems__r){
            
                c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItem creditLineItem = new c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItem();
                
                creditLineItem.Product = new c2g.CODAAPICommon.Reference();
                creditLineItem.Product.Id = invoiceLine.c2g__Product__c;
                
                creditLineItem.Quantity = invoiceLine.c2g__Quantity__c;
                creditLineItem.UnitPrice = invoiceLine.c2g__UnitPrice__c;
                
                creditLineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                creditLineItem.Dimension1.Id = invoiceLine.c2g__Dimension1__c;
                
                creditLineItem.Dimension2 = new c2g.CODAAPICommon.Reference();
                creditLineItem.Dimension2.Id = invoiceLine.c2g__Dimension2__c;
                
                creditLineItem.TaxRate1 = invoiceLine.c2g__TaxRate1__c;
                creditLineItem.TaxRate2 = invoiceLine.c2g__TaxRate2__c;
                creditLineItem.TaxRate3 = invoiceLine.c2g__TaxRate3__c;
                
                creditLineItem.TaxValue1 = invoiceLine.c2g__TaxValue1__c;
                creditLineItem.TaxValue2 = invoiceLine.c2g__TaxValue2__c;
                creditLineItem.TaxValue3 = invoiceLine.c2g__TaxValue3__c;
                
                creditLineItem.TaxCode1 = new c2g.CODAAPICommon.Reference();
                creditLineItem.TaxCode2 = new c2g.CODAAPICommon.Reference();
                creditLineItem.TaxCode3 = new c2g.CODAAPICommon.Reference();
                
                creditLineItem.TaxCode1.Id = invoiceLine.c2g__TaxCode1__c;
                creditLineItem.TaxCode2.Id = invoiceLine.c2g__TaxCode2__c;
                creditLineItem.TaxCode3.Id = invoiceLine.c2g__TaxCode3__c;
                
                creditLineItem.OwnerCompany = new c2g.CODAAPICommon.Reference();
                creditLineItem.OwnerCompany.Id = invoiceLine.c2g__OwnerCompany__c;
                
                system.debug('Auto Credit Line Item: ' + creditLineItem);
                
                creditNote.LineItems.LineItemList.add(creditLineItem);
            }
            creditNotes.add(creditnote);
            invoice.Is_Credited_In_Full__c = true;

            invoices.add(invoice);
            
            try{
                c2g.CODAAPICommon.Reference result = c2g.CODAAPISalesCreditNote_7_0.CreateCreditNote(context, creditNote);
                system.debug('VS : Create Creditnote result : ' + result);

                if (postCreditNote == true){
                    list<c2g__codaCreditNote__c> listCreditNotes = new list<c2g__codaCreditNote__c>();
                    for (c2g__codaCreditNote__c cn : [select id from c2g__codaCreditNote__c where id = :result.Id]){
                        cn.Product_Delivered__c = invoice.c2g__Opportunity__r.Product_Delivered__c;
                        cn.Credit_Note_Product_Group__c = invoice.c2g__Opportunity__r.Credit_Note_Product_Group__c;

                        listCreditNotes.add(cn);
                    }
                    update listCreditNotes;
                    
                    boolean errorOccured = false;

                    c2g.CODAAPISalesCreditNote_7_0.PostCreditNote(context,result);
                }
                

                FinanceHelper.InvoiceCreditMatch(invoice.Name, invoice.c2g__Account__c, invoice.c2g__Period__c);
            } catch(Exception e) { 
                
                System.debug('VS Post Creditnote Error: '+e.getMessage() + e.getStackTraceString());
            }
        } 
        if (test.isRunningTest() == false)
            update invoices;
            
        return null;
    }
    
    
    static void InvoiceCreditMatch(string salesInvoiceName, id accountId, id periodId){
        List<string> documentRefs = new List<string>();
        
        List<c2g__codatransactionlineitem__c> transactionLinesToMatch = [select Id, c2g__AccountValue__c from c2g__codaTransactionLineItem__c
                                                                         where c2g__Transaction__r.c2g__DocumentReference__c  = :salesInvoiceName and c2g__LineType__c = 'Account'];
        
        system.debug('transactionLinesToMatch: '+ transactionLinesToMatch);
        
        // Match Invoice with Cash Entry
        c2g.CODAAPICommon_6_0.Context context1 = new c2g.CODAAPICommon_6_0.Context();
        c2g.CODAAPICashMatchingTypes_6_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_6_0.Configuration();
        configuration.Account = c2g.CODAAPICommon.getRef(accountId, null);
        configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_6_0.enumMatchingCurrencyMode.Account; 
        configuration.MatchingDate = System.today();
        configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(periodId, null);
        List<c2g.codaapicashmatchingtypes_6_0.item> items = new List<c2g.codaapicashmatchingtypes_6_0.item>();
        for (c2g__codaTransactionLineItem__c transactionLine : transactionLinesToMatch)
        {
            c2g.CODAAPICashMatchingTypes_6_0.Item item = new c2g.CODAAPICashMatchingTypes_6_0.Item();
            item.TransactionLineItem = c2g.CODAAPICommon.getRef(transactionLine.Id, null);
            item.Paid = transactionLine.c2g__AccountValue__c;
            item.Discount = 0;
            item.WriteOff = 0;
            items.add(item);
            system.debug('--------------------------------------------------item'+item);
        }
        c2g.CODAAPICashMatchingTypes_6_0.Analysis analisysInfo = new c2g.CODAAPICashMatchingTypes_6_0.Analysis();
        c2g.CODAAPICommon.Reference matchReference =  c2g.CODAAPICashMatching_6_0.Match(context1, configuration, items, analisysInfo);
    }

    @isTest(SeeAllData=true)
    public static void testFinanceCreditNote()
    {
        
        Account acc = new Account();
        acc.Name = 'The Company Inc Plc 3668923';
        acc.CurrencyIsoCode = 'GBP';
        acc.Active__c = True;
        acc.Principle_Address_ZIP_Postal_Code__c = 'SW20 999';
        acc.BillingPostalCode = 'SW20 999';
        insert acc;

        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        contact.LastName = 'Test';
        contact.FirstName = 'Account121';
        contact.Email = 'test@testaccount121.com';
        insert contact;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Qualifying';
        opp.CloseDate = System.today();
        opp.AccountId = acc.id;
        opp.Price_Approval_Given__c = true;
        insert opp;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = contact.id;
        oppContRole.OpportunityId = opp.id;
        oppContRole.IsPrimary = true;
        insert oppContRole;
        
        Product2 prod = new Product2();
        prod.Name = 'Test  Product';
        prod.ProductCode = 'TESTCODE1';
        prod.Duration__c='1 Year';
        prod.Subscription_Product__c = true;
        prod.Auto_Post_Invoice__c = true;
        insert prod;
        
        //Pricebook2 stdPricebook = [Select Id From Pricebook2 Where IsStandard = true Limit 1];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 300;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.IsActive = true;
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 120;
        
        insert oli;
         
        
        Special_Event__c specialEvent1 = new Special_Event__c(
            Opportunity__c = opp.Id,
            Name = 'oppcont 1',
            Product__c = prod.Id,
            Type__c = 'In-Company Training',
            Status__c = 'Allocating',
            Stage__c = 'Provisional',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5));
        insert specialEvent1;
        
        /* CREATE BSC EVENT BOOKING*/
        Special_Event_Booking__c specialEventbooking2 = new Special_Event_Booking__c(
            Opportunity__c = opp.Id,
            Booking_Fee__c =  10000,
            Special_Event__c = specialEvent1.Id,
            Type__c = 'Public',
            OPL_ID__c = oli.Id,
            status__c = 'Provisional'
        );
        insert specialEventbooking2; 
        
        specialEvent1.status__c = 'Confirmed';
        update specialEvent1;
        
        specialEventbooking2.status__c = 'Confirmed';
        update specialEventbooking2;
        
        opp.StageName = 'Booking Received';
        update opp;
        
        test.startTest();
        Id inv = FinanceHelper.createInvoiceFromOpp(opp.Id, true);
        c2g__codaInvoice__c invoice = [SELECT 
                                        Id
                                        FROM
                                            c2g__codaInvoice__c
                                        WHERE
                                            Id = :inv][0];        
        
        List<Id> invLst = new List<Id>();
        invLst.add(invoice.Id);
        
        createCreditNotes(invLst, true);
        test.stopTest();
        
    }
    
}