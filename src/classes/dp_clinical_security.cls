public with sharing class dp_clinical_security {
  static Set<String> pi_profiles = new Set<String> {'HopeRX - Intake','Force.com - Patient Intake','Force.com - Denver - Patient Intake'};
  static Set<String> foa_profiles = new Set<String> {'FOA','FOA - No Prescreen','FOA - No Prescreen - TPlan','FOA - NPscreen - TPlan - PPF','FOA - TPLAN'};
  static Set<String> assistant_profiles = new Set<String> {'Clinical Assistant','SF - Clinical Assistant'};
  static Set<String> doctor_profiles = new Set<String> {'Clinical Doctor','SF - Clinical Doctor'};
  static Map<ID,Profile> profile_map;
  
  public Boolean is_profile_doctor(String profile_name) {
  	if(doctor_profiles.contains(profile_name))
  	  return true;
  	else
  	  return false;
  }
  
  public Boolean is_profile_id_doctor(ID pid) {
  	if(profile_map==null)
  	  init_profile_map();  	
  	return is_profile_doctor(profile_map.get(pid)==null?'':profile_map.get(pid).name);
  }
  
  public Boolean is_profile_assistant(String profile_name) {
  	if(assistant_profiles.contains(profile_name))
  	  return true;
  	else
  	  return false;
  }
  
  public Boolean is_profile_id_assistant(ID pid) {
  	if(profile_map==null)
  	  init_profile_map();  	
  	return is_profile_assistant(profile_map.get(pid)==null?'':profile_map.get(pid).name);
  }
  
  public Boolean is_profile_foa(String profile_name) {
  	if(foa_profiles.contains(profile_name))
  	  return true;
  	else
  	  return false;
  }
  
  public Boolean is_profile_id_foa(ID pid) {
  	if(profile_map==null)
  	  init_profile_map();  	
  	return is_profile_foa(profile_map.get(pid)==null?'':profile_map.get(pid).name);
  }
  
  public Boolean is_profile_intake(String profile_name) {
  	if(pi_profiles.contains(profile_name))
  	  return true;
  	else
  	  return false;
  }
  
  public Boolean is_profile_id_intake(ID pid) {
  	if(profile_map==null)
  	  init_profile_map();  	
  	return is_profile_intake(profile_map.get(pid)==null?'':profile_map.get(pid).name);
  }  
  
  public void init_profile_map() {
  	profile_map = new Map<ID,Profile> ([select id,name from profile]);
  }
  
  public Boolean allow_notes_edit(String note_profile_name) {
  	//office staff can edit note for each other
  	if(is_profile_id_intake(userinfo.getProfileId()) || is_profile_id_foa(userinfo.getProfileId())) {
  	  if(is_profile_foa(note_profile_name) || is_profile_intake(note_profile_name))
  	    return true;
  	} else if(is_profile_id_assistant(userinfo.getProfileId())) {
  	  //asistants can edit notes for assistants and office staff
  	  if(is_profile_foa(note_profile_name) || is_profile_intake(note_profile_name) || is_profile_assistant(note_profile_name))
  	    return true;
  	} else if(is_profile_id_doctor(userinfo.getProfileId())) {
  	  //doctors can edit any note
  	  return true;
  	}
  	return false;
  }
  
}