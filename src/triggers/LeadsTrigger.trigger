trigger LeadsTrigger on Lead (before Insert, before Update) {

    LeadManagement__c lmSetting;
    
    if (lmSetting == null)
         lmSetting = LeadManagement__c.getOrgDefaults();
    
    if (lmSetting.Enable_Triggers__c){
        
        System.Debug('Executing Lead Trigger');
        
        if (trigger.isUpdate && trigger.isBefore){
            
            list<Lead> updateLeads = new list<Lead>();
            
            for (integer i = 0; i < trigger.new.size(); i++){
                if (trigger.New[i].Exclude_from_Auto_Assignment__c == false &&
                    (trigger.New[i].NumberOfEmployees != trigger.Old[i].NumberOfEmployees || 
                     trigger.New[i].Principle_Address_Country__c != trigger.Old[i].Principle_Address_Country__c || 
                     trigger.New[i].Principle_Address_ZIP_Postal_Code__c != trigger.Old[i].Principle_Address_ZIP_Postal_Code__c ||
                     trigger.New[i].Exclude_from_Auto_Assignment__c !=  trigger.Old[i].Exclude_from_Auto_Assignment__c) )
                    updateLeads.add(trigger.New[i]);
            }
            
            System.Debug('Update Leads Started'+ trigger.new.size() );
            
        	LeadManagement.assignOwners(updateLeads);
            
            System.Debug('Update Leads Complete');
        }
        
        if (trigger.isInsert && trigger.isBefore){
            System.Debug('Inserting Leads Started'+ trigger.new.size() );
            
            list<Lead> insertLeads = new list<Lead>();
            
            for (integer i = 0; i < trigger.new.size(); i++){
                if (trigger.New[i].Exclude_from_Auto_Assignment__c == false)
                    insertLeads.add(trigger.New[i]);
            }
        	LeadManagement.assignOwners(insertLeads);
            
            System.Debug('Inserting Leads Complete');
        }
        
    } else {
        System.Debug('Lead Triggers Disabled');
    }

}