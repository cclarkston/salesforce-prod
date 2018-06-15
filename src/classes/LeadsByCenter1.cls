/**********************************************************************************
Name    : LeadsByCenter
Date    : March 16, 2011
Usage   : Controller for the following VFPage:
          - LeadsByCenter 


CHANGE HISTORY
===============================================================================
DATE            NAME                   DESC
2011-03-16      Mike Merino            Created
2011-04-12      Mike Merino            Make data appear in table up/down not across
2011-04-20      Mike Merino            Move cursor to top to avoid soql limit error
2012-03-13      Chris McDowell         Blocked Chicago Deerfield and Colorado Springs from Displaying 
*************************************************************************************/
public with sharing class LeadsByCenter1 {

public List<dataTableWrapper> myCollection1 = new List<dataTableWrapper>();
public List<dataTableWrapper> myCollection2 = new List<dataTableWrapper>();
public List<dataTableWrapper> myCollection3 = new List<dataTableWrapper>();
List<Center_Information__c> locations =[Select id, Name from Center_Information__c where Name NOT IN('New Market Not Yet Open','Unknown','Chicago Deerfield/Northbrook','Colorado Springs','Phoenix Mesa') order by Name];
List<AggregateResult> results= [Select Count(l.name) cnt,  l.Center_Location__c 
                                From Lead l 
                                WHERE Inbound_Call__c='Dental Inquiry'
                                  and CreatedDate = TODAY
                                  and Name NOT IN('New Market Not Yet Open','Unknown')
                                  //added by CM on 2012-9-24 per Scott/Kathrynn - they want the big board to match the CC dashboard
                                  and Call_Result__c in ('Consultation Scheduled','Not Scheduled', 'VIP Seminar Scheduled')
                                group by l.Center_Location__c];
List<dataTableWrapper> myCollection;

	public Integer num_web {get; set;}
	public Integer num_web_no_response {get; set;}
	public Decimal avg_response_time {get; set;}

  public LeadsByCenter1() {
	  Set<Id> all_web_ids = new Set<Id>{};
	  num_web_no_response = 0;
	  avg_response_time = 0.0;
	  for(CampaignMember cm : [select leadid, lead.name, campaign.type, lead.trigger_referral_source__c from campaignmember cm  where lead.createddate >= today and campaign.type in ('Web Lead','Web Lead 3 (IMS)')]) {
	  	all_web_ids.add(cm.leadid);
	  }
	  num_web = all_web_ids.size();
	  Decimal total_time_diff = 0;
	  for(Lead l : [Select (Select createddate From Tasks where activity_type__c in ('Outbound Call','Inbound Call') order by createddate limit 1),createddate From Lead l where createddate >= today and id in :all_web_ids ]) {
	  	if(l.tasks.size()==0) {
	  	  System.debug('Total time diff : ' + Decimal.valueof((System.now().getTime() - l.createddate.getTime())));	
	  	  total_time_diff += (System.now().getTime() - l.createddate.getTime())/(1000.0*60.0);
        System.debug('Total time diff : ' + total_time_diff);	  	  
	  	  num_web_no_response++;
	  	}
	  	else {
	  		for(Task t : l.tasks) {
	  	    total_time_diff += (t.createddate.getTime() - l.createddate.getTime())/(1000.0*60.0);
	  	    System.debug('Total time diff : ' + total_time_diff);
	  		}
	  	}
	  }	  
	  if(num_web>0) {
	    avg_response_time = total_time_diff/(num_web*1.0);
	    avg_response_time = avg_response_time.setscale(2);
	  }	  	 
  }

/****************************************************************************************/
public List<dataTableWrapper> getMyCollection1() {
  myMethod();
  Integer i = 0;
  Integer NumRows = myCollection.size()/3;
  Integer RowStart = NumRows*0+1;
  Integer RowEnd = RowStart+NumRows;
  for (dataTableWrapper t:myCollection)
  {
    i++;
    if(i>=RowStart && i<RowEnd)
      {
      myCollection1.add(t);
      }
  }
  return myCollection1;
}


/****************************************************************************************/
public List<dataTableWrapper> getMyCollection2() {
  myMethod();
  Integer i = 0;
  Integer NumRows = myCollection.size()/3;
  Integer RowStart = NumRows*1+1;
  Integer RowEnd = RowStart+NumRows;
  for (dataTableWrapper t:myCollection)
  {
    i++;
    if(i>=RowStart && i<RowEnd)
      {
      myCollection2.add(t);
      }
  }
  return myCollection2;
}


/****************************************************************************************/
public List<dataTableWrapper> getMyCollection3() {
  myMethod();
  Integer i = 0;
  Integer NumRows = myCollection.size()/3;
  Integer RowStart = NumRows*2+1;
  Integer RowEnd = RowStart+NumRows;
  for (dataTableWrapper t:myCollection)
  {
    i++;
    if(i>=RowStart && i<RowEnd)
      {
       myCollection3.add(t);
       }
  }
  return myCollection3;
}


/****************************************************************************************/
public Integer getTotalLeads() 
{
Integer totals=0;
for(AggregateResult ar  :results )
    {
   
        totals = totals+ Integer.valueOf(ar.get('cnt'));
    }
  return totals;
}

/****************************************************************************************/
  public List<dataTableWrapper> myMethod(){
  myCollection = new List<dataTableWrapper>();
  Integer counter = 0;
  String item;
  Boolean FoundIt = false;
  String location;
  for(Center_Information__c loc: locations)
  {
     item= loc.Name;   
 //    system.debug('### location '+location);
  
     for(AggregateResult ar  : results)
    {
       location= String.valueOf(ar.get('Center_Location__c'));
       if (location == item)
       {
            counter = Integer.valueOf(ar.get('cnt'));          
            FoundIt =true;
       }
    }  
    if (FoundIt)
     {
        myCollection.add(new dataTableWrapper(item, counter));
        system.debug('### found it '+item+'--'+counter);
        FoundIt = false; // reset flag
     } 
   else
    {
      myCollection.add(new dataTableWrapper(item, 0));
      system.debug('### not found '+item);
    }
  } 
  // trick to get the three table equal in number of rows
Integer offset = math.mod(myCollection.size(),3);
system.debug('### offset '+offset);
item = '--';
if (offset==1)
{
  myCollection.add(new dataTableWrapper(item,0));
  myCollection.add(new dataTableWrapper(item,0));
}
else if(offset==2)
{
    myCollection.add(new dataTableWrapper(item,0));
}
return myCollection;
}
 
/****************************************************************************************/
// inner class
class dataTableWrapper {
 
  public Integer counter { get; set; }
  public String item { get; set;}
 
  public DataTableWrapper(String item, Integer counter) {
  //    system.debug('### inner class '+item+'--'+counter);
    this.item = item;
    this.counter = counter;
  }
}


}