public with sharing class CleanUpUtilities
{
	public static void opportunitiesCleanup(List<Opportunity> opps)
	/*
	  During the BatchUpdateAccountHierarchy, opportunity Owners have been
	  reassigned to the Account Owner.  This method will reassign the Opportunity
	  to the Creater of the Opportunity.
	  There are however certain exceptions
	  1) Ignore Disable Reassignments
	  2) Ignore where the Renewal Flag is ticked
	  3) Ignore where the created by is inactive
	  4) Opportunity Closed Date is greater than 23 Feb 
	*/
	{
		List<Opportunity> updateOpportunityList = new List<Opportunity>();
		Opportunity updateOpportunity = new Opportunity();
		for (Opportunity o:opps)
		{
			if (o.CreatedBy.name == '2020 Management'||
				o.CreatedBy.name == 'Steve Ward'||
				o.CreatedBy.name == 'Martin Bow'||
				o.CreatedBy.name == 'Sheila Lacey'||
				o.CreatedBy.name == 'Will Murray-Jones'||
				o.CreatedBy.name == 'Misbah Harun-Popat'||
				o.CreatedBy.name == 'Vandana Singal'||
				o.CreatedBy.name == 'Karen Louden'||
				o.CreatedBy.name == 'James Ing'||
				o.CreatedBy.name == 'Chris Warburton'||
				o.CreatedBy.name == 'Adam Cartledge'||
				o.CreatedBy.name == 'Kim Shears'||
				o.CreatedBy.name == 'Kathy Wheeler'||
				o.CreatedBy.name == 'Jack Ingram'||
				o.CreatedBy.name == 'Roisin Anderson'||
				o.CreatedBy.name == 'Helen Kent'||
				o.CreatedBy.name == 'Lisa Gilchrist'||
				o.CreatedBy.name == 'Alex Lovie'||
				o.CreatedBy.name == '2020 Development'||
				o.CreatedBy.name == 'Anja Rapo'||
				o.CreatedBy.name == 'Anna Harkiewicz'||
				o.CreatedBy.name == 'Louise Poulton'||
				o.CreatedBy.name == 'Sophie Davis'||
				o.Owner.IsActive == false)
			{
				o.ownerId = o.account.ownerId;
				
			}
			else
			{
				o.ownerId=o.createdById;
			}
			//updateOpportunityList.add(updateOpportunity);
		}
		// System.debug(updateOpportunityList);
		update opps;
	}
	
	static testMethod void testOpportunitiesCleanup()
	{		
		List<Opportunity> opp = [Select o.Id, o.OwnerId, o.Owner.isActive, o.CreatedBy.name, o.Account.OwnerId from Opportunity o Where o.Disable_re_assignment__c = False and o.Renewal_Opportunity__c = false and o.AccountId!=null and (o.isclosed = false or o.CloseDate > 2011-02-23) limit 1];
		test.startTest();
		opportunitiesCleanup(opp);
		test.stopTest();
	}

}