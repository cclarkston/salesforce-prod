trigger DoctorChange on Practice_Doctor__c (before delete,before insert,before update) {
  if(trigger.isinsert || trigger.isupdate) {
  	for(Practice_Doctor__c pd : Trigger.new) {
  	  if(pd.first_name__c != null) {
	    String first_letter = pd.first_name__c.substring(0,1);
		String replacement_letter = first_letter.toUpperCase();
		if(!first_letter.equals(replacement_letter))
		  pd.first_name__c = pd.first_name__c.replaceFirst(first_letter,replacement_letter);
	  }
	  
	  if(pd.last_name__c != null) {
	    String first_letter = pd.last_name__c.substring(0,1);
		String replacement_letter = first_letter.toUpperCase();
		if(!first_letter.equals(replacement_letter))
		  pd.last_name__c = pd.last_name__c.replaceFirst(first_letter,replacement_letter);
	  }
	  
	  if(pd.middle__c != null) {
	    String first_letter = pd.middle__c.substring(0,1);
		String replacement_letter = first_letter.toUpperCase();
		if(!first_letter.equals(replacement_letter))
		  pd.middle__c = pd.middle__c.replaceFirst(first_letter,replacement_letter);
	  }
	  
	  if(pd.title__c != null) {
	    String first_letter = pd.title__c.substring(0,1);
		String replacement_letter = first_letter.toUpperCase();
		if(!first_letter.equals(replacement_letter))
		  pd.title__c = pd.title__c.replaceFirst(first_letter,replacement_letter);
	  }
	  
	  if(pd.suffix__c != null) {
	    String first_letter = pd.suffix__c.substring(0,1);
		String replacement_letter = first_letter.toUpperCase();
		if(!first_letter.equals(replacement_letter))
		  pd.suffix__c = pd.suffix__c.replaceFirst(first_letter,replacement_letter);
	  }
  	}
  }	
	
  if (Trigger.isDelete) {
  	Set<ID> deleted_docs = new Set<Id>();
  	//we need to remove any pp_workshop_members for this doctor
  	for (Practice_Doctor__c pd : Trigger.old) {
      deleted_docs.add(pd.id);
    }
    
    List<PP_Workshop_Member__c> member_delete_list = [select id from PP_Workshop_Member__c where practice_doctor__c in :deleted_docs];
    System.debug('Attempting to delete ' + member_delete_list.size() + ' pp_workshop_member__c records due to doctor removal');
    try {
      if(member_delete_list.size()>0)
        delete member_delete_list;
    }
    catch (Exception e) {
  	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	  String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	  mail.setToAddresses(toAddresses);
	  mail.setReplyTo('cmcdowell@sfnoresponse.com');
	  mail.setSenderDisplayName('Apex error message');
	  mail.setSubject('Doctor Change Trigger Error');
	  mail.setPlainTextBody('Unable to remove workshop members ' + e.getMessage() + '/r/n' + member_delete_list);
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  }
}