public with sharing class MembershipApplicationForm {

	Opportunity opp;
	private final String hash;
	public Boolean fatalError {get;private set;}
	public String iWantTo {get;set;}
	public Boolean confirmTerms {get;set;}
    public String currencySymbol {get; private  set;}

	public List<Subscription_Site__c> allSubSites {get;set;}

	private String url = 'http://britishsafetycouncil.fftest.cs7.force.com/forms/MembershipApplicationForm';
	//private String url = 'http://britishsafetycouncil.force.com/forms/MembershipApplicationForm';
	
	public String authorisedBy {get;set;}
	public String authorisedPosition {get;set;}
	public String methodofPayment {get;set;}
	public String purchaseOrderReference {get;set;}
	public OpportunityContactRole oppPrimaryContactRole {get; private set;}
	public Opportunity oppDetails {get; private set;}
	public Boolean confirmed {public get; private set;}

	// STATICS
	static final Id SITES_GROUP_ID = '00GM0000000G1qpMAC';
	
	/*
	 * CONSTRUCTOR
	 */
	public MembershipApplicationForm(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        this.hash = ApexPages.currentPage().getParameters().get('hash');
        this.allSubSites = getSubSites();
        // @todo: Checking for contact role is in javascript button but should catch exception.
        this.oppPrimaryContactRole = [SELECT ContactId FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId = :this.opp.Id LIMIT 1][0];
	    this.oppDetails = [SELECT Id, Subscription__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];

		List<Customer_Approval__c> customerApprovals = new List<Customer_Approval__c>([SELECT 
																Id
																FROM Customer_Approval__c
																WHERE Opportunity__c = :this.opp.Id]);
		if (customerApprovals.isEmpty()) {
		    this.confirmed = false;
		}else{
		    this.confirmed = true;
		}
	    //upsrtSubscrtiption();
    }
    
    /*
     * GET OPP LINES
     */
    public OpportunityLineItem [] getOppLines() {
    	
    	List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>([SELECT o.PriceBookEntry.ProductCode, 
    																			o.Quantity, 
    																			o.Qty_to_show_on_booking_form__c, 
    																			o.TotalPrice, 
    																			o.UnitPrice, 
    																			o.Booking_form_total_price__c,
    																			o.Show_Price_as_TBA__c, 
    																			o.PriceBookEntry.Product2.Product_Correspondence_Name__c ,
    																			o.Product_Correspondence_Name__c
    																		FROM OpportunityLineItem o
    																		WHERE OpportunityId = :this.opp.Id
                                                                            	AND Qty_to_show_on_booking_form__c !=0
    																		]);
		return oppLines;
    }
    
    /*
     * GET OPPORTUNITY TOTAL
     */
    public Decimal getOppTotal() {
        
        Decimal totalAmount = 0;
        
        for(OpportunityLineItem oppLine : [SELECT o.PriceBookEntry.ProductCode, o.Quantity, o.Qty_to_show_on_booking_form__c, o.TotalPrice, o.UnitPrice, o.PriceBookEntry.Product2.Product_Correspondence_Name__c 
                                                                            FROM OpportunityLineItem o
                                                                            WHERE OpportunityId = :this.opp.Id
                                                                            	AND Qty_to_show_on_booking_form__c != 0
                                                                            ]){
            if(oppLine.Qty_to_show_on_booking_form__c > 0){
            	totalAmount+=(oppLine.Qty_to_show_on_booking_form__c * oppLine.UnitPrice);
            }else{
            	totalAmount+=(oppLine.Quantity * oppLine.UnitPrice);
            }
            
        }
        System.debug('Total Opp Amount: '+totalAmount);
        return totalAmount;
    }

    /*
     * GET CONTACT ROLE
     */
    public OpportunityContactRole getContactRole() {

    	//@todo check for no records
    	try {
	    	OpportunityContactRole oppContactRole = [SELECT ContactId, Contact.Name, Contact.Salutation, Role, Contact.Email, Contact.Title, Contact.Phone FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId = :this.opp.Id LIMIT 1][0];
    		return oppContactRole;
	
		}catch(Exception e){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to continue, no primary contact role exists on the opportunity');
			ApexPages.addMessage(myMsg);
			
			fatalError = true;
			this.fatalError = true;
			return null;
    	}
    }

    /*
     * GET TAX AMOUNTS
     * Gets the tax amounts of the invoice part of the membership application VF.
     */
    public List<Decimal> getTaxAmounts(){

        Decimal [] taxAmounts = new List<Decimal>();

        /*
        Account acc = [SELECT c2g__CODAInputVATCode__c FROM Account WHERE Id = :this.opp.AccountId LIMIT 1][0];
        Id taxCodeId = acc.c2g__CODAInputVATCode__c;
        */
        Opportunity oppTax = [SELECT Tax_Code__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
        Id taxCodeId = oppTax.Tax_Code__c;
        System.debug('TaxCodeId: '+taxCodeId);
        
        
        if (taxCodeId == null){
            // @todo error not appearing:
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The opportunity doesn\'t have an VAT code set');
            ApexPages.addMessage(myMsg);
            fatalError = true;
            this.fatalError = true;
            taxAmounts.add(0); taxAmounts.add(0);           
        }else{
            //@todo check for no records
            c2g__codaTaxRate__c taxRate = [SELECT c2g__Rate__c FROM c2g__codaTaxRate__c WHERE c2g__StartDate__c < :Date.Today() AND c2g__TaxCode__r.Id = :taxCodeId ORDER BY c2g__StartDate__c DESC LIMIT 1][0];
            
            taxAmounts.add(taxRate.c2g__Rate__c);
            try {
                taxAmounts.add(getOppTotal()*taxRate.c2g__Rate__c);
            }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity does not have any products!');
                ApexPages.addMessage(myMsg);
                fatalError = true;
                this.fatalError = true;
            }
        }
        
        return taxAmounts;
    }
	
	public List<Subscription_Site__c> getSubSites(){
		
		Opportunity opp = [SELECT Subscription__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
		
		List<Subscription_Site__c> subSites = new List<Subscription_Site__c>([SELECT 
																Id,
																Site_Account__c,
																Site_Account__r.Name,
																Site_Account__r.isPersonAccount,
																Site_Account__r.Principle_Address_Building__c,
							        							Site_Account__r.Principle_Address_Street__c,
							        							Site_Account__r.Principle_Address_Area__c,
							        							Site_Account__r.Principle_Address_City__c,
							        							Site_Account__r.Principle_Address_State_Province__c,
							        							Site_Account__r.Principle_Address_ZIP_Postal_Code__c,
							        							Site_Account__r.Principle_Address_Country__c,
																Site_Account__r.Industry_Sector__c,
																Site_Account__r.Industry,
																Site_Account__r.NumberOfEmployees,
																CE_Site_Building__c,
																CE_Site_Name__c,
																CE_Site_Street__c,
																CE_Site_Area__c,
																CE_Site_City__c,
																CE_Site_Postal_Zip_code__c,
																CE_Site_Country__c,
																CE_Site_Contact_Name__c,
																CE_Site_Contact_Email__c,
																CE_Site_Contact_Phone__c,
																CE_Number_of_Site_Employees__c,
																CE_Site_Industry__c,
																Site_Contact__c,
																Site_Contact__r.Name,
																Site_Contact__r.Email,
																Site_Contact__r.Phone,
																Name,
																Subscription_Site_Ref__c,
																Type__c,
																(SELECT Id,
																		Subscription_Line__r.Product__r.Product_Correspondence_Name__c, 
																		Subscription_Line__r.Product__r.Core_Subscription_Product__c 
																		FROM 
																		Site_Products__r
																		ORDER BY 
																		Subscription_Line__r.Product__r.Core_Subscription_Product__c DESC
																		)
																FROM Subscription_Site__c WHERE Subscription__c = :opp.Subscription__c AND (Site_Account__r.isPersonAccount = false OR Site_Account__r.isPersonAccount = true OR Site_Account__r.isPersonAccount = null)]);
		
		this.allSubSites = subSites;
		System.debug('All SubSites:'+this.allSubSites);
		return this.allSubSites;
	}

    /*
     * GET THE CURRENCY SYMBOL FOR THE FORM
     * 
     */
    public String getCurrSymbol(){
        
        if (this.currencySymbol == null){
            Opportunity opp = [SELECT CurrencyIsoCode FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
            if (opp.CurrencyIsoCode == 'GBP'){
                this.currencySymbol = '£';
            }else{
                this.currencySymbol = opp.CurrencyIsoCode;
            } 
        }
        return this.currencySymbol;
    }
    

	/*
	 * Get available modules that can be added to the subscription sites
	 *
	 */
	public List<Subscription_Line__c> getAvilProducts(){

		Opportunity opp = [SELECT Subscription__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];

		List<Subscription_Line__c> subSiteProducts = new List<Subscription_Line__c>([SELECT 
																Id,
																Product__r.Product_Correspondence_Name__c
																FROM Subscription_Line__c
																WHERE Quantity_Available__c > 0
																AND Product__r.Core_Subscription_Product__c = false
																AND Subscription__c = :opp.Subscription__c
																]);
		if (subSiteProducts.isEmpty()) {
			System.debug('no available products found');
			return null;
		}else{
			System.debug('Found available products: '+subSiteProducts);
			return subSiteProducts;
		}
	}

	/*
	 * Get number of available modules that can be added to the subscription sites
	 *
	 */
	public Integer getAvilProductsCount(){
		
		Integer size = 0;
		List<Subscription_Line__c> availProducts = getAvilProducts();
		if (availProducts == null){
			size = 0;
		}else{
			size = availProducts.size();
		}
		return size;
	
	}
	
    /*
     * GET LATEST CUSTOMER APPROVAL
     *
     * Gets the latest customer approval for the opportunity
     * 
     */
    public Customer_Approval__c getCustApproval(){
    	
    	        // Get the latest authorisation information
        Customer_Approval__c[] custApprRec = [SELECT Authorised_By__c, 
								Authorised_Position__c,
								Method_of_Payment__c,
								Purchase_Order_Reference__c,
								CreatedDate
							FROM
								Customer_Approval__c
							WHERE
								Opportunity__c = :this.opp.Id ORDER BY CreatedDate DESC LIMIT 1];
        if (custApprRec.size() > 0){
        	return custApprRec[0];
        }else{
        	return null;
        }
    }
    
	/**********************************
	 *          VF ACTIONS            *
	 **********************************
	 */
	
	public pageReference updateSite(){
		
		update allSubSites;
		
		List<Subscription_Site__c> subSites = new List<Subscription_Site__c>();
		subSites = getSubSites();
		//		this.allSubSites = getSubSites();
		
		return null;
	}
	
	/*
	 * ACTION: SEND TO AE
	 * 
	 */
	public pageReference sendToAE(){
		
		String changeDetails = ApexPages.currentPage().getParameters().get('changeDetails');
		Id whoId = ApexPages.currentPage().getParameters().get('whoId');
		
		Task newTask = new Task(
                            Subject = 'Customer Feedback from '+opp.Opportunity_Number__c+' ("' + opp.Name + '") opportunity',
                            Priority = 'Normal',
                            Status = 'Not Started',
                            Description = 'RESPONSE FROM CUSTOMER:\n\n'+changeDetails,
                            IsReminderSet = true,
                            ReminderDateTime = System.now(),
                            ActivityDate = date.today(),
                            WhoId = whoId,
                            WhatId = this.opp.Id,
                            Type = 'Online Form',
                            OwnerId = this.opp.OwnerId
                            );
		insert newTask;
		
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {opp.Owner.Email};
        //mail.setOrgWideEmailAddressId(this.ORG_WIDE_EMAIL);
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('salesforce@britsafe.org');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('British Safety Council Order :: Customer Feedback from opportunity');
        mail.setUseSignature(true);
        mail.setPlainTextBody('A customer has feedback on their booking: https://eu1.salesforce.com/'+newTask.Id);
		mail.setHtmlBody('A customer has feedback on their booking: <a href="https://eu1.salesforce.com/'+newTask.Id+'">https://eu1.salesforce.com/'+newTask.Id+'</a>');
		
        System.debug('Sent email to Opp Owner: '+opp.Owner.Email);   
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		System.debug('sendToAE message to: '+this.opp.OwnerId+' Message:'+newTask);
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Account Executive has been contact and will contact your shortly');
		ApexPages.addMessage(myMsg);
		
		return null;
	}

	/*
	 * ACTION: CONFIRM BOOKING
	 * 
	 */
	public pageReference confirmBooking(){

		Opportunity opp = [SELECT Name, Owner.Email, Owner.Id FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];

		Id whoId = ApexPages.currentPage().getParameters().get('whoId');
		
        Boolean error = false;
        String errMsg;
        this.authorisedBy = ApexPages.currentPage().getParameters().get('authorisedBy');
        this.authorisedPosition = ApexPages.currentPage().getParameters().get('authorisedPosition');
        this.methodofPayment = ApexPages.currentPage().getParameters().get('methodofPayment');
        this.purchaseOrderReference = ApexPages.currentPage().getParameters().get('purchaseOrderReference');
        
        if(this.authorisedBy == ''){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must add a value in the authorised by field');
            ApexPages.addMessage(myMsg);
        }
        if(this.authorisedPosition == ''){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must add a value in the authorised position field');
            ApexPages.addMessage(myMsg);
        }
        if(this.methodofPayment == ''){
            error = true; 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must add a value in the method of payment field');
            ApexPages.addMessage(myMsg);
        }
        if(this.purchaseOrderReference == '' && this.methodofPayment != 'Credit Card'){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must add a value in the purchase order / other reference field if you select a payment method of purchase order or other reference');
            ApexPages.addMessage(myMsg);
        }

        if (!this.confirmTerms){
            error = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must confirm that you have read and accept the terms and conditions');
            ApexPages.addMessage(myMsg);
        }
        if (!error){
			this.confirmed = true;
            Customer_Approval__c custApproval = new Customer_Approval__c(
                                Opportunity__c = this.opp.Id,
                                Authorised_By__c = this.authorisedBy,
                                Authorised_Position__c = this.authorisedPosition,
                                Method_of_Payment__c = this.methodofPayment,
                                Purchase_Order_Reference__c = this.purchaseOrderReference,
                                Type__c = 'Approval');
            insert custApproval;
            
            Task newTask = new Task(
                            Subject = 'Customer confirmed opportunity booking',
                            Priority = 'Normal',
                            Status = 'Not Started',
                            Description = 'RESPONSE FROM CUSTOMER:\n\nAuthorised By: '+this.authorisedBy+'\nAuthorised Position: '+this.authorisedPosition+'\nMethod of Payment: '+this.methodofPayment+'\nPurchase Order Reference: '+this.purchaseOrderReference+'\n\nCustomer Approval Record: https://eu1.salesforce.com/'+custApproval.Id,
                            IsReminderSet = true,
                            ReminderDateTime = System.now(),
                            ActivityDate = date.today(),
                            WhoId = whoId,
                            WhatId = this.opp.Id,
                            Type = 'Online Form',
                            OwnerId = this.opp.OwnerId
                            );
	        insert newTask;

			// Send email to Sales Rep
			
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {opp.Owner.Email};
            mail.setToAddresses(toAddresses);
            //mail.setOrgWideEmailAddressId('0D2M00000008OXA');
            mail.setReplyTo('salesforce@britsafe.org');
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('British Safety Council Order :: Confirmed Booking');
            mail.setUseSignature(true);
            mail.setPlainTextBody('A customer has confirmed their booking: https://eu1.salesforce.com/'+newTask.Id);//+newTask.Id);
			mail.setHtmlBody('A customer has confirmed their booking: <a href="https://eu1.salesforce.com/'+newTask.Id+'">View Task</a>');//+newTask.Id+'">https://eu1.salesforce.com/'+newTask.Id+'</a>');
			
            System.debug('Sent email to Opp Owner: '+opp.Owner.Email);            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            System.debug('sendToAE message to: '+this.opp.OwnerId+' Message:'+custApproval);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Event has been confirmed');
            ApexPages.addMessage(myMsg);

            // START: Create an attachment of the Booking form and attach it too the Customer Approval
	        Attachment attach = new Attachment();
	        PageReference pdf = Page.EventApplicationForm;
	        pdf.setRedirect(false);
	        // add parent id to the parameters for standardcontroller
        	pdf.getParameters().put('id', this.opp.Id);
	        pdf.getParameters().put('p','1');
	        // Due to record not being saved until the end of the transaction the VF doesn't show the customer approval
	        // So posting in url:
	        pdf.getParameters().put('Authorised_By__c', this.authorisedBy);
            pdf.getParameters().put('Authorised_Position__c', this.authorisedPosition);
            pdf.getParameters().put('Method_of_Payment__c', this.methodofPayment);
            pdf.getParameters().put('Purchase_Order_Reference__c', this.purchaseOrderReference);
            pdf.getParameters().put('CreatedDate', String.valueOf(System.now()));

	        // the contents of the attachment from the pdf
	        Blob body;
	        try
	        {
	            // returns the output of the page as a PDF
	            body = pdf.getContent();
	            
	            // need to pass unit test -- current bug
	        }
	        catch (VisualforceException e)
	        {
	            body = Blob.valueOf('An error occurred trying to get the contents of the PDF, please try again');
	        }

	        attach.Body = body;
	        
	        // add the name
	        attach.name = 'Booking Form ' + opp.Name + '.pdf';
	        attach.IsPrivate = false;
	        attach.ContentType = 'application/pdf';
            
	        // attach the pdf to the Customer Approval
	        attach.ParentId = custApproval.Id;
	        insert attach;

            // END: Create an attachment of the Booking form and attach it too the Customer Approval

        }
        return null;
	}

	/*
	 * ACTION: UPDATE ADDRESS & CONTACT
	 *
	 */
	public pageReference updateAddAndContant(){
		
		update allSubSites;
		
		List<Subscription_Site__c> subSites = new List<Subscription_Site__c>();
		subSites = getSubSites();
		
		return null;
	}

	/*
	 * ACTION: SEND TO CUSTOMER
	 * 
	 * Sales rep clicks the button on the form to send the form to the customer
	 * 
	 */
	public pageReference sendToCustomer(){

    	Opportunity opp = [SELECT StageName, Owner.Email FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
		OpportunityContactRole oppContactRole = [SELECT ContactId, Contact.Name, Contact.Salutation, Role, Contact.Email, Contact.Title FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId = :this.opp.Id LIMIT 1][0];
		
		Boolean error = false;
		String errMsg;
		if(!(opp.StageName == 'Quote/Proposal' || opp.StageName == 'Negotiation' || opp.StageName == 'Create Renewal')){
			error = true;
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The order cannot be sent to the customer because the Opportunity is not at the stage: "Quote/Proposal", "Negotiation" or "Create Renewal". Update the stage before sending the form');
			ApexPages.addMessage(myMsg);
		}
		
		if (!error){
			// Create email & send to customer
			// Create email activity on opportunity
			
			// Reserve email capacity for the current Apex transaction to ensure,
			// that we won't exceed our daily email limits when sending email.
			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {oppContactRole.Contact.Email};
			mail.setToAddresses(toAddresses);
			//mail.setReplyTo('support@acme.com');
			//mail.setSenderDisplayName('Salesforce Support');
			mail.setSubject('British Safety Council Order');
			mail.setUseSignature(true);
			mail.setPlainTextBody('Thankyou for your order. Please click the following link to confirm your order. \n\n'+this.url+'?id='+this.opp.Id+'&hash='+getHash()+'\n\n If you need and alteration to the order please use the options at the bottom of the page. If you have any other questions please let me know.');

		    System.debug('Sent email to customer: '+oppContactRole.Contact.Email);
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The booking form has been sent to the customer.');
			ApexPages.addMessage(myMsg);
			
		}
		//setSharingRules('create');
		
		return null;
	}

	/*
	 * ACTION: Sets a site a primary
	 * 
	 * Sales rep clicks the button on the form to send the form to the customer
	 * 
	 */
	public pageReference makePrimarySite(){
		
		Opportunity opp = [SELECT Subscription__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
		
		System.debug('FJP1: '+ApexPages.currentPage().getParameters());
		Id siteId = ApexPages.currentPage().getParameters().get('siteId');
		List<Subscription_Site__c> subSites = new List<Subscription_Site__c>([SELECT 
																Id,
																Type__c
																FROM Subscription_Site__c WHERE Subscription__c = :opp.Subscription__c AND (Site_Account__r.isPersonAccount = false OR Site_Account__r.isPersonAccount = true OR Site_Account__r.isPersonAccount = null)]);
		
		System.debug('FJP siteId: '+siteId);
		
		if (subSites.isEmpty()){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find Site to make primary');
			ApexPages.addMessage(myMsg);
			
		}else{
			for(Subscription_Site__c subSite : subSites){
				System.debug('FJP subSiteId: '+subSite.Id);
				if (subSite.Id == siteId){
					subSite.Type__c = 'Multi-Site Primary';
				}else{
					subSite.Type__c = 'Multi-Site Subsidary';
				}
			}
			update subSites;
			// Refresh Subsites:
			subSites = getSubSites();
		}
		return null;
	}

	/*
	 * ACTION: Remove a Site product from a subscription site on the form
	 * 
	 */
	public pageReference removeSiteProduct(){
		
		// XXX NEEDS TO BE TESTED
		Id siteProductId = ApexPages.currentPage().getParameters().get('siteProduct');
		System.debug('Removing Sub Site Product from Sub Site: '+siteProductId);
		
		Site_Product__c siteProduct = [SELECT 
											Id, 
											Subscription_Line__c 
										FROM 
											Site_Product__c 
										WHERE 
											Id = :siteProductId
										LIMIT 1][0];
		
		// Increment the availablity of the product so that it can be re-allocated.
		Subscription_Line__c subscriptionLine = [SELECT 
													Id, 
													Quantity_Available__c 
												FROM 
													Subscription_Line__c 
												WHERE 
													Id = :siteProduct.Subscription_Line__c
												LIMIT 1][0];
		subscriptionLine.Quantity_Available__c = subscriptionLine.Quantity_Available__c +1;
		update subscriptionLine;
		
		delete siteProduct;
		
		this.allSubSites = getSubSites();
		
		return null;
	}
	
	/*
	 * ACTION: Add a Site product to a subscription site on the form
	 * 
	 */
	public pageReference addSiteProduct(){
		
		Opportunity oppSub = [SELECT Subscription__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
		
		Id subLineId = ApexPages.currentPage().getParameters().get('module');
		Id subSiteId = ApexPages.currentPage().getParameters().get('subSiteId');
		System.debug('Adding Sub Site Product from Sub Site: '+subSiteId+' subLineId ='+subLineId);
		
		Site_Product__c siteProduct = new Site_Product__c(
												Subscription__c = oppSub.Subscription__c,
												Subscription_Line__c = subLineId,
												Subscription_Site__c = subSiteId
		);
		
		insert siteProduct;

		Subscription_Line__c subLine = [SELECT Id, Quantity_Available__c FROM Subscription_Line__c WHERE Id = :subLineId LIMIT 1][0];
		subLine.Quantity_Available__c = subLine.Quantity_Available__c - 1;
		update subLine;		
		
		this.allSubSites = getSubSites();
		
		return null;
	}

	/* 
	 * SET SHARING RULES
	 * 
	 * Sets the sharing permissions needed for the form to be seen by an external user.
	 * 
	 * @arg		action		create | destory		Creates or deletes the manual sharing rules required for sites
	 *												user to access all information on the form.
	 */
	private Boolean setSharingRules(String action){
		
		Opportunity oppSub = [SELECT Subscription__c FROM Opportunity WHERE Id = :this.opp.Id LIMIT 1][0];
		
		if (action == 'create'){
			// Add opportunity sharing rule
			System.debug('Create Manual sharing rules requested');

			OpportunityShare oppShare = new OpportunityShare(
												UserOrGroupId = SITES_GROUP_ID,
												OpportunityId = this.opp.Id,
												OpportunityAccessLevel = 'Read'
			);
			insert oppShare;
			
			// Add Subscription sharing rule
			Subscription__Share subShare = new Subscription__Share(
												UserOrGroupId = SITES_GROUP_ID,
												ParentId = oppSub.Subscription__c,
												AccessLevel = 'Edit'
			);
			insert subShare;
			
		
		}else if(action == 'destroy'){
			System.debug('Destroy Manual sharing rules requested');
			OpportunityShare oppShare = [SELECT Id FROM OpportunityShare WHERE OpportunityId = :this.opp.Id AND UserOrGroupId = :SITES_GROUP_ID];
			delete oppShare;
			
			Subscription__Share subShare = [SELECT Id FROM Subscription__Share WHERE ParentId = :oppSub.Subscription__c AND UserOrGroupId = :SITES_GROUP_ID];
			delete subShare;
		}
		
		return true;
	}
	
	
	private String getHash(){
		
		String inputStr = 'sjej2'+this.opp.Id;
		
		System.debug('md5 String: '+inputStr);
		String algorithmName = 'MD5';
      	Blob mac = Crypto.generateDigest(algorithmName, Blob.valueOf(inputStr));
    	String macUrl = EncodingUtil.urlEncode(EncodingUtil.ConvertToHex(mac), 'UTF-8');
	
		return macUrl;
	}

    @IsTest
    private static void testMembershipPage(){
        
        Account acc = new Account (
            Name = 'Test Acc',
            Phone = '00000',
            BillingCountry = 'United Kingdom',
            Principle_Address_Country__c = 'United Kingdom'
            );
        insert acc;
        
        Contact contact = new Contact (
        	Active__c = True,
        	Email = 'bsc+testscriptemail@netstronghold.com',
        	FirstName = 'TestFirst',
        	LastName = 'TestLast',
        	MailingCountry = 'United Kingdom',
        	Title = 'Mr'
        );
        insert contact;
        
        Subscription__c sub = new Subscription__c(
        	Start_Date__c = Date.today()+7,
        	End_Date__c = Date.today()+372,
        	Account_Name__c = acc.Id,
        	Contact__c = contact.Id,
        	Status__c = 'Current',
        	Type__c = 'New'
        );
        insert sub;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Subscription__c = sub.Id,
            Name = 'Test Opp',
            StageName = 'Qualifying',
            IC_Price_Variation_Approved__c = true,
            CloseDate = System.today());
        insert opp;
        
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
        
        OpportunityContactRole oppContRole = new OpportunityContactRole(
        	ContactId = contact.Id,
        	OpportunityId = opp.Id,
        	IsPrimary = true
        );
        
        insert oppContRole;
        
        Special_Event__c event = new Special_Event__c(
            Product__c = prod.Id,
            City__c = 'London',
            StartDate__c = System.today().addDays(3));
        insert event;

        //EventApplicationForm controller = new EventApplicationForm();

        List<Opportunity> oppQuery = [
            SELECT
                Id,
                Name,
                IsWon,
                IsClosed,
                StageName,
                AccountId,
                Opportunity_Number__c,
                OwnerId,
                Owner.Email,
                Owner.Phone,
               (SELECT
                    Id,
                    PricebookEntry.Product2.Name,
                    PricebookEntry.Product2.Allows_Provisional_Bookings__c, Quantity,
                    UnitPrice From OpportunityLineItems)
            FROM
                Opportunity
            WHERE
                Id = :opp.id];
                                        
        if (oppQuery.size() == 1)
            opp = oppQuery.get(0);
        
        test.startTest();
 		
 		ApexPages.Standardcontroller stdContr = new ApexPages.Standardcontroller(opp);
        MembershipApplicationForm controller = new MembershipApplicationForm(stdContr);
        
        controller.confirmTerms = True;
        controller.opp = opp;
                
        OpportunityLineItem [] oppLines = controller.getOppLines();
        Decimal oppTotal = controller.getOppTotal();
        OpportunityContactRole contactRole = controller.getContactRole();
		List<Decimal> taxAmounts = controller.getTaxAmounts();
		List<Subscription_Site__c> subSites = controller.getSubSites();
		String currSymbol = controller.getCurrSymbol();
		List<Subscription_Line__c> availProducts = controller.getAvilProducts();
		Integer avilProductsCount = controller.getAvilProductsCount();
		Customer_Approval__c custAproval = controller.getCustApproval();
        
        controller.updateSite();
		controller.updateAddAndContant();
		controller.sendToCustomer();
		controller.sendToAE();
		controller.confirmBooking();
		/*
		makePrimarySite()
		removeSiteProduct()
        */
        
        test.stopTest();
        
    }
}