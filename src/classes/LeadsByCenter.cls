/**********************************************************************************
Name    : LeadsByCenter
Date    : March 16, 2011
Usage   : Controller for the following VFPage:
          - LeadsByCenter 


CHANGE HISTORY
===============================================================================
DATE            NAME                   DESC
2011-03-16      Mike Merino            Created

*************************************************************************************/
public with sharing class LeadsByCenter {

public List<dataTableWrapper> myCollection = new List<dataTableWrapper>();

public List<dataTableWrapper> getMyCollection() {
  Integer counter = 0;
  String item;
    for(AggregateResult ar  : [Select Count(l.name) cnt,  l.Center_Location__c 
                                From Lead l WHERE Inbound_Call__c='Dental Inquiry' AND CreatedDate=TODAY
                                group by l.Center_Location__c
                                order by l.Center_Location__c])
    {
            counter = Integer.valueOf(ar.get('cnt'));            
            item = String.valueOf(ar.get('Center_Location__c'));
    // add the wrapper to the collection
    myCollection.add(new dataTableWrapper(item, counter));
  }
return myCollection;
}
 
// inner class
class dataTableWrapper {
 
  public Integer counter { get; set; }
  public String item { get; set;}
 
  public DataTableWrapper(String item, Integer counter) {
    this.item = item;
    this.counter = counter;
  }
}                               
}