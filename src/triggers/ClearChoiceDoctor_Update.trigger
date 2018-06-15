trigger ClearChoiceDoctor_Update on ClearChoice_Doctor__c (after update) {
  /*  3/8/2018 CM - Adding trigger to keep CCE credit hours in synch with monthly snapshots.  When the cce_credits are updated on the doctor record,  
                 this trigger will make a similar change to the currently monthly snapshot*/
                 
  /*To-Do:  we might need to handle the adjustments for training checkboxes) */
	
	  
  if(trigger.isUpdate) {  	
  	//map to store cce credit change amount by clearchoice doctor id
  	Map<ID,Integer> cce_map = new Map<ID,Integer>();
  	Set<ID> onboarding_set = new Set<ID> ();
  	Set<ID> practice_mastery_set = new Set<ID> ();
  	Set<ID> practice_mastery2_set = new Set<ID> ();
  	Set<ID> rainmaker_set = new Set<ID> ();  	
  	Set<ID> practice_leadership_set = new Set<ID> ();
  	Set<ID> pacesetter_set = new Set<ID> ();  	
  	
    for(ClearChoice_Doctor__c doctor : trigger.new) {
      ClearChoice_Doctor__c old_doc = Trigger.oldmap.get(doctor.id);
      if(doctor.CCE_Credits__c!=null) {
      	if(doctor.cce_credits__c!=old_doc.cce_credits__c) {
      	  Integer old_value = (old_doc.cce_credits__c==null?0:old_doc.cce_credits__c.intvalue());
      	  Integer new_value = (doctor.cce_credits__c==null?0:doctor.cce_credits__c.intvalue());	      		
      	  Integer cce_change = new_value - old_value;
      	  cce_map.put(doctor.id,cce_change);      	        	 
      	}
      	if(doctor.onboarding_complete__c && doctor.onboarding_complete__c != old_doc.onboarding_complete__c)
      	  onboarding_set.add(doctor.id);
      	if(doctor.practice_mastery_completed__c && doctor.practice_mastery_completed__c != old_doc.practice_mastery_completed__c)
      	  practice_mastery_set.add(doctor.id);
      	if(doctor.practice_mastery_2_completed__c && doctor.practice_mastery_2_completed__c != old_doc.practice_mastery_2_completed__c)
      	  practice_mastery2_set.add(doctor.id);
      	if(doctor.rainmaker_training__c && doctor.rainmaker_training__c != old_doc.rainmaker_training__c)
      	  rainmaker_set.add(doctor.id);
      	if(doctor.practice_leadership_completed__c && doctor.practice_leadership_completed__c != old_doc.practice_leadership_completed__c)
      	  practice_leadership_set.add(doctor.id);
      	if(doctor.pacesetter__c && doctor.pacesetter__c != old_doc.pacesetter__c)
      	  pacesetter_set.add(doctor.id);      	
      }
    }
      
    //since snapshot records for the previous month, and credit entry comes in after the fact,  we need to update the entries in the prior months scorecard
    Integer current_month = System.today().addmonths(-1).month();
    Integer current_year = System.today().addmonths(-1).year();
      
    Map<ID,Doctor_Mastery_User_Snapshot__c> user_snap_map = new Map<ID,Doctor_Mastery_User_Snapshot__c>();
    for(Doctor_Mastery_User_Snapshot__c user_snap  : [Select d.Year__c, d.Month__c, d.ClearChoice_Doctor__c, d.CCE_Credits__c,d.id,d.Rainmaker_Training__c, d.Practice_Mastery_Completed__c, d.Practice_Mastery_2_Completed__c, d.Practice_Leadership_Completed__c, d.Pacesetter__c, d.Onboarding_Complete__c 
      From Doctor_Mastery_User_Snapshot__c d where month__c = :current_month and year__c = :current_year]) {
      user_snap_map.put(user_snap.clearchoice_doctor__c, user_snap);	
    }
         
    //did we have any changes to cce credits
    if(cce_map.size()>0) {      
      for(ID doc_id : cce_map.keyset()) {
        if(user_snap_map.get(doc_id)!=null) 
          user_snap_map.get(doc_id).cce_credits__c += cce_map.get(doc_id);          
      } 
    }    
    //any changes to onboarding?
    user_snap_map = update_snapshot_fields(onboarding_set, 'onboarding_complete__c', user_snap_map);    
    //any changes to practice mastery?
    user_snap_map = update_snapshot_fields(practice_mastery_set, 'practice_mastery_completed__c', user_snap_map);
    //any changes to practice mastery 2?
    user_snap_map = update_snapshot_fields(practice_mastery2_set, 'practice_mastery_2_completed__c', user_snap_map);   
    //any changes to rainmaker?
    user_snap_map = update_snapshot_fields(rainmaker_set, 'rainmaker_training__c', user_snap_map);   
    //any changes to practice leadership?
    user_snap_map = update_snapshot_fields(practice_leadership_set, 'Practice_Leadership_Completed__c', user_snap_map);   
    //any changes to pacesetter
    user_snap_map = update_snapshot_fields(pacesetter_set, 'pacesetter__c', user_snap_map);
    update user_snap_map.values();
  }
  
  public Map<ID,Doctor_Mastery_User_Snapshot__c> update_snapshot_fields(Set<ID> id_set, String field_name, Map<ID,Doctor_Mastery_User_Snapshot__c> snap_map) {
  	if(id_set.size()>0) {
      for(ID doc_id : id_set) {
      	if(snap_map.get(doc_id)!=null)
      	  snap_map.get(doc_id).put(field_name,true);
      }
    }
    return snap_map;
  }
       
}