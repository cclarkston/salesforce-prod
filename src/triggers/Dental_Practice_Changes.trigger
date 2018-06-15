trigger Dental_Practice_Changes on Dental_Practice__c (before update,after update, after insert) {
  if(trigger.isInsert) {
  	//create an implementation checklist for this practice
  	List<Implementation_Checklist__c> ic_list = new List<Implementation_Checklist__c>();
  	for(Dental_Practice__c dp : Trigger.new) {
  	  Implementation_Checklist__c ic = new Implementation_Checklist__c(Dental_Practice__c = dp.id);
  	  ic_list.add(ic);
  	}
  	insert ic_list;
  }

  if(trigger.isUpdate && trigger.isBefore) {
    for(Dental_Practice__c dp : Trigger.new) {
      Dental_Practice__c old_dp = Trigger.oldMap.get(dp.ID);
      //12/11/2014 Cm - changing this per a request from Dan McKelvey - Vantage office id setup moved to refer_to_this_practice
      if(old_dp.PSA_contract_completed__c==false && dp.PSA_contract_completed__c==true) {
        // dp.practice_status__c = 'Finished PSA'; 2016-06-21 AW - Removing updates to Practice_Status__c per Russell Balli (Also changed list of statuses so 'Finished PSA' doesn't exist anymore.)
        dp.display_to_vendor__c = true;
      }
      if(dp.brochure_number__c != null) {
	      if(old_dp.brochure_number__c!=dp.brochure_number__c) {
	      	//create a new marketing campaign
	      	String new_phone = dp.brochure_number__c;
	  	    new_phone = new_phone.replace('(','');
			new_phone = new_phone.replace(')','');
			new_phone = new_phone.replace(' ','');
			 new_phone = new_phone.replace('-','');
	        new_phone = new_phone.replace('#','');
	        new_phone = new_phone.replace('=','');
	        new_phone = new_phone.toUpperCase();
	      	ID rtype = [Select id From RecordType r where sobjecttype = 'Campaign' and Name = 'Generic Campaign'].id;
	      	Practice_Doctor__c pd = [Select id, First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c, first_last__c From Practice_Doctor__c where Dental_Practice__c = :dp.id limit 1];
	      	Campaign c = new Campaign(doctor_id__c = pd.id, practice_id__c = dp.id, recordtypeid = rtype, phone_number__c = new_phone,name = dp.name + ' Practice Privileges Jumpstart Brochure', Creative_Name__c = 'Jumpstart 1.0 Brochure', Media_Outlet_Vendor__c = 'Practice Privileges', Type = 'Brochure', Media__c = 'Insert', Media_Format__c = 'Brochure', Startdate = System.today(), status = 'In Progress', isactive  = true);
	      	Util_TriggerContext.setalreadyProcessed();
	      	try {
	      	  insert c;
	      	}
	      	catch (Exception e) {
	      	  
	      	}
	      }
      }
      if(old_dp.ClearVantage_Complete__c==false && dp.ClearVantage_Complete__c==true) {
      	  if(dp.ClearVantage_Effective_Date__c==null)
      	    dp.ClearVantage_Effective_Date__c = system.now();
      }
      if(old_dp.Refer_to_this_practice__c==false && dp.refer_to_this_practice__c==true) {
        // 2016-06-21 AW - Removing updates to Practice_Status__c per Russell Balli (Also changed list of statuses so 'Finished PSA' doesn't exist anymore.)
        // if(dp.practice_status__c!='Finished PSA' && dp.practice_status__c!='Finished Agreement')
        //   dp.practice_status__c = 'Finished Agreement';
      	if(dp.center_information__c==null) {
  	  	  dp.center_information__c.adderror('You must fill out a center before marking this practice as ready to refer');
		  dp.addError('You must fill out a center before marking this practice as ready to refer');
  	  	}	
  	  	/*if(dp.Vantage_OfficeID__c==null) {
  	      System.debug('No Office ID detected');
  	      dp.vantage_OfficeID__c = '-2';  	  	   	  	  
	      try {	      	
    	    myWs.sendOfficeInfo(dp.id);     	   
	      } catch(Exception e) {
	        System.debug('Callout error: '+ e);
	        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	        message.setReplyTo('cmcdowell@clearchoice.com');
	        message.setSubject('There was an Error calling Vantage API - New Practice ');
	 		message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
	      }		
  	  	}*/
      }
    }
  }
 
 
  if(trigger.isUpdate && trigger.isAfter) {
    for(Dental_Practice__c dp : Trigger.new) {  	  
  	  Dental_Practice__c old_dp = Trigger.oldMap.get(dp.ID);
  	  //see if we marked the referral checkbox
  	  //System.debug('Old ' + old_dp.Refer_to_this_practice__c);
  	  //System.debug('New ' + dp.refer_to_this_practice__c);
  	  //modified by cm 2014-09-16 - using psa contract completed now as the trigger for email
  	  if(old_dp.PSA_contract_completed__c==false && dp.PSA_contract_completed__c==true) {
  	  //if(old_dp.Refer_to_this_practice__c==false && dp.refer_to_this_practice__c==true) {
  	  	//moved this to the before update context
  	  	/*System.debug('Start Ref API Call');
  	  	//check to make sure we have a center filled out - otherwise throw an error
  	  	if(dp.center_information__c==null) {
  	  	  dp.center_information__c.adderror('You must fill out a center before marking this practice as ready to refer');
		  dp.addError('You must fill out a center before marking this practice as ready to refer');
  	  	}	
  	  	//make sure we don't already have an office ID from Vantage - send an API request if we don't
  	  	//disabled until ready for production environment
  	  	if(dp.Vantage_OfficeID__c==null) {
  	  	  System.debug('No Office ID detected');  	  	   	  	  
	      try {
    	    myWs.sendOfficeInfo(dp.id);     	   
	      } catch(Exception e) {
	        System.debug('Callout error: '+ e);
	        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	        message.setReplyTo('cmcdowell@clearchoice.com');
	        message.setSubject('There was an Error calling Vantage API - New Practice ');
	 		message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
	      }
  	    } //end vantage id is not null*/
  	    //send an email out to vendors that a new member has signed up for the practicepriviliges program
  	    Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
  	    //cm 2/10/2015 - restoring the old list per Nathaly.  this will remain until I cahnge the form
  	    //to allow for practices to do an individual sign up.
  	    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','nambos@clearchoice.com','dmckelvey@clearchoice.com','ger@myclearvantage.com','tonyrocker@hotmail.com'};
  	    //String[] toAddresses = new String[] {'ger@myclearvantage.com','rayh@c3ms.com','randy@wellnesshour.com','clearchoice@prosites.com','tonyrocker@hotmail.com','cmcdowell@clearchoice.com','nambos@clearchoice.com','dmckelvey@clearchoice.com'};
		//String[] toAddresses = new String[] {'ger@myclearvantage.com','rayh@c3ms.com','tonyrocker@hotmail.com','cmcdowell@clearchoice.com','nambos@clearchoice.com','dmckelvey@clearchoice.com'};
		//String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('cmcdowell@sfnoresponse.com');
		
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopments@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
//		mail.setSenderDisplayName('Practice Privileges Membership');
		mail.setSubject('New Practice Development Member');
		mail.setHtmlBody('You have a new member for the Practice Development program.  Please contact them as soon as possible.<br /><br />You can access their contact information <a href="https://c.na2.visual.force.com/apex/practice_privileges" style="color:blue;">here</a><br /><br />If you have any issues,  please contact Nathaly Ambos at 303-729-5054 or nambos@clearchoice.com');
		mail.setPlainTextBody('You have a new member for the Practice Development program.  Please contact them as soon as possible.<br /><br />You can access their contact information at https://c.na2.visual.force.com/apex/practice_privileges .     If you have any issues,  please contact Nathaly Ambos at 303-729-5054 or nambos@clearchoice.com');
		//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		Task t = new Task(WhatId = dp.id, OwnerId = Userinfo.getUserId(), Subject = 'New Practice Development Member', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
		try {
		  insert t;
		}
		catch (Exception e) {
		  	
		}
		//make sure we don't already have a username for ClearConnect - send an API request if we don't
		/*if(dp.ClearConnect_UserName__c==null) {
		  try {
		  	myWS.newCCOinfo(dp.id);		  	
		  }	catch(Exception e) {
	        System.debug('Callout error: '+ e);
	        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	        message.setReplyTo('cmcdowell@clearchoice.com');
	        message.setSubject('There was an Error calling ClearConnect API - New Practice ');
	 		message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
	      }
	      //create the campaign to hold these values
	      //modified by cm on 6/17/2014 - stopping the clearconnect thing - this is on hold.
	      try {	      	
	      	String cname = 'CConnect_' + dp.name;	      
	      	Dental_Practice__c dp2 = [select ClearConnect_UserName__c,Location_Code__c from Dental_Practice__c where id = :dp.id];
	      	String rid = [Select id,name From RecordType where SobjectType = 'Campaign' and name = 'Generic Campaign'].id;
	        Campaign c = new Campaign(Name = cname, startdate = System.today(), type = 'ClearConnect Referral', status = 'In Progress', Phone_number__c = dp2.Location_Code__c,
	          Creative_Name__c = 'ClearConnect Referral', Media_Format__c = 'ClearConnect Referral', isactive = true, recordtypeid = rid);
	        insert c;	        
	      } catch(Exception e) {
	      	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	        message.setReplyTo('cmcdowell@clearchoice.com');
	        message.setSubject('There was an Error creating ClearConnect Campaign');
	 		message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	      }
		}	*/				  	   
  	  } //end marked referral box
  	  //check for ClearViewTV - completion
  	  if(old_dp.ClearViewTV_complete__c==false && dp.ClearViewTV_complete__c==true) {
  	  	Practice_Doctor__c pd = [Select First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c, first_last__c From Practice_Doctor__c where Dental_Practice__c = :dp.id limit 1];
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();		
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','selterich@clearchoice.com','nambos@clearchoice.com','dhinkle@clearchoice.com','dmckelvey@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('cmcdowell@sfnoresponse.com');
		//mail.setSenderDisplayName('Practice Privileges Program');
		
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopments@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
		mail.setSubject('Practice Development - ClearViewTV Completed');
		mail.setHtmlBody('<h2>ClearViewTV has completed work on a Practice</h2><p style="font-weight:20pt;font-family:georgia;padding-left:20px;"><span style="font-weight:bold;width:150px;display:inline-block;">Practice Name :</span><span style="color:#5789AE;">' + dp.name + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Name : </span><span style="color:#5789AE;">' + pd.first_last__c + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Phone : </span><span style="color:#5789AE;">' + pd.phone__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">City :</span><span style="color:#5789AE;">' + dp.City__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">Website :</span><span style="color:#5789AE;">' + dp.Practice_Website__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">Date for Site Installation :</span><span style="color:#5789AE;">' + dp.ClearViewTV_site_installation_date__c + '</span></p>');
		mail.setPlainTextBody('ClearViewTV has completed work on a Practice.  Practice Name : ' + dp.name + ' Doctor Name : ' + pd.first_last__c + ' Date for Site Installation : ' + dp.ClearViewTV_site_installation_date__c );
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });			
  	  }
  	  //check for ClearTrain - completion
  	  //modified by cm on 2014-10-10 - Dan M requested I disable this
  	  /*if(old_dp.Cleartrain_complete__c==false && dp.Cleartrain_complete__c==true) {
  	  	Practice_Doctor__c pd = [Select First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c, first_last__c From Practice_Doctor__c where Dental_Practice__c = :dp.id limit 1];
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();		
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','selterich@clearchoice.com','nambos@clearchoice.com','dhinkle@clearchoice.com','dmckelvey@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('cmcdowell@sfnoresponse.com');
		
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopments@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
		//mail.setSenderDisplayName('Practice Privileges Program');
		mail.setSubject('Practice Privileges - Cleartrain Completed');
		mail.setHtmlBody('<h2>ClearTrain has completed work on a Practice</h2><p style="font-weight:20pt;font-family:georgia;padding-left:20px;"><span style="font-weight:bold;width:150px;display:inline-block;">Practice Name :</span><span style="color:#5789AE;">' + dp.name + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Name : </span><span style="color:#5789AE;">' + pd.first_last__c + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Phone : </span><span style="color:#5789AE;">' + pd.phone__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">City :</span><span style="color:#5789AE;">' + dp.City__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">Website :</span><span style="color:#5789AE;">' + dp.Practice_Website__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">When they went live with training :</span><span style="color:#5789AE;">' + dp.ClearTrain_live_training_date__c + '</span></p>');
		mail.setPlainTextBody('Cleartrain has completed work on a Practice.  Practice Name : ' + dp.name + ' Doctor Name : ' + pd.first_last__c + ' When they went live with training : ' + dp.ClearTrain_live_training_date__c );
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
  	  }*/
  	  //check for ClearWeb - completion
  	  if(old_dp.Clearweb_complete__c==false && dp.Clearweb_complete__c==true) {
  	  	Practice_Doctor__c pd = [Select First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c, first_last__c From Practice_Doctor__c where Dental_Practice__c = :dp.id limit 1];
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();		
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','selterich@clearchoice.com','nambos@clearchoice.com','dhinkle@clearchoice.com','dmckelvey@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('cmcdowell@sfnoresponse.com');
		
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopments@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
		//mail.setSenderDisplayName('Practice Privileges Program');
		mail.setSubject('Practice Development - ClearWeb Completed');
		mail.setHtmlBody('<h2>ClearWeb has completed work on a Practice</h2><p style="font-weight:20pt;font-family:georgia;padding-left:20px;"><span style="font-weight:bold;width:150px;display:inline-block;">Practice Name :</span><span style="color:#5789AE;">' + dp.name + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Name : </span><span style="color:#5789AE;">' + pd.first_last__c + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Phone : </span><span style="color:#5789AE;">' + pd.phone__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">City :</span><span style="color:#5789AE;">' + dp.City__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">Website :</span><span style="color:#5789AE;">' + dp.Practice_Website__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">When did the site go live :</span><span style="color:#5789AE;">' + dp.When_did_the_site_go_live__c + '</span></p>');
		mail.setPlainTextBody('ClearWeb has completed work on a Practice.  Practice Name : ' + dp.name + ' Doctor Name : ' + pd.first_last__c + ' When did the site go live : ' + dp.When_did_the_site_go_live__c );
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
  	  }
  	  //check for ClearVantage - completion
  	  if(old_dp.ClearVantage_Complete__c==false && dp.ClearVantage_Complete__c==true) {
  	  	Practice_Doctor__c pd = [Select First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c, first_last__c From Practice_Doctor__c where Dental_Practice__c = :dp.id limit 1];
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();		
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','selterich@clearchoice.com','nambos@clearchoice.com','dhinkle@clearchoice.com','dmckelvey@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopments@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
		mail.setReplyTo('cmcdowell@sfnoresponse.com');
//		mail.setSenderDisplayName('Practice Privileges Program');
		mail.setSubject('Practice Development - ClearVantage Completed');
		mail.setHtmlBody('<h2>ClearVantage has completed work on a Practice</h2><p style="font-weight:20pt;font-family:georgia;padding-left:20px;"><span style="font-weight:bold;width:150px;display:inline-block;">Practice Name :</span><span style="color:#5789AE;">' + dp.name + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Name : </span><span style="color:#5789AE;">' + pd.first_last__c + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Phone : </span><span style="color:#5789AE;">' + pd.phone__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">City :</span><span style="color:#5789AE;">' + dp.City__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">Website :</span><span style="color:#5789AE;">' + dp.Practice_Website__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">When did the practice go live :</span><span style="color:#5789AE;">' + dp.ClearVantage_Live_Date__c + '</span></p>');
		mail.setPlainTextBody('ClearVantage has completed work on a Practice.  Practice Name : ' + dp.name + ' Doctor Name : ' + pd.first_last__c + ' When did the practice go live : ' + dp.ClearVantage_Effective_Date__c );
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
		//update the center gp count
		try {
			Center_Information__c ci = [select id,GP_Office_Count__c from Center_Information__c where id = :dp.Center_Information__c];
			Integer current_count = 0;
			if(ci.gp_office_count__c!=null)
			  current_count = ci.gp_office_count__c.intValue();
			current_count++;
			ci.gp_office_count__c = current_count;
			update ci;
		}
		catch (Exception e) {
		  System.debug('Callout error: '+ e);
	      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	      message.setReplyTo('cmcdowell@clearchoice.com');
	      message.setSubject('There was an Error updating GP office #');
	      message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
		}
  	  }
  	  if(old_dp.ClearVantage_Complete__c==true && dp.ClearVantage_Complete__c==false) {	
		//update the center gp count
		try {
			Center_Information__c ci = [select id,GP_Office_Count__c from Center_Information__c where id = :dp.Center_Information__c];
			Integer current_count = 0;
			if(ci.gp_office_count__c!=null)
			  current_count = ci.gp_office_count__c.intValue();
			current_count--;
			ci.gp_office_count__c = current_count;
			update ci;
		}
		catch (Exception e) {
		  System.debug('Callout error: '+ e);
	      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	      message.setReplyTo('cmcdowell@clearchoice.com');
	      message.setSubject('There was an Error updating GP office #');
	      message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
		}
  	  }
  	  //check for Clearconnect - completion
  	  /*if(old_dp.ClearConnect_Complete__c==false && dp.ClearConnect_Complete__c==true) {
  	  	Practice_Doctor__c pd = [Select First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c, first_last__c From Practice_Doctor__c where Dental_Practice__c = :dp.id limit 1];
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();		
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','selterich@clearchoice.com','nambos@clearchoice.com','dhinkle@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('cmcdowell@sfnoresponse.com');
		//mail.setSenderDisplayName('Practice Privileges Program');
		
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopments@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
		mail.setSubject('Practice Privileges - ClearConnect Completed');
		mail.setHtmlBody('<h2>ClearConnect has completed work on a Practice</h2><p style="font-weight:20pt;font-family:georgia;padding-left:20px;"><span style="font-weight:bold;width:150px;display:inline-block;">Practice Name :</span><span style="color:#5789AE;">' + dp.name + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Name : </span><span style="color:#5789AE;">' + pd.first_last__c + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Phone : </span><span style="color:#5789AE;">' + pd.phone__c + '</span><br /><br /><span style="font-weight:bold;width:200px;display:inline-block;">When did the practice go live :</span><span style="color:#5789AE;">' + dp.ClearConnect_Live_Date__c + '</span></p>');
		mail.setPlainTextBody('ClearConnect has completed work on a Practice.  Practice Name : ' + dp.name + ' Doctor Name : ' + pd.first_last__c + ' When did the practice go live : ' + dp.ClearConnect_Live_Date__c);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
  	  }*/
  	  
  	} //end for trigger.new
  }  //end if isinsert
} //end trigger