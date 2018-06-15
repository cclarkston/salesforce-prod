public with sharing class dp_clinical_srx {
  public final Surgical_rx__c srx {get; set;}
  public Account patient {get; set;}    
  
  public dp_clinical_srx() {
  	srx = [Select s.Max_Implant_System__c, s.Max_Implant_System_Other__c, s.Man_implant_system__c, s.Man_Implant_System_Other__c, s.Single_Multi_Grafting__c, s.Single_Multi_Grafting_Note__c, 
  	  s.Max_Grafting__c, s.Max_Grafting_Note__c, s.Mand_grafting__c, s.Mand_Grafting_note__c, s.BMI__c,s.isactive__c, s.Weight__c, s.SystemModstamp, s.Reason__c, s.Pulse__c, s.Pulse_Ox__c, 
  	  s.Patient_POT__c, s.OwnerId, s.Name, s.Max_max_left_post_bone_reduction__c, s.Max_max_ant_bone_reduction__c, s.Max_Implant_teeth__c, s.Man_max_right_post_bone_reduction__c, 
  	  s.Man_max_left_post_bone_reduction__c, s.Man_max_ant_bone_reduction__c, s.Man_implant_teeth__c, s.MAX_max_right_post_bone_reduction__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, 
  	  s.Implant_Placement__c, s.Id, s.Height_Inches__c, s.Height_Feet__c, s.Grafting_as_needed__c, s.Extraction_teeth__c, s.Dr_to__c, s.DR_for__c, s.CreatedDate, s.CreatedById, s.Comments__c, 
  	  s.BP_Systolic__c, s.BP_Diastolic__c, s.Account__c, s.ASA__c, s.createdby.name, s.upper_arch_sinus_grafting__c, s.upper_arch_sinus_grafting_right__c, s.upper_arch_sinus_grafting_left__c,
  	  s.sm_sinus_grafting__c, s.sm_sinus_grafting_left__c, s.sm_sinus_grafting_right__c, s.extraction_notes__c, s.sm_implant_system__c, s.sm_implant_system_other__c, s.sm_implant_system_type__c,
  	  s.lower_immediate_load__c, s.lower_immediate_placement__c, s.lower_immediate_load_notes__c, s.upper_immediate_load__c, s.upper_immediate_placement__c, s.upper_immediate_notes__c ,
  	  s.sm_immediate_load__c, s.sm_immediate_placement__c, s.sm_immediate_load_notes__c, s.include_upper_arch__c, s.include_lower_arch__c, s.include_sm__c, s.reviewed_by__r.name, s.review_time__c, s.reviewed_by__c,
  	  s.center_information__r.legal_name__c,s.center_information__r.street_1__c,s.center_information__r.street_2__c,s.center_information__r.city__c,s.center_information__r.state__c,s.center_information__r.zip_code__c
  	  From Surgical_RX__c s
  	  where id = :apexpages.currentpage().getparameters().get('srxid')];  	
    patient = [select id,name,phone,email__c,billingStreet,billingcity,billingstate,billingpostalcode,personmobilephone,emergency_contact_name__c,emergency_contact_phone__c,
      clinical_notes__c,isPersonAccount,firstname,lastname,date_of_birth__c,PersonContactId,main_photo_id__c,personemail,age__c,warranty_id__c
      from Account where id = :apexpages.currentpage().getparameters().get('ptid')];
  }
  
  public String getpatient_allergy_info() {
  	String allergy_line = '';
  	String prefix_char = '';
  	try {
  	  for(Allergy__c a : [select name from Allergy__c where patient__c = :patient.id]) {
  	    allergy_line += prefix_char + a.name;
  	    prefix_char = ',';
  	  }
  	} catch (Exception e) {}
  	if(allergy_line=='')
  	  allergy_line = 'NKDA';
  	return allergy_line;
  }
  
  
    
  public String getcenter_address_line() {
  	String address_line = srx.center_information__r.street_1__c;
  	if(srx.center_information__r.street_2__c!=null)
  	  address_line += ', ' + srx.center_information__r.street_2__c;
  	address_line += '<br />' + srx.center_information__r.city__c + ', ' + srx.center_information__r.state__c + ' ' + srx.center_information__r.zip_code__c;
  	return address_line;
  }
    
}