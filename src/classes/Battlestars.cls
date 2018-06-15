global class Battlestars {

  WebService static Boolean AddCenterStar(String CenterId) {
  	try {
  	  //need to add a star to the center,  as well as all doctors currently assigned to the center
  	  Center_Information__c center = [select id,battlegroup_stars__c from Center_Information__c where id = :centerid];
  	  center.battlegroup_stars__c = (center.battlegroup_stars__c==null?0:center.battlegroup_stars__c) + 1;
  	  update center;
  	
  	  //grab all clearhoice doctor records tied to this center and give them a star as well
  	  List<ClearChoice_Doctor__c> doctor_list = [select id,battlegroup_stars__c from ClearChoice_Doctor__c where center_information__c = :center.id];
  	  for(ClearChoice_Doctor__c doctor : doctor_list) {
  	    doctor.battlegroup_stars__c = (doctor.battlegroup_stars__c==null?0:doctor.battlegroup_stars__c) + 1; 
  	  } 
  	  update doctor_list;
  	  
  	  return true;
  	} catch (Exception e) {
  	  return false;  
  	}
  }
  
  WebService static Boolean AddDoctorStar(String DoctorId) {
  	//just need to increment the batlegroup_stars field on the clearchoice_doctor table
  	try {
  	  ClearChoice_Doctor__c doctor = [select id,battlegroup_stars__c from ClearChoice_Doctor__c where id = :doctorid];
  	  doctor.battlegroup_stars__c = (doctor.battlegroup_stars__c==null?0:doctor.battlegroup_stars__c) + 1; 
  	  update doctor;
  	  
  	  return true;
  	} catch (Exception e) {
  	  return false;  
  	}
  }
}