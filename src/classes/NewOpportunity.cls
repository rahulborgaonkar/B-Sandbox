public with sharing class NewOpportunity {

	public Boolean isFromContact {private get; private set;}
	public String contactId {private get; private set;}
	public String accountId {private get; private set;}
	public String recordTypeId {private get; private set;}
	
	// Following used for subsequent opportunity button on opportunity:
	public String oppId {private get; private set;}
	public String oppName {private get; private set;}
	public String accName {private get; private set;}
	public String subOppId {private get; private set;}
	
	public NewOpportunity(ApexPages.StandardController controller){
				
		String ret = ApexPages.currentPage().getParameters().get('RetURL');
		this.contactId = ApexPages.currentPage().getParameters().get('conid');
		this.accountId = ApexPages.currentPage().getParameters().get('accid');
		this.recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
		
		// Following used for subsequent opportunity button on opportunity:
		this.oppId = ApexPages.currentPage().getParameters().get('oppId'); // Opportunity.Id
		this.oppName = ApexPages.currentPage().getParameters().get('opp3');
		this.subOppId = ApexPages.currentPage().getParameters().get('CF00N20000002Ogr5'); // This is the ID of the opportunity.Subsequent_opportunity field.

		if (this.contactId == null && this.oppId != null){
			try{
				OpportunityContactRole oppCont = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :this.oppId AND IsPrimary = True LIMIT 1][0];
				this.contactId = (string)oppCont.ContactId;
			}catch(Exception e){

			}
		}
		
		if (this.accountId != null && this.subOppId == null){
			try {
				Account acc = [SELECT Name FROM Account WHERE Id = :this.accountId LIMIT 1][0];
				this.oppName = acc.Name+': ';
			}catch(Exception e){
				
			}
		}
		
		if (this.contactId =='null'){
			this.isFromContact = false;
			ApexPages.currentPage().getParameters().put('conid','');
			ApexPages.currentPage().getParameters().put('accid','');
		}else{
			this.isFromContact = true;
		}
	
	}
	
	public PageReference doRedirect(){
		
		System.debug('Debug details: '+this.contactId+' A: '+this.accountId+' S:'+this.isFromContact+' OId: '+this.oppId+' oppName:'+this.oppName);
		
		String redirectURL;
		
		if (this.contactId !=null){
			System.debug('FJP test2');
			redirectURL = '/006/e?nooverride=1&accid='+this.accountId+'&conid='+this.contactId+'&opp6=&RecordType='+this.recordTypeId+'&opp3='+EncodingUtil.urlEncode(this.oppName, 'UTF-8');
			
			if (this.subOppId != null){
				redirectURL = redirectURL+'&CF00N20000002Ogr5_lkid='+this.subOppId+'&CF00N20000002Ogr5='+EncodingUtil.urlEncode(this.oppName, 'UTF-8');
			}
			
		}else{
			redirectURL = '/apex/NewOpportunityError';
		}
		
		PageReference pageRef = new PageReference(redirectURL);
		
		return pageRef;
	}
}