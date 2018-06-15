public with sharing class ctrl_referral_print {
  public Dental_Practice__c dp {get; set;}
  public Lead l {get; set;}
  public Account a {get; set;}
  
  public Boolean Hygiene {get;set;}
  public Boolean Crown_Bridge {get;set;}
  public Boolean Teeth_Whitening {get;set;}
  public Boolean Dentures {get;set;}
  public Boolean Invisalign {get;set;}
  public Boolean Botox {get;set;}
  public Boolean Traditional_Ortho {get;set;}
  public Boolean Endontics {get;set;}
  public Boolean Laser_Dentistry {get;set;}
  public Boolean Veneers {get;set;}
  public Boolean Wisdom_Teeth {get;set;} 
  
  public String patient_note {get;set;}
	

  public ctrl_referral_print() {
  	hygiene = false;
  	crown_bridge = false;
  	teeth_whitening = false;
  	dentures = false;
  	invisalign = false;
  	botox = false;
  	traditional_ortho = false;
  	endontics = false;
  	laser_dentistry = false;
  	veneers = false;
  	wisdom_teeth = false;
  	if(apexpages.currentpage().getparameters().get('rnote')==null) 
  	  patient_note = '';
  	else
  	  patient_note = apexpages.currentpage().getparameters().get('rnote');
  	
  	//see if this is coming from the referral page,  or being fed in with values
  	if(apexpages.currentpage().getparameters().get('rout')==null) {
	  if(apexpages.currentpage().getparameters().get('dpid')==null) {  
	    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.error, 'Unknown GP office - Please contact IT');
	    ApexPages.addMessage(errMsg); 
	  }
	  else 
	    dp = [Select d.center_information__r.Local_Front_Desk__c,d.center_information__c,d.center_information__r.name,d.Wednesday_Start__c, d.Wednesday_Open__c, d.Wednesday_End__c, d.Tuesday_Start__c, d.Tuesday_Open__c, d.Tuesday_End__c, d.Thursday_Start__c, d.Thursday_Open__c, 
	      d.Thursday_End__c, d.Sunday_Start__c, d.Sunday_Open__c, d.Sunday_End__c, d.Saturday_Start__c, d.Saturday_Open__c, d.Saturday_End__c, d.Monday_Start__c, d.Monday_Open__c, d.Monday_End__c, 
	      d.Friday_Start__c, d.Friday_Open__c, d.Friday_End__c, d.Street__c, d.State_Province__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.Id, d.City__c,(Select ID, Name, Description From Attachments where name='ReferralMap.png') 
	      From Dental_Practice__c d where d.id = :apexpages.currentpage().getparameters().get('dpid')];
	  if(apexpages.currentpage().getparameters().get('lid')==null && apexpages.currentpage().getparameters().get('aid')==null) {
	    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.error, 'Unknown Lead/Account id - Please contact IT');
	    ApexPages.addMessage(errMsg); 
	  }
	  if(apexpages.currentpage().getparameters().get('lid')!=null)
	    l = [Select l.name, l.phone,  l.Street, l.State, l.PostalCode, l.City From Lead l where l.id = :apexpages.currentpage().getparameters().get('lid')];
	  if(apexpages.currentpage().getparameters().get('aid')!=null)
	    a = [Select a.phone, a.Name, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCity From Account a where a.id = :apexpages.currentpage().getparameters().get('aid')];
	  
	  if(apexpages.currentpage().getparameters().get('hygiene')!=null)
	    hygiene = true;
	  if(apexpages.currentpage().getparameters().get('crown_bridge')!=null)
	    crown_bridge = true;
	  if(apexpages.currentpage().getparameters().get('teeth_whitening')!=null)
	    teeth_whitening = true;
	  if(apexpages.currentpage().getparameters().get('dentures')!=null)
	    dentures = true;
	  if(apexpages.currentpage().getparameters().get('invisalign')!=null)
	    invisalign = true;
	  if(apexpages.currentpage().getparameters().get('botox')!=null)
	    botox = true;
	  if(apexpages.currentpage().getparameters().get('traditional_ortho')!=null)
	    traditional_ortho = true;
	  if(apexpages.currentpage().getparameters().get('endontics')!=null)
	    endontics = true;
	  if(apexpages.currentpage().getparameters().get('laser_dentistry')!=null)
	    laser_dentistry = true;
	  if(apexpages.currentpage().getparameters().get('veneers')!=null)
	    veneers = true;
	  if(apexpages.currentpage().getparameters().get('wisdom_teeth')!=null)
	    wisdom_teeth = true;
  	}
  	else {
  	  Referral_Out__c ro = [Select r.Referral_Notes__c,r.Procedure_Interested_In__c, r.Lead__c, r.Dental_Practice__c From Referral_Out__c r where r.id = :apexpages.currentpage().getparameters().get('rout')];
  	  l = [Select l.name, l.phone,  l.Street, l.State, l.PostalCode, l.City From Lead l where l.id = :ro.lead__c];
  	  dp = [Select d.center_information__r.Local_Front_Desk__c,d.center_information__c, d.center_information__r.name,d.Wednesday_Start__c, d.Wednesday_Open__c, d.Wednesday_End__c, d.Tuesday_Start__c, d.Tuesday_Open__c, d.Tuesday_End__c, d.Thursday_Start__c, d.Thursday_Open__c, d.Thursday_End__c,
  	    d.Sunday_Start__c, d.Sunday_Open__c, d.Sunday_End__c, d.Saturday_Start__c, d.Saturday_Open__c, d.Saturday_End__c, d.Monday_Start__c, d.Monday_Open__c, d.Monday_End__c, d.Friday_Start__c, 
  	    d.Friday_Open__c, d.Friday_End__c, d.Street__c, d.State_Province__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.Id, d.City__c, (Select ID, Name, Description From Attachments where name='ReferralMap.png')
  	    From Dental_Practice__c d where d.id = :ro.dental_practice__c];
  	  patient_note = ro.referral_notes__c;
  	  if(ro.procedure_interested_in__c.contains('Hygiene'))
  	    hygiene = true;
  	  if(ro.procedure_interested_in__c.contains('Crown & Bridge'))
  	    crown_bridge = true;
  	  if(ro.procedure_interested_in__c.contains('Teeth Whitening'))
  	    teeth_whitening = true;
  	  if(ro.procedure_interested_in__c.contains('Dentures'))
  	    dentures = true;
  	  if(ro.procedure_interested_in__c.contains('Invisalign'))
  	    invisalign = true;
  	  if(ro.procedure_interested_in__c.contains('Botox'))
  	    botox = true;
  	  if(ro.procedure_interested_in__c.contains('Traditional Orthodontics'))
  	    traditional_ortho = true;  
  	  if(ro.procedure_interested_in__c.contains('Endontics'))
  	    endontics = true;
  	  if(ro.procedure_interested_in__c.contains('Veneers'))
  	    veneers = true;
  	  if(ro.procedure_interested_in__c.contains('Wisdom Teeth'))
  	    wisdom_teeth = true;
  	}  	
  }
  
  public String getpatient_name() {
  	try {
  	  if(l!=null)
  	    return l.name;
  	  else
  	    return a.name;
  	}
  	catch (Exception e) {
  	  apexpages.addmessages(e);
  	  return 'N/A';
  	}
  }
  
  public String getpatient_phone() {
  	try {
  	  if(l!=null)
  	    return l.phone;
  	  else
  	    return a.phone;
  	}
  	catch (Exception e) {
  	  apexpages.addmessages(e);
  	  return 'N/A';
  	}
  }
  
  public String getpatient_street() {
  	try {
  	  if(l!=null)
  	    return l.street;
  	  else
  	    return a.billingstreet;
  	}
  	catch (Exception e) {
  	  apexpages.addmessages(e);
  	  return 'N/A';
  	}
  }
  
  public String getpatient_state() {
  	try {
  	  if(l!=null)
  	    return l.state;
  	  else
  	    return a.billingstate;
  	}
  	catch (Exception e) {
  	  apexpages.addmessages(e);
  	  return 'N/A';
  	}
  }
  
  public String getpatient_city() {
  	try {
  	  if(l!=null)
  	    return l.city;
  	  else
  	    return a.billingcity;
  	}
  	catch (Exception e) {
  	  apexpages.addmessages(e);
  	  return 'N/A';
  	}
  }
  
  public String getpatient_postal() {
  	try {
  	  if(l!=null)
  	    return l.postalcode;
  	  else
  	    return a.billingpostalcode;
  	}
  	catch (Exception e) {
  	  apexpages.addmessages(e);
  	  return 'N/A';
  	}
  }
  
  public String getdentist_name() {
  	try {
  	  Practice_Doctor__c pd = [select p.Last_Name__c, p.First_Name__c,p.name from practice_doctor__c p where p.dental_practice__c = :dp.id limit 1];
  	  return pd.first_name__c + ' ' + pd.last_name__c;
  	}
  	catch (Exception e) {
  	  apexpages.addmessages(e);
  	  return 'Unknown';
  	}
  }
  
  public String getcenter_address() {
  	Center_Information__c ci = [Select c.name,c.Zip_Code__c, c.Street_2__c, c.Street_1__c, c.State__c, c.City__c From Center_Information__c c where id = :dp.center_information__c];
  	String return_address = ci.street_1__c + '<br />';
  	if(ci.street_2__c!=null)
  	  return_address += ci.street_2__c + '<br />';
  	return_address += ci.city__c + ', ' + ci.state__c + ' ' + ci.zip_code__c;
  	return return_address;
  }
  
  public String getMapId() {
    String map_Id = '';
    System.debug('Attachments : ' + dp.attachments.size());
    try {
      if(dp.attachments.size()>0)
      //List<Attachment> attachedFiles = [select Id from Attachment where parentId =:dp.id and name = 'ReferralMap.png' order By LastModifiedDate desc limit 1];
      //if( attachedFiles != null && attachedFiles.size() > 0 ) {
        map_id = dp.attachments[0].Id;
      //}
      return map_Id;
    }
    catch (Exception e) {
      Apexpages.addmessages(e);
      return '';
    }
  }
  
  public String getmonday_hours() {
  	String hours = '';
  	if(dp.Monday_Start__c==null || dp.Monday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = dp.Monday_Start__c.split(':');
  	  String[] end_time = dp.Monday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) ;
  	  Integer end_hour = integer.valueOf(end_time[0]) ;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String gettuesday_hours() {
  	String hours = '';
  	if(dp.Tuesday_Start__c==null || dp.Tuesday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = dp.Tuesday_Start__c.split(':');
  	  String[] end_time = dp.Tuesday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) ;
  	  Integer end_hour = integer.valueOf(end_time[0]) ;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getwednesday_hours() {
  	String hours = '';
  	if(dp.wednesday_Start__c==null || dp.wednesday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = dp.wednesday_Start__c.split(':');
  	  String[] end_time = dp.wednesday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) ;
  	  Integer end_hour = integer.valueOf(end_time[0]) ;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getthursday_hours() {
  	String hours = '';
  	if(dp.Thursday_Start__c==null || dp.Thursday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = dp.Thursday_Start__c.split(':');
  	  String[] end_time = dp.Thursday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) ;
  	  Integer end_hour = integer.valueOf(end_time[0]) ;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getfriday_hours() {
  	String hours = '';
  	if(dp.friday_Start__c==null || dp.friday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = dp.friday_Start__c.split(':');
  	  String[] end_time = dp.friday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) ;
  	  Integer end_hour = integer.valueOf(end_time[0]) ;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getsaturday_hours() {
  	String hours = '';
  	if(dp.saturday_Start__c==null || dp.saturday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = dp.saturday_Start__c.split(':');
  	  String[] end_time = dp.saturday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) ;
  	  Integer end_hour = integer.valueOf(end_time[0]) ;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getsunday_hours() {
  	String hours = '';
  	if(dp.sunday_Start__c==null || dp.sunday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = dp.sunday_Start__c.split(':');
  	  String[] end_time = dp.sunday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) ;
  	  Integer end_hour = integer.valueOf(end_time[0]) ;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
}