trigger SubscriptionSiteTrigger on Subscription_Site__c (after insert, after update, before update, after delete) {
	
	System.debug('** SubscriptionSiteTrigger');

	if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
		
		if(ApexCodePatrol.execute('AccountSubscriptionFlags')){
			// Accounts to update
			Set<Id> accsToUpdate = new Set<Id>();
			
			if(Trigger.isDelete){
				for(Subscription_Site__c subSite : Trigger.old){
					// Get unique accounts
					if (subSite.Site_Account__c !=null){
						accsToUpdate.add(subSite.Site_Account__c);
					}
				}
				System.debug('FJP Acc Sites to Update1'+accsToUpdate);
				AccountMemberCheck.setAccountMemberFlagByAcc(accsToUpdate);
			}
			
			if (!Trigger.isDelete){
				for(Subscription_Site__c subSite : Trigger.new){
					// Get unique accounts
					if (subSite.Site_Account__c !=null){
						accsToUpdate.add(subSite.Site_Account__c);
					}
				}
				if (Trigger.isUpdate){
					// Update the old account to potentially remove the memberflag from the site.
					for(Subscription_Site__c subSite : Trigger.old){
						// Get unique accounts
						if (subSite.Site_Account__c !=null){
							accsToUpdate.add(subSite.Site_Account__c);
						}
					}
				}
				System.debug('FJP Acc Sites to Update2'+accsToUpdate);
				AccountMemberCheck.setAccountMemberFlagByAcc(accsToUpdate);
			}
		}
	}
	
	if (Trigger.isUpdate && Trigger.isBefore){
		
		// Create Vouchers if required:
		SubscriptionSiteTriggerMethods.createVoucher(Trigger.new);

		// Check to see if the active flag has changed and if so disable products / sub lines (created so
		// that renewals knows not to renew sites/products/sub lines for sites that are disabled.
		Map<Id,Subscription_Site__c> newSubSiteMap = Trigger.newMap;
		Map<Id,Subscription_Site__c> oldSubSiteMap = Trigger.oldMap;
		List<Subscription_Site__c> deactivatedSubSitesToUpdate = new List<Subscription_Site__c>();
		List<Subscription_Site__c> activatedSubSitesToUpdate = new List<Subscription_Site__c>();
		
		for (Id subSiteId:newSubSiteMap.keySet()){
			Subscription_Site__c myNewSubSite = newSubSiteMap.get(subSiteId);
			Subscription_Site__c myOldSubSite = oldSubSiteMap.get(subSiteId);
			if (myNewSubSite.Active__c <> myOldSubSite.Active__c){
			   
				if (myNewSubSite.Active__c == true){
					activatedSubSitesToUpdate.add(myNewSubSite);
				}else{
					deactivatedSubSitesToUpdate.add(myNewSubSite);
				}
			}
		}
		System.debug('Subscription Sites to be resynced: '+activatedSubSitesToUpdate);
		ApexCodePatrol.disable('AccountSubscriptionFlags');
		if (activatedSubSitesToUpdate.size() > 0){
			// More than one site exists so do update
			SubscriptionSiteTriggerMethods.activateSubSites(activatedSubSitesToUpdate);
		}
		if (deactivatedSubSitesToUpdate.size() > 0){
			// More than one site exists so do update
			SubscriptionSiteTriggerMethods.deactivateSubSites(deactivatedSubSitesToUpdate);
		}
		ApexCodePatrol.enable('AccountSubscriptionFlags');
	
		// Update voucher product codes if needed
		SubscriptionSiteTriggerMethods.updateVoucherProdCodesAndQty(Trigger.new, true);
	
	}
	
}