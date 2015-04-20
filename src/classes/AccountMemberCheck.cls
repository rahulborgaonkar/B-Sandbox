public with sharing class AccountMemberCheck {
	
	/*
	 * SET ACCOUNT MEMBER FLAG BY SUB SITE
	 *
	 * Gets a set of unique accounts from the list of sub sites passed and then calls the account
	 * flags update.
	 */
	public static void setAccountMemberFlagBySubSite(Set<Subscription_Site__c> subSiteList){
		
		List<Account> accs = new List<Account>();
		for (Subscription_Site__c subSite : subSiteList){
			
		}
	}
	
	/**
	* Method: isAccountMember
	* New trigger, we need to update the checkbox "Member" 
    * on the account based on whether the account has a subscription site, 
    * which has a site product, where "Membership Product" = TRUE
    * but only when the subscription to which the subscription site is linked has
    * a status that starts with current
    *
    * acc.Subscription_Site__c.Membership_Product__c = true
    * acc.Subscription_Site__c.Subscription__c.Status like 'Current%'
    * 
	**/
	public static void setAccountMemberFlagByAcc(Set<Id> accList){
		
		List<Account> accUpdList = new List<Account>();
		List<Account> accObjList = new List<Account>([SELECT 
				Id, 
				Member__c, 
				Subscriber__c,
				E_Delivery_Subscriber__c,
				(SELECT Subscription__r.Includes_RCP_Product__c, 
						Subscription__r.Includes_Membership_Product__c, 
						Subscription__r.Includes_E_Delivery_Product__c,
						Subscription__r.Includes_Publication_Product__c
				 	FROM 
				 		Multi_Site_Subscription_Sites__r
				 	WHERE
				 		//Site_Status__c like 'Current%' AND
				 		Subscription__r.Status__c like 'Current%' AND
				 		Active__c = True AND
				 		Cancelled__c = False
				 		) 
			FROM 
				Account 
			WHERE Id IN :accList]);
		
		System.debug('Account List: '+accObjList);
		
		for (Account acc : accObjList){

			boolean statusHasChanged = false;
			boolean isAccountMember = false;
			boolean isSubscriptionMember = false;
			boolean isEDeliveryMember = false;
			
			if (acc !=null){
				for(Subscription_Site__c subSite : acc.Multi_Site_Subscription_Sites__r){					
					System.debug(subSite);
					if (subSite.Subscription__r.Includes_Membership_Product__c == true){
						System.debug(acc.Id+' has membership from subscription: '+subSite.Id);
						isAccountMember = true;
					}
					if (subSite.Subscription__r.Includes_Publication_Product__c == true){
						System.debug(acc.Id+' has subscription from subscription: '+subSite.Id);
						isSubscriptionMember = true;
					}					
					if (subSite.Subscription__r.Includes_E_Delivery_Product__c == true){
						System.debug(acc.Id+' has eDelivery Subscription from subscription: '+subSite.Id);
						isEDeliveryMember = true;
					}	
				}
				
				if ((acc.Subscriber__c <> isSubscriptionMember) || (acc.Member__c <> isAccountMember) || (acc.E_Delivery_Subscriber__c <> isEDeliveryMember)){
					// Change has been made to this accounts status
					statusHasChanged = True;
				}
				
			}
			
			System.debug('FJP** ACC Fields: Mem:' + acc.Member__c + ' Sub:'+acc.Subscriber__c);
			System.debug('FJP** isAccountMember: ' + isAccountMember);
			System.debug('FJP** isSubscriber: ' + isSubscriptionMember);
			System.debug('FJP** Status has Changed: ' + statusHasChanged);
			
			// Add account to update list if the status has changed in anyway
			if (statusHasChanged){
				if (acc.Member__c <> isAccountMember){
					acc.Member__c = isAccountMember;
				}
				if (acc.Subscriber__c <> isSubscriptionMember){
					acc.Subscriber__c = isSubscriptionMember;
				}
				if (acc.E_Delivery_Subscriber__c <> isEDeliveryMember){
					acc.E_Delivery_Subscriber__c = isEDeliveryMember;
				}
				accUpdList.add(acc);
			}
		}
		System.debug('FJP Updating: '+accUpdList);
		update accUpdList;
	}

	/*
	 * SET ACCOUNT MEMBER FLAG
	 * 
	 * Sets the account member flag but unlike above works based on the subscription not just the account.
	 */
	public static void setAccountMemberFlag(List<Subscription__c> subsList){
		
		// List of all accounts that need to be updated 
		Set<Id> accsToUpdate = new Set<Id>();
		
		for(Subscription_Site__c subSite : [SELECT Site_Account__c
											FROM Subscription_Site__c
											WHERE Subscription__c IN :subsList AND Site_Account__c != null]){
			if (!accsToUpdate.contains(subSite.Site_Account__c)){
				accsToUpdate.add(subSite.Site_Account__c);
			}
		}
		
		System.debug('Disabling AccountReAssignment');
		ApexCodePatrol.disable('AccountReAssignment');
		
		setAccountMemberFlagByAcc(accsToUpdate);

		ApexCodePatrol.enable('AccountReAssignment');

	}
	
}