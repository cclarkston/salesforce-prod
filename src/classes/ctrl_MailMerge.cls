public with sharing class ctrl_MailMerge {
  public Lead l;
  public Account a;
  //public String letter_output;
  public String task_subject;
  public Integer form_num {get; set;}
  
  public Pagereference update_task_entries() {
  	Task t = new Task();                    
    if(l.convertedcontactid==null)
      t = new Task(WhoId = l.id, OwnerId = Userinfo.getUserId(), Subject = task_subject, Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
    else
      t = new Task(WhoId = l.convertedcontactid, OwnerId = Userinfo.getUserId(), Subject = task_subject, Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
    try {          
      insert t;
    } catch (System.DmlException e) {
      for (Integer i = 0; i < e.getNumDml(); i++) {
        // Process exception here 
        System.debug('ID : ' + e.getDmlId(i) + ' Msg : ' +  e.getDmlMessage(i) + ' Index : ' + e.getDmlIndex(i)); 
      }
    }
    return null;
  }
  
  public ctrl_MailMerge () {
  	/*if(apexpages.currentpage().getparameters().get('action')==null)
      action = 'single_print';
    else
      action = apexpages.currentpage().getparameters().get('action');*/
    if(apexpages.currentpage().getparameters().get('form_num')==null)
      form_num = 1;
    else
      form_num = Integer.valueOf(apexpages.currentpage().getparameters().get('form_num'));
    if(apexpages.currentpage().getparameters().get('id')<>null)
      l = [select l.center__r.call_center_marketing__c,l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, l.Center__r.City__c,l.convertedcontactid,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.language_spoken__c,l.center__c,l.center__r.name from lead l where id = :apexpages.currentpage().getparameters().get('id')];
    if(apexpages.currentpage().getparameters().get('aid')<>null)
      a = [select a.center__r.call_center_marketing__c,a.Center__r.Zip_Code__c, a.Center__r.Street_2__c, a.Center__r.Street_1__c, a.Center__r.State__c, a.Center__r.City__c,a.name,a.firstname,a.lastname,a.billingstreet,a.billingstate,a.billingcity,a.billingpostalcode,a.center__r.full_address__c,a.center__r.name,a.owner.name,a.center__c from account a where id = :apexpages.currentpage().getparameters().get('aid')];
    if(form_num==1)
  	  task_subject = 'BCP Letter';
    else if(form_num==2 || form_num == 4)
  	  task_subject = 'Welcome Letter';    
    else if(form_num==3)          
  	  task_subject = 'Seminar Letter';    
  }
  
  public String getsingle_print() {
  	String return_val;
  	Ctrl_BulkPrintLetters bulk_con = new Ctrl_BulkPrintLetters();
  	if(form_num==1)  {
  	  Center_Information__c ci = [select id,bcp_center__c from Center_Information__c where id = :l.center__c];
  	  if(ci.bcp_center__c==null) 
  	    //return_val = bulk_con.generate_new_BCP_letter(l);
  	    //return_val = bulk_con.generate_BCP_letter_v5_14(l);
  	    if(l.pre_screen__c=='Green' || l.pre_screen__c=='Yellow' || l.pre_screen__c=='Red')
  	      return_val = bulk_con.generate_BCP_letter_v6_1(l);
  	    else
  	      return_val = bulk_con.generate_BCP_letter_v6_1_no_prescreen(l);
  	  else {
  	  	Center_Information__c bcp_center = [select id,Letter_Address__c,call_center_marketing__c,BCP_Center__c,zip_code__c,street_2__c,street_1__c,state__c,city__c from Center_Information__c where id = :ci.bcp_center__c];
  	  	//return_val = bulk_con.generate_network_BCP_letter(l, bcp_center);
  	  	//return_val = bulk_con.generate_network_BCP_letter_v5_14(l,bcp_center);
  	  	if(l.pre_screen__c=='Green' || l.pre_screen__c=='Yellow' || l.pre_screen__c=='Red')
  	  	  return_val = bulk_con.generate_network_BCP_letter_v6_1(l,bcp_center);
  	  	else
  	  	  return_val = bulk_con.generate_network_BCP_letter_v6_1_no_prescreen(l,bcp_center);
  	  }
  	}
  	if(form_num==2) {
  		//if(l.Language_Spoken__c=='Spanish')
  		  //return_val = bulk_con.generate_spanish_welcome_letter(l);
  		//else
  		  //return_val = bulk_con.generate_new_welcome_letter(l);
  		  //return_val = bulk_con.generate_welcome_letter_v5_14(l);
  	  Datetime move_date = datetime.newinstance(2015,12,7,0,0,0);  	  
      if(l.pre_screen__c=='Green' || l.pre_screen__c=='Yellow' || l.pre_screen__c=='Red') {
      	if(l.center__r.name=='Miami Fort Lauderdale' && l.DateTime_Consult_Scheduled__c >= move_date && System.now() < move_date)
          return_val = bulk_con.generate_welcome_letter_v6_1_FTL(l);
        else
  	      return_val = bulk_con.generate_welcome_letter_v6_1(l);
      }
  	  else {
  	  	if(l.center__r.name=='Miami Fort Lauderdale' && l.DateTime_Consult_Scheduled__c >= move_date && System.now() < move_date)
  	      return_val = bulk_con.generate_welcome_letter_v6_1_no_prescreen_FTL(l);
  	    else
  	      return_val = bulk_con.generate_welcome_letter_v6_1_no_prescreen(l);
  	  }
  	}
  	if(form_num==3) 
  	  return_val = bulk_con.generate_seminar_letter(l);
    if(form_num==4) {
      //welcome letter for a consult (account) record - need to retrieve the consult inventory block that goes with this first
      try {
      	Consult_Inventory__c cinv = [select apt_date__c,start_hour_int__c,start_minute_int__c from Consult_Inventory__c where scheduled_account__c = :a.id and apt_date__c >= today order by apt_date__c desc limit 1];
      	return_val = bulk_con.generate_consult_welcome_letter_v6_1(a,cinv);
      } catch (Exception e) {
      	return_val = 'Error producing letter - ' + e;
      }
    }  	  
  	return return_val;
  }
}