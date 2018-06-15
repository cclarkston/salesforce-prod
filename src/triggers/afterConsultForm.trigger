trigger afterConsultForm on Consult_Form__c (after update) {
 if(trigger.isUpdate) {
  	for(Consult_Form__c cf : Trigger.new) {
  	  //grab our account record with all relevant fields we might update
  	  Account a = [select a.Name, a.Taking_Bisphosphonates__c, a.Prescribed_Bisphosphonates__c, a.Pregnant__c, a.Phone, a.PersonMobilePhone, a.PersonMailingStreet, a.PersonMailingState, a.PersonMailingPostalCode,
  	     a.PersonMailingCity, a.Periodontal_Gum_Disease__c, a.Occupation__c, a.Major_Medical_Problem__c, a.Major_Medical_Problem_What__c, a.Main_Dental_Concern__c, a.Last_Dentist_Visit__c, 
  	     a.LastName, a.How_would_treatment_change_your_life__c, a.How_soon_would_you_like_to_start__c, a.How_is_dental_condition_affecting_you__c, a.Have_Family_Dentist__c, a.Gender__c,
  	     a.FirstName, a.Employer__c, a.Email__c, a.Discuss_Medical_Care_Relationship_2__c, a.Discuss_Medical_Care_Relationship_1__c, a.Discuss_Medical_Care_Name_2__c, 
  	     a.Discuss_Medical_Care_Name_1__c, a.Dentist_Name__c, a.Date_of_Birth__c, a.Business_Phone__c, a.BMOC_Weekend__c, a.BMOC_Evening__c, a.BMOC_Daytime__c,a.BMOC_Weekend_VM__c, 
  	     a.BMOC_Evening_VM__c, a.BMOC_Daytime_VM__c, a.isPersonAccount, a.Accompanied_By__c, Accompanied_by_Name__c, a.Approve_iCat__c, a.Approve_Nothing__c, a.Approve_Panoramic__c, 
  	     a.Approve_Consult__c from Account a where id = :cf.account__c];
  	  a.Taking_Bisphosphonates__c = cf.Taking_Bisphosphonates__c;
  	  a.Prescribed_Bisphosphonates__c = cf.Prescribed_Bisphosphonates__c;
  	  a.Pregnant__c = cf.Pregnant__c;
  	  if(cf.phone__c!=null)
  	    a.Phone = cf.Phone__c;
  	  if(cf.PersonMobilePhone__c!=null)
  	    a.PersonMobilePhone = cf.PersonMobilePhone__c;
  	  if(cf.PersonMailingStreet__c!=null) {
  	    a.PersonMailingStreet = cf.PersonMailingStreet__c;
  	    a.BillingStreet = cf.PersonMailingStreet__c;
  	  }
  	  if(cf.PersonMailingPostalCode__c!=null) {
  	  	a.PersonMailingPostalCode = cf.PersonMailingPostalCode__c;
  	  	a.BillingPostalCode = cf.PersonMailingPostalCode__c;
  	  }
  	  if(cf.PersonMailingState__c!=null) {
  	    a.PersonMailingState = cf.PersonMailingState__c;
  	    a.BillingState = cf.PersonMailingState__c;
  	  }
  	  if(cf.PersonMailingCity__c!=null) {
  	    a.PersonMailingCity = cf.PersonMailingCity__c;
  	    a.BillingCity = cf.PersonMailingCity__c;
  	  }
  	  a.Periodontal_Gum_Disease__c = cf.Periodontal_Gum_Disease__c;
  	  a.Occupation__c = cf.Occupation__c;
  	  a.Major_Medical_Problem__c = cf.Major_Medical_Problem__c;
  	  a.Major_Medical_Problem_What__c = cf.Major_Medical_Problem_What__c;
  	  a.Main_Dental_Concern__c = cf.Main_Dental_Concern__c;
  	  a.Last_Dentist_Visit__c = cf.Last_Dentist_Visit__c;
  	  if(cf.lastname__c!=null)
  	    a.LastName = cf.LastName__c;
  	  a.How_would_treatment_change_your_life__c = cf.How_would_treatment_change_your_life__c;
  	  a.How_soon_would_you_like_to_start__c = cf.How_soon_would_you_like_to_start__c;
  	  a.How_is_dental_condition_affecting_you__c = cf.How_is_dental_condition_affecting_you__c;
  	  a.Have_Family_Dentist__c = cf.Have_Family_Dentist__c;
  	  if(cf.Gender__c!=null)
  	    a.Gender__c = cf.Gender__c;
  	  if(cf.FirstName__c!=null)
  	    a.FirstName = cf.FirstName__c;
  	  a.Employer__c = cf.Employer__c;
  	  a.Email__c = cf.Email__c;
  	  a.Discuss_Medical_Care_Relationship_2__c = cf.Discuss_Medical_Care_Relationship_2__c;
  	  a.Discuss_Medical_Care_Relationship_1__c = cf.Discuss_Medical_Care_Relationship_1__c;
  	  a.Discuss_Medical_Care_Name_2__c = cf.Discuss_Medical_Care_Name_2__c;
  	  a.Discuss_Medical_Care_Name_1__c = cf.Discuss_Medical_Care_Name_1__c;
  	  a.Dentist_Name__c = cf.Dentist_Name__c;
  	  a.Date_of_Birth__c = cf.Date_of_Birth__c;
  	  if(cf.Business_Phone__c!=null)
  	    a.Business_Phone__c = cf.Business_Phone__c;
  	  a.BMOC_Weekend__c = cf.BMOC_Weekend__c;
  	  a.BMOC_Weekend_VM__c = cf.BMOC_Weekend_VM__c;
  	  a.BMOC_Evening__c = cf.BMOC_Evening__c;
  	  a.BMOC_Evening_VM__c = cf.BMOC_Evening_VM__c;
  	  a.BMOC_Daytime__c = cf.BMOC_Daytime__c;
  	  a.BMOC_Daytime_VM__c = cf.BMOC_Daytime_VM__c;
  	  a.Accompanied_By__c = cf.Accompanied_By__c;
  	  a.Accompanied_by_Name__c = cf.Accompanied_by_Name__c;
  	  a.Approve_iCat__c = cf.Approve_iCat__c;
  	  a.Approve_Nothing__c = cf.Approve_Nothing__c;
  	  a.Approve_Panoramic__c = cf.Approve_Panoramic__c;
  	  a.Approve_Consult__c = cf.Approve_Consult__c;
  	  
  	  try {
  	  	update a;
  	  } catch (Exception e) {
  	  	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('Trigger :: There was an Error running afterConsultForm');
        message.setUseSignature(false);
        message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString()+'\r'+e);
  	  }
  	}
  }    
}