public with sharing class SubscriptionTriggerMethods {

	/* SET SUB SITES FOR PRINTING
	 *
	 * Loops over all subscription sites to print all certificates based on the subscription sites.
	 * This does not check to see if it should print the certificates or not based on subscription status etc
	 * as this is done by the workflow rule.
	 * 
	 */
	public static List<Subscription_Site__c> setSubForCertPrinting(Set<Subscription__c> subscriptionList){
		
		List<Subscription_Site__c> subSiteList = new List<Subscription_Site__c>([SELECT
			Id,
			Print_Certificate__c
			FROM
			Subscription_Site__c
			WHERE
			Active__c = True AND
			Subscription__c IN :subscriptionList]);
		
		List<Subscription_Site__c> result = setSubSitesForCertPrinting(subSiteList);
		
		return result;
	}
	
	public static List<Subscription_Site__c> setSubSitesForCertPrinting(List<Subscription_Site__c> subSiteList){
		
		for(Subscription_Site__c subSite:subSiteList){
			subSite.Print_Certificate__c = true;
		}
		update subSiteList;
		
		return subSiteList;
	}
	
	/*
	 * UPDATE SUBSEQUENT & PREVIOUS STATUSES
	 *
	 * Based on some subscription status changing the parent or child subscription status may need to change
	 * this handles this.
	 */
	public static List<Subscription__c> updateSubequentStatus(List<Subscription__c> subList){
		
		ApexCodePatrol.disable('subscriptionStatusUpdates');
		System.debug('updateSubsequentStatus');
		
		// START: Get subscriptions for reverse looking rule updates.
		// "Subscriptions_Previous__r" below isn't the list of previous subscriptions for the subscription but subsequent.
		List<Subscription__c> oldSubsList = new List<Subscription__c>([SELECT Id, Status__c, Subsequent_Subscription__c FROM Subscription__c WHERE Subsequent_Subscription__c IN :subList]);
		
		System.debug('Old Subs List: '+oldSubsList);
		// Holder for any subscriptions that need to be updated.
		List<Subscription__c> subsToUpd = new List<Subscription__c>();
		
		
		for (Subscription__c oldSub : oldSubsList){
			
			System.debug('oldSub Status: '+oldSub.Status__c);
			Boolean subNeedingUpd = false;
			// T8 Subsequent Sub gets paid therefore: "Current - Renewing" > "Current - Renewed"
			if (oldSub.Status__c == 'Current - Renewing'){
				System.debug('Previous sub is "Current - Renewing"');
				for (Subscription__c newSub : subList){
					system.debug('newSub.Status__c : ' + newSub.Status__c);
					if ((newSub.Status__c == 'Pending - Not Paid' || newSub.Status__c == 'Pending - Paid') && newSub.Invoice_Status__c == 'Paid' && newSub.Id == oldSub.Subsequent_Subscription__c ){
						system.debug('setting oldSub.Status__c = Current - Renewed');
						oldSub.Status__c = 'Current - Renewed';
						subsToUpd.add(oldSub);
					}
				}
			}
			
			// T9 Subsequent sub status is currrent therefore: "Ended - Lapsing" > "Ended - Renewed"
			if (oldSub.Status__c == 'Ended - Lapsing' || oldSub.Status__c == 'Ended - Lapse Extended'){
				System.debug('Previous sub is "Ended - Lapsing"');
				Boolean foundStatus = false;
				for (Subscription__c newSub : subList){
					system.debug('newSub.Status__c : ' + newSub.Status__c);
					if (newSub.Status__c == 'Current' || (newSub.Status__c == 'Current - Not Paid' && newSub.Invoice_Status__c == 'Paid')  && newSub.Id == oldSub.Subsequent_Subscription__c ){
						system.debug('setting oldSub.Status__c = Ended - Renewed');
						oldSub.Status__c = 'Ended - Renewed';
						subsToUpd.add(oldSub);
					}
				}
			}	
		}
		// END: Get subscriptions for reverse looking rule updates.
		
		// START: Get subscriptions for forward looking rule updates.
		List<Subscription__c> fullSubsListFwd = new List<Subscription__c>([SELECT
				Id,
				Status__c,
				Lapse_Exception_Approved__c,
				(SELECT
					Id,
					Status__c
				FROM
					Subscriptions_Previous__r)
			FROM
				Subscription__c
			WHERE
				Id IN :subList
			]);
			
			
		for (Subscription__c sub : fullSubsListFwd){
			

			// T11 "Ended - Lapsing" > "Ended - Cancelled"
			if (sub.Status__c == 'Ended - Lapsed'){
				System.debug ('Sub found to be "Ended - Lasped"');
				for (Subscription__c subSub : sub.Subscriptions_Previous__r){
					if (subSub.Status__c != 'Ended - Cancelled'){
						System.debug ('Child Sub found that needs to be updated to "Ended - Cancelled"');
						subSub.Status__c = 'Ended - Cancelled';
						subsToUpd.add(subSub);
					}
				}
			}
			
			// T15 If old subscription = "Current - Cancelling" then set new sub "Ended - Cancelled"
			if (sub.Status__c == 'Current - Cancelling'){
				System.debug ('Sub found to be "Current - Cancelling"');
				for (Subscription__c subSub : sub.Subscriptions_Previous__r){
					if (subSub.Status__c == 'Pending - Not Paid'){
						System.debug ('Child Sub found that needs to be updated to "Pending - Not Paid"');
						subSub.Status__c = 'Ended - Cancelled';
						subsToUpd.add(subSub);
					}
				}
			}
			
			// T16 If new Subscription = "Ended - Cancelled" then old sub status = "Ended - Lapsed"
			if (sub.Status__c == 'Ended - Cancelled'){
				System.debug ('Sub found to be "Ended - Cancelled"');
				for (Subscription__c subSub : sub.Subscriptions_Previous__r){
					if (subSub.Status__c == 'Ended - Lapsing'){
						System.debug ('Child Sub found that needs to be updated to "Ended - Lapsed"');
						subSub.Status__c = 'Ended - Lapsed';
						subsToUpd.add(subSub);
					}
				}
			}
			// T17 
            // VS uncommented this code to check new sub, if current set the previous to Ended - Renewed
			if (sub.Status__c == 'Current'){
				System.debug ('Sub found to be "Ended - Cancelled"');
				for (Subscription__c subSub : sub.Subscriptions_Previous__r){
					if (subSub.Status__c == 'Ended - Lapsed' || subSub.Status__c == 'Ended - Lapsing'){
						System.debug ('Child Sub found that needs to be updated to "Ended - Renewed"');
						subSub.Status__c = 'Ended - Renewed';
						subsToUpd.add(subSub);
					}
				}
			}			
			/*		
			if (subNeedingUpd){
				subsToUpd.add(sub);
			}	
			*/		
			// T17 
			/*
			if (sub.Status__c == 'Ended - Cancelled' && sub.Lapse_Exception_Approved__c == True){
				System.debug ('Sub found to be "Ended - Cancelled"');
				sub.Status__c = 'Current - Not Paid';

				for (Subscription__c subSub : sub.Subscriptions_Previous__r){
					if (subSub.Status__c == 'Ended - Lapsed'){
						System.debug ('Child Sub found that needs to be updated to "Ended - Lapse Extended"');
						subSub.Status__c = 'Ended - Lapse Extended';
						subsToUpd.add(subSub);
					}
				}
				subsToUpd.add(sub);
			}
			*/
		}


		// END: Get subscriptions for forward looking rule updates.


		System.debug('Subs to Update:'+subsToUpd);
		
		if (subsToUpd.size() > 0){
			update subsToUpd;
		}

		ApexCodePatrol.enable('subscriptionStatusUpdates');
		return subsToUpd;
	}
	
	public testmethod static void TestSubscription()
	{
		TestHelper.CreateSpecialEventBooking();
		set<Subscription__c> setSubs = new set<Subscription__c>();
		list<Subscription__c> subslist = new list<Subscription__c>();
		setSubs.add(TestHelper.subscription);
		subslist.add(TestHelper.subscription);
		
		SubscriptionTriggerMethods.setSubForCertPrinting(setSubs);
		SubscriptionTriggerMethods.updateSubequentStatus(subslist);
		
	}
}