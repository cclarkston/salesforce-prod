public with sharing class SearchInfoCision{
    public String searchString {get; set;}
    public List<Lead> returnedLeads { get; set; }
    Private String SOQL = '';
    public SearchInfoCision(ApexPages.StandardController stdController){
        returnedLeads = new List<Lead>();
    }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
    
    // the current field to sort by. defaults to last name
    public String sortField {
        get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
        set;
    }
    
    // toggles the sorting of query from asc<-->desc
    public void toggleSort() {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQuery();
    }
    
    public void runQuery() {
        try {
          returnedLeads = Database.query(SOQL + ' ORDER BY ' + sortField + ' ' + sortDir + ' LIMIT 100');
        } catch (Exception e) {
           ApexPages.addMessages(e);
        }
    }
    
    public PageReference Search(){
        searchString = ApexPages.currentPage().getParameters().get('Search');
        if(searchString  == '' || searchString  == null){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Provide a Search Parameter'));
        } else {
            try{
                SOQL = 'SELECT State, PostalCode, Phone, Name, LastName, FirstName, Email, CreatedDate, City, Street '
                    + 'FROM Lead '
                    + 'WHERE ( FirstName LIKE \''+String.escapeSingleQuotes(searchString)+'\' '
                    + 'OR LastName LIKE \''+String.escapeSingleQuotes(searchString)+'\' '
                    + 'OR Name LIKE \''+String.escapeSingleQuotes(searchString)+'\' '
                    + 'OR Phone LIKE \''+String.escapeSingleQuotes(searchString)+'\' '
                    + 'OR Email LIKE \''+String.escapeSingleQuotes(searchString)+'\' ';
                    
                if(searchString.replaceAll('[^0-9]','').length() == 10){
                	String phoneTest = searchString.replaceAll('[^0-9]','');
                	SOQL += 'OR Phone LIKE \''+String.escapeSingleQuotes(phoneTest)+'\' ';
                	SOQL += 'OR Phone LIKE \''+String.escapeSingleQuotes('%'+phoneTest.substring(0,3)+'%'+phoneTest.substring(3,6)+'%'+phoneTest.substring(6))+'\' ';
                }
                SOQL += ')'; // AND Contact_Agency__c = \'Infocision\'';
                returnedLeads = Database.query(SOQL);
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
            runQuery();
        }
        return null;
    }
}