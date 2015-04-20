trigger SubscriptionLineTrigger on Subscription_Line__c (after update, after delete, before update) {

	// updateInvoiceStatus on before update only:
	// SubscriptionLineTriggerMethods.updateInvoiceStatus(trigger.newMap);
	
	if(Trigger.isBefore){
		SubscriptionLineTriggerMethods.updateInvoiceStatus(trigger.newMap);
	}
	
	if(Trigger.isAfter){
		if(ApexCodePatrol.execute('AccountSubscriptionLineFlags')){
			if(Trigger.isDelete){
				SubscriptionLineTriggerMethods.updateSubscriptionProdStatus(trigger.old);
			} 
			
			if(!Trigger.isDelete){
				SubscriptionLineTriggerMethods.updateSubscriptionProdStatus(trigger.new);
				// Update sub site product codes:
				SiteProductTriggerMethods.setSubSiteProductCodes(trigger.old, trigger.new);
			}
		}	
	}
}