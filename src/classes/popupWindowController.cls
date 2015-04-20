public with sharing class popupWindowController {

    public String fieldName { get; set; }

    public List<Result> searchResults { get; set; }
    public String searchTerm { get; set; }
    public String entityName { get; set; }

    public class Result {
        public Result(String name, Id recordId) {
            this.Name = Name;
            this.recordId = recordId;
        }
        public String Name { get; set; }
        public Id recordId { get; set; }
    }
    
    public popupWindowController() {
        searchResults = new List<Result>();
    }
    
    public void search() {
        searchResults.clear();
        if(searchTerm==null || searchTerm=='')
            return;
        String localSearchTerm = searchTerm.replace('\\*','%');
        
        for(SObject s:database.query('select id,name from contact  limit 50'))
            searchResults.add(new Result(String.valueOf(s.get('name')),String.valueOf(s.get('id'))));
    }

}