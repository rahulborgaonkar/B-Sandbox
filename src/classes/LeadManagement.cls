public class LeadManagement {

    public static string uk = 'United Kingdom';
    
    public static void assignOwners(list<Lead> newleads ){
        
        set<string> postcodes = new set<string>();
        set<string> countries = new set<string>();
        
        for (Lead l : newLeads){
            postcodes.add(parsePostcode(l.Principle_Address_ZIP_Postal_Code__c));
            
            if (l.Principle_Address_Country__c != uk)
            	countries.add(l.Principle_Address_Country__c);
        }
        
        system.debug(postcodes +':' + countries);    
        
        Map<String, Map<String, Area__c>> areas = getAreas(postcodes, countries);
        
        if (areas.size() > 0){
            for (Lead l : newLeads){
                
                string postcode = parsePostcode(l.Principle_Address_ZIP_Postal_Code__c);
                
                Map<String, Area__c> foundAreaMap;
                                
                if (l.Principle_Address_Country__c == uk){
                    string str= l.Principle_Address_Country__c + '-' + postcode;
                    foundAreaMap = areas.get(str.toLowerCase());
                    system.debug(str.toLowerCase());
                } else {
                    string str = l.Principle_Address_Country__c;
                    foundAreaMap = areas.get(str.toLowerCase());
                    system.debug(str.toLowerCase());
                }
                
                system.debug(foundAreaMap); 
                
                Area__c foundArea = null;
                
                if (l.NumberOfEmployees >= 1999) {
                    if(foundAreaMap.get('KAM') != null)
                        foundArea = foundAreaMap.get('KAM');
                    else {
                        if(foundAreaMap.get('RAM') != null)
                            foundArea = foundAreaMap.get('RAM');
                    }
                } else if (l.NumberOfEmployees < 1999 || l.NumberOfEmployees == null ) {
                    if(foundAreaMap.get('RAM') != null)
                        foundArea = foundAreaMap.get('RAM');
                }
                
                if (foundArea != null){
                    l.Allocated_Area__c = foundArea.Id;
                    l.OwnerId = foundArea.Territory__r.Territory_Manager__c;
                }
            }
        }
            
    }
 
    public static Map<String, Map<String, Area__c>> getAreas(Set<String> postcodes, Set<String> countries){
        
        Map<String, Map<String, Area__c>> areas = new Map<String, Map<String, Area__c>>();
        
        for (Area__c a : [SELECT Id, Name, Area_Postcode__c, Country__c, Postcode_District__c, Territory__c, Territory__r.Territory_Manager__c, Type__c  FROM Area__c WHERE (Area_Postcode__c in :postcodes AND Country__c = :uk ) or Country__c in :countries ]){
            
            String key = a.Country__c + (a.Country__c == uk ? '-' + a.Area_Postcode__c : '');
           
            key =  key.toLowerCase();
            
            if (!areas.containsKey(key))
                areas.put(key, new Map<String, Area__c>());
            
            areas.get(key).put(a.Type__c, a);
            
        }
        system.debug('Areas found: ' + areas);
        return areas;
    }
    
    public static String parsePostcode(String postcode){
        
        if (postcode != null && postcode != '') {
            
            String[] splitted = postcode.split('[0-9]');
            
            if (splitted.size() > 0 && splitted[0] != null && splitted[0] != '') 
                return splitted[0];
        }
        
        return null;
    }
    
}