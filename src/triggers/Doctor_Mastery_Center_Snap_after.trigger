trigger Doctor_Mastery_Center_Snap_after on Doctor_Mastery_Center_Snapshot__c (after update) {
  /* 3/8/2018 CM - Trigger will fire when arches delivered is updated on the monthly center snapshot record.  All doctors currently at the center will get credit for the arches delivered and their
    current user snapshot will also be updated ro reflect their total deliveres	
  */

  if(trigger.isafter) {
  	//map to store arch count changes by center id
  	Map<ID,Integer> arch_change_map = new Map<ID,Integer> ();
  	for(Doctor_Mastery_Center_Snapshot__c center_snap : trigger.new) {
  	  Doctor_Mastery_Center_Snapshot__c old_snap = trigger.oldmap.get(center_snap.id);
  	  //was there a change in the number of arches delivered
  	  if(center_snap.arches_delivered__c!=old_snap.arches_delivered__c) {
  	  	Integer arch_change = (center_snap.arches_delivered__c==null?0:center_snap.arches_delivered__c.intvalue()) - (old_snap.arches_delivered__c==null?0:old_snap.arches_delivered__c.intvalue());
  	  	//store the arch count difference in the map
  	    arch_change_map.put(center_snap.center_information__c,arch_change);
  	  }
  	}
  	
  	//did we have a change we need to work through
  	if(arch_change_map.size()>0) {
      //update total arches delivered for all clearchoice doctors working at the center
      List<ClearChoice_Doctor__c> docs_updated = new List<ClearChoice_Doctor__c>();
      for(ClearChoice_Doctor__c doctor : [select id,total_arches_delivered__c,center_information__c from ClearChoice_Doctor__c where active__c = true and center_information__c in : arch_change_map.keyset()]) {
        doctor.total_arches_delivered__c = (doctor.total_arches_delivered__c==null?0:doctor.total_arches_delivered__c) + arch_change_map.get(doctor.center_information__c);
        docs_updated.add(doctor);	
      }
      update docs_updated;
      
            
      //update total arches on the doctor mastery user snapshots for the current month
      Integer current_month = System.today().month();
      Integer current_year = System.today().year();
      List<Doctor_Mastery_User_Snapshot__c> user_snap_updates = new List<Doctor_Mastery_User_Snapshot__c> ();
      for(Doctor_Mastery_User_Snapshot__c snap : [select clearchoice_doctor__r.center_information__c,id,total_arches_delivered__c from Doctor_Mastery_User_Snapshot__c 
        where clearchoice_doctor__r.center_information__c in :arch_change_map.keyset() and month__c = :current_month and year__c = :current_year]) {
      	snap.total_arches_delivered__c = (snap.total_arches_delivered__c==null?0:snap.total_arches_delivered__c) + arch_change_map.get(snap.clearchoice_doctor__r.center_information__c);
      	user_snap_updates.add(snap);
      }      
      update user_snap_updates;            
  	}
  	  	
  } 
  
}