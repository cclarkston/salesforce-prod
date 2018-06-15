trigger Net_Promoter_After on Net_Promoter_Survery__c (after insert) {
  Set<String> opp_ids = new Set<String>();
  
  //pull a list of all opp_id values
  for(Net_Promoter_Survery__c nps : Trigger.new) {
  	if(nps.opp_id__c!=null)
  	  opp_ids.add(nps.opp_id__c);
  }
  
  Map<ID,Opportunity> opp_map = new Map<ID,Opportunity> ([select id,net_promoter_score__c,net_promoter_time__c from Opportunity where id in :opp_ids]);
  if(opp_map.values().size()>0) {
    for(Net_Promoter_Survery__c nps : Trigger.new) {
  	  if(nps.opp_id__c!=null) {
  	  	if(opp_map.get(nps.opp_id__c).net_promoter_score__c==null) {
  	      opp_map.get(nps.opp_id__c).net_promoter_score__c = nps.npscore__c;
  	      opp_map.get(nps.opp_id__c).net_promoter_time__c = nps.createddate;
  	  	}
  	  }  	
    }
  
  
    try {
  	  update opp_map.values();
    } catch (Exception e) {
      System.debug('Error updating opportunity records');
    }
  }
}