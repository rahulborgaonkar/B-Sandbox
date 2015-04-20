trigger SubscriptionTrigger on Subscription__c (after insert, after update, after delete, before update) {
	
	System.debug('** SubscriptionTrigger');

	
	if (Trigger.isAfter){		
		
		// START: Update account member flags based on subscription changes
		
		if(ApexCodePatrol.execute('AccountSubscriptionFlags')){
			
			if(Trigger.isDelete){
				AccountMemberCheck.setAccountMemberFlag(Trigger.old);
			}
			
			if (!Trigger.isDelete){
				AccountMemberCheck.setAccountMemberFlag(Trigger.new);
			}
		}
		// END: Update account member flags based on subscription changes
	}
	
	// List to hold subscriptions that vouchers need to be created for.
	List<Subscription__c> subsForVoucherCreation = new List<subscription__c>();
	
	// START: Check if subscriptions have changed to paid and if so fire off sites to print certs.
	if (Trigger.isBefore && Trigger.isUpdate){
		System.debug('Checking to see if certificates need to printed on subscriptions');
		Set<Subscription__c> subsToPrintCerts = new Set<Subscription__c>();
		
		Map<Id,Subscription__c> newSubMap = Trigger.newMap;
		Map<Id,Subscription__c> oldSubMap = Trigger.oldMap;
		
		for (Id subId:newSubMap.keySet()){
			Subscription__c myNewSub = newSubMap.get(subId);
			Subscription__c myOldSub = oldSubMap.get(subId);
			
			if ((myNewSub.Invoice_Status__c <> myOldSub.Invoice_Status__c && myNewSub.Invoice_Status__c == 'Paid') || myNewSub.Print_Certificates__c == True){
				System.debug('Subscription '+subId+' invoice status has changed to paid or subscription needs printed');
				subsToPrintCerts.add(myNewSub);
				myNewSub.Print_Certificates__c = False;
			}
			System.debug('New Status: '+myNewSub.Status__c);
			System.debug('Old Status: '+myOldSub.Status__c);
			
			// Check to see if status has changed to current and if so maybe need to create vouchers:
			if (myNewSub.Status__c =='Current' && myOldSub.Status__c != 'Current'){
				subsForVoucherCreation.add(myNewSub);
			}
		}
		if (subsToPrintCerts.size() > 0){
			SubscriptionTriggerMethods.setSubForCertPrinting(subsToPrintCerts);
		}

	}
	// END: Check if subscriptions have changed to paid and if so fire off sites to print certs.
	
	// START: Check to see if subscriptions has changed status to current and if so create voucher if not yet created
	if (Trigger.isAfter && Trigger.isUpdate){
		
		Map<Id,Subscription__c> newSubMap = Trigger.newMap;
		Map<Id,Subscription__c> oldSubMap = Trigger.oldMap;
		
		for (Id subId:newSubMap.keySet()){
			Subscription__c myNewSub = newSubMap.get(subId);
			Subscription__c myOldSub = oldSubMap.get(subId);
			
			// Check to see if status has changed to current and if so maybe need to create vouchers:
			if (myNewSub.Status__c == ('Current') && myOldSub.Status__c != ('Current') && myNewSub.Includes_Membership_Product__c == True){
				subsForVoucherCreation.add(myNewSub);
			}

		}
	}
	
	System.debug('Sub Voucher update list '+subsForVoucherCreation.size());
	
	if (subsForVoucherCreation.size() > 0){
		List<Subscription_Site__c> subSitesToUpdate = SubscriptionSiteTriggerMethods.createVoucher(subsForVoucherCreation);
		update subSitesToUpdate;
	}

	// END: Check to see if subscriptions has changed status to current and if so create voucher if not yet created

	// START: Update child or parent subscriptions if the subscription status needs to be changed.
	if (Trigger.isAfter && Trigger.isUpdate){
		if(ApexCodePatrol.execute('subscriptionStatusUpdates')){
			SubscriptionTriggerMethods.updateSubequentStatus(Trigger.new);
		}
	}
	// END: Update child or parent subscriptions if the subscription status needs to be changed.

	/*
	if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){

		
		if (Trigger.oldMap([0]).status <> subscriptionNew[0].status) && subscriptionNew.status = current {
			get subscription__r.subscription_site
			select subscription_site__c.id from subscription_site__c 
			where subscription_site__c.Subscription__c.id = Trigger.subscription__c.id
				set subscription_site__c.newcode=
				subscription_site__c.Site Number+Rand(4)
			update sites
		}

	}*/
}