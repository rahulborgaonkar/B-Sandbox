public with sharing class SubscriptionSiteTriggerMethods {

    /*
     * CONSTRUCTOR
     */
    public SubscriptionSiteTriggerMethods(){}
    
    /*
     * PUBLIC METHODS
     */

    /*
     * ACTIVATE SUBSCRIPTION SITE ACTIONS
     *
     * Update qty's for renewal on subline IDs
     */
    public static void activateSubSites(List<Subscription_Site__c> subSites){
        updateQtyOnSubLines(subSites, true);
    }

    /*
     * DEACTIVATE SUBSCRIPTION SITE ACTIONS
     *
     * Update qty's for renewal on subline IDs
     */
    public static void deactivateSubSites(List<Subscription_Site__c> subSites){
        updateQtyOnSubLines(subSites, false);
    }
    
    /*
     * UPDATE VOUCHER PRODUCT CODES & QUANTITY
     *
     * Updates the voucher products codes on the subscription site if the product attached to the site
     * has a voucher product code attached to it. 
     */
    public static void updateVoucherProdCodesAndQty(List<Subscription_Site__c> triggerSubSites, Boolean beforeTrigger){
    	
    	List<Subscription_Site__c> subSites = new List<Subscription_Site__c>();
    	for (Subscription_Site__c subSite : triggerSubSites){
    		if (subSite.Site_Status__c == 'Current' || subSite.Site_Status__c == 'Pending - Paid'){
    			subSites.add(subSite);
    		}
    	}
    	if (subSites.size() > 0){
	    	List<Subscription_Site__c> allSubSites = new List<Subscription_Site__c>([SELECT
	    											Id,
	    											Voucher_Product_Codes__c,
	    											Site_Status__c,
	    											(SELECT
	    												Id,
	    												Subscription_Line__r.Product__r.Voucher_product_codes__c,
	    												Subscription_Line__r.Product__r.Duration_Years__c,
	    												Subscription_Line__r.Product__r.Subscription_Product__c
	    												FROM
	    													Site_Products__r
	    												WHERE
	    													Subscription_Line__r.Product__r.Voucher_product_codes__c <> '' AND
	    													Subscription_Line__r.Product__r.Subscription_Product__c = True)
	    											FROM
	    												Subscription_Site__c
	    											WHERE
	    												Id IN :subSites]);
	    	
	    	for (Subscription_Site__c subSite : allSubSites){
	    		
				// Get site status based on trigger.new values not DB query
				String siteStatus = 'unknown';
	
				for (Subscription_Site__c singleSite : subSites){
	    			if (singleSite.id == subSite.id){
	    				siteStatus = singleSite.Site_Status__c;
	    			}
	    		}
	    		if (siteStatus == 'Current' || siteStatus == 'Pending - Paid'){
		    		String strVoucherProdCodes = '';
		    		Decimal decVoucherQty = 0;
	
		    		for (Site_Product__c subSiteProd : subSite.Site_Products__r){
		    			if (strVoucherProdCodes == ''){
		                	strVoucherProdCodes=subSiteProd.Subscription_Line__r.Product__r.Voucher_product_codes__c;
		                }else{
		                	strVoucherProdCodes=strVoucherProdCodes + ';' + subSiteProd.Subscription_Line__r.Product__r.Voucher_product_codes__c;
		    			}
		    			if (subSiteProd.Subscription_Line__r.Product__r.Subscription_Product__c == true){
			    			decVoucherQty = decVoucherQty+(subSiteProd.Subscription_Line__r.Product__r.Duration_Years__c*100);
		    			}
		    		}    		
		    		System.debug('prod codes: '+strVoucherProdCodes);
		    		subSite.Voucher_Product_Codes__c = strVoucherProdCodes;
		    		
		    		if (beforeTrigger){
			    		// find subsite in trigger list and update prodcodes
			    		for (Subscription_Site__c singleSite : subSites){
			    			if (singleSite.id == subSite.id){
			    				System.debug('found record');
			    				singleSite.Voucher_Product_Codes__c = strVoucherProdCodes;
			    				singleSite.Voucher_Max_Qty__c = decVoucherQty;
			    			}
			    		}
		    		}else{
		    			subSite.Voucher_Product_Codes__c = strVoucherProdCodes;
		    			subSite.Voucher_Max_Qty__c = decVoucherQty;
		    		}
	    		}
	    	}
	    	if (!beforeTrigger){
		    	update allSubSites;
	    	}
    	}
    }
    
    /*
     * PRIVATE METHODS
     */
     
    /*
     * UPDATE QTY ON SUB LINES
     *
     * When a site is deactivated or activated the subscription line renewal quantity needs to incremented or decremented.
     */
    private static void updateQtyOnSubLines(List<Subscription_Site__c> subSites, Boolean isChangedToActive){
        
        Map<Id, Decimal> subLineQty = new Map<Id, Decimal>();
        
        // Get Products the reated products for each sub site
        for(Subscription_Site__c subSite : [SELECT
                Id,
                (SELECT
                        Id,
                        Subscription__c,
                        Subscription_Line__c,
                        Subscription_Line__r.Quantity__c,
                        Subscription_Line__r.Renewal_Quantity__c
                    FROM
                        Site_Products__r)
            FROM
                Subscription_Site__c
            WHERE
                Id IN :subSites
            ]){
            
            for (Site_Product__c subSiteProd : subSite.Site_Products__r){
                // Add the initial qty to the map so that it can be manipulated.
                if(subLineQty.get(subSiteProd.Subscription_Line__c) == null){
                    System.debug('Sub not in map :: Add subscription line to map');
                    if (subSiteProd.Subscription_Line__r.Renewal_Quantity__c == null){
                        System.debug('Subscription line has no renewal quantity ('+subSiteProd.Subscription_Line__r.Renewal_Quantity__c+')');
                        subLineQty.put(subSiteProd.Subscription_Line__c, subSiteProd.Subscription_Line__r.Quantity__c);
                    }else{
                        System.debug('Subscription line has a renewal quantity ('+subSiteProd.Subscription_Line__r.Renewal_Quantity__c+')');
                        subLineQty.put(subSiteProd.Subscription_Line__c, subSiteProd.Subscription_Line__r.Renewal_Quantity__c);
                    }
                }
                
                // remove the record to re-add it with the new value.
                Decimal origRenewalQty = subLineQty.remove(subSiteProd.Subscription_Line__c);
    
                if (isChangedToActive){
                    subLineQty.put(subSiteProd.Subscription_Line__c,origRenewalQty+1);
                }else{
                    subLineQty.put(subSiteProd.Subscription_Line__c,origRenewalQty-1);
                }
            }
        }
        
        Set <Id> subLineIds = new Set<Id>();
        subLineIds = subLineQty.keySet();
        
        List<Subscription_Line__c> subLinesToUpd = new List<Subscription_Line__c>([SELECT 
                Id, 
                Renewal_Quantity__c
            FROM
                Subscription_Line__c
            WHERE
                Id IN :subLineIds
        ]);
        
        for(Subscription_Line__c subLine : subLinesToUpd){
            subLine.Renewal_Quantity__c = subLineQty.get(subLine.Id);
        }
        System.debug('Subscription Lines updating: '+subLinesToUpd);
        update subLinesToUpd;
    }
    
    /*
     * CREATE VOUCHER (with Sub Sites)
     *
     * Creates a voucher for the subscription site if the subscription site has a current subscription.
     *
     * @returns List<SubscriptionSite__c>  List of all sub sites that have had a voucher added to them.
     */
    public static List<Subscription_Site__c> createVoucher(List<Subscription_Site__c> subSites){
        
        System.debug('Voucher Creation Method');
        List<Subscription_Site__c> sitesUpdated = new List<Subscription_Site__c>();
        
        for(Subscription_Site__c subSite : SubSites){
            if (subSite.Site_Status__c == 'Current' || subSite.Site_Status__c == 'Pending - Paid'){
                if (subSite.Voucher__c == null){
                    System.debug('Creating Voucher');
                    subSite.Voucher__c = subSite.Name + Math.round(Math.random()*10000);
                    subSite.Voucher_created_at__c = System.now();
                    sitesUpdated.add(subSite);
                }else{
                    System.debug('Voucher Already created');
                    
                }
            }else{
                System.debug('Not creating voucher Subscription Site not \'Current\' yet.');
            }
        }
        return sitesUpdated;
    }
    
    /*
     * CREATE VOUCHER (with Subs)
     *
     * Creates vouchers for the subscription's sub sites if the subscription site status is current.
     *
     * @returns List<SubscriptionSite__c>  List of all sub sites that have had a voucher added to them.
     */
    public static List<Subscription_Site__c> createVoucher(List<Subscription__c> subs){
    
        List<Subscription_Site__c> subSites = new List<Subscription_Site__c>([SELECT
                Id,
                Site_Status__c,
                Voucher__c,
                Voucher_created_at__c,
                Name
            FROM
                Subscription_Site__c
            WHERE
                Subscription__c IN :subs
        ]);
        
        List<Subscription_Site__c> subSiteResults = createVoucher(subSites);
        return subSiteResults;
    }
    
    private static void updateQtyOnSubLines(List<Subscription__c> subs){
        
    }
    
}