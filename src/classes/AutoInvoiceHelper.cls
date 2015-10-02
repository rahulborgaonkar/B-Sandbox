global without sharing class AutoInvoiceHelper {
 
    static final String DEFAULT_DIMENSION_1_NAME = '510 - Sales Management';
    static final Boolean isTest = false;
    static set<id> subscriptions;
    static Map<Id,list<Subscription_Line__c>> oppLineSubLineList;

    
    public class invoiceException extends Exception{}
    
    public static boolean createInvoiceFromWS = false;
    
    webservice static id wsCreateInvoiceFromOpp(id oppId, string invoiceCompany){
        createInvoiceFromWS = true;
        return bulkCreateInvoiceFromOpps(new list<id>{oppId}, AutoInvoiceSettings.autoPostInvoices, invoiceCompany)[0];
    }
    

    public static list<id> bulkCreateInvoiceFromOpps(list<Id> oppIds, boolean postInvoices, string invoiceCompany){
        
        oppLineSubLineList = new Map<Id,list<Subscription_Line__c>>();
        subscriptions = new set<id>();
        
        list<c2g.CODAAPIInvoiceTypes_9_0.Invoice> invoices = new list<c2g.CODAAPIInvoiceTypes_9_0.Invoice>();
        List<String> usrCurrentCompanyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
        list<string> errors = new list<string>();
        list<id> returnInvoiceId = new list<id>();
        
        List<c2g__codaDimension1__c> dimension1 = [Select c.Name, c.Id From c2g__codaDimension1__c c WHERE c.Name = :DEFAULT_DIMENSION_1_NAME LIMIT 1];
        
        for(id oppId : oppIds){
            oppLineSubLineList.put(oppid,new list<Subscription_Line__c>());
        }
        
        system.debug('oppLineSubLineList 1' + oppLineSubLineList);
        getOppLineSubLineMap(oppIds);
        system.debug('oppLineSubLineList 2' + oppLineSubLineList);
        
        list<Opportunity> opps = [SELECT  Id, Name,
                                        Amount,
                                        AccountId,
                                        Latest_Invoice__c,
                                        Subscription_Start_Date__c,
                                        Create_Invoice__c,
                                        Finance_to_Credit_Opp__c,
                                        Finance_to_Invoice_Opp__c,
                                        Subscription__c,
                                        Invoice_Company__r.Name,
                                        Purchase_Order_Reference__c,
                                        OwnerId,
                                        Type,
                                        StageName,
                                        Do_Not_Auto_Post_SIN_SCR__c,
                                        Exclude_from_Auto_Invoicing__c,
                                        RecordType.Name,
                                        Account.c2g__CODAInvoiceEmail__c,
                                        Account.c2g__CODADaysOffset1__c,
                                        (SELECT  Id,
                                             Opportunity.AccountId,
                                             Opportunity.Account.c2g__CODADimension1__c,
                                             Opportunity.Tax_Code__c,
                                             PricebookEntry.Product2.Name,
                                             PricebookEntry.Product2Id,
                                             PricebookEntry.Product2.Web_Dimension_2__c,
                                             PricebookEntry.Product2.Renewal_Dimension_1__c,
                                             PricebookEntry.Product2.Renewal_Dimension_2__c,
                                             PricebookEntry.Product2.Auto_Post_Invoice__c,
                                             PricebookEntry.Product2.Dimension_1__c,
                                             PricebookEntry.Product2.Dimension_2__c,
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
                                             Opportunity.Type,
                                             Dimension_2__c,
                                             Dimension_1__c
                                        FROM 
                                             OpportunityLineItems),
                                        (Select Status__c, 
                                            Special_Event__r.Status__c,
                                            Special_Event__c, 
                                            Name,
                                            Special_Event__r.Name,
                                            Special_Event__r.Product__c,
                                            Product__c,
                                            Special_Event__r.Product__r.Dimension_1__c,
                                            Special_Event__r.Product__r.Dimension_2__c,
                                            Special_Event__r.Dimension_4__c,
                                            OPL_ID__c, 
                                            Invoice_Status__c, 
                                            Event_Start_Date__c, 
                                            Credited_Status__c, 
                                            Contact__r.FirstName,
                                            Contact__r.LastName, 
                                            Booking_Fee__c,
                                            Transfer_Cancellation_Reason__c
                                        From 
                                            BSC_Event_Bookings__r
                                       where Type__c != 'In-Company Additional')
                                FROM
                                    Opportunity
                                WHERE
                                Id in :oppIds
                               ];
        
        for (Opportunity opp : opps)
        {
            
            System.debug('Opportunity to create invoice for: '+opp.Id+' for  amount: '+opp.Amount);
            
            /*if(opp.Amount == 0 || opp.Amount == null){
                errors.add('Opportunity ' + opp.Name + ' does not have a valid amount' );
            } else {*/

                list<Subscription_Line__c> subLine =  oppLineSubLineList.get(opp.id);
                invoices.add(createInvoice(opp, subline));
                system.debug('bulkCreateInvoiceFromOpps invoices 1' + invoices);
            //}
        }
        
        list<id> invoiceIds = new list<id>();
    
        //stop opp control execution
        execControl.stopOppControls = true;
        //execControl.stopInvoiceTrigger = false;
        
        try{
            c2g.CODAAPICommon_9_0.Context context = new c2g.CODAAPICommon_9_0.Context();
            context.CompanyName = invoiceCompany;
            
            List<c2g.codaapicommon.reference> invoicerefs = c2g.CODAAPISalesInvoice_9_0.BulkCreateInvoice(context, invoices);
            system.debug('invoicerefs '+invoicerefs );
            
            for (c2g.codaapicommon.reference ref : invoicerefs){
                invoiceIds.add(ref.id);
            }
            
            returnInvoiceId = invoiceIds;
                
            if (postInvoices){
                
                List<c2g__codaInvoice__c> invoicesToPost = [select id from c2g__codaInvoice__c where id in :invoiceIds and (c2g__Opportunity__r.Do_Not_Auto_Post_SIN_SCR__c = false or c2g__Opportunity__r.Do_Not_Auto_Post_SIN_SCR__c = null)];
                List<c2g.codaapicommon.reference> invoicerefsToPost = new List<c2g.codaapicommon.reference>();
                
                for (c2g__codaInvoice__c invToPost : invoicesToPost){
                    c2g.codaapicommon.reference r = new c2g.codaapicommon.reference();
                    r.id = invToPost.Id;
                    invoicerefsToPost.add(r);
                }
                
                c2g.CODAAPISalesInvoice_9_0.BulkPostInvoice(null, invoicerefsToPost);
            }
        } catch (Exception e) {
            system.debug('::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::error: ' + e);
            list<string> info = new list<string>();
            info.add(AutoInvoiceSettings.emailNotificationTo);
            list<string>  error = new list<string>();
           
            error.add(string.valueof(e.getLineNumber()));
            error.add(e.getMessage());
            error.add(e.getStackTraceString());
            error.add(e.getTypeName());
            AutoInvoiceHelper.sendMail('Auto Invoice Process Error', 'Unable to Create invoices for following Opps : ' + oppIds + error, info);
            throw new invoiceException(e.getMessage());
            
        }
        
        list<c2g__codaInvoice__c> updateInvoices = [Select c.Id,
                                                           c.c2g__CustomerReference__c, 
                                                           c2g__InvoiceTotal__c, 
                                                           c2g__Opportunity__c, 
                                                           c2g__Opportunity__r.Amount,
                                                           c2g__Opportunity__r.StageName,
                                                           c2g__transaction__c, 
                                                           c2g__PaymentStatus__c, 
                                                           c2g__InvoiceStatus__c, 
                                                           c2g__InvoiceDate__c, 
                                                           name, 
                                                           c2g__OutstandingValue__c
                                                           From c2g__codaInvoice__c c 
                                                           where c.Id in :invoiceIds];
        
        //generating financial transaction records for invoices created
        system.debug('generating financial transaction records for invoices created: ' + updateInvoices);
                                                           
        for (Opportunity opp : opps){
            boolean oppFound = false;
            for (c2g__codaInvoice__c invoice : updateInvoices){
                if (invoice.c2g__Opportunity__c == opp.Id){
                    opp.Latest_Invoice__c = invoice.id;
                    opp.Finance_to_Invoice_Opp__c = false;
                    //opp.StageName = 'Invoiced';
                    
                    AutoInvoiceHistory.createHistory(invoice.c2g__InvoiceTotal__c, invoice.c2g__Opportunity__c, invoice.c2g__Opportunity__r.Amount, invoice.c2g__Opportunity__r.StageName, null, invoice.id, 'Invoiced', 'Invoice', '', opp.Account.c2g__CODAInvoiceEmail__c);
                    oppFound = true;
                    break;
                } else {
                    oppfound = false;
                }
            }
            
            if (oppFound == false){
                AutoInvoiceHistory.createHistory(null, opp.id, opp.Amount, opp.StageName, null, null, 'Failed to Invoice', 'Invoice', 'Failed to Invoice',opp.Account.c2g__CODAInvoiceEmail__c);
            }
        }
        
        list<Subscription__c> subsList = [select id, Opportunity__c from Subscription__c where id in :subscriptions ]; 
        for (Subscription__c sub : subsList){
            for (c2g__codaInvoice__c invoice : updateInvoices){
                if (invoice.c2g__Opportunity__c == sub.Opportunity__c){
                    sub.Renewal_Sales_Invoice__c = invoice.Id;
                } 
            }
        } 
        
        update subsList;
        update opps;
        
        //start trigger execution
        //execControl.stopInvoiceTrigger = false;
        
        set<id> invoiceSet = new set<id>();
        for (c2g__codaInvoice__c inv : updateInvoices)
            invoiceSet.add(inv.id);
            
        if (createInvoiceFromWS && returnInvoiceId.size() == 1 && postInvoices){
            AutoGenerateFinancialTransactions aft = new AutoGenerateFinancialTransactions(new set<id>(returnInvoiceId) , invoiceCompany);
            aft.fromWs = true;
            database.executeBatch(aft,1);
        }
            
        return returnInvoiceId;
    }

    public static c2g.CODAAPIInvoiceTypes_9_0.Invoice createInvoice(Opportunity opp, list<Subscription_Line__c> subLines){
        
        c2g.CODAAPIInvoiceTypes_9_0.Invoice invoice = new c2g.CODAAPIInvoiceTypes_9_0.Invoice();
        
        invoice.InvoiceDate = Date.today();
        invoice.PrintedText1AllowEdit = false;
        invoice.PrintedText2AllowEdit = false;
        invoice.PrintedText3AllowEdit = false;
        invoice.PrintedText4AllowEdit = false;
        invoice.PrintedText5AllowEdit = false;
        invoice.Usepartperiods = false;
        
        if (opp.Account.c2g__CODADaysOffset1__c == null || opp.Account.c2g__CODADaysOffset1__c == 0){
            invoice.DueDate = Date.today();
        } else {
            invoice.DueDate = Date.today().addDays((integer)opp.Account.c2g__CODADaysOffset1__c);
        }
        
        invoice.InvoiceDescription = opp.Purchase_Order_Reference__c;
        invoice.InvoiceStatus = c2g.CODAAPIInvoiceTypes_9_0.enumInvoiceStatus.InProgress;
        
        invoice.Opportunity = new c2g.CODAAPICommon.Reference();
        invoice.Opportunity.Id = opp.Id;
        
        invoice.Account = new c2g.CODAAPICommon.Reference();
        invoice.Account.Id = opp.AccountId;
        
        list<c2g.CODAAPIInvoiceTypes_9_0.CustomField> iCFList = new list<c2g.CODAAPIInvoiceTypes_9_0.CustomField>();
        
        if (createInvoiceFromWS)
            iCFList.add((c2g.CODAAPIInvoiceTypes_9_0.CustomField)addCustomField('Invoice','Processed__c', 'Manually'));
        else
            iCFList.add((c2g.CODAAPIInvoiceTypes_9_0.CustomField)addCustomField('Invoice','Processed__c', 'Automatically'));
            
        invoice.CustomFields = iCFList;
        
        invoice.LineItems = new c2g.CODAAPIInvoiceLineItemTypes_9_0.InvoiceLineItems();
        invoice.LineItems.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_9_0.InvoiceLineItem>();
        
        List<String> usrCurrentCompanyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
        
        //if (opp.BSC_Event_Bookings__r.size() == 0 && subLines.size() == 0 && opp.OpportunityLineItems.size() > 0){
            for (OpportunityLineItem oli : opp.OpportunityLineItems){
                
                boolean bookingFound = false;
                boolean subFound = false;
                
                for (Special_Event_Booking__c booking : opp.BSC_Event_Bookings__r){
                    if (oli.id == booking.OPL_ID__c){
                        bookingFound = true;
                        break;
                    }
                }
                
                for (Subscription_Line__c subsline : subLines){
                    if (oli.id == subsline.OPL_ID__c){
                        subFound = true;
                        break;
                    }
                }
                
                if (bookingFound == false && subFound == false){
                    c2g.CODAAPIInvoiceLineItemTypes_9_0.InvoiceLineItem lineItem = new c2g.CODAAPIInvoiceLineItemTypes_9_0.InvoiceLineItem();
                    
                    lineItem.Product = new c2g.CODAAPICommon.Reference();
                    lineItem.Product.Id = oli.PriceBookEntry.Product2Id;
                    lineItem.UnitPrice = oli.UnitPrice;
                    if(oli.Set_an_Invoice_Quantity__c == null)
                    {   
                        if(oli.Quantity_Invoiced__c == null){
                            oli.Quantity_Invoiced__c = 0;
                        }
                        if(oli.Quantity_Credited__c == null){
                            oli.Quantity_Credited__c = 0;
                        }
                        lineItem.Quantity = oli.Quantity - oli.Quantity_Invoiced__c + oli.Quantity_Credited__c;
                    }   
                    else{
                        lineItem.Quantity = oli.Set_an_Invoice_Quantity__c;
                    }
                    lineItem.LineDescription = oli.Id+';void';
                    lineItem.UsePartPeriods = false;
                    
                    if (oli.PricebookEntry.Product2.Dimension_1__c != null){
                        lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                        lineItem.Dimension1.Id = oli.PricebookEntry.Product2.Dimension_1__c;
                    }else{
                        if(InvoiceHelper.getDimension1CodeFromOwner(opp.OwnerId) != null){
                            lineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
                            lineItem.Dimension1.Id = InvoiceHelper.getDimension1CodeFromOwner(opp.OwnerId);
                        }
                    }
                    lineItem.Dimension2 = new c2g.CODAAPICommon.Reference();
                    lineItem.Dimension2.Id = FinanceHelper.getDim2Code(oli);
                    
                    invoice.LineItems.LineItemList.add(lineItem);
                }
            }   
        //}
        
        for (Special_Event_Booking__c booking : opp.BSC_Event_Bookings__r){
            boolean ok = false;
            
            for (OpportunityLineItem oli : opp.OpportunityLineItems){
                
                if (oli.id == booking.OPL_ID__c){
                    ok = true;
                    
                    c2g.CODAAPIInvoiceLineItemTypes_9_0.InvoiceLineItem lineItem2 = new c2g.CODAAPIInvoiceLineItemTypes_9_0.InvoiceLineItem();
                    lineItem2.Product = new c2g.CODAAPICommon.Reference();
                    
                    if (booking.Transfer_Cancellation_Reason__c == null)
                        lineItem2.Product.Id = booking.Special_Event__r.Product__c;
                    else
                        lineItem2.Product.Id = oli.PriceBookEntry.Product2Id;
                    
                    lineItem2.Quantity = 1;
                    //if (opp.RecordType.Name == 'In-company Event')
                    lineItem2.UnitPrice = oli.UnitPrice;    
                    lineItem2.LineDescription = oli.Id+';'+booking.Id+';'+booking.Special_Event__r.Name+';'+booking.Event_Start_Date__c;
                    lineItem2.UsePartPeriods = false;
                    
                    if(booking.Special_Event__r.Dimension_4__c!=null){
                        lineItem2.Dimension4 = new c2g.CODAAPICommon.Reference();
                        lineItem2.Dimension4.Id  = booking.Special_Event__r.Dimension_4__c;
                    }
                    
                    if(oli.Dimension_2__c!=null){
                        lineItem2.Dimension2 = new c2g.CODAAPICommon.Reference();
                        lineItem2.Dimension2.Id = oli.PricebookEntry.Product2.Dimension_2__c;
                    }
                    
                    if(oli.Dimension_1__c!=null){
                        lineItem2.Dimension1 = new c2g.CODAAPICommon.Reference();
                        lineItem2.Dimension1.Id  = oli.PricebookEntry.Product2.Dimension_1__c;
                    }else{
                        if(InvoiceHelper.getDimension1CodeFromOwner(opp.OwnerId) != null){
                            lineItem2.Dimension1 = new c2g.CODAAPICommon.Reference();
                            lineItem2.Dimension1.Id = InvoiceHelper.getDimension1CodeFromOwner(opp.OwnerId);
                        }
                    }
                    invoice.LineItems.LineItemList.add(lineItem2);
                    break;
                }
            }
            
            if (!ok){
                throw new invoiceException('Booking ' + booking.name + ' does not have valid opl id' ); 
            }
        }
        
        for (Subscription_Line__c subsline : subLines){
            boolean ok = false;
            
            for (OpportunityLineItem oli : opp.OpportunityLineItems){
                
                if (oli.id == subsline.OPL_ID__c){
                    ok = true;
                    
                    c2g.CODAAPIInvoiceLineItemTypes_9_0.InvoiceLineItem lineItem2 = new c2g.CODAAPIInvoiceLineItemTypes_9_0.InvoiceLineItem();
                    lineItem2.Product = new c2g.CODAAPICommon.Reference();
                    lineItem2.Product.Id = subsLine.Product__c;
                    lineItem2.Quantity = subsLine.Quantity__c;
                    lineItem2.UnitPrice = oli.UnitPrice;
                    lineItem2.LineDescription = oli.Id + ';' + subsLine.Id;
                    lineItem2.UsePartPeriods = false;
                    
                    if(subsLine.Product__r.Dimension_1__c!=null){
                        lineItem2.Dimension1 = new c2g.CODAAPICommon.Reference();
                        lineItem2.Dimension1.Id = subsLine.Product__r.Dimension_1__c;                                   
                    }else{
                        if(InvoiceHelper.getDimension1CodeFromOwner(opp.OwnerId) != null){
                            lineItem2.Dimension1 = new c2g.CODAAPICommon.Reference();
                            lineItem2.Dimension1.Id = InvoiceHelper.getDimension1CodeFromOwner(opp.OwnerId);
                        }
                    }
                    
                    lineItem2.Dimension2 = new c2g.CODAAPICommon.Reference();
                    lineItem2.Dimension2.Id = FinanceHelper.getDim2Code(oli);
                                         
                    invoice.LineItems.LineItemList.add(lineItem2);
                    
                    break;
                }
            }
            
            if (!ok){
                throw new invoiceException('subscription Line ' + subsline.name + ' does not have valid opl id' ); 
            }
        }
        return invoice;
    }
    

    
    /*
     * GET OPPORTUNITY AND SUBSCRIPTION LINE MAP
     *
     * Returns a map which links opportunity id to subscription lines
     *
     * Returns: map<OpportunityId,SubscriptionLine>
     */
    public static Map<Id,list<Subscription_Line__c>> getOppLineSubLineMap(list<id> opps){
        
        for (Subscription_Line__c subLine : [SELECT s.Id,
                                                    s.OPL_ID__c,
                                                    s.Subscription__c,
                                                    s.Subscription__r.opportunity__c,
                                                    s.Subscription__r.Sub_Ref__c, 
                                                    s.Subscription__r.Account_Name__r.Name,
                                                    s.Quantity__c, 
                                                    s.Product__c,
                                                    s.Product__r.Dimension_1__c,
                                                    s.Product__r.Dimension_2__c,
                                                    s.Product__r.Renewal_Dimension_2__c,
                                                    s.Product_Sales_Price__c, 
                                                    s.Name, 
                                                    s.Invoice_Status__c, 
                                                    s.Credited_Status__c 
                                             FROM
                                                    Subscription_Line__c s
                                             WHERE
                                                    s.Subscription__r.opportunity__c in :opps]){
            
            oppLineSubLineList.get(subLine.Subscription__r.opportunity__c).Add(subLine);
            subscriptions.add(subLine.Subscription__c);
            
        }
        return oppLineSubLineList;
    }

    public static boolean fromWS = false;
    
    webservice static void wsCreateCreditNoteFromOpp(id invoiceId, string invoiceCompany){
        
        fromWS = true;
        createCreditNotes(new list<id>{invoiceId}, AutoInvoiceSettings.autoPostCreditNotes, invoiceCompany);
        
    }
    
    /*
     * CREATE CREDIT NOTEs FROM invoices
     *
     * Creates an creditnotes based on Invoices
     */
    public static List<Id> createCreditNotes(List<id> invoiceIds, boolean postCreditNote, string invoiceCompany){
        
        system.debug('Inside createCreditNotes');
        system.debug('boolean postCreditNote - ' + postCreditNote);
        
        list<c2g.CODAAPICreditNoteTypes_9_0.CreditNote> creditNotes = new list<c2g.CODAAPICreditNoteTypes_9_0.CreditNote>();
       
        list<id> retList = new list<id>();
        
        /*CREATE CONTEXT FOR FINANCIAL FORCE*/      
        c2g.CODAAPICommon_9_0.Context context = new c2g.CODAAPICommon_9_0.Context();
        if(!isTest)
            context.CompanyName = invoiceCompany;
            //List<String> usrCurrentCompanyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
            //context.CompanyName = usrCurrentCompanyName.get(0);
        
        
        id periodId = [SELECT Id,Name FROM c2g__codaPeriod__c WHERE c2g__StartDate__c <= TODAY AND c2g__EndDate__c >= TODAY AND c2g__OwnerCompany__r.name = :invoiceCompany].Id;
        system.debug('Period/Company - ' + periodId + ' / ' + invoiceCompany);
        list<c2g__codaInvoice__c> invoices = [select  Id 
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
                                                    where Id in :invoiceIds];

        list<string> invoiceNames = new list<string>();   
        list<UnMatchHelper> unMatches = new list<UnMatchHelper>();
                                             
        for (c2g__codaInvoice__c invoice : invoices){
            invoiceNames.add(invoice.Name);
        }
        
        for (c2g__codaMatchingReference__c matchRef: [SELECT id, name,  (Select c2g__Account__c, c2g__MatchingReference__c, c2g__Period__c, Invoice_Number__c From c2g__MatchingHistories__r) 
                                                        FROM c2g__codaMatchingReference__c
                                                       WHERE  ID IN (SELECT c2g__MatchingReference__c FROM c2g__codaCashMatchingHistory__c
                                                                      WHERE Invoice_Number__c IN :invoiceNames and c2g__UndoMatchingReference__c = null)
                                                          AND ID NOT IN (SELECT c2g__UndoMatchingReference__c FROM c2g__codaCashMatchingHistory__c
                                                                          WHERE Invoice_Number__c IN :invoiceNames and c2g__UndoMatchingReference__c != null)]){
            
            for (c2g__codaCashMatchingHistory__c matchingHistory : matchRef.c2g__MatchingHistories__r){
                boolean brk = false;
                
                for (string inv : invoiceNames){
                    if (inv == matchingHistory.Invoice_Number__c ){
                        UnMatchHelper unmatch = new UnMatchHelper();
                        unmatch.matchingReference = matchRef;
                        unmatch.invoiceName = inv;
                        unmatch.accountId = matchingHistory.c2g__Account__c;
                        unmatch.periodId = periodId;
                        unMatches.add(unmatch);
                        brk = true;
                        break;
                    }
                }
                
                if (brk)
                   break;
            }
        }
        
        try{
            /* UNMATCH INVOICES*/
            UnMatchInvoice(unMatches);
        } catch (Exception e) {
             list<string> info = new list<string>();
            info.add(AutoInvoiceSettings.emailNotificationTo);
            list<string>  error = new list<string>();
           
            error.add(string.valueof(e.getLineNumber()));
            error.add(e.getMessage());
            error.add(e.getStackTraceString());
            error.add(e.getTypeName());
            AutoInvoiceHelper.sendMail('Auto Credit Process Error', 'Unable to UnMatchInvoice(unMatches) : ' + unMatches + error, info);
            return null;
        }
        
        for (c2g__codaInvoice__c invoice : invoices){

            c2g.CODAAPICreditNoteTypes_9_0.CreditNote creditNote = new c2g.CODAAPICreditNoteTypes_9_0.CreditNote();
            creditNote.Account = new c2g.CODAAPICommon.Reference();
            creditNote.Account.Id = invoice.c2g__Account__c;
            creditNote.Opportunity = new c2g.CODAAPICommon.Reference();
            creditNote.Opportunity.Id = invoice.c2g__Opportunity__c;
            creditNote.CreditNoteCurrency = new c2g.CODAAPICommon.Reference();
            creditNote.CreditNoteCurrency.Id = invoice.c2g__InvoiceCurrency__c;
            creditNote.InvoiceDate = invoice.c2g__InvoiceDate__c;
            creditNote.Period = new c2g.CODAAPICommon.Reference();
            creditNote.Period.Id = periodId;
            creditNote.OwnerCompany = new c2g.CODAAPICommon.Reference();
            creditNote.OwnerCompany.Id = invoice.c2g__OwnerCompany__c;
            creditNote.CreditNoteStatus = c2g.CODAAPICreditNoteTypes_9_0.enumCreditNoteStatus.InProgress;
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

            creditNote.Invoice = new c2g.CODAAPICommon.Reference();
            creditNote.Invoice.Id = invoice.Id;
            creditNote.CustomerReference = invoice.Name;
            system.debug('VS Dimension 2 value: ' + invoice.c2g__Dimension2__c + 'end');
            
            creditNote.LineItems = new c2g.CODAAPICreditNoteLineItemTypes_9_0.CreditNoteLineItems();
            creditNote.LineItems.LineItemList = new List<c2g.CODAAPICreditNoteLineItemTypes_9_0.CreditNoteLineItem>();
        
            for (c2g__codaInvoiceLineItem__c invoiceLine : invoice.c2g__InvoiceLineItems__r){
            
                c2g.CODAAPICreditNoteLineItemTypes_9_0.CreditNoteLineItem creditLineItem = new c2g.CODAAPICreditNoteLineItemTypes_9_0.CreditNoteLineItem();
                
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
                
                if (invoiceLine.c2g__TaxCode1__c !=  null)
                    creditLineItem.TaxValue1 = invoiceLine.c2g__TaxValue1__c;
                
                if (invoiceLine.c2g__TaxCode2__c !=  null)
                    creditLineItem.TaxValue2 = invoiceLine.c2g__TaxValue2__c;
                
                if (invoiceLine.c2g__TaxCode3__c !=  null)
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
                
                list<c2g.CODAAPICreditNoteLineItemTypes_9_0.CustomField> cl = new list<c2g.CODAAPICreditNoteLineItemTypes_9_0.CustomField>();
                
                c2g.CODAAPICreditNoteLineItemTypes_9_0.CustomField cusFld =  new c2g.CODAAPICreditNoteLineItemTypes_9_0.CustomField(); 
                cusFld.FieldName = 'Sales_Invoice_Line_Item__c';
                cusFld.value = invoiceLine.id;
                cl.add(cusFld);
                creditLineItem.CustomFields = cl;
                
                creditNote.LineItems.LineItemList.add(creditLineItem);
                
            }
             
            list<c2g.CODAAPICreditNoteTypes_9_0.CustomField> cnCFList = new list<c2g.CODAAPICreditNoteTypes_9_0.CustomField>();
            
            cnCFList.add((c2g.CODAAPICreditNoteTypes_9_0.CustomField)addCustomField('CreditNote','Product_Delivered__c', invoice.c2g__Opportunity__r.Product_Delivered__c));
            cnCFList.add((c2g.CODAAPICreditNoteTypes_9_0.CustomField)addCustomField('CreditNote','Credit_Note_Product_Group__c', invoice.c2g__Opportunity__r.Credit_Note_Product_Group__c));
            
            if (fromWS)
                cnCFList.add((c2g.CODAAPICreditNoteTypes_9_0.CustomField)addCustomField('CreditNote','Processed__c', 'Manually'));
            else
                cnCFList.add((c2g.CODAAPICreditNoteTypes_9_0.CustomField)addCustomField('CreditNote','Processed__c', 'Automatically'));

            if (postCreditNote)
                cnCFList.add((c2g.CODAAPICreditNoteTypes_9_0.CustomField)addCustomField('CreditNote','Match_Invoice__c', 'true'));
            
            creditnote.CustomFields = cnCFList;
            system.debug('Credit Notes: ' + creditnote );
            creditNotes.add(creditnote);
        } 
        
        try{
        
            execControl.stopOppControls = true;
            execControl.stopCreditNoteTrigger = true;
            
            set<id> oppIds = new set<id>();    
            list<c2g.CODAAPICommon.Reference> results = c2g.CODAAPISalesCreditNote_9_0.BulkCreateCreditNote(context, creditNotes);
            system.debug('VS : Create Creditnote result : ' + results);
            
            list<id> cnIds = new list<id>();
            for (c2g.CODAAPICommon.Reference ref : results){
                cnIds.add(ref.id);
            }
                                                               
            list<c2g__codaCreditNote__c> listCreditNotes =  [select id, 
                                                                    match_invoice__c,
                                                                    c2g__Opportunity__r.Credit_Note_Reason__c, 
                                                                    c2g__Opportunity__r.Product_Delivered__c, 
                                                                    c2g__Opportunity__r.Credit_Note_Product_Group__c,
                                                                    c2g__Opportunity__c,
                                                                    c2g__Invoice__r.c2g__InvoiceTotal__c,
                                                                    c2g__Invoice__r.c2g__Opportunity__c,
                                                                    c2g__Invoice__r.c2g__Opportunity__r.Amount,
                                                                    c2g__Invoice__r.c2g__Opportunity__r.StageName,
                                                                    c2g__Invoice__r.Name,
                                                                    c2g__Invoice__c,
                                                                    c2g__Invoice__r.c2g__Account__c,
                                                                    c2g__Invoice__r.c2g__Period__c
                                                               from c2g__codaCreditNote__c 
                                                              where id in :cnIds];


            for (c2g__codaCreditNote__c cn : listCreditNotes){
                cn.c2g__CreditNoteReason__c = cn.c2g__Opportunity__r.Credit_Note_Reason__c;
                oppIds.Add(cn.c2g__Opportunity__c);                    
            }

            update listCreditNotes;      
            for (c2g__codaInvoice__c inv : invoices){
                boolean createdCN = false;
                 
                for (c2g__codaCreditNote__c cn : listCreditNotes){
                    if (inv.Id == cn.c2g__Invoice__c){
                        AutoInvoiceHistory.createHistory(inv.c2g__InvoiceTotal__c,inv.c2g__Opportunity__c, inv.c2g__Opportunity__r.Amount, inv.c2g__Opportunity__r.StageName, cn.id, cn.c2g__Invoice__c, 'Credited', 'Credit', '','');
                        createdCN = true;
                        break;
                    }
                }
                
                if (createdCN == false)
                   AutoInvoiceHistory.createHistory(inv.c2g__InvoiceTotal__c,inv.c2g__Opportunity__c, inv.c2g__Opportunity__r.Amount, inv.c2g__Opportunity__r.StageName, null, inv.id, 'Failed to Credit', 'Credit', 'Failed to Credit','');
            }
            

            system.debug('updated credit notes reasons after creation');
            
            if (postCreditNote) {
                c2g.CODAAPISalesCreditNote_9_0.BulkPostCreditNote(null,results);
            }

            list<Opportunity> opps = [select id from Opportunity where id in :oppIds];
            
            for (Opportunity opp : opps)
                opp.Finance_to_Credit_Opp__c = false;
                
            update opps;
            
            execControl.stopCreditNoteTrigger = false;
            
            if (results.size() == 1 && fromWS){
                
                if (test.isRunningTest() == false){
                    AutoInvCreditMatchBatch acmb = new AutoInvCreditMatchBatch(invoiceCompany);
                    acmb.creditNoteId = cnIds[0];
                    database.executeBatch(acmb);
                }
               
            }
            
            return cnIds;
            
        } catch(Exception e) { 
            
            list<string> info = new list<string>();
            info.add(AutoInvoiceSettings.emailNotificationTo);
            list<string>  error = new list<string>();
           
            error.add(string.valueof(e.getLineNumber()));
            error.add(e.getMessage());
            error.add(e.getStackTraceString());
            error.add(e.getTypeName());
            AutoInvoiceHelper.sendMail('Auto Credit Process Error', 'Unable to Create Credit Notes for following Invoices : ' + invoiceIds + error, info);
            //throw new invoiceException(e.getmessage()); 
            return null;
        }
    }
    
    public class UnMatchHelper{
        public c2g__codaMatchingReference__c matchingReference;
        public string invoiceName;
        public id accountId;
        public id periodId;
    }
    
    public static boolean UnMatchInvoice(list<UnMatchHelper> unMatchInvoices){
        
        boolean returnValue = true;
        
        system.debug('Unmatching Invoice ' + unMatchInvoices);
        
        execControl.stopOppControls = true;
        
        c2g.CODAAPICommon_7_0.Context context = new c2g.CODAAPICommon_7_0.Context();
        List<String> usrCurrentCompanyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(new c2g.CODAAPICommon_2_0.Context());
        context.CompanyName = usrCurrentCompanyName.get(0);
        
        for (UnMatchHelper unmatch : unMatchInvoices){
            
            c2g.CODAAPICashMatchingTypes_7_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_7_0.Configuration();        
            configuration.Account = c2g.CODAAPICommon.getRef(unmatch.accountId, null);
            configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_7_0.enumMatchingCurrencyMode.Account;
            configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(unmatch.periodId, null);
            configuration.MatchingDate = System.today();
            c2g.codaapicommon.reference ref =  new c2g.codaapicommon.reference();
            ref = c2g.CODAAPICommon.getRef(unmatch.matchingReference.Id, null);

            c2g.codaapicommon.reference result =  c2g.CODAAPICashMatching_7_0.UnMatch(context, configuration, ref, c2g.CODAAPICashMatchingTypes_7_0.enumUndoReason.MatchingError);
            system.debug(result);
        }

        system.debug('Unmatching Invoice Completed ' + unMatchInvoices);
        
        return returnValue;
    }
    
    
    public static void InvoiceCreditMatch(string salesInvoiceName, id accountId, id periodId){
        
        execControl.stopOppControls = true;
        
        List<string> documentRefs = new List<string>();
        
        List<c2g__codatransactionlineitem__c> transactionLinesToMatch = [select Id, 
                                                                                c2g__AccountValue__c 
                                                                           from c2g__codaTransactionLineItem__c
                                                                          where c2g__Transaction__r.c2g__DocumentReference__c  = :salesInvoiceName 
                                                                            and c2g__LineType__c = 'Account'];
        system.debug('@@@@@transactionLinesToMatch '+transactionLinesToMatch );

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
        }
        
        c2g.CODAAPICashMatchingTypes_6_0.Analysis analisysInfo = new c2g.CODAAPICashMatchingTypes_6_0.Analysis();
                
        c2g.CODAAPICommon.Reference matchReference =  c2g.CODAAPICashMatching_6_0.Match(context1, configuration, items, analisysInfo);
        
    }
    
    public static void sendMail(string subject, string body, list<string> toAddress){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setToAddresses(toAddress);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static object addCustomField(string objType, string fldName, string val){
        if (objType =='CreditNote'){ 
            c2g.CODAAPICreditNoteTypes_9_0.CustomField cfl =  new c2g.CODAAPICreditNoteTypes_9_0.CustomField(); 
            cfl.FieldName = fldName;
            cfl.value = val;                
            system.debug('CreditNote c2g.CODAAPICreditNoteTypes_9_0.CustomField cfl - ' + cfl);
            return cfl;
        } if (objType =='Invoice'){ 
            c2g.CODAAPIInvoiceTypes_9_0.CustomField cfl =  new c2g.CODAAPIInvoiceTypes_9_0.CustomField(); 
            cfl.FieldName = fldName;
            cfl.value = val;                
            system.debug('Invoice c2g.CODAAPICreditNoteTypes_9_0.CustomField cfl - ' + cfl);
            return cfl;
        } else {
            return null;
        }
    }
    
    public static boolean stopCreditNoteTriggers;
    
    public static void setCWExecutionTime(){
        
        
        Datetime cwTime = System.now();
        time schTime = time.newInstance(21, 00, 00, 00);
        Datetime schDateTime = datetime.newInstance(cwTime.date(), schTime);
        
        list<string> info = new list<string>();
        info.add(AutoInvoiceSettings.emailNotificationTo);
        AutoInvoiceHelper.sendMail('Auto step', ' Company: ' + c2g.CODACurrentCompanyDisplayController.getCompanyName().companyName, info);
            
        AutoInvoiceSettings__c aiSetting = [Select Complywise_Last_Execution__c From AutoInvoiceSettings__c][0];
        aiSetting.Complywise_Last_Execution__c = schDateTime;
        update aiSetting;
        
    }

}