/**********************************************************************************
Name    : UpdateOffSiteEvent
Usage   : In order to preserve historical reporting integrity, the campaign name should 
          be populated into this picklist so marketing can generate list of which leads 
          and contacts are associated with a campaign. 

CHANGE HISTORY
===============================================================================
DATE            NAME                  DESC
2011-05-17     Mike Merino            Initial release       

2011-09-08		Seth Davidow 		Suggesting this get pulled since it's causing a circular
									reference with lead and campaign memeber.  Suggest that reports
									are done in the future off of Campaigns, not this historic field.
									Can setup a batch process (nightly), or add back in/attach to other 
									trigger to prevent the loop.
         This can't be done because updating lead updates cm, so turning off for now.
2011-09-19 		Seth Davidow		Pulling soql out of for loop         
*************************************************************************************/
    
trigger UpdateOffSiteEvent on CampaignMember (after insert, after update) {

List<Lead> myLeads = new  List<Lead>();
Lead leadTemp;
String CampaignName;
Boolean FoundCampaign = false;
Id ProspectivePatientId;
Id LeadId;
Id CampaignId;

set<id> campaignset = new set<id>();//set of campaigns used/found in trigger of campaign memebers
for(CampaignMember cm : trigger.new){
	campaignset.add(cm.campaignid);
}

list<Campaign> cnames = [select name, id from Campaign where id in :campaignset]; //list of campaing names

Map<id, string> Mapar = new Map<id, string>(); //map of campaignid and camapign names
for(Campaign c : cnames){
	mapar.put(c.id, c.name);
}

/*
for(AggregateResult ar  : [Select c.id, c.name
                           from Campaign c 
                           where c.id = :CampaignId
                           group by c.id, c.name
                           ])

*/
for (integer i=0; i<trigger.new.size();i++)
{
     ProspectivePatientId = trigger.new[i].leadId;
     LeadId = trigger.new[i].LeadId;
     CampaignId = trigger.new[i].CampaignId;
     system.debug('### ProspectiveId '+ProspectivePatientId+ ' campaignID '+CampaignId);
     if (ProspectivePatientId!=null ) 
     {
          
        /* sjd to fix sqol limit, moving outside of for loop
           // find Campaign Name
         for(AggregateResult ar  : [Select c.id, c.name
                                 from Campaign c 
                                where c.id = :CampaignId
                                group by c.id, c.name
                                ])
        
        end sjd */
        
        {
            id theCamp;
            theCamp = trigger.new[i].Campaignid;
            CampaignName = Mapar.get(theCamp);
            //CampaignName = String.valueOf(Mapar.get('name'));
            FoundCampaign = true;
        }
        if (FoundCampaign)
        {
             leadTemp= new Lead(id = LeadId,VIP_Event__c = CampaignName); 
             myLeads.add(leadTemp);
             system.debug('### Found UpdateOffSiteEvent '+leadTemp);
        }
    }
    if (myLeads.size() > 0) 
    {
       try{
         update myLeads;
         system.debug('### Leads updated size=('+myLeads.size()+') '+myLeads);
       } catch (exception e){
           system.debug('The trigger was unable to update due to the following: '+e+'---'+myLeads);
       }
    }
}
}