/*
modified by cm on 2012-3-2
adding some code in here to keep the cancelled date field current on an opportunity record

modified by cm on 2017-03-28
pulled some code that was updating campaignmemberstatus
*/
trigger OpptyAfter on Opportunity (after insert, after update) {    
  
  Set<ID> opptyIds = Trigger.newmap.keyset();
  Set<ID> contactIds = new Set<ID>();
  Set<ID> accIds = new Set<ID>();
  Map<Id, Opportunity> contactToOppMap = new Map<Id, Opportunity>(); 
  Map<Id, Opportunity> accountToOppMap = new Map<Id, Opportunity>();
  
  public void send_failure_message(String msg_txt, String msg_subject) {
  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	mail.setToAddresses(toAddresses);
	mail.setReplyTo('cmcdowell@acme.com');
	mail.setSenderDisplayName('Apex error message');
	mail.setSubject(msg_subject);
	mail.setPlainTextBody(msg_txt);
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  } 
	
  if(!Util_TriggerContext.hasalreadyProcessed()) {
	for(Opportunity o: Trigger.new) {
      accIds.add(o.AccountId);
      accountToOppMap.put(o.AccountId, o);
	}
	    
	if(Trigger.isInsert) {		    
    
      Set<String> call_back_list = new Set<String> {'2nd Consult','30 Day Pipeline','60 Day Pipeline','90 Day Pipeline','Medical Clearance','Doctor Declined Case','Refered Out to Doctor',
      	 'No Longer Interested','Not a Candidate','No Money','Walked Out','Treatment Received Elsewhere'};
      //if the consult record has a result type in the call back list,  we need to update it to Prostho Exam Scheduled Call Back
      List<Account> all_accounts = [select id,consult_result__c,createddate from Account where id in :accIds]; 
      for(Account a : all_accounts) {
        if(call_back_list.contains(a.consult_result__c)) {
      	  //check to see if the start is a same day start.
      	  Opportunity o = accounttooppmap.get(a.id);
      	  if(o.createddate.issameday(a.createddate))
      	    a.consult_result__c = 'Prostho Exam Scheduled';
      	  else
            a.consult_result__c = 'Prostho Exam Scheduled Call Back';
        }       
      }
      try {
    	Boolean util_state = Util_TriggerContext.hasalreadyProcessed(); 
        Util_TriggerContext.setalreadyProcessed();
        update all_accounts;
        Util_TriggerContext.alteralreadyprocessed(util_state);
      } catch(Exception e) {
		send_failure_message(e.getMessage() + ' ' + e,'Opportunity After Trigger - Account Update Issue');	    
      }    
	} // end Trigger.isInsert
	
	//List<Opportunity> update_list = new List<Opportunity>();
	Map<ID,Opportunity> update_map = new Map<ID,Opportunity>();
	Opportunity upd_op;
	
	if(Trigger.isUpdate) {
	  Set<Id> cancellation_list = new Set<Id> ();
	  Set<Id> owner_changed_list = new Set<Id> ();
	  map<ID,ID> owner_change_map = new map<ID,ID> ();
	  
	  //we'll need to know if a treatment plan has been selected for one of the checks down below - build a map to store treatment plan count by opp id
	  Map<ID,Integer> tpcount_map = new Map<ID,Integer> ();
	  for(AggregateResult ar : database.query('select opportunity__c,count(id) tp_count from Treatment_plan__c where opportunity__c in :opptyIds group by opportunity__c')) {
	  	tpcount_map.put((ID)ar.get('opportunity__c'),(Integer)ar.get('tp_count'));
	  }
	  	  	  
	  for (Opportunity new_opp : trigger.new) {
	    Opportunity old_opp = trigger.oldmap.get(new_opp.id);
	    
	    //check to see if the current_prosth_exam_owner__c field has been changed
	    if(new_opp.current_prosth_owner__c != old_opp.current_prosth_owner__c && old_opp.current_prosth_owner__c!=null) {
	      owner_changed_list.add(new_opp.id);
	      owner_change_map.put(new_opp.id,new_opp.current_prosth_owner__c);
	    }
	    
	    //variable flags for certain conditional fields set below	    
	    Boolean tp_check = false;
	    if(tpcount_map.get(new_opp.id)!=null)
	      //old opp start value check,  is due to legacy data records prior to treatment plan process
	      if(tpcount_map.get(new_opp.id)>0 || old_opp.start_value__c >0)
	        tp_check = true;
	    Boolean payments_setup = false;
	    System.debug('Outstanding Balance : ' + new_opp.Outstanding_Balance_incl_anticipated__c);
	    if(new_opp.Outstanding_Balance_incl_anticipated__c<=0)
	      payments_setup = true;	      
	    boolean fully_paid = false;
	    if(new_opp.total_payments__c == new_opp.negotiated_total_amount__c && new_opp.negotiated_total_amount__c > 0)
	      fully_paid = true;
	    Boolean down_payment = false;
	    if(new_opp.total_payments__c>=1000 || fully_paid)
	      down_payment = true;
	      
	    //added 6/6/2018 by cm - valid status check for Scott
	    if(down_payment && tp_check && payments_setup && new_opp.valid_date__c==null) {
	      if(update_map.get(new_opp.id)==null) {
	        upd_op = new Opportunity(id = new_opp.id, valid_date__c = System.today());
	        //update_list.add(upd_op);
	        update_map.put(new_opp.id,upd_op);
	      } else 
	      	update_map.get(new_opp.id).valid_date__c = System.today();	      
	    } else if(!(down_payment && tp_check && payments_setup) && new_opp.valid_date__c!=null) {
	      //see if we need to clear valid date (1 day check)
	      if(new_opp.valid_date__c.daysBetween(System.today())<1) {
	      	if(update_map.get(new_opp.id)==null) {
	          upd_op = new Opportunity(id = new_opp.id, valid_date__c = null);
	          //update_list.add(upd_op);
	          update_map.put(new_opp.id,upd_op);
	      	} else
	      	  update_map.get(new_opp.id).valid_date__c = null;
	      }	
	    }	    
	    
	    /*modified by cm on 2016-1-5 
	      rule is being revised to total payments > 1000 and outstanding balance <= 0,  mark this as paid
	      from a data governance decision in the last week of December
	    */
	    //checking to see if we've recieved the $1000 prosth exam fee.	    
	    //if(new_opp.total_net_payments__c>=1000 && old_opp.total_net_payments__c<1000) {
	    //if(new_opp.Total_Payments__c>=1000 && old_opp.Total_Payments__c<1000 && old_opp.prosth_exam_paid__c == false) {
	    //if(new_opp.Total_Payments__c>=1000 && new_opp.Outstanding_Balance_incl_anticipated__c<=0 && new_opp.prosth_exam_paid__c == false) {
	    // modified by cm on 5/31/2018 - check to see if 100% payment has been achieved.  If so mark as paid.  Only used when treatment amount > 0
	    if(old_opp.prosth_exam_paid__c == false && new_opp.Outstanding_Balance_incl_anticipated__c<=0 && 
	      (new_opp.Total_Payments__c>=1000 || fully_paid)) {
	      if(update_map.get(new_opp.id)==null) {
	        upd_op = new Opportunity(id = new_opp.id, prosth_exam_paid__c = true, prosth_exam_paid_date__c = System.today());
	        //update_list.add(upd_op);
	        update_map.put(new_opp.id,upd_op);
	      } else {
	        update_map.get(new_opp.id).prosth_exam_paid__c = true;
	        update_map.get(new_opp.id).prosth_exam_paid_date__c = System.today();
	      }
	    }	    	    	  
	    
	     //checking to see if we dropped below 1,000 in collected payments - red user error or trying to cheat the system
	     //note - haveing outstanding balance go above 0 is not going to cancel out a start.  That will be managed by the audit team for now.
	    //if(new_opp.total_net_payments__c>=1000 && old_opp.total_net_payments__c<1000) {
	    if(new_opp.prosth_exam_paid__c==true && (new_opp.total_payments__c<1000 && !fully_paid)) {
	      if(old_opp.prosth_exam_paid_date__c.daysBetween(System.today())<1) {
	      	if(update_map.get(new_opp.id)==null) {
	          upd_op = new Opportunity(id = new_opp.id, prosth_exam_paid__c = false, prosth_exam_paid_date__c = null);
	          //update_list.add(upd_op);
	          update_map.put(new_opp.id,upd_op);
	      	} else {
	      	  update_map.get(new_opp.id).prosth_exam_paid__c = false;
	      	  update_map.get(new_opp.id).prosth_exam_paid_date__c = null;
	      	}
	      }	
	    }
	    /*if(new_opp.Total_Payments__c<1000 && old_opp.Total_Payments__c>=1000 && old_opp.prosth_exam_paid__c == true) {
	      //modified by cm on 5/31/2018 - team has requested that this only be allowed to reset if it's within 1 day of the paid date
	      if(old_opp.prosth_exam_paid_date__c.daysBetween(System.today())<1) {
	      	if(update_map.get(new_opp.id)==null) {
	          upd_op = new Opportunity(id = new_opp.id, prosth_exam_paid__c = false, prosth_exam_paid_date__c = null);
	          //update_list.add(upd_op);
	          update_map.put(new_opp.id,upd_op);
	      	} else {
	      	  update_map.get(new_opp.id).prosth_exam_paid__c = false;
	          update_map.get(new_opp.id).prosth_exam_paid_date__c = null;	
	      	}	      	  
	      }	    
	    }  //modified by cm on 5/31/2018 - plans less than 1000 need to be tested for 100% payment now - which means I also need to check for this being undone. request from Scott Lawrence 
	    else if(old_opp.prosth_exam_paid__c == true && new_opp.negotiated_total_amount__c < 1000 && !fully_paid) {
	      //modified by cm on 5/31/2018 - team has requested that this only be allowed to reset if it's within 1 day of the paid date
	      if(old_opp.prosth_exam_paid_date__c.daysBetween(System.today())<1) {
	      	if(update_map.get(new_opp.id)==null) {
	          upd_op = new Opportunity(id = new_opp.id, prosth_exam_paid__c = false, prosth_exam_paid_date__c = null);
	          //update_list.add(upd_op);
	          update_map.put(new_opp.id,upd_op);
	      	} else {
	      	  update_map.get(new_opp.id).prosth_exam_paid__c = false;
	      	  update_map.get(new_opp.id).prosth_exam_paid_date__c = null;
	      	}
	      }
	    }*/
	    
	    //new code to look for records that need the cancel date updated - CM
	    //modified by cm on 5/31/2018 - cancel date field will only be updated if it's currently null now - pre Scott Lawrence request 
	    if(new_opp.StageName == 'Cancelled Not Rescheduled' && (old_opp.StageName != 'Cancelled Not Rescheduled'
	      && old_opp.Completed_Stage__c <> 'Not Moving Forward' && old_opp.Completed_Stage__c <> 'Financing Difficulty'
	      && old_opp.Completed_Stage__c <> 'Patient Non Responsive' && old_opp.Completed_Stage__c <> 'Non Candidate'
	      && old_opp.Completed_Stage__c <> 'Doctor Declined Case') && new_opp.cancel_date__c==null) {
	      if(update_map.get(new_opp.id)==null) {
            upd_op = new Opportunity(id = new_opp.Id,cancel_date__c = Datetime.now());
            //update_list.add(upd_op);
            update_map.put(new_opp.id,upd_op);                
	      }  else
	        update_map.get(new_opp.id).cancel_date__c = datetime.now();
	      cancellation_list.add(new_opp.Id);   
	    }
	    else if((new_opp.Completed_Stage__c == 'Not Moving Forward' || new_opp.Completed_Stage__c == 'Financing Difficulty'
	      || new_opp.Completed_Stage__c == 'Patient Non Responsive' || new_opp.Completed_Stage__c == 'Non Candidate'
	      || new_opp.Completed_Stage__c == 'Doctor Declined Case') && (old_opp.StageName != 'Cancelled Not Rescheduled'
	      && old_opp.Completed_Stage__c <> 'Not Moving Forward' && old_opp.Completed_Stage__c <> 'Financing Difficulty'
	      && old_opp.Completed_Stage__c <> 'Patient Non Responsive' && old_opp.Completed_Stage__c <> 'Non Candidate'
	      && old_opp.Completed_Stage__c <> 'Doctor Declined Case') && new_opp.cancel_date__c==null) {
	      if(update_map.get(new_opp.id)==null) {
            upd_op = new Opportunity(id = new_opp.Id,cancel_date__c = Datetime.now());
            //update_list.add(upd_op);
            update_map.put(new_opp.id,upd_op);
	      } else 
	        update_map.get(new_opp.id).cancel_date__c = datetime.now();
          cancellation_list.add(new_opp.Id);        
	    }
	    
	    
	    //check to see if any opportunities moved into a cancellation state
	    if(cancellation_list.size()>0) {
	      //if so pull a list of anticipated payments tied to these records so we can update them.
	      List<CCPayment__c> payment_updates = new List<CCPayment__c>();
	      for(CCPayment__c payment : [select id,Payment_Status__c from CCPayment__c where opportunity__c in :cancellation_list and 
	    	payment_status__c in ('Anticipated','Anticipated Promise Note')]) {
	    	if(payment.payment_status__c == 'Anticipated')
	    	  payment.payment_status__c = 'Anticipated Payment Cancelled';
	    	else if(payment.payment_status__c=='Anticipated Promise Note')
	    	  payment.payment_status__c = 'Anticipated Prom Note Payment Cancelled';
	    	payment_updates.add(payment);
	      }
	      if(payment_updates.size()>0)
	    	update payment_updates;
	    }
	    
	    //check to see if we had an owner change
	    if(owner_changed_list.size()>0) {
	      //pull a list of anticipated payments,  and update the pec__c field
	      List<CCPayment__c> payment_list = [select id,opportunity__c,pec__c from CCPayment__c where opportunity__c in :owner_changed_list and payment_status__c in ('Anticipated','Anticipated Promise Note')];
	      for(CCPayment__c cc : payment_list) {
	      	cc.pec__c = owner_change_map.get(cc.opportunity__c);
	      }
	      if(payment_list.size()>0)
	        update payment_list;
	    }	    
	           
	  } // end for lopp	  	  	    	    
	}  //end isUpdate
	 
	//adjusting the order here to try and prevent record locks
	if(update_map.values().size()>0) {
      try {
	    update update_map.values();
	  } catch (Exception e) {
	  	send_failure_message(e.getMessage(),'Oppurtunity Trigger After - Opportunity Cancel Date Update X');
      }
	}     
	//insert oppContactRoleList;
  } //end utiltriggercontext
}