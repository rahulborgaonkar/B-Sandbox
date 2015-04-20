trigger SiteProductTrigger on Site_Product__c (after update) {

	SiteProductTriggerMethods.setSubSiteProductCodes(Trigger.new);
}