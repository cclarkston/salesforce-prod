trigger CampaignMemberAfter on CampaignMember(after insert, after update){

/*Map<Id,CampaignMember> campaignLeads = new Map<Id,CampaignMember>{};
List<CampaignMember> camMembers = trigger.new;
--List<Campaign> campaignName = trigger.new;

for(CampaignMember cm : camMembers)

campaignLeads.put(cm.LeadId, cm);

List<Lead> leadsToUpdate = new List<Lead>{};

for(Lead l : [SELECT Id,VIP_Event__c from Lead where Id in :campaignLeads.keySet()])
{
        l.VIP_Event__c='Test';

LeadsToUpdate.add(l);
}*/
}